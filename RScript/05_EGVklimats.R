# komandu rindas vistu vanaga izplatības modeļa parametrizācijā 
# izmantoto ekoģeogrāfisko mainīgo sagatavošanai

# šis skripts izveido sekojošiem EGV nepieciešamos slāņus:
# `Climate_FebPrec_cell.tif` - Februāra (gada aukstākā mēneša) nokrišņu summu mediāna 2015-2023
# `Climate_JulPrec_cell.tif` - Jūlija (gada siltākā mēneša) nokrišņu summu mediāna 2015-2023
# `Climate_VegTempSums_cell.tif` - Dienas vidējo temperatūru 2 m augstumā vismaz 279 grādi K summu mediāna 2015-2023
# `Climate_YearPrecSum_cell.tif` - Uzkrāto ik mēneša nokrišņu summu mediāna 2015-2023




# pakotnes -----

library(terra)
library(tidyverse)
library(sf)
library(arrow)
library(sfarrow)
library(mgcv)


# templates ----

paraugs=rast("./Templates/TemplateRasters/LV10m_10km.tif")
template100=rast("./Templates/TemplateRasters/LV100m_10km.tif")
rastrs100=raster::raster(template100)

# 100 m rezgis ----
rezgis=st_read_parquet("./Templates/TemplateGrids/tikls100_sauzeme.parquet")

# darbs ----


FebPrec=rast("./IevadesDati/klimats/mozaikas/FebPrec.tif")
YearPrecSum=rast("./IevadesDati/klimats/mozaikas/YearPrecSum.tif")
JulPrec=rast("./IevadesDati/klimats/mozaikas/JulPrec.tif")
VegTempSums=rast("./IevadesDati/klimats/mozaikas/VegTempSums.tif")

soli=levels(factor(rezgis$tks50km))
dati=rezgis %>% filter(tks50km == soli[1])
dati$FebPrec=exactextractr::exact_extract(FebPrec,dati,"mean")
dati$YearPrecSum=exactextractr::exact_extract(YearPrecSum,dati,"mean")
dati$JulPrec=exactextractr::exact_extract(JulPrec,dati,"mean")
dati$VegTempSums=exactextractr::exact_extract(VegTempSums,dati,"mean")

for(i in 2:length(soli)){
  sakums=Sys.time()
  print(i)
  solis=soli[i]
  rezgitis=rezgis %>% filter(tks50km==solis)
  
  rezgitis$FebPrec=exactextractr::exact_extract(FebPrec,rezgitis,"mean")
  rezgitis$YearPrecSum=exactextractr::exact_extract(YearPrecSum,rezgitis,"mean")
  rezgitis$JulPrec=exactextractr::exact_extract(JulPrec,rezgitis,"mean")
  rezgitis$VegTempSums=exactextractr::exact_extract(VegTempSums,rezgitis,"mean")
  
  dati=bind_rows(dati,rezgitis)
  
}

st_write_parquet(dati,"./IevadesDati/klimats/dati.parquet")

# centri ----

dati=st_read_parquet("./IevadesDati/klimats/dati.parquet")

centri=st_centroid(dati)
koords=st_coordinates(centri)
dati$X=koords[,1]
dati$Y=koords[,2]

# modeli malu autokorelatīvai aizpildīšanai ----


mod_FebPrec=gam(FebPrec~s(X,Y),data=dati)
dati$fit_FebPrec=predict(mod_FebPrec,dati)
dati$new_FebPrec=ifelse(is.na(dati$FebPrec),dati$fit_FebPrec,dati$FebPrec)

mod_YearPrecSum=gam(YearPrecSum~s(X,Y),data=dati)
dati$fit_YearPrecSum=predict(mod_YearPrecSum,dati)
dati$new_YearPrecSum=ifelse(is.na(dati$YearPrecSum),dati$fit_YearPrecSum,dati$YearPrecSum)

mod_JulPrec=gam(JulPrec~s(X,Y),data=dati)
dati$fit_JulPrec=predict(mod_JulPrec,dati)
dati$new_JulPrec=ifelse(is.na(dati$JulPrec),dati$fit_JulPrec,dati$JulPrec)

mod_VegTempSums=gam(VegTempSums~s(X,Y),data=dati)
dati$fit_VegTempSums=predict(mod_VegTempSums,dati)
dati$new_VegTempSums=ifelse(is.na(dati$VegTempSums),dati$fit_VegTempSums,dati$VegTempSums)



# EGV ----

FebPrec=fasterize::fasterize(dati,rastrs100,field="new_FebPrec")
FebPrec=rast(FebPrec)
FebPrec2=terra::mask(FebPrec,template100,overwrite=TRUE,filename=paste0("./Rastri_100m/RAW/climate_FebPrec.tif"))

YearPrecSum=fasterize::fasterize(dati,rastrs100,field="new_YearPrecSum")
YearPrecSum=rast(YearPrecSum)
YearPrecSum2=terra::mask(YearPrecSum,template100,overwrite=TRUE,filename="./Rastri_100m/RAW/climate_YearPrecSum.tif")

JulPrec=fasterize::fasterize(dati,rastrs100,field="new_JulPrec")
JulPrec=rast(JulPrec)
JulPrec2=terra::mask(JulPrec,template100,overwrite=TRUE,filename="./Rastri_100m/RAW/climate_JulPrec.tif")

VegTempSums=fasterize::fasterize(dati,rastrs100,field="new_VegTempSums")
VegTempSums=rast(VegTempSums)
VegTempSums2=terra::mask(VegTempSums,template100,overwrite=TRUE,filename="./Rastri_100m/RAW/climate_VegTempSums.tif")
