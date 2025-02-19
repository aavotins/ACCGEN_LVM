# vides pārmaiņu apjoma raksturojums

# direktorijas ----

dir.create("./VidesParmainas/Parmainam/")

# pakotnes ----
library(terra)
library(sf)
library(tidyverse)
library(arrow)
library(sfarrow)
library(exactextractr)

# vadība ----

lapas_tikls=data.frame(fails_c=list.files("./Templates/TemplateGrids/lapas/"))
lapas_tikls$cels_grid=paste0("./Templates/TemplateGrids/lapas/",lapas_tikls$fails_c)
lapas_tikls$lapa=substr(lapas_tikls$fails,10,13)
lapas_radiusi=data.frame(fails_r=list.files("./Templates/TemplateGridPoints/lapas/"))
lapas_radiusi$cels_radiuss=paste0("./Templates/TemplateGridPoints/lapas/",lapas_radiusi$fails_r)
lapas_radiusi=separate(lapas_radiusi,fails_r,into=c("sakums","veids","lapa","beigas"),remove = FALSE)

lapas_r500=lapas_radiusi %>% 
  filter(veids=="r500") %>% 
  mutate(fails_r500=fails_r,
         cels_r500=cels_radiuss) %>% 
  dplyr::select(-sakums,-beigas,-fails_r,-cels_radiuss,-veids)

lapas_r1250=lapas_radiusi %>% 
  filter(veids=="r1250") %>% 
  mutate(fails_r1250=fails_r,
         cels_r1250=cels_radiuss) %>% 
  dplyr::select(-sakums,-beigas,-fails_r,-cels_radiuss,-veids)

lapas_r3000=lapas_radiusi %>% 
  filter(veids=="r3000") %>% 
  mutate(fails_r3000=fails_r,
         cels_r3000=cels_radiuss) %>% 
  dplyr::select(-sakums,-beigas,-fails_r,-cels_radiuss,-veids)

lapas=lapas_tikls %>% 
  left_join(lapas_r500) %>% 
  left_join(lapas_r1250) %>% 
  left_join(lapas_r3000)

## vides rastri ----

tcl=rast("./Rastri_10m/TreeCoverLossYear.tif")
tcl2=ifel(tcl<17,NA,tcl)
writeRaster(tcl2,"./VidesParmainas/KokuVainagiem.tif")

dw17=rast("./VidesParmainas/Parmainam/DW_2017_apraug.tif")
dw18=rast("./VidesParmainas/Parmainam/DW_2018_apraug.tif")
dw19=rast("./VidesParmainas/Parmainam/DW_2019_apraug.tif")
dw20=rast("./VidesParmainas/Parmainam/DW_2020_apraug.tif")
dw21=rast("./VidesParmainas/Parmainam/DW_2021_apraug.tif")
dw22=rast("./VidesParmainas/Parmainam/DW_2022_apraug.tif")
dw23=rast("./VidesParmainas/Parmainam/DW_2023_apraug.tif")

chDWa=ifel(dw17==dw18,0,1)
writeRaster(chDWa,"./VidesParmainas/chDWa.tif")
chDWb=ifel(dw18==dw19,0,1)
writeRaster(chDWb,"./VidesParmainas/chDWb.tif")
chDWc=ifel(dw19==dw20,0,1)
writeRaster(chDWc,"./VidesParmainas/chDWc.tif")
chDWd=ifel(dw20==dw21,0,1)
writeRaster(chDWd,"./VidesParmainas/chDWd.tif")
chDWe=ifel(dw21==dw22,0,1)
writeRaster(chDWe,"./VidesParmainas/chDWe.tif")
chDWf=ifel(dw22==dw23,0,1)
writeRaster(chDWf,"./VidesParmainas/chDWf.tif")
plot(chDWf)

# utility ----

darbiba <- function(raster, vector) {
  exact_extract(raster, vector, function(value, coverage_fraction) {
    data.frame(value = value,
               frac = coverage_fraction / sum(coverage_fraction, na.rm = TRUE)) %>%
      arrange(value) %>% 
      group_by(value) %>%
      summarize(freq = sum(frac, na.rm = TRUE), .groups = 'drop') %>%
      pivot_wider(names_from = 'value',
                  names_prefix = 'freq_',
                  values_from = 'freq')
  }) %>%
    mutate(across(starts_with('freq'), ~replace_na(., 0)))
}


# parmainas ----
lapas_tikls=data.frame(fails_c=list.files("./Templates/TemplateGrids/lapas/"))
lapas_tikls$cels_grid=paste0("./Templates/TemplateGrids/lapas/",lapas_tikls$fails_c)
lapas_tikls$lapa=substr(lapas_tikls$fails,10,13)
lapas_radiusi=data.frame(fails_r=list.files("./Templates/TemplateGridPoints/lapas/"))
lapas_radiusi$cels_radiuss=paste0("./Templates/TemplateGridPoints/lapas/",lapas_radiusi$fails_r)
lapas_radiusi=separate(lapas_radiusi,fails_r,into=c("sakums","veids","lapa","beigas"),remove = FALSE)

lapas_r500=lapas_radiusi %>% 
  filter(veids=="r500") %>% 
  mutate(fails_r500=fails_r,
         cels_r500=cels_radiuss) %>% 
  dplyr::select(-sakums,-beigas,-fails_r,-cels_radiuss,-veids)

lapas_r1250=lapas_radiusi %>% 
  filter(veids=="r1250") %>% 
  mutate(fails_r1250=fails_r,
         cels_r1250=cels_radiuss) %>% 
  dplyr::select(-sakums,-beigas,-fails_r,-cels_radiuss,-veids)

lapas_r3000=lapas_radiusi %>% 
  filter(veids=="r3000") %>% 
  mutate(fails_r3000=fails_r,
         cels_r3000=cels_radiuss) %>% 
  dplyr::select(-sakums,-beigas,-fails_r,-cels_radiuss,-veids)

lapas=lapas_tikls %>% 
  left_join(lapas_r500) %>% 
  left_join(lapas_r1250) %>% 
  left_join(lapas_r3000)


soli=levels(factor(lapas$lapa))

library(foreach)
library(doParallel)
cl <- makeCluster(12)
registerDoParallel(cl)

foreach(i = 1:length(soli)) %dopar% {
  library(terra)
  library(sf)
  library(tidyverse)
  library(arrow)
  library(sfarrow)
  library(exactextractr)
  
  darbiba <- function(raster, vector) {
    exact_extract(raster, vector, function(value, coverage_fraction) {
      data.frame(value = value,
                 frac = coverage_fraction / sum(coverage_fraction, na.rm = TRUE)) %>%
        arrange(value) %>% 
        group_by(value) %>%
        summarize(freq = sum(frac, na.rm = TRUE), .groups = 'drop') %>%
        pivot_wider(names_from = 'value',
                    names_prefix = 'freq_',
                    values_from = 'freq')
    }) %>%
      mutate(across(starts_with('freq'), ~replace_na(., 0)))
  }
  
  
  sakums=Sys.time()
  print(i)
  solis=soli[i]
  celi=lapas %>% filter(lapa==solis)
  
  sunas=st_read_parquet(celi$cels_grid)
  sunas=sunas %>% dplyr::select(id,yes,tks50km,X,Y)
  r500=st_read_parquet(celi$cels_r500)
  r500=r500 %>% dplyr::select(id,yes,tks50km,X,Y)
  r1250=st_read_parquet(celi$cels_r1250)
  r1250=r1250 %>% dplyr::select(id,yes,tks50km,X,Y)
  r3000=st_read_parquet(celi$cels_r3000)
  r3000=r3000 %>% dplyr::select(id,yes,tks50km,X,Y)
  
  telpa=st_as_sfc(st_bbox(r3000))
  telpa2=st_buffer(telpa,dist=1000)
  
  tcl2=rast("./VidesParmainas/KokuVainagiem.tif")
  tcl_telpa=crop(tcl2,telpa2)
  
  loss_cell=darbiba(tcl_telpa, sunas)
  sunas=cbind(sunas,loss_cell)
  loss_r500=darbiba(tcl_telpa, r500)
  r500=cbind(r500,loss_r500)
  loss_r1250=darbiba(tcl_telpa, r1250)
  r1250=cbind(r1250,loss_r1250)
  loss_r3000=darbiba(tcl_telpa, r3000)
  r3000=cbind(r3000,loss_r3000)
  
  chDWa=rast("./VidesParmainas/chDWa.tif")
  chDWb=rast("./VidesParmainas/chDWb.tif")
  chDWc=rast("./VidesParmainas/chDWc.tif")
  chDWd=rast("./VidesParmainas/chDWd.tif")
  chDWe=rast("./VidesParmainas/chDWe.tif")
  chDWf=rast("./VidesParmainas/chDWf.tif")
  
  names(chDWa)="DWchange_1718"
  names(chDWb)="DWchange_1819"
  names(chDWc)="DWchange_1920"
  names(chDWd)="DWchange_2021"
  names(chDWe)="DWchange_2122"
  names(chDWf)="DWchange_2223"
  
  mazs_chDWa=crop(chDWa,telpa2)
  mazs_chDWb=crop(chDWb,telpa2)
  mazs_chDWc=crop(chDWc,telpa2)
  mazs_chDWd=crop(chDWd,telpa2)
  mazs_chDWe=crop(chDWe,telpa2)
  mazs_chDWf=crop(chDWf,telpa2)
  
  
  mazas_DW=raster::stack(c(mazs_chDWa,mazs_chDWb,mazs_chDWc,mazs_chDWd,mazs_chDWe,mazs_chDWf))
  
  sunam=exact_extract(mazas_DW,sunas,"mean")
  r500am=exact_extract(mazas_DW,r500,"mean")
  r1250am=exact_extract(mazas_DW,r1250,"mean")
  r3000am=exact_extract(mazas_DW,r3000,"mean")
  
  sunas=cbind(sunas,sunam)
  r500=cbind(r500,r500am)
  r1250=cbind(r1250,r1250am)
  r3000=cbind(r3000,r3000am)
  
  
  st_write_parquet(sunas,celi$cels_grid)
  st_write_parquet(r500,celi$cels_r500)
  st_write_parquet(r1250,celi$cels_r1250)
  st_write_parquet(r3000,celi$cels_r3000)
  
  beigas=Sys.time()
  ilgums=beigas-sakums
  print(ilgums)
}
stopCluster(cl)

## apvienošana ----

pirmas_sunas=sfarrow::st_read_parquet(lapas$cels_grid[lapas$lapa==soli[1]])
pirmas_r500=sfarrow::st_read_parquet(lapas$cels_r500[lapas$lapa==soli[1]])
pirmas_r1250=sfarrow::st_read_parquet(lapas$cels_r1250[lapas$lapa==soli[1]])
pirmas_r3000=sfarrow::st_read_parquet(lapas$cels_r3000[lapas$lapa==soli[1]])


dati_c=pirmas_sunas
dati_r500=pirmas_r500
dati_r1250=pirmas_r1250
dati_r3000=pirmas_r3000

for(i in 2:length(soli)){
  print(i)
  sakums=Sys.time()
  solis=soli[i]
  nakosas_sunas=sfarrow::st_read_parquet(lapas$cels_grid[lapas$lapa==solis])
  nakosas_r500=sfarrow::st_read_parquet(lapas$cels_r500[lapas$lapa==solis])
  nakosas_r1250=sfarrow::st_read_parquet(lapas$cels_r1250[lapas$lapa==solis])
  nakosas_r3000=sfarrow::st_read_parquet(lapas$cels_r3000[lapas$lapa==solis])
  
  dati_c=bind_rows(dati_c,nakosas_sunas)
  dati_r500=bind_rows(dati_r500,nakosas_sunas)
  dati_r1250=bind_rows(dati_r1250,nakosas_sunas)
  dati_r3000=bind_rows(dati_r3000,nakosas_sunas)
  
  beigas=Sys.time()
  ilgums=beigas-sakums
  print(ilgums)
}

st_write_parquet(dati_c,"./VidesParmainas/VidesParmainas_suna.parquet")
st_write_parquet(dati_r500,"./VidesParmainas/VidesParmainas_r500.parquet")
st_write_parquet(dati_r1250,"./VidesParmainas/VidesParmainas_r1250.parquet")
st_write_parquet(dati_r3000,"./VidesParmainas/VidesParmainas_r3000.parquet")

dati_c2=dati_c %>% 
  mutate(cell_TCLNaN=freq_NaN,
         cell_TCL17=freq_17,
         cell_TCL18=freq_18,
         cell_TCL19=freq_19,
         cell_TCL20=freq_20,
         cell_TCL21=freq_21,
         cell_TCL22=freq_22,
         cell_TCL23=freq_23,
         cell_DWchange1718=mean.DWchange_1718,
         cell_DWchange1819=mean.DWchange_1819,
         cell_DWchange1920=mean.DWchange_1920,
         cell_DWchange2021=mean.DWchange_2021,
         cell_DWchange2122=mean.DWchange_2122,
         cell_DWchange2223=mean.DWchange_2223) %>% 
  dplyr::select(id,yes,tks50km,X,Y,
                cell_TCLNaN,cell_TCL17,cell_TCL18,cell_TCL19,cell_TCL20,cell_TCL21,cell_TCL22,cell_TCL23,
                cell_DWchange1718,cell_DWchange1819,cell_DWchange1920,cell_DWchange2021,cell_DWchange2122,cell_DWchange2223)

dati_r500a=data.frame(dati_r500) %>% 
  mutate(r500_TCLNaN=freq_NaN,
         r500_TCL17=freq_17,
         r500_TCL18=freq_18,
         r500_TCL19=freq_19,
         r500_TCL20=freq_20,
         r500_TCL21=freq_21,
         r500_TCL22=freq_22,
         r500_TCL23=freq_23,
         r500_DWchange1718=mean.DWchange_1718,
         r500_DWchange1819=mean.DWchange_1819,
         r500_DWchange1920=mean.DWchange_1920,
         r500_DWchange2021=mean.DWchange_2021,
         r500_DWchange2122=mean.DWchange_2122,
         r500_DWchange2223=mean.DWchange_2223) %>% 
  dplyr::select(id,
                r500_TCLNaN,r500_TCL17,r500_TCL18,r500_TCL19,r500_TCL20,r500_TCL21,r500_TCL22,r500_TCL23,
                r500_DWchange1718,r500_DWchange1819,r500_DWchange1920,r500_DWchange2021,r500_DWchange2122,r500_DWchange2223)

dati_r1250a=data.frame(dati_r1250) %>% 
  mutate(r1250_TCLNaN=freq_NaN,
         r1250_TCL17=freq_17,
         r1250_TCL18=freq_18,
         r1250_TCL19=freq_19,
         r1250_TCL20=freq_20,
         r1250_TCL21=freq_21,
         r1250_TCL22=freq_22,
         r1250_TCL23=freq_23,
         r1250_DWchange1718=mean.DWchange_1718,
         r1250_DWchange1819=mean.DWchange_1819,
         r1250_DWchange1920=mean.DWchange_1920,
         r1250_DWchange2021=mean.DWchange_2021,
         r1250_DWchange2122=mean.DWchange_2122,
         r1250_DWchange2223=mean.DWchange_2223) %>% 
  dplyr::select(id,
                r1250_TCLNaN,r1250_TCL17,r1250_TCL18,r1250_TCL19,r1250_TCL20,r1250_TCL21,r1250_TCL22,r1250_TCL23,
                r1250_DWchange1718,r1250_DWchange1819,r1250_DWchange1920,r1250_DWchange2021,r1250_DWchange2122,r1250_DWchange2223)


dati_r3000a=data.frame(dati_r3000) %>% 
  mutate(r3000_TCLNaN=freq_NaN,
         r3000_TCL17=freq_17,
         r3000_TCL18=freq_18,
         r3000_TCL19=freq_19,
         r3000_TCL20=freq_20,
         r3000_TCL21=freq_21,
         r3000_TCL22=freq_22,
         r3000_TCL23=freq_23,
         r3000_DWchange1718=mean.DWchange_1718,
         r3000_DWchange1819=mean.DWchange_1819,
         r3000_DWchange1920=mean.DWchange_1920,
         r3000_DWchange2021=mean.DWchange_2021,
         r3000_DWchange2122=mean.DWchange_2122,
         r3000_DWchange2223=mean.DWchange_2223) %>% 
  dplyr::select(id,
                r3000_TCLNaN,r3000_TCL17,r3000_TCL18,r3000_TCL19,r3000_TCL20,r3000_TCL21,r3000_TCL22,r3000_TCL23,
                r3000_DWchange1718,r3000_DWchange1819,r3000_DWchange1920,r3000_DWchange2021,r3000_DWchange2122,r3000_DWchange2223)


vides_parmainas=dati_c2 %>% 
  left_join(dati_r500a,by=c("id")) %>% 
  left_join(dati_r1250a,by=c("id")) %>% 
  left_join(dati_r3000a,by=c("id"))

st_write_parquet(vides_parmainas,"./VidesParmainas/VidesParmainas_visas.parquet")
