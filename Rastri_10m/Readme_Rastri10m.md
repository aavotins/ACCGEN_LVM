# Ģeodatu apstrādes starprezultāti


Atsevišķos gadījumos ievades datiem veikta relatīvi apjomīga apstrāde (sagatavojot 
ievades produktus), kas nepieciešama turpmākajam darbam - ekoģeogrāfisko mainīgu 
sagatavošanai un novērojumu filtrēšanai. Šie produkti un to izstrādes gaita 
raksturota atbilstošajās apakšnodaļās.

Ievades produkti veidoti kā rastri atbilstoši standartizācijas failiem. Visvairāk 
rastra (ievades līmeņa) produktu radīts 10 m izšķirstpējā, bet daļa arī saistīta 
ar citām izšķirtspējām vai jau agregācijām vektordatos. Visi references rastri 
ir savā starpā saistīti pēc pikseļu izvietojuma.

Ievades jēldatu rasterizēšana veikta, lai risinātu topoloģiskos, topogrāfiskos 
un savstarpējā novietojuma izaicinājumus, kas raksturīgi atšķirīgos un dažādos 
mērogos izstrādātiem un uzturētiem vektordatiem. Rasterizēšana ļauj ne tikai 
telpiski harmonizēt šos datus, tā arī atvieglo to apstrādi, gan attiecībā uz 
ainavas objektu sasvstarpējo novietojumu, gan apstrādei nepieciešamajiem 
resursiem (instrukciju sarežģītība, to procesēšanas kopējais laiks un 
procesor-stundu izmaksas). Sekojošajās apakšnodaļās raksturoti izaicinājumi, to 
risināšanai pieņemtie lēmumi un ar komandu rindām ieviestie risinājumi.

## Ainava

Šajā vingrinājumā “ainava” ir dažādu zemes seguma un lietojuma veidu klašu pārstāvniecība, 
kurā svarīga ir šo klašu zīmēšanas secība, jo nereti dažādu avotu telpiskajiem 
datiem ir savstarpēja robežu neatbilstība, kas liek risināt gan to savstarpējo 
pārklāšanos (1), gan aizpildīt robus vietām, par kurām nav datubāzu informāicja (2), un 
izvēle par objektu uzsvēršanu ar kādu apstrādi, piemēram, buferēšanu, jo daļa vides 
raksturošanai (jo sevišķi, malas efektu) nozīmīgu elementu var būt ar tik mazu 
laukumu vai tādu novietojumu, ka rasterizāicjas procesā tie pazūd (3). Pamata 
ainavas slānim nozīme ir arī kalpot kā maskai turpmāko vides aprakstu sagatavošanā. 
Šeit raksturota pamata (vienkāršas) ainavas izstrāde un sekojošajās apakšnodaļās 
tās bagātināšana ar klasēm specifiskākiem vides ekoģeogrāfiskajiem mainīgajiem. 
Vienkāršā ainava saglabāta failā Ainava_vienk_mask.tif, kurā esošās klases un to 
izveidošanas procedūra raksturota sekojošajā uzskaitījumā:

- klase `100` - ceļi: dažādu avotu ceļi, aizpildīta secībā - dominē pār klasēm ar 
lielāku vērtību, lai nepazustu relatīvi neliela izmēra objekti un nodrošinātu 
informāciju par malām. Šīs klases izveidošanai apvienoti:

  – topogrāfiskās kartes slāņi `road_A` un `road_L` (izņemot mazāko platuma grupu, 
  kura visbiežāk neveido vienlaidus pārrāvumu vainagu klājā, skatīt atlasi), 
  pirms rasterizēšanas tos buferējot par 10 m;

  – LVM atvērto datu slāņi `LVM_MEZA_AUTOCELI`, `LVM_ATTISTAMIE_AUTOCELI`, 
  `LVM_APGRIESANAS_LAUKUMI`, `LVM_IZMAINISANAS_VIETAS` un `LVM_NOBRAUKTUVES`, 
  tās buferējot par 10 m.

  – nav izmantota Meža valsts reģistra informācija par dabiskajām brauktuvēm, 
  jo tās visbiežāk neveido vienlaidus pārrāvumu vainagu klājā. Šī reģistra 
  informācija par ceļiem ir arī pārējos resursos, tā nav dublēta.

- klase `200` - ūdeņi: dažādu avotu ūdensobjekti, aizpildīta secībā - dominē pār 
klasēm ar lielāku vērtību, lai nepazustu relatīvi neliela izmēra objekti un 
nodrošinātu informāciju par malām. Šīs klases izveidošanai apvienoti:

  – topogrāfiskās kartes slāņi `hidro_A` un `hidro_L` (buferēts par 5 m);

  – MKIS slānis `Ditches`, to buferējot par 3 m;

  – LVM atvērto datu slāņi `LVM_GRAVJI`, tās buferējot par 5 m.

  – nav izmantota Meža valsts reģistra informācija par grāvjiem, jo tai ir jābūt 
  arī pārējos resursos, vai tik nelielai, ka nerada vienlaidus pārrāvumu koku vainagu klājā.

- klase `300` - lauki: lauksaimniecības zemes LAD lauku blokos aizpildīta 
secībā - dominē pār klasēm ar lielāku vērtību, tomēr pēc pamata klašu izveidošanas, 
robu aizpildīšanā papildināta ar informāciju no Dynamic World. Šīs klases 
izveidošanai apvienoti:

  – `LAD lauku informācijas slānis`, kurš, sekojot pieņemtajam lēmumam par 
  grupējumu, dalīts trīs plašās grupās (pārklāšanās secībā):

    – **aramzemes** ar klases kodu `310`;

    – **papuves** ar klases kodu `320`;

    – **zālāji** ar klases kodu `330`;

  – pamata ainavā augļudārzi un ilggadīgie krūmveida stādījumi ievietoti citās ainavas klasēs.

- klase `400` - mazdārziņi un augļudārzi, vasarnīcas, aizpildīta secībā - dominē 
pār klasēm ar lielāku vērtību. Šīs klases izveidošanai apvienoti (pārklāšanās secībā):

  – topogrāfiskās kartes slāņa `landus_A` klases "poligons_Augļudārzs",
  "poligons_Sakņudārzs", "poligons_Ogulājs", kura rezultāts kodēts ar `410`;

  – `LAD lauku informācijas` slāņa grupa “augļudārzi”, kura rezultāts kodēts ar `420`.
  
- klase `500` - apbūve: apbūvētās platības, aizpildīta beigās, izmantojot 
informāciju no Dynamic World par vietām, kuras nav nosegtas ar citām klasēm.

- klase `600` - meži, krūmāji, izcirtumi: ar kokiem un krūmiem klātās platības un 
izcirtumi un iznīkušās mežaudzes, aizpildīta secībā - dominē pār klasēm ar lielāku 
vērtību. Šīs klases izveidošanai apvienoti (pārklāšanās secībā):

  – The Global Forest Watch slānī reģistrētās koku vainagu seguma izzušanas 
  kopš 2020. gada, kura rezultāts kodēts ar `610`;

  – Meža valsts reģistrā atzīmētie izcirtumi un iznīkušās audzes, kura 
  rezultāts kodēts ar `610`;

  – Meža valsts reģistrā atzīmētās mežaudzes, kas ir zemākas par 5 m un sēklu 
  ieguves plantācijas, kura rezultāts kodēts ar `620`;

  – topogrāfiskās kartes slāņa `flora_L` ar krūmiem saistītās klases, kas 
  buferētas par 10 m, kura rezultāts kodēts ar `620`;

  – topogrāfiskās kartes slāņA `landus_A` klase “poligons_Krūmājs”, kura rezultāts 
  kodēts ar `620`;

  – LAD lauku informācijas slāņa grupa  “ilggadīgie krūmveida stādījumi”, kura 
  rezultāts kodēts ar `620`;

  – Meža valsts reģistrā atzīmētās mežaudzes augstumā no 5 m, rezultāts kodēts 
  ar `630`;

  – topogrāfiskās kartes slāņa `landus_A` klases “poligons_Parks”, 
  “poligons_Meza_kapi”, “poligons_Kapi”, kura rezultāts kodēts ar `640`;

  – topogrāfiskās kartes slāņa flora_L ar kokiem saistītās klases, kas buferētas 
  par 10 m, kura rezultāts kodēts ar `640`;

  – Palsar Forests slānis, kura rezultāts kodēts ar `630`.

- klase `700` - mitrāji: apvienojot ar niedrājiem, purviem un bebrainēs saistītos 
ģeotelpiskos datus, aizpildīta secībā - dominē pār klasēm ar lielāku vērtību. Šīs 
klases izveidošanai apvienoti (pārklāšanās secībā):

  – topogrāfiskās kartes slāņa `landus_A` klases “Meldrājs_ūdenī_poligons”, 
  “poligons_Grīslājs”, “poligons_Meldrājs”, “poligons_Nec_purvs_grīslājs”, 
  “poligons_Nec_purvs_meldrājs”, “Sēklis_poligons”, kura rezultāts kodēts ar `720`;

  – topogrāfiskās kartes slāņa `landus_A` klases “poligons_Nec_purvs_sūnājs”, 
  “poligons_Sūnājs”, kuru rezultāts kodēts ar `710`;

  – topogrāfiskās kartes slāņa swamp_A, kura rezultāts kodēts ar `710`;

  – Meža valsts reģistrā atzīmētās zemes kategorijas “21”, “22”, “23”, kura 
  rezultāts kodēts ar `710`;

  – Meža valsts reģistrā atzīmētās zemes kategorijas “41”, “42”, kura rezultāts 
  kodēts ar `730`.

- klase `800` - smiltāji un kūdras lauki: apvienojot ar smiltājiem, virsājiem un 
kūdras karjeriem saistītos slāņus, aizpildīta secībā - tā kā šī ir augstākā klase, 
tā dominē tikai pār robu aizpildīšanai izmantoto Dynamic World. Šīs klases izveidošanai 
apvienoti (pārklāšanās secībā):

  – topogrāfiskās kartes slāņa `landus_A` klases “poligons_Smiltājs”, 
  “poligons_Kūdra”, kura rezultāts kodēts ar `800`;

  – Meža valsts reģistrā atzīmētās zemes kategorijas “33”, “34”, kura rezultāts 
  kodēts ar `800`.

Komandu rindas pareizā secībā apvieno iepriekš izveidotos slāņus ar ainavas klasēm 
un nodrošina robu aizpildīšanu ar atbilstoši klasificētu Dynamic World 2023. gada aprīļa-augusta 
kompozītu, kuru, pēc maskēšanas tikai analīzes telpai, failā `Ainava_vienk_mask.tif` 
saglabā turpmākam darbam.

## Zālāji visi

Rastrs ar šūnas izmēru 10 m un segumu visai Latvijas teritorijai.

- Vērtība 1 apzīmē šūnas, kurās vienkāršās ainavas slānī ir reģistrēti zālāji (klase 330);

- Vērtība 0 - pārējās Latvijas teritorijā esošās šūnas.

## Papuves

Rastrs ar šūnas izmēru 10 m un segumu visai Latvijas teritorijai.

- Vērtība 1 apzīmē šūnas, kurās vienkāršās ainavas slānī ir reģistrētas papuves (klase 320);

- Vērtība 0 - pārējās Latvijas teritorijā esošās šūnas.

## Aramzemes

Rastrs ar šūnas izmēru 10 m un segumu visai Latvijas teritorijai.

- Vērtība 1 apzīmē šūnas, kurās vienkāršās ainavas slānī ir reģistrēta klase 310;

- Vērtība 0 - pārējās Latvijas teritorijā esošās šūnas.

## Oligotrofi susinātie meži

Rastrs ar šūnas izmēru 10 m un segumu visai Latvijas teritorijai.

- Vērtība `656` apzīmē šūnas, kurās vienkāršās ainavas maskā ir reģistrētas klases 
diapazonā no `600` līdz `700` un Meža valsts reģistra Meža inventarizācijas failā laukā mt 
norādītas vērtības: 17=viršu ārenis, 18=mētru ārenis, 22=viršu kūdrenis, 23=mētru kūdrenis;

- Vērtība 0 - pārējās Latvijas teritorijā esošās šūnas.


## Oligotrofi sausieņu un slapjaiņu meži

Rastrs ar šūnas izmēru 10 m un segumu visai Latvijas teritorijai.

- Vērtība `651` apzīmē šūnas, kurās vienkāršās ainavas maskā ir reģistrētas klases 
diapazonā no `600` līdz `700` un Meža valsts reģistra Meža inventarizācijas failā 
laukā mt norādītas vērtības: 1=sils, 2=mētrājs, 3=lāns, 7=grīnis, 8=slapjais mētrājs;

- Vērtība 0 - pārējās Latvijas teritorijā esošās šūnas.


## Mezotrofi sausieņu un slapjaiņu meži

Rastrs ar šūnas izmēru 10 m un segumu visai Latvijas teritorijai.

- Vērtība `652` apzīmē šūnas, kurās vienkāršās ainavas maskā ir reģistrētas klases 
diapazonā no `600` līdz `700` un Meža valsts reģistra Meža inventarizācijas failā 
laukā mt norādītas vērtības: 4=damaksnis, 9=slapjais damaksnis;

- Vērtība 0 - pārējās Latvijas teritorijā esošās šūnas.


## Eitrofi susinātie meži

Rastrs ar šūnas izmēru 10 m un segumu visai Latvijas teritorijai.

- Vērtība `657` apzīmē šūnas, kurās vienkāršās ainavas maskā ir reģistrētas klases 
diapazonā no `600` līdz `700` un Meža valsts reģistra Meža inventarizācijas failā 
laukā mt norādītas vērtības: 19=šaurlapju ārenis, 21=platlapju ārenis, 
24=šaurlapju kūdrenis, 25=platlapju kūdrenis;

- Vērtība 0 - pārējās Latvijas teritorijā esošās šūnas.

##  Izcirtumi un jaunaudzes līdz 5 m

Rastrs ar šūnas izmēru 10 m un segumu visai Latvijas teritorijai.

- Vērtība `661` apzīmē šūnas, kurās vienkāršās ainavas maskā ir reģistrētas klases 
diapazonā no `600` līdz `700` un

  – Meža valsts reģistra Meža inventarizācijas failā laukā `zkat` norādītas 
  vērtības “16” vai [“10” un valdošās sugas augstums ir līdz 5 m];

  – vienkāršās ainavas maskā ir reģistrēta klase `610` (Global Forest Watch izzudušais 
  koku vainagu segums kopš 2020. gada un izcirtumi un iznīkušās mežaudzes no 
  Meža valsts reģistra);

- Vērtība 0 - pārējās Latvijas teritorijā esošās šūnas.

## Šaurlapju

Rastrs ar šūnas izmēru 10 m un segumu visai Latvijas teritorijai.

- Vērtība `672` apzīmē šūnas, kurās vienkāršās ainavas maskā ir reģistrētas klases 
diapazonā no `600` līdz `700` un Meža valsts reģistra Meža inventarizācijas failā 
laukā `zkat` norādītas vērtības “10” un kokaudzes pirmajā stāvā šaurlapju 
sugu (s1* apzīmējumi: “4”,“6”,“8”,“9”,“19”,“20”,“21”,“32”,“35”,“50”,“68”) krāja 
veido vismaz 75% no kopējās krājas, pēc Skujkoku kritērija pielietošanas;

Vērtība 0 - pārējās Latvijas teritorijā esošās šūnas.

## Jauktu koku jaunaudzes, vidēja vecuma un briestaudzes

Rastrs ar šūnas izmēru 10 m un segumu visai Latvijas teritorijai.

- Vērtība `687` apzīmē šūnas, kurās vienkāršās ainavas maskā ir reģistrētas klases 
diapazonā no `600` līdz `700` un Meža valsts reģistra Meža inventarizācijas failā 
laukā `vgr` norādītas vērtības “1”, “2” vai “3” un kokaudzes pirmā stāva krājas 
klasifikācija atbilst Jauktu koku;

- Vērtība 0 - pārējās Latvijas teritorijā esošās šūnas.


## Netaksētās mežaudzes

Rastrs ar šūnas izmēru 10 m un segumu visai Latvijas teritorijai.

- Vērtība `1` apzīmē šūnas, kurās vienkāršās ainavas slānī ir reģistrēti 
meži (klase `630`), kas neatrodas Meža valsts reģistra Meža inventarizācijas 
failā laukā `zkat` ar vērtību “10” atzīmētajās vietās;

- Vērtība 0 - pārējās Latvijas teritorijā esošās šūnas.

## Vasarnīcas un mazdārziņi

Rastrs ar šūnas izmēru 10 m un segumu visai Latvijas teritorijai.

- Vērtība `1` apzīmē šūnas, kurās vienkāršās ainavas slānī ir reģistrētas klases 
diapazonā no `400` līdz `500`;

- Vērtība `0` - pārējās Latvijas teritorijā esošās šūnas.

## Apbūves un koku mala


Rastrs ar šūnas izmēru 10 m un segumu visai Latvijas teritorijai, pārklasificējot 
vienkāršās ainavas slānī reģistrētās vērtības:

- vērtība `500` saglabāta vienkāršās ainavas slāņa klasei `500`;

- vērtība `634` piešķirta vienkāršās ainavas slāņa klašu diapozonam [`630`,`640`];

- pārējās Latvijas teritorijā esošās šūnas aizpildītas ar NA.

## Aramzemju (visu) malas

Rastrs ar šūnas izmēru 10 m un segumu visai Latvijas teritorijai, pārklasificējot 
vienkāršās ainavas slānī reģistrētās vērtības:

- vērtība `310` saglabāta vienkāršās ainavas slāņa klasei `310`;

- pārējās Latvijas teritorijā esošās šūnas aizpildītas ar 0.



## LIZ, izcirtumu un jaunaudžu (<5m) malas ar kokiem >5m

Rastrs ar šūnas izmēru 10 m un segumu visai Latvijas teritorijai, pārklasificējot 
vienkāršās ainavas slānī reģistrētās vērtības:

- vērtība `634` piešķirta vienkāršās ainavas slāņa klašu diapozonam [`630`, `640`];

- vērtība `1` piešķirta vienkāršās ainavas slāņa klašu diapozoniem:

  – [`300`, `400`);

  – [`600`, `620`];

- pārējās Latvijas teritorijā esošās šūnas aizpildītas ar NA.