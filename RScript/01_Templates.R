# Sagatavo harmonizācijas slāņus
# Apraksts: ./Templates/Readme_Templates.md 
# Pirms komandu rindu izpildes, nepieciešams sagatavot ievades failus.

# Pakotnes
if(!require(sf)) {install.packages("sf"); require(sf)}
if(!require(tidyverse)) {install.packages("tidyverse"); require(tidyverse)}
if(!require(arrow)) {install.packages("arrow"); require(arrow)}
if(!require(sfarrow)) {install.packages("sfarrow"); require(sfarrow)}
if(!require(terra)) {install.packages("terra"); require(terra)}

# nepieciešamās direktorijas

dir.create("./Templates/TemplateGridPoints")
dir.create("./Templates/TemplateGridPoints/lapas")
dir.create("./Templates/TemplateGrids/lapas")
dir.create("./Templates/TemplateRasters")


# Vektordatu režģi ----

# Administratīvās teritorijas
adm_ter=read_sf("./Templates/administrativas_teritorijas_2021/Administrativas_teritorijas_2021.shp")

# režģis 100 m
tikls100=read_sf("./Templates/grid_lv_100/grid_lv_100.gpkg",layer="grid_lv_100")
tikls100$yes=1
tikls100=st_transform(tikls100,crs=3059)
tikls100_sauszeme=tikls100[adm_ter,,]
st_write_parquet(tikls100_sauszeme,"./Templates/TemplateGrids/tikls100_sauzeme.parquet")


# 100 m režģa apvienošana
tikls100_apvienots=tikls100_sauszeme %>% 
  group_by(yes) %>% 
  summarise()
st_write(tikls100_apvienots,"./Templates/TemplateGrids/tikls100_apvienots.shp")

# 100 m režģa centri
centri100=st_centroid(tikls100_sauszeme)
st_write_parquet(centri100,"./Templates/TemplateGridPoints/pts100_sauzeme.parquet")

# 100 m režģa centri tks93_50km
tks50km=st_read_parquet("./Templates/TemplateGrids/tks93_50km.parquet") 
savienots=st_join(centri100,tks50km)
savienots=savienots %>% 
  mutate(tks50km=NUMURS) %>% 
  dplyr::select(id,yes,tks50km)
st_write_parquet(savienots,"./Templates/TemplateGridPoints/pts100_sauzeme.parquet")


# 1000 m

tikls1000=read_sf("./grid_lv_1k/Grid_LV_1k.shp")
tikls1000$yes=1
tikls1000_sauszeme=tikls1000[adm_ter,,]
sfarrow::st_write_parquet(tikls1000_sauszeme,"./Templates/TemplateGrids/tikls1k_sauzeme.parquet")

# 1000 m identifikatoru pievienošana 100 m režģim
tikls1000_sauszeme$ID1km=tikls1000_sauszeme$ID
punkti=st_read_parquet("./Templates/TemplateGridPoints/pts100_sauzeme.parquet")
savienots=st_join(punkti,tikls1000_sauszeme[,"ID1km"])
st_write_parquet(savienots,"./Templates/TemplateGridPoints/pts100_sauzeme.parquet")

pievienosanai=data.frame(savienots) %>% 
  dplyr::select(id,ID1km)
tikls100=tikls100 %>% 
  left_join(pievienosanai,by="id")
st_write_parquet(tikls100,"./Templates/TemplateGrids/tikls100_sauzeme.parquet")

# 1000 m saistīšana ar tks93_50km
tks50km=st_read_parquet("./Templates/TemplateGrids/tks93_50km.parquet")
centri1000=st_centroid(tikls1000_sauszeme)
centri1000=st_join(centri1000,tks50km)
centri1000=centri1000 %>% 
  mutate(tks50km=NUMURS) %>% 
  dplyr::select(ID1km,tks50km)
st_write_parquet(centri1000,"./Templates/TemplateGridPoints/pts1000_sauzeme.parquet")


# 300 m režģis
# izveidošana
tikls300=st_make_grid(tikls100,cellsize=c(300,300))
tikls300_LV=tikls300[tikls100,,]
tikls300_LV=st_as_sf(tikls300_LV)
tikls300_LV$rinda300=rownames(tikls300_LV)
st_write_parquet(tikls300_LV,"./Templates/TemplateGrids/tikls300_sauzeme.parquet")

# 300 m centra punkti
tikls300_LV=st_read_parquet("./Templates/TemplateGrids/tikls300_sauzeme.parquet")
centri300=st_centroid(tikls300_LV)
st_write_parquet(centri300,"./Templates/TemplateGridPoints/pts300_sauzeme.parquet")

# 300 m saistīšana ar tks93_50km
tks50km=st_read_parquet("./Templates/TemplateGrids/tks93_50km.parquet")
centri300=st_join(centri300,tks50km)
centri300b=centri300 %>% 
  mutate(tks50km=NUMURS) %>% 
  dplyr::select(rinda300,tks50km)
st_write_parquet(centri300b,"./Templates/TemplateGridPoints/pts300_sauzeme.parquet")

# 300 m identificēšana 100 m punktos
punkti=st_read_parquet("./Templates/TemplateGridPoints/pts100_sauzeme.parquet")
savienots=st_join(punkti,tikls300_LV)
st_write_parquet(savienots,"./Templates/TemplateGridPoints/pts100_sauzeme.parquet")

# 300 m identificēšana 100 m režģī
pievienosanai=data.frame(savienots) %>% 
  dplyr::select(id,rinda300)
tikls100=tikls100 %>% 
  left_join(pievienosanai,by="id")
st_write_parquet(tikls100,"./Templates/TemplateGrids/tikls100_sauzeme.parquet")


# 500 m 
# sagatavošana
tikls500=st_make_grid(tikls100,cellsize = 500,crs=3059)
t500=st_as_sf(tikls500)
t500$rinda500=rownames(t500)
sfarrow::st_write_parquet(t500,"./Templates/TemplateGrids/tikls500_sauzeme.parquet")

# 500 m centru punkti
centri500=st_centroid(tikls500)
st_write_parquet(centri500,"./Templates/TemplateGridPoints/pts500_sauzeme.parquet")

# 500 m savienošana ar tks93_50km
tks50km=st_read_parquet("./Templates/TemplateGrids/tks93_50km.parquet")
savienots=st_join(centri500,tks50km)
savienots=savienots %>% 
  mutate(tks50km=NUMURS) %>% 
  dplyr::select(rinda500,tks50km)
st_write_parquet(savienots,"./Templates/TemplateGridPoints/pts500_sauzeme.parquet")
pievienosanai=data.frame(savienots) %>% 
  dplyr::select(rinda500,tks50km)
tikls500=tikls500 %>% 
  left_join(pievienosanai,by="rinda500")
st_write_parquet(tikls500,"./Templates/TemplateGrids/tikls500_sauzeme.parquet")

# 500 m identificēšana 100 m punktos
savienots=st_join(punkti,tikls500)
st_write_parquet(savienots,"./Templates/TemplateGridPoints/pts100_sauzeme.parquet")

# 500 m identificēšana 100 m režģī
pievienosanai=data.frame(savienots) %>% 
  dplyr::select(id,rinda500)
tikls100=tikls100 %>% 
  left_join(pievienosanai,by="id")
st_write_parquet(tikls100,"./Templates/TemplateGrids/tikls100_sauzeme.parquet")

# visus sagatavotos slāņus ievieto ģeosainī (geopackage)
st_write(tikls100,"./Templates/vector_grids.gpkg",layer="tikls100_sauzeme")
st_write(tikls300,"./Templates/vector_grids.gpkg",layer="tikls300_sauzeme")
st_write(tikls500,"./Templates/vector_grids.gpkg",layer="tikls500_sauzeme")
st_write(tikls1000,"./Templates/vector_grids.gpkg",layer="tikls1km_sauzeme")
st_write(centri100,"./Templates/vector_grids.gpkg",layer="pts100_sauzeme")
st_write(centri300,"./Templates/vector_grids.gpkg",layer="pts300_sauzeme")
st_write(centri500,"./Templates/vector_grids.gpkg",layer="pts500_sauzeme")
st_write(centri1000,"./Templates/vector_grids.gpkg",layer="pts1000_sauzeme")
st_write(tks50km,"./Templates/vector_grids.gpkg",layer="tks93_50km")


##  Stratificēšana ģeoprocesēšanas paralelizācijai ----


# Nepieciešamais slānis
rc=st_read_parquet("./Templates/TemplateGridPoints/pts100_sauzeme.parquet")

# karšu lapas
karsu_lapas=levels(factor(rezgis$tks50km))


# Buferēšana un saglabāšana ik 100 m punktam
for(i in seq_along(karsu_lapas)){
  lapa=karsu_lapas[i]
  punkti=rc %>% filter(tks50km == lapa)
  
  rcbuff500=st_buffer(punkti,dist=500)
  st_write_parquet(rcbuff500,paste0("./Templates/TemplateGridPoints/lapas/pts100_r500_",lapa,".parquet"))
  
  rcbuff1250=st_buffer(punkti,dist=1250)
  st_write_parquet(rcbuff1250,paste0("./Templates/TemplateGridPoints/lapas/pts100_r1250_",lapa,".parquet"))
  
  rcbuff3000=st_buffer(punkti,dist=3000)
  st_write_parquet(rcbuff3000,paste0("./Templates/TemplateGridPoints/lapas/pts100_r3000_",lapa,".parquet"))
  
  rcbuff10000=st_buffer(punkti,dist=10000)
  st_write_parquet(rcbuff10000,paste0("./Templates/TemplateGridPoints/lapas/pts100_r10000_",lapa,".parquet"))
}



# punkti 300 m
centri300b=st_read_parquet("./Templates/TemplateGridPoints/pts300_sauzeme.parquet")
numuri=levels(factor(centri300b$tks50km))
for(i in 1:length(numuri)){
  numurs=numuri[i]
  lapa=centri300b %>% filter(tks50km==numurs)
  buferi=st_buffer(lapa,dist=3000)
  st_write_parquet(buferi,paste0("./Templates/TemplateGridPoints/lapas/pts300_r3000_",numurs,".parquet"))
}


# punkti 1000 m
centri1km=st_read_parquet("./Templates/TemplateGridPoints/pts1000_sauzeme.parquet")
numuri=levels(factor(centri1km$tks50km))
for(i in 1:length(numuri)){
  numurs=numuri[i]
  lapa=centri1km %>% filter(tks50km==numurs)
  buferi=st_buffer(lapa,dist=10000)
  st_write_parquet(buferi,paste0("./Templates/TemplateGridPoints/lapas/pts1km_r10000_",numurs,".parquet"))
}

# režģis 100 m
tikls100=st_read_parquet("./Templates/TemplateGrids/tikls100_sauzeme.parquet")
numuri=levels(factor(tikls100$tks50km))
for(i in 1:length(numuri)){
  numurs=numuri[i]
  lapa=tikls100 %>% filter(tks50km==numurs)
  st_write_parquet(lapa,paste0("./Templates/TemplateGrids/lapas/tikls100_",numurs,".parquet"))
}


# References rastri ----


# Nepieciešamie slāņi
tikls100=st_read_parquet("./Templates/TemplateGrids/tikls100_sauzeme.parquet")
b=terra::crs(tikls100)
adm_ter=read_sf("./Templates/administrativas_teritorijas_2021/Administrativas_teritorijas_2021.shp")
adm_ter$yes=1



# 10 m
rastrs=terra::rast(xmin=302800,xmax=772800,ymin=162900,ymax=448900, 
                   resolution=10,crs=b)
rast_LV=rasterize(vect(adm_ter),rastrs)
terra::writeRaster(rast_LV,"./Templates/TemplateRasters/LV10m_10km.tif")


# 100 m
rastrs100=terra::rast(xmin=302800,xmax=772800,ymin=162900,ymax=448900,
                      resolution=100,crs=b)
rast_LV100=rasterize(vect(adm_ter),rastrs100,touches=TRUE)
terra::writeRaster(rast_LV100,"./Templates/TemplateRasters/LV100m_10km.tif")

# 500 m
rastrs500=terra::rast(xmin=302800,xmax=772800,ymin=162900,ymax=448900,resolution=500,crs=b)
rast_LV500=rasterize(vect(adm_ter),rastrs500,touches=TRUE)
terra::writeRaster(rast_LV500,"./Templates/TemplateRasters/LV500m_10km.tif")