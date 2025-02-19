# Vietu prioritizācijas uzdevumu sagatavošana izpildei konteinerī "zig4_latest.sif"
# Apraksts: ./RScript/Readme_RScript.md un projekta 2024. gada pārskatā.
# Sākumā izveido nepieciešamās direktorijas, tad darba sesijai pievieno pakotnes, 
# tālāk tiek sagatavoti divi prioritizācijas uzdevumi, pēc tam sniegtas komandu 
# rindas to rezultātu vizualizācijai

# direktorijas ----

dir.create("./SuguModeli/Prioritisation/")
dir.create("./SuguModeli/Prioritisation/SingleSpecies_site/")
dir.create("./SuguModeli/Prioritisation/SingleSpecies_DS/")
dir.create("./SuguModeli/Prioritisation/Pics/")

# pakotnes ----

library(tidyverse)
library(terra)
library(readxl)
library(openxlsx)
library(sf)
library(patchwork)


# individuālu vietu prioritizācija ----


suga="ACCGEN"

kartes_cels=paste0("../../BestHSmap/BestHSmap_",suga,".tif")
dir.create(paste0("./SuguModeli/Prioritisation/SingleSpecies_site/site_",suga))
fails_SiteFeatures=paste0("./SuguModeli/Prioritisation/SingleSpecies_site/site_",suga,"/FeaturesList.spp")
saturs_SiteFeatures=paste0("1 1 1 1 0.25 ",kartes_cels)
writeLines(saturs_SiteFeatures,fails_SiteFeatures)
fails_SiteSettings=paste0("./SuguModeli/Prioritisation/SingleSpecies_site/site_",suga,"/Settings.dat")
saturs_SiteSettings=c("[Settings]
removal rule = 2
warp factor = 100
edge removal = 0
add edge points = 0")
writeLines(saturs_SiteSettings,fails_SiteSettings)

Site_jobname=paste0("s",suga)
Site_outname=paste0("SSSite_",suga,".out")

Site_cels_Settings=paste0("site_",suga,"/Settings.dat")
Site_cels_Feature=paste0("site_",suga,"/FeaturesList.spp")
Site_cels_rezultats=paste0("site_",suga,"/outputs/site_",suga,".txt")
Site_vadibai=" 0.0 0 1.0 0 "

Site_bashcels=paste0("./SuguModeli/Prioritisation/SingleSpecies_site/site_",suga,".sh")

Site_textam=paste0("#!/bin/bash
#SBATCH --job-name=",Site_jobname,"			 # Job name
#SBATCH --partition=regular			 # Partition name
#SBATCH --ntasks=1				 # Number of tasks
#SBATCH --cpus-per-task=1
#SBATCH --time=40:00:00			 # Time limit, hrs:min:sec
#SBATCH --mem=16G				 # Kopējā atmiņa - ierobezota
#SBATCH --output=",Site_outname,"			 # Standard output and error log

echo 'Starting job'
echo 'Date = $(date)'
echo 'Node hostname = $(hostname -s)'
echo 'Working Directory = $(pwd)'
echo ''
echo 'Loading modules'

module load singularity/3.7.1
srun singularity exec  ../../../../zig4_latest.sif zig4 -r ",Site_cels_Settings," ",Site_cels_Feature," ",Site_cels_rezultats,Site_vadibai,"

#echo ''
#echo 'Running R script'


echo ''
echo 'All done on $(date)'")
writeLines(Site_textam,Site_bashcels)





# prioritizācija ligzdošanas iecirkņu apmērā ----

suga="ACCGEN"
radiuss=921 # HomeRange rādiuss. Paskaidrojumi aprakstā

dir.create(paste0("./SuguModeli/Prioritisation/SingleSpecies_DS/ds_",suga))
fails_dsFeatures=paste0("./SuguModeli/Prioritisation/SingleSpecies_DS/ds_",suga,"/FeaturesList.spp")


alfai=2/radiuss
alfa=ifelse(alfai>1,1,alfai)
saturs_dsFeatures=paste0("1 ",alfa," 1 1 0.25 ",kartes_cels)
writeLines(saturs_dsFeatures,fails_dsFeatures)

fails_dsSettings=paste0("./SuguModeli/Prioritisation/SingleSpecies_DS/ds_",suga,"/Settings.dat")
saturs_dsSettings=c("[Settings]
removal rule = 2
warp factor = 100
edge removal = 0
add edge points = 0")
writeLines(saturs_dsSettings,fails_dsSettings)

ds_jobname=paste0("ds",suga)
ds_outname=paste0("SSds_",suga,".out")

ds_cels_Settings=paste0("ds_",suga,"/Settings.dat")
ds_cels_Feature=paste0("ds_",suga,"/FeaturesList.spp")
ds_cels_rezultats=paste0("ds_",suga,"/outputs/site_",suga,".txt")
ds_vadibai=" 0.0 1 1.0 0 "

ds_bashcels=paste0("./SuguModeli/Prioritisation/SingleSpecies_DS/ds_",suga,".sh")

ds_textam=paste0("#!/bin/bash
#SBATCH --job-name=",ds_jobname,"			 # Job name
#SBATCH --partition=regular			 # Partition name
#SBATCH --ntasks=1				 # Number of tasks
#SBATCH --cpus-per-task=1
#SBATCH --time=40:00:00			 # Time limit, hrs:min:sec
#SBATCH --mem=16G				 # Kopējā atmiņa - ierobezota
#SBATCH --output=",ds_outname,"			 # Standard output and error log

echo 'Starting job'
echo 'Date = $(date)'
echo 'Node hostname = $(hostname -s)'
echo 'Working Directory = $(pwd)'
echo ''
echo 'Loading modules'

module load singularity/3.7.1
srun singularity exec  ../../../../zig4_latest.sif zig4 -r ",ds_cels_Settings," ",ds_cels_Feature," ",ds_cels_rezultats,ds_vadibai,"

#echo ''
#echo 'Running R script'


echo ''
echo 'All done on $(date)'")
writeLines(ds_textam,ds_bashcels)





# rezultātu noformēšana -----

suga="ACCGEN"


slanis_hs=terra::rast(paste0("./SuguModeli/BestHSmap/BestHSmap_",
                             suga,".tif"))

slanis_binars=terra::rast(paste0("./SuguModeli/BestHSbinaryMaps/HSbinary_",
                                 suga,".tif"))
vektors_binars=terra::as.polygons(slanis_binars)
vektors_binars=sf::st_as_sf(vektors_binars)
vektors_viens=vektors_binars %>% 
  filter(lyr1==1)

populacijai=exactextractr::exact_extract(slanis_hs,vektors_viens,"sum")
popsum=sum(as.vector(slanis_hs),na.rm=TRUE)
aizsardzibai=populacijai/popsum


# site
slanis_site=terra::rast(paste0("./SuguModeli/Prioritisation/SingleSpecies_site/site_",
                               suga,"/outputs/site_",suga,".ABF_.rank.compressed.tif"))


curves_site=read.table(paste0("./SuguModeli/Prioritisation/SingleSpecies_site/site_",
                              suga,"/outputs/site_",suga,".ABF_.curves.txt"),
                       skip=1L)
names(curves_site)=c("PropLandLost","Cost","MinPropRemain","MeanPropRemain",
                     "WeightPropRemain","ext1","ext2","PropEach")

site_krutspunktam=which.min(abs(curves_site$ext2-curves_site$MeanPropRemain))
site_krutpunkts=curves_site$PropLandLost[site_krutspunktam]

site_zemajam=which.min(abs(curves_site$MeanPropRemain-aizsardzibai))
site_zema_PropLand=curves_site$PropLandLost[site_zemajam]

df_site_raw=terra::as.data.frame(slanis_site,xy=TRUE)
df_site_raw$raw_ranks=df_site_raw[,3]

fig1=ggplot(df_site_raw,aes(x=x,y=y,fill=raw_ranks))+
  geom_raster()+
  scale_fill_viridis_c(breaks=seq(0,1,0.2),
                       limit=c(0,1))+
  coord_fixed()+
  labs(fill="Vietas nozīme aizsardzībā\n(relatīvais ranks ar pieaugošu vērtību)")+
  ggthemes::theme_map()+
  theme(legend.position="bottom")


curves_site_long=curves_site %>% 
  dplyr::select(PropLandLost,ext2,MeanPropRemain) %>% 
  pivot_longer(ext2:MeanPropRemain,names_to="Veids",values_to="Vertiba") %>% 
  mutate(Nosaukumiem=ifelse(Veids=="ext2","Izzušanas risks","Šķietamā populācija"))

fig2=ggplot(curves_site_long,aes(x=PropLandLost,y=Vertiba,lty=Nosaukumiem)) +
  theme_classic()+
  annotate("rect", 
           xmin=0,xmax=site_zema_PropLand,ymin = 0,ymax=1,
           fill = "grey",alpha=0.5)+
  annotate("rect", 
           xmin=site_zema_PropLand,xmax=site_krutpunkts,ymin = 0,ymax=1,
           fill = "yellow",alpha=0.5)+
  annotate("rect", 
           xmin=site_krutpunkts,xmax=1,ymin = 0,ymax=1,
           fill = "red",alpha=0.5)+
  geom_line()+
  labs(x="Ainavas daļa ar pieaugošu nozīmi aizsardzībā",
       y="Īpatsvars")+
  theme(legend.title = element_blank())+
  scale_x_continuous(breaks=seq(0,1,0.1))+
  scale_y_continuous(breaks=seq(0,1,0.1))+
  theme(legend.position="top")



df_site_raw$klases=factor(ifelse(df_site_raw$raw_ranks<site_zema_PropLand,"Zemākas\nnozīmes",
                                 ifelse(df_site_raw$raw_ranks<site_krutpunkts,"Augstas\nnozīmes",
                                        "Prioritāra")),ordered=TRUE,
                          levels=c("Zemākas\nnozīmes","Augstas\nnozīmes","Prioritāra"))
fig3=ggplot(df_site_raw,aes(x=x,y=y,fill=klases))+
  geom_raster() + 
  scale_fill_manual(values = c("Zemākas\nnozīmes"="grey",
                               "Augstas\nnozīmes"="yellow",
                               "Prioritāra"="red"))+
  coord_fixed()+
  labs(fill="Vietas nozīme aizsardzībā\n(stratificēta)")+
  ggthemes::theme_map()+
  theme(legend.position="bottom")




# ds

slanis_ds=terra::rast(paste0("./SuguModeli/Prioritisation/SingleSpecies_DS/ds_",
                             suga,"/outputs/site_",suga,".ABF_S100.rank.compressed.tif"))

curves_ds=read.table(paste0("./SuguModeli/Prioritisation/SingleSpecies_DS/ds_",
                            suga,"/outputs/site_",suga,".ABF_S100.curves.txt"),
                     skip=1L)
names(curves_ds)=c("PropLandLost","Cost","MinPropRemain","MeanPropRemain",
                   "WeightPropRemain","ext1","ext2","PropEach")

ds_krutspunktam=which.min(abs(curves_ds$ext2-curves_ds$MeanPropRemain))
ds_krutpunkts=curves_ds$PropLandLost[ds_krutspunktam]

ds_zemajam=which.min(abs(curves_ds$MeanPropRemain-aizsardzibai))
ds_zema_PropLand=curves_ds$PropLandLost[ds_zemajam]

df_ds_raw=terra::as.data.frame(slanis_ds,xy=TRUE)
df_ds_raw$raw_ranks=df_ds_raw[,3]

fig4=ggplot(df_ds_raw,aes(x=x,y=y,fill=raw_ranks))+
  geom_raster()+
  scale_fill_viridis_c(breaks=seq(0,1,0.2),
                       limit=c(0,1))+
  coord_fixed()+
  labs(fill="Vietas nozīme aizsardzībā\n(relatīvais ranks ar pieaugošu vērtību)")+
  ggthemes::theme_map()+
  theme(legend.position="bottom")


curves_ds_long=curves_ds %>% 
  dplyr::select(PropLandLost,ext2,MeanPropRemain) %>% 
  pivot_longer(ext2:MeanPropRemain,names_to="Veids",values_to="Vertiba") %>% 
  mutate(Nosaukumiem=ifelse(Veids=="ext2","Izzušanas risks","Šķietamā populācija"))

fig5=ggplot(curves_ds_long,aes(x=PropLandLost,y=Vertiba,lty=Nosaukumiem)) +
  theme_classic()+
  annotate("rect", 
           xmin=0,xmax=ds_zema_PropLand,ymin = 0,ymax=1,
           fill = "grey",alpha=0.5)+
  annotate("rect", 
           xmin=ds_zema_PropLand,xmax=ds_krutpunkts,ymin = 0,ymax=1,
           fill = "yellow",alpha=0.5)+
  annotate("rect", 
           xmin=ds_krutpunkts,xmax=1,ymin = 0,ymax=1,
           fill = "red",alpha=0.5)+
  geom_line()+
  labs(x="Ainavas daļa ar pieaugošu nozīmi aizsardzībā",
       y="Īpatsvars")+
  theme(legend.title = element_blank())+
  scale_x_continuous(breaks=seq(0,1,0.1))+
  scale_y_continuous(breaks=seq(0,1,0.1))+
  theme(legend.position="top")


df_ds_raw$klases=factor(ifelse(df_ds_raw$raw_ranks<ds_zema_PropLand,"Zemākas\nnozīmes",
                               ifelse(df_ds_raw$raw_ranks<ds_krutpunkts,"Augstas\nnozīmes",
                                      "Prioritāra")),ordered=TRUE,
                        levels=c("Zemākas\nnozīmes","Augstas\nnozīmes","Prioritāra"))

fig6=ggplot(df_ds_raw,aes(x=x,y=y,fill=klases))+
  geom_raster() + 
  scale_fill_manual(values = c("Zemākas\nnozīmes"="grey",
                               "Augstas\nnozīmes"="yellow",
                               "Prioritāra"="red"))+
  coord_fixed()+
  labs(fill="Vietas nozīme aizsardzībā\n(stratificēta)")+
  ggthemes::theme_map()+
  theme(legend.position="bottom")


# attēls

attelsX=fig1+fig2+fig3+fig4+fig5+fig6+
  plot_layout(byrow=FALSE,ncol=2,nrow=3,widths=c(1,1),heights=c(3,1.5,3))+
  plot_annotation(tag_levels = "A") 

faila_nosaukumam=paste0("./SuguModeli/Prioritisation/Pics/SingleSpecies_",suga,".png")
ggsave(attelsX,filename=faila_nosaukumam,device="png",
       width = 1750,height = 1750,units="px",dpi=175)
