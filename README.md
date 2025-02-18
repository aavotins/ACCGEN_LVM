# Vistu vanaga izplatības modelēšana


Šajā repozitorijā ir sniegtas komandu rindas, kas izmantotas vistu vanaga 
izplatības modeļa sagatavošanai Latvijas Universitātē īstenotā AS "Latvijas 
valsts meži" pasūtītā zinātniskās izpētes projekta "Vistu vanaga *Accipiter gentilis* 
monitoringa pilnveidošana un dzīvotņu piemērotības telpiskā modeļa izveide" otrā 
darba uzdevuma ietvaros. Šis darba uzdevums īstenots temporāli pārklājoties un pēc būtības 
papildinot divus citus aptveramo sugu skaita un veicamo uzdevumu ziņā daudz 
plašākus projektus. Kopējie putnu sugu izplatības modelēšanā pieņemtie lēmumi 
un to ieviešana iztirzāta [šajā e-dokumentā](https://aavotins.github.io/PutnuSDMs_gramata/). 
Šis repozitorijs sagatavots, lai fokusētu tieši vistu vanaga izplatības modelēšanai 
un modeļa turpmākai ieviešanai nepieciešamās komandu rindas.

Komandu rindas ir veidotas, izmantojot relatīvos ceļus, pieņemot datu failu 
izvietojumu, kāds ir iezīmēts šajā repozitorijā. Esošā direktoriju struktūra:

1. [Templates](./Templates/Readme_Templates.md) ar vairākām apakšdirektorijām. Tajās ievietojamais saturs 
skaidrots atbilstošajos `*.md` failos. Šis repozitorijs nesniedz piekļuvi datiem, 
jo ievērojama daļa no tiem ir ierobežotas pieejamības - to sagādāšana un atbilstoša 
izvietošana ir katra šī darba reproducētāja uzdevums;

2. [IevadesDati](./IevadesDati/Readme_IevadesDati.md) ar vairākām apakšdirektorijām. Tajās ievietojamais saturs 
skaidrots atbilstošajos `*.md` failos. Šis repozitorijs nesniedz piekļuvi datiem, 
jo ievērojama daļa no tiem ir ierobežotas pieejamības - to sagādāšana un atbilstoša 
izvietošana ir katra šī darba reproducētāja uzdevums;

3. [Rastri_10m](./Rastri_10m/Readme_Rastri10m.md), kurā tiks ievietoti ievades ģeodatu apstrādes 
starprezultāti;

4. [Rastri_500m](./Rastri_500m/Readme_Rastri500m.md), kurā tiks ievietoti ievades ģeodatu apstrādes 
starprezultāti;

5. [Rastri_100m](./Rastri_100m/Readme_Rastri100m.md) ar vairākām apakšdirektorijām, kurās komandu 
rindu izpildes rezultātā tiks ievietoti ekoģeogrāfiskei mainīgie. Saturs 
skaidrots atbilstošajos `*.md` failos.;

6. [VidesParmainas](./VidesParmainas/Readme_VidesParmainas.md) ar vairākām apakšdirektorijām. Tajās 
ievietojamais saturs skaidrots atbilstošajos `*.md` failos. Daļa šīs direktorijas 
satura ir jāiegūst pašiem reproducētājiem, daļa tiks radīta komandu rindu izpildes 
rezultātā;

7. [SuguModeli](./SuguModeli/Readme_SuguModeli.md) ar vairākām apakšdirektorijām, kurās izvietoti sugas 
izplatības modelēšanas un vietu prioritizācijas rezultāti;

8. [RScript](./RScript/), kurā atrodas izpildīšanas secībā numurēti R komandrindu 
faili. Tie visi kalpo vienam mērķim - datu sagatavošanai sugas izplatības 
modelēšanai, pašai modelēšanai un tai sekojošajai vietu prioritizēšanai un pēc 
būtības ir apvienojami vienā failā. Tomēr ir veidota vairāku secīgi izpildāmu 
failu struktūra, lai atvieglotu rezultātu turpmāko lietojumu - izpildot tikai tās 
daļas, kuras ir nepieciešams.

Komandu rindas ir izstrādātas un testētas dažādās operētājsistēmās - gan individuāli 
uzturētās, gan skaitļošanas centros, izmantojot konteinerizētu vidi. Ņemot vērā 
procesēšanas apjomu, rekomendēju izmantot skaitļošanas centru pakalpojumus, kuros 
izmantot pārbaudītus konteinerus:

- visām darbībām, izņemot prioritizāciju, ir jābūt izpildāmām 
[rocker/geospatial](https://hub.docker.com/r/rocker/geospatial) konteinerā. 
Visas komandu rindas šajā repozitorijā ir pārbaudītas 2024-11-15 pieejamajā 
versijā;

- vietu prioritizācija ir veikta [Zonation 4. versijā](https://github.com/cbig/zonation-core), 
kura konteinerizētā veidā ir pieejama no `docker://ghcr.io/wkmor1/zig4`.

Šajā projektā izmantots Latvijas Universitātes Skaitliskās modelēšanas institūta HPC, 
kurā konteineri izmantoti ar `singularity/3.7.1` moduli. To lejupielādei un 

- `singularity pull geospatial2024.simg docker://rocker/geospatial:4.4.2`, kas 
izveido darbam pieejamu konteineru "geospatial2024.simg". Ne visas šajā projektā 
izmantotās R pakotnes ir uzreiz konteinerā pieejamās, tādēļ R komandu rindu faili 
pārbauda to pieejamību un veic instalāciju, ja tā ir nepieciešama. Ir pārbaudīts, 
ka šajā konteinerī ir visas nepieciešamās sistēmas atkarības;

- `singularity pull docker://ghcr.io/wkmor1/zig4`, kas 
izveido darbam pieejamu konteineru "zig4_latest.sif".

Lai samazinātu reproducēšanas darba apjomu, šajā repozitorijā ir sniegta tikai 
suga izplatības modelēšanas beigu modelī izmantoto ekoģeogrāfisko mainīgo 
sagatavošanas procedūras.
