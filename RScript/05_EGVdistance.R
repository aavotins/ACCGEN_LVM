# komandu rindas vistu vanaga izplatības modeļa parametrizācijā 
# izmantoto ekoģeogrāfisko mainīgo sagatavošanai

# šis skripts izveido sekojošiem EGV nepieciešamos slāņus:
# `Dist_AtkritumuPoligoni-vid_cell.tif` - Attālums līdz atkritumu poligoniem, vidējais analīzes šūnā
# `Dist_Jura-vid_cell.tif` - Attālums līdz jūrai, vidējais analīzes šūnā



# pakotnes -----
library(terra)
library(tidyverse)
library(raster)
library(fasterize)
library(arrow)
library(sf)
library(sfarrow)
library(exactextractr)
library(whitebox)
library(readxl)



# templates ----
paraugs_10=rast("./Templates/TemplateRasters/LV10m_10km.tif")
paraugs_100m=rast("./Templates/TemplateRasters/LV100m_10km.tif")
rastrs_100m=raster::raster(paraugs_100m)
rastrs_10m=raster::raster(paraugs_10)


# atkritumu poligoni ----

atkritumi1=read_excel("./IevadesDati/atkritumi/Waste.xlsx",sheet="Poligoni")
poligoni_sf=st_as_sf(atkritumi1,coords=c("X","Y"),crs=3059)
pol_rast=rasterize(poligoni_sf,paraugs_100m)
plot(pol_rast)
nullem100=subst(paraugs_100m,1,0)
pol_rast2=cover(pol_rast,nullem100)
writeRaster(pol_rast2,"./Rastri_10m/AtkritumuPoligoni_100.tif",overwrite=TRUE)

q=wbt_euclidean_distance(
  input="./Rastri_10m/AtkritumuPoligoni_100.tif",
  output="./Rastri_100m/RAW/dist_AtkritumuPoligoni_vid.tif"
)


# jūra ----

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


