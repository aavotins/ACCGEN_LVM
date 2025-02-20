# vistu vanaga izplatības modeļa parametrizācija
# Apraksts: ./RScript/Readme_RScript.md un projekta 2024. gada pārskatā.
# Sākumā izveido nepieciešamās direktorijas, tad darba sesijai pievieno pakotnes, 
# tālāk tiek veiktas darbības izplatības modeļa parametrizācijai, tā izvērtēšanai 
# un sīka rezultātu pēcapstrāde

# direktorijas -----


dir.create("./SuguModeli/GridSearch_Models/")
dir.create("./SuguModeli/GridSearch_Tables/")
dir.create("./SuguModeli/BestCV/")
dir.create("./SuguModeli/BestComb/")
dir.create("./SuguModeli/BestHSmap/")
dir.create("./SuguModeli/BestThresholds/")
dir.create("./SuguModeli/BestROCs/")
dir.create("./SuguModeli/BestVarImp/")
dir.create("./SuguModeli/Null_reference/")
dir.create("./SuguModeli/Null_models/")
dir.create("./SuguModeli/Beigam_IzvelesAttels/")
dir.create("./SuguModeli/Beigam_KarteNebal/")
dir.create("./SuguModeli/MarginalResponses/")
dir.create("./SuguModeli/Pic_VarImp/")
dir.create("./SuguModeli/BestHSbinaryMaps/")

# pakotnes -----

library(plotROC)
library(ecospat)
library(maxnet)
library(tidyverse)
library(terra)
library(arrow)
library(usdm)
library(maps)
library(rasterVis)
library(readxl)
library(SDMtune)
library(ENMeval)
library(zeallot)
library(openxlsx)
library(ggview)
library(scales)
library(ggtext)

# sagatavošanās -----

## egvs ----

egv_faili=data.frame(egv_fails=list.files(path="./Rastri_100m/Scaled/",
                                          pattern=".tif$"),
                     egv_cels=list.files(path="./Rastri_100m/Scaled/",
                                         pattern=".tif$",full.names = TRUE))

egv_izvelei=read_excel("./SuguModeli/EGVselection/EGV_ACCGEN.xlsx")

egv_izvelei2=egv_izvelei %>% 
  filter(!is.na(final_VIF))

egv_faili=egv_faili %>% 
  right_join(egv_izvelei2,by=c("egv_fails"="scale_NAME"))

egvs=terra::rast(egv_faili$egv_cels)
names(egvs)=egv_faili$egv_id



## apmācību dati ----

treninklatbutnes=read_parquet("./SuguModeli/ApmacibuDati/TrainingPresence/TrainPres_ACCGEN.parquet")
treninklatbutnes=treninklatbutnes %>% 
  mutate(y=as.numeric(y)) %>% 
  dplyr::select(x,y)

treninfons=read_parquet("./SuguModeli/ApmacibuDati/TrainingBackground/TrainBg_ACCGEN.parquet")
treninfons=treninfons %>% 
  mutate(y=as.numeric(y)) %>% 
  dplyr::select(x,y)


trenin_dati <- prepareSWD(species = suga,
                          p = treninklatbutnes,
                          a = treninfons,
                          env = egvs)
trenin_dati=addSamplesToBg(trenin_dati)

block_folds <- get.block(occ = trenin_dati@coords[trenin_dati@pa == 1, ], 
                         bg = trenin_dati@coords[trenin_dati@pa == 0, ])

## testa dati ----

testklatbutnes=read_parquet("./SuguModeli/ApmacibuDati/TestingPresence/TestPres_ACCGEN.parquet")
testklatbutnes=testklatbutnes %>% 
  ungroup() %>% 
  mutate(y=as.numeric(y)) %>% 
  dplyr::select(x,y)

testfons=read_parquet("./SuguModeli/ApmacibuDati/TestingBackground/TestBg_ACCGEN.parquet")
testfons=testfons %>% 
  mutate(y=as.numeric(y)) %>% 
  dplyr::select(x,y)


testa_dati=prepareSWD(species=suga,
                      p = testklatbutnes,
                      a = testfons,
                      env = egvs)

rm(treninklatbutnes)
rm(treninfons)
rm(testklatbutnes)
rm(testfons)


# Grid Search ----
print(paste0("Uzsāku modelēšanu: ",Sys.time()))

sakummodelis <- train(method = "Maxnet", 
                      data = trenin_dati,
                      test=testa_dati,
                      fc="lq",
                      folds = block_folds)

print(paste0("Uzsāku grid search: ",Sys.time()))

# burtu secībai ir nozīme!
fc_lqph <- list(reg = c(0.2, 1/3, 0.5, 0.75, 1, 1.25, 2, 3, 5, 7.5, 10), 
                fc = c("l", "lq", "lp", "lqp", "qp","lh","qh","lqh","lhp","qhp","lqhp"))
fc_lqp <- list(reg = c(0.2, 1/3, 0.5, 0.75, 1, 1.25, 2, 3, 5, 7.5, 10), 
               fc = c("l", "lq", "lp", "lqp", "qp","q"))
fc_lq <- list(reg = c(0.2, 1/3, 0.5, 0.75, 1, 1.25, 2, 3, 5, 7.5, 10), 
              fc = c("l", "lq", "q"))

izveles_rezgis <- function(objekts) {
  rezA <- try(gridSearch(objekts, 
                         hypers = fc_lqph, 
                         metric = "tss"), silent = TRUE)
  if (inherits(rezA, 'try-error')) {
    rezB <- try(gridSearch(objekts, 
                           hypers = fc_lqp, 
                           metric = "tss"), silent = TRUE)
    if (inherits(rezB, 'try-error')) {
      rezC <- gridSearch(objekts, 
                         hypers = fc_lq, 
                         metric = "tss")
      return(rezC)
    }
    return(rezB)
  }
  return(rezA)
}

meklesanas_rezgis <- izveles_rezgis(sakummodelis)
write_rds(meklesanas_rezgis,paste0("./SuguModeli/GridSearch_Models/GSModeli_",suga,".RDS"))
rm(sakummodelis)

# izveles tabula ----
print(paste0("Uzsāku izvēles tabulu: ",Sys.time()))

izveles_tabula=meklesanas_rezgis@results
izveles_tabula$IndepTest_auc=NA_real_
izveles_tabula$IndepTest_tss=NA_real_

darbiba_auc=function(numurs){
  rez=try(auc(combineCV(meklesanas_rezgis@models[[numurs]]),test=testa_dati))
  if (inherits(rez, 'try-error')) {
    return(NA)
  }
  return(rez)
}
darbiba_tss=function(numurs){
  rez=try(tss(combineCV(meklesanas_rezgis@models[[numurs]]),test=testa_dati))
  if (inherits(rez, 'try-error')) {
    return(NA)
  }
  return(rez)
}

for(i in 1:nrow(izveles_tabula)){
  print(i)
  fin_auc=darbiba_auc(i)
  izveles_tabula$IndepTest_auc[i]=fin_auc
  fin_tss=darbiba_tss(i)
  izveles_tabula$IndepTest_tss[i]=fin_tss
  #print(paste0("independent AUC: ",fin_auc))
  #print(paste0("independent TSS: ",fin_tss))
}
names(izveles_tabula)=c("fc","reg","train_TSS","validation_TSS","diff_TSS","IndepTest_auc","IndepTest_tss")
write.xlsx(izveles_tabula,paste0("./SuguModeli/GridSearch_Tables/GSTabula_",suga,".xlsx"))

# labaka noskaidrosana ----
print(paste0("Izvēlos labāko: ",Sys.time()))

labakajam_modelim=izveles_tabula %>% 
  mutate(rinda=as.numeric(rownames(.))) %>% 
  filter(IndepTest_tss==max(IndepTest_tss,na.rm=TRUE)) %>% 
  filter(diff_TSS==min(diff_TSS,na.rm=TRUE)) %>% 
  filter(validation_TSS==max(validation_TSS,na.rm=TRUE)) %>% 
  filter(nchar(fc)==min(nchar(fc)))
labaka_numurs=labakajam_modelim$rinda

# krosvalidetais ----
print(paste0("Saglabāju labāko CV: ",Sys.time()))

labakais_CV=meklesanas_rezgis@models[[labaka_numurs]]
write_rds(labakais_CV,paste0("./SuguModeli/BestCV/BestCV_",suga,".RDS"))

# kombinetais ----
print(paste0("Saglabāju labāko kombinēto: ",Sys.time()))

labakais_comb=combineCV(meklesanas_rezgis@models[[labaka_numurs]])
write_rds(labakais_comb,paste0("./SuguModeli/BestComb/BestComb_",suga,".RDS"))
rm(meklesanas_rezgis)


# projekcija ----
print(paste0("Saglabāju HS projekciju: ",Sys.time()))

map_best <- predict(labakais_comb,
                    data = egvs,
                    type = "cloglog",
                    file = paste0("./SuguModeli/BestHSmap/BestHSmap_",suga,".tif"),
                    overwrite=TRUE)

#terra::plot(map_best)
rm(map_best)

# thresholds ----
print(paste0("Saglabāju sliekšņa līmeņus: ",Sys.time()))

ths <- SDMtune::thresholds(labakais_comb, 
                           type = "cloglog",
                           test=testa_dati)
ths$suga=suga
write.xlsx(ths,paste0("./SuguModeli/BestThresholds/BestThs_",suga,".xlsx"))
rm(ths)


# pROC ----
print(paste0("Saglabāju ROC līkni: ",Sys.time()))

labakais_proc=SDMtune::plotROC(labakais_comb,test = testa_dati)
labakais_proc
write_rds(labakais_proc,paste0("./SuguModeli/BestROCs/BestROC_",suga,".RDS"))
rm(labakais_proc)

# var importance ----
print(paste0("Uzsāku egv nozīmi: ",Sys.time()))

vi_tss <- varImp(labakais_CV,permut = 99)
names(vi_tss)=c("egv_id","final_PermImp_avg","final_PermImp_sd")
egv_importance=egv_izvelei %>% 
  left_join(vi_tss,by="egv_id")
write.xlsx(egv_importance,paste0("./SuguModeli/BestVarImp/BestVarImp_",suga,".xlsx"))
rm(vi_tss)
rm(egv_importance)


# Nulles reference ----
print(paste0("Uzsāku nulles referenci: ",Sys.time()))


ref_fc=labakais_comb@model@fc
ref_rm=labakais_comb@model@reg

occs=trenin_dati@coords[trenin_dati@pa==1,]
bg=trenin_dati@coords[trenin_dati@pa==0,]


rm(testa_dati)
rm(trenin_dati)
rm(labakais_CV)
rm(labakais_comb)
rm(izveles_tabula)
rm(fc_lqp)
rm(fc_lqph)
rm(egv_faili)
rm(egv_izvelei)
rm(egv_izvelei2)
rm(savienoti)
rm(savsugai)
rm(labakajam_modelim)
rm(block_folds)

tune.args <- list(fc = ref_fc, rm = ref_rm)
nulles_reference <- ENMevaluate(occs = occs, envs = egvs, bg = bg,
                                algorithm = 'maxnet', partitions = 'block', 
                                tune.args = tune.args)
write_rds(nulles_reference,paste0("./SuguModeli/Null_reference/NullRef_",suga,".RDS"))

# Nulles salidzinajumi ----
print(paste0("Uzsāku nulles salīdzinājumus: ",Sys.time()))

nulles_modeli <- ENMnulls(nulles_reference, mod.settings = list(fc = ref_fc, rm = ref_rm), no.iter = 100)
write_rds(nulles_modeli,paste0("./SuguModeli/Null_models/NullModels_",suga,".RDS"))

print(paste0("Beidzu: ",Sys.time()))



# attēli -----

## modeļa kvalitāte -----

suga="ACCGEN"

izveles_tabula=read_excel(paste0("./SuguModeli/GridSearch_Tables/GSTabula_",
                                 suga,
                                 ".xlsx"))
izveles_tabula_long=izveles_tabula %>% 
  pivot_longer(cols=train_TSS:IndepTest_tss,
               names_to = "veids",
               values_to = "vertibas") %>% 
  mutate(veids_long=case_when(veids=="train_TSS"~"Apmācību\nTSS",
                              veids=="validation_TSS"~"Validācijas\nTSS",
                              veids=="diff_TSS"~"Apmācību un\nvalidācijas\nTSS starpība",
                              veids=="IndepTest_auc"~"Neatkarīgā\ntesta\nAUC",
                              veids=="IndepTest_tss"~"Neatkarīgā\ntesta\nTSS")) %>% 
  mutate(sec_veids=case_when(veids=="train_TSS"~4,
                             veids=="validation_TSS"~3,
                             veids=="diff_TSS"~2,
                             veids=="IndepTest_auc"~5,
                             veids=="IndepTest_tss"~1))


izveles_labakais=izveles_tabula %>% 
  mutate(rinda=as.numeric(rownames(.))) %>% 
  filter(IndepTest_tss==max(IndepTest_tss,na.rm=TRUE)) %>% 
  filter(diff_TSS==min(diff_TSS,na.rm=TRUE)) %>% 
  filter(validation_TSS==max(validation_TSS,na.rm=TRUE)) %>% 
  filter(nchar(fc)==min(nchar(fc)))

izveles_labakais_long=izveles_labakais %>% 
  pivot_longer(cols=train_TSS:IndepTest_tss,
               names_to = "veids",
               values_to = "vertibas") %>% 
  mutate(veids_long=case_when(veids=="train_TSS"~"Apmācību\nTSS",
                              veids=="validation_TSS"~"Validācijas\nTSS",
                              veids=="diff_TSS"~"Apmācību un\nvalidācijas\nTSS starpība",
                              veids=="IndepTest_auc"~"Neatkarīgā\ntesta\nAUC",
                              veids=="IndepTest_tss"~"Neatkarīgā\ntesta\nTSS")) %>% 
  mutate(sec_veids=case_when(veids=="train_TSS"~4,
                             veids=="validation_TSS"~3,
                             veids=="diff_TSS"~2,
                             veids=="IndepTest_auc"~5,
                             veids=="IndepTest_tss"~1))


# roci
rociem=read_rds(paste0("./SuguModeli/BestROCs/BestROC_",
                       suga,
                       ".RDS"))
vidus=rociem+
  theme_bw()+
  labs(subtitle="ROC līkne")+
  theme(axis.title = element_text(size=14),
        axis.text = element_text(size=11),
        plot.subtitle = element_text(size=14),
        legend.title = element_text(size=14),
        legend.text = element_text(size=11),
        legend.position="inside",
        legend.position.inside = c(0.7,0.2))


# nullei

nullem=read_rds(paste0("./SuguModeli/Null_models/NullModels_",
                       suga,
                       ".RDS"))
nullu_tabula_apkopots=nullem@null.emp.results
nullu_tabula_nulles=nullem@null.results

nullu_tabulai=evalplot.nulls(nullem, 
                             stats = c("auc.val","cbi.val","or.mtp","or.10p"), 
                             plot.type = "violin",
                             return.tbl = TRUE)
nulles=nullu_tabulai$null.avgs %>% 
  mutate(nosaukumi=case_when(metric=="auc.val"~"AUC\n(validācijas)",
                             metric=="cbi.val"~"Continuous\nBoyce index\n(validācijas)",
                             metric=="or.10p"~"10% training\nomission rate",
                             metric=="or.mtp"~"Minimum\ntraining presence\nomission rate")) %>% 
  mutate(secibai=case_when(metric=="auc.val"~1,
                           metric=="cbi.val"~2,
                           metric=="or.10p"~3,
                           metric=="or.mtp"~4))
empiriskie=nullu_tabulai$empirical.results %>% 
  mutate(nosaukumi=case_when(metric=="auc.val"~"AUC\n(validācijas)",
                             metric=="cbi.val"~"Continuous\nBoyce index\n(validācijas)",
                             metric=="or.10p"~"10% training\nomission rate",
                             metric=="or.mtp"~"Minimum\ntraining presence\nomission rate")) %>% 
  mutate(secibai=case_when(metric=="auc.val"~1,
                           metric=="cbi.val"~2,
                           metric=="or.10p"~3,
                           metric=="or.mtp"~4))


# trīs attēli

kreisais=ggplot()+
  geom_violin(data=izveles_tabula_long,
              aes(reorder(veids_long,sec_veids),vertibas),
              col="grey",
              fill="grey",
              alpha=0.2)+
  geom_jitter(data=izveles_tabula_long,
              aes(reorder(veids_long,sec_veids),vertibas),
              col="grey",
              width=0.25)+
  geom_point(data=izveles_labakais_long,
             aes(reorder(veids_long,sec_veids),vertibas),
             col="black",
             size=3)+
  theme_classic()+
  coord_cartesian(ylim=c(0,1))+
  scale_y_continuous(breaks=seq(0,1,by=0.1))+
  labs(x="Metrika",
       y="Vērtība",
       subtitle="Modeļa izvēle")+
  theme(axis.title = element_text(size=14),
        axis.text = element_text(size=11),
        plot.subtitle = element_text(size=14))

vidus=rociem+
  theme_bw()+
  labs(subtitle="ROC līkne")+
  theme(axis.title = element_text(size=14),
        axis.text = element_text(size=11),
        plot.subtitle = element_text(size=14),
        legend.title = element_text(size=14),
        legend.text = element_text(size=11),
        legend.position="inside",
        legend.position.inside = c(0.8,0.15))

labais=ggplot()+
  geom_violin(data=nulles,
              aes(reorder(nosaukumi,secibai),avg),
              col="grey",
              fill="grey",
              alpha=0.2)+
  geom_jitter(data=nulles,
              aes(reorder(nosaukumi,secibai),avg),
              col="grey",
              width=0.2,
              shape=3)+
  geom_point(data=empiriskie,
             aes(reorder(nosaukumi,secibai),avg),
             col="black",
             size=3)+
  coord_cartesian(ylim=c(0,1))+
  theme_classic()+
  scale_y_continuous(breaks=seq(0,1,0.1))+
  labs(x="Metrika",y="Vērtība",subtitle="Izvēlētā modeļa salīdzinājums ar nejaušību")+
  theme(axis.title = element_text(size=14),
        axis.text = element_text(size=11),
        plot.subtitle = element_text(size=14))

izveles_attelam=kreisais+vidus+labais+plot_annotation(tag_levels="A")+
  ggview::canvas(width=1750,height=500,units="px",dpi=100)
izveles_attels=kreisais+vidus+labais+plot_annotation(tag_levels="A")
ggsave(izveles_attels,filename=paste0("./SuguModeli/Beigam_IzvelesAttels/IzvelesAttels_",
                                      suga,
                                      ".png"),
       width=1750,height=500,units="px",dpi=100)



## dzīvotņu piemērotības projekcija ----

suga="ACCGEN"

slieksni=read_excel(paste0("./SuguModeli/BestThresholds/BestThs_",
                           suga,
                           ".xlsx"))
slieksnis=slieksni[2,2]
slieksnis_vert=as.numeric(slieksnis)
apaksdala=mean(c(0,slieksnis_vert))
augsdala=mean(c(1,slieksnis_vert))


slanis=terra::rast(paste0("./SuguModeli/BestHSmap/BestHSmap_",
                          suga,
                          ".tif"))
slanis_df=terra::as.data.frame(slanis,xy=TRUE)

slanis_df_augstie=slanis_df[slanis_df$lyr1>=slieksnis_vert,]
slanis_df_zemie=slanis_df[slanis_df$lyr1<slieksnis_vert,]

krasas <- c("#2c7bb6", "#abd9e9", "#ffffbf", "#fdae61", "#d7191c")
parejas <- c(0, apaksdala, slieksnis_vert, augsdala, 1)

karte=ggplot(slanis_df,aes(x=x,y=y,fill=lyr1))+
  geom_raster() +
  coord_fixed(ratio=1)+
  scale_fill_gradientn("",
                       colors = krasas,
                       values = parejas,
                       breaks=c(0,round(slieksnis_vert,3),1),
                       limits=c(0,1))+
  ggthemes::theme_map()+
  theme(legend.position = "inside",
        legend.position.inside=c(0,0.6),
        plot.background = element_rect(fill="white",color="white"))

ggsave(karte,
       filename=paste0("./SuguModeli/Beigam_KarteNebal/BeiguKarteiNebal_",
                       suga,
                       ".png"),
       width=900,height=550,units="px",dpi=100)



## marginālās atbildes ----

suga="ACCGEN"


modelis_CV=read_rds(paste0("./SuguModeli/BestCV/BestCV_",suga,".RDS"))
mainigo_tabula=read_excel(paste0("./SuguModeli/BestVarImp/BestVarImp_",suga,".xlsx"))

mainigie=mainigo_tabula %>% 
  filter(!is.na(final_PermImp_avg))

augstums=ceiling(length(mainigie$Nosaukums)/7)*300

a=plotResponse(modelis_CV, 
               var = mainigie$egv_id[1], 
               type = "cloglog",
               only_presence = TRUE,
               marginal = TRUE, 
               rug = TRUE,
               col="black")
b=ggplot2::ggplot_build(a)

saistibas_funkcija=b$plot$data
saistibas_funkcija$nosaukums=mainigie$Nosaukums[1]
saistibas_funkcija$egv=mainigie$egv_id[1]
vietas_presence=b$data[[3]]
vietas_presence$y=1
vietas_presence$nosaukums=mainigie$Nosaukums[1]
vietas_presence$egv=mainigie$egv_id[1]
vietas_absence=b$data[[4]]
vietas_absence$y=-0.03
vietas_absence$nosaukums=mainigie$Nosaukums[1]
vietas_absence$egv=mainigie$egv_id[1]

for(i in 2:length(mainigie$egv_id)){
  a=plotResponse(modelis_CV, 
                 var = mainigie$egv_id[i], 
                 type = "cloglog",
                 only_presence = TRUE,
                 marginal = TRUE, 
                 rug = TRUE,
                 col="black")
  b=ggplot2::ggplot_build(a)
  
  saistibas_funkcija_i=b$plot$data
  saistibas_funkcija_i$nosaukums=mainigie$Nosaukums[i]
  saistibas_funkcija_i$egv=mainigie$egv_id[i]
  vietas_presence_i=b$data[[3]]
  vietas_presence_i$y=1
  vietas_presence_i$nosaukums=mainigie$Nosaukums[i]
  vietas_presence_i$egv=mainigie$egv_id[i]
  vietas_absence_i=b$data[[4]]
  vietas_absence_i$y=-0.03
  vietas_absence_i$nosaukums=mainigie$Nosaukums[i]
  vietas_absence_i$egv=mainigie$egv_id[i]
  
  saistibas_funkcija=bind_rows(saistibas_funkcija,saistibas_funkcija_i)
  vietas_presence=bind_rows(vietas_presence,vietas_presence_i)
  vietas_absence=bind_rows(vietas_absence,vietas_absence_i)
}


attels=ggplot(saistibas_funkcija)+
  geom_ribbon(data=saistibas_funkcija,aes(x=x,y=y,ymin=y_min,ymax=y_max),alpha=0.5)+
  geom_line(data=saistibas_funkcija,aes(x=x,y=y))+
  facet_wrap(~nosaukums,scales = "free_x",ncol=7,
             labeller = label_wrap_gen(width=25,multi_line = TRUE))+
  geom_point(data=vietas_presence,aes(x=x,y=y),size=0.5,alpha=0.5)+
  geom_point(data=vietas_absence,aes(x=x,y=y),size=0.5,alpha=0.5)+
  coord_cartesian(ylim=c(0,1))+
  scale_y_continuous(breaks=seq(0,1,0.25))+
  theme_bw()+
  theme(panel.grid.minor = element_blank(),
        axis.title.x = element_blank())+
  labs(y="Marginālo atbilžu funkcijas (cloglog)")
ggsave(attels,
       filename=paste0("./SuguModeli/MarginalResponses/MargResp_",suga,".png"),
       width=2000,height=augstums,units="px",dpi=120)

## EGV nozīme ----

suga="ACCGEN"


mainigo_tabula=read_excel(paste0("./SuguModeli/BestVarImp/BestVarImp_",suga,".xlsx"))
mainigie=mainigo_tabula %>% 
  filter(!is.na(final_PermImp_avg))

augstums=ceiling(length(mainigie$Nosaukums)/10)*300

pic_varimp=ggplot(mainigie,aes(x=reorder(Nosaukums,final_PermImp_avg),y=final_PermImp_avg))+
  geom_col()+
  geom_pointrange(data=mainigie,aes(x=reorder(Nosaukums,final_PermImp_avg),
                                    y=final_PermImp_avg,
                                    ymin=final_PermImp_avg-final_PermImp_sd,
                                    ymax=final_PermImp_avg+final_PermImp_sd))+
  scale_y_continuous("Pazīmes ietekme (%)",breaks=seq(0,100,10))+
  scale_x_discrete(labels = function(x) stringr::str_wrap(x, width = 75))+
  geom_text(data=mainigie,aes(x=reorder(Nosaukums,final_PermImp_avg),
                              y=103,
                              label=round(final_VIF,3)),hjust=0,size=3)+
  coord_flip(ylim=c(0,105))+
  theme_classic()+
  theme(axis.title.y = element_blank(),
        panel.grid.major.x = element_line(colour="grey"))

ggsave(pic_varimp,
       filename=paste0("./SuguModeli/Pic_VarImp/PicVarImp_",suga,".png"),
       width=1250,height=augstums,units="px",dpi=120)

# binarizēta dzīvotņu piemērotība ----

suga="ACCGEN"

karte=terra::rast(paste0("./SuguModeli/BestHSmap/BestHSmap_",suga,".tif"))
slieksni=readxl::read_excel(paste0("./SuguModeli/BestThresholds/BestThs_",suga,".xlsx"))
slieksnis=as.numeric(slieksni[2,2])

matricai=c(0,slieksnis,0,
           slieksnis,1,1)
matrica=matrix(matricai,ncol=3,byrow=TRUE)
binarizets=terra::classify(karte,matrica,include.lowest=TRUE,
                           filename=paste0("./SuguModeli/BestHSbinaryMaps/HSbinary_",suga,".tif"),
                           overwrite=TRUE)