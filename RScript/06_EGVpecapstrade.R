# izveidoto slāņu harmonizēšana. 
# Tai nepieciešamie faili (bez pašiem slāņiem) ir šajā repozitorijā


# direktorijas ----

dir.create("./Rastri_100m/Proj/")
dir.create("./Rastri_100m/Scaled/")


# pakotnes -----

library(tidyverse)
library(terra)
library(readxl)
library(openxlsx)


# Beigu apstrāde ----


 
definicija=rast("./Rastri_100m/nulles_LV100m_10km.tif")

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
  fails=project(fails,definicija)
  maskets=mask(fails,definicija)
  iztrukumi=ifel(is.na(maskets)&!is.na(definicija),1,NA)
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

# Pārsaukšana, centrēšana un mērogošana, vērtību pierakstīšana

nosaukumiem=read_excel("./Rastri_100m/EGV_names.xlsx")

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
