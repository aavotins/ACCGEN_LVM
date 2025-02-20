# vistu vanaga izplatības modelēšanai izmantojamo sugas klātbūtnes vietu atlase 
# ārēji harmonizētā datu kopā
# Apraksts: ./IevadesDati/Noverojumi/Readme_Noverojumi.md un projekta 2024. gada pārskatā.

# Novērojumi no dažādām datu bāzēm ir savstarpēji harmonizēti un apvienoti vienā 
# failā. 
# Paši novērojumi ir uzskatāmi par ierobežotas pieejamības informāciju, kuras 
# brīva publiskošana var traucēt populācijā notiekošajiem procesiem, piemēram, 
# olu un mazuļu zagļu dēļ. Tādēļ tie nav šajā repozitorijā iekļauti.


#Novērojumu atlase sugu izplatības modelēšanai veikta vairākos soļos:
# 1. solis: tikai analizējamo sugu atlase;
# 2. solis: novērojumi no 2017-01-01 līdz 2023-12-01, saglabāju tikai tos, kuri 
# attiecas uz ziņošanas laika periodu, kas nepārsniedz 10 dienas un nav mazāks par -1 dienu;
# 3. solis: dublieru izslēgšana - gan no ik viena datu avota, gan datu avotu kopas;
# 4. solis: savienošana ar Corine Land Cover klasēm acīmredzami nekorekto novērojumu izslēgšanai;
# 5. solis: novērojums veikts ligzdošanas sezonā;
# 6. solis: saistīšana ar vides pārmaiņām;
# 7. solis: papildkritērijs vistu vanagam - attālums no apdzīvotajām vietām;
# 8. solis: novērojumu apjoma un izvietojuma izvērtēšana, lēmumu modelēšanai pieņemšana.



# direktorijas ----

dir.create("./IevadesDati/Noverojumi/apkopoti/") # apkopoto novērojumu atrašanās vieta pirms atlases
dir.create("./SuguModeli/ApmacibuDati/")
dir.create("./SuguModeli/ApmacibuDati/TestingPresence/")
dir.create("./SuguModeli/ApmacibuDati/TrainingPresence/")
dir.create("./SuguModeli/ApmacibuDati/TrainingBackground/")
dir.create("./SuguModeli/ApmacibuDati/TestingBackground/")
dir.create("./SuguModeli/ApmacibuDati/IzvelesAtteli/")

dir.create("./IevadesDati/Noverojumi/apkopoti/AtteliIzvelei")


# pakotnes -----

library(tidyverse)
library(readxl)
library(openxlsx)
library(sf)
library(arrow)
library(sfarrow)
library(patchwork)
library(ggthemes)
library(ggtext)


# dati ----
dati=read_parquet("./IevadesDati/Noverojumi/apkopoti/apvienoti_putni.parquet")

# atlases kritēriji
kriteriji=read_excel("./IevadesDati/Noverojumi/apkopoti/NoverojumuAtlasei.xlsx")

# atlases gaita ----
## solis 1 ----
dati=dati %>% 
  mutate(solis1=ifelse(KODS == "ACCGEN",1,0))
dati2=dati %>% 
  filter(solis1==1)

## solis 2 ----
dati2=dati2 %>% 
  mutate(solis2=ifelse(datums_no>=as.Date("2017-01-01")&
                         (datums_lidz<=as.Date("2023-12-01")|is.na(datums_lidz))&
                         (nov_periods>=-1&nov_periods<=10),1,0))

## solis 3 ----
dati2=dati2 %>% 
  mutate(dublieriem=paste0(Name_key,"_",BreedCat,"_",datums_no,"_",tikls100,"_",tikls1000)) %>% 
  mutate(solis3=as.numeric(!duplicated(dublieriem))) %>% 
  dplyr::select(-dublieriem)


## solis 4 ----

clc=st_read_parquet("./IevadesDati/CLC/CLC_LV_2018.parquet")
maksligie=c("111","112","121","122","123","124","131","132","133","142")
atvertie=c("211","222","231","242","243","321","322","331")
koki=c("141","311","312","313","324","333")
mitraji=c("411","412")
udeni=c("511","512","523")
clc = clc %>% 
  mutate(clc_kopa=ifelse(code_18 %in% maksligie,"maksligie",
                         ifelse(code_18 %in% atvertie,"atvertie",
                                ifelse(code_18 %in% koki, "koki",
                                       ifelse(code_18 %in% mitraji,"mitraji",
                                              ifelse(code_18 %in% udeni, "udeni",NA)))))) %>% 
  dplyr::select(clc_kopa)
clc_lks=st_transform(clc,crs=3059)

dati_sf=dati %>% 
  st_as_sf(coords=c("lksX","lksY"),crs=3059) %>% 
  dplyr::select(novID,KODS) %>% 
  st_join(clc_lks)
dati_clc=data.frame(dati_sf) %>% 
  dplyr::select(novID,KODS,clc_kopa)

dati_clcKrit=dati_clc %>% 
  left_join(kriteriji,by=c("KODS"="kods"))
dati_clcKrit2=dati_clcKrit %>% 
  mutate(solis4=ifelse(clc_kopa=="maksligie"&!is.na(Maksligie),0,1),
         solis4=ifelse(clc_kopa=="atvertie"&!is.na(Atvertie),0,solis4),
         solis4=ifelse(clc_kopa=="koki"&!is.na(Koki),0,solis4),
         solis4=ifelse(clc_kopa=="mitraji"&!is.na(Mitraji),0,solis4),
         solis4=ifelse(clc_kopa=="udeni"&!is.na(Udeni),0,solis4),
         solis4=ifelse(is.na(clc_kopa)&is.na(solis4),0,solis4))


pievienot_solis4=dati_clcKrit2 %>% 
  dplyr::select(novID,clc_kopa,solis4)

dati2=dati2 %>% 
  left_join(pievienot_solis4,by="novID") 



## solis 5 ----
sezonai=kriteriji %>% 
  dplyr::select(kods,Ligzd_sakums,Ligzd_beigas)
dati2=dati2 %>% 
  left_join(sezonai,by=c("KODS"="kods"))
dati2=dati2 %>% 
  mutate(sakums_DoY=lubridate::yday(datums_no),
         beigas_DoY=ifelse(!is.na(datums_lidz),lubridate::yday(datums_lidz),lubridate::yday(datums_no))) %>% 
  mutate(solis5=ifelse(sakums_DoY>=Ligzd_sakums&
                         sakums_DoY<=Ligzd_beigas&
                         beigas_DoY>=Ligzd_sakums&
                         beigas_DoY<=Ligzd_beigas,1,0))

## solis 6 ----

## Saistīšana ar vides pārmaiņām

radiusiem=kriteriji %>% 
  dplyr::select(kods,radiuss)
dati2=dati2 %>% 
  left_join(radiusiem,by=c("KODS"="kods"))
vides_parmainas=st_read_parquet("./VidesParmainas/VidesParmainas_visas.parquet")
vides_parmainas=data.frame(vides_parmainas) %>% 
  dplyr::select(-geom)
datiem=dati2 %>% 
  dplyr::select(tikls100,novID,gads,radiuss)
datiem=datiem %>% 
  left_join(vides_parmainas,by=c("tikls100"="id"))

## solis 6 r3000 

datiem_r3000=datiem %>% 
  filter(radiuss==3000)

datiem_r3000=datiem_r3000 %>% 
  rowwise() %>% 
  mutate(cell_TCL=ifelse(gads==2017,
                         sum(c(cell_TCL17,cell_TCL18,cell_TCL19,cell_TCL20,cell_TCL21,cell_TCL22,cell_TCL23),
                             na.rm=TRUE),
                         NA)) %>% 
  mutate(cell_TCL=ifelse(gads==2018,
                         sum(c(cell_TCL18,cell_TCL19,cell_TCL20,cell_TCL21,cell_TCL22,cell_TCL23),
                             na.rm=TRUE),
                         cell_TCL)) %>% 
  mutate(cell_TCL=ifelse(gads==2019,
                         sum(c(cell_TCL19,cell_TCL20,cell_TCL21,cell_TCL22,cell_TCL23),
                             na.rm=TRUE),
                         cell_TCL)) %>% 
  mutate(cell_TCL=ifelse(gads==2020,
                         sum(c(cell_TCL20,cell_TCL21,cell_TCL22,cell_TCL23),
                             na.rm=TRUE),
                         cell_TCL)) %>% 
  mutate(cell_TCL=ifelse(gads==2021,
                         sum(c(cell_TCL21,cell_TCL22,cell_TCL23),
                             na.rm=TRUE),
                         cell_TCL)) %>% 
  mutate(cell_TCL=ifelse(gads==2022,
                         sum(c(cell_TCL22,cell_TCL23),
                             na.rm=TRUE),
                         cell_TCL)) %>% 
  mutate(cell_TCL=ifelse(gads==2023,
                         sum(c(cell_TCL23),
                             na.rm=TRUE),
                         cell_TCL)) %>% 
  mutate(hr_TCL=ifelse(gads==2017,
                       sum(c(r3000_TCL17,r3000_TCL18,r3000_TCL19,r3000_TCL20,r3000_TCL21,r3000_TCL22,r3000_TCL23),
                           na.rm=TRUE),
                       NA)) %>% 
  mutate(hr_TCL=ifelse(gads==2018,
                       sum(c(r3000_TCL18,r3000_TCL19,r3000_TCL20,r3000_TCL21,r3000_TCL22,r3000_TCL23),
                           na.rm=TRUE),
                       hr_TCL)) %>% 
  mutate(hr_TCL=ifelse(gads==2019,
                       sum(c(r3000_TCL19,r3000_TCL20,r3000_TCL21,r3000_TCL22,r3000_TCL23),
                           na.rm=TRUE),
                       hr_TCL)) %>% 
  mutate(hr_TCL=ifelse(gads==2020,
                       sum(c(r3000_TCL20,r3000_TCL21,r3000_TCL22,r3000_TCL23),
                           na.rm=TRUE),
                       hr_TCL)) %>% 
  mutate(hr_TCL=ifelse(gads==2021,
                       sum(c(r3000_TCL21,r3000_TCL22,r3000_TCL23),
                           na.rm=TRUE),
                       hr_TCL)) %>% 
  mutate(hr_TCL=ifelse(gads==2022,
                       sum(c(r3000_TCL22,r3000_TCL23),
                           na.rm=TRUE),
                       hr_TCL)) %>% 
  mutate(hr_TCL=ifelse(gads==2023,
                       sum(c(r3000_TCL23),
                           na.rm=TRUE),
                       hr_TCL)) %>% 
  mutate(cell_DWchange=ifelse(gads==2017,
                              sum(c(cell_DWchange1718,cell_DWchange1819,cell_DWchange1920,cell_DWchange2021,
                                    cell_DWchange2122,cell_DWchange2223),
                                  na.rm=TRUE),
                              NA)) %>% 
  mutate(cell_DWchange=ifelse(gads==2018,
                              sum(c(cell_DWchange1819,cell_DWchange1920,cell_DWchange2021,
                                    cell_DWchange2122,cell_DWchange2223),
                                  na.rm=TRUE),
                              cell_DWchange)) %>% 
  mutate(cell_DWchange=ifelse(gads==2019,
                              sum(c(cell_DWchange1920,cell_DWchange2021,
                                    cell_DWchange2122,cell_DWchange2223),
                                  na.rm=TRUE),
                              cell_DWchange)) %>% 
  mutate(cell_DWchange=ifelse(gads==2020,
                              sum(c(cell_DWchange2021,
                                    cell_DWchange2122,cell_DWchange2223),
                                  na.rm=TRUE),
                              cell_DWchange)) %>% 
  mutate(cell_DWchange=ifelse(gads==2021,
                              sum(c(cell_DWchange2122,cell_DWchange2223),
                                  na.rm=TRUE),
                              cell_DWchange)) %>% 
  mutate(cell_DWchange=ifelse(gads==2022,
                              sum(c(cell_DWchange2223),
                                  na.rm=TRUE),
                              ifelse(is.na(cell_DWchange),1,cell_DWchange))) %>%
  mutate(cell_DWchange=ifelse(gads==2023,0,cell_DWchange)) %>% 
  mutate(hr_DWchange=ifelse(gads==2017,
                            sum(c(r3000_DWchange1718,r3000_DWchange1819,r3000_DWchange1920,r3000_DWchange2021,
                                  r3000_DWchange2122,r3000_DWchange2223),
                                na.rm=TRUE),
                            NA)) %>% 
  mutate(hr_DWchange=ifelse(gads==2018,
                            sum(c(r3000_DWchange1819,r3000_DWchange1920,r3000_DWchange2021,
                                  r3000_DWchange2122,r3000_DWchange2223),
                                na.rm=TRUE),
                            hr_DWchange)) %>% 
  mutate(hr_DWchange=ifelse(gads==2019,
                            sum(c(r3000_DWchange1920,r3000_DWchange2021,
                                  r3000_DWchange2122,r3000_DWchange2223),
                                na.rm=TRUE),
                            hr_DWchange)) %>% 
  mutate(hr_DWchange=ifelse(gads==2020,
                            sum(c(r3000_DWchange2021,
                                  r3000_DWchange2122,r3000_DWchange2223),
                                na.rm=TRUE),
                            hr_DWchange)) %>% 
  mutate(hr_DWchange=ifelse(gads==2021,
                            sum(c(r3000_DWchange2122,r3000_DWchange2223),
                                na.rm=TRUE),
                            hr_DWchange)) %>% 
  mutate(hr_DWchange=ifelse(gads==2022,
                            sum(c(r3000_DWchange2223),
                                na.rm=TRUE),
                            ifelse(is.na(hr_DWchange),1,hr_DWchange))) %>%
  mutate(hr_DWchange=ifelse(gads==2023,0,hr_DWchange)) %>% 
  mutate(solis6=ifelse(cell_TCL<0.1&cell_DWchange<0.1&hr_TCL<0.1&hr_DWchange<0.1,1,0))
table(datiem_r3000$solis6,useNA="always")
table(datiem_r3000$solis6,datiem_r3000$gads,useNA="always")

datiem_r3000=datiem_r3000 %>% 
  dplyr::select(novID,cell_TCL,hr_TCL,cell_DWchange,hr_DWchange,solis6)

## apvienošana 

datiem_videsparmainas=datiem_r3000

dati2=dati2 %>% 
  left_join(datiem_videsparmainas,by="novID")


## solis 7 ----
accgen=dati2 %>% 
  filter(KODS=="ACCGEN") %>% 
  dplyr::select(novID,lksX,lksY)
clc_maksligie=clc_lks %>% 
  filter(clc_kopa=="maksligie")
accgen_sf=accgen %>% 
  st_as_sf(coords=c("lksX","lksY"),crs=3059)
a=st_distance(accgen_sf,clc_maksligie)
b=apply(a,1,min)
accgen$dist_clc1=b
accgen$solis7=ifelse(accgen$dist_clc1<3000,0,1)
table(accgen$solis7,useNA="always")
accgen=accgen %>% 
  dplyr::select(novID,dist_clc1,solis7)
dati2=dati2 %>% 
  dplyr::select(-dist_clc1.x,-dist_clc1.y,-"1",-solis7.x,-solis7.y)
dati2=dati2 %>% 
  left_join(accgen,by="novID")
dati2=dati2 %>% 
  mutate(solis7=ifelse(is.na(solis7),1,solis7))


## solis 8 ----

dati_atlaseB=dati2 %>% 
  filter(solis1==1) %>% 
  filter(solis2==1) %>% 
  filter(solis3==1) %>% 
  filter(solis4==1) %>% 
  filter(solis5==1) %>% 
  filter(solis6==1) %>% 
  filter(solis7==1)
dati_novB=dati_atlaseB %>% 
  group_by(KODS) %>% 
  summarise(Nov_BCD=n())

dati_atlaseC=dati2 %>% 
  filter(solis1==1) %>% 
  filter(solis2==1) %>% 
  filter(solis3==1) %>% 
  filter(solis4==1) %>% 
  filter(solis5==1) %>% 
  filter(solis6==1) %>% 
  filter(solis7==1) %>% 
  filter(BreedCode<=2)
dati_novC=dati_atlaseC %>% 
  group_by(KODS) %>% 
  summarise(Nov_CD=n())


dati_atlaseD=dati2 %>% 
  filter(solis1==1) %>% 
  filter(solis2==1) %>% 
  filter(solis3==1) %>% 
  filter(solis4==1) %>% 
  filter(solis5==1) %>% 
  filter(solis6==1) %>% 
  filter(solis7==1) %>% 
  filter(BreedCode==1)
dati_novD=dati_atlaseD %>% 
  group_by(KODS) %>% 
  summarise(Nov_D=n())

unikalajiemB_1km=dati_atlaseB %>% 
  group_by(KODS) %>% 
  filter(!duplicated(tikls1000)) %>% 
  summarise(BCD_1km=n())
unikalajiemC_1km=dati_atlaseC %>% 
  group_by(KODS) %>% 
  filter(!duplicated(tikls1000)) %>% 
  summarise(CD_1km=n())
unikalajiemD_1km=dati_atlaseD %>% 
  group_by(KODS) %>% 
  filter(!duplicated(tikls1000)) %>% 
  summarise(D_1km=n())

unikalajiemB_100=dati_atlaseB %>% 
  group_by(KODS) %>% 
  filter(!duplicated(tikls100)) %>% 
  group_by(KODS) %>% 
  summarise(BCD_100m=n())
unikalajiemC_100=dati_atlaseC %>% 
  group_by(KODS) %>% 
  filter(!duplicated(tikls100)) %>% 
  summarise(CD_100m=n())
unikalajiemD_100=dati_atlaseD %>% 
  group_by(KODS) %>% 
  filter(!duplicated(tikls100)) %>% 
  summarise(D_100m=n())

izvelei_tab=dati_novB %>% 
  left_join(unikalajiemB_1km,by="KODS") %>% 
  left_join(unikalajiemB_100,by="KODS") %>% 
  left_join(dati_novC,by="KODS") %>% 
  left_join(unikalajiemC_1km,by="KODS") %>% 
  left_join(unikalajiemC_100,by="KODS") %>% 
  left_join(dati_novD,by="KODS") %>% 
  left_join(unikalajiemD_1km,by="KODS") %>% 
  left_join(unikalajiemD_100,by="KODS")

radiusi=kriteriji %>% 
  dplyr::select(kods,radiuss)

izvelei_tab_r=izvelei_tab %>% 
  left_join(radiusi,by=c("KODS"="kods"))

write.xlsx(izvelei_tab_r,"./IevadesDati/Noverojumi/apkopoti/tabula_izvelei.xlsx")

dati2_sf=dati2 %>% 
  st_as_sf(coords=c("lksX","lksY"),crs=3059)

dati_atlaseB_sf=dati_atlaseB %>% 
  st_as_sf(coords=c("lksX","lksY"),crs=3059)
dati_atlaseC_sf=dati_atlaseC %>% 
  st_as_sf(coords=c("lksX","lksY"),crs=3059)
dati_atlaseD_sf=dati_atlaseD %>% 
  st_as_sf(coords=c("lksX","lksY"),crs=3059)


unikalieB_1km=dati_atlaseB_sf %>% 
  group_by(KODS) %>% 
  filter(!duplicated(tikls1000)) %>% 
  ungroup()
unikalieC_1km=dati_atlaseC_sf %>% 
  group_by(KODS) %>% 
  filter(!duplicated(tikls1000)) %>% 
  ungroup()
unikalieD_1km=dati_atlaseD_sf %>% 
  group_by(KODS) %>% 
  filter(!duplicated(tikls1000)) %>% 
  ungroup()

unikalieB_100=dati_atlaseB_sf %>% 
  group_by(KODS) %>% 
  filter(!duplicated(tikls100)) %>% 
  ungroup()
unikalieC_100=dati_atlaseC_sf %>% 
  group_by(KODS) %>% 
  filter(!duplicated(tikls100)) %>% 
  ungroup()
unikalieD_100=dati_atlaseD_sf %>% 
  group_by(KODS) %>% 
  filter(!duplicated(tikls100)) %>% 
  ungroup()

admin=read_sf("./Templates/administrativas_teritorijas_2021/Administrativas_teritorijas_2021.shp")

kodi=levels(factor(dati2$KODS))

### soli

beigam=dati2 %>% 
  dplyr::select(KODS,solis1,solis2,solis3,solis4,solis5,solis6,solis7)

solis1=beigam %>% 
  mutate(solis="solis 1") %>% 
  group_by(KODS,solis) %>% 
  summarise(izmest=0,
            saglabat=n())

solis2=beigam %>% 
  mutate(solis="solis 2") %>% 
  group_by(KODS,solis) %>% 
  summarise(izmest=sum(ifelse(solis2!=1,1,0),na.rm=TRUE),
            saglabat=sum(ifelse(solis2==1,1,0),na.rm=TRUE))


solis3=beigam %>% 
  filter(solis2==1) %>% 
  mutate(solis="solis 3") %>% 
  group_by(KODS,solis) %>% 
  summarise(izmest=sum(ifelse(solis3!=1,1,0),na.rm=TRUE),
            saglabat=sum(ifelse(solis3==1,1,0),na.rm=TRUE))

solis4=beigam %>% 
  filter(solis2==1&solis3==1) %>% 
  mutate(solis="solis 4") %>% 
  group_by(KODS,solis) %>% 
  summarise(izmest=sum(ifelse(solis4!=1,1,0),na.rm=TRUE),
            saglabat=sum(ifelse(solis4==1|is.na(solis4),1,0),na.rm=TRUE))

solis5=beigam %>% 
  filter(solis2==1&solis3==1&solis4==1) %>% 
  mutate(solis = "solis 5") %>% 
  group_by(KODS,solis) %>% 
  summarise(izmest=sum(ifelse(solis5!=1,1,0),na.rm=TRUE),
            saglabat=sum(ifelse(solis5==1,1,0),na.rm=TRUE))

solis6=beigam %>% 
  filter(solis2==1&solis3==1&solis4==1&solis5==1) %>% 
  mutate(solis = "solis 6") %>% 
  group_by(KODS,solis) %>% 
  summarise(izmest=sum(ifelse(solis6!=1,1,0),na.rm=TRUE),
            saglabat=sum(ifelse(solis6==1,1,0),na.rm=TRUE))

solis7=beigam %>% 
  filter(solis2==1&solis3==1&solis4==1&solis5==1&solis6==1) %>% 
  mutate(solis = "solis 7") %>% 
  group_by(KODS,solis) %>% 
  summarise(izmest=sum(ifelse(solis7!=1,1,0),na.rm=TRUE),
            saglabat=sum(ifelse(solis7==1,1,0),na.rm=TRUE))

soli=bind_rows(solis1,solis2,solis3,solis4,solis5,solis6,solis7)
soli2=soli %>% 
  ungroup() %>% 
  mutate(soli_seciba=factor(solis,ordered = TRUE,
                            levels=c("solis 1","solis 2","solis 3","solis 4",
                                     "solis 5","solis 6","solis 7","solis 8"))) %>% 
  pivot_longer(cols=saglabat:izmest,names_to = "darbiba",values_to = "skaits")



### abi atteli


suga="ACCGEN"

visi=dati2_sf %>% 
  filter(KODS==suga)
skaits_visi=nrow(visi)
BCD_1km=unikalieB_1km %>% 
  filter(KODS==suga)
skaits_BCD1km=nrow(BCD_1km)
BCD_100=unikalieB_100 %>% 
  filter(KODS==suga)
skaits_BCD100=nrow(BCD_100)
CD_1km=unikalieC_1km %>% 
  filter(KODS==suga)
skaits_CD1km=nrow(CD_1km)
CD_100=unikalieC_100 %>% 
  filter(KODS==suga)
skaits_CD100=nrow(CD_100)
D_1km=unikalieD_1km %>% 
  filter(KODS==suga)
skaits_D1km=nrow(D_1km)
D_100=unikalieD_100 %>% 
  filter(KODS==suga)
skaits_D100=nrow(D_100)


pic1=ggplot()+
  theme_map()+
  geom_sf(data=admin)+
  geom_sf(data=visi,col="grey20",alpha=0.5)+
  labs(subtitle=paste0("Visi pirms atlases (n=",skaits_visi,")"))

pic2=ggplot()+
  theme_map()+
  geom_sf(data=admin)+
  geom_sf(data=BCD_1km,col="red")+
  geom_sf(data=BCD_100,col="black",pch=3,size=3)+
  labs(subtitle=paste0("Telpiski unikālie BCD pēc atlases (N=",
                       skaits_BCD1km,", n=",skaits_BCD100,")"))

pic3=ggplot()+
  theme_map()+
  geom_sf(data=admin)+
  geom_sf(data=CD_1km,col="red")+
  geom_sf(data=CD_100,col="black",pch=3,size=3)+
  labs(subtitle=paste0("Telpiski unikālie CD pēc atlases (N=",
                       skaits_CD1km,", n=",skaits_CD100,")"))

pic4=ggplot()+
  theme_map()+
  geom_sf(data=admin)+
  geom_sf(data=D_1km,col="red")+
  geom_sf(data=D_100,col="black",pch=3,size=3)+
  labs(subtitle=paste0("Telpiski unikālie D pēc atlases (N=",
                       skaits_D1km,", n=",skaits_D100,")"))

solu_dati=soli2 %>% 
  filter(KODS==suga)

stabini=ggplot(solu_dati,aes(soli_seciba,skaits,fill=darbiba))+
  geom_col()+
  theme_bw()+
  scale_fill_manual("Atlases lēmums",
                    values=c("grey","darkgreen"),
                    labels=c("izmest","saglabāt"))+
  labs(x="",y="Novērojumu skaits")+
  theme(legend.position = "bottom")+
  labs(title=suga,
       subtitle="Novērojumu atlases gaita")

dizains <- c(
  area(2, 1, 5, 5),
  area(1, 6, 3, 11),
  area(1, 12, 3, 17),
  area(4, 6, 6, 11),
  area(4, 12, 6, 17)
)
attelsX=stabini+pic1+pic2+pic3+pic4+plot_layout(design=dizains)
faila_nosaukumam=paste0("./IevadesDati/Noverojumi/apkopoti/AtteliIzvelei/ObsSelection_",suga,".png")
ggsave(attelsX,filename=faila_nosaukumam,device="png",width = 1500,height = 750,units="px",dpi=100)



### lēmums

lemums=read_excel("./IevadesDati/Noverojumi/apkopoti/tabula_izvelei_early.xlsx")
lemums2=lemums %>% 
  dplyr::select(KODS,izvele1)

dati2=dati2 %>% 
  left_join(lemums2,by="KODS")
table(lemums2$izvele1,useNA = "always")
table(dati2$BreedCat,dati2$BreedCode,useNA = "always")

dati2=dati2 %>% 
  mutate(solis8=case_when(izvele1=="pārāk maz"~0,
                          izvele1=="BCD"&BreedCode<=3~1,
                          izvele1=="CD"&BreedCode<=2~1,
                          izvele1=="D"&BreedCode==1~1),
         solis8=ifelse(is.na(solis8),0,solis8))
table(dati2$solis8,useNA="always")



beigam=dati2 %>% 
  dplyr::select(KODS,solis1,solis2,solis3,solis4,solis5,solis6,solis7,solis8)

solis1=beigam %>% 
  mutate(solis="solis 1") %>% 
  group_by(KODS,solis) %>% 
  summarise(izmest=0,
            saglabat=n())

solis2=beigam %>% 
  mutate(solis="solis 2") %>% 
  group_by(KODS,solis) %>% 
  summarise(izmest=sum(ifelse(solis2!=1,1,0),na.rm=TRUE),
            saglabat=sum(ifelse(solis2==1,1,0),na.rm=TRUE))


solis3=beigam %>% 
  filter(solis2==1) %>% 
  mutate(solis="solis 3") %>% 
  group_by(KODS,solis) %>% 
  summarise(izmest=sum(ifelse(solis3!=1,1,0),na.rm=TRUE),
            saglabat=sum(ifelse(solis3==1,1,0),na.rm=TRUE))

solis4=beigam %>% 
  filter(solis2==1&solis3==1) %>% 
  mutate(solis="solis 4") %>% 
  group_by(KODS,solis) %>% 
  summarise(izmest=sum(ifelse(solis4!=1,1,0),na.rm=TRUE),
            saglabat=sum(ifelse(solis4==1|is.na(solis4),1,0),na.rm=TRUE))

solis5=beigam %>% 
  filter(solis2==1&solis3==1&solis4==1) %>% 
  mutate(solis = "solis 5") %>% 
  group_by(KODS,solis) %>% 
  summarise(izmest=sum(ifelse(solis5!=1,1,0),na.rm=TRUE),
            saglabat=sum(ifelse(solis5==1,1,0),na.rm=TRUE))

solis6=beigam %>% 
  filter(solis2==1&solis3==1&solis4==1&solis5==1) %>% 
  mutate(solis = "solis 6") %>% 
  group_by(KODS,solis) %>% 
  summarise(izmest=sum(ifelse(solis6!=1,1,0),na.rm=TRUE),
            saglabat=sum(ifelse(solis6==1,1,0),na.rm=TRUE))

solis7=beigam %>% 
  filter(solis2==1&solis3==1&solis4==1&solis5==1&solis6==1) %>% 
  mutate(solis = "solis 7") %>% 
  group_by(KODS,solis) %>% 
  summarise(izmest=sum(ifelse(solis7!=1,1,0),na.rm=TRUE),
            saglabat=sum(ifelse(solis7==1,1,0),na.rm=TRUE))

solis8=beigam %>% 
  filter(solis2==1&solis3==1&solis4==1&solis5==1&solis6==1&solis7==1) %>% 
  mutate(solis = "solis 8") %>% 
  group_by(KODS,solis) %>% 
  summarise(izmest=sum(ifelse(solis8!=1,1,0),na.rm=TRUE),
            saglabat=sum(ifelse(solis8==1,1,0),na.rm=TRUE))


soli=bind_rows(solis1,solis2,solis3,solis4,solis5,solis6,solis7,solis8)

soli2=soli %>% 
  ungroup() %>% 
  mutate(soli_seciba=factor(solis,ordered = TRUE,
                            levels=c("solis 1","solis 2","solis 3","solis 4",
                                     "solis 5","solis 6","solis 7","solis 8"))) %>% 
  pivot_longer(cols=saglabat:izmest,names_to = "darbiba",values_to = "skaits")


write_parquet(dati2,"./IevadesDati/Noverojumi/apkopoti/putnu_dati2_solis8.parquet")
write_parquet(soli2,"./IevadesDati/Noverojumi/apkopoti/putnu_dati2_AtlasesGaita.parquet")


## neatkarīgie testa dati ----

ACCGEN_test=read_parquet("./IevadesDati/Noverojumi/apkopoti/TestaKopa_1km_2024.parquet")

clc_maksligie=clc_lks %>% 
  filter(clc_kopa=="maksligie")
ACCGEN_test_sf=ACCGEN_test %>% 
  st_as_sf(coords=c("lksX","lksY"),crs=3059)
ta=st_distance(ACCGEN_test_sf,clc_maksligie)
tb=apply(ta,1,min)
ACCGEN_test$dist_clc1=tb
ACCGEN_test$metamie=ifelse(ACCGEN_test$dist_clc1<1500,0,1)


# Modelēšanas datu saglabāšana un procesa vizualizēšana ----

## Testa un treniņdati ----

### Testa dati

clc_maksligie=clc_lks %>% 
  filter(clc_kopa=="maksligie")
ACCGEN_test_sf=ACCGEN_test %>% 
  st_as_sf(coords=c("lksX","lksY"),crs=3059)
ta=st_distance(ACCGEN_test_sf,clc_maksligie)
tb=apply(ta,1,min)
ACCGEN_test$dist_clc1=tb
ACCGEN_test$metamie=ifelse(ACCGEN_test$dist_clc1<1500,0,1)

ACCGEN_test=ACCGEN_test %>% 
  filter(!duplicated(tikls1000)) %>% 
  mutate(x=lksX,
         y=lksY) %>% 
  dplyr::select(KODS,Name_key,x,y,tikls100,tikls1000)
write_parquet(ACCGEN_test,"./SuguModeli/ApmacibuDati/TestingPresence/TestPres_ACCGEN.parquet")


### Apmacibu dati

ACCGEN_train=dati2 %>% 
  filter(KODS=="ACCGEN") %>% 
  filter(solis1==1,solis2==1,solis3==1,solis4==1,
         solis5==1,solis6==1,solis7==1,solis8==1) %>% 
  filter(!duplicated(tikls1000)) %>% 
  mutate(x=lksX,
         y=lksY) %>% 
  dplyr::select(KODS,Name_key,x,y,tikls100,tikls1000)
write_parquet(ACCGEN_train,"./SuguModeli/ApmacibuDati/TrainingPresence/TrainPres_ACCGEN.parquet")


### Background

egv_telpa=terra::rast("./Rastri_100m/nulles_LV100m_10km.tif")
vides_fons <- terra::spatSample(egv_telpa, size = 27500, na.rm = TRUE, 
                                values = FALSE, xy = TRUE) |> as.data.frame()
vides_fons$rinda=rownames(vides_fons)

fons_test=vides_fons %>% 
  sample_n(7500)

fons_trenins=vides_fons %>% 
  filter(!(rinda %in% fons_test$rinda)) %>% 
  dplyr::select(-rinda)
write_parquet(fons_trenins,"./SuguModeli/ApmacibuDati/TrainingBackground/TrainBg_ACCGEN.parquet")

fons_test=fons_test %>% 
  dplyr::select(-rinda)
write_parquet(fons_test,"./SuguModeli/ApmacibuDati/TestingBackground/TestBg_ACCGEN.parquet")



## Beigu attēls ----

dati2=read_parquet("./IevadesDati/Noverojumi/apkopoti/putnu_dati2_solis8.parquet")
dati2_sf=dati2 %>% 
  st_as_sf(coords=c("lksX","lksY"),crs=3059)


soli2=read_parquet("./IevadesDati/Noverojumi/apkopoti/putnu_dati2_AtlasesGaita.parquet")



dati_atlaseB=dati2 %>% 
  filter(solis1==1) %>% 
  filter(solis2==1) %>% 
  filter(solis3==1) %>% 
  filter(solis4==1) %>% 
  filter(solis5==1) %>% 
  filter(solis6==1) %>% 
  filter(solis7==1)
dati_novB=dati_atlaseB %>% 
  group_by(KODS) %>% 
  summarise(Nov_BCD=n())

dati_atlaseC=dati2 %>% 
  filter(solis1==1) %>% 
  filter(solis2==1) %>% 
  filter(solis3==1) %>% 
  filter(solis4==1) %>% 
  filter(solis5==1) %>% 
  filter(solis6==1) %>% 
  filter(solis7==1) %>% 
  filter(BreedCode<=2)
dati_novC=dati_atlaseC %>% 
  group_by(KODS) %>% 
  summarise(Nov_CD=n())


dati_atlaseD=dati2 %>% 
  filter(solis1==1) %>% 
  filter(solis2==1) %>% 
  filter(solis3==1) %>% 
  filter(solis4==1) %>% 
  filter(solis5==1) %>% 
  filter(solis6==1) %>% 
  filter(solis7==1) %>% 
  filter(BreedCode==1)
dati_novD=dati_atlaseD %>% 
  group_by(KODS) %>% 
  summarise(Nov_D=n())

unikalajiemB_1km=dati_atlaseB %>% 
  group_by(KODS) %>% 
  filter(!duplicated(tikls1000)) %>% 
  summarise(BCD_1km=n())
unikalajiemC_1km=dati_atlaseC %>% 
  group_by(KODS) %>% 
  filter(!duplicated(tikls1000)) %>% 
  summarise(CD_1km=n())
unikalajiemD_1km=dati_atlaseD %>% 
  group_by(KODS) %>% 
  filter(!duplicated(tikls1000)) %>% 
  summarise(D_1km=n())

unikalajiemB_100=dati_atlaseB %>% 
  group_by(KODS) %>% 
  filter(!duplicated(tikls100)) %>% 
  group_by(KODS) %>% 
  summarise(BCD_100m=n())
unikalajiemC_100=dati_atlaseC %>% 
  group_by(KODS) %>% 
  filter(!duplicated(tikls100)) %>% 
  summarise(CD_100m=n())
unikalajiemD_100=dati_atlaseD %>% 
  group_by(KODS) %>% 
  filter(!duplicated(tikls100)) %>% 
  summarise(D_100m=n())


dati_atlaseB_sf=dati_atlaseB %>% 
  st_as_sf(coords=c("lksX","lksY"),crs=3059)
dati_atlaseC_sf=dati_atlaseC %>% 
  st_as_sf(coords=c("lksX","lksY"),crs=3059)
dati_atlaseD_sf=dati_atlaseD %>% 
  st_as_sf(coords=c("lksX","lksY"),crs=3059)


unikalieB_1km=dati_atlaseB_sf %>% 
  group_by(KODS) %>% 
  filter(!duplicated(tikls1000)) %>% 
  ungroup()
unikalieC_1km=dati_atlaseC_sf %>% 
  group_by(KODS) %>% 
  filter(!duplicated(tikls1000)) %>% 
  ungroup()
unikalieD_1km=dati_atlaseD_sf %>% 
  group_by(KODS) %>% 
  filter(!duplicated(tikls1000)) %>% 
  ungroup()

unikalieB_100=dati_atlaseB_sf %>% 
  group_by(KODS) %>% 
  filter(!duplicated(tikls100)) %>% 
  ungroup()
unikalieC_100=dati_atlaseC_sf %>% 
  group_by(KODS) %>% 
  filter(!duplicated(tikls100)) %>% 
  ungroup()
unikalieD_100=dati_atlaseD_sf %>% 
  group_by(KODS) %>% 
  filter(!duplicated(tikls100)) %>% 
  ungroup()

testa_klatbutnes=readbulk::read_bulk(directory="./SuguModeli/ApmacibuDati/TestingPresence/",
                                     name_contains = ".parquet",
                                     fun=arrow::read_parquet)
trenina_klatbutnes=readbulk::read_bulk(directory="./SuguModeli/ApmacibuDati/TrainingPresence/",
                                       name_contains = ".parquet",
                                       fun=arrow::read_parquet)
testa_fons=readbulk::read_bulk(directory="./SuguModeli/ApmacibuDati/TestingBackground/",
                               name_contains = ".parquet",
                               fun=arrow::read_parquet)
trenina_fons=readbulk::read_bulk(directory="./SuguModeli/ApmacibuDati/TrainingBackground/",
                                 name_contains = ".parquet",
                                 fun=arrow::read_parquet)




admin=read_sf("./Templates/TemplateGrids/administrativas_teritorijas_2021/Administrativas_teritorijas_2021.shp")
kodi=levels(factor(dati2$KODS))

nosaukumiem=dati2 %>% 
  dplyr::select(KODS,Name_key,zinatniski) %>% 
  mutate(latviski=sub("^(.*)(\\s+\\S+){2}$", "\\1", Name_key))

suga="ACCGEN"

nosaukumam=nosaukumiem %>% 
  filter(KODS==suga)


visi=dati2_sf %>% 
  filter(KODS==suga)
skaits_visi=nrow(visi)
BCD_1km=unikalieB_1km %>% 
  filter(KODS==suga)
skaits_BCD1km=nrow(BCD_1km)
BCD_100=unikalieB_100 %>% 
  filter(KODS==suga)
skaits_BCD100=nrow(BCD_100)
CD_1km=unikalieC_1km %>% 
  filter(KODS==suga)
skaits_CD1km=nrow(CD_1km)
CD_100=unikalieC_100 %>% 
  filter(KODS==suga)
skaits_CD100=nrow(CD_100)
D_1km=unikalieD_1km %>% 
  filter(KODS==suga)
skaits_D1km=nrow(D_1km)
D_100=unikalieD_100 %>% 
  filter(KODS==suga)
skaits_D100=nrow(D_100)



pic1=ggplot()+
  theme_map()+
  geom_sf(data=admin)+
  geom_sf(data=visi,col="grey20",alpha=0.5)+
  labs(subtitle=paste0("Visi pirms atlases (n=",skaits_visi,")"))

pic2=ggplot()+
  theme_map()+
  geom_sf(data=admin)+
  geom_sf(data=BCD_1km,col="red")+
  geom_sf(data=BCD_100,col="black",pch=3,size=3)+
  labs(subtitle=paste0("Telpiski unikālie BCD pēc atlases (N=",
                       skaits_BCD1km,", n=",skaits_BCD100,")"))

pic3=ggplot()+
  theme_map()+
  geom_sf(data=admin)+
  geom_sf(data=CD_1km,col="red")+
  geom_sf(data=CD_100,col="black",pch=3,size=3)+
  labs(subtitle=paste0("Telpiski unikālie CD pēc atlases (N=",
                       skaits_CD1km,", n=",skaits_CD100,")"))

pic4=ggplot()+
  theme_map()+
  geom_sf(data=admin)+
  geom_sf(data=D_1km,col="red")+
  geom_sf(data=D_100,col="black",pch=3,size=3)+
  labs(subtitle=paste0("Telpiski unikālie D pēc atlases (N=",
                       skaits_D1km,", n=",skaits_D100,")"))

solu_dati=soli2 %>% 
  filter(KODS==suga)
stabini=ggplot(solu_dati,aes(soli_seciba,skaits,fill=darbiba))+
  geom_col()+
  theme_bw()+
  scale_fill_manual("Atlases lēmums",
                    values=c("grey","darkgreen"),
                    labels=c("atteikties","saglabāt"))+
  labs(x="",y="Novērojumu skaits")+
  theme(legend.position = "bottom")+
  labs(title=substitute(a~"-"~b~italic(x), 
                        list(a=nosaukumam$KODS,
                             b=nosaukumam$latviski,
                             x=nosaukumam$zinatniski)),
       subtitle="Novērojumu atlases gaita")+
  theme(panel.grid = element_blank())


treninklatbutnes=trenina_klatbutnes %>% 
  filter(KODS==suga) %>% 
  st_as_sf(coords=c("x","y"),crs=3059)
skaits_treninklatbutnes=nrow(treninklatbutnes)
treninfons=trenina_fons %>% 
  filter(str_detect(File,suga)) %>% 
  st_as_sf(coords=c("x","y"),crs=3059)
pic5=ggplot()+
  theme_map()+
  geom_sf(data=admin)+
  geom_sf(data=treninfons,col="black",pch=3)+
  geom_sf(data=treninklatbutnes,col="red")+
  labs(subtitle=paste0("Modeļa apmācību kopa (pirms telpisko bloku krosvalidācijas; N=",
                       skaits_treninklatbutnes,")"))

testklatbutnes=testa_klatbutnes %>% 
  filter(KODS==suga) %>% 
  st_as_sf(coords=c("x","y"),crs=3059)
skaits_testklatbutnes=nrow(testklatbutnes)
testfons=testa_fons %>% 
  filter(str_detect(File,suga)) %>% 
  st_as_sf(coords=c("x","y"),crs=3059)
pic6=ggplot()+
  theme_map()+
  geom_sf(data=admin)+
  geom_sf(data=testfons,col="black",pch=3)+
  geom_sf(data=testklatbutnes,col="red")+
  labs(subtitle=paste0("Modeļa neatkarīgās testēšanas kopa (N=",
                       skaits_testklatbutnes,")"))


dizains <- c(
  area(2, 1, 5, 5),
  area(1, 6, 3, 11),
  area(1, 12, 3, 17),
  area(4, 6, 6, 11),
  area(4, 12, 6, 17),
  area(1, 18, 3, 23),
  area(4, 18, 6, 23)
)
#plot(dizains)
attelsX=stabini+pic1+pic2+pic3+pic4+pic5+pic6+
  plot_layout(design=dizains) +
  plot_annotation(tag_levels = "A") 
faila_nosaukumam=paste0("./SuguModeli/ApmacibuDati/IzvelesAtteli/ObsSelection_",suga,".png")
ggsave(attelsX,filename=faila_nosaukumam,device="png",
       width = 2000,height = 750,units="px",dpi=100)

