# Readme_Templates: references slāņi harmonizētam darbam

Šajā direktorijā ir nepieciešams no atvērto datu portāla manuāli lejupielādēt un 
atarhivēt sekojošos ģeoreferencētos slāņus:

- Latvijas teritoriju (iekšzemes un jūras) aptverošs režģis ar šūnas malas 
garumu 100 m (https://data.gov.lv/dati/lv/dataset/rezgis) [skatīts: 2024-01-20]. 
Pēc lejupielādes dokumentu nepieciešams atarhivēt `./Templates/grid_lv_100`, 
kurā atrodas *geopackage* `grid_lv_100.gpkg` ar slāni `grid_lv_100`;

- Latvijas teritoriju (iekšzemes un jūras) aptverošs režģis ar šūnas malas 
garumu 1000 m (https://data.gov.lv/dati/lv/dataset/rezgis) [skatīts: 2024-01-20]. 
Pēc lejupielādes dokumentu nepieciešams atarhivēt `./Templates/grid_lv_1k`, 
kurā atrodas *ESRI shapefile* `Grid_LV_1k`;

- Latvijas administratīvās teritorijas pēc 2021. gada reformas (atbilstoši 
Administratīvo teritoriju un apdzīvoto vietu likuma redakcijai, kas stājās 
spēkā 2021. gada 3. jūnijā) (https://data.gov.lv/dati/lv/dataset/atr) [skatīts: 2024-01-20]. 
Pēc lejupielādes dokumentu nepieciešams atarhivēt `./Templates/administrativas_teritorijas_2021`, 
kurā atrodas *ESRI shapefile*.

Papildus tam ir nepieciešams slānis ar karšu lapām ģeoprocesēšanas telpiskai 
dalīšanai. Es izmantoju Envirotech izplatīto 1993. gada topogrāfisko karšu 
sistēmas M:50000 rāmi. Tas kā *geoparquet* slānis ievietots šajā repozitorijā 
`./Templates/TemplateGrids/tks93_50km.parquet`.

Tālāk aprakstītais darbs ir veicams ar komandu rindām failā `./RScript/01_Templates.R`

## Vektordatu režģi

Tā kā lejupielādētie vektordatu režģi ietver arī Latvijas Ekskluzīvās Ekonomiskās 
Zonas ūdeņus, no tiem atlasīti tikai tie kvadrāti, kas pārklājas ar administratīvajām 
teritorijām. Rezultējošie objekti saglabāti {sf} tieši atbalstītā geoparquet formātā 
turpmāko darbu paātrināšanai un geopackage formātā plašākam lietojumam un pārbaudītai stabilitātei.

Lai samazinātu faila apjomu un to izmantotu Zemes novērošanas sistēmas datu filtrēšanai, 
sagatavots ESRI shapefile slānis, kurā visi sauszemes 100 m kvadrāti apvienoti vienā ģeometrijā.

Līdzīga atlase veikta 1km režģim - tikai tie, kas saskarās ar Latvijas administratīvajām robežām.

Dažādu ainavas metriku aprēķināšanai, sagatavoti arī 300 m un 500 m režģi. To nepieciešamības 
pamatojums sniegts https://aavotins.github.io/PutnuSDMs_gramata/Chapter5.html#Chapter5.1

Katram no iepriekš minētajiem režģiem aprēķinātas centroīdas, no kurām sagatavoti slāņi ar 
ģeometrijām “punkts”. Šie punkti saistīti ar Envirotech izplatīto 1993. gada topogrāfisko 
karšu sistēmas M:50000 rāmi (tks93_50km). Ik punktam atbilstošais tks93_50km lapas numurs pievienots 
tā tīklam un katra tīkla identifikatori pievienoti 100 m tīklam.


### Stratificēšana ģeoprocesēšanas paralelizācijai

Lai atvieglotu un paātrinātu ģeoprocesēšanu, analīzes telpu ir nepieciešams sadalīt 
mazākās daļās. Tam izmantotas tks93_50km lapas.

Dažādu ainavas metriku aprēķināšanai un sagatavošanās darbu veikšanai sugu ligzdošanas 
iecirkņu un tiem atbilstošo ainavu mērogos, sagatavots 100 m režģa centra punktu slānis un, 
ik TKS karšu lapai atsevišķā failā, atbilstoši buferētu laukumu slāņi.


Papildus tam, ģeoprocesēšanas paātrināšanai, sagatavoti 3000 m buferi ap 300 m tīkla 
centriem un 10000 m buferi ap 1 km centriem un saglabāti ik tks93_50km lapā. Atsevišķi 
faili ik lapai sagatavoti arī 100 m tīklam.


## References rastri

Lai nodrošinātu ievades datu (to pirmapstrādes produktu) telpisko harmonizētību un 
tai iespējami tuvotos attiecībā pret ekoģeogrāfiskajiem mainīgajiem, sagatavoti 
references rastri. Tie saglabāti kā Geotiff faili ar trīs šūnas izmēriem - 10 m 
(ievades datiem), 100 m (analīzes šūna) un 500 m (daļa starprezultātu).

Katra rastra telpiskais pārklājums ir par 10 km plašāks nekā Latvijas 
sauszemes 100 m tīkls, lai nodrošinātu iespēju ainavmetriku aprēķiniem.

Sagatavojot 10 m rastru, izmantotas tās šūnas, kuru centri atrodas Latvijas 
administratīvajās teritorijās. Savukārt rastriem ar šūnas izmēru 100 m un 500 m kā 
nosacījums izmantota pieskaršanās Latvijas administratīvajām teritorijām.


## Noslēgums

Šie faili tiks izmantoti par pamatu harmonizētai datu analīzei kā telpiskās 
vienības un maskas. Diemžēl, daļai ievades ģeodatu nav iespējams jēgpilni nodrošināt 
pietiekoši korektu aizpildījumu uz Latvijas robežām, tādēļ sagatavots vienotas 
minimālās analīzes telpas maskas slānis, kurš pieejams direktorijas `Rastri_100m` failā 
`nulles_LV100m_10km.tif`.

Visi slāņi projektēti [Latvijas koordinātu sistēmā ar EPSG kodu 3059](https://epsg.io/3059).