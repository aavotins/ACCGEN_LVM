# vistu vanaga izplatības modeļa parametrizācijā izmantojamo ekoģeogrāfisko mainīgo izvēle
# Apraksts: ./RScript/Readme_RScript.md un projekta 2024. gada pārskatā.
# Sākumā izveido nepieciešamās direktorijas, tad darba sesijai pievieno pakotnes, 
# tālāk tiek veiktas darbības ekoģeogrāfisko mainīgo izvēlei pēc multikolinearitātes 
# (VIF) un tad pēc saistības indikatīvajā modelī

# direktorijas ----

dir.create("./SuguModeli/EGVselection")

# pakotnes -----

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



# EGVs ----
faili=data.frame(fails=list.files(path="./Rastri_100m/Scaled/",
                                  pattern=".tif$"),
                 cels=list.files(path="./Rastri_100m/Scaled/",
                                 pattern=".tif$",full.names = TRUE))


suga="ACCGEN"
sakumam=read_excel("./Rastri_100m/EGV_ACCGEN.xlsx")

sakumsaraksts_sugai=sakumam %>% 
  filter(suga_kods==suga)
isssakums_sugai=sakumsaraksts_sugai %>% 
  filter(sakuma_izvele==1)
faili_sugai=faili %>% 
  filter(fails %in% isssakums_sugai$scale_NAME)
rastri_sugai=terra::rast(faili_sugai$cels)


# VIF selection ----

VifStep_sugai=usdm::vifstep(rastri_sugai,th=10,size=20000)
izslegt=VifStep_sugai@excluded
saglabat=VifStep_sugai@results

saglabat2=saglabat %>% 
  mutate(faila_nosaukums=paste0(Variables,".tif"),
         sakumVIF=VIF) %>% 
  dplyr::select(faila_nosaukums,sakumVIF)
sakums2=sakumsaraksts_sugai %>% 
  left_join(saglabat2,by=c("scale_NAME"="faila_nosaukums"))

EGVtabulai=paste0("./SuguModeli/EGVselection/EGV_",suga,".xlsx")
write.xlsx(sakums2,EGVtabulai)


# indikatīvā saistība ----

## egv ----
egv_faili=data.frame(egv_fails=list.files(path="./Rastri_100m/Scaled/",
                                          pattern=".tif$"),
                     egv_cels=list.files(path="./Rastri_100m/Scaled/",
                                         pattern=".tif$",full.names = TRUE))

## punkti ----


suga="ACCGEN"
izvelei_sugai=read_excel("./SuguModeli/EGVselection/EGV_ACCGEN.xlsx")
izvelei_sugai=izvelei_sugai %>% 
  dplyr::select(sakums:sakumVIF)


isais_saraksts=izvelei_sugai %>% 
  filter(!is.na(sakumVIF))

egv_faili2=isais_saraksts %>% 
  left_join(egv_faili,by=c("scale_NAME"="egv_fails"))

predictors <- terra::rast(egv_faili2$egv_cels)
names(predictors)=egv_faili2$egv_id
names(predictors)

klatbutnem=read_parquet("./SuguModeli/ApmacibuDati/TrainingPresence/TrainPres_ACCGEN.parquet")
klatbutnes=klatbutnem %>%
  mutate(y=as.numeric(y)) %>% 
  dplyr::select(x,y)

foniem=read_parquet("./SuguModeli/ApmacibuDati/TrainingBackground/TrainBg_ACCGEN.parquet")
foni=foniem %>% 
  dplyr::select(x,y)

dati <- prepareSWD(species = suga,
                   p = klatbutnes,
                   a = foni,
                   env = predictors)
dati2=addSamplesToBg(dati)

## indikatīvais modelis ----
izveles_modelis=function(datini){
  rezA=try(train("Maxnet",
                 data = datini,
                 fc="lqph"))
  if (inherits(rezA, 'try-error')) {
    rezB=train("Maxnet",
               data = datini,
               fc="lqp")
    return(rezB)
  }
  return(rezA)
}
maxnet_model=izveles_modelis(dati2)


## permutāciju nozīme ----
vi_maxnet <- varImp(maxnet_model, 
                    permut = 9) # lielā EGV apjoma un indikācijas vispārīgumam
names(vi_maxnet)=c("egv_id","first_VarImp","first_VarImpSD")

vidus=izvelei_sugai %>% 
  left_join(vi_maxnet,by="egv_id")
write.xlsx(vidus,"./SuguModeli/EGVselection/EGV_ACCGEN.xlsx")

## turpmāk apstrādājamo VIF ----
beigu_saraksts=vidus %>% 
  filter(first_VarImp>=1)
egv_faili3=beigu_saraksts %>% 
  left_join(egv_faili,by=c("scale_NAME"="egv_fails"))

egvs <- terra::rast(egv_faili3$egv_cels)
names(egvs)=egv_faili3$egv_id
names(egvs)

vertibam=usdm::vif(egvs,size=20000)
names(vertibam)=c("egv_id","final_VIF")

beigas=vidus %>% 
  left_join(vertibam,by="egv_id")
write.xlsx(beigas,"./SuguModeli/EGVselection/EGV_ACCGEN.xlsx")