# komandu rindas vistu vanaga izplatības modeļa parametrizācijā 
# izmantoto ekoģeogrāfisko mainīgo sagatavošanai

# šis skripts izveido sekojošiem EGV nepieciešamos slāņus:
# `Malas_Apbuve-Koki_r3000.tif` - Šūnu (10m), kuras raksturo robežu starp apbūvi un kokiem, skaits r=3000 m ap analīzes šūnas centru
# `Malas_AramzemesY_cell.tif` - Šūnu (10m), kuras raksturo aramzemju malas ar jebko citu, skaits analīzes šūnā
# `Malas_AramzemesY_r10000.tif` - Šūnu (10m), kuras raksturo aramzemju malas ar jebko citu, skaits r=10000 m ap analīzes šūnas centru
# `Malas_LIZzemieKoki-Koki_cell.tif` - Šūnu (10m), kuras raksturo LIZ_izcirtumu_krūmu malas ar kokiem (vismaz 5m), skaits analīzes šūnā
# `Malas_LIZzemieKoki-Koki_r10000.tif` - Šūnu (10m), kuras raksturo LIZ_izcirtumu_krūmu malas ar kokiem (vismaz 5m), skaits r=10000 m ap analīzes šūnas centru


# Pa priekšu sagatavoju nepieciešamos analīzes šūnas līmeņa mainīgos, tad veidoju 
# to apjoma rādītājus ainavas telpās. Lai veidotu aprakstus ainavas līmenī,
# tiem ir nepieciešami atbilstoši apraksti šūnas līmenī


# šūnas līmenis ----

## direktorijas ----
dir.create("./IevadesDati/ainava/Malas/Malas_Apbuve_Koki_cell", recursive=TRUE)
dir.create("./IevadesDati/ainava/Malas/Malas_AramzemesY_cell", recursive=TRUE)
dir.create("./IevadesDati/ainava/Malas/Malas_LIZzemieKoki_Koki_cell", recursive=TRUE)

## pakotnes -----
library(terra)
library(sf)
library(tidyverse)
library(sfarrow)
library(landscapemetrics)

## darbs -----


kvadratiem=data.frame(fails_c=list.files("./Templates/TemplateGrids/lapas/"))
kvadratiem$cels_c=paste0("./Templates/TemplateGrids/lapas/",kvadratiem$fails_c)
kvadratiem$numurs=substr(kvadratiem$fails_c,10,13)



numuri=levels(factor(kvadratiem$numurs))



library(foreach)
library(doParallel)
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
  
  
  # Malas_Apbuve-Koki
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
  
  # Malas_AramzemesY
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
  
  # Malas_LIZzemieKoki-Koki
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




# Malas_Apbuve-Koki
slani=list.files("./IevadesDati/ainava/Malas/Malas_Apbuve_Koki_cell/",full.names = TRUE)
virt_slani=terra::vrt(slani)
names(virt_slani)="Malas_Apbuve_Koki_cell"
writeRaster(virt_slani,"./Rastri_100m/RAW/Malas_Apbuve_Koki_cell.tif",overwrite=TRUE)

# Malas_AramzemesY
slani=list.files("./IevadesDati/ainava/Malas/Malas_AramzemesY_cell/",full.names = TRUE)
virt_slani=terra::vrt(slani)
names(virt_slani)="Malas_AramzemesY_cell"
writeRaster(virt_slani,"./Rastri_100m/RAW/Malas_AramzemesY_cell.tif",overwrite=TRUE)

# Malas_LIZzemieKoki-Koki
slani=list.files("./IevadesDati/ainava/Malas/Malas_LIZzemieKoki_Koki_cell/",full.names = TRUE)
virt_slani=terra::vrt(slani)
names(virt_slani)="Malas_LIZzemieKoki_Koki_cell"
writeRaster(virt_slani,"./Rastri_100m/RAW/Malas_LIZzemieKoki_Koki_cell.tif",overwrite=TRUE)



# ainavas telpas ----

## direktorijas ----

# `Malas_Apbuve-Koki_r3000.tif`
dir.create("./IevadesDati/ainava/Malas/Malas_Apbuve_Koki_r3000", recursive=TRUE)

# `Malas_AramzemesY_r10000.tif`
dir.create("./IevadesDati/ainava/Malas/Malas_AramzemesY_r10000", recursive=TRUE)

# `Malas_LIZzemieKoki-Koki_r10000.tif`
dir.create("./IevadesDati/ainava/Malas/Malas_LIZzemieKoki_Koki_r10000")



## pakotnes -----
library(terra)
library(sf)
library(tidyverse)
library(exactextractr)
library(arrow)
library(sfarrow)



## darbs ----


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
  filter(sakums=="pts300") %>% 
  mutate(fails_r3000=fails_r,
         cels_r3000=cels_radiuss) %>% 
  dplyr::select(-sakums,-beigas,-fails_r,-cels_radiuss,-veids)

kvadratiem_r10000=kvadratiem_radiusi %>% 
  filter(veids=="r10000") %>% 
  filter(sakums=="pts1km") %>% 
  mutate(fails_r10000=fails_r,
         cels_r10000=cels_radiuss) %>% 
  dplyr::select(-sakums,-beigas,-fails_r,-cels_radiuss,-veids)

kvadrati=kvadratiem %>% 
  left_join(kvadratiem_r500,by=c("numurs"="lapa")) %>% 
  left_join(kvadratiem_r1250,by=c("numurs"="lapa")) %>% 
  left_join(kvadratiem_r3000,by=c("numurs"="lapa")) %>% 
  left_join(kvadratiem_r10000,by=c("numurs"="lapa"))


numuri=levels(factor(kvadrati$numurs))


tikls100=st_read_parquet("./Templates/TemplateGrids/tikls100_sauzeme.parquet")


library(foreach)
library(doParallel)
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
  
  # apbūve un koki
  slanis=rast("./Rastri_100m/RAW/Malas_Apbuve_Koki_cell.tif")
  slanis_mazs=crop(slanis,telpa2)
  r3000$vertibas=exact_extract(slanis_mazs,r3000,"sum")
  x3000=data.frame(r3000) %>% dplyr::select(rinda300,vertibas)
  sunas300=sunas300 %>% 
    dplyr::select(id,yes,tks50km,rinda300,rinda500,ID1km) %>% 
    left_join(x3000,by="rinda300")
  rezA=fasterize::fasterize(sunas300,rastrs_100_mazs,field="vertibas")
  rezA=rast(rezA)
  rezB=terra::mask(rezA,temp100_mazs,overwrite=TRUE,
                   filename=paste0("./IevadesDati/ainava/Malas/Malas_Apbuve_Koki_r3000/Malas_Apbuve_Koki_r3000","_",solis,".tif"))
  
  # LIZ_zemieKoki un Koki
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
  
  # aramzemju malas
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




## apvienošana ----

# `Malas_Apbuve-Koki_r3000.tif`
slani=list.files("./IevadesDati/ainava/Malas/Malas_Apbuve_Koki_r3000/",full.names = TRUE)
virt_slani=terra::vrt(slani)
names(virt_slani)="Malas_Apbuve_Koki_r3000"
writeRaster(virt_slani,"./Rastri_100m/RAW/Malas_Apbuve_Koki_r3000.tif",overwrite=TRUE)

# `Malas_AramzemesY_r10000.tif`
slani=list.files("./IevadesDati/ainava/Malas/Malas_AramzemesY_r10000/",full.names = TRUE)
virt_slani=terra::vrt(slani)
names(virt_slani)="Malas_AramzemesY_r10000"
writeRaster(virt_slani,"./Rastri_100m/RAW/Malas_AramzemesY_r10000.tif",overwrite=TRUE)

# `Malas_LIZzemieKoki-Koki_r10000.tif`
slani=list.files("./IevadesDati/ainava/Malas/Malas_LIZzemieKoki_Koki_r10000/",full.names = TRUE)
virt_slani=terra::vrt(slani)
names(virt_slani)="Malas_LIZzemieKoki_Koki_r10000"
writeRaster(virt_slani,"./Rastri_100m/RAW/Malas_LIZzemieKoki_Koki_r10000.tif",overwrite=TRUE)

