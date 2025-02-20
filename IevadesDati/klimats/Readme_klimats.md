# ERA5 Land klimata dati

ERA5-Land ir sauszemei veikta klimata (laika apstākļu) pazīmju reanalīze 
sauszemei 0.1° izšķirtspējā un aptver laika periodu kopš 1950. gada janvāra līdz 
mūsdienām (datu kopa tiek nepārtraukti papildināta) ar stundas temporālo 
izšķirtspēju (Sabater, n.d.). Oriģināldati lejupielādei ir pieejami ESA Copernicus 
Clima Data Store (https://cds.climate.copernicus.eu/datasets/reanalysis-era5-land?tab=download), 
tie pieejami arī Google Earth Engine platformā (Gorelick et al., 2017) kā [dienas](https://developers.google.com/earth-engine/datasets/catalog/ECMWF_ERA5_LAND_DAILY_AGGR) 
un [mēneša](https://developers.google.com/earth-engine/datasets/catalog/ECMWF_ERA5_LAND_MONTHLY_AGGR) 
līmeņu agregāti. Šie agregāti izmantoti sugu izplatības modelēšanai 
nepieciešamo pazīmju jēladatu sagatavošanai - izmantotās [komandu rindas](https://code.earthengine.google.com/4f1597f749ad4296ca46b373d8c4bd2f?noload=true). 
Piedāvātais skripts aprēķina vairākas pazīmes un piedāvā to lejupielādi Google Drive direktorijā. 
Lai izmantotu šo skriptu, ir nepieciešams [GEE konts un projekts](https://code.earthengine.google.com/register) 
un pietiekošs apjoms vietas Google Drive diskā. Skripta izpildīšana lejupielādei piedāvās sekojošus failus:

- `FebPrec`, kas raksturo ik pikseļa mediānu starp ik februāra (gada aukstākais 
mēnesis Latvijā) kopējo nokrišņu summām ik gadā no 2015. līdz 2023.;

- `FebTempSum`, kas raksturo ik pikseļa mediānu starp ik februāra (gada aukstākais 
mēnesis Latvijā) ikdienas vidējo gaisa temperatūru (2 m virs zemes) summām ik gadā no 2015. līdz 2023.;

- `JulPrec`, kas raksturo ik pikseļa mediānu starp ik jūlija (gada siltākais 
mēnesis Latvijā) kopējo nokrišņu summām ik gadā no 2015. līdz 2023.;

- `PosTempDays`, kas raksturo ik pikseļa mediānu starp dienu, kuru vidējā gaisa 
temperatūra (2 m virs zemes) ir vismaz 274°K (~0°C), skaitu ik gadā no 2015. līdz 2023.;

- `VegTempSums`, kas raksturo ik pikseļa mediānu starp ik dienas, kuras vidējā 
gaisa temperatūra (2 m virs zemes) ir vismaz 279°K (~5°C), summu ik gadā no 2015. līdz 2023.;

- `YearPrecSum`, kas raksturo ik pikseļa mediānu starp ik mēneša kopējo nokrišņu 
daudzuma summām ik gadā no 2015. līdz 2023..

Tā kā klimata datu kodējums ir Float, tie tiek sagatavoti kā no četrām lapām (katram 
slānim) sastāvoši GeoTIFF faili, kurua nepieciešams lejupielādēt darba cietajā diskā 
direktorijā `./IevadesDati/klimats/RAW/`. 
Failā `./RScript/02_GeodatiSakums.R` esošās komandu rindas nodrošina šo lapu 
apvienošanu un projektēšanu atbilstībai references rastram.
