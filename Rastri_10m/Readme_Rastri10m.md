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

