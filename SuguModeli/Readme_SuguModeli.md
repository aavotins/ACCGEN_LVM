# vistu vanaga izplatības modeļa rezultāti un starprezultāti

Direktorija satur 18 apakšdirektorijas, kurām ir arī dziļāka hierarhija, ar modeļa 
rezultātiem un starprezultāti, kādie rodas, izpildot komandu rindas. Failu apjoma dēļ, 
tie nav ievietoti šajā repozitorijā, bet ir pieejami šajā 
saitē: https://drive.google.com/drive/folders/11ZilaN2AiS1LOYe-GalwyYDjoWCpHkPz?usp=sharing

Direktorijas un konspektīvs to satura apraksts:

- `ApmacibuDati` ar vairākām apakšdirektorijām:

  - `IzvelesAtteli` - no vairākām daļām sastāvošs attēls, kurā demonstrēta novērojumu 
  atlases gaita (*.png);
  
  - `TestingBacground` - sugas izplatības modeļa apmācībai izmantotie vidi-kopumā 
  raksturojošie punkti (*.parquet);
  
  - `TestingPresence` - sugas izplatības modeļa apmācībai izmantotie sugas klātbūtni 
  raksturojošie punkti (*.parquet);
  
  - `TrainingBackground` - sugas izplatības modeļa neatkarīgai testēšanai izmantotie 
  vidi-kopumā raksturojošie punkti (*.parquet);
  
  - `TrainingPresence` - sugas izplatības modeļa neatkarīgai testēšanai izmantotie 
  sugas klātbūtni raksturojošie punkti (*.parquet);

- `Beigam_IzvelesAttels` - sugas izplatības modeļa parametrizācijas izvēles un izvērtējuma
attēli (*.png);

- `Beigam_KarteNebal` - sugas izplatības modeļa labākās parametrizācijas projekcijas 
kartes vizualizācija (*.png);

- `BestComb` - sugas izplatības modeļa labākās parametrizācijas krosvalidāciju modeļa 
kombinētais rezultāts (*.RDS);

- `BestCV` - sugas izplatības modeļa labākās parametrizācijas krosvalidāciju modelis (*.RDS);

- `BestHSbinaryMaps` - sugas izplatības modeļa labākās parametrizācijas 
dzīvotņu piemērotības projekcijas binarizēta versija piemērotajās un nepiemērotajās, 
izmantojot vienādas sensitivitātes un specifiskuma slieksni (*.tif);

- `BestHSmap` - sugas izplatības modeļa labākās parametrizācijas 
dzīvotņu piemērotības projekcija (*.tif);

- `BestROCs` - neapstrādāta ROC līkne (*.RDS);

- `BestThresholds` - biežāk lietotie sliekšņa līmeņi (un to izvērtējums) dzīvotņu 
piemērotības projekciju klasifikācijai (*.xlsx);

- `BestVarImp` - vistu vanaga izplatības modelēšanai sākotnēji izvēlētie EGV, to 
neatkarības novērtējums, ietekme indikatīvajā modelī, ietekme par labāko parametrizāciju 
atzītajā modelī un atkārtots neatkarības izvērtējums (*.xlsx);

- `EGVselection` - sākotnējie vistu vanaga izplatības modelēšanai izvēlētie EGV (*.xlsx);

- `GridSearch_Models` - vistu vanaga izplatības modeļa parametrizācija ar visiem 
tās ietvaros sagatavotajiem krosvalidāciju modeļiem (*.RDS);

- `GridSearch_Tables` - vistu vanaga izplatības modeļu parametrizāciju rezultāti 
(*.xlsx);

- `MarginalResponses` - labākās vistu vanaga izplatības modeļa parametrizācijā iekļauto 
EGV ietekme uz dzīvotņu piemērotību sugai, pārējos EGV marginalizējot vidējam 
aritmētiskajam stāvoklim (*.png);

- `Null_models` - labākās vistu vanaga izplatības modeļa parametrizācijas 
izvērtējums pret nejaušību  (*.RDS);

- `Null_reference` - labākās vistu vanaga izplatības modeļa parametrizācijas, 
kas izstrādāta {SDMtune}, implementācija {ENMeval}, uz kuras pamata, veidot 
salīdzinājumus ar nulles modeļiem (*.RDS);

- `Pic_VarImp` - labākajā vistu vanaga izplatības modeļa parametrizācijā iekļauto 
EGV nozīme dzīvotņu piemērotības raksturošanā 99 permutāciju procedūrā (vidējais 
aritmētiskias ar standartnovirzi) un EGV savstarpējās neatkarības raksturojums 
(VIF vērtības) attēla labajā pusē (*.png);

- `Prioritisation` ar apakšdirektorijām:

  - `Pics` - vietu nozīmes sugas populācijas aizsardzībā ranžējums - divu pieeju 
  rezultāti apvienoti vienā attēlā (*.png);
  
  - `SingleSpecies_site` - direktorija, kas satur vairākus objektus, kas raksturo 
  vietu prioritizācijas populācijas aizsardzībai uzdevumu un rezultātus, izmantojot 
  saskaitāmā ieguvuma funkciju, kurā tiek vērtētas individuālas šūnas kopējās 
  šķietamās populācijas (dzīvotņu relatīvās piemērotības) un ar to saistīto 
  telpisko izzušanas risku aprēķināšanai:
  
  - `SingleSpecies_site/site_ACCGEN.sh` - vadības fails prioritizācijas uzdevumam;
  
  - `SingleSpecies_site/site_ACCGEN/FeaturesList.spp` - prioritizācijas uzdevumam sniegtā informācija 
  par sugu (noklusējuma vērtības, kas netiek izmantotas) un ceļš uz projicētās 
  dzīvotņu piemērotības slāni (relatīvi pret *.spp failu);
  
  - `SingleSpecies_site/site_ACCGEN/Settings.dat` - prioritizācijas uzdevumam sniegtās kopējās norādes: 
  izmantot saskaitāmā ieguvuma funkciju, ik iterācijā atteikties no 100 zemākās 
  nozīmes šūnām pirms pārrēķināt nozīmi ik atlikušajās šūnās, pieļaut šūnu izslēgšanu 
  no jebkuras vietas ainavā, neiekļaut nejauši izvēlētas malas;
  
  - `SingleSpecies_site/site_ACCGEN/outputs` - vietu prioritizācijas rezultātu direktorija;
  
  - `SingleSpecies_site/site_ACCGEN/outputs/site_ACCGEN.ABF_.curves.txt` - Zonation standarta 
  izvade, kurā raksturota aizsargātās teritorijas īpatsvara (ar pieeaugošu nozīmes 
  vērtību) saistība ar aizsargāto populāciju un sugas izzušanas risku;
  
  - `SingleSpecies_site/site_ACCGEN/outputs/site_ACCGEN.ABF_.features_info.txt` - Zonation 
  standarta ievades slāņu apraksta;
  
  - `SingleSpecies_site/site_ACCGEN/outputs/site_ACCGEN.ABF_.jpg` - Zonation izvades 
  apraksta fails ar programmas noklusējuma vizualizāciju vietu nozīmes sugas 
  aizsardzībā rankiem;
  
  - `SingleSpecies_site/site_ACCGEN/outputs/site_ACCGEN.ABF_.rank.compressed.tif` - ģeoreferencēta 
  vietu nozīme sugas aizsardzība (relatīvie ranki ar pieaugošu nozīmi);
  
  - `SingleSpecies_site/site_ACCGEN/outputs/site_ACCGEN.ABF_.run_info.txt` - Zonation izvades 
  apraksta fails;
  
  - `SingleSpecies_site/site_ACCGEN/outputs/site_ACCGEN.ABF_.wrscr.compressed.tif` - Zonation 
  izvades fails, kurš nav informatīvs vienas sugas gadījumā;
  
  - `SingleSpecies_site/site_ACCGEN/outputs/site_ACCGEN.txt` - Zonation izvades apraksta fails;
  
    
  - `SingleSpecies_DS` - direktorija, kas satur vairākus objektus, kas raksturo 
  vietu prioritizācijas populācijas aizsardzībai uzdevumu un rezultātus, izmantojot 
  saskaitāmā ieguvuma funkciju, kurā šūnu vērtības tiek vērtētas, izmantojot Gausa 
  funkciju ar mērogošanas parametru, kas raksturo minimālo vidējo sugas ligzdošanas 
  iecirkņa platību telemetrijas pētījumos, kopējās šķietamās populācijas (dzīvotņu 
  relatīvās piemērotības) un ar to saistīto telpisko izzušanas risku aprēķināšanai:
  
  - `SingleSpecies_DS/ds_ACCGEN.sh` - vadības fails prioritizācijas uzdevumam;
  
  - `SingleSpecies_DS/ds_ACCGEN/FeaturesList.spp` - prioritizācijas uzdevumam sniegtā informācija 
  par sugu (otrā vērtība raksturo Gausa funkcijas mērogošanas parametru, pārējās ir 
  noklusējuma vērtības, kas netiek izmantotas) un ceļš uz projicētās 
  dzīvotņu piemērotības slāni (relatīvi pret *.spp failu);
  
  - `SingleSpecies_DS/ds_ACCGEN/Settings.dat` - prioritizācijas uzdevumam sniegtās kopējās norādes: 
  izmantot saskaitāmā ieguvuma funkciju, ik iterācijā atteikties no 100 zemākās 
  nozīmes šūnām pirms pārrēķināt nozīmi ik atlikušajās šūnās, pieļaut šūnu izslēgšanu 
  no jebkuras vietas ainavā, neiekļaut nejauši izvēlētas malas;
  
  - `SingleSpecies_DS/ds_ACCGEN/outputs` - vietu prioritizācijas rezultātu direktorija;
  
  - `SingleSpecies_DS/ds_ACCGEN/outputs/site_ACCGEN.ABF_S100.curves.txt` - Zonation standarta 
  izvade, kurā raksturota aizsargātās teritorijas īpatsvara (ar pieeaugošu nozīmes 
  vērtību) saistība ar aizsargāto populāciju un sugas izzušanas risku;
  
  - `SingleSpecies_DS/ds_ACCGEN/outputs/site_ACCGEN.ABF_S100.features_info.txt` - Zonation 
  standarta ievades slāņu apraksta;
  
  - `SingleSpecies_DS/ds_ACCGEN/outputs/site_ACCGEN.ABF_S100.jpg` - Zonation izvades 
  apraksta fails ar programmas noklusējuma vizualizāciju vietu nozīmes sugas 
  aizsardzībā rankiem;
  
  - `SingleSpecies_DS/ds_ACCGEN/outputs/site_ACCGEN.ABF_S100.rank.compressed.tif` - ģeoreferencēta 
  vietu nozīme sugas aizsardzība (relatīvie ranki ar pieaugošu nozīmi);
  
  - `SingleSpecies_DS/ds_ACCGEN/outputs/site_ACCGEN.ABF_S100.run_info.txt` - Zonation izvades 
  apraksta fails;
  
  - `SingleSpecies_DS/ds_ACCGEN/outputs/site_ACCGEN.ABF_S100.wrscr.compressed.tif` - Zonation 
  izvades fails, kurš nav informatīvs vienas sugas gadījumā;
  
  - `SingleSpecies_DS/ds_ACCGEN/outputs/site_ACCGEN.txt` - Zonation izvades apraksta fails;
  


