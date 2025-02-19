# Vides pārmaiņas

Vides pārmaiņas nepieciešamas novērojumu filtrēšanai. Daļēji tās būtu iegūstamas 
no Meža Valsts reģistra un LAD lauku informācija datiem, tomēr projektam nav pieejami 
ik gada raksturojumi (1) un šīs datubāzes neaptver visu valsts teritoriju (2), 
tādēļ nepieciešams neatkarīgs vērtējums. Tāda izstrādāšanai izmantoju Dynamic World 
aprīļa līdz augusta kompozīta ik gadam no 2017. līdz 2023. rezultātus un 
Global Forest Watch datus, raksturojot pārmaiņu apjomus analīzes šūnā un ligzdošanas 
iecirkņa rādiusa buferī ap analīzes šūnu centriem.

Saskaņā ar [Dynamic World izpēte](https://aavotins.github.io/PutnuSDMs_gramata/Chapter4.html) rezultātiem, 
ir vērts izmantot šo resursu vides kopējo pārmaiņu analīzē kopš 2017. gada. Par kopējām 
pārmaiņām uzskatīta jebkura izmaiņa Dynamic World klasē, to salīdzinot ik 10 m 
pikselim aprīļa-augusta sezonā starp katriem diviem secīgiem gadiem. Pārmaiņu apjoms 
raksturots kā platības īpatsvars 100 m šūnā vai putnu ligzdošanas iecirkņu rādiusu grupu 
buferos ap šīs šūnas centru. Tā kā pārmaiņas analizētas vienos un tajos pašos rastros, 
izmantojot dažādus laukumveida objektus, kurus nepieciešams apvienot vienā failā, 
katras ģeometrijas raksturojums iestrādāts lauku nosaukumos.

Kopumā līdzīga procedūra veikta koku vainagu seguma izzušanas apjoma (īpatsvara 
no telpas kopumā) raksturošanai. Tomēr šī informācija ir iestrādāta vienā rastra 
slānī, notikuma gadu norādot kā pikseļa vērtību. Tas ikgadējā samazinājuma apjoma 
aprēķināšanu apgrūtina, tomēr nepadara par neiespējamu (skatīt komandu rindas, 
specifiski - funkciju darbiba). Līdz ar ik gadu zudušā koku vainagu seguma 
īpatsvara no analīzes telpas platības iegūšanu, tā pievienota analizētajai 
ģeometrijai kā atsevišķs lauks katram notikuma gadam. Tāpat kā iepriekš - lauku 
nosaukumi harmonizēti, tajos iestrādājot analīzes telpas raksturojumu, un rezultāti 
pievienoti 100 m režģa atbilstošajām šūnām.

Šis uzdevums ir visai smagnējs no skaitļošanas viedokļa. Tā veikšanai ir jāieplāno 
pietiekošs apjoms datorresursu. Iniciāli tas īstenots, izmantojot 68 GiB RAM un 
daļā uzdevuma, aprēķinus veicot 12 paralēlos procesos, vairākās diennaktīs. 
Potenciāli, to ir iespējams izpildīt ātrāk, pārskatot zonālās statistikas lietojumu 
saistībā ar [Procesēšanas atvieglošana](https://aavotins.github.io/PutnuSDMs_gramata/Chapter5.html#Chapter5.1).
