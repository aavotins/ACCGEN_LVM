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




# Dynamic World ----

# klimats ----





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






# LAD ----




# MVR ----




# topo ----


