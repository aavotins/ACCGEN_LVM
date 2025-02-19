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







# Malas_AramzemesY_r10000.tif ----
# Šūnu (10m), kuras raksturo aramzemju malas ar jebko citu, skaits r=10000 m ap analīzes šūnas centru
# Ievades (tiešās) atkarības: 







# Malas_LIZzemieKoki-Koki_cell.tif ----
# Šūnu (10m), kuras raksturo LIZ_izcirtumu_krūmu malas ar kokiem (vismaz 5m), skaits analīzes šūnā
# Ievades (tiešās) atkarības: 








# Malas_LIZzemieKoki-Koki_r10000.tif ----
# Šūnu (10m), kuras raksturo LIZ_izcirtumu_krūmu malas ar kokiem (vismaz 5m), skaits r=10000 m ap analīzes šūnas centru
# Ievades (tiešās) atkarības: 








# Mezi_ApsuKraja-sum_cell.tif ----
# VMD MVR reģistrētā pirmā stāva apšu krāja analīzes šūnā
# Ievades (tiešās) atkarības: 








# Mezi_BerzuKraja-sum_cell.tif ----
# VMD MVR reģistrētā pirmā stāva bērzu krāja analīzes šūnā
# Ievades (tiešās) atkarības: 








# Mezi_EgluKraja-sum_cell.tif ----
# VMD MVR reģistrētā pirmā stāva egļu krāja analīzes šūnā
# Ievades (tiešās) atkarības: 








# Mezi_EitrSus_r10000.tif ----
# Eitrofu susināto mežu (MVR MAAT klase) platības īpatsvars r=10000 m ap analīzes šūnas centru
# Ievades (tiešās) atkarības: 








# Mezi_IzcUNzem5m_cell.tif ----
# Izcirtumu un MVR mežaudžu līdz 5 m platības īpatsvars analīzes šūnā
# Ievades (tiešās) atkarības: 








# Mezi_JauktukokuJaunas_r3000.tif ----
# VMD MVR reģistrēto jauktu koku jaunaudžu, vidēja vecuma un briestaudžu platības īpatsvars r=3000 m ap analīzes šūnas centru
# Ievades (tiešās) atkarības: 








# Mezi_LielakaisDiametrs-max_cell.tif ----
# VMD MVR reģistrētais lielākā koka diametrs analīzes šūnā
# Ievades (tiešās) atkarības: 








# Mezi_MelnalksnuKraja-sum_cell.tif ----
# VMD MVR reģistrētā pirmā stāva melnalkšņu krāja analīzes šūnā
# Ievades (tiešās) atkarības: 







# Mezi_MezoSaus_r10000.tif ----
# Mezotrofu sausieņu un slapjaiņu mežu (MVR MAAT klase) platības īpatsvars r=10000 m ap analīzes šūnas centru
# Ievades (tiešās) atkarības: 







# Mezi_NogabalaVecumaProp-vid_cell.tif ----
# VMD MVR reģistrētā valdošās sugas vecuma īpatsvars no galvenās cirtes vecuma, vidējais analīzes šūnā
# Ievades (tiešās) atkarības: 







# Mezi_OligoSaus_r10000.tif ----
# Oligotrofu sausieņu un slapjaiņu mežu (MVR MAAT klase) platības īpatsvars r=10000 m ap analīzes šūnas centru
# Ievades (tiešās) atkarības: 







# Mezi_OligoSus_r10000.tif ----
# Oligotrofu susināto mežu (MVR MAAT klase) platības īpatsvars r=10000 m ap analīzes šūnas centru
# Ievades (tiešās) atkarības: 








# Mezi_PriezuKraja-sum_cell.tif ----
# VMD MVR reģistrētā pirmā stāva priežu krāja analīzes šūnā
# Ievades (tiešās) atkarības: 








# Mezi_Saurlapju_r10000.tif ----
# VMD MVR reģistrēto šaurlapju mežaudžu platības īpatsvars r=10000 m ap analīzes šūnas centru
# Ievades (tiešās) atkarības: 








# Mezi_SaurlapjuCKraja-sum_cell.tif ----
# VMD MVR reģistrētā pirmā stāva šaurlapju (atsevišķi neaprakstīto) krāja analīzes šūnā
# Ievades (tiešās) atkarības: 







# Mezi_TaucLaiks-vid_cell.tif ----
# Laiks no pēdējā ar koku augšanu saistītā traucējuma līdz 2024.gadam, vidējais aritmētiskais analīzes šūnā
# Ievades (tiešās) atkarības: 





