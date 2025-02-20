# Pārbauda vai ir pieejamas darbam nepieciešamās R pakotnes. Daļa no tām jau ir 
# instalēta rekomendētajā konteinerī, daļu nepieciešams instalēt, ko sekojošās 
# komandu rindas izdara.


if(!require(sf)) {install.packages("sf"); require(sf)}
if(!require(tidyverse)) {install.packages("tidyverse"); require(tidyverse)}
if(!require(arrow)) {install.packages("arrow"); require(arrow)}
if(!require(sfarrow)) {install.packages("sfarrow"); require(sfarrow)}
if(!require(terra)) {install.packages("terra"); require(terra)}
if(!require(readxl)) {install.packages("readxl"); require(readxl)}
if(!require(openxlsx)) {install.packages("openxlsx"); require(openxlsx)}
if(!require(patchwork)) {install.packages("patchwork"); require(patchwork)}
if(!require(usdm)) {install.packages("usdm"); require(usdm)}
if(!require(maps)) {install.packages("maps"); require(maps)}
if(!require(maxnet)) {install.packages("maxnet"); require(maxnet)}
if(!require(ecospat)) {install.packages("ecospat"); require(ecospat)}
if(!require(plotROC)) {install.packages("plotROC"); require(plotROC)}
if(!require(rasterVis)) {install.packages("rasterVis"); require(rasterVis)}
if(!require(SDMtune)) {install.packages("SDMtune"); require(SDMtune)}
if(!require(ENMeval)) {install.packages("ENMeval"); require(ENMeval)}
if(!require(zeallot)) {install.packages("zeallot"); require(zeallot)}
if(!require(ggview)) {install.packages("ggview"); require(ggview)}
if(!require(scales)) {install.packages("scales"); require(scales)}
if(!require(ggthemes)) {install.packages("ggthemes"); require(ggthemes)}
if(!require(ggtext)) {install.packages("ggtext"); require(ggtext)}
if(!require(raster)) {install.packages("raster"); require(raster)}
if(!require(fasterize)) {install.packages("fasterize"); require(fasterize)}
if(!require(gdalUtilities)) {install.packages("gdalUtilities"); require(gdalUtilities)}
if(!require(exactextractr)) {install.packages("exactextractr"); require(exactextractr)}
if(!require(whitebox)) {install.packages("whitebox"); require(whitebox)}
if(!require(landscapemetrics)) {install.packages("landscapemetrics"); require(landscapemetrics)}
if(!require(httr)) {install.packages("httr"); require(httr)}
if(!require(ows4R)) {install.packages("ows4R"); require(ows4R)}
if(!require(doParallel)) {install.packages("doParallel"); require(doParallel)}
if(!require(foreach)) {install.packages("foreach"); require(foreach)}
