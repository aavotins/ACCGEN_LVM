# komandu rindas vistu vanaga izplatības modeļa parametrizācijā 
# izmantoto ekoģeogrāfisko mainīgo sagatavošanai

# šis skripts izveido sekojošiem EGV nepieciešamos slāņus:
# `Ainava_MeziNetaksets_cell.tif` - Netaksēto mežu platības īpatsvars analīzes šūnā
# `Ainava_MeziNetaksets_r3000.tif` - Netaksēto mežu platības īpatsvars r=3000m ap analīzes šūnas centru
# `Ainava_Vasarnicas_r10000.tif` - Mazdārziņu un vasarnīcu koloniju platības īpatsvars r=10000m ap analīzes šūnas centru
# `Lauku_AramVisas_cell.tif` - Visu aramzemju klašu platības īpatsvars analīzes šūnā
# `Lauku_Papuves_r10000.tif` - LAD papuvju platības īpatsvars r=10000 m ap analīzes šūnas centru
# `Lauku_ZalajiVisi_r10000.tif` - Visu zālāju klašu platības īpatsvars r=10000 m ap analīzes šūnas centru
# `Mezi_EitrSus_r10000.tif` - Eitrofu susināto mežu (MVR MAAT klase) platības īpatsvars r=10000 m ap analīzes šūnas centru
# `Mezi_IzcUNzem5m_cell.tif` - Izcirtumu un MVR mežaudžu līdz 5 m platības īpatsvars analīzes šūnā
# `Mezi_JauktukokuJaunas_r3000.tif` - VMD MVR reģistrēto jauktu koku jaunaudžu, vidēja vecuma un briestaudžu platības īpatsvars r=3000 m ap analīzes šūnas centru
# `Mezi_MezoSaus_r10000.tif` - Mezotrofu sausieņu un slapjaiņu mežu (MVR MAAT klase) platības īpatsvars r=10000 m ap analīzes šūnas centru
# `Mezi_OligoSaus_r10000.tif` - Oligotrofu sausieņu un slapjaiņu mežu (MVR MAAT klase) platības īpatsvars r=10000 m ap analīzes šūnas centru
# `Mezi_OligoSus_r10000.tif` - Oligotrofu susināto mežu (MVR MAAT klase) platības īpatsvars r=10000 m ap analīzes šūnas centru
# `Mezi_Saurlapju_r10000.tif` - VMD MVR reģistrēto šaurlapju mežaudžu platības īpatsvars r=10000 m ap analīzes šūnas centru


# Pa priekšu sagatavoju nepieciešamos analīzes šūnas līmeņa mainīgos, tad veidoju 
# to platības īpatsvara rādītājus ainavas telpās. Lai veidotu aprakstus ainavas līmenī,
# tiem ir nepieciešami atbilstoši apraksti šūnas līmenī


# šūnas līmenis ----

## pakotnes -----
library(tidyverse)
library(sf)
library(arrow)
library(sfarrow)
library(terra)
library(raster)
library(fasterize)
library(gdalUtilities)
library(readxl)

## templates -----
template10=rast("./Templates/TemplateRasters/LV10m_10km.tif")
template100=rast("./Templates/TemplateRasters/LV100m_10km.tif")


## utility -----

EGVcell_sum=function(smalkais,template100,cels){
  pirmais=resample(x=smalkais,y=template100,method="sum",
                   filename=cels,
                   overwrite=TRUE)
  return(pirmais)
}

EGVcell_mean=function(smalkais,template100,cels){
  pirmais=resample(x=smalkais,y=template100,method="average",
                   filename=cels,
                   overwrite=TRUE)
  return(pirmais)
}



EGVcell_sum_recl=function(smalkais,template100,cels){
  nultais=terra::ifel(smalkais>0,1,smalkais)
  pirmais=resample(x=nultais,y=template100,method="sum",
                   filename=cels,
                   overwrite=TRUE)
  return(pirmais)
}

EGVcell_mean_recl=function(smalkais,template100,cels){
  nultais=terra::ifel(smalkais>0,1,smalkais)
  pirmais=resample(x=nultais,y=template100,method="average",
                   filename=cels,
                   overwrite=TRUE)
  return(pirmais)
}



## Ainava_MeziNetaksets_cell.tif ----
# šūnas līmeņa EGV

slanis=terra::rast("./Rastri_10m/Ainava_MeziNetaksets.tif")
slanis
cels="./Rastri_100m/RAW/Ainava_MeziNetaksets_cell.tif"
if(minmax(slanis,compute=FALSE)[2]>1){
  EGVcell_mean_recl(slanis,template100,cels)
} else {
  EGVcell_mean(slanis,template100,cels)}



## Ainava_Vasarnicas ----
# šūnas līmenis ievadei tālākā EGV izveidei

slanis=terra::rast("./Rastri_10m/Ainava_VasarnicasYN.tif")
slanis
cels="./Rastri_100m/RAW/Ainava_Vasarnicas_cell.tif"
if(minmax(slanis,compute=FALSE)[2]>1){
  EGVcell_mean_recl(slanis,template100,cels)
} else {
  EGVcell_mean(slanis,template100,cels)}



## Lauku_AramVisas_cell.tif ----
# šūnas līmeņa EGV

slanis=terra::rast("./Rastri_10m/Lauki_AramzemesYN.tif")
slanis
cels="./Rastri_100m/RAW/Lauku_AramVisas_cell.tif"
if(minmax(slanis,compute=FALSE)[2]>1){
  EGVcell_mean_recl(slanis,template100,cels)
} else {
  EGVcell_mean(slanis,template100,cels)}




## Lauku_Papuves ----
# šūnas līmenis ievadei tālākā EGV izveidei

slanis=terra::rast("./Rastri_10m/Lauki_papuvesYN.tif")
slanis
cels="./Rastri_100m/RAW/Lauku_Papuves_cell.tif"
if(minmax(slanis,compute=FALSE)[2]>1){
  EGVcell_mean_recl(slanis,template100,cels)
} else {
  EGVcell_mean(slanis,template100,cels)}





## Lauku_ZalajiVisi ----
# šūnas līmenis ievadei tālākā EGV izveidei


slanis=terra::rast("./Rastri_10m/Lauki_zalajiYN.tif")
slanis
cels="./Rastri_100m/RAW/Lauku_ZalajiVisi_cell.tif"
if(minmax(slanis,compute=FALSE)[2]>1){
  EGVcell_mean_recl(slanis,template100,cels)
} else {
  EGVcell_mean(slanis,template100,cels)}





## Mezi_EitrSus ----
# šūnas līmenis ievadei tālākā EGV izveidei

slanis=terra::rast("./Rastri_10m/Mezi_EitrSus.tif")
slanis
cels="./Rastri_100m/RAW/Mezi_EitrSus_cell.tif"
if(minmax(slanis,compute=FALSE)[2]>1){
  EGVcell_mean_recl(slanis,template100,cels)
} else {
  EGVcell_mean(slanis,template100,cels)}





## Mezi_IzcUNzem5m_cell.tif ----
# šūnas līmeņa EGV

slanis=terra::rast("./Rastri_10m/Mezi_IzcUNzem5m.tif")
slanis
cels="./Rastri_100m/RAW/Mezi_IzcUNzem5m_cell.tif"
if(minmax(slanis,compute=FALSE)[2]>1){
  EGVcell_mean_recl(slanis,template100,cels)
} else {
  EGVcell_mean(slanis,template100,cels)}




## Mezi_JauktukokuJaunas ----
# šūnas līmenis ievadei tālākā EGV izveidei

slanis=terra::rast("./Rastri_10m/Mezi_JauktkokuJaunas.tif")
slanis
cels="./Rastri_100m/RAW/Mezi_JauktukokuJaunas_cell.tif"
if(minmax(slanis,compute=FALSE)[2]>1){
  EGVcell_mean_recl(slanis,template100,cels)
} else {
  EGVcell_mean(slanis,template100,cels)}





## Mezi_MezoSaus ----
# šūnas līmenis ievadei tālākā EGV izveidei

slanis=terra::rast("./Rastri_10m/Mezi_MezoSaus.tif")
slanis
cels="./Rastri_100m/RAW/Mezi_MezoSaus_cell.tif"
if(minmax(slanis,compute=FALSE)[2]>1){
  EGVcell_mean_recl(slanis,template100,cels)
} else {
  EGVcell_mean(slanis,template100,cels)}




## Mezi_OligoSaus ----
# šūnas līmenis ievadei tālākā EGV izveidei

slanis=terra::rast("./Rastri_10m/Mezi_OligoSaus.tif")
slanis
cels="./Rastri_100m/RAW/Mezi_OligoSaus_cell.tif"
if(minmax(slanis,compute=FALSE)[2]>1){
  EGVcell_mean_recl(slanis,template100,cels)
} else {
  EGVcell_mean(slanis,template100,cels)}




## Mezi_OligoSus ----
# šūnas līmenis ievadei tālākā EGV izveidei

slanis=terra::rast("./Rastri_10m/Mezi_OligoSus.tif")
slanis
cels="./Rastri_100m/RAW/Mezi_OligoSus_cell.tif"
if(minmax(slanis,compute=FALSE)[2]>1){
  EGVcell_mean_recl(slanis,template100,cels)
} else {
  EGVcell_mean(slanis,template100,cels)}




## Mezi_Saurlapju ----
# šūnas līmenis ievadei tālākā EGV izveidei


slanis=terra::rast("./Rastri_10m/Mezi_SaurlapjuJaunas.tif")
slanis
cels="./Rastri_100m/RAW/Mezi_SaurlapjuJaunas_cell.tif"
if(minmax(slanis,compute=FALSE)[2]>1){
  EGVcell_mean_recl(slanis,template100,cels)
} else {
  EGVcell_mean(slanis,template100,cels)}




rm(list=ls())

# ainavas telpas ----

## direktorijas ----



## Ainava_MeziNetaksets_r3000.tif
dir.create("./IevadesDati/ainava/ClassArea/Ainava_MeziNetaksets_r3000", recursive=TRUE)

## Ainava_Vasarnicas_r10000.tif
dir.create("./IevadesDati/ainava/ClassArea/Ainava_Vasarnicas_r10000", recursive=TRUE)

## Lauku_Papuves_r10000.tif
dir.create("./IevadesDati/ainava/ClassArea/Lauku_Papuves_r10000", recursive=TRUE)

## Lauku_ZalajiVisi_r10000.tif
dir.create("./IevadesDati/ainava/ClassArea/Lauku_ZalajiVisi_r10000", recursive=TRUE)

## Mezi_EitrSus_r10000.tif
dir.create("./IevadesDati/ainava/ClassArea/Mezi_EitrSus_r10000", recursive=TRUE)

## Mezi_JauktukokuJaunas_r3000.tif
dir.create("./IevadesDati/ainava/ClassArea/Mezi_JauktukokuJaunas_r3000", recursive=TRUE)

## Mezi_MezoSaus_r10000.tif
dir.create("./IevadesDati/ainava/ClassArea/Mezi_MezoSaus_r10000", recursive=TRUE)

## Mezi_OligoSaus_r10000.tif
dir.create("./IevadesDati/ainava/ClassArea/Mezi_OligoSaus_r10000", recursive=TRUE)

## Mezi_OligoSus_r10000.tif
dir.create("./IevadesDati/ainava/ClassArea/Mezi_OligoSus_r10000", recursive=TRUE)

## Mezi_Saurlapju_r10000.tif
dir.create("./IevadesDati/ainava/ClassArea/Mezi_Saurlapju_r10000", recursive=TRUE)



## pakotnes -----

library(terra)
library(sf)
library(tidyverse)
library(sfarrow)


## cikla vadība ----


kvadratiem=data.frame(fails_c=list.files("./Templates/TemplateGrids/lapas/"))
kvadratiem$cels_c=paste0("./Templates/TemplateGrids/lapas/",kvadratiem$fails_c)
kvadratiem$numurs=substr(kvadratiem$fails_c,10,13)


kvadratiem_radiusi=data.frame(fails_r=list.files("./Templates/TemplateGridPoints/lapas/"))
kvadratiem_radiusi$cels_radiuss=paste0("./Templates/TemplateGridPoints/lapas/",kvadratiem_radiusi$fails_r)
kvadratiem_radiusi=separate(kvadratiem_radiusi,fails_r,into=c("sakums","veids","lapa","beigas"),remove = FALSE)

kvadratiem_r500=kvadratiem_radiusi %>% 
  filter(veids=="r500") %>% 
  mutate(fails_r500=fails_r,
         cels_r500=cels_radiuss) %>% 
  dplyr::select(-sakums,-beigas,-fails_r,-cels_radiuss,-veids)

kvadratiem_r1250=kvadratiem_radiusi %>% 
  filter(veids=="r1250") %>% 
  mutate(fails_r1250=fails_r,
         cels_r1250=cels_radiuss) %>% 
  dplyr::select(-sakums,-beigas,-fails_r,-cels_radiuss,-veids)

kvadratiem_r3000=kvadratiem_radiusi %>% 
  filter(veids=="r3000") %>% 
  mutate(fails_r3000=fails_r,
         cels_r3000=cels_radiuss) %>% 
  filter(sakums!="pts100") %>% 
  dplyr::select(-sakums,-beigas,-fails_r,-cels_radiuss,-veids)

kvadratiem_r10000=kvadratiem_radiusi %>% 
  filter(veids=="r10000") %>% 
  mutate(fails_r10000=fails_r,
         cels_r10000=cels_radiuss) %>% 
  filter(sakums!="pts100") %>% 
  dplyr::select(-sakums,-beigas,-fails_r,-cels_radiuss,-veids)

kvadrati=kvadratiem %>% 
  left_join(kvadratiem_r500,by=c("numurs"="lapa")) %>% 
  left_join(kvadratiem_r1250,by=c("numurs"="lapa")) %>% 
  left_join(kvadratiem_r3000,by=c("numurs"="lapa")) %>% 
  left_join(kvadratiem_r10000,by=c("numurs"="lapa"))

rm(kvadratiem)
rm(kvadratiem_r500)
rm(kvadratiem_r1250)
rm(kvadratiem_r3000)
rm(kvadratiem_r10000)

numuri=levels(factor(kvadrati$numurs))



## darbs ----



library(foreach)
library(doParallel)
cl <- makeCluster(8)
registerDoParallel(cl)

tikls100=st_read_parquet("./Templates/TemplateGrids/tikls100_sauzeme.parquet")

foreach(i = 1:length(numuri)) %dopar% {
  library(tidyverse)
  library(sf)
  library(arrow)
  library(sfarrow)
  library(terra)
  library(raster)
  library(exactextractr)
  library(fasterize)
  
  
  sakums=Sys.time()
  print(i)
  solis=numuri[i]
  celi=kvadrati %>% filter(numurs==solis)
  
  sunas=st_read_parquet(celi$cels_c)
  sunas=sunas %>% dplyr::select(id,yes,tks50km,rinda300,rinda500,ID1km)
  r3000=st_read_parquet(celi$cels_r3000)
  r3000=r3000 %>% dplyr::select(rinda300)
  r10000=st_read_parquet(celi$cels_r10000)
  r10000=r10000 %>% dplyr::select(ID1km)
  
  sunas300=tikls100 %>% 
    filter(rinda300 %in% r3000$rinda300) %>% 
    dplyr::select(id,yes,tks50km,rinda300,rinda500,ID1km)
  sunas1000=tikls100 %>% 
    filter(ID1km %in% r10000$ID1km) %>% 
    dplyr::select(id,yes,tks50km,rinda300,rinda500,ID1km)
  
  telpa=st_as_sfc(st_bbox(r10000))
  telpa2=st_buffer(telpa,dist=1000)
  
  
  template_100=rast("./Templates/TemplateRasters/LV100m_10km.tif")
  temp100_mazs=crop(template_100,telpa2)
  rastrs_100_mazs=raster::raster(temp100_mazs)
  
  ## Ainava_MeziNetaksets_r3000.tif
  slanis=rast("./Rastri_100m/RAW/Ainava_MeziNetaksets_cell.tif")
  slanis_mazs=crop(slanis,telpa2)
  r3000$vertibas=exact_extract(slanis_mazs,r3000,"mean")
  x3000=data.frame(r3000) %>% dplyr::select(rinda300,vertibas)
  sunas300=sunas300 %>% 
    dplyr::select(id,yes,tks50km,rinda300,rinda500,ID1km) %>% 
    left_join(x3000,by="rinda300")
  rezA=fasterize::fasterize(sunas300,rastrs_100_mazs,field="vertibas")
  rezA=rast(rezA)
  rezB=terra::mask(rezA,temp100_mazs,overwrite=TRUE,
                   filename=paste0("./IevadesDati/ainava/ClassArea/Ainava_MeziNetaksets_r3000/Ainava_MeziNetaksets_r3000","_",solis,".tif"))
  
  
  ## Ainava_Vasarnicas_r10000.tif
  slanis=rast("./Rastri_100m/RAW/Ainava_Vasarnicas_cell.tif")
  slanis_mazs=crop(slanis,telpa2)
  r10000$vertibas=exact_extract(slanis_mazs,r10000,"mean")
  x10000=data.frame(r10000) %>% dplyr::select(ID1km,vertibas)
  sunas1000=sunas1000 %>% 
    dplyr::select(id,yes,tks50km,rinda300,rinda500,ID1km) %>% 
    left_join(x10000,by="ID1km")
  rezA=fasterize::fasterize(sunas1000,rastrs_100_mazs,field="vertibas")
  rezA=rast(rezA)
  rezB=terra::mask(rezA,temp100_mazs,overwrite=TRUE,
                   filename=paste0("./IevadesDati/ainava/ClassArea/Ainava_Vasarnicas_r10000/Ainava_Vasarnicas_r10000","_",solis,".tif"))
  
  
  ## Lauku_Papuves_r10000.tif
  slanis=rast("./Rastri_100m/RAW/Lauku_Papuves_cell.tif")
  slanis_mazs=crop(slanis,telpa2)
  r10000$vertibas=exact_extract(slanis_mazs,r10000,"mean")
  x10000=data.frame(r10000) %>% dplyr::select(ID1km,vertibas)
  sunas1000=sunas1000 %>% 
    dplyr::select(id,yes,tks50km,rinda300,rinda500,ID1km) %>% 
    left_join(x10000,by="ID1km")
  rezA=fasterize::fasterize(sunas1000,rastrs_100_mazs,field="vertibas")
  rezA=rast(rezA)
  rezB=terra::mask(rezA,temp100_mazs,overwrite=TRUE,
                   filename=paste0("./IevadesDati/ainava/ClassArea/Lauku_Papuves_r10000/Lauku_Papuves_r10000","_",solis,".tif"))
  
  
  ## Lauku_ZalajiVisi_r10000.tif
  slanis=rast("./Rastri_100m/RAW/Lauku_ZalajiVisi_cell.tif")
  slanis_mazs=crop(slanis,telpa2)
  r10000$vertibas=exact_extract(slanis_mazs,r10000,"mean")
  x10000=data.frame(r10000) %>% dplyr::select(ID1km,vertibas)
  sunas1000=sunas1000 %>% 
    dplyr::select(id,yes,tks50km,rinda300,rinda500,ID1km) %>% 
    left_join(x10000,by="ID1km")
  rezA=fasterize::fasterize(sunas1000,rastrs_100_mazs,field="vertibas")
  rezA=rast(rezA)
  rezB=terra::mask(rezA,temp100_mazs,overwrite=TRUE,
                   filename=paste0("./IevadesDati/ainava/ClassArea/Lauku_ZalajiVisi_r10000/Lauku_ZalajiVisi_r10000","_",solis,".tif"))
  
  
  ## Mezi_EitrSus_r10000.tif
  slanis=rast("./Rastri_100m/RAW/Mezi_EitrSus_cell.tif")
  slanis_mazs=crop(slanis,telpa2)
  r10000$vertibas=exact_extract(slanis_mazs,r10000,"mean")
  x10000=data.frame(r10000) %>% dplyr::select(ID1km,vertibas)
  sunas1000=sunas1000 %>% 
    dplyr::select(id,yes,tks50km,rinda300,rinda500,ID1km) %>% 
    left_join(x10000,by="ID1km")
  rezA=fasterize::fasterize(sunas1000,rastrs_100_mazs,field="vertibas")
  rezA=rast(rezA)
  rezB=terra::mask(rezA,temp100_mazs,overwrite=TRUE,
                   filename=paste0("./IevadesDati/ainava/ClassArea/Mezi_EitrSus_r10000/Mezi_EitrSus_r10000","_",solis,".tif"))
  
  
  ## Mezi_JauktukokuJaunas_r3000.tif
  slanis=rast("./Rastri_100m/RAW/Mezi_JauktukokuJaunas_cell.tif")
  slanis_mazs=crop(slanis,telpa2)
  r3000$vertibas=exact_extract(slanis_mazs,r3000,"mean")
  x3000=data.frame(r3000) %>% dplyr::select(rinda300,vertibas)
  sunas300=sunas300 %>% 
    dplyr::select(id,yes,tks50km,rinda300,rinda500,ID1km) %>% 
    left_join(x3000,by="rinda300")
  rezA=fasterize::fasterize(sunas300,rastrs_100_mazs,field="vertibas")
  rezA=rast(rezA)
  rezB=terra::mask(rezA,temp100_mazs,overwrite=TRUE,
                   filename=paste0("./IevadesDati/ainava/ClassArea/Mezi_JauktukokuJaunas_r3000/Mezi_JauktukokuJaunas_r3000","_",solis,".tif"))
  
  
  ## Mezi_MezoSaus_r10000.tif
  slanis=rast("./Rastri_100m/RAW/Mezi_MezoSaus_cell.tif")
  slanis_mazs=crop(slanis,telpa2)
  r10000$vertibas=exact_extract(slanis_mazs,r10000,"mean")
  x10000=data.frame(r10000) %>% dplyr::select(ID1km,vertibas)
  sunas1000=sunas1000 %>% 
    dplyr::select(id,yes,tks50km,rinda300,rinda500,ID1km) %>% 
    left_join(x10000,by="ID1km")
  rezA=fasterize::fasterize(sunas1000,rastrs_100_mazs,field="vertibas")
  rezA=rast(rezA)
  rezB=terra::mask(rezA,temp100_mazs,overwrite=TRUE,
                   filename=paste0("./IevadesDati/ainava/ClassArea/Mezi_MezoSaus_r10000/Mezi_MezoSaus_r10000","_",solis,".tif"))
  
  
  ## Mezi_OligoSaus_r10000.tif
  slanis=rast("./Rastri_100m/RAW/Mezi_OligoSaus_cell.tif")
  slanis_mazs=crop(slanis,telpa2)
  r10000$vertibas=exact_extract(slanis_mazs,r10000,"mean")
  x10000=data.frame(r10000) %>% dplyr::select(ID1km,vertibas)
  sunas1000=sunas1000 %>% 
    dplyr::select(id,yes,tks50km,rinda300,rinda500,ID1km) %>% 
    left_join(x10000,by="ID1km")
  rezA=fasterize::fasterize(sunas1000,rastrs_100_mazs,field="vertibas")
  rezA=rast(rezA)
  rezB=terra::mask(rezA,temp100_mazs,overwrite=TRUE,
                   filename=paste0("./IevadesDati/ainava/ClassArea/Mezi_OligoSaus_r10000/Mezi_OligoSaus_r10000","_",solis,".tif"))
  
  
  ## Mezi_OligoSus_r10000.tif
  slanis=rast("./Rastri_100m/RAW/Mezi_OligoSus_cell.tif")
  slanis_mazs=crop(slanis,telpa2)
  r10000$vertibas=exact_extract(slanis_mazs,r10000,"mean")
  x10000=data.frame(r10000) %>% dplyr::select(ID1km,vertibas)
  sunas1000=sunas1000 %>% 
    dplyr::select(id,yes,tks50km,rinda300,rinda500,ID1km) %>% 
    left_join(x10000,by="ID1km")
  rezA=fasterize::fasterize(sunas1000,rastrs_100_mazs,field="vertibas")
  rezA=rast(rezA)
  rezB=terra::mask(rezA,temp100_mazs,overwrite=TRUE,
                   filename=paste0("./IevadesDati/ainava/ClassArea/Mezi_OligoSus_r10000/Mezi_OligoSus_r10000","_",solis,".tif"))
  
  
  ## Mezi_Saurlapju_r10000.tif
  slanis=rast("./Rastri_100m/RAW/Mezi_Saurlapju_cell.tif")
  slanis_mazs=crop(slanis,telpa2)
  r10000$vertibas=exact_extract(slanis_mazs,r10000,"mean")
  x10000=data.frame(r10000) %>% dplyr::select(ID1km,vertibas)
  sunas1000=sunas1000 %>% 
    dplyr::select(id,yes,tks50km,rinda300,rinda500,ID1km) %>% 
    left_join(x10000,by="ID1km")
  rezA=fasterize::fasterize(sunas1000,rastrs_100_mazs,field="vertibas")
  rezA=rast(rezA)
  rezB=terra::mask(rezA,temp100_mazs,overwrite=TRUE,
                   filename=paste0("./IevadesDati/ainava/ClassArea/Mezi_Saurlapju_r10000/Mezi_Saurlapju_r10000","_",solis,".tif"))
  
  
  
  beigas=Sys.time()
  ilgums=beigas-sakums
  print(ilgums)
}
stopCluster(cl)



## apvienošana ----


## Ainava_MeziNetaksets_r3000.tif
slani=list.files("./IevadesDati/ainava/ClassArea/Ainava_MeziNetaksets_r3000/",full.names = TRUE)
virt_slani=terra::vrt(slani)
names(virt_slani)="Ainava_MeziNetaksets_r3000"
writeRaster(virt_slani,"./Rastri_100m/RAW/Ainava_MeziNetaksets_r3000.tif",overwrite=TRUE)

## Ainava_Vasarnicas_r10000.tif
slani=list.files("./IevadesDati/ainava/ClassArea/Ainava_Vasarnicas_r10000/",full.names = TRUE)
virt_slani=terra::vrt(slani)
names(virt_slani)="Ainava_Vasarnicas_r10000"
writeRaster(virt_slani,"./Rastri_100m/RAW/Ainava_Vasarnicas_r10000.tif",overwrite=TRUE)

## Lauku_Papuves_r10000.tif
slani=list.files("./IevadesDati/ainava/ClassArea/Lauku_Papuves_r10000/",full.names = TRUE)
virt_slani=terra::vrt(slani)
names(virt_slani)="Lauku_Papuves_r10000"
writeRaster(virt_slani,"./Rastri_100m/RAW/Lauku_Papuves_r10000.tif",overwrite=TRUE)

## Lauku_ZalajiVisi_r10000.tif
slani=list.files("./IevadesDati/ainava/ClassArea/Lauku_ZalajiVisi_r10000/",full.names = TRUE)
virt_slani=terra::vrt(slani)
names(virt_slani)="Lauku_ZalajiVisi_r10000"
writeRaster(virt_slani,"./Rastri_100m/RAW/Lauku_ZalajiVisi_r10000.tif",overwrite=TRUE)

## Mezi_EitrSus_r10000.tif
slani=list.files("./IevadesDati/ainava/ClassArea/Mezi_EitrSus_r10000/",full.names = TRUE)
virt_slani=terra::vrt(slani)
names(virt_slani)="Mezi_EitrSus_r10000"
writeRaster(virt_slani,"./Rastri_100m/RAW/Mezi_EitrSus_r10000.tif",overwrite=TRUE)

## Mezi_JauktukokuJaunas_r3000.tif
slani=list.files("./IevadesDati/ainava/ClassArea/Mezi_JauktukokuJaunas_r3000/",full.names = TRUE)
virt_slani=terra::vrt(slani)
names(virt_slani)="Mezi_JauktukokuJaunas_r3000"
writeRaster(virt_slani,"./Rastri_100m/RAW/Mezi_JauktukokuJaunas_r3000.tif",overwrite=TRUE)

## Mezi_MezoSaus_r10000.tif
slani=list.files("./IevadesDati/ainava/ClassArea/Mezi_MezoSaus_r10000/",full.names = TRUE)
virt_slani=terra::vrt(slani)
names(virt_slani)="Mezi_MezoSaus_r10000"
writeRaster(virt_slani,"./Rastri_100m/RAW/Mezi_MezoSaus_r10000.tif",overwrite=TRUE)

## Mezi_OligoSaus_r10000.tif
slani=list.files("./IevadesDati/ainava/ClassArea/Mezi_OligoSaus_r10000/",full.names = TRUE)
virt_slani=terra::vrt(slani)
names(virt_slani)="Mezi_OligoSaus_r10000"
writeRaster(virt_slani,"./Rastri_100m/RAW/Mezi_OligoSaus_r10000.tif",overwrite=TRUE)

## Mezi_OligoSus_r10000.tif
slani=list.files("./IevadesDati/ainava/ClassArea/Mezi_OligoSus_r10000/",full.names = TRUE)
virt_slani=terra::vrt(slani)
names(virt_slani)="Mezi_OligoSus_r10000"
writeRaster(virt_slani,"./Rastri_100m/RAW/Mezi_OligoSus_r10000.tif",overwrite=TRUE)

## Mezi_Saurlapju_r10000.tif
slani=list.files("./IevadesDati/ainava/ClassArea/Mezi_Saurlapju_r10000/",full.names = TRUE)
virt_slani=terra::vrt(slani)
names(virt_slani)="Mezi_Saurlapju_r10000"
writeRaster(virt_slani,"./Rastri_100m/RAW/Mezi_Saurlapju_r10000.tif",overwrite=TRUE)

