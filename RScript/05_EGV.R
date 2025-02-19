# komandu rindas 33 vistu vanaga izplatības modeļa parametrizācijā 
# izmantoto ekoģeogrāfisko mainīgo sagatavošanai

# daļas EGV sgatavošana ir visai apjomīgi procesēšanas uzdevumi

# zemāk esošie nodaļu nosaukumi ir EGV-slāņu nosaukumi. Aiz tiem uzreiz nākošajā
# rindā ir EGV nosaukums, kāds izmantots attēlos un gala pārskatā.
# katram mainīgajam EGV pēc nosaukuma uzskaitīti izmantotie ievades ģeodati 
# vai ievades ģeodatu starprezultāti, lai atvieglotu to savstarpējo saistīšanu

# Šeit slāņu veidošanas komandu rindas ir piedāvātas kā ik individuāla slāņa sagatavošanai,
# ar kopīgām nodaļām "direkotrijas", "pakotnes", "templates", "utility" un "ciklu vadībai",
# lai gan faktiskā sagatavošana daudz ātrāka būtu tos apvienojot loģiskās grupās,
# kuru sagatavošanu veikt vienkop:
# - analīzes šūnas ietvaros esošie EGV
# - klases platības mainīgie buferzonās apa analīzes šūnas centru
# - malu mainīgie

# Šada pieeja izvēlēta, lai uzlabotu ik EGV sagatavošanas procedūras izvērtēšanu

# Šī komandu rindu faila beigās ir izveidoto slāņu harmonizēšana. 
# Tai nepieciešamie faili (bez pašiem slāņiem) ir šajā repozitorijā

# direktorijas ----

dir.create("./Rastri_100m/RAW/")
dir.create("./Rastri_100m/Proj/")
dir.create("./Rastri_100m/Scaled/")
dir.create("./IevadesDati/ainava/ClassArea/Ainava_MeziNetaksets_r3000", recursive=TRUE)
dir.create("./IevadesDati/ainava/ClassArea/Ainava_Vasarnicas_r10000", recursive=TRUE)
dir.create("./IevadesDati/ainava/ClassArea/Lauku_Papuves_r10000", recursive=TRUE)
dir.create("./IevadesDati/ainava/ClassArea/Lauku_ZalajiVisi_r10000", recursive=TRUE)
dir.create("./IevadesDati/ainava/Malas/Malas_Apbuve_Koki_cell",recursive=TRUE)
dir.create("./IevadesDati/ainava/Malas/Malas_Apbuve_Koki_r3000", recursive=TRUE)
dir.create("./IevadesDati/ainava/Malas/Malas_AramzemesY_cell", recursive=TRUE)
dir.create("./IevadesDati/ainava/Malas/Malas_AramzemesY_r10000", recursive=TRUE)
dir.create("./IevadesDati/ainava/Malas/Malas_LIZzemieKoki_Koki_cell", recursive=TRUE)
dir.create("./IevadesDati/ainava/Malas/Malas_LIZzemieKoki_Koki_r10000", recursive=TRUE)
dir.create("./IevadesDati/ainava/ClassArea/Mezi_EitrSus_r10000", recursive=TRUE)
dir.create("./IevadesDati/ainava/ClassArea/Mezi_JauktukokuJaunas_r3000", recursive=TRUE)
dir.create("./IevadesDati/ainava/ClassArea/Mezi_MezoSaus_r10000", recursive=TRUE)
dir.create("./IevadesDati/ainava/ClassArea/Mezi_OligoSaus_r10000", recursive=TRUE)
dir.create("./IevadesDati/ainava/ClassArea/Mezi_OligoSus_r10000", recursive=TRUE)
dir.create("./IevadesDati/ainava/ClassArea/Mezi_Saurlapju_r10000", recursive=TRUE)



# pakotnes -----

library(tidyverse)
library(sf)
library(arrow)
library(sfarrow)
library(terra)
library(raster)
library(fasterize)
library(gdalUtilities)
library(readxl)
library(exactextractr)
library(whitebox)

library(landscapemetrics)

library(foreach)
library(doParallel)

# templates ----
template10=rast("./Templates/TemplateRasters/LV10m_10km.tif")
template100=rast("./Templates/TemplateRasters/LV100m_10km.tif")

paraugs=template10
rastrs100=raster::raster(template100)


paraugs_10=rast("./Templates/TemplateRasters/LV10m_10km.tif")
paraugs_100m=rast("./Templates/TemplateRasters/LV100m_10km.tif")
rastrs_100m=raster::raster(paraugs_100m)
rastrs_10m=raster::raster(paraugs_10)


template10=rast("./Templates/TemplateRasters/LV10m_10km.tif")
template100=rast("./Templates/TemplateRasters/LV100m_10km.tif")
r100=raster::raster(template100)
r10=raster::raster(template10)

t_nulles=subst(template10,1,0)
r_nulles=raster::raster(t_nulles)

t_0_100=subst(template100,1,0)
r_0_100=raster::raster(t_0_100)



# utility ----

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


# ciklu vadībai ----


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

#rm(kvadratiem)
rm(kvadratiem_r500)
rm(kvadratiem_r1250)
rm(kvadratiem_r3000)
rm(kvadratiem_r10000)

numuri=levels(factor(kvadrati$numurs))

tikls100=st_read_parquet("./Templates/TemplateGrids/tikls100_sauzeme.parquet")
rezgis=tikls100



## cikls tukšs ----


cl <- makeCluster(8)
registerDoParallel(cl)
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
  r500=st_read_parquet(celi$cels_r500)
  r500=r500 %>% dplyr::select(id)
  r1250=st_read_parquet(celi$cels_r1250)
  r1250=r1250 %>% dplyr::select(id)
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
  
  
  # šeit
  
  
  
  
  beigas=Sys.time()
  ilgums=beigas-sakums
  print(ilgums)
}
stopCluster(cl)





# Ainava_MeziNetaksets_cell.tif ----
# Netaksēto mežu platības īpatsvars analīzes šūnā
# Ievades (tiešās) atkarības: 
## `./Rastri_10m/Ainava_MeziNetaksets.tif`

slanis=terra::rast("./Rastri_10m/Ainava_MeziNetaksets.tif")
slanis
cels="./Rastri_100m/RAW/Ainava_MeziNetaksets_cell.tif"
if(minmax(slanis,compute=FALSE)[2]>1){
  EGVcell_mean_recl(slanis,template100,cels)
} else {
  EGVcell_mean(slanis,template100,cels)}





# Ainava_MeziNetaksets_r3000.tif ----
# Netaksēto mežu platības īpatsvars r=3000m ap analīzes šūnas centru
# Ievades (tiešās) atkarības: 
## `./Rastri_100m/RAW/Ainava_MeziNetaksets_cell.tif`



cl <- makeCluster(8)
registerDoParallel(cl)
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
  
  sunas300=tikls100 %>% 
    filter(rinda300 %in% r3000$rinda300) %>% 
    dplyr::select(id,yes,tks50km,rinda300,rinda500,ID1km)
  
  telpa=st_as_sfc(st_bbox(r3000))
  telpa2=st_buffer(telpa,dist=1000)
  
  
  template_100=rast("./Templates/TemplateRasters/LV100m_10km.tif")
  temp100_mazs=crop(template_100,telpa2)
  rastrs_100_mazs=raster::raster(temp100_mazs)
  
  
  
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
  
  
  
  beigas=Sys.time()
  ilgums=beigas-sakums
  print(ilgums)
}
stopCluster(cl)

slani=list.files("./IevadesDati/ainava/ClassArea/Ainava_MeziNetaksets_r3000/",full.names = TRUE)
virt_slani=terra::vrt(slani)
names(virt_slani)="Ainava_MeziNetaksets_r3000"
writeRaster(virt_slani,"./Rastri_100m/RAW/Ainava_MeziNetaksets_r3000.tif",overwrite=TRUE)




# Ainava_Vasarnicas_r10000.tif ----
# Mazdārziņu un vasarnīcu koloniju platības īpatsvars r=10000m ap analīzes šūnas centru
# Ievades (tiešās) atkarības: 
## "./Rastri_10m/Ainava_VasarnicasYN.tif"



slanis=terra::rast("./Rastri_10m/Ainava_VasarnicasYN.tif")
slanis
cels="./Rastri_100m/RAW/Ainava_Vasarnicas_cell.tif"
if(minmax(slanis,compute=FALSE)[2]>1){
  EGVcell_mean_recl(slanis,template100,cels)
} else {
  EGVcell_mean(slanis,template100,cels)}



cl <- makeCluster(8)
registerDoParallel(cl)
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
  r10000=st_read_parquet(celi$cels_r10000)
  r10000=r10000 %>% dplyr::select(ID1km)
  
  sunas1000=tikls100 %>% 
    filter(ID1km %in% r10000$ID1km) %>% 
    dplyr::select(id,yes,tks50km,rinda300,rinda500,ID1km)
  
  telpa=st_as_sfc(st_bbox(r10000))
  telpa2=st_buffer(telpa,dist=1000)
  
  
  template_100=rast("./Templates/TemplateRasters/LV100m_10km.tif")
  temp100_mazs=crop(template_100,telpa2)
  rastrs_100_mazs=raster::raster(temp100_mazs)
  
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
  
  
  
  
  beigas=Sys.time()
  ilgums=beigas-sakums
  print(ilgums)
}
stopCluster(cl)


slani=list.files("./IevadesDati/ainava/ClassArea/Ainava_Vasarnicas_r10000/",full.names = TRUE)
virt_slani=terra::vrt(slani)
names(virt_slani)="Ainava_Vasarnicas_r10000"
writeRaster(virt_slani,"./Rastri_100m/RAW/Ainava_Vasarnicas_r10000.tif",overwrite=TRUE)





# Climate_FebPrec_cell.tif ----
# Februāra (gada aukstākā mēneša) nokrišņu summu mediāna 2015-2023
# Ievades (tiešās) atkarības: 
## ./IevadesDati/klimats/mozaikas/FebPrec.tif

FebPrec=rast("./IevadesDati/klimats/mozaikas/FebPrec.tif")

soli=levels(factor(rezgis$tks50km))
dati=rezgis %>% filter(tks50km == soli[1])
dati$FebPrec=exactextractr::exact_extract(FebPrec,dati,"mean")


for(i in 2:length(soli)){
  sakums=Sys.time()
  print(i)
  solis=soli[i]
  rezgitis=rezgis %>% filter(tks50km==solis)
  
  rezgitis$FebPrec=exactextractr::exact_extract(FebPrec,rezgitis,"mean")
  
  dati=bind_rows(dati,rezgitis)
  
}

centri=st_centroid(dati)
koords=st_coordinates(centri)
dati$X=koords[,1]
dati$Y=koords[,2]


mod_FebPrec=gam(FebPrec~s(X,Y),data=dati)
dati$fit_FebPrec=predict(mod_FebPrec,dati)
dati$new_FebPrec=ifelse(is.na(dati$FebPrec),dati$fit_FebPrec,dati$FebPrec)

FebPrec=fasterize::fasterize(dati,rastrs100,field="new_FebPrec")
FebPrec=rast(FebPrec)
FebPrec2=terra::mask(FebPrec,template100,overwrite=TRUE,filename=paste0("./Rastri_100m/RAW/climate_FebPrec.tif"))



# Climate_JulPrec_cell.tif ----
# Jūlija (gada siltākā mēneša) nokrišņu summu mediāna 2015-2023
# Ievades (tiešās) atkarības: 
## ./IevadesDati/klimats/mozaikas/JulPrec.tif


JulPrec=rast("./IevadesDati/klimats/mozaikas/JulPrec.tif")

soli=levels(factor(rezgis$tks50km))
dati=rezgis %>% filter(tks50km == soli[1])
dati$JulPrec=exactextractr::exact_extract(JulPrec,dati,"mean")

for(i in 2:length(soli)){
  sakums=Sys.time()
  print(i)
  solis=soli[i]
  rezgitis=rezgis %>% filter(tks50km==solis)
  
  rezgitis$JulPrec=exactextractr::exact_extract(JulPrec,rezgitis,"mean")
  
  dati=bind_rows(dati,rezgitis)
  
}

centri=st_centroid(dati)
koords=st_coordinates(centri)
dati$X=koords[,1]
dati$Y=koords[,2]


mod_JulPrec=gam(JulPrec~s(X,Y),data=dati)
dati$fit_JulPrec=predict(mod_JulPrec,dati)
dati$new_JulPrec=ifelse(is.na(dati$JulPrec),dati$fit_JulPrec,dati$JulPrec)


JulPrec=fasterize::fasterize(dati,rastrs100,field="new_JulPrec")
JulPrec=rast(JulPrec)
JulPrec2=terra::mask(JulPrec,template100,overwrite=TRUE,filename="./Rastri_100m/RAW/climate_JulPrec.tif")


# Climate_VegTempSums_cell.tif ----
# Dienas vidējo temperatūru 2 m augstumā vismaz 279 grādi K summu mediāna 2015-2023
# Ievades (tiešās) atkarības: 
## ./IevadesDati/klimats/mozaikas/VegTempSums.tif

VegTempSums=rast("./IevadesDati/klimats/mozaikas/VegTempSums.tif")

soli=levels(factor(rezgis$tks50km))
dati=rezgis %>% filter(tks50km == soli[1])
dati$VegTempSums=exactextractr::exact_extract(VegTempSums,dati,"mean")

for(i in 2:length(soli)){
  sakums=Sys.time()
  print(i)
  solis=soli[i]
  rezgitis=rezgis %>% filter(tks50km==solis)
  
  rezgitis$VegTempSums=exactextractr::exact_extract(VegTempSums,rezgitis,"mean")
  
  dati=bind_rows(dati,rezgitis)
  
}


centri=st_centroid(dati)
koords=st_coordinates(centri)
dati$X=koords[,1]
dati$Y=koords[,2]


mod_VegTempSums=gam(VegTempSums~s(X,Y),data=dati)
dati$fit_VegTempSums=predict(mod_VegTempSums,dati)
dati$new_VegTempSums=ifelse(is.na(dati$VegTempSums),dati$fit_VegTempSums,dati$VegTempSums)


VegTempSums=fasterize::fasterize(dati,rastrs100,field="new_VegTempSums")
VegTempSums=rast(VegTempSums)
VegTempSums2=terra::mask(VegTempSums,template100,overwrite=TRUE,filename="./Rastri_100m/RAW/climate_VegTempSums.tif")





# Climate_YearPrecSum_cell.tif ----
# Uzkrāto ik mēneša nokrišņu summu mediāna 2015-2023
# Ievades (tiešās) atkarības: 
## ./IevadesDati/klimats/mozaikas/YearPrecSum.tif 


YearPrecSum=rast("./IevadesDati/klimats/mozaikas/YearPrecSum.tif")

soli=levels(factor(rezgis$tks50km))
dati=rezgis %>% filter(tks50km == soli[1])
dati$YearPrecSum=exactextractr::exact_extract(YearPrecSum,dati,"mean")

for(i in 2:length(soli)){
  sakums=Sys.time()
  print(i)
  solis=soli[i]
  rezgitis=rezgis %>% filter(tks50km==solis)
  
  rezgitis$YearPrecSum=exactextractr::exact_extract(YearPrecSum,rezgitis,"mean")
  
  dati=bind_rows(dati,rezgitis)
  
}

centri=st_centroid(dati)
koords=st_coordinates(centri)
dati$X=koords[,1]
dati$Y=koords[,2]

mod_YearPrecSum=gam(YearPrecSum~s(X,Y),data=dati)
dati$fit_YearPrecSum=predict(mod_YearPrecSum,dati)
dati$new_YearPrecSum=ifelse(is.na(dati$YearPrecSum),dati$fit_YearPrecSum,dati$YearPrecSum)


YearPrecSum=fasterize::fasterize(dati,rastrs100,field="new_YearPrecSum")
YearPrecSum=rast(YearPrecSum)
YearPrecSum2=terra::mask(YearPrecSum,template100,overwrite=TRUE,filename="./Rastri_100m/RAW/climate_YearPrecSum.tif")




# Dist_AtkritumuPoligoni-vid_cell.tif ----
# Attālums līdz atkritumu poligoniem, vidējais analīzes šūnā
# Ievades (tiešās) atkarības: 
## ./IevadesDati/atkritumi/Waste.xlsx

atkritumi1=read_excel("./IevadesDati/atkritumi/Waste.xlsx",sheet="Poligoni")
poligoni_sf=st_as_sf(atkritumi1,coords=c("X","Y"),crs=3059)
pol_rast=rasterize(poligoni_sf,paraugs_100m)

nullem100=subst(paraugs_100m,1,0)
pol_rast2=cover(pol_rast,nullem100)

writeRaster(pol_rast2,"./Rastri_10m/AtkritumuPoligoni_100.tif",overwrite=TRUE)

q=wbt_euclidean_distance(
  input="./Rastri_10m/AtkritumuPoligoni_100.tif",
  output="./Rastri_100m/RAW/dist_AtkritumuPoligoni_vid.tif"
)




# Dist_Jura-vid_cell.tif ----
# Attālums līdz jūrai, vidējais analīzes šūnā
# Ievades (tiešās) atkarības: 
## ./IevadesDati/LV_EEZ/LV_EEZ.shp


jura=st_read("./IevadesDati/LV_EEZ/LV_EEZ.shp")
r_jura=fasterize(jura,rastrs_10m,field="LV_EEZ")
t_jura=rast(r_jura)

nulles=subst(paraugs_10,1,0)
prieks_dist_jura=cover(t_jura,nulles)

q=wbt_euclidean_distance(
  input=prieks_dist_jura,
  output="./Rastri_10m/dist_Jura.tif"
)
dist_jura=rast("./Rastri_10m/dist_Jura.tif")
dist_jura2=ifel(!is.na(nulles),dist_jura,nulles)
dist_jura_vid_cell=resample(dist_jura2,paraugs_100m,method="average",
                            filename="./Rastri_100m/RAW/dist_Jura_vid.tif",
                            overwrite=TRUE)



# Lauku_AramVisas_cell.tif ----
# Visu aramzemju klašu platības īpatsvars analīzes šūnā
# Ievades (tiešās) atkarības: 
## ./Rastri_10m/Lauki_AramzemesYN.tif


slanis=terra::rast("./Rastri_10m/Lauki_AramzemesYN.tif")
slanis
cels="./Rastri_100m/RAW/Lauku_AramVisas_cell.tif"
if(minmax(slanis,compute=FALSE)[2]>1){
  EGVcell_mean_recl(slanis,template100,cels)
} else {
  EGVcell_mean(slanis,template100,cels)}





# Lauku_Papuves_r10000.tif ----
# LAD papuvju platības īpatsvars r=10000 m ap analīzes šūnas centru
# Ievades (tiešās) atkarības: 
## ./Rastri_10m/Lauki_papuvesYN.tif




slanis=terra::rast("./Rastri_10m/Lauki_papuvesYN.tif")
slanis
cels="./Rastri_100m/RAW/Lauku_Papuves_cell.tif"
if(minmax(slanis,compute=FALSE)[2]>1){
  EGVcell_mean_recl(slanis,template100,cels)
} else {
  EGVcell_mean(slanis,template100,cels)}



cl <- makeCluster(8)
registerDoParallel(cl)
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
  r10000=st_read_parquet(celi$cels_r10000)
  r10000=r10000 %>% dplyr::select(ID1km)
  
  sunas1000=tikls100 %>% 
    filter(ID1km %in% r10000$ID1km) %>% 
    dplyr::select(id,yes,tks50km,rinda300,rinda500,ID1km)
  
  telpa=st_as_sfc(st_bbox(r10000))
  telpa2=st_buffer(telpa,dist=1000)
  
  
  template_100=rast("./Templates/TemplateRasters/LV100m_10km.tif")
  temp100_mazs=crop(template_100,telpa2)
  rastrs_100_mazs=raster::raster(temp100_mazs)
  
  
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
  
  
  beigas=Sys.time()
  ilgums=beigas-sakums
  print(ilgums)
}
stopCluster(cl)

slani=list.files("./IevadesDati/ainava/ClassArea/Lauku_Papuves_r10000/",full.names = TRUE)
virt_slani=terra::vrt(slani)
names(virt_slani)="Lauku_Papuves_r10000"
writeRaster(virt_slani,"./Rastri_100m/RAW/Lauku_Papuves_r10000.tif",overwrite=TRUE)


# Lauku_ZalajiVisi_r10000.tif ----
# Visu zālāju klašu platības īpatsvars r=10000 m ap analīzes šūnas centru
# Ievades (tiešās) atkarības: 
## ./Rastri_10m/Lauki_zalajiYN.tif


slanis=terra::rast("./Rastri_10m/Lauki_zalajiYN.tif")
slanis
cels="./Rastri_100m/RAW/Lauku_ZalajiVisi_cell.tif"
if(minmax(slanis,compute=FALSE)[2]>1){
  EGVcell_mean_recl(slanis,template100,cels)
} else {
  EGVcell_mean(slanis,template100,cels)}



cl <- makeCluster(8)
registerDoParallel(cl)
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
  r10000=st_read_parquet(celi$cels_r10000)
  r10000=r10000 %>% dplyr::select(ID1km)
  
  sunas1000=tikls100 %>% 
    filter(ID1km %in% r10000$ID1km) %>% 
    dplyr::select(id,yes,tks50km,rinda300,rinda500,ID1km)
  
  telpa=st_as_sfc(st_bbox(r10000))
  telpa2=st_buffer(telpa,dist=1000)
  
  
  template_100=rast("./Templates/TemplateRasters/LV100m_10km.tif")
  temp100_mazs=crop(template_100,telpa2)
  rastrs_100_mazs=raster::raster(temp100_mazs)
  
  
  slanis=rast("./Rastri_100m/RAW/Lauku_ZalajiVisi_cell.tif")
  slanis_mazs=crop(slanis,telpa2)
  
  
  
  
  beigas=Sys.time()
  ilgums=beigas-sakums
  print(ilgums)
}
stopCluster(cl)

slani=list.files("./IevadesDati/ainava/ClassArea/Lauku_ZalajiVisi_r10000/",full.names = TRUE)
virt_slani=terra::vrt(slani)
names(virt_slani)="Lauku_ZalajiVisi_r10000"
writeRaster(virt_slani,"./Rastri_100m/RAW/Lauku_ZalajiVisi_r10000.tif",overwrite=TRUE)



# Malas_Apbuve-Koki_r3000.tif ----
# Šūnu (10m), kuras raksturo robežu starp apbūvi un kokiem, skaits r=3000 m ap analīzes šūnas centru
# Ievades (tiešās) atkarības: 
## ./Rastri_10m/Malam_Apbuve_koki.tif

cl <- makeCluster(24)
registerDoParallel(cl)

foreach(i = 1:length(numuri)) %dopar% {
  library(tidyverse)
  library(sf)
  library(arrow)
  library(sfarrow)
  library(terra)
  library(raster)
  library(exactextractr)
  library(fasterize)
  library(landscapemetrics)
  
  
  sakums=Sys.time()
  print(i)
  solis=numuri[i]
  celi=kvadratiem %>% filter(numurs==solis)
  
  sunas=st_read_parquet(celi$cels_c)
  sunas=sunas %>% dplyr::select(id,tks50km)
  
  telpa=st_as_sfc(st_bbox(sunas))
  telpa2=st_buffer(telpa,dist=1000)
  
  
  template_10=rast("./Templates/TemplateRasters/LV10m_10km.tif")
  temp10_mazs=crop(template_10,telpa2)
  template_100=rast("./Templates/TemplateRasters/LV100m_10km.tif")
  temp100_mazs=crop(template_100,telpa2)
  rastrs_100_mazs=raster::raster(temp100_mazs)
  
  
  # apbūve un koki
  slanis=rast("./Rastri_10m/Malam_Apbuve_koki.tif")
  slanis_mazs=crop(slanis,telpa2)
  ## cell
  a=sample_lsm(slanis_mazs,y=sunas,plot_id=sunas$id,what="lsm_l_te",count_boundary=FALSE)
  a$value[is.na(a$value)]=0
  sunas$vertibas=a$value
  slanis=fasterize::fasterize(sunas,rastrs_100_mazs,field="vertibas")
  slanis=rast(slanis)
  slanis2=terra::mask(slanis,temp100_mazs,overwrite=TRUE,
                      filename=paste0("./IevadesDati/ainava/Malas/Malas_Apbuve_Koki_cell/Malas_Apbuve_Koki_cell_",solis,".tif"))
  
  
  beigas=Sys.time()
  ilgums=beigas-sakums
  print(ilgums)
}
stopCluster(cl)

## cell
slani=list.files("./IevadesDati/ainava/Malas/Malas_Apbuve_Koki_cell/",full.names = TRUE)
virt_slani=terra::vrt(slani)
names(virt_slani)="Malas_Apbuve_Koki_cell"
writeRaster(virt_slani,"./Rastri_100m/RAW/Malas_Apbuve_Koki_cell.tif",overwrite=TRUE)

## r3000
cl <- makeCluster(24)
registerDoParallel(cl)

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
  
  sunas300=tikls100 %>% 
    filter(rinda300 %in% r3000$rinda300) %>% 
    dplyr::select(id,yes,tks50km,rinda300,rinda500,ID1km)
  
  telpa=st_as_sfc(st_bbox(r3000))
  telpa2=st_buffer(telpa,dist=1000)
  
  template_100=rast("./Templates/TemplateRasters/LV100m_10km.tif")
  temp100_mazs=crop(template_100,telpa2)
  rastrs_100_mazs=raster::raster(temp100_mazs)
  
  
  # apbūve un koki
  slanis=rast("./Rastri_100m/RAW/Malas_Apbuve_Koki_cell.tif")
  slanis_mazs=crop(slanis,telpa2)
  
  ## r3000
  r3000$vertibas=exact_extract(slanis_mazs,r3000,"sum")
  x3000=data.frame(r3000) %>% dplyr::select(rinda300,vertibas)
  sunas300=sunas300 %>% 
    dplyr::select(id,yes,tks50km,rinda300,rinda500,ID1km) %>% 
    left_join(x3000,by="rinda300")
  rezA=fasterize::fasterize(sunas300,rastrs_100_mazs,field="vertibas")
  rezA=rast(rezA)
  rezB=terra::mask(rezA,temp100_mazs,overwrite=TRUE,
                   filename=paste0("./IevadesDati/ainava/Malas/Malas_Apbuve_Koki_r3000/Malas_Apbuve_Koki_r3000","_",solis,".tif"))
  
  
  beigas=Sys.time()
  ilgums=beigas-sakums
  print(ilgums)
}
stopCluster(cl)


slani=list.files("./IevadesDati/ainava/Malas/Malas_Apbuve_Koki_r3000/",full.names = TRUE)
virt_slani=terra::vrt(slani)
names(virt_slani)="Malas_Apbuve_Koki_r3000"
writeRaster(virt_slani,"./Rastri_100m/RAW/Malas_Apbuve_Koki_r3000.tif",overwrite=TRUE)



# Malas_AramzemesY_cell.tif ----
# Šūnu (10m), kuras raksturo aramzemju malas ar jebko citu, skaits analīzes šūnā
# Ievades (tiešās) atkarības: 
## ./Rastri_10m/Malam_Aramzemes_Y.tif


library(foreach)
library(doParallel)
cl <- makeCluster(4)
registerDoParallel(cl)

foreach(i = 1:length(numuri)) %dopar% {
  library(tidyverse)
  library(sf)
  library(arrow)
  library(sfarrow)
  library(terra)
  library(raster)
  library(exactextractr)
  library(fasterize)
  library(landscapemetrics)
  
  
  sakums=Sys.time()
  print(i)
  solis=numuri[i]
  celi=kvadratiem %>% filter(numurs==solis)
  
  sunas=st_read_parquet(celi$cels_c)
  sunas=sunas %>% dplyr::select(id,tks50km)
  
  telpa=st_as_sfc(st_bbox(sunas))
  telpa2=st_buffer(telpa,dist=1000)
  
  
  template_10=rast("./Templates/TemplateRasters/LV10m_10km.tif")
  temp10_mazs=crop(template_10,telpa2)
  template_100=rast("./Templates/TemplateRasters/LV100m_10km.tif")
  temp100_mazs=crop(template_100,telpa2)
  rastrs_100_mazs=raster::raster(temp100_mazs)
  
  
  
  
  # aramzemju malas
  slanis=rast("./Rastri_10m/Malam_Aramzemes_Y.tif")
  slanis_mazs=crop(slanis,telpa2)
  ## cell
  a=sample_lsm(slanis_mazs,y=sunas,plot_id=sunas$id,what="lsm_l_te",count_boundary=FALSE)
  a$value[is.na(a$value)]=0
  sunas$vertibas=a$value
  slanis=fasterize::fasterize(sunas,rastrs_100_mazs,field="vertibas")
  slanis=rast(slanis)
  slanis2=terra::mask(slanis,temp100_mazs,overwrite=TRUE,
                      filename=paste0("./IevadesDati/ainava/Malas/Malas_AramzemesY_cell/Malas_AramzemesY_cell_",solis,".tif"))
  
  
  
  
  beigas=Sys.time()
  ilgums=beigas-sakums
  print(ilgums)
}
stopCluster(cl)


slani=list.files("./IevadesDati/ainava/Malas/Malas_AramzemesY_cell/",full.names = TRUE)
virt_slani=terra::vrt(slani)
names(virt_slani)="Malas_AramzemesY_cell"
writeRaster(virt_slani,"./Rastri_100m/RAW/Malas_AramzemesY_cell.tif",overwrite=TRUE)



# Malas_AramzemesY_r10000.tif ----
# Šūnu (10m), kuras raksturo aramzemju malas ar jebko citu, skaits r=10000 m ap analīzes šūnas centru
# Ievades (tiešās) atkarības: 
## ./Rastri_100m/RAW/Malas_AramzemesY_cell.tif



cl <- makeCluster(8)
registerDoParallel(cl)
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
  r10000=st_read_parquet(celi$cels_r10000)
  r10000=r10000 %>% dplyr::select(ID1km)
  
  sunas1000=tikls100 %>% 
    filter(ID1km %in% r10000$ID1km) %>% 
    dplyr::select(id,yes,tks50km,rinda300,rinda500,ID1km)
  
  telpa=st_as_sfc(st_bbox(r10000))
  telpa2=st_buffer(telpa,dist=1000)
  
  
  template_100=rast("./Templates/TemplateRasters/LV100m_10km.tif")
  temp100_mazs=crop(template_100,telpa2)
  rastrs_100_mazs=raster::raster(temp100_mazs)
  
  
  slanis=rast("./Rastri_100m/RAW/Malas_AramzemesY_cell.tif")
  slanis_mazs=crop(slanis,telpa2)
  
  r10000$vertibas=exact_extract(slanis_mazs,r10000,"sum")
  x10000=data.frame(r10000) %>% dplyr::select(ID1km,vertibas)
  sunas1000=sunas1000 %>% 
    dplyr::select(id,yes,tks50km,rinda300,rinda500,ID1km) %>% 
    left_join(x10000,by="ID1km")
  rezA=fasterize::fasterize(sunas1000,rastrs_100_mazs,field="vertibas")
  rezA=rast(rezA)
  rezB=terra::mask(rezA,temp100_mazs,overwrite=TRUE,
                   filename=paste0("./IevadesDati/ainava/Malas/Malas_AramzemesY_r10000/Malas_AramzemesY_r10000","_",solis,".tif"))
  
  
  
  beigas=Sys.time()
  ilgums=beigas-sakums
  print(ilgums)
}
stopCluster(cl)

slani=list.files("./IevadesDati/ainava/Malas/Malas_AramzemesY_r10000/",full.names = TRUE)
virt_slani=terra::vrt(slani)
names(virt_slani)="Malas_AramzemesY_r10000"
writeRaster(virt_slani,"./Rastri_100m/RAW/Malas_AramzemesY_r10000.tif",overwrite=TRUE)




# Malas_LIZzemieKoki-Koki_cell.tif ----
# Šūnu (10m), kuras raksturo LIZ_izcirtumu_krūmu malas ar kokiem (vismaz 5m), skaits analīzes šūnā
# Ievades (tiešās) atkarības: 
## ./Rastri_10m/Malam_LIZzemiekoki_Koki.tif


library(foreach)
library(doParallel)
cl <- makeCluster(4)
registerDoParallel(cl)

foreach(i = 1:length(numuri)) %dopar% {
  library(tidyverse)
  library(sf)
  library(arrow)
  library(sfarrow)
  library(terra)
  library(raster)
  library(exactextractr)
  library(fasterize)
  library(landscapemetrics)
  
  
  sakums=Sys.time()
  print(i)
  solis=numuri[i]
  celi=kvadratiem %>% filter(numurs==solis)
  
  sunas=st_read_parquet(celi$cels_c)
  sunas=sunas %>% dplyr::select(id,tks50km)
  
  telpa=st_as_sfc(st_bbox(sunas))
  telpa2=st_buffer(telpa,dist=1000)
  
  
  template_10=rast("./Templates/TemplateRasters/LV10m_10km.tif")
  temp10_mazs=crop(template_10,telpa2)
  template_100=rast("./Templates/TemplateRasters/LV100m_10km.tif")
  temp100_mazs=crop(template_100,telpa2)
  rastrs_100_mazs=raster::raster(temp100_mazs)
  
  
  slanis=rast("./Rastri_10m/Malam_LIZzemiekoki_Koki.tif")
  slanis_mazs=crop(slanis,telpa2)
  ## cell
  a=sample_lsm(slanis_mazs,y=sunas,plot_id=sunas$id,what="lsm_l_te",count_boundary=FALSE)
  a$value[is.na(a$value)]=0
  sunas$vertibas=a$value
  slanis=fasterize::fasterize(sunas,rastrs_100_mazs,field="vertibas")
  slanis=rast(slanis)
  slanis2=terra::mask(slanis,temp100_mazs,overwrite=TRUE,
                      filename=paste0("./IevadesDati/ainava/Malas/Malas_LIZzemieKoki_Koki_cell/Malas_LIZzemieKoki_Koki_cell_",solis,".tif"))
  
  
  
  beigas=Sys.time()
  ilgums=beigas-sakums
  print(ilgums)
}
stopCluster(cl)

slani=list.files("./IevadesDati/ainava/Malas/Malas_LIZzemieKoki_Koki_cell/",full.names = TRUE)
virt_slani=terra::vrt(slani)
names(virt_slani)="Malas_LIZzemieKoki_Koki_cell"
writeRaster(virt_slani,"./Rastri_100m/RAW/Malas_LIZzemieKoki_Koki_cell.tif",overwrite=TRUE)






# Malas_LIZzemieKoki-Koki_r10000.tif ----
# Šūnu (10m), kuras raksturo LIZ_izcirtumu_krūmu malas ar kokiem (vismaz 5m), skaits r=10000 m ap analīzes šūnas centru
# Ievades (tiešās) atkarības: 
## ./Rastri_100m/RAW/Malas_LIZzemieKoki_Koki_cell.tif



cl <- makeCluster(8)
registerDoParallel(cl)
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
  r10000=st_read_parquet(celi$cels_r10000)
  r10000=r10000 %>% dplyr::select(ID1km)
  
  sunas1000=tikls100 %>% 
    filter(ID1km %in% r10000$ID1km) %>% 
    dplyr::select(id,yes,tks50km,rinda300,rinda500,ID1km)
  
  telpa=st_as_sfc(st_bbox(r10000))
  telpa2=st_buffer(telpa,dist=1000)
  
  
  template_100=rast("./Templates/TemplateRasters/LV100m_10km.tif")
  temp100_mazs=crop(template_100,telpa2)
  rastrs_100_mazs=raster::raster(temp100_mazs)
  
  
  slanis=rast("./Rastri_100m/RAW/Malas_LIZzemieKoki_Koki_cell.tif")
  slanis_mazs=crop(slanis,telpa2)
  r10000$vertibas=exact_extract(slanis_mazs,r10000,"sum")
  x10000=data.frame(r10000) %>% dplyr::select(ID1km,vertibas)
  sunas1000=sunas1000 %>% 
    dplyr::select(id,yes,tks50km,rinda300,rinda500,ID1km) %>% 
    left_join(x10000,by="ID1km")
  rezA=fasterize::fasterize(sunas1000,rastrs_100_mazs,field="vertibas")
  rezA=rast(rezA)
  rezB=terra::mask(rezA,temp100_mazs,overwrite=TRUE,
                   filename=paste0("./IevadesDati/ainava/Malas/Malas_LIZzemieKoki_Koki_r10000/Malas_LIZzemieKoki_Koki_r10000","_",solis,".tif"))
  
  
  
  
  beigas=Sys.time()
  ilgums=beigas-sakums
  print(ilgums)
}
stopCluster(cl)

slani=list.files("./IevadesDati/ainava/Malas/Malas_LIZzemieKoki_Koki_r10000/",full.names = TRUE)
virt_slani=terra::vrt(slani)
names(virt_slani)="Malas_LIZzemieKoki_Koki_r10000"
writeRaster(virt_slani,"./Rastri_100m/RAW/Malas_LIZzemieKoki_Koki_r10000.tif",overwrite=TRUE)






# Mezi_ApsuKraja-sum_cell.tif ----
# VMD MVR reģistrētā pirmā stāva apšu krāja analīzes šūnā
# Ievades (tiešās) atkarības: 
## ./IevadesDati/MVR/nogabali_2024janv.parquet

nogabali=st_read_parquet("./IevadesDati/MVR/nogabali_2024janv.parquet")

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
rm(r_Kraja)
rm(t_Kraja)
rm(t_Kraja2)
rm(KrajasSumma)



# Mezi_BerzuKraja-sum_cell.tif ----
# VMD MVR reģistrētā pirmā stāva bērzu krāja analīzes šūnā
# Ievades (tiešās) atkarības: 
## ./IevadesDati/MVR/nogabali_2024janv.parquet

nogabali=st_read_parquet("./IevadesDati/MVR/nogabali_2024janv.parquet")



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
rm(r_Kraja)
rm(t_Kraja)
rm(t_Kraja2)
rm(KrajasSumma)





# Mezi_EgluKraja-sum_cell.tif ----
# VMD MVR reģistrētā pirmā stāva egļu krāja analīzes šūnā
# Ievades (tiešās) atkarības: 
## ./IevadesDati/MVR/nogabali_2024janv.parquet

nogabali=st_read_parquet("./IevadesDati/MVR/nogabali_2024janv.parquet")


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
rm(r_Kraja)
rm(t_Kraja)
rm(t_Kraja2)
rm(KrajasSumma)







# Mezi_EitrSus_r10000.tif ----
# Eitrofu susināto mežu (MVR MAAT klase) platības īpatsvars r=10000 m ap analīzes šūnas centru
# Ievades (tiešās) atkarības: 
## ./Rastri_10m/Mezi_EitrSus.tif


slanis=terra::rast("./Rastri_10m/Mezi_EitrSus.tif")
slanis
cels="./Rastri_100m/RAW/Mezi_EitrSus_cell.tif"
if(minmax(slanis,compute=FALSE)[2]>1){
  EGVcell_mean_recl(slanis,template100,cels)
} else {
  EGVcell_mean(slanis,template100,cels)}



cl <- makeCluster(8)
registerDoParallel(cl)
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
  r10000=st_read_parquet(celi$cels_r10000)
  r10000=r10000 %>% dplyr::select(ID1km)
  
  sunas1000=tikls100 %>% 
    filter(ID1km %in% r10000$ID1km) %>% 
    dplyr::select(id,yes,tks50km,rinda300,rinda500,ID1km)
  
  telpa=st_as_sfc(st_bbox(r10000))
  telpa2=st_buffer(telpa,dist=1000)
  
  
  template_100=rast("./Templates/TemplateRasters/LV100m_10km.tif")
  temp100_mazs=crop(template_100,telpa2)
  rastrs_100_mazs=raster::raster(temp100_mazs)
  
  
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
  
  
  
  
  beigas=Sys.time()
  ilgums=beigas-sakums
  print(ilgums)
}
stopCluster(cl)

slani=list.files("./IevadesDati/ainava/ClassArea/Mezi_EitrSus_r10000/",full.names = TRUE)
virt_slani=terra::vrt(slani)
names(virt_slani)="Mezi_EitrSus_r10000"
writeRaster(virt_slani,"./Rastri_100m/RAW/Mezi_EitrSus_r10000.tif",overwrite=TRUE)





# Mezi_IzcUNzem5m_cell.tif ----
# Izcirtumu un MVR mežaudžu līdz 5 m platības īpatsvars analīzes šūnā
# Ievades (tiešās) atkarības: 
## ./Rastri_10m/Mezi_IzcUNzem5m.tif


slanis=terra::rast("./Rastri_10m/Mezi_IzcUNzem5m.tif")
slanis
cels="./Rastri_100m/RAW/Mezi_IzcUNzem5m_cell.tif"
if(minmax(slanis,compute=FALSE)[2]>1){
  EGVcell_mean_recl(slanis,template100,cels)
} else {
  EGVcell_mean(slanis,template100,cels)}







# Mezi_JauktukokuJaunas_r3000.tif ----
# VMD MVR reģistrēto jauktu koku jaunaudžu, vidēja vecuma un briestaudžu platības īpatsvars r=3000 m ap analīzes šūnas centru
# Ievades (tiešās) atkarības: 
## ./Rastri_10m/Mezi_JauktkokuJaunas.tif

slanis=terra::rast("./Rastri_10m/Mezi_JauktkokuJaunas.tif")
slanis
cels="./Rastri_100m/RAW/Mezi_JauktukokuJaunas_cell.tif"
if(minmax(slanis,compute=FALSE)[2]>1){
  EGVcell_mean_recl(slanis,template100,cels)
} else {
  EGVcell_mean(slanis,template100,cels)}



cl <- makeCluster(8)
registerDoParallel(cl)
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
  
  sunas300=tikls100 %>% 
    filter(rinda300 %in% r3000$rinda300) %>% 
    dplyr::select(id,yes,tks50km,rinda300,rinda500,ID1km)
  
  telpa=st_as_sfc(st_bbox(r3000))
  telpa2=st_buffer(telpa,dist=1000)
  
  
  template_100=rast("./Templates/TemplateRasters/LV100m_10km.tif")
  temp100_mazs=crop(template_100,telpa2)
  rastrs_100_mazs=raster::raster(temp100_mazs)
  
  
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
  
  
  
  
  beigas=Sys.time()
  ilgums=beigas-sakums
  print(ilgums)
}
stopCluster(cl)


slani=list.files("./IevadesDati/ainava/ClassArea/Mezi_JauktukokuJaunas_r3000/",full.names = TRUE)
virt_slani=terra::vrt(slani)
names(virt_slani)="Mezi_JauktukokuJaunas_r3000"
writeRaster(virt_slani,"./Rastri_100m/RAW/Mezi_JauktukokuJaunas_r3000.tif",overwrite=TRUE)


# Mezi_LielakaisDiametrs-max_cell.tif ----
# VMD MVR reģistrētais lielākā koka diametrs analīzes šūnā
# Ievades (tiešās) atkarības: 
## ./IevadesDati/MVR/nogabali_2024janv.parquet

nogabali=st_read_parquet("./IevadesDati/MVR/nogabali_2024janv.parquet")

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







# Mezi_MelnalksnuKraja-sum_cell.tif ----
# VMD MVR reģistrētā pirmā stāva melnalkšņu krāja analīzes šūnā
# Ievades (tiešās) atkarības: 
## ./IevadesDati/MVR/nogabali_2024janv.parquet

nogabali=st_read_parquet("./IevadesDati/MVR/nogabali_2024janv.parquet")


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
rm(r_Kraja)
rm(t_Kraja)
rm(t_Kraja2)
rm(KrajasSumma)






# Mezi_MezoSaus_r10000.tif ----
# Mezotrofu sausieņu un slapjaiņu mežu (MVR MAAT klase) platības īpatsvars r=10000 m ap analīzes šūnas centru
# Ievades (tiešās) atkarības: 
## ./Rastri_10m/Mezi_MezoSaus.tif

slanis=terra::rast("./Rastri_10m/Mezi_MezoSaus.tif")
slanis
cels="./Rastri_100m/RAW/Mezi_MezoSaus_cell.tif"
if(minmax(slanis,compute=FALSE)[2]>1){
  EGVcell_mean_recl(slanis,template100,cels)
} else {
  EGVcell_mean(slanis,template100,cels)}



cl <- makeCluster(8)
registerDoParallel(cl)
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
  r10000=st_read_parquet(celi$cels_r10000)
  r10000=r10000 %>% dplyr::select(ID1km)
  
  sunas1000=tikls100 %>% 
    filter(ID1km %in% r10000$ID1km) %>% 
    dplyr::select(id,yes,tks50km,rinda300,rinda500,ID1km)
  
  telpa=st_as_sfc(st_bbox(r10000))
  telpa2=st_buffer(telpa,dist=1000)
  
  
  template_100=rast("./Templates/TemplateRasters/LV100m_10km.tif")
  temp100_mazs=crop(template_100,telpa2)
  rastrs_100_mazs=raster::raster(temp100_mazs)
  
  
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
  
  
  
  
  beigas=Sys.time()
  ilgums=beigas-sakums
  print(ilgums)
}
stopCluster(cl)

slani=list.files("./IevadesDati/ainava/ClassArea/Mezi_MezoSaus_r10000/",full.names = TRUE)
virt_slani=terra::vrt(slani)
names(virt_slani)="Mezi_MezoSaus_r10000"
writeRaster(virt_slani,"./Rastri_100m/RAW/Mezi_MezoSaus_r10000.tif",overwrite=TRUE)



# Mezi_NogabalaVecumaProp-vid_cell.tif ----
# VMD MVR reģistrētā valdošās sugas vecuma īpatsvars no galvenās cirtes vecuma, vidējais analīzes šūnā
# Ievades (tiešās) atkarības: 
## ./IevadesDati/MVR/nogabali_2024janv.parquet

nogabali=st_read_parquet("./IevadesDati/MVR/nogabali_2024janv.parquet")

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

NogVecProp_vid=resample(t_nogvec2,template100,method="max",
                        filename="./Rastri_100m/RAW/mezi_NogabalaVecumaProp_vid.tif",
                        overwrite=TRUE)
rm(r_nogvec)
rm(t_nogvec)
rm(t_nogvec2)
rm(NogVecProp_vid)







# Mezi_OligoSaus_r10000.tif ----
# Oligotrofu sausieņu un slapjaiņu mežu (MVR MAAT klase) platības īpatsvars r=10000 m ap analīzes šūnas centru
# Ievades (tiešās) atkarības: 
## ./Rastri_10m/Mezi_OligoSaus.tif


slanis=terra::rast("./Rastri_10m/Mezi_OligoSaus.tif")
slanis
cels="./Rastri_100m/RAW/Mezi_OligoSaus_cell.tif"
if(minmax(slanis,compute=FALSE)[2]>1){
  EGVcell_mean_recl(slanis,template100,cels)
} else {
  EGVcell_mean(slanis,template100,cels)}


cl <- makeCluster(8)
registerDoParallel(cl)
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
  r10000=st_read_parquet(celi$cels_r10000)
  r10000=r10000 %>% dplyr::select(ID1km)
  
  sunas1000=tikls100 %>% 
    filter(ID1km %in% r10000$ID1km) %>% 
    dplyr::select(id,yes,tks50km,rinda300,rinda500,ID1km)
  
  telpa=st_as_sfc(st_bbox(r10000))
  telpa2=st_buffer(telpa,dist=1000)
  
  
  template_100=rast("./Templates/TemplateRasters/LV100m_10km.tif")
  temp100_mazs=crop(template_100,telpa2)
  rastrs_100_mazs=raster::raster(temp100_mazs)
  
  
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
  
  
  
  
  beigas=Sys.time()
  ilgums=beigas-sakums
  print(ilgums)
}
stopCluster(cl)


slani=list.files("./IevadesDati/ainava/ClassArea/Mezi_OligoSaus_r10000/",full.names = TRUE)
virt_slani=terra::vrt(slani)
names(virt_slani)="Mezi_OligoSaus_r10000"
writeRaster(virt_slani,"./Rastri_100m/RAW/Mezi_OligoSaus_r10000.tif",overwrite=TRUE)



# Mezi_OligoSus_r10000.tif ----
# Oligotrofu susināto mežu (MVR MAAT klase) platības īpatsvars r=10000 m ap analīzes šūnas centru
# Ievades (tiešās) atkarības: 
## ./Rastri_10m/Mezi_OligoSus.tif

slanis=terra::rast("./Rastri_10m/Mezi_OligoSus.tif")
slanis
cels="./Rastri_100m/RAW/Mezi_OligoSus_cell.tif"
if(minmax(slanis,compute=FALSE)[2]>1){
  EGVcell_mean_recl(slanis,template100,cels)
} else {
  EGVcell_mean(slanis,template100,cels)}




cl <- makeCluster(8)
registerDoParallel(cl)
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
  r10000=st_read_parquet(celi$cels_r10000)
  r10000=r10000 %>% dplyr::select(ID1km)
  
  sunas1000=tikls100 %>% 
    filter(ID1km %in% r10000$ID1km) %>% 
    dplyr::select(id,yes,tks50km,rinda300,rinda500,ID1km)
  
  telpa=st_as_sfc(st_bbox(r10000))
  telpa2=st_buffer(telpa,dist=1000)
  
  
  template_100=rast("./Templates/TemplateRasters/LV100m_10km.tif")
  temp100_mazs=crop(template_100,telpa2)
  rastrs_100_mazs=raster::raster(temp100_mazs)
  
  
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
  
  
  
  
  beigas=Sys.time()
  ilgums=beigas-sakums
  print(ilgums)
}
stopCluster(cl)




slani=list.files("./IevadesDati/ainava/ClassArea/Mezi_OligoSus_r10000/",full.names = TRUE)
virt_slani=terra::vrt(slani)
names(virt_slani)="Mezi_OligoSus_r10000"
writeRaster(virt_slani,"./Rastri_100m/RAW/Mezi_OligoSus_r10000.tif",overwrite=TRUE)



# Mezi_PriezuKraja-sum_cell.tif ----
# VMD MVR reģistrētā pirmā stāva priežu krāja analīzes šūnā
# Ievades (tiešās) atkarības: 
## ./IevadesDati/MVR/nogabali_2024janv.parquet

nogabali=st_read_parquet("./IevadesDati/MVR/nogabali_2024janv.parquet")

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
rm(r_Kraja)
rm(t_Kraja)
rm(t_Kraja2)
rm(KrajasSumma)








# Mezi_Saurlapju_r10000.tif ----
# VMD MVR reģistrēto šaurlapju mežaudžu platības īpatsvars r=10000 m ap analīzes šūnas centru
# Ievades (tiešās) atkarības: 
## ./Rastri_10m/Mezi_Saurlapju.tif

slanis=terra::rast("./Rastri_10m/Mezi_Saurlapju.tif")
slanis
cels="./Rastri_100m/RAW/Mezi_Saurlapju_cell.tif"
if(minmax(slanis,compute=FALSE)[2]>1){
  EGVcell_mean_recl(slanis,template100,cels)
} else {
  EGVcell_mean(slanis,template100,cels)}



cl <- makeCluster(8)
registerDoParallel(cl)
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
  r10000=st_read_parquet(celi$cels_r10000)
  r10000=r10000 %>% dplyr::select(ID1km)
  
  sunas1000=tikls100 %>% 
    filter(ID1km %in% r10000$ID1km) %>% 
    dplyr::select(id,yes,tks50km,rinda300,rinda500,ID1km)
  
  telpa=st_as_sfc(st_bbox(r10000))
  telpa2=st_buffer(telpa,dist=1000)
  
  
  template_100=rast("./Templates/TemplateRasters/LV100m_10km.tif")
  temp100_mazs=crop(template_100,telpa2)
  rastrs_100_mazs=raster::raster(temp100_mazs)
  
  
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




slani=list.files("./IevadesDati/ainava/ClassArea/Mezi_Saurlapju_r10000/",full.names = TRUE)
virt_slani=terra::vrt(slani)
names(virt_slani)="Mezi_Saurlapju_r10000"
writeRaster(virt_slani,"./Rastri_100m/RAW/Mezi_Saurlapju_r10000.tif",overwrite=TRUE)



# Mezi_SaurlapjuCKraja-sum_cell.tif ----
# VMD MVR reģistrētā pirmā stāva šaurlapju (atsevišķi neaprakstīto) krāja analīzes šūnā
# Ievades (tiešās) atkarības: 
## ./IevadesDati/MVR/nogabali_2024janv.parquet

nogabali=st_read_parquet("./IevadesDati/MVR/nogabali_2024janv.parquet")


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
rm(r_Kraja)
rm(t_Kraja)
rm(t_Kraja2)
rm(KrajasSumma)







# Mezi_TaucLaiks-vid_cell.tif ----
# Laiks no pēdējā ar koku augšanu saistītā traucējuma līdz 2024.gadam, vidējais aritmētiskais analīzes šūnā
# Ievades (tiešās) atkarības: 
## ./IevadesDati/MVR/nogabali_2024janv.parquet
## ./Rastri_10m/Ainava_vienk_mask.tif
## ./IevadesDati/koki/TreeCoverLossYear.tif


nogabali=st_read_parquet("./IevadesDati/MVR/nogabali_2024janv.parquet")


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


# Beigu apstrāde ----


# Templates 
vieni=rast("./Templates/TemplateRasters/LV100m_10km.tif")
nulles=subst(vieni,1,0)

failu_celi=list.files("./Rastri_100m/RAW/",full.names = TRUE,pattern=".tif$")
nosaukumiem=list.files("./Rastri_100m/RAW/",full.names = FALSE,pattern=".tif$")

faili=data.frame(faili=failu_celi,
                 nosaukumi=nosaukumiem,
                 pietrukst=NA)


faili$pietrukst2=NA
for(i in seq_along(faili$faili)){
  print(i)
  sakums=Sys.time()
  fails=rast(faili$faili[i])
  fails=project(fails,nulles3)
  maskets=mask(fails,nulles3)
  iztrukumi=ifel(is.na(maskets)&!is.na(nulles3),1,NA)
  frekvences=freq(iztrukumi)
  vertiba=frekvences$count[frekvences$value==1]
  faili$pietrukst2[i]=vertiba
  beigas=Sys.time()
  laiks=beigas-sakums
  print(laiks)
}


write.xlsx(faili,"./Rastri_100m/RAW_names.xlsx")
# Nosaukumi projektētajiem un mērogotajiem slāņiem piešķirti analogi.
# Pēc nosaukumu harmonizēšanas, fails pārsaukts par "EGV_names.xlsx" 
# un izmantots tālāk

# Pārsaukšana


nosaukumiem=read_excel("./Rastri_100m/EGV_names.xlsx")
definicija=rast("./Rastri_100m/nulles_LV100m_10km.tif")

for(i in seq_along(nosaukumiem$nosaukumi)){
  print(i)
  sakums=Sys.time()
  fails=rast(nosaukumiem$faili[i])
  fails=project(fails,definicija)
  maskets=mask(fails,definicija)
  names(maskets)=substr(nosaukumiem$proj_NAME[i],1,nchar(nosaukumiem$proj_NAME[i])-4)
  writeRaster(maskets,
              filename=paste0("./Rastri_100m/Proj/",nosaukumiem$proj_NAME[i]),
              overwrite=TRUE)
  videjais=global(maskets,fun="mean",na.rm=TRUE)
  centrets=maskets-videjais[,1]
  standartnovirze=terra::global(centrets,fun="rms",na.rm=TRUE)
  merogots=centrets/standartnovirze[,1]
  nosaukumiem$var_videjais[i]=videjais
  nosaukumiem$var_standartnovirze[i]=standartnovirze
  writeRaster(merogots,
              filename=paste0("./Rastri_100m/Scaled/",nosaukumiem$scale_NAME[i]),
              overwrite=TRUE)
  beigas=Sys.time()
  ilgums=beigas-sakums
  print(ilgums)
}
write.xlsx(nosaukumiem,"./Rastri_100m/EGV_names_scaling.xlsx")

