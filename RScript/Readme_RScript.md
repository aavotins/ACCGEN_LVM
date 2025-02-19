# Readme_RScript: Komandu rindas darba izpildei

Šajā direktorijā ir apkopoti R komandu rindu faili, kas nepieciešama vistu vanaga 
izplatības modelēšanas reproducēšanai. Faili ir numurēti to izpildes secībā. 
Šī apraksta beigās ir sniegts konspektīvs kopsavilkums komandu rindu failos veiktajiem 
uzdevumiem. Daļā gadījumu - galvenokārt, saistībā ar ievades ģeodatu ieguvi - plašāki 
apraksti ir piedāvāti komandu rindu failos kā ceļš uz `Readme_*.md` failu (relatīvais 
ceļš no `*.Rproj` faila), kurā ir sniegts paskaidrojums, to saistot ar vietu repozitorijā, 
kurā šiem datiem ir jāatrodas. Daļā gadījumu plaši apraksti nav dublēti, tiem sniegta 
saita uz citos resursos izvietotajiem.

Uzņemot personīgu atbildību, komandu rindas drīkst mainīt. To izstrādes gaitā, 
domājot par to noformējumu, pieņemts lēmums izmantot mazāk funkcionālās 
programmēšanas, lai uzlabotu lasāmību un atvieglotu iespēju izmantot tikai 
atsevišķas daļas, nevis obligāti visu pilno darba plūsmu. Tomēr ir jāuzsver, ka 
par šādu praksi un tās sniegto rezultātu atbildība ir paša lietotāja.

Komandu rindu faili:

- `00_pakotnes.R` veic šajā repozitorijā izmantot pakotņu pieejamības pārbaudi un 
veic instalāciju, ja tā ir nepieciešama. Reproducējot šī repozitorija darba plūsmu, 
izmantojot pamata aprakstā sniegtos koteinerus, nav sagaidāmas instalācijas kļūdas, 
ko nevar garantēt ārpus tiem. Visas pakotnes un komandu rindas ir pārbaudītas 
vairākās operētājsistēmās (MS Windows 10, MS Windows 11, Ubuntu 20.04 LTE, Fedora 46, 
MacOS Sequoia 15), tomēr nepieciešamais piepūles apjoms sekmīgai 
instalācijai un darbības nodrošināšanai var būt nomācošs, tādēļ rekomendēju 
izmantot repozitorija pamata aprakstā ieteiktos konteinerus;

- `01_Templates.R` sagatavo harmonizētas apstrādes failus. Darba 
gaita aprakstīta `./Templates/Readme_Templates.md`;

- `02_GeodatiSakums.R` veic priekšapstrādi daļai `./IevadesDati` esošajiem failiem. 
Šos failus nepieciešams iegūt personīgi un izvietot failu kopā atbilstoši 
`./IevadesDati/Readme_IevadesDati.md` aprakstam;

- `03_GeodatiStarprezultati.R` veic `./IevadesDati` un to priekšapstrādes produktu 
tālāku apstrādi, sagatavojot dažāda līmeņa produktus, kas nepieciešami vistu vanaga 
izplatības modeļa parametrizācijā izmantoto ekoģeogrāfisko mainīgo izveidošanai. 
Lielākā daļa produktu ir rastra slāņi ar 10 m pikseļa izmēru, kas 
tiek ievietoti `./Rastri_10m`, bet starp tiem ir arī atsevišķi citi produkti;

- `04_VidesParmainas.R` sagatavo ikgadējo vides pārmaiņu apjoma raksturojumu 
harmonizētā 100 m vektordatu režģa šūnās un 3000 m rādiusā ap to centriem. 
Nepieciešams novērojumu atlasei modelēšanai;

- `05_EGV.R` komandu rindas 33 vistu vanaga izplatības modeļa parametrizācijā 
izmantoto ekoģeogrāfisko mainīgo sagatavošanai. Visi putnu sugu izplatības 
modelēšanai izstrādātie EGV ir raksturoti https://aavotins.github.io/PutnuSDMs_gramata/Chapter5.html, 
kur ir niegtas saites to lejupielādei. Vistu vanaga izplatības modeļa parametrizācijā 
izmantotie, ir pievienoti projekta 2024. gada pārskata elektroniskajā pielikumā;

- `06_NoverojumuSagatavosana.R` veic vistu vanaga izplatības modelēšanai izmantojamo 
sugas klātbūtnes vietu atlasi ārēji harmonizētā datu kopā, kurā apkopoti šī projekta 
ietvaros iegūtie, dabas novērojumu portālā dabasdati.lv ziņotie, Dabas aizsardzības 
pārvaldes dabas datu pārvaldības sistēmā OZOLS reģistrētie un individuālu dabas 
aizsardzības ekspertu putnu jomā un gredzenotāju novērojumi. Atlases gaita ir nedaudz 
skaidrota ar komentāriem komandu rindu failā, tās ietvaros nodalīta modeļa apmācības 
datu kopa no modeļa neatkarīgai testēšanai izmantojamās, sagatavotas vidi-kopumā 
aprakstošas vietas, kuras tāpat kā klātbūtnes vietas stratificētas modeļa apmācībai 
un neatkarīgai testēšanai izmantojamās;

- `07_EGVizvele.R` atkārto izmantoto procedūru vistu vanaga izplatības modeļa 
parametrizācijā izmantojamo ekoģeogrāfisko mainīgo izvēlei. Sākumā pētnieku komandā 
par sugas izplatību potenciāli ietekmējošiem izvēlēti 117 mainīgie, no kuriem 
tikai 87 nebija multikolineāri $(\text{VIF} \le 10)$. Šie mainīgie tālāk izmantoti 
indikatīvā modeļa izveidošanai, kura turpmākā parametrizācijai izvēlēti tikai tie, 
kuriem indikatīvā (n=9) permutāciju procedūrā vidējā aritmētiskā ietekme bija 
vismaz 1%. Šo komandu izpildes gaitā sagatavotā tabula ir ievietota šajā repozitorijā 
`./SuguModeli/BestVarImp/BestVarImp_ACCGEN.xlsx`;

- `08_SDM.R` atkārto vistu vanaga izplatības modeļa parametrizāciju, labākās 
parametrizācijas izvēli, sagatavo tās salīdzinošo (ar pārējām parametrizācijām) 
raksturojumu, veic dzīvotņu piemērotības projekcijas kartes saglabāšanu GeoTIFF failā 
un ievieš labākās parametrizācijas izvērtējumu saistībā ar nulles modeļiem. Teorētiskais 
pamatojums ir sniegts projekta 2024. gada pārskatā;

- `09_Prioritizacija.R` sagatavo komandu rindu failus vietu (anlīzes rastra šūnu 
ar malas garumu 100 m) prioritizāciju vistu vanaga aizsardzībai, izmantojot Zonation 
ceturto versiju ar saskaitāmā ieguvuma funkciju (*additive benefit function*) ar 100 
zemākās nozīmes šūnu novākšanu ik iteratīvā procesa solī, to darot no jebkuras 
vietas ainavā (nevis tikai no malām). Prioritizācija veikta divos variantos:

  -- individuālās šūnās, ņemot vērā to nozīmi dzīvotņu piemērotības aizsardzībai 
  Latvijā kopumā;
  
  -- ik šūnas nozīmi dzīvotņu piemērotības aizsardzībai Latvijā kopumā, aprēķinot 
  ar fokālas Gausa funkcijas, kuras mēroga parametrs ir minimālais vidējais 
  ligzdošanas iecirkņa rādiuss (pieņemot apli) telemetrijas pētījumos, palīdzību.
  
Komandu rindu fails satur arī komandas 2024. gada pārskatā izmantoto attēlu 
noformēšanai. Prioritizācijas rezultāti ir pievienoti 2024. gada pārskatam kā 
elektroniskie pielikumi.