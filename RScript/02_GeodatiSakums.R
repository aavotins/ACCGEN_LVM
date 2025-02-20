# priekšapstrāde daļai Ievades Datu failiem


# Corine Land Cover ----

# pakotnes
library(sf)
library(arrow)
library(sfarrow)

# lejupielādētie dati - lejupielāde jāveic patstāvīgi
clcLV=st_read("./IevadesDati/CLC/clcLV.gpkg",layer="clcLV")

# tukšās ģeometrijas
clcLV2 = clcLV[!st_is_empty(clcLV),,drop=FALSE] # OK

# ģeometriju validēšana
validity=st_is_valid(clcLV2) 
table(validity) # 3 non-valid
clcLV3=st_make_valid(clcLV2)

# koordinātu sistēma
clcLV3=st_transform(clcLV3,crs=3059)

# saglabāšana
sfarrow::st_write_parquet(clcLV3, "./IevadesDati/CLC/CLC_LV_2018.parquet")


rm(list=ls())

# Dynamic World ----
library(tidyverse)
library(terra)


# reference
paraugs=rast("./Templates/TemplateRasters/LV10m_10km.tif")

# saraksts ar lejupielādētajiem failiem, pieņemot, ka tie atrodas direktorijā 
# "DWE_float"
faili=data.frame(faili=list.files("./IevadesDati/DynamicWorld/DynamicWorld_Eksperimentam/DWE_float/"))
faili$celi_sakums=paste0("./IevadesDati/DynamicWorld/DynamicWorld_Eksperimentam/DWE_float/",faili$faili)

# Korekti projektētu mozaīku sagatavošana
# failu nosaukumi un ceļš saglabāšanai
faili=faili %>% 
  separate(faili,into=c("DW","gads","periods","parejais"),sep="_",remove = FALSE) %>% 
  mutate(unikalais=paste0(DW,"_",gads,"_",periods),
         mosaic_name=paste0(unikalais,".tif"),
         masaic_cels=paste0("./IevadesDati/DynamicWorld/DynamicWorld_Eksperimentam/DWE_mosaic/",mosaic_name))

# unikālie failu nosaukumi cikla vadībai
unikalie=levels(factor(faili$unikalais))

# cikls uzdevuma veikšanai
for(i in seq_along(unikalie)){
  unikalais=faili %>% filter(unikalais==unikalie[i])
  beigu_cels=unique(unikalais$masaic_cels)
  
  # ik slānis sastāv no divām lapām
  viens=rast(unikalais$celi_sakums[1])
  divi=rast(unikalais$celi_sakums[2])
  
  viens2=project(viens,paraugs)
  divi2=project(divi,paraugs)
  
  mozaika=mosaic(viens2,divi2,fun="first")
  maskets=mask(mozaika,paraugs,filename=beigu_cels,overwrite=TRUE)
}

# pēc izpētes (https://aavotins.github.io/PutnuSDMs_gramata/Chapter4.html) turpmākam 
# darbam izmantojamo pārvietošana


dw17=rast("./IevadesDati/DynamicWorld/DynamicWorld_Eksperimentam/DWE_mosaic/DW_2017_apraug.tif")
writeRaster(dw17,"./VidesParmainas/Parmainam/DW_2017_apraug.tif")
dw18=rast("./IevadesDati/DynamicWorld/DynamicWorld_Eksperimentam/DWE_mosaic/DW_2018_apraug.tif")
writeRaster(dw18,"./VidesParmainas/Parmainam/DW_2018_apraug.tif")
dw19=rast("./IevadesDati/DynamicWorld/DynamicWorld_Eksperimentam/DWE_mosaic/DW_2019_apraug.tif")
writeRaster(dw19,"./VidesParmainas/Parmainam/DW_2019_apraug.tif")
dw20=rast("./IevadesDati/DynamicWorld/DynamicWorld_Eksperimentam/DWE_mosaic/DW_2020_apraug.tif")
writeRaster(dw20,"./VidesParmainas/Parmainam/DW_2020_apraug.tif")
dw21=rast("./IevadesDati/DynamicWorld/DynamicWorld_Eksperimentam/DWE_mosaic/DW_2021_apraug.tif")
writeRaster(dw21,"./VidesParmainas/Parmainam/DW_2021_apraug.tif")
dw22=rast("./IevadesDati/DynamicWorld/DynamicWorld_Eksperimentam/DWE_mosaic/DW_2022_apraug.tif")
writeRaster(dw22,"./VidesParmainas/Parmainam/DW_2022_apraug.tif")
dw23=rast("./IevadesDati/DynamicWorld/DynamicWorld_Eksperimentam/DWE_mosaic/DW_2023_apraug.tif")
writeRaster(dw23,"./VidesParmainas/Parmainam/DW_2023_apraug.tif")


rm(list=ls())



# klimats ----

# pakotnes

library(terra)
library(sf)
library(tidyverse)
library(arrow)
library(sfarrow)
library(exactextractr)

# reference
template=rast("./Templates/TemplateRasters/LV10m_10km.tif")

# DW export no GEE 
faili=data.frame(fails=list.files("./IevadesDati/klimats/RAW/"))
faili$celi_sakums=paste0("./IevadesDati/klimats/RAW/",faili$fails)

# Sagatavošana
faili=faili %>% 
  separate(fails,into=c("nosaukums","vidus","beigas"),sep="-",remove = FALSE) %>% 
  mutate(mosaic_name=paste0(nosaukums,".tif"),
         masaic_cels=paste0("./IevadesDati/klimats/mozaikas/",mosaic_name))

unikalie=levels(factor(faili$nosaukums))
for(i in seq_along(unikalie)){
  unikalais=faili %>% filter(nosaukums==unikalie[i])
  beigu_cels=unique(unikalais$masaic_cels)
  # katrs slānis sastāv no četrām lapām
  viens=rast(unikalais$celi_sakums[1])
  divi=rast(unikalais$celi_sakums[2])
  tris=rast(unikalais$celi_sakums[3])
  cetri=rast(unikalais$celi_sakums[4])
  
  viens2=terra::project(viens,paraugs)
  divi2=terra::project(divi,paraugs)
  tris2=terra::project(tris,paraugs)
  cetri2=terra::project(cetri,paraugs)
  
  mozaika=terra::merge(viens2,divi2,tris2,cetri2)
  maskets=mask(mozaika,paraugs,filename=beigu_cels,overwrite=TRUE)
}

rm(list=ls())

# koki ----

## The Global Forest Watch ----

library(tidyverse)
library(terra)

# reference
paraugs=rast("./Templates/TemplateRasters/LV10m_10km.tif")

# TreeCoverLoss - pēc lejupielādes
treecoverloss=rast("./IevadesDati/koki/RAW/TreeCoverLoss.tif")

# Fona aivietošana ar iztrūkstošajām vērtībām
tcl=ifel(treecoverloss<1,NA,treecoverloss)

# projektēšana un maskēšana ar faila saglabāšanu
tcl2=terra::project(tcl,paraugs)
tcl3=mask(tcl2,paraugs,filename="./IevadesDati/koki/TreeCoverLossYear.tif",overwrite=TRUE)
writeRaster(tcl3,filename="./Rastri_10m/TreeCoverLossYear.tif",overwrite=TRUE)


rm(list=ls())


## Palsar ----

library(tidyverse)
library(terra)

# reference
paraugs=rast("./Templates/TemplateRasters/LV10m_10km.tif")

# Palsar Trees
fnf1=rast("./IevadesDati/koki/RAW/ForestNonForest-0000023296-0000023296.tif")
fnf2=rast("./IevadesDati/koki/RAW/ForestNonForest-0000023296-0000000000.tif")
fnf3=rast("./IevadesDati/koki/RAW/ForestNonForest-0000000000-0000023296.tif")
fnf4=rast("./IevadesDati/koki/RAW/ForestNonForest-0000000000-0000000000.tif")

# projektēšana
fnf1p=terra::project(fnf1,paraugs)
fnf2p=terra::project(fnf2,paraugs)
fnf3p=terra::project(fnf3,paraugs)
fnf4p=terra::project(fnf4,paraugs)

# Apvienošana
fnfA=terra::merge(fnf1p,fnf2p)
fnfB=terra::merge(fnfA,fnf3p)
fnfC=terra::merge(fnfB,fnf4p)

# Reklasificēšana
fnf_X=ifel(fnfC<=2&fnfC>=1,1,NA)

# Maskēšana un saglabāšana
fnf_XX=mask(fnf_X,paraugs,filename="./IevadesDati/koki/Palsar_Forests.tif",overwrite=TRUE)




rm(list=ls())


# LAD ----

# pakotnes
library(sf)
library(arrow)
library(sfarrow)
library(gdalUtilities)
library(httr)
library(tidyverse)
library(ows4R)


# lejupielāde
wfs_bwk <- "https://karte.lad.gov.lv/arcgis/services/lauki/MapServer/WFSServer"
url <- parse_url(wfs_bwk)
url$query <- list(service = "wfs",
                  #version = "2.0.0", # fakultatīvi
                  request = "GetCapabilities"
)
vaicajums <- build_url(url)

bwk_client <- WFSClient$new(wfs_bwk, 
                            serviceVersion = "2.0.0")
bwk_client$getFeatureTypes() %>%
  map_chr(function(x){x$getTitle()})

dati <- read_sf(vaicajums)

# multipoligoni
ensure_multipolygons <- function(X) {
  tmp1 <- tempfile(fileext = ".gpkg")
  tmp2 <- tempfile(fileext = ".gpkg")
  st_write(X, tmp1)
  ogr2ogr(tmp1, tmp2, f = "GPKG", nlt = "MULTIPOLYGON")
  Y <- st_read(tmp2)
  st_sf(st_drop_geometry(X), geom = st_geometry(Y))
}
dati2 <- ensure_multipolygons(dati)

# pārbaudes
dati3 = dati2[!st_is_empty(dati2),,drop=FALSE] # OK
validity=st_is_valid(dati3) 
table(validity) # OK

# saglabāšana
sfarrow::st_write_parquet(dati3, "./IevadesDati/LAD/LAD_lauki.parquet")


rm(list=ls())

# MVR ----

# pakotnes
library(sf)
library(arrow)
library(sfarrow)
library(gdalUtilities)

# datubāze
nog=read_sf("./IevadesDati/MVR/VMD.gdb/",layer="Nogabali_pilna_datubaze")

# ģeometriju nodrošināšana
ensure_multipolygons <- function(X) {
  tmp1 <- tempfile(fileext = ".gpkg")
  tmp2 <- tempfile(fileext = ".gpkg")
  st_write(X, tmp1)
  ogr2ogr(tmp1, tmp2, f = "GPKG", nlt = "MULTIPOLYGON")
  Y <- st_read(tmp2)
  st_sf(st_drop_geometry(X), geom = st_geometry(Y))
}
nogabali <- ensure_multipolygons(nog)

# ģeometriju pārbaudes 
nogabali2 = nogabali[!st_is_empty(nogabali),,drop=FALSE] # 108 tukšas ģeometrijas
validity=st_is_valid(nogabali2) 
table(validity) # 1733 invalid ģeometrijas
nogabali3=st_make_valid(nogabali2)
table(st_is_valid(nogabali3)) # OK

# saglabāšana
sfarrow::st_write_parquet(nogabali3, "./IevadesDati/MVR/nogabali.parquet")

rm(list=ls())

# topo ----

# pakotnes
library(sf)
library(arrow)
library(sfarrow)


# flora_L 
flora_L=st_read("./IevadesDati/topo/Topo10_v3_12_07_2016.gdb/",layer="flora_L")
flora2 = flora_L[!st_is_empty(flora_L),,drop=FALSE] # OK
validity=st_is_valid(flora2) 
table(validity) # 12 invalid geometrijas
sfarrow::st_write_parquet(flora2, "./IevadesDati/topo/Topo_floraL.parquet")


# hidro A
hidro_A=st_read("./IevadesDati/topo/Topo10_v3_12_07_2016.gdb/",layer="hidro_A")
hidro2 = hidro_A[!st_is_empty(hidro_A),,drop=FALSE] # OK
validity=st_is_valid(hidro2) 
table(validity) # 12 invalid geometrijas
hidro3=st_make_valid(hidro2)
sfarrow::st_write_parquet(hidro3, "./IevadesDati/topo/Topo_hidroA.parquet")

# hidro L
hidro_L=st_read("./IevadesDati/topo/Topo10_v3_12_07_2016.gdb/",layer="hidro_L")
table(hidro_L$FNAME,useNA="always")
hidro_Lx=hidro_L %>% 
  filter(FNAME=="Ūdenstece līdz 3m") # grāvji
hidro_Lx2 = hidro_Lx[!st_is_empty(hidro_Lx),,drop=FALSE] # OK
validity=st_is_valid(hidro_Lx) 
table(validity) # OK
sfarrow::st_write_parquet(hidro_Lx, "./IevadesDati/topo/Topo_hidroL.parquet")

# road A
road_A=st_read("./IevadesDati/topo/Topo10_v3_12_07_2016.gdb/",layer="road_A")
road2 = road_A[!st_is_empty(road_A),,drop=FALSE] # OK
validity=st_is_valid(road2) 
table(validity) # 28 invalid geometrijas
road3=st_make_valid(road2)
sfarrow::st_write_parquet(road3, "./IevadesDati/topo/Topo_roadA.parquet")

# road L
road_L=st_read("./IevadesDati/topo/Topo10_v3_12_07_2016.gdb/",layer="road_L")
table(road_L$FNAME,useNA="always")
road_Lx=road_L %>% 
  filter(FNAME!="Gājēju celiņš līdz 3m") %>% # ne pavisam sīkie
  filter(FNAME!="Gājēju celiņš mērogā") %>% 
  filter(FNAME!="Taka")
roadL2 = road_Lx[!st_is_empty(road_Lx),,drop=FALSE] # OK
validity=st_is_valid(roadL2) 
table(validity) # OK
sfarrow::st_write_parquet(roadL2, "./IevadesDati/topo/Topo_roadL.parquet")

# swamp A
swamp_A=st_read("./IevadesDati/topo/Topo10_v3_12_07_2016.gdb/",layer="swamp_A")
swamp2 = swamp_A[!st_is_empty(swamp_A),,drop=FALSE] # OK
validity=st_is_valid(swamp2) 
table(validity) # 17 invalid geometrijas
swamp3=st_make_valid(swamp2)
sfarrow::st_write_parquet(swamp3, "./IevadesDati/topo/Topo_swampA.parquet")

# bridge_L
bridge_L=st_read("./IevadesDati/topo/Topo10_v3_12_07_2016.gdb/",layer="bridge_L")
bridgeL2 = bridge_L[!st_is_empty(bridge_L),,drop=FALSE] # OK
validity=st_is_valid(bridgeL2) 
table(validity) # OK
sfarrow::st_write_parquet(bridgeL2, "./IevadesDati/topo/Topo_bridgeL.parquet")

# bridge_P
bridge_P=st_read("./IevadesDati/topo/Topo10_v3_12_07_2016.gdb/",layer="bridge_P")
bridgeP2 = bridge_P[!st_is_empty(bridge_P),,drop=FALSE] # OK
validity=st_is_valid(bridgeP2) 
table(validity) # OK
sfarrow::st_write_parquet(bridgeP2, "./IevadesDati/topo/Topo_bridgeP.parquet")

# landus A
landus_A=st_read("./IevadesDati/topo/Topo10_v3_12_07_2016.gdb/",layer="landus_A")
landus2 = landus_A[!st_is_empty(landus_A),,drop=FALSE] # OK
validity=st_is_valid(landus2) 
table(validity) # 5734 invalid geometrijas
landus3=st_make_valid(landus2)
sfarrow::st_write_parquet(landus3, "./IevadesDati/topo/Topo_landusA.parquet")


rm(list=ls())
