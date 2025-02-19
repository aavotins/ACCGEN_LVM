# Koku dati

Sastāv no divām daļām.

## The Global Forest Watch

The Global Forest Watch (GFW) ir plaši pazīstam produkts, kurš raksturo koku 
vainagu segumu 2000. gadā, tā ikgadējo pieaugumu no 2001. gada līdz 2012. gadam 
un zudumu katrā gadā kopš 2001. gada līdz aktuālajai versijai, kas ik gadu tiek 
papildināta (Hansen et al., 2013). Dati ir pieejami gan projekta [mājaslapā](https://data.globalforestwatch.org/documents/941f17325a494ed78c4817f9bb20f33a/explore), 
gan [GEE](https://developers.google.com/earth-engine/datasets/catalog/UMD_hansen_global_forest_change_2023_v1_11), 
kurā tie ir izstrādāti. Šajā projektā izmantota v1.11, kurā pēdējais koku 
izzušanas datēšanas gads ir 2023, to sagatavojot lejupielādei GEE platformā ar 
[šo replicēšanas skriptu](https://code.earthengine.google.com/1878026f59c5118080cac0a8c976c744?noload=true). 
Lai izmantotu šo skriptu, ir nepieciešams [GEE konts un projekts](https://code.earthengine.google.com/register) 
un pietiekošs apjoms vietas Google Drive diskā. Izpildot komandrindas tiks 
piedāvāta lejuplāde failam, kuru nepieciešams saglabāt Google diskā.

Pēc komandrindu izpildes un rezultātu sagatavošanas Google Drive diskā, darba 
cietajā diskā ir lejupielādējams viens fails un tas pielāgojams references rastram. 
Failu ir jāizvieto direktorijā `./IevadesDati/koki/RAW/`, to ir jānosauc par `TreeCoverLoss.tif`

## Palsar Forests

*Palsar Forests* resurss ir balstīts PALSAR-2 sintētiskās aprertūras radara (SAR) 
atstarojumu klasifikācijā meža un nemeža zemēs ar 25 m pikseļa izšķirtspēju. Par 
mežu tiek klasificētas vismaz 0.5 ha plašas ar kokiem klātas teritorijas, kurās 
koku (vismaz 5 m augstu) seguma ir vismaz 10% (Shimada et al., 2013). Dati ir 
pieejami [GEE](https://developers.google.com/earth-engine/datasets/catalog/JAXA_ALOS_PALSAR_YEARLY_FNF4). 
Šajā projektā izmantota 4-klašu versija (1=Dense Forest, 2=Non-dense Forest, 3=Non-Forest, 4=Water), 
kurā pēdējais koku seguma datēšanas gads ir 2020, to sagatavojot lejupielādei GEE 
platformā ar šo [replicēšanas skriptu](https://code.earthengine.google.com/3ec78ab057e6c8910cb1546002132b34?noload=true). 
Lai izmantotu šo skriptu, ir nepieciešams GEE konts un projekts un pietiekošs 
apjoms vietas Google Drive diskā. Izpildot komandrindas tiks piedāvāta 
lejuplāde failam, kuru nepieciešams saglabāt Google diskā.

Pēc komandrindu izpildes un rezultātu sagatavošanas Google Drive diskā, 
ir lejupielādējami četri faili. Tos nepieciešams projektēt atbilstībai references 
rastram un apvienot. Šajā resursā koki ir kodēti divās grupās: 1=Dense Forest 
un 2=Non-dense Forest, kuras nepieciešams apvienot un pārējo 
pārvērst par iztrūkstošajām vērtībām.

Lejupielādētos failus ir jāizvieto direktorijā `./IevadesDati/koki/RAW/`, to nosaukumi 
nav jāmaina - jāsaglabā `ForestNonForest-0000023296-0000023296.tif`, `ForestNonForest-0000023296-0000000000.tif`, 
`ForestNonForest-0000000000-0000023296.tif`, `ForestNonForest-0000000000-0000000000.tif`.


Lai gan šī resursa dati raksturo situāciju 2020. nevis 2023. gadā, tie ir izmantoti, 
jo koku vainagu seguma izzušanu raksturošanai ir pieejami The Global Forest Watch dati, 
bet vainagu parādīšanās nav tik strauja, lai būtu nozīmīgas izmaiņas trīs gadu laikā, 
un šis gads atrodas pa vidu ar novērojumiem aptvertajam laika periodam (2017.-2023. gadi).