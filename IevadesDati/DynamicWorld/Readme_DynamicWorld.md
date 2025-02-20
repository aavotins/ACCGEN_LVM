# Dynamic World

Dynamic World (DW) ir relatīvi nesens Zemes novērošanas sistēmu produkts, kurš 
klasificē zemes segumu un lietojumu (LULC) deviņās 
kategorijās (0=water, 1=trees, 2=grass, 3=flooded_vegetation, 4=crops, 5=shrub_and_scrub, 6=built, 7=bare, 8=snow_and_ice), 
katram ESA Copernicus Sentinel-2 attēlam ar identificēto mākoņainību $\le 35$, 
pieļaujot filtrēšanu un dažādu agregāciju veidošanu (Brown et al., 2022).

DW ievades informācija - rastra slānis katrai sezonai katrā gadā - sagtavots 
Google Earth Engine platformā (Gorelick et al., 2017), [izmantojot replicēšanas skriptu](https://code.earthengine.google.com/941bb1a16331727787bb3fc1bbbda95b?noload=true). 
Lai izmantotu šo skriptu, ir nepieciešams [GEE konts un projekts](https://code.earthengine.google.com/register) 
un pietiekošs apjoms vietas Google Drive diskā. Izpildot komandrindas tiks piedāvāta 
lejuplāde failam, kas aptver laika periodu no vērtības 7. rindā līdz vērtībai 8. 
rindā (faila nosaukums norādāms 32. rindā, tā apraksts - 33. rindā un direktorija 
Google diskā - 31. rindā vai tas viss norādāms apstiprinot saglabāšanau) - šis 
skripts nav optimizēts visu sezonālo griezumu visiem gadiem sagatavošanai, lai 
reproducētu vai paplašinātu šo izpēti, tās nepieciešams manuāli izmainīt.

Pēc komandrindu izpildes un rezultātu sagatavošanas Google Drive diskā, ir 
redzams, ka katrs visu Latviju aptverošais slānis ir sadalīts vairākās lapās. Tas 
ir tādēļ, ka, lai nodrošinātu nulles patieso vērtību (klase “water”, nevis fons), slāņi 
kodēti kā Float, nevis veselie skaitļi. Visas šīs lapas ir nepieciešams lejuplādēt 
direktorijā `././IevadesDati/DynamicWorld/DynamicWorld_Eksperimentam/DWE_float/`, tad, 
sekojot `./RScript/02_GeodatiSakums.R` veikt to sagatavošanu tālākam darbam.