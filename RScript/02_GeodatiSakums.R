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

