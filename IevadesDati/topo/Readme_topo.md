# Topogrāfiskā karte

Latvijas Ģeotelpiskās informācijas aģentūras topogrāfiskās kartes M:10000 vekotrodatu 
ģeodatubāze studiju un pētniecības procesu nodrošināšanai Latvijas Universitātē 
saņemta 2016. gada jūlijā pēc licences līguma noslēgšanas. Tās aktālizēta (tas ir 
nepārtraukts process) versija ir pieejama publiskai apskatei, bet vektordatu 
pieejamība ir ierobežota.

Šajā projektā izmantoti sekojoši slāņi:

- `bride_L`, kurā raksturoti 3928 tilti kā linijveida objekti;

- `bridge_P`, kurā raksturoti 4551 tilti kā punktveida objekti

- `hidro_A`, kurā raksturoti 264439 ūdensobjektu plankumi;

- `hidro_L`, kurā raksturots grāvju tīkls un mazās upes;

- `landus_A`, kurā raksturots zemes segums un lietojums ar 1291781 laukumveida ģeometriju;

- `road_A`, kurā raksturoti 32094 ceļi, kas atzīmēti ar laukumu;

- `road_L`, kurā raksturoti dažāda platuma, tajā skaitā relatīvi šauri ceļi un takas;

- `swamp_A`, kurā raksturoti augstie purvi ar 48105 laukumveida objektu;

- `flora_L`, kurā raksturoti līnijveida koku un krūmu objekti,

kuri pārveidoti par geoparquet. Failu formāta maiņas ietvaros pārbaudītas 
ģeometrijas (tukšās, to validitāte, kas nepieciešamības gadījumā labota).

Failam direktoriju kokā ir jāatrodas `./IevadesDati/topo/Topo10_v3_12_07_2016.gdb/`, 
tā apstrādei izmantotās komandu rindas ir failā `./RScript/02_GeodatiSakums.R`