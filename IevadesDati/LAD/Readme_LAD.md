# Lauku atbalsta dienests

Lauku Atbalsta Dienests uztur regulāri aktualizētu informāciju atvērto datu 
portālā. Tajā ir pieejams arī arhīvs (kopš 2015. gada), izmantojamās datu kopas 
satur atslēgvārdu “deklarētās platības”. Šī projekta ietvaros izmantots WFS 
pieslēgums datu lejupielādei (2023-11-14). Lejupielāde veicama direktorijā 
`./IevadesDati/LAD/`

Pēc lejupielādes nodrošinātas ģeometrijas, tās pārbaudītas, dzēšot tukšās un validējot
pārējās, un saglabātas geoparquet formātā. Komandu rindas dotas failā 
`./RScript/02_GeodatiSakums.R`.