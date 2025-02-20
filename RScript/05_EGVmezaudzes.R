# komandu rindas vistu vanaga izplatības modeļa parametrizācijā 
# izmantoto ekoģeogrāfisko mainīgo sagatavošanai

# šis skripts izveido sekojošiem EGV nepieciešamos slāņus:
# `Mezi_ApsuKraja-sum_cell.tif` - VMD MVR reģistrētā pirmā stāva apšu krāja analīzes šūnā
# `Mezi_BerzuKraja-sum_cell.tif` - VMD MVR reģistrētā pirmā stāva bērzu krāja analīzes šūnā
# `Mezi_EgluKraja-sum_cell.tif` - VMD MVR reģistrētā pirmā stāva egļu krāja analīzes šūnā
# `Mezi_LielakaisDiametrs-max_cell.tif` - VMD MVR reģistrētais lielākā koka diametrs analīzes šūnā
# `Mezi_MelnalksnuKraja-sum_cell.tif` - VMD MVR reģistrētā pirmā stāva melnalkšņu krāja analīzes šūnā
# `Mezi_NogabalaVecumaProp-vid_cell.tif` - VMD MVR reģistrētā valdošās sugas vecuma īpatsvars no galvenās cirtes vecuma, vidējais analīzes šūnā
# `Mezi_PriezuKraja-sum_cell.tif` - VMD MVR reģistrētā pirmā stāva priežu krāja analīzes šūnā
# `Mezi_SaurlapjuCKraja-sum_cell.tif` - VMD MVR reģistrētā pirmā stāva šaurlapju (atsevišķi neaprakstīto) krāja analīzes šūnā
# `Mezi_TaucLaiks-vid_cell.tif` - Laiks no pēdējā ar koku augšanu saistītā traucējuma līdz 2024.gadam, vidējais aritmētiskais analīzes šūnā




# pakotnes -----

library(tidyverse)
library(sf)
library(arrow)
library(sfarrow)
library(terra)
library(raster)


# templates ----


template10=rast("./Templates/TemplateRasters/LV10m_10km.tif")
template100=rast("./Templates/TemplateRasters/LV100m_10km.tif")
r100=raster::raster(template100)
r10=raster::raster(template10)

t_nulles=subst(template10,1,0)
r_nulles=raster::raster(t_nulles)

t_0_100=subst(template100,1,0)
r_0_100=raster::raster(t_0_100)



# nogabali ----
nogabali=st_read_parquet("./IevadesDati/MVR/nogabali_2024janv.parquet")




# Laiks kopš pēdējās darbības ----
names(nogabali)
nog_df=data.frame(nogabali)
plot(nog_df$p_cirg~nog_df$p_darbg)
summary(nog_df$p_cirg)

testam=ifelse(nog_df$p_cirg>2024,nog_df$p_cirg,1)
table(testam)

testam=ifelse(nog_df$p_darbg>2024,nog_df$p_darbg,1)
table(testam)

nogabali=nogabali %>% 
  mutate(new_PDG=ifelse(p_darbg>2024,NA,
                        ifelse(p_darbv %in% c("1","4","5","6","7","10","11"),p_darbg,NA)),
         new_PDG2=ifelse(new_PDG<1500,NA,new_PDG),
         new_PCG=ifelse(p_cirg>2024,NA,p_cirg),
         new_PCG2=ifelse(new_PCG<1500,NA,new_PCG),
         vecumam=ifelse(a10==0,NA,a10),
         new_PCG3=2024-new_PCG2,
         new_PDG3=2024-new_PDG2) %>% 
  rowwise() %>% 
  mutate(Laikam=min(c(vecumam,new_PDG3,new_PCG3),na.rm=TRUE)) %>% 
  ungroup() %>% 
  mutate(KopsTraucejuma=ifelse(is.infinite(Laikam),NA,Laikam))

testam=data.frame(nogabali)
summary(testam$KopsTraucejuma)

plot(testam$new_PCG2~testam$new_PDG2)
summary(testam$vecumam)

mvr_trauclaiks=fasterize::fasterize(nogabali,r10,field="KopsTraucejuma",fun = "min")
t_MVRtrauclaiks=rast(mvr_trauclaiks)

gfw=rast("./IevadesDati/koki/TreeCoverLossYear.tif")
plot(gfw)
gfw2=ifel(gfw>=0,24-gfw,NA)
plot(gfw2)


# No ainavas:
## Mežaudzes un koki = 50
## Krūmāji un parki = 5
## pārējais = 0
ainava=rast("./Rastri_10m/Ainava_vienk_mask.tif")
aizpildisanai=ifel(ainava==630,50,
                   ifel(ainava==620|ainava==640,5,0))
freq(aizpildisanai)


trauclaiks1=cover(t_MVRtrauclaiks,gfw2)
trauclaiks2=cover(trauclaiks1,aizpildisanai)
plot(trauclaiks2)
trauclaiks=resample(trauclaiks2,template100,method="average",
                    filename="./Rastri_100m/RAW/mezi_Tauclaiks_vid.tif",
                    overwrite=TRUE)

rm(trauclaiks1)
rm(trauclaiks2)
rm(trauclaiks)
rm(aizpildisanai)
rm(nog_df)
rm(gfw)
rm(gfw2)
rm(t_MVRtrauclaiks)
rm(mvr_trauclaiks)


# Lielākā koka diametrs ----
nogabali=nogabali %>%
  rowwise() %>% 
  mutate(maxDiam=max(c(d10,d11,d12,d13,d14,d22,d23,d24),na.rm=TRUE)) %>% 
  ungroup() %>% 
  mutate(maxDiam2=ifelse(maxDiam>100,100,maxDiam))

hist(nogabali$maxDiam2)

testam=data.frame(nogabali)
plot(testam$valddiam~testam$maxDiam2)
cor(testam$valddiam~testam$maxDiam2)

r_max_diam=fasterize::fasterize(nogabali,r10,field="maxDiam2",fun = "max")
t_max_diam=rast(r_max_diam)
t_max_diam2=cover(t_max_diam,t_nulles)
plot(t_max_diam2)

lielakais_diametrs_max=resample(t_max_diam2,template100,method="max",
                                filename="./Rastri_100m/RAW/mezi_LielakaisDiametrs_max.tif",
                                overwrite=TRUE)
rm(r_max_diam)
rm(t_max_diam)
rm(t_max_diam2)
rm(lielakais_diametrs_max)


# Vidējais vecuma īpatsvars no cirtmeta ----
table(nogabali$bon,useNA="always")

#Meža likums, 9. pants. https://likumi.lv/ta/id/2825#p9

ozoli=c("10","61")
priedes_lapegles=c("1","13","14","22")
eolgvk=c("3","15","23","11","64","12","62","16","65","24","63")
berzi=c("4")
melnalksni=c("6")
apses=c("8","19","68")

bonA=c("0","1")
bonB=c("2","3")
bonC=c("4","5","6")
bonAB=c("0","1","2","3")

nogabali=nogabali %>% 
  mutate(cirtmets=ifelse((s10 %in% ozoli)&(bon %in% bonA),101,
                         ifelse((s10 %in% ozoli),121,NA))) %>% 
  mutate(cirtmets=ifelse((s10 %in% priedes_lapegles)&(bon %in% bonAB),101,
                         ifelse((s10 %in% priedes_lapegles),121,cirtmets))) %>% 
  mutate(cirtmets=ifelse((s10 %in% eolgvk),81,cirtmets)) %>% 
  mutate(cirtmets=ifelse((s10 %in% berzi)&(bon %in% bonAB),71,
                         ifelse((s10 %in% berzi),51,cirtmets))) %>% 
  mutate(cirtmets=ifelse((s10 %in% melnalksni),71,cirtmets))  %>% 
  mutate(cirtmets=ifelse((s10 %in% apses),41,cirtmets))   %>% 
  mutate(cirtmets=ifelse(is.na(cirtmets)&zkat=="10",35,cirtmets)) %>% 
  mutate(nogvec=a10/cirtmets) %>% 
  mutate(nogvec2=ifelse(nogvec>3,3,nogvec))

summary(nogabali$nogvec)
hist(nogabali$nogvec)
hist(nogabali$nogvec2)


r_nogvec=fasterize::fasterize(nogabali,r10,field="nogvec2")
t_nogvec=rast(r_nogvec)
t_nogvec2=cover(t_nogvec,t_nulles)
plot(t_nogvec2)

NogVecProp_vid=resample(t_nogvec2,template100,method="max",
                        filename="./Rastri_100m/RAW/mezi_NogabalaVecumaProp_vid.tif",
                        overwrite=TRUE)
rm(r_nogvec)
rm(t_nogvec)
rm(t_nogvec2)
rm(NogVecProp_vid)



# Apšu krāja ----
apses=c("8","19","68")

nogabali=nogabali %>% 
  mutate(ApsuKraja=ifelse(s10 %in% apses, v10, 0)+ifelse(s11 %in% apses,v11,0)+
           ifelse(s12 %in% apses, v12,0)+ifelse(s13 %in% apses,v13,0)+
           ifelse(s14 %in% apses, v14,0)) %>% 
  mutate(ApsuKraja2=ApsuKraja/10000*10*10) %>% 
  mutate(ApsuKraja3=ifelse(ApsuKraja2>5,5,ApsuKraja2))

hist(nogabali$ApsuKraja3)


r_Kraja=fasterize::fasterize(nogabali,r10,field="ApsuKraja3")
t_Kraja=rast(r_Kraja)
t_Kraja2=cover(t_Kraja,t_nulles)


KrajasSumma=resample(t_Kraja2,template100,method="sum",
                     filename="./Rastri_100m/RAW/mezi_ApsuKraja_sum.tif",
                     overwrite=TRUE)
plot(KrajasSumma)
rm(r_Kraja)
rm(t_Kraja)
rm(t_Kraja2)
rm(KrajasSumma)


# Bērzu krāja ----
berzi=c("4")

nogabali=nogabali %>% 
  mutate(BerzuKraja=ifelse(s10 %in% berzi, v10, 0)+ifelse(s11 %in% berzi,v11,0)+
           ifelse(s12 %in% berzi, v12,0)+ifelse(s13 %in% berzi,v13,0)+
           ifelse(s14 %in% berzi, v14,0)) %>% 
  mutate(BerzuKraja2=BerzuKraja/10000*10*10) %>% 
  mutate(BerzuKraja3=ifelse(BerzuKraja2>5,5,BerzuKraja2))

hist(nogabali$BerzuKraja3)


r_Kraja=fasterize::fasterize(nogabali,r10,field="BerzuKraja3")
t_Kraja=rast(r_Kraja)
t_Kraja2=cover(t_Kraja,t_nulles)


KrajasSumma=resample(t_Kraja2,template100,method="sum",
                     filename="./Rastri_100m/RAW/mezi_BerzuKraja_sum.tif",
                     overwrite=TRUE)
plot(KrajasSumma)
rm(r_Kraja)
rm(t_Kraja)
rm(t_Kraja2)
rm(KrajasSumma)


# Egļu krāja ----
egles=c("3","13","15","23")

nogabali=nogabali %>% 
  mutate(EgluKraja=ifelse(s10 %in% egles, v10, 0)+ifelse(s11 %in% egles,v11,0)+
           ifelse(s12 %in% egles, v12,0)+ifelse(s13 %in% egles,v13,0)+
           ifelse(s14 %in% egles, v14,0)) %>% 
  mutate(EgluKraja2=EgluKraja/10000*10*10) %>% 
  mutate(EgluKraja3=ifelse(EgluKraja2>5,5,EgluKraja2))

hist(nogabali$EgluKraja3)


r_Kraja=fasterize::fasterize(nogabali,r10,field="EgluKraja3")
t_Kraja=rast(r_Kraja)
t_Kraja2=cover(t_Kraja,t_nulles)


KrajasSumma=resample(t_Kraja2,template100,method="sum",
                     filename="./Rastri_100m/RAW/mezi_EgluKraja_sum.tif",
                     overwrite=TRUE)
plot(KrajasSumma)
rm(r_Kraja)
rm(t_Kraja)
rm(t_Kraja2)
rm(KrajasSumma)



# Šaurlapju (citu) krāja ----
sl_citi=c("9","20","21","32","35","50")

nogabali=nogabali %>% 
  mutate(SaurlapjuCKraja=ifelse(s10 %in% sl_citi, v10, 0)+ifelse(s11 %in% sl_citi,v11,0)+
           ifelse(s12 %in% sl_citi, v12,0)+ifelse(s13 %in% sl_citi,v13,0)+
           ifelse(s14 %in% sl_citi, v14,0)) %>% 
  mutate(SaurlapjuCKraja2=SaurlapjuCKraja/10000*10*10) %>% 
  mutate(SaurlapjuCKraja3=ifelse(SaurlapjuCKraja2>3,3,SaurlapjuCKraja2))

hist(nogabali$SaurlapjuCKraja3)


r_Kraja=fasterize::fasterize(nogabali,r10,field="SaurlapjuCKraja3")
t_Kraja=rast(r_Kraja)
t_Kraja2=cover(t_Kraja,t_nulles)


KrajasSumma=resample(t_Kraja2,template100,method="sum",
                     filename="./Rastri_100m/RAW/mezi_SaurlapjuCKraja_sum.tif",
                     overwrite=TRUE)
plot(KrajasSumma)
rm(r_Kraja)
rm(t_Kraja)
rm(t_Kraja2)
rm(KrajasSumma)

# Melnalkšņa krāja -----
melnalksni=c("6")

nogabali=nogabali %>% 
  mutate(MeKraja=ifelse(s10 %in% melnalksni, v10, 0)+ifelse(s11 %in% melnalksni,v11,0)+
           ifelse(s12 %in% melnalksni, v12,0)+ifelse(s13 %in% melnalksni,v13,0)+
           ifelse(s14 %in% melnalksni, v14,0)) %>% 
  mutate(MeKraja2=MeKraja/10000*10*10) %>% 
  mutate(MeKraja3=ifelse(MeKraja2>4,4,MeKraja2))

hist(nogabali$MeKraja3)


r_Kraja=fasterize::fasterize(nogabali,r10,field="MeKraja3")
t_Kraja=rast(r_Kraja)
t_Kraja2=cover(t_Kraja,t_nulles)


KrajasSumma=resample(t_Kraja2,template100,method="sum",
                     filename="./Rastri_100m/RAW/mezi_MelnalksnuKraja_sum.tif",
                     overwrite=TRUE)
plot(KrajasSumma)
rm(r_Kraja)
rm(t_Kraja)
rm(t_Kraja2)
rm(KrajasSumma)


# Priežu krāja ----
priedes=c("1","14","22")

nogabali=nogabali %>% 
  mutate(PriezuKraja=ifelse(s10 %in% priedes, v10, 0)+ifelse(s11 %in% priedes,v11,0)+
           ifelse(s12 %in% priedes, v12,0)+ifelse(s13 %in% priedes,v13,0)+
           ifelse(s14 %in% priedes, v14,0)) %>% 
  mutate(PriezuKraja2=PriezuKraja/10000*10*10) %>% 
  mutate(PriezuKraja3=ifelse(PriezuKraja2>6,6,PriezuKraja2))

hist(nogabali$PriezuKraja3[nogabali$PriezuKraja3>0])
hist(nogabali$PriezuKraja3)


r_Kraja=fasterize::fasterize(nogabali,r10,field="PriezuKraja3")
t_Kraja=rast(r_Kraja)
t_Kraja2=cover(t_Kraja,t_nulles)


KrajasSumma=resample(t_Kraja2,template100,method="sum",
                     filename="./Rastri_100m/RAW/mezi_PriezuKraja_sum.tif",
                     overwrite=TRUE)
plot(KrajasSumma)
rm(r_Kraja)
rm(t_Kraja)
rm(t_Kraja2)
rm(KrajasSumma)

