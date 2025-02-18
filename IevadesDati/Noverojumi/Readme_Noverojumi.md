# Vistu vanaga izplatības modelēšanai izmantojamo sugas klātbūtnes vietu atlase 

Novērojumi no dažādām datu bāzēm ir savstarpēji harmonizēti un apvienoti vienā 
failā. Harmonizēšana ir veikta ārēji no šī repozitorija. Paši novērojumi ir 
uzskatāmi par ierobežotas pieejamības informāciju, kuras brīva publiskošana var 
traucēt populācijā notiekošajiem procesiem, piemēram, olu un mazuļu zagļu dēļ. 
Tādēļ tie nav šajā repozitorijā iekļauti.

Tomēr šim aprakstam blakus esošajā direktorijā ir ievieotti kritēriji novērojumu atlasei.

Kopumā šim pētījumam ir iegūtas ir 16 datu kopas, tās ir apvienojamas plašākās 
grupās pēc datu rakstura un būtības:

- pētnieki, eksperti, gredzenotāji:

  -- ar sistemātisku datu ieguvi un padziļinātu sugu izpēti strādājošu putnu 
  pētnieku (D. Ūlanda, A. Avotiņa, E. Lediņa, I. Jakovļeva, A. Kalvāna, J. Ķuzes, 
  E. Račinska) personīgo un uzturētajās datubāzēs (daļa, kuras atvēršana nepārkāpj 
  sugu aizsardzības un datu drošības normas, personu līgumsaistības) esošo lauka 
  novērojumu apkopojums;

  -- nozīmīgāko ar lielo ligzdu apdzīvošanu saistīto sugu aizsardzības un izpētes 
  projektu, kuros notikuši apjomīgi lauka darbi kopš 2016. gada, novērojumi. Šie 
  projekti ir:

    – Latvijas Dabas fonda īstenotais projekts “Mazā ērgļa aizsardzība Latvijā” 
    (LIFE AQPOM Nr.LIFE 13 NAT/LV/001078);

    – Latvijas Ornitoloģijas biedrības īstenotais projekts par sugas aizsardzības 
    plāna izstrādi sugu grupai “Pūces”;

    – Latvijas Universitātes īstenotā AS “Latvijas valsts meži” pasūtītā zinātniskās 
    izpētes projekta “Vistu vanaga Accipiter gentilis monitoringa pilnveidošana un 
    dzīvotņu piemērotības telpiskā modeļa izveide” (AS “Latvijas valsts meži” dokumenta 
    Nr. 5-5.5.1_000r_101_23_27_6) 2023. gada lauka darbu dati;

- monitoringu dati:

  -- “Plēsīgo putnu fona monitoringa” dati no 2017. līdz 2023. gada lauka darbu sezonām;

  -- “Ligzdojošo putnu uzskaites” dati par 2023. gada lauka darbu sezonu;

- oportūnistiski dabas draugu novērojumi dabas novērojumu no portāla 
dabasdati.lv [SQL-dump: 2023-12-01];

- DAP dabas datu pārvaldības sistēmas OZOLS brīvpieejas informācija [lejupielāde: 2024-11-17].

Datu meklēšanas komunikācijā un sākotnējās apkopošanas procesā pieprasīti tikai kā 
punkti reģistrēti novērojumi.

Šajās datu kopās apkopotā informācija izmantota sugu izplatības/dzīvotņu piemērotības 
modeļu apmācībai, validācijai un testēšanai. Protams, pirms modeļa sagatavošanas ir 
nepieciešama datu tīrīšana - tikai uzticamo novērojumu atlase no vietām, kurās nav 
notikušas ievērojamas vides pārmaiņas, izslēdzot dublikātus utml. Lai to paveiktu, 
nepieciešams harmonizēt datu kopas. Harmonizēšanas ietvaros veikta sākotnējā atlase, 
kas dokumentēta līdz ar lauku aprakstu. Pēc harmonizēšanas datu kopas apvienotas, 
ievērojot secību, kāda ir augstāk esošajā uzskaitījaumā (tai ir nozīme dupbikātu 
izslēgšanā), un veikta novērojumu atlase (tīrīšana) modelēšanai, kas aprakstīta 
sekojošajās nodaļās.

Pirms datu kopu harmonizēšanas katrai no tām piešķirti pieci lauki, kuros 
veikta sugu nosaukumu harmonizēšana ar citos projektos izmantoto, sekojot 
Latvijas Ornitoloģijas biedrības padomē apstiprinātajm un publicētajam putnu 
sugu nosaukumu sarakstam. Pievienotie lauki:

- `Grupa`: visos gadījumumos satur vērtību “Putni”;

- `NR`: sugas numurs pēc kārtas, saskaņā ar sarakstu. Var izmantot kartošanai taksonomiskās sistemātiskas kārtībā;

- `Name_key`: apvienots Latviskais un zinātniskais nosaukums;

- `KODS`: sugas apzīmējums ar sešiem lielajiem burtiem. Tas veidots no zinātniskā nosaukuma ģints apzīmējuma pirmajiem trīs burtiem un sugas epiteta pirmajiem trīs burtiem, izņemot sugas, kurām tie atkārtojas - tādā gadījumā visām sugām pēdējie trīs burti apzīmējumā ir no sugas epiteta pēdējiem trīs burtiem;

- `zinatniski`: zinātniskais nosaukums.

Visās datu kopās izveidoti sekojoši lauki, veicoet vērtību ievietošanu vai ierakstu 
izslēgšanu, sekojot uzskaitījumam:

- `gads`: novērojuma gads. Izdalīts no novērojuma datuma (periodu gadījumā - sākuma 
datuma), ja nav atsevišķi norādīts;

- `datums_no`: novērojuma datums vai ar novērojumu aptvertā perioda sākuma datums. 
Daļā gadījumu precīzs datums nav bijis zināms. Ekspertu datu kopās, kurās ir ziņots 
par apdzīvotām ligzdām, ievietots atbilstošā gada 15.jūnijs, pārējos gadījumos 
ieraksti izslēgti;

- `datums_lidz`: ar novērojumu aptvertā perioda beigu datums; “NA”, ja novērojums 
neattiecas uz periodu;

- `nov_periods`: ar novērojumu aptvertā perioda ilgums dienās kā starpība starp 
lauku datums_lidz un datums_no starpība; ja vērtība ir tikai laukā datums_no, 
ievietota vērtība “0”;

- `pazime`: datu kopā reģistrētā ligzdošanas ticamības pazīme; “NA”, ja tādas 
nav, bet ir ligzdošanas ticamības kategorija, izņemot ekspertu datus, kuros 
ziņojumiem par apzīvotām ligzdām piešķirta vērtība “AL”;

- `BreedCat`: ligzdošanas ticamības kategorija kā reģistrēta datu kopā vai ievietota 
atbilstoši vērtībai laukā pazime. Ieraksti, kuriem nav ne ligzdošanas ticamības pazīmes, 
ne kategorijas, izslēgti. Izslēgti arī novērojumi, kuriem reģistrētie statusi nav 
attiecināmi uz ligzdošanu;

- `BreedCode`: skaitliski kodēta ligzdošanas ticamības kategorija:

  -- “Pierādīta ligzdošana” = 1;

  -- “Ticama ligzdošana” = 2;

  -- “Iespējama ligzdošana” = 3;

- `lksX`: Latvijas taisnleņķa projicēto koordinātu sistēmas (epsg: 3059) X-koordināte;

- `lksY`: Latvijas taisnleņķa projicēto koordinātu sistēmas (epsg: 3059) Y-koordināte;

- `DatuKopa`: datu kopas nosaukums plašās kategorijās: “eksperti”, “monitoringi”, 
“dabasdati”, “DAP”, “TestaKopa”.

Visi novērojumi sagatavoti atbilstībai Latvijas taisnleņķa projicēto koordinātu 
sistēmai (epsg: 3059) `simple features` objektā, kas saglabāts diskā Arrow *parquet* 
failā, izmantojot R pakotnes {arrow} funkcionalitāti. Novērojumi telpiski savienoti 
ar 100 m un 1 km vektordatu režģi. Šīs procedūras ietvaros pievienoti sekojoši lauki:

- `tikls100`: Latvijas 100 m vektordatu režģa šūnas, kurā atrodas novērojuma punkts, 
identifikators. No turpmākām darbībām izslēgti novērojumi, kuri nesavienojas ar šiem tīkliem;

- `tikls1000`: Latvijas 1 km vektordatu režģa šūnas, kurā atrodas novērojuma punkts, 
identifikators. No turpmākām darbībām izslēgti novērojumi, kuri nesavienojas ar šiem tīkliem.

Šī darba laikā arī izslēdzu novērojumus, kuri apraksta neapdzīvotas ligzdas vai 
norāda neprecīzas koordinātes. Dabasdatu kopā izslēdzu novērojumus, kurus reģistrējušai 
personai uzticamības līmenis atzīmēts kā “Apzinātas muļķības” vai “Biežas kļūdas 
elementārās lietās”.

Uzreiz veicu novērojumu atlasi līdz vienam punktam 1 km tīklā.

Ar sagatavoto harmonizēto datu kopu turpināju novērojumu atlasi modelēšanai, kurai 
izmantotās komandu rindas ir failā `./RScript/06_NoverojumuSagatavosana.R`.


## Novērojumu atlases gaita

Novērojumu atlase sugu izplatības modelēšanai veikta vairākos soļos:

1. solis: tikai analizējamo sugu atlase;

2. solis: novērojumi no 2017-01-01 līdz 2023-12-01, saglabāju tikai tos, kuri 
attiecas uz ziņošanas laika periodu, kas nepārsniedz 10 dienas un nav mazāks par -1 dienu;

3. solis: dublieru izslēgšana - gan no ik viena datu avota, gan datu avotu kopas;

4. solis: savienošana ar Corine Land Cover klasēm acīmredzami nekorekto novērojumu izslēgšanai;

5. solis: novērojums veikts ligzdošanas sezonā;

6. solis: saistīšana ar vides pārmaiņām;

7. solis: papildkritērijs vistu vanagam - attālums no apdzīvotajām vietām;

8. solis: novērojumu apjoma un izvietojuma izvērtēšana, lēmumu modelēšanai pieņemšana.
