# `./IevadesDati` un to priekšapstrādes produktu 
# tālāku apstrādi, sagatavojot dažāda līmeņa produktus, kas nepieciešami vistu vanaga 
# izplatības modeļa parametrizācijā izmantoto ekoģeogrāfisko mainīgo izveidošanai. 
# Lielākā daļa produktu ir rastra slāņi ar 10 m pikseļa izmēru, kas 
# tiek ievietoti `./Rastri_10m`, bet starp tiem ir arī atsevišķi citi produkti


# zemāk esošie nodaļu nosaukumi ir atbilstošo komandu rindu sagatavoto slāņu nosaukumi,
# kādi tiks ievietoti atbilstošajā direktorijā. Tie ir nepieciešami tālākai 
# EGV sagatavošanai. Šo mainīgo sagatavošanas secībai ir nozīme.




# `./Rastri_10m/Ainava_vienk_mask.tif` ----
# Komandu rindas pareizā secībā apvieno iepriekš izveidotos slāņus ar ainavas klasēm 
# un nodrošina robu aizpildīšanu ar atbilstoši klasificētu Dynamic World 2023. gada aprīļa-augusta 
# kompozītu, kuru, pēc maskēšanas tikai analīzes telpai, failā `Ainava_vienk_mask.tif` 
# saglabā turpmākam darbam.
# Apraksts faila `./Rastri_10m/Readme_Rastri10m.md` nodaļā Ainava

# pakotnes

library(tidyverse)
library(sf)
library(arrow)
library(sfarrow)
library(terra)
library(raster)
library(fasterize)
library(gdalUtilities)
library(readxl)



# templates
template_t=rast("./Templates/TemplateRasters/LV10m_10km.tif")
template_r=raster(template_t)

## 100 ----
#poly
celi_topo=st_read_parquet("./IevadesDati/topo/Topo_road_A.parquet")
celi_topo=celi_topo %>% 
  mutate(yes=100) %>% 
  dplyr::select(yes)
ctb=st_buffer(celi_topo,dist=10)
r_celi_topo=fasterize(ctb,template_r,field="yes")

# pts
nobrauktuves=st_read("./IevadesDati/LVM_AtvertieDati/lejupielades/LVM_NOBRAUKTUVES/LVM_NOBRAUKTUVES_Shape.shp")
nobrauktuves=nobrauktuves %>% 
  mutate(yes=100) %>% 
  dplyr::select(yes)
izmainisanas=st_read("./IevadesDati/LVM_AtvertieDati/lejupielades/LVM_IZMAINISANAS_VIETAS/LVM_IZMAINISANAS_VIETAS_Shape.shp")
izmainisanas=izmainisanas %>% 
  mutate(yes=100) %>% 
  dplyr::select(yes)
apgriesanas=st_read("./IevadesDati/LVM_AtvertieDati/lejupielades/LVM_APGRIESANAS_LAUKUMI/LVM_APGRIESANAS_LAUKUMI_Shape.shp")
apgriesanas=apgriesanas %>% 
  mutate(yes=100) %>% 
  dplyr::select(yes)
cp=rbind(nobrauktuves,izmainisanas,apgriesanas)
cpb=st_buffer(cp,dist=10)
r_celi_pts=fasterize(cpb,template_r,field="yes")


# lines
meza_autoceli=st_read("./IevadesDati/LVM_AtvertieDati/lejupielades/LVM_MEZA_AUTOCELI/LVM_MEZA_AUTOCELI_Shape.shp")
meza_autoceli=meza_autoceli %>% 
  mutate(yes=100) %>% 
  dplyr::select(yes)
attistamie=st_read("./IevadesDati/LVM_AtvertieDati/lejupielades/LVM_ATTISTAMIE_AUTOCELI/LVM_ATTISTAMIE_AUTOCELI_Shape.shp")
attistamie=attistamie %>% 
  mutate(yes=100) %>% 
  dplyr::select(yes)
topo_lines=st_read_parquet("./IevadesDati/topo/Topo_roadL.parquet")
topo_lines=topo_lines %>% 
  mutate(yes=100) %>% 
  dplyr::select(yes)
cl=bind_rows(meza_autoceli,attistamie,topo_lines)
cl=cl %>% 
  dplyr::select(yes)
clb=st_buffer(cl,dist=10)
r_celi_lines=fasterize(clb,template_r,field="yes")

# liekā aizvākšana
rm(apgriesanas)
rm(attistamie)
rm(celi_topo)
rm(topo_lines)
rm(ctb)
rm(cl)
rm(clb)
rm(cp)
rm(cpb)
rm(izmainisanas)
rm(meza_autoceli)
rm(nobrauktuves)

# ģeometriju rasterizēšana
t_celi_topo=rast(r_celi_topo)
writeRaster(t_celi_topo,"./IevadesDati/ainava/100a.tif")
t_celi_pts=rast(r_celi_pts)
writeRaster(t_celi_pts,"./IevadesDati/ainava/100b.tif")
t_celi_lines=rast(r_celi_lines)
writeRaster(t_celi_lines,"./IevadesDati/ainava/100c.tif")

# liekā aizvākšana
rm(r_celi_lines)
rm(r_celi_pts)
rm(r_celi_topo)
rm(t_celi_lines)
rm(t_celi_pts)
rm(t_celi_topo)

# apvienošana
a100=rast("./IevadesDati/ainava/100a.tif")
b100=rast("./IevadesDati/ainava/100b.tif")
c100=rast("./IevadesDati/ainava/100c.tif")

rastri=sprc(a100,b100,c100)
rastrs_celi=terra::merge(rastri,
                         filename="./IevadesDati/ainava/100_celi.tif",
                         overwrite=TRUE)
# liekā aizvākšana
rm(a100)
rm(b100)
rm(c100)
rm(rastri)
rm(rastrs_celi)

## 200 ----

# topo
topo_udens_poly=st_read_parquet("./IevadesDati/topo/Topo_hidroA.parquet")
topo_udens_poly=topo_udens_poly %>% 
  mutate(yes=200) %>% 
  dplyr::select(yes) %>% 
  st_transform(crs=3059)
topo_udens_lines=st_read_parquet("./IevadesDati/topo/Topo_hidroL.parquet")
topo_udens_lines=topo_udens_lines %>% 
  mutate(yes=200) %>% 
  st_buffer(dist=5) %>% 
  dplyr::select(yes) %>% 
  st_transform(crs=3059)
topo_udens=rbind(topo_udens_poly,topo_udens_lines)
r_topo_udens=fasterize(topo_udens,template_r,field="yes")
raster::writeRaster(r_topo_udens,
                    "./IevadesDati/ainava/200_topo.tif",
                    progress="text")
# liekā aizvākšana
rm(topo_udens_lines)
rm(topo_udens_poly)
rm(topo_udens)
rm(r_topo_udens)

# mkis
mkis_gravji=st_read("./IevadesDati/MKIS/MKIS_20180612.gdb/",layer="Ditches")

ensure_MULTILINESTRING <- function(X) {
  tmp1 <- tempfile(fileext = ".gpkg")
  tmp2 <- tempfile(fileext = ".gpkg")
  st_write(X, tmp1)
  ogr2ogr(tmp1, tmp2, f = "GPKG", nlt = "MULTILINESTRING")
  Y <- st_read(tmp2)
  st_sf(st_drop_geometry(X), geom = st_geometry(Y))
}
mkis_gravji2 <- ensure_MULTILINESTRING(mkis_gravji)

mkis_gravji3 = mkis_gravji2[!st_is_empty(mkis_gravji2),,drop=FALSE] # 2 geom
validity=st_is_valid(mkis_gravji3) 
table(validity) # OK

mkis_gravji=mkis_gravji3 %>% 
  mutate(yes=200) %>% 
  st_buffer(dist=3) %>% 
  dplyr::select(yes)
r_mkis_udens=fasterize(mkis_gravji,template_r,field="yes")
raster::writeRaster(r_mkis_udens,
                    "./IevadesDati/ainava/200_mkis.tif",
                    progress="text")
# liekā aizvākšana
rm(mkis_gravji)
rm(mkis_gravji2)
rm(mkis_gravji3)
rm(r_mkis_udens)
rm(validity)

# lvm
lvm_gravji=st_read("./IevadesDati/LVM_AtvertieDati/lejupielades/LVM_GRAVJI/LVM_GRAVJI_Shape.shp")
lvm_gravji=lvm_gravji %>% 
  mutate(yes=200) %>% 
  st_buffer(dist=5) %>% 
  dplyr::select(yes)
r_lvm_gravji=fasterize(lvm_gravji,template_r,field="yes")
raster::writeRaster(r_lvm_gravji,
                    "./IevadesDati/ainava/200_lvm.tif",
                    progress="text",
                    overwrite=TRUE)
# liekā aizvākšana
rm(lvm_gravji)
rm(r_lvm_gravji)


# apvienojums
a200=rast("./IevadesDati/ainava/200_topo.tif")
b200=rast("./IevadesDati/ainava/200_mkis.tif")
c200=rast("./IevadesDati/ainava/200_lvm.tif")

rastri_udens=sprc(a200,b200,c200)
rastrs_udens=terra::merge(rastri_udens,
                          filename="./IevadesDati/ainava/200_udens_premask.tif",
                          overwrite=TRUE)
# liekā aizvākšana
rm(a200)
rm(b200)
rm(c200)
rm(rastri_udens)
rm(rastrs_udens)

## 300 ----
# lad
lad_klasem=read_excel("./IevadesDati/LAD/KulturuKodi_2024.xlsx")
lad=st_read_parquet("./IevadesDati/LAD/LAD_lauki.parquet")


## aramzemes
amazemem=lad_klasem %>% 
  filter(str_detect(SDM_grupa_sakums,"aramz"))
aramzemes=lad %>% 
  filter(PRODUCT_CODE %in% amazemem$kods) %>% 
  mutate(yes=310) %>% 
  dplyr::select(yes)
r_aramzemes_lad=fasterize(aramzemes,template_r,field="yes")
raster::writeRaster(r_aramzemes_lad,
                    "./IevadesDati/ainava/310_aramzemes_lad.tif",
                    progress="text",
                    overwrite=TRUE)
# liekā aizvākšana
rm(amazemem)
rm(aramzemes)
rm(r_aramzemes_lad)


## papuves
papuvem=lad_klasem %>% 
  filter(str_detect(SDM_grupa_sakums,"papuv"))
papuves=lad %>% 
  filter(PRODUCT_CODE %in% papuvem$kods) %>% 
  mutate(yes=320) %>% 
  dplyr::select(yes)
r_papuves_lad=fasterize(papuves,template_r,field="yes")
raster::writeRaster(r_papuves_lad,
                    "./IevadesDati/ainava/320_papuves_lad.tif",
                    progress="text",
                    overwrite=TRUE)
# liekā aizvākšana
rm(papuvem)
rm(papuves)
rm(r_papuves_lad)

## zalaji
zalajiem=lad_klasem %>% 
  filter(str_detect(SDM_grupa_sakums,"zālā"))
zalaji=lad %>% 
  filter(PRODUCT_CODE %in% zalajiem$kods) %>% 
  mutate(yes=330) %>% 
  dplyr::select(yes)
r_zalaji_lad=fasterize(zalaji,template_r,field="yes")
raster::writeRaster(r_zalaji_lad,
                    "./IevadesDati/ainava/330_zalaji_lad.tif",
                    progress="text",
                    overwrite=TRUE)
# liekā aizvākšana
rm(zalajiem)
rm(zalaji)
rm(r_zalaji_lad)

# apvienojums
a300=rast("./IevadesDati/ainava/310_aramzemes_lad.tif")
b300=rast("./IevadesDati/ainava/320_papuves_lad.tif")
c300=rast("./IevadesDati/ainava/330_zalaji_lad.tif")

rastri_laukiem=sprc(a300,b300,c300)
rastrs_lauki=terra::merge(rastri_laukiem,
                          filename="./IevadesDati/ainava/300_lauki_premask.tif",
                          overwrite=TRUE)
# liekā aizvākšana
rm(lad)
rm(lad_klasem)
rm(a300)
rm(b300)
rm(c300)
rm(rastri_laukiem)
rm(rastrs_lauki)

## 400 ----

# topo
darzini_topo=st_read_parquet("./IevadesDati/topo/Topo_landusA.parquet")
table(darzini_topo$FNAME,useNA="always")
darzini_topo=darzini_topo %>% 
  filter(FNAME %in% c("poligons_Augļudārzs","poligons_Sakņudārzs",
                      "poligons_Ogulājs")) %>% 
  mutate(yes=410) %>% 
  dplyr::select(yes)
r_darzini_topo=fasterize(darzini_topo,template_r,field="yes")
raster::writeRaster(r_darzini_topo,
                    "./IevadesDati/ainava/410_darzini_topo.tif",
                    progress="text",
                    overwrite=TRUE)
# liekā aizvākšana
rm(darzini_topo)
rm(r_darzini_topo)

# lad
lad_klasem=read_excel("./IevadesDati/LAD/KulturuKodi_2024.xlsx")
table(lad_klasem$SDM_grupa_sakums,useNA="always")
augludarziem=lad_klasem %>% 
  filter(SDM_grupa_sakums=="augļudārzi")
lad=st_read_parquet("./IevadesDati/LAD/LAD_lauki.parquet")
lad=lad %>% 
  filter(PRODUCT_CODE %in% augludarziem$kods) %>% 
  mutate(yes=420) %>% 
  dplyr::select(yes)
r_darzini_lad=fasterize(lad,template_r,field="yes")
raster::writeRaster(r_darzini_lad,
                    "./IevadesDati/ainava/420_darzini_lad.tif",
                    progress="text",
                    overwrite=TRUE)
# liekā aizvākšana
rm(lad_klasem)
rm(augludarziem)
rm(lad)
rm(r_darzini_lad)

# apvienojums
a400=rast("./IevadesDati/ainava/410_darzini_topo.tif")
b400=rast("./IevadesDati/ainava/420_darzini_lad.tif")

rastri_vasarnicam=sprc(a400,b400)
rastrs_vasarnicas=terra::merge(rastri_vasarnicam,
                               filename="./IevadesDati/ainava/400_varnicas_premask.tif",
                               overwrite=TRUE)
# liekā aizvākšana
rm(a400)
rm(b400)
rm(rastri_vasarnicam)
rm(rastrs_vasarnicas)

## 500 ----
# aizpildīts beigās


## 600 ----

# mvr 
mvr=st_read_parquet("./IevadesDati/MVR/nogabali_2024janv.parquet")

# izcirtumi
izcirtumi=mvr %>% 
  filter(zkat %in% c("12","14")) %>% 
  mutate(yes=610) %>% 
  dplyr::select(yes)
r_izcirtumi_mvr=fasterize(izcirtumi,template_r,field="yes")
raster::writeRaster(r_izcirtumi_mvr,
                    "./IevadesDati/ainava/610_izcirtumi_mvr.tif",
                    progress="text",
                    overwrite=TRUE)
# liekā aizvākšana
rm(izcirtumi)
rm(r_izcirtumi_mvr)

# zemās audzes
# arī zkat 16
zemas_audzes=mvr %>% 
  filter((zkat =="10" & h10<5)|zkat=="16") %>% 
  mutate(yes=620) %>% 
  dplyr::select(yes)
r_zemas_mvr=fasterize(zemas_audzes,template_r,field="yes")
raster::writeRaster(r_zemas_mvr,
                    "./IevadesDati/ainava/620_zemas_mvr.tif",
                    progress="text",
                    overwrite=TRUE)
# liekā aizvākšana
rm(zemas_audzes)
rm(r_zemas_mvr)


# augstās audzes
augstas_audzes=mvr %>% 
  filter(zkat =="10" & h10>=5) %>% 
  mutate(yes=630) %>% 
  dplyr::select(yes)
r_augstas_mvr=fasterize(augstas_audzes,template_r,field="yes")
raster::writeRaster(r_augstas_mvr,
                    "./IevadesDati/ainava/630_augstas_mvr.tif",
                    progress="text",
                    overwrite=TRUE)
# liekā aizvākšana
rm(augstas_audzes)
rm(r_augstas_mvr)
rm(mvr)

# tcl - kopš 2020
tcl=rast("./Rastri_10m/TreeCoverLossYear.tif")
tcl2=ifel(tcl<20,NA,610,
          filename="./IevadesDati/ainava/610_TCL.tif",
          overwrite=TRUE)
# liekā aizvākšana
rm(tcl)
rm(tcl2)

# palsar
palsar=rast("./Rastri_10m/Palsar_Forests.tif")
palsar2=ifel(palsar==1,630,NA,
             filename="./IevadesDati/ainava/630_Palsar.tif",
             overwrite=TRUE)
# liekā aizvākšana
rm(palsar)
rm(palsar2)


# lad
lad_klasem=read_excel("./IevadesDati/LAD/KulturuKodi_2024.xlsx")
table(lad_klasem$SDM_grupa_sakums,useNA="always")
lad=st_read_parquet("./IevadesDati/LAD/LAD_lauki.parquet")
krumiem=lad_klasem %>% 
  filter(str_detect(SDM_grupa_sakums,"krūmv"))
krumi=lad %>% 
  filter(PRODUCT_CODE %in% krumiem$kods) %>% 
  mutate(yes=620) %>% 
  dplyr::select(yes)
r_krumi_lad=fasterize(krumi,template_r,field="yes")
raster::writeRaster(r_krumi_lad,
                    "./IevadesDati/ainava/620_krumi_lad.tif",
                    progress="text",
                    overwrite=TRUE)
# liekā aizvākšana
rm(lad_klasem)
rm(lad)
rm(krumiem)
rm(krumi)
rm(r_krumi_lad)

# topo - pkk
pkk_topo=st_read_parquet("./IevadesDati/topo/Topo_landusA.parquet")
table(pkk_topo$FNAME,useNA="always")
pkk_topo=pkk_topo %>% 
  filter(FNAME %in% c("poligons_Parks","poligons_Meza_kapi","poligons_Kapi")) %>% 
  mutate(yes=640) %>% 
  dplyr::select(yes)
r_pkk_topo=fasterize(pkk_topo,template_r,field="yes")
raster::writeRaster(r_pkk_topo,
                    "./IevadesDati/ainava/640_pkk_topo.tif",
                    progress="text",
                    overwrite=TRUE)
# liekā aizvākšana
rm(pkk_topo)
rm(r_pkk_topo)

# topo - krūmi
krumi_topo=st_read_parquet("./IevadesDati/topo/Topo_landusA.parquet")
table(krumi_topo$FNAME,useNA="always")
krumi_topo=krumi_topo %>% 
  filter(FNAME %in% c("poligons_Krūmājs")) %>% 
  mutate(yes=620) %>% 
  dplyr::select(yes)
r_krumi_topo=fasterize(krumi_topo,template_r,field="yes")
raster::writeRaster(r_krumi_topo,
                    "./IevadesDati/ainava/620_krumi_topo.tif",
                    progress="text",
                    overwrite=TRUE)
# liekā aizvākšana
rm(krumi_topo)
rm(r_krumi_topo)

# topo - linijkrumi un linijkoki
linijas_topo=st_read_parquet("./IevadesDati/topo/Topo_floraL.parquet")

# linijkrumi
krumu_linijas_topo=linijas_topo %>% 
  filter(str_detect(FNAME,"Krūmu")) %>% 
  mutate(yes=620) %>% 
  st_buffer(dist=10) %>% 
  dplyr::select(yes)
r_krumu_linijas_topo=fasterize(krumu_linijas_topo,template_r,field="yes")
raster::writeRaster(r_krumu_linijas_topo,
                    "./IevadesDati/ainava/620_KrumuLinijas_topo.tif",
                    progress="text",
                    overwrite=TRUE)
# liekā aizvākšana
rm(krumu_linijas_topo)
rm(r_krumu_linijas_topo)

# linijkoki
koku_linijas_topo=linijas_topo %>% 
  filter(str_detect(FNAME,"Koku")) %>% 
  mutate(yes=640) %>% 
  st_buffer(dist=10) %>% 
  dplyr::select(yes)
r_koku_linijas_topo=fasterize(koku_linijas_topo,template_r,field="yes")
raster::writeRaster(r_koku_linijas_topo,
                    "./IevadesDati/ainava/640_KokuLinijas_topo.tif",
                    progress="text",
                    overwrite=TRUE)
# liekā aizvākšana
rm(koku_linijas_topo)
rm(r_koku_linijas_topo)
rm(linijas_topo)

# apvienosana
r_krumi_lad=rast("./IevadesDati/ainava/620_krumi_lad.tif")
r_pkk_topo=rast("./IevadesDati/ainava/640_pkk_topo.tif")
r_krumi_topo=rast("./IevadesDati/ainava/620_krumi_topo.tif")
r_krumu_linijas_topo=rast("./IevadesDati/ainava/620_KrumuLinijas_topo.tif")
r_koku_linijas_topo=rast("./IevadesDati/ainava/640_KokuLinijas_topo.tif")
r_palsar=rast("./IevadesDati/ainava/630_palsar.tif")
r_tcl=rast("./IevadesDati/ainava/610_TCL.tif")
r_augstas_mvr=rast("./IevadesDati/ainava/630_augstas_mvr.tif")
r_zemas_mvr=rast("./IevadesDati/ainava/620_zemas_mvr.tif")
r_izcirtumi_mvr=rast("./IevadesDati/ainava/610_izcirtumi_mvr.tif")

rastri_meziem=sprc(r_tcl,r_izcirtumi_mvr,
                   r_zemas_mvr,r_krumu_linijas_topo,r_krumi_topo,r_krumi_lad,
                   r_augstas_mvr,
                   r_pkk_topo,r_koku_linijas_topo,
                   r_palsar)
rastrs_mezi=terra::merge(rastri_meziem,
                         filename="./IevadesDati/ainava/600_meziem_premask.tif",
                         overwrite=TRUE)
# liekā aizvākšana
rm(r_krumi_lad)
rm(r_pkk_topo)
rm(r_krumi_topo)
rm(r_krumu_linijas_topo)
rm(r_koku_linijas_topo)
rm(r_palsar)
rm(r_tcl)
rm(r_augstas_mvr)
rm(r_zemas_mvr)
rm(r_izcirtumi_mvr)
rm(rastri_meziem)
rm(rastrs_mezi)


## 700 ----

# topo
topo=st_read_parquet("./IevadesDati/topo/Topo_landusA.parquet")
table(topo$FNAME,useNA="always")

## niedrāji
niedraji_topo=topo %>% 
  filter(FNAME %in% c("Meldrājs_ūdenī_poligons","poligons_Grīslājs",
                      "poligons_Meldrājs","poligons_Nec_purvs_grīslājs",
                      "poligons_Nec_purvs_meldrājs","Sēklis_poligons")) %>% 
  mutate(yes=720) %>% 
  dplyr::select(yes)
r_niedraji_topo=fasterize(niedraji_topo,template_r,field="yes")
raster::writeRaster(r_niedraji_topo,
                    "./IevadesDati/ainava/720_niedraji_topo.tif",
                    progress="text")
# liekā aizvākšana
rm(niedraji_topo)
rm(r_niedraji_topo)


## purvi
purvi_topo=topo %>% 
  filter(FNAME %in% c("poligons_Nec_purvs_sūnājs","poligons_Sūnājs")) %>% 
  mutate(yes=710) %>% 
  dplyr::select(yes)
topo_purvi=st_read_parquet("./IevadesDati/topo/Topo_swampA.parquet")
topo_purvi=topo_purvi %>% 
  mutate(yes=710) %>% 
  dplyr::select(yes)
purvi=rbind(purvi_topo,topo_purvi)
r_purvi_topo=fasterize(purvi,template_r,field="yes")
raster::writeRaster(r_purvi_topo,
                    "./IevadesDati/ainava/710_purvi_topo.tif",
                    progress="text",
                    overwrite=TRUE)
# liekā aizvākšana
rm(purvi_topo)
rm(topo_purvi)
rm(purvi)
rm(r_purvi_topo)


# mvr
mvr=st_read_parquet("./IevadesDati/MVR/nogabali_2024janv.parquet")

# sūnu, zālu pārejas purvi
mvr_purvi=mvr %>% 
  filter(zkat %in% c("21","22","23")) %>% 
  mutate(yes=710) %>% 
  dplyr::select(yes)
r_purvi_mvr=fasterize(mvr_purvi,template_r,field="yes")
raster::writeRaster(r_purvi_mvr,
                    "./IevadesDati/ainava/710_purvi_mvr.tif",
                    progress="text",
                    overwrite=TRUE)
# liekā aizvākšana
rm(mvr_purvi)
rm(r_purvi_mvr)

# bebraines un pārplūstoši klajumi
mvr_bebri=mvr %>% 
  filter(zkat %in% c("41","42")) %>% 
  mutate(yes=730) %>% 
  dplyr::select(yes)
r_bebri_mvr=fasterize(mvr_bebri,template_r,field="yes")
raster::writeRaster(r_bebri_mvr,
                    "./IevadesDati/ainava/730_bebri_mvr.tif",
                    progress="text",
                    overwrite=TRUE)
# liekā aizvākšana
rm(mvr_bebri)
rm(r_bebri_mvr)
rm(mvr)

# apvienosana
r_niedraji_topo=rast("./IevadesDati/ainava/720_niedraji_topo.tif")
r_purvi_topo=rast("./IevadesDati/ainava/710_purvi_topo.tif")
r_purvi_mvr=rast("./IevadesDati/ainava/710_purvi_mvr.tif")
r_bebri_mvr=rast("./IevadesDati/ainava/730_bebri_mvr.tif")


rastri_mitrajiem=sprc(r_niedraji_topo,r_purvi_topo,r_purvi_mvr,r_bebri_mvr)
rastrs_mitraji=terra::merge(rastri_mitrajiem,
                            filename="./IevadesDati/ainava/700_mitraji_premask.tif",
                            overwrite=TRUE)
# liekā aizvākšana
rm(r_niedraji_topo)
rm(r_purvi_topo)
rm(r_purvi_mvr)
rm(r_bebri_mvr)
rm(rastri_mitrajiem)
rm(rastrs_mitraji)

## 800 ----

smiltaji_topo=st_read_parquet("./IevadesDati/topo/Topo_landusA.parquet")
table(smiltaji_topo$FNAME,useNA="always")
smiltaji_topo=smiltaji_topo %>% 
  filter(FNAME %in% c("poligons_Smiltājs","poligons_Kūdra")) %>% 
  mutate(yes=800) %>% 
  dplyr::select(yes)
r_smiltaji_topo=fasterize(smiltaji_topo,template_r,field="yes")
raster::writeRaster(r_smiltaji_topo,
                    "./IevadesDati/ainava/800_SmiltajiKudra_topo.tif",
                    progress="text")
# liekā aizvākšana
rm(smiltaji_topo)
rm(r_smiltaji_topo)

# mvr zkat 33 un 34
mvr=st_read_parquet("./IevadesDati/MVR/nogabali_2024janv.parquet")

smiltajiem=mvr %>% 
  filter(zkat %in% c("33","34")) %>% 
  mutate(yes=800) %>% 
  dplyr::select(yes)
r_smiltaji_mvr=fasterize(smiltajiem,template_r,field="yes")
raster::writeRaster(r_smiltaji_mvr,
                    "./IevadesDati/ainava/800_SmiltVirs_mvr.tif",
                    progress="text",
                    overwrite=TRUE)
# liekā aizvākšana
rm(mvr)
rm(smiltajiem)
rm(r_smiltaji_mvr)

# apvienosana
r_smiltaji_topo=rast("./IevadesDati/ainava/800_SmiltajiKudra_topo.tif")
r_smiltaji_mvr=rast("./IevadesDati/ainava/800_SmiltVirs_mvr.tif")

rastri_smiltajiem=sprc(r_smiltaji_topo,r_smiltaji_mvr)
rastrs_smiltajiem=terra::merge(rastri_smiltajiem,
                               filename="./IevadesDati/ainava/800_smiltaji_premask.tif",
                               overwrite=TRUE)
# liekā aizvākšana
rm(r_smiltaji_topo)
rm(r_smiltaji_mvr)
rm(rastri_smiltajiem)
rm(rastrs_smiltajiem)

## aizpildīšana ----


# DW pildījums 
dynworld=rast("./IevadesDati/DynamicWorld/DynamicWorld_Eksperimentam/DWE_mosaic/DW_2023_apraug.tif")
klases=matrix(c(0,200,
                1,620,
                2,330,
                3,720,
                4,310,
                5,710,
                6,500,
                7,800,
                8,500),ncol=2,byrow=TRUE)
dw2=terra::classify(dynworld,klases)
writeRaster(dw2,
            "./IevadesDati/ainava/DW_reclass.tif",
            overwrite=TRUE)

celi=rast("./IevadesDati/ainava/100_celi.tif")
udeni=rast("./IevadesDati/ainava/200_udens_premask.tif")
lauki=rast("./IevadesDati/ainava/300_lauki_premask.tif")
vasarnicas=rast("./IevadesDati/ainava/400_varnicas_premask.tif")
mezi=rast("./IevadesDati/ainava/600_meziem_premask.tif")
mitraji=rast("./IevadesDati/ainava/700_mitraji_premask.tif")
smiltaji=rast("./IevadesDati/ainava/800_smiltaji_premask.tif")
dw2=rast("./IevadesDati/ainava/DW_reclass.tif")

rastri_ainavai=sprc(celi,udeni,lauki,vasarnicas,mezi,mitraji,smiltaji,dw2)
rastrs_ainava=terra::merge(rastri_ainavai,
                           filename="./IevadesDati/ainava/Ainava_vienkarsa.tif",
                           overwrite=TRUE)
# liekā aizvākšana
rm(celi)
rm(udeni)
rm(lauki)
rm(vasarnicas)
rm(mezi)
rm(mitraji)
rm(smiltaji)
rm(klases)
rm(dynworld)
rm(dw2)
rm(rastri_ainavai)
rm(rastrs_ainava)

# maskēšana
rastrs_ainava=rast("./IevadesDati/ainava/Ainava_vienkarsa.tif")
masketa_ainava=terra::mask(rastrs_ainava,
                           template_t,
                           filename="./IevadesDati/ainava/Ainava_vienk_mask.tif",
                           overwrite=TRUE)
masketa_ainava2=terra::mask(rastrs_ainava,
                            template_t,
                            filename="./Rastri_10m/Ainava_vienk_mask.tif",
                            overwrite=TRUE)

# liekā aizvākšana
rm(rastrs_ainava)
rm(masketa_ainava)

rm(list=ls())


# `./Rastri_10m/Lauki_zalajiYN.tif` ----


library(tidyverse)
library(sf)
library(arrow)
library(sfarrow)
library(terra)
library(raster)
library(fasterize)
library(gdalUtilities)
library(readxl)


# templates
template_t=rast("./Templates/TemplateRasters/LV10m_10km.tif")
template_r=raster(template_t)

nulles=terra::subst(template_t,from=1,to=0)

# vienkāršā ainava
ainava_t=rast("./Rastri_10m/Ainava_vienk_mask.tif")
ainava_r=raster(ainava_t)

# zālāji
zalajiYN=ifel(ainava_t==330,1,0,
              filename="./Rastri_10m/Lauki_zalajiYN.tif",
              overwrite=TRUE)


rm(list=ls())



# `./Rastri_10m/Lauki_papuvesYN.tif` ----



library(tidyverse)
library(sf)
library(arrow)
library(sfarrow)
library(terra)
library(raster)
library(fasterize)
library(gdalUtilities)
library(readxl)

# templates
template_t=rast("./Templates/TemplateRasters/LV10m_10km.tif")
template_r=raster(template_t)

nulles=terra::subst(template_t,from=1,to=0)

# vienkāršā ainava
ainava_t=rast("./Rastri_10m/Ainava_vienk_mask.tif")
ainava_r=raster(ainava_t)

# papuves
papuvesYN=ifel(ainava_t==320,1,0,
               filename="./Rastri_10m/Lauki_papuvesYN.tif",
               overwrite=TRUE)

rm(list=ls())

# `./Rastri_10m/Lauki_AramzemesYN.tif` ----



library(tidyverse)
library(sf)
library(arrow)
library(sfarrow)
library(terra)
library(raster)
library(fasterize)
library(gdalUtilities)
library(readxl)

# templates
template_t=rast("./Templates/TemplateRasters/LV10m_10km.tif")
template_r=raster(template_t)

nulles=terra::subst(template_t,from=1,to=0)

# vienkāršā ainava
ainava_t=rast("./Rastri_10m/Ainava_vienk_mask.tif")
ainava_r=raster(ainava_t)

# aramzemes
aramzemesYN=ifel(ainava_t==310,1,0,
                 filename="./Rastri_10m/Lauki_AramzemesYN.tif",
                 overwrite=TRUE)

rm(list=ls())



# `./Rastri_10m/Mezi_OligoSus.tif` ----


library(tidyverse)
library(sf)
library(arrow)
library(sfarrow)
library(terra)
library(raster)
library(fasterize)
library(gdalUtilities)
library(readxl)



# templates
template_t=rast("./Templates/TemplateRasters/LV10m_10km.tif")
template_r=raster(template_t)

nulles=terra::subst(template_t,from=1,to=0)

# vienkāršā ainava
ainava_t=rast("./Rastri_10m/Ainava_vienk_mask.tif")
ainava_r=raster(ainava_t)
maska_meziem=ifel(ainava_t>600&ainava_t<700,1,NA)

# meži
mvr=st_read_parquet("./IevadesDati/MVR/nogabali_2024janv.parquet")
mvr$yes=1


# Oligotrofi susinātie meži
nogabali=mvr %>% 
  filter(mt %in% c("17","18","22","23"))
rastrs_mvr=fasterize::fasterize(nogabali,template_r,field="yes")
rastrs_mvr=rast(rastrs_mvr)

pirmsmaskas_rastrs=ifel(!is.na(rastrs_mvr)&maska_meziem==1,656,0)
aizpildits=terra::cover(pirmsmaskas_rastrs,nulles)
pecmaskas_rastrs=mask(aizpildits,template_t,
                      filename="./Rastri_10m/Mezi_OligoSus.tif",
                      overwrite=TRUE)

rm(list=ls())



# `./Rastri_10m/Mezi_OligoSaus.tif` ----


library(tidyverse)
library(sf)
library(arrow)
library(sfarrow)
library(terra)
library(raster)
library(fasterize)
library(gdalUtilities)
library(readxl)


# templates
template_t=rast("./Templates/TemplateRasters/LV10m_10km.tif")
template_r=raster(template_t)

nulles=terra::subst(template_t,from=1,to=0)

# vienkāršā ainava
ainava_t=rast("./Rastri_10m/Ainava_vienk_mask.tif")
ainava_r=raster(ainava_t)
maska_meziem=ifel(ainava_t>600&ainava_t<700,1,NA)

# meži
mvr=st_read_parquet("./IevadesDati/MVR/nogabali_2024janv.parquet")
mvr$yes=1


# Oligotrofi sausieņu un slapjaiņu meži
nogabali=mvr %>% 
  filter(mt %in% c("1","2","3","7","8"))
rastrs_mvr=fasterize::fasterize(nogabali,template_r,field="yes")
rastrs_mvr=rast(rastrs_mvr)

pirmsmaskas_rastrs=ifel(!is.na(rastrs_mvr)&maska_meziem==1,651,0)
aizpildits=terra::cover(pirmsmaskas_rastrs,nulles)
pecmaskas_rastrs=mask(aizpildits,template_t,
                      filename="./Rastri_10m/Mezi_OligoSaus.tif",
                      overwrite=TRUE)
rm(list=ls())




# `./Rastri_10m/Mezi_MezoSaus.tif` ----


library(tidyverse)
library(sf)
library(arrow)
library(sfarrow)
library(terra)
library(raster)
library(fasterize)
library(gdalUtilities)
library(readxl)


# templates
template_t=rast("./Templates/TemplateRasters/LV10m_10km.tif")
template_r=raster(template_t)

nulles=terra::subst(template_t,from=1,to=0)

# vienkāršā ainava
ainava_t=rast("./Rastri_10m/Ainava_vienk_mask.tif")
ainava_r=raster(ainava_t)
maska_meziem=ifel(ainava_t>600&ainava_t<700,1,NA)

# meži
mvr=st_read_parquet("./IevadesDati/MVR/nogabali_2024janv.parquet")
mvr$yes=1

# Mezotrofi sausieņu un slapjaiņu meži
nogabali=mvr %>% 
  filter(mt %in% c("4","9"))
rastrs_mvr=fasterize::fasterize(nogabali,template_r,field="yes")
rastrs_mvr=rast(rastrs_mvr)

pirmsmaskas_rastrs=ifel(!is.na(rastrs_mvr)&maska_meziem==1,652,0)
aizpildits=terra::cover(pirmsmaskas_rastrs,nulles)
pecmaskas_rastrs=mask(aizpildits,template_t,
                      filename="./Rastri_10m/Mezi_MezoSaus.tif",
                      overwrite=TRUE)

rm(list=ls())



# `./Rastri_10m/Mezi_EitrSus.tif` ----


library(tidyverse)
library(sf)
library(arrow)
library(sfarrow)
library(terra)
library(raster)
library(fasterize)
library(gdalUtilities)
library(readxl)


# templates
template_t=rast("./Templates/TemplateRasters/LV10m_10km.tif")
template_r=raster(template_t)

nulles=terra::subst(template_t,from=1,to=0)

# vienkāršā ainava
ainava_t=rast("./Rastri_10m/Ainava_vienk_mask.tif")
ainava_r=raster(ainava_t)
maska_meziem=ifel(ainava_t>600&ainava_t<700,1,NA)


# meži
mvr=st_read_parquet("./IevadesDati/MVR/nogabali_2024janv.parquet")
mvr$yes=1

# Eitrofi susinātie meži
nogabali=mvr %>% 
  filter(mt %in% c("19","21","24","25"))
rastrs_mvr=fasterize::fasterize(nogabali,template_r,field="yes")
rastrs_mvr=rast(rastrs_mvr)

pirmsmaskas_rastrs=ifel(!is.na(rastrs_mvr)&maska_meziem==1,657,0)
aizpildits=terra::cover(pirmsmaskas_rastrs,nulles)
pecmaskas_rastrs=mask(aizpildits,template_t,
                      filename="./Rastri_10m/Mezi_EitrSus.tif",
                      overwrite=TRUE)
rm(list=ls())



# `./Rastri_10m/Mezi_IzcUNzem5m.tif` ----


library(tidyverse)
library(sf)
library(arrow)
library(sfarrow)
library(terra)
library(raster)
library(fasterize)
library(gdalUtilities)
library(readxl)


# templates
template_t=rast("./Templates/TemplateRasters/LV10m_10km.tif")
template_r=raster(template_t)

nulles=terra::subst(template_t,from=1,to=0)

# vienkāršā ainava
ainava_t=rast("./Rastri_10m/Ainava_vienk_mask.tif")
ainava_r=raster(ainava_t)
maska_meziem=ifel(ainava_t>600&ainava_t<700,1,NA)



# meži
mvr=st_read_parquet("./IevadesDati/MVR/nogabali_2024janv.parquet")
mvr$yes=1

# Izcirtumi un jaunaudzes līdz 5 m
nogabali=mvr %>% 
  filter((zkat=="10"&h10<5)|zkat=="16") %>% 
  mutate(yes=661)
rastrs_mvr=fasterize::fasterize(nogabali,template_r,field="yes")
rastrs_mvr=rast(rastrs_mvr)

klase_610=ifel(ainava_t==610,661,NA)
klases=merge(klase_610,rastrs_mvr)
pirmsmaskas_rastrs=ifel(!is.na(klases)&maska_meziem==1,661,0)
aizpildits=terra::cover(pirmsmaskas_rastrs,nulles)
pecmaskas_rastrs=mask(aizpildits,template_t,
                      filename="./Rastri_10m/Mezi_IzcUNzem5m.tif",
                      overwrite=TRUE)
rm(list=ls())


# `./Rastri_10m/Mezi_Saurlapju.tif` ----


library(tidyverse)
library(sf)
library(arrow)
library(sfarrow)
library(terra)
library(raster)
library(fasterize)
library(gdalUtilities)
library(readxl)


# templates
template_t=rast("./Templates/TemplateRasters/LV10m_10km.tif")
template_r=raster(template_t)

nulles=terra::subst(template_t,from=1,to=0)

# vienkāršā ainava
ainava_t=rast("./Rastri_10m/Ainava_vienk_mask.tif")
ainava_r=raster(ainava_t)
maska_meziem=ifel(ainava_t>600&ainava_t<700,1,NA)

# meži
mvr=st_read_parquet("./IevadesDati/MVR/nogabali_2024janv.parquet")
mvr$yes=1
skujkoki=c("1","3","13","14","15","22","23") # 7
saurlapji=c("4","6","8","9","19","20","21","32","35","50","68") # 11
platlapji=c("10","11","12","16","17","18","24","25","26","27","28","29",
            "61","62","63","64","65","66","67","69") # 20
mvr=mvr %>% 
  mutate(kraja_skujkoku=ifelse(s10 %in% skujkoki,v10,0)+
           ifelse(s11 %in% skujkoki,v11,0)+ifelse(s12 %in% skujkoki,v12,0)+
           ifelse(s13 %in% skujkoki,v13,0)+ifelse(s14 %in% skujkoki,v14,0),
         kraja_saurlapju=ifelse(s10 %in% saurlapji,v10,0)+
           ifelse(s11 %in% saurlapji,v11,0)+ifelse(s12 %in% saurlapji,v12,0)+
           ifelse(s13 %in% saurlapji,v13,0)+ifelse(s14 %in% saurlapji,v14,0),
         kraja_platlapju=ifelse(s10 %in% platlapji,v10,0)+
           ifelse(s11 %in% platlapji,v11,0)+ifelse(s12 %in% platlapji,v12,0)+
           ifelse(s13 %in% platlapji,v13,0)+ifelse(s14 %in% platlapji,v14,0)) %>% 
  mutate(kopeja_kraja=kraja_skujkoku+kraja_platlapju+kraja_saurlapju) %>% 
  mutate(tips=ifelse(kraja_skujkoku/kopeja_kraja>=0.75,"skujkoku",
                     ifelse(kraja_saurlapju/kopeja_kraja>=0.75,"saurlapju",
                            ifelse(kraja_platlapju/kopeja_kraja>0.5,"platlapju",
                                   "jauktu koku"))))
# Šaurlapju
nogabali=mvr %>% 
  filter(zkat=="10"&tips=="saurlapju") %>% 
  mutate(yes=672) # 1298549
rastrs_mvr=fasterize::fasterize(nogabali,template_r,field="yes")
rastrs_mvr=rast(rastrs_mvr)

pirmsmaskas_rastrs=ifel(!is.na(rastrs_mvr)&maska_meziem==1,672,0)
aizpildits=terra::cover(pirmsmaskas_rastrs,nulles)
pecmaskas_rastrs=mask(aizpildits,template_t,
                      filename="./Rastri_10m/Mezi_Saurlapju.tif",
                      overwrite=TRUE)
rm(list=ls())


# `./Rastri_10m/Mezi_JauktkokuJaunas.tif` ----


library(tidyverse)
library(sf)
library(arrow)
library(sfarrow)
library(terra)
library(raster)
library(fasterize)
library(gdalUtilities)
library(readxl)


# templates
template_t=rast("./Templates/TemplateRasters/LV10m_10km.tif")
template_r=raster(template_t)

nulles=terra::subst(template_t,from=1,to=0)

# vienkāršā ainava
ainava_t=rast("./Rastri_10m/Ainava_vienk_mask.tif")
ainava_r=raster(ainava_t)
maska_meziem=ifel(ainava_t>600&ainava_t<700,1,NA)

# meži
mvr=st_read_parquet("./IevadesDati/MVR/nogabali_2024janv.parquet")
mvr$yes=1
skujkoki=c("1","3","13","14","15","22","23") # 7
saurlapji=c("4","6","8","9","19","20","21","32","35","50","68") # 11
platlapji=c("10","11","12","16","17","18","24","25","26","27","28","29",
            "61","62","63","64","65","66","67","69") # 20
mvr=mvr %>% 
  mutate(kraja_skujkoku=ifelse(s10 %in% skujkoki,v10,0)+
           ifelse(s11 %in% skujkoki,v11,0)+ifelse(s12 %in% skujkoki,v12,0)+
           ifelse(s13 %in% skujkoki,v13,0)+ifelse(s14 %in% skujkoki,v14,0),
         kraja_saurlapju=ifelse(s10 %in% saurlapji,v10,0)+
           ifelse(s11 %in% saurlapji,v11,0)+ifelse(s12 %in% saurlapji,v12,0)+
           ifelse(s13 %in% saurlapji,v13,0)+ifelse(s14 %in% saurlapji,v14,0),
         kraja_platlapju=ifelse(s10 %in% platlapji,v10,0)+
           ifelse(s11 %in% platlapji,v11,0)+ifelse(s12 %in% platlapji,v12,0)+
           ifelse(s13 %in% platlapji,v13,0)+ifelse(s14 %in% platlapji,v14,0)) %>% 
  mutate(kopeja_kraja=kraja_skujkoku+kraja_platlapju+kraja_saurlapju) %>% 
  mutate(tips=ifelse(kraja_skujkoku/kopeja_kraja>=0.75,"skujkoku",
                     ifelse(kraja_saurlapju/kopeja_kraja>=0.75,"saurlapju",
                            ifelse(kraja_platlapju/kopeja_kraja>0.5,"platlapju",
                                   "jauktu koku"))))
# Jauktu koku jaunaudzes, vidēja vecuma un briestaudzes
nogabali=mvr %>% 
  filter(zkat=="10"&tips=="jauktu koku"&(vgr=="1"|vgr=="2"|vgr=="3")) %>% 
  mutate(yes=687) # 
rastrs_mvr=fasterize::fasterize(nogabali,template_r,field="yes")
rastrs_mvr=rast(rastrs_mvr)

pirmsmaskas_rastrs=ifel(!is.na(rastrs_mvr)&maska_meziem==1,687,0)
aizpildits=terra::cover(pirmsmaskas_rastrs,nulles)
pecmaskas_rastrs=mask(aizpildits,template_t,
                      filename="./Rastri_10m/Mezi_JauktkokuJaunas.tif",
                      overwrite=TRUE)

rm(list=ls())



# `./Rastri_10m/Ainava_MeziNetaksets.tif` ----


library(tidyverse)
library(sf)
library(arrow)
library(sfarrow)
library(terra)
library(raster)
library(fasterize)
library(gdalUtilities)
library(readxl)


# templates
template_t=rast("./Templates/TemplateRasters/LV10m_10km.tif")
template_r=raster(template_t)

nulles=terra::subst(template_t,from=1,to=0)

# vienkāršā ainava
ainava_t=rast("./Rastri_10m/Ainava_vienk_mask.tif")
ainava_r=raster(ainava_t)


# Netaksētās mežaudzes 
meziem=ifel(ainava_t==630,1,0)
nogabali=st_read_parquet("./IevadesDati/MVR/nogabali_2024janv.parquet")
nogabali=nogabali %>% 
  filter(zkat=="10") %>% 
  mutate(yes=1)

rastrs_mvr=fasterize::fasterize(nogabali,template_r,field="yes")
rastrs_mvr=rast(rastrs_mvr)

pirmsmaskas_rastrs=ifel(is.na(rastrs_mvr)&meziem==1,1,0)
aizpildits=terra::cover(pirmsmaskas_rastrs,nulles)
pecmaskas_rastrs=mask(aizpildits,template_t,
                      filename="./Rastri_10m/Ainava_MeziNetaksets.tif",
                      overwrite=TRUE)
rm(list=ls())


# `./Rastri_10m/Ainava_VasarnicasYN.tif` ----


library(tidyverse)
library(sf)
library(arrow)
library(sfarrow)
library(terra)
library(raster)
library(fasterize)
library(gdalUtilities)
library(readxl)


# templates
template_t=rast("./Templates/TemplateRasters/LV10m_10km.tif")
template_r=raster(template_t)

nulles=terra::subst(template_t,from=1,to=0)

# vienkāršā ainava
ainava_t=rast("./Rastri_10m/Ainava_vienk_mask.tif")
ainava_r=raster(ainava_t)

# Vasarnīcas un mazdārziņi
vasarnicas=ifel(ainava_t>=400&ainava_t<500,1,0)
vasarnicas=cover(vasarnicas,nulles,
                 filename="./Rastri_10m/Ainava_VasarnicasYN.tif",
                 overwrite=TRUE)
rm(list=ls())


# `./Rastri_10m/Malam_Apbuve_koki.tif` ----


library(tidyverse)
library(sf)
library(arrow)
library(sfarrow)
library(terra)
library(raster)
library(fasterize)
library(gdalUtilities)
library(readxl)


# templates
template_t=rast("./Templates/TemplateRasters/LV10m_10km.tif")
template_r=raster(template_t)

nulles=terra::subst(template_t,from=1,to=0)

# vienkāršā ainava
ainava_t=rast("./Rastri_10m/Ainava_vienk_mask.tif")
ainava_r=raster(ainava_t)

# Apbūves un koku malām
apbuve=ifel(ainava_t==500,500,NA)
koki=ifel(ainava_t>=630&ainava_t<=640,634,NA)
abi=merge(apbuve,koki,
          filename="./Rastri_10m/Malam_Apbuve_koki.tif",
          overwrite=TRUE)
rm(list=ls())

# `./Rastri_10m/Malam_Aramzemes_Y.tif` ----


library(tidyverse)
library(sf)
library(arrow)
library(sfarrow)
library(terra)
library(raster)
library(fasterize)
library(gdalUtilities)
library(readxl)


# templates
template_t=rast("./Templates/TemplateRasters/LV10m_10km.tif")
template_r=raster(template_t)

nulles=terra::subst(template_t,from=1,to=0)

# vienkāršā ainava
ainava_t=rast("./Rastri_10m/Ainava_vienk_mask.tif")
ainava_r=raster(ainava_t)

# aramzemju malām
aramzemes=ifel(ainava_t==310,310,0,
               filename="./Rastri_10m/Malam_Aramzemes_Y.tif",
               overwrite=TRUE)

rm(list=ls())

# `./Rastri_10m/Malam_LIZzemiekoki_Koki.tif` ----



library(tidyverse)
library(sf)
library(arrow)
library(sfarrow)
library(terra)
library(raster)
library(fasterize)
library(gdalUtilities)
library(readxl)


# templates
template_t=rast("./Templates/TemplateRasters/LV10m_10km.tif")
template_r=raster(template_t)

nulles=terra::subst(template_t,from=1,to=0)

# vienkāršā ainava
ainava_t=rast("./Rastri_10m/Ainava_vienk_mask.tif")
ainava_r=raster(ainava_t)

# LIZ, izcirtumu un jaunaudžu (<5m) malām ar kokiem >5m
viens=ifel((ainava_t>=300&ainava_t<400)|(ainava_t>=600&ainava_t<=620),1,NA)
koki=ifel(ainava_t>=630&ainava_t<=640,634,NA)
abi=merge(viens,koki,
          filename="./Rastri_10m/Malam_LIZzemiekoki_Koki.tif",
          overwrite=TRUE)
rm(list=ls())

