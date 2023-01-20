*EXAMPLE SCRIPT FOR MULTIPLE IMPUTATIONS
BASED ON THE TUTORIAL ON https://stats.idre.ucla.edu/sas/seminars/multiple-imputation-in-sas/mi_new_1/
WE USE THE THREE-STEP APPROACH TO SCALE- AND ITEM-LEVEL IMPUTATION DESCRIBED AT THE END OF https://www.tandfonline.com/doi/full/10.1080/00273171.2012.640589?casa_token=rjqcZEspPIQAAAAA%3Abts_sITCn7vn01Eq0IwDO7eS81wHpS_6RKBl6-szS9CviLLE1tUssX3iYE61pzTvkphQA_mTORg
AUTHORS: LIVIA GUADAGNOLI, LUKAS VAN OUDENHOVE

APRIL-MAY 2021

*NOTE: This code is executed in Base SAS & data is imported from excel. There are slight differences in how different programs (e.g., Base SAS vs. SAS Studio) 
and different data file formats (e.g., excel, csv, jmp) import, label, and categorize the data. Therefore, using data programs other than SAS Base and/or importing the
data from a different file format could result in errors in the code.

-----------
DATA IMPORT
-----------;

*assign library to individual dataset folder;
libname refl_ind "C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\Data_files\SAS_Files\Individual_Variable_Datasets"; /* Liv's path */
libname refl_ind 'C:\Users\lukas\OneDrive - KU Leuven\proj-reflux-database\Data_files\SAS_Files\Individual_Variable_Datasets'; /* Lukas' path */

*set paths;
%let path=C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\Data_files\Excel_Files; /* Liv's path */
%let path=C:\Users\lukas\OneDrive - KU Leuven\proj-reflux-database\Data_files\Excel_Files; /* Lukas' path */

*import from excel;
proc import
	datafile="&path\Reflux_Database.xlsx"
	out=work.reflux_test
	dbms=xlsx;
run;

proc datasets library=work nolist;
   contents data=reflux_test;
run;
quit;

*NOTE: you have to check after import with proc datasets whether every variable is imported correctly as character/numeric, and some may need to be changed - see code below for individual variables;


*----------------
Formatting data: 
-----------------
We are rounding any variables that contain items with multiple decimal places to 1 or 2 deciminal places. 
This is done so we can identify the imputed values later on in the process (imputed values will have multiple decimal points);

Data work.reflux_test;
Set work.reflux_test;
BMI = round(BMI, 0.01);
up_gastr_acid_exp = round(up_gastr_acid_exp, 0.1);
Noct_gastric_acid_exp = round(Noct_gastric_acid_exp, 0.1);
Total_gastric_acid_exp = round(Total_gastric_acid_exp, 0.1);
Up_eso_acid_exp = round(Up_eso_acid_exp, 0.1);
Noct_eso_acid_exp = round(Noct_eso_acid_exp, 0.1);
Total_eso_acid_exp = round(Total_eso_acid_exp, 0.1);
up_vol_exp = round(up_vol_exp, 0.1);
noct_vol_exp = round(noct_vol_exp, 0.1);
Tot_vol_exp = round(Tot_vol_exp, 0.1);
__mixed = round(__mixed, 0.01);
SI_HB_acid = round(SI_HB_acid, 0.1);
SI_Regurg_acid = round(SI_Regurg_acid, 0.1);
SI_Regurg_nonacid = round(SI_Regurg_nonacid, 0.1);
SI_regurg_total = round(SI_regurg_total, 0.1);
RQ_totaal = round(RQ_totaal, 0.1);
PHQ15som = round(PHQ15som, 0.01);
PCCLcat = round(PCCLcat, 0.1);
PCCLpco = round(PCCLpco, 0.1);
PCCLint = round(PCCLint, 0.1);
PCCLext = round(PCCLext, 0.1);
Run;



*---------------------
----------------------
SCALE-LEVEL IMPUTATION
----------------------
----------------------

*----------------------
PREPARING TO CONDUCT MI
-----------------------;

*First step: Examine the number and proportion of missing values among your variables of interest;
proc means data=reflux_test nmiss; 
var wellbeing RQ_zuur RQ_bovenbuik RQ_onderbuik RQ_misselijkheid RQ_slaapstoornissen CNAQtot 
MAAGtotaal PHQ15som PHQ9dep LSAStot PTSDtotaal STAIStot STAITtot ASItot VSItot PASStot PCCLcat PCCLpco PCCLint PCCLext 
IAStot BAQtot NEO_N NEO_E NEO_O NEO_A NEO_C CIStot CTQtot;
run;

*create flag variables for missingness;
data reflux_test;
set reflux_test;
if wellbeing = . then wellbeing_flag = 1; else wellbeing_flag = 0;
if RQ_zuur = . then RQ_zuur_flag = 1; else RQ_zuur_flag = 0;
if RQ_bovenbuik = . then RQ_bovenbuik_flag = 1; else RQ_bovenbuik_flag = 0;
if RQ_onderbuik = . then RQ_onderbuik_flag = 1; else RQ_onderbuik_flag = 0;
if RQ_misselijkheid = . then RQ_misselijkheid_flag = 1; else RQ_misselijkheid_flag = 0;
if RQ_slaapstoornissen = . then RQ_slaapstoornissen_flag = 1; else RQ_slaapstoornissen_flag = 0;
if RQ_andere = . then RQ_andere_flag = 1; else RQ_andere_flag = 0;
if CNAQtot = . then CNAQtot_flag = 1; else CNAQtot_flag = 0;
if MAAGtotaal = . then MAAGtotaal_flag = 1; else MAAGtotaal_flag = 0;
if PHQ15som = . then PHQ15som_flag = 1; else PHQ15som_flag = 0;
if PHQ9dep = . then PHQ9dep_flag = 1; else PHQ9dep_flag = 0;
if LSAStot = . then LSAStot_flag = 1; else LSAStot_flag = 0;
if PTSDtotaal = . then PTSDtotaal_flag = 1; else PTSDtotaal_flag = 0;
if STAIStot = . then STAIStot_flag = 1; else STAIStot_flag = 0;
if STAITtot = . then STAITtot_flag = 1; else STAITtot_flag = 0;
if ASItot = . then ASItot_flag = 1; else ASItot_flag = 0;
if VSItot = . then VSItot_flag = 1; else VSItot_flag = 0;
if PASStot = . then PASStot_flag = 1; else PASStot_flag = 0;
if PCCLcat = . then PCCLcat_flag = 1; else PCCLcat_flag = 0;
if PCCLpco = . then PCCLpco_flag = 1; else PCCLpco_flag = 0;
if PCCLint = . then PCCLint_flag = 1; else PCCLint_flag = 0;
if PCCLext = . then PCCLext_flag = 1; else PCCLext_flag = 0;
if IAStot = . then IAStot_flag = 1; else IAStot_flag = 0;
if BAQtot = . then BAQtot_flag = 1; else BAQtot_flag = 0;
if NEO_N = . then NEO_N_flag = 1; else NEO_N_flag = 0;
if NEO_E = . then NEO_E_flag = 1; else NEO_E_flag = 0;
if NEO_O = . then NEO_O_flag = 1; else NEO_O_flag = 0;
if NEO_A = . then NEO_A_flag = 1; else NEO_A_flag = 0;
if NEO_C = . then NEO_C_flag = 1; else NEO_C_flag = 0;
if CIStot = . then CIStot_flag = 1; else CIStot_flag = 0;
if CTQtot = . then CTQtot_flag = 1; else CTQtot_flag = 0;
run;

*Second Step: Examine Missing Data Patterns among your variables of interest;
proc mi data=reflux_test nimpute=0;
var wellbeing RQ_zuur RQ_bovenbuik RQ_onderbuik RQ_misselijkheid RQ_slaapstoornissen RQ_andere CNAQtot 
MAAGtotaal PHQ15som PHQ9dep LSAStot PTSDtotaal STAIStot STAITtot ASItot VSItot PASStot PCCLcat PCCLpco PCCLint PCCLext 
IAStot BAQtot NEO_N NEO_E NEO_O NEO_A NEO_c CIStot CTQtot;
ods select misspattern;
run;

*Third Step: If necessary, identify potential auxiliary variables
a. check correlations between variables of interest;
proc corr data=reflux_test spearman;
var wellbeing RQ_zuur RQ_bovenbuik RQ_onderbuik RQ_misselijkheid RQ_slaapstoornissen RQ_andere CNAQtot 
MAAGtotaal PHQ15som PHQ9dep LSAStot PTSDtotaal STAIStot STAITtot ASItot VSItot PASStot PCCLcat PCCLpco PCCLint PCCLext 
IAStot BAQtot NEO_N NEO_E NEO_O NEO_A NEO_c CIStot CTQtot;
run;

*b. explore correlations with potential auxiliary variables;
proc corr data=reflux_test spearman;
var age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
with wellbeing RQ_zuur RQ_bovenbuik RQ_onderbuik RQ_misselijkheid RQ_slaapstoornissen RQ_andere CNAQtot 
MAAGtotaal PHQ15som PHQ9dep LSAStot PTSDtotaal STAIStot STAITtot ASItot VSItot PASStot PCCLcat PCCLpco PCCLint PCCLext 
IAStot BAQtot NEO_N NEO_E NEO_O NEO_A NEO_c CIStot CTQtot;
run;
*all very low correlation coefficients, none of them exceeding the |r| = 0.40 threshold recommended in the tutorial, so not very useful as auxiliary variables

*c. check associations between potential auxiliary variables and missingness for variables of interest;
proc npar1way data=reflux_test wilcoxon;
var age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
class wellbeing_flag;
run;
*none of the variables is associated with missingness on wellbeing;

proc npar1way data=reflux_test wilcoxon;
var age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
class RQ_zuur_flag;
run;
*associations with age, education, (marital status);

proc npar1way data=reflux_test wilcoxon;
var age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
class RQ_bovenbuik_flag;
run;
*associations with marital status, (education);

proc npar1way data=reflux_test wilcoxon;
var age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
class RQ_onderbuik_flag;
run;
*associations with age, occupation;

proc npar1way data=reflux_test wilcoxon;
var age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
class RQ_misselijkheid_flag;
run;
*associations with age, occupation;

proc npar1way data=reflux_test wilcoxon;
var age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
class RQ_slaapstoornissen_flag;
run;
*associations with education,(occupation), weight, BMI;

proc npar1way data=reflux_test wilcoxon;
var age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
class RQ_andere_flag;
run;
*associations with age, education,(weight), BMI, total_gastric_acid_exp;

proc npar1way data=reflux_test wilcoxon;
var age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
class CNAQtot_flag;
run;
*associations with gender, occupation, length;

proc npar1way data=reflux_test wilcoxon;
var age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
class MAAGtotaal_flag;
run;
*associations with age, marital status, education, occupation, length, total_eso_acid_exp;

proc npar1way data=reflux_test wilcoxon;
var age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
class PHQ15som_flag;
run;
*associations with age, gender, education, occupation, length;

proc npar1way data=reflux_test wilcoxon;
var age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
class PHQ9dep_flag;
run;
*associations with age, education, occupation;

proc npar1way data=reflux_test wilcoxon;
var age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
class LSAStot_flag;
run;
*associations with age, gender, education, occupation, length;

proc npar1way data=reflux_test wilcoxon;
var age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
class PTSDtotaal_flag;
run;
*associations with age, education, occupation;

proc npar1way data=reflux_test wilcoxon;
var age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
class STAIStot_flag;
run;
*associations with (education), length, (BMI), total_gastric_acid_exp, total_eso_acid_exp, total_nr_acid;

proc npar1way data=reflux_test wilcoxon;
var age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
class STAITtot_flag;
run;
*associations with age, education, occupation, length, BMI, tot_vol_exp;

proc npar1way data=reflux_test wilcoxon;
var age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
class ASItot_flag;
run;
*associations with education;

proc npar1way data=reflux_test wilcoxon;
var age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
class VSItot_flag;
run;
*associations with education, (length);

proc npar1way data=reflux_test wilcoxon;
var age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
class PASStot_flag;
run;
*associations with age, (gender), education, length; 

proc npar1way data=reflux_test wilcoxon;
var age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
class PCCLcat_flag;
run;
*associations with education, length;

proc npar1way data=reflux_test wilcoxon;
var age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
class PCCLpco_flag;
run;
*associations with age, marital status, (occupation);

proc npar1way data=reflux_test wilcoxon;
var age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
class PCCLint_flag;
run;
*none of the variables is associated with missingness on PCCL internal locus of control;

proc npar1way data=reflux_test wilcoxon;
var age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
class PCCLext_flag;
run;
*none of the variables is associated with missingness on PCCL external locus of control;

proc npar1way data=reflux_test wilcoxon;
var age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
class IAStot_flag;
run;
*associations with age, occupation;

proc npar1way data=reflux_test wilcoxon;
var age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
class BAQtot_flag;
run;
*none of the variables is associated with missingness on BAQ;

proc npar1way data=reflux_test wilcoxon;
var age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
class NEO_N_flag;
run;
*associations with education, length, tot_vol_exp, total_nr_acid;

proc npar1way data=reflux_test wilcoxon;
var age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
class NEO_E_flag;
run;
*associations with education, (length), tot_vol_exp;

proc npar1way data=reflux_test wilcoxon;
var age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
class NEO_O_flag;
run;
*associations with gender, (education), weight, length, total_gastric_acid_exp, (total_eso_acid_exp), ( tot_vol_exp);

proc npar1way data=reflux_test wilcoxon;
var age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
class NEO_A_flag;
run;
*associations with length;

proc npar1way data=reflux_test wilcoxon;
var age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
class NEO_C_flag;
run;
*associations with (gender), weight, length,(total_gastric_acid_exp);

proc npar1way data=reflux_test wilcoxon;
var age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
class CIStot_flag;
run;
*associations with gender, (weight);

proc npar1way data=reflux_test wilcoxon;
var age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
class CTQtot_flag;
run;
*associations with gender, (education), length;

*CONCLUSION OF ALL THIS: all of those are useful as auxiliary variables!


*----------------------------------------
MI USING MULTIVARIATE NORMAL DISTRIBUTION
-----------------------------------------
NOTE: we choose this option because we only have continuous variables to impute


1. Imputation Phase;
proc mi data=reflux_test nimpute=50 out=reflux_test_fcs seed=54321 simple; *minimum=(0 0 0 0 0 0 8 0 0 0 0 22 20 20 0 0 0 1 1 1 1 0 18 12 12 12 12 12 20 25 18 . . . . 40 1.40 15 0 0 0 0) maximum=(10 70 70 70 70 70 40 40 2 27 144 88 80 80 64 75 200 6 6 6 6 116 126 60 60 60 60 60 140 125 85 . . . . 150 2.1 45 100 100 20 200);
class gender marital_status education occupation;
var wellbeing RQ_zuur RQ_bovenbuik RQ_onderbuik RQ_misselijkheid RQ_slaapstoornissen RQ_andere CNAQtot 
MAAGtotaal PHQ15som PHQ9dep LSAStot PTSDtotaal STAIStot STAITtot ASItot VSItot PASStot PCCLcat PCCLpco PCCLint PCCLext 
IAStot BAQtot NEO_N NEO_E NEO_O NEO_A NEO_c CIStot CTQtot age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
fcs discrim(gender marital_status education occupation /classeffects=include) nbiter =100; 
run;
* NOTES
1. we choose nimpute=50, which is a high number of imputations, but recommended given the high levels of missingness in our dataset here
2. seed is optional, but since imputation is a stochastic process, specifying it allows us to obtain the same imputed datasets every time we rerun the code
3. var contains variables of interest to be imputed (all up to CTQtot in our case) as well as auxiliaries (the rest) obtained in the previous step
4. we added the class and fcs statements to proc mi to specify which variables are categorical
5. minimum= and maximum= options in the proc mi statement define the minimum and maximum imputed values for all variables, to be specified in the order in which they appear in the var statement further on
   we excluded the min/max option because proc mi was drawing values outside of the designated range and aborted/issued an error message. We instead chose to impose min/max value restrictions in the data step (below). 
   for further information about error with the min/max option see: https://support.sas.com/techsup/notes/v8/24/475.html ;

*2. Analysis Phase
NOTE: in our case, this simply implies calculating the mean for each subject over the 50 imputations, since for now we only want to create placeholders for the scale-level scores;
proc means data=reflux_test_fcs nway mean;
var wellbeing RQ_zuur RQ_bovenbuik RQ_onderbuik RQ_misselijkheid RQ_slaapstoornissen RQ_andere CNAQtot 
MAAGtotaal PHQ15som PHQ9dep LSAStot PTSDtotaal STAIStot STAITtot ASItot VSItot PASStot PCCLcat PCCLpco PCCLint PCCLext 
IAStot BAQtot NEO_N NEO_E NEO_O NEO_A NEO_c CIStot CTQtot age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
class subject;
output out = reflux_test_fcs_mean (drop = _TYPE_ _FREQ_);
run;

data reflux_test_fcs_mean;
set reflux_test_fcs_mean;
if _STAT_ NE 'MEAN' then delete;
drop _STAT_;
run;

*check distributions and extreme/out of possible range values;
proc univariate data=reflux_test_fcs_mean;
var wellbeing RQ_zuur RQ_bovenbuik RQ_onderbuik RQ_misselijkheid RQ_slaapstoornissen RQ_andere CNAQtot 
MAAGtotaal PHQ15som PHQ9dep LSAStot PTSDtotaal STAIStot STAITtot ASItot VSItot PASStot PCCLcat PCCLpco PCCLint PCCLext 
IAStot BAQtot NEO_N NEO_E NEO_O NEO_A NEO_c CIStot CTQtot age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
histogram wellbeing RQ_zuur RQ_bovenbuik RQ_onderbuik RQ_misselijkheid RQ_slaapstoornissen RQ_andere CNAQtot 
MAAGtotaal PHQ15som PHQ9dep LSAStot PTSDtotaal STAIStot STAITtot ASItot VSItot PASStot PCCLcat PCCLpco PCCLint PCCLext 
IAStot BAQtot NEO_N NEO_E NEO_O NEO_A NEO_c CIStot CTQtot age gender marital_status education occupation weight length BMI total_gastric_acid_exp total_eso_acid_exp tot_vol_exp total_nr_acid;
run;

*manually remove of out of range values;
data reflux_test_fcs_mean;
set reflux_test_fcs_mean;

if wellbeing < 0 then wellbeing=0;
if wellbeing > 10 then wellbeing=10;
rename wellbeing=wellbeing_imp;
label wellbeing=wellbeing_imp;

if RQ_zuur < 0 then RQ_zuur=0;
if RQ_zuur > 70 then RQ_zuur=70;
rename RQ_zuur=RQ_zuur_imp;
label RQ_zuur=RQ_zuur_imp;

if RQ_bovenbuik < 0 then RQ_bovenbuik=0;
if RQ_bovenbuik > 70 then RQ_bovenbuik=70;
rename RQ_bovenbuik=RQ_bovenbuik_imp;
label RQ_bovenbuik=RQ_bovenbuik_imp;

if RQ_onderbuik < 0 then RQ_onderbuik=0;
if RQ_onderbuik > 70 then RQ_onderbuik=70;
rename RQ_onderbuik=RQ_onderbuik_imp;
label RQ_onderbuik=RQ_onderbuik_imp;

if RQ_misselijkheid < 0 then RQ_misselijkheid=0;
if RQ_misselijkheid > 70 then RQ_misselijkheid=70;
rename RQ_misselijkheid=RQ_misselijkheid_imp;
label RQ_misselijkheid=RQ_misselijkheid_imp;

if RQ_slaapstoornissen < 0 then RQ_slaapstoornissen=0;
if RQ_slaapstoornissen > 70 then RQ_slaapstoornissen=70;
rename RQ_slaapstoornissen=RQ_slaapstoornissen_imp;
label RQ_slaapstoornissen=RQ_slaapstoornissen_imp;

if RQ_andere < 0 then RQ_andere=0;
if RQ_andere > 70 then RQ_andere=70;
rename RQ_andere=RQ_andere_imp;
label RQ_andere=RQ_andere_imp;

rename CNAQtot=CNAQtot_imp;
label CNAQtot=CNAQtot_imp;
*No extreme values for CNAQtot;

rename MAAGtotaal=MAAGtotaal_imp;
label MAAGtotaal=MAAGtotaal_imp;
*No extreme values for MAAGtotaal;

rename PHQ15som=PHQ15som_imp;
label PHQ15som=PHQ15som_imp;
*No extreme values for PHQ15som;

if PHQ9dep < 0 then PHQ9dep=0;
if PHQ9dep > 27 then PHQ9dep=27;
rename PHQ9dep=PHQ9dep_imp;
label PHQ9dep=PHQ9dep_imp;

if LSAStot < 0 then LSAStot=0;
if LSAStot > 144 then LSAStot=144;
rename LSAStot=LSAStot_imp;
label LSAStot=LSAStot_imp;

if PTSDtotaal < 22 then PTSDtotaal=22;
if PTSDtotaal > 88 then PTSDtotaal=88;
rename PTSDtotaal=PTSDtotaal_imp;
label PTSDtotaal=PTSDtotaal_imp;

rename STAIStot=STAIStot_imp;
label STAIStot=STAIStot_imp;
*No extreme values for STAIStot;

if STAITtot < 20 then STAITtot=20;
if STAITtot > 80 then STAITtot=80;
rename STAITtot=STAITtot_imp;
label STAITtot=STAITtot_imp;

rename ASItot=ASItot_imp;
label ASItot=ASItot_imp;
*No extreme values for ASItot;

rename VSItot=VSItot_imp;
label VSItot=VSItot_imp;
*No extreme values for VSItot;

rename PASStot=PASStot_imp;
label PASStot=PASStot_imp;
*No extreme values for PASStot;

rename PCCLcat=PCCLcat_imp;
label PCCLcat=PCCLcat_imp;
*No extreme values for PCCLcat;

rename PCCLpco=PCCLpco_imp;
label PCCLpco=PCCLpco_imp;
*No extreme values for PCCLpco;

if PCCLint < 1 then PCCLint=1;
if PCCLint > 6 then PCCLint=6;
rename PCCLint=PCCLint_imp;
label PCCLint=PCCLint_imp;

rename PCCLext=PCCLext_imp;
label PCCLext=PCCLext_imp;
*No extreme values for PCCLext;

rename IAStot=IAStot_imp;
label IAStot=IAStot_imp;
*No extreme values for IAStot;

if BAQtot < 18 then BAQtot=18;
if BAQtot > 126 then BAQtot=126;
rename BAQtot=BAQtot_imp;
label BAQtot=BAQtot_imp;

if NEO_N < 12 then NEO_N=12;
if NEO_N > 60 then NEO_N=60;
rename NEO_N=NEO_N_imp;
label NEO_N=NEO_N_imp;

rename NEO_E=NEO_E_imp;
label NEO_E=NEO_E_imp;
*No extreme values for NEO_E;

rename NEO_O=NEO_O_imp;
label NEO_O=NEO_O_imp;
*No extreme values for NEO_O;

rename NEO_A=NEO_A_imp;
label NEO_A=NEO_A_imp;
*No extreme values for NEO_A;

rename NEO_C=NEO_C_imp;
label NEO_C=NEO_C_imp;
*No extreme values for NEO_C;

rename CIStot=CIStot_imp;
label CIStot=CIStot_imp;
*No extreme values for CIStot;

rename CTQtot=CTQtot_imp;
label CTQtot=CTQtot_imp;
*No extreme values for CTQtot;

if age < 18 then age=18;
if age > 85 then age=85;
rename age=age_imp;
label age=age_imp;

rename gender=gender_imp;
label gender=gender_imp;
*No extreme values for gender;

rename marital_status=marital_status_imp;
label marital_status=marital_status_imp;
*No extreme values for marital_status;

rename education=education_imp;
label education=education_imp;
*No extreme values for education;

rename occupation=occupation_imp;
label occupation=occupation_imp;
*No extreme values for occupation;

if weight < 40 then weight=40;
if weight > 150 then weight=150;
rename weight=weight_imp;
label weight=weight_imp;
*No extreme values for weight;

if length < 1.40 then length=1.40;
if length > 2.10 then length=2.10;
rename length=length_imp;
label length=length_imp;
*No extreme values for length;

if BMI < 15 then BMI=15;
if BMI > 45 then BMI=45;
rename BMI=BMI_imp;
label BMI=BMI_imp;
*No extreme values for BMI;

rename total_gastric_acid_exp=total_gastric_acid_exp_imp;
label total_gastric_acid_exp=total_gastric_acid_exp_imp;
*No extreme values for total_gastric_acid_exp;

rename total_eso_acid_exp=total_eso_acid_exp_imp;
label total_eso_acid_exp=total_eso_acid_exp_imp;
*No extreme values for total_eso_acid_exp;

rename tot_vol_exp=tot_vol_exp_imp;
label tot_vol_exp=tot_vol_exp_imp;
*No extreme values for tot_vol_exp;

rename total_nr_acid=total_nr_acid_imp;
label total_nr_acid=total_nr_acid_imp;
*No extreme values for tot_nr_acid;
run;
*NOTE: We are specifying the minimum and maximum values for each variable where there are extreme values. We then re-named each imputed variable as "variable name_imp"to prepare to merge this dataset with the full dataset (items included).
Renaming/labeling variables: https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/basess/n1m4p5okk735vrn183zgkvg17jot.htm;

*recheck distributions and extreme/out of possible range values;
proc univariate data=reflux_test_fcs_mean;
var wellbeing_imp RQ_zuur_imp RQ_bovenbuik_imp RQ_onderbuik_imp RQ_misselijkheid_imp RQ_slaapstoornissen_imp RQ_andere_imp CNAQtot_imp
MAAGtotaal_imp PHQ15som_imp PHQ9dep_imp LSAStot_imp PTSDtotaal_imp STAIStot_imp STAITtot_imp ASItot_imp VSItot_imp PASStot_imp PCCLcat_imp PCCLpco_imp PCCLint_imp PCCLext_imp
IAStot_imp BAQtot_imp NEO_N_imp NEO_E_imp NEO_O_imp NEO_A_imp NEO_c_imp CIStot_imp CTQtot_imp age_imp gender_imp marital_status_imp education_imp occupation_imp weight_imp length_imp BMI_imp total_gastric_acid_exp_imp total_eso_acid_exp_imp tot_vol_exp_imp total_nr_acid_imp;
histogram wellbeing_imp RQ_zuur_imp RQ_bovenbuik_imp RQ_onderbuik_imp RQ_misselijkheid_imp RQ_slaapstoornissen_imp RQ_andere_imp CNAQtot_imp
MAAGtotaal_imp PHQ15som_imp PHQ9dep_imp LSAStot_imp PTSDtotaal_imp STAIStot_imp STAITtot_imp ASItot_imp VSItot_imp PASStot_imp PCCLcat_imp PCCLpco_imp PCCLint_imp PCCLext_imp
IAStot_imp BAQtot_imp NEO_N_imp NEO_E_imp NEO_O_imp NEO_A_imp NEO_c_imp CIStot_imp CTQtot_imp age_imp gender_imp marital_status_imp education_imp occupation_imp weight_imp length_imp BMI_imp total_gastric_acid_exp_imp total_eso_acid_exp_imp tot_vol_exp_imp total_nr_acid_imp;
run;

*round categorical variables to nearest integer;
data reflux_test_fcs_mean;
	set reflux_test_fcs_mean;
	gender_imp = round(gender_imp);
	marital_status_imp = round(marital_status_imp);
	education_imp = round(education_imp);
	occupation_imp = round(occupation_imp);
run;

*Merge imputed total score dataset with the full dataset in preparation for item-level imputation;
proc sort data= work.reflux_test;
  by subject;
run;

data work.Reflux_test_merged;
 merge work.reflux_test
 work.reflux_test_fcs_mean;
 by subject;
 run;


data refl_ind.reflux_test_merged;
  set work.reflux_test_merged;
run;
*Saving the merged dataset to a newly created sas library "reflux", corresponding to the local folder with the specified path;


*--------------------
---------------------
ITEM-LEVEL IMPUTATION
---------------------
---------------------


*--------------
    RQ Acid
---------------

*----------------------
PREPARING TO CONDUCT MI
-----------------------;

*Examine Missing Data Patterns among your variables of interest;
proc mi data=refl_ind.reflux_test_merged nimpute=0;
var acid_acidfreq acid_acidinvl acid_heartburn acid_belching acid_br_throat acid_bad_breath acid_heartburn_n acid_belching_n acid_taste acid_br_ascending acid_warm acid_br_throat_1 acid_saliva acid_br_bb acid_br_chest acid_antacid;
ods select misspattern;
run;
*NOTE: we are not going to identify specific auxiliary variables for each item, but use the following auxiliary variables for all items:
1. all scale_xxx_imp variables (these are the scale-level imputation variables excluding the scale for which we are imputing the items), as suggested in
https://www.tandfonline.com/doi/full/10.1080/00273171.2012.640589?casa_token=rjqcZEspPIQAAAAA%3Abts_sITCn7vn01Eq0IwDO7eS81wHpS_6RKBl6-szS9CviLLE1tUssX3iYE61pzTvkphQA_mTORg
2. all auxiliary variables used in scale level imputation (demographics etc)

*----------------------------------------
MI USING MULTIVARIATE NORMAL DISTRIBUTION
-----------------------------------------

1. Imputation Phase;
proc mi data=refl_ind.reflux_test_merged nimpute=50 out=reflux_test_merged_fcs_acid seed=54321 ;*simple minimum=(-0.5) maximum=(3.5);
class gender_imp marital_status_imp education_imp occupation_imp acid_heartburn acid_belching acid_br_throat acid_bad_breath acid_heartburn_n acid_belching_n acid_taste acid_br_ascending acid_warm acid_br_throat_1 acid_saliva acid_br_bb acid_br_chest acid_antacid;
var acid_acidfreq acid_acidinvl acid_heartburn acid_belching acid_br_throat acid_bad_breath acid_heartburn_n acid_belching_n acid_taste acid_br_ascending acid_warm acid_br_throat_1 acid_saliva acid_br_bb acid_br_chest acid_antacid
wellbeing_imp RQ_bovenbuik_imp RQ_onderbuik_imp RQ_misselijkheid_imp RQ_slaapstoornissen_imp RQ_andere_imp CNAQtot_imp
MAAGtotaal_imp PHQ15som_imp LSAStot_imp PTSDtotaal_imp STAIStot_imp STAITtot_imp ASItot_imp VSItot_imp PASStot_imp 
PCCLcat_imp PCCLpco_imp PCCLint_imp PCCLext_imp IAStot_imp BAQtot_imp NEO_N_imp NEO_E_imp NEO_O_imp NEO_A_imp NEO_c_imp CIStot_imp CTQtot_imp 
age_imp gender_imp marital_status_imp education_imp occupation_imp weight_imp length_imp BMI_imp total_gastric_acid_exp_imp total_eso_acid_exp_imp tot_vol_exp_imp total_nr_acid_imp;
fcs discrim(gender_imp marital_status_imp education_imp occupation_imp acid_heartburn acid_belching acid_br_throat acid_bad_breath acid_heartburn_n acid_belching_n acid_taste acid_br_ascending acid_warm acid_br_throat_1 acid_saliva acid_br_bb acid_br_chest acid_antacid /classeffects=include) nbiter =100; 
run;
* NOTES
1. we choose nimpute=50, which is a high number of imputations, but recommended given the high levels of missingness in our dataset here
2. seed is optional, but since imputation is a stochastic process, specifying it allows us to obtain the same imputed datasets every time we rerun the code
3. var contains variables of interest to be imputed (questionnaire items) as well as the auxiliaries (the rest)
4. we added the class and fcs statements to proc mi to specify which variables are categorical
5. minimum= and maximum= options in the proc mi statement define the minimum and maximum imputed values for all variables. In some cases we do not specify the min/max, as the range is too small and it produces an error.
   for further information about error with the min/max option see: https://support.sas.com/techsup/notes/v8/24/475.html 
6. **Important**: For item-level imputations, always exclude the total score for the questionnaire you are imputing. In the above example, we removed the RQ_zuur_imp as we are imputing the variables for that scale at the item-level;

*2. Analysis Phase;
proc means data=reflux_test_merged_fcs_acid nway mean;
var acid_acidfreq acid_acidinvl acid_heartburn acid_belching acid_br_throat acid_bad_breath acid_heartburn_n acid_belching_n acid_taste acid_br_ascending acid_warm acid_br_throat_1 acid_saliva acid_br_bb acid_br_chest acid_antacid;
class subject;
output out = reflux_test_merged_fcs_acid_mean (drop = _TYPE_ _FREQ_);
run;

data reflux_test_merged_fcs_acid_mean;
set reflux_test_merged_fcs_acid_mean;
if _STAT_ NE 'MEAN' then delete;
drop _STAT_;
run;

*check distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_acid_mean;
var acid_acidfreq acid_acidinvl acid_heartburn acid_belching acid_br_throat acid_bad_breath acid_heartburn_n acid_belching_n acid_taste acid_br_ascending acid_warm acid_br_throat_1 acid_saliva acid_br_bb acid_br_chest acid_antacid;
histogram acid_acidfreq acid_acidinvl acid_heartburn acid_belching acid_br_throat acid_bad_breath acid_heartburn_n acid_belching_n acid_taste acid_br_ascending acid_warm acid_br_throat_1 acid_saliva acid_br_bb acid_br_chest acid_antacid;
run;

*Remove out of range/extreme values;
data reflux_test_merged_fcs_acid_mean;
set reflux_test_merged_fcs_acid_mean;

array q  acid_acidfreq acid_acidinvl;
do i=1 to dim(q);
   if Q[i] < 0 then Q[i] = 0;
   if Q[i] > 10 then Q[i] = 10;
   end;
   drop i;
run;

*round categorical variables to nearest integer;
data reflux_test_merged_fcs_acid_mean;
set reflux_test_merged_fcs_acid_mean;

array q  acid_heartburn acid_belching acid_br_throat acid_bad_breath acid_heartburn_n acid_belching_n acid_taste acid_br_ascending acid_warm acid_br_throat_1 acid_saliva acid_br_bb acid_br_chest acid_antacid;
do i=1 to dim(q);
   Q[i] = round(Q[i]);
   end;
   drop i;
run;

*recheck distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_acid_mean;
var acid_acidfreq acid_acidinvl acid_heartburn acid_belching acid_br_throat acid_bad_breath acid_heartburn_n acid_belching_n acid_taste acid_br_ascending acid_warm acid_br_throat_1 acid_saliva acid_br_bb acid_br_chest acid_antacid;
histogram acid_acidfreq acid_acidinvl acid_heartburn acid_belching acid_br_throat acid_bad_breath acid_heartburn_n acid_belching_n acid_taste acid_br_ascending acid_warm acid_br_throat_1 acid_saliva acid_br_bb acid_br_chest acid_antacid;
run;

*Create new total scale score;
data reflux_test_merged_fcs_acid_mean;
set reflux_test_merged_fcs_acid_mean;
RQ_Acid_imp_IT = acid_acidfreq*acid_acidinvl; 
run;

*Add suffix "_IMP_IT" to all variables except subject ID (per https://support.sas.com/kb/48/674.html);
*First, create macro variable '&list' with the list of variables (Where clause indicates only PHQ variables, 
because we do not want to change subject ID as we will subject ID to merge datasets in the future);
proc sql noprint;
   select cats(name,'=',name,'_imp_IT')
          into :list
          separated by ' '
          from dictionary.columns
          where libname = 'WORK' and memname = 'REFLUX_TEST_MERGED_FCS_ACID_MEAN'
          and upcase(name) like 'ACID%';
quit;

*Rename using the macro variable you have created;
proc datasets library = work nolist;
   modify reflux_test_merged_fcs_acid_mean;
   rename &list;
quit;

*match label to new variable name (e.g., change label to reflect '_imp_IT' variable name);
proc datasets lib=work;
  modify reflux_test_merged_fcs_acid_mean;
  attrib _all_ label=' ';
run;

*save dataset; 
*libname reflux "C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\data\SAS Files\Individual_Variable_Datasets";
data refl_ind.reflux_test_RQacid;
  set work.reflux_test_merged_fcs_acid_mean;
run;

*------------------------------------------------------------------------------------

*--------------
RQ Bovenbuik
---------------

*----------------------
PREPARING TO CONDUCT MI
-----------------------;

*Examine Missing Data Patterns among your variables of interest;
proc mi data=refl_ind.reflux_test_merged nimpute=0;
var bb_freq bb_invl bb_pressure bb_pain bb_fullfeeling bb_quickfeelingfull bb_burning bb_br_acid bb_inc_stool bb_pain_n bb_pain_n_1 bb_pain_wake bb_LBP bb_HBP bb_appetite;
ods select misspattern;
run;

*----------------------------------------
MI USING MULTIVARIATE NORMAL DISTRIBUTION
-----------------------------------------

1. Imputation Phase;
proc mi data=refl_ind.reflux_test_merged nimpute=50 out=reflux_test_merged_fcs_bb seed=54321 ;*simple minimum=(-0.5) maximum=(3.5);
class gender_imp marital_status_imp education_imp occupation_imp bb_pressure bb_pain bb_fullfeeling bb_quickfeelingfull bb_burning bb_br_acid bb_inc_stool bb_pain_n bb_pain_n_1 bb_pain_wake bb_LBP bb_HBP bb_appetite;
var bb_freq bb_invl bb_pressure bb_pain bb_fullfeeling bb_quickfeelingfull bb_burning bb_br_acid bb_inc_stool bb_pain_n bb_pain_n_1 bb_pain_wake bb_LBP bb_HBP bb_appetite
wellbeing_imp RQ_zuur_imp RQ_onderbuik_imp RQ_misselijkheid_imp RQ_slaapstoornissen_imp RQ_andere_imp CNAQtot_imp
MAAGtotaal_imp PHQ15som_imp PHQ9dep_imp LSAStot_imp PTSDtotaal_imp STAIStot_imp STAITtot_imp ASItot_imp VSItot_imp PASStot_imp 
PCCLcat_imp PCCLpco_imp PCCLint_imp PCCLext_imp IAStot_imp BAQtot_imp NEO_N_imp NEO_E_imp NEO_O_imp NEO_A_imp NEO_c_imp CIStot_imp CTQtot_imp 
age_imp gender_imp marital_status_imp education_imp occupation_imp weight_imp length_imp BMI_imp total_gastric_acid_exp_imp total_eso_acid_exp_imp tot_vol_exp_imp total_nr_acid_imp;
fcs discrim(gender_imp marital_status_imp education_imp occupation_imp bb_pressure bb_pain bb_fullfeeling bb_quickfeelingfull bb_burning bb_br_acid bb_inc_stool bb_pain_n bb_pain_n_1 bb_pain_wake bb_LBP bb_HBP bb_appetite /classeffects=include) nbiter =100; 
run;

*2. Analysis Phase;
proc means data=reflux_test_merged_fcs_bb nway mean;
var bb_freq bb_invl bb_pressure bb_pain bb_fullfeeling bb_quickfeelingfull bb_burning bb_br_acid bb_inc_stool bb_pain_n bb_pain_n_1 bb_pain_wake bb_LBP bb_HBP bb_appetite;
class subject;
output out = reflux_test_merged_fcs_bb_mean (drop = _TYPE_ _FREQ_);
run;

data reflux_test_merged_fcs_bb_mean;
set reflux_test_merged_fcs_bb_mean;
if _STAT_ NE 'MEAN' then delete;
drop _STAT_;
run;

*check distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_bb_mean;
var bb_freq bb_invl bb_pressure bb_pain bb_fullfeeling bb_quickfeelingfull bb_burning bb_br_acid bb_inc_stool bb_pain_n bb_pain_n_1 bb_pain_wake bb_LBP bb_HBP bb_appetite;
histogram bb_freq bb_invl bb_pressure bb_pain bb_fullfeeling bb_quickfeelingfull bb_burning bb_br_acid bb_inc_stool bb_pain_n bb_pain_n_1 bb_pain_wake bb_LBP bb_HBP bb_appetite;
run;

*Remove out of range/extreme values;
data reflux_test_merged_fcs_bb_mean;
set reflux_test_merged_fcs_bb_mean;

array q  bb_freq bb_invl;
do i=1 to dim(q);
   if Q[i] < 0 then Q[i] = 0;
   if Q[i] > 10 then Q[i] = 10;
   end;
   drop i;
run;

*round categorical variables to nearest integer;
data reflux_test_merged_fcs_bb_mean;
set reflux_test_merged_fcs_bb_mean;

array q  bb_pressure bb_pain bb_fullfeeling bb_quickfeelingfull bb_burning bb_br_acid bb_inc_stool bb_pain_n bb_pain_n_1 bb_pain_wake bb_LBP bb_HBP bb_appetite;
do i=1 to dim(q);
   Q[i] = round(Q[i]);
   end;
   drop i;
run;

*recheck distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_bb_mean;
var bb_freq bb_invl bb_pressure bb_pain bb_fullfeeling bb_quickfeelingfull bb_burning bb_br_acid bb_inc_stool bb_pain_n bb_pain_n_1 bb_pain_wake bb_LBP bb_HBP bb_appetite;
histogram bb_freq bb_invl bb_pressure bb_pain bb_fullfeeling bb_quickfeelingfull bb_burning bb_br_acid bb_inc_stool bb_pain_n bb_pain_n_1 bb_pain_wake bb_LBP bb_HBP bb_appetite;
run;

*Create new total scale score;
data reflux_test_merged_fcs_bb_mean;
set reflux_test_merged_fcs_bb_mean;
RQ_Bovenbuik_imp_IT = bb_freq*bb_invl; 
run;

*Add suffix "_IMP_IT" to all variables except subject ID (per https://support.sas.com/kb/48/674.html);
proc sql noprint;
   select cats(name,'=',name,'_imp_IT')
          into :list
          separated by ' '
          from dictionary.columns
          where libname = 'WORK' and memname = 'REFLUX_TEST_MERGED_FCS_BB_MEAN'
          and upcase(name) like 'BB%';
quit;

*Rename using the macro variable you have created;
proc datasets library = work nolist;
   modify reflux_test_merged_fcs_bb_mean;
   rename &list;
quit;

*match label to new variable name (e.g., change label to reflect '_imp_IT' variable name);
proc datasets lib=work;
  modify reflux_test_merged_fcs_bb_mean;
  attrib _all_ label=' ';
run;

*save dataset; 
*libname reflux "C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\data\SAS Files\Individual_Variable_Datasets";
data refl_ind.reflux_test_RQbovenbuik;
  set work.reflux_test_merged_fcs_bb_mean;
run;


*--------------
RQ Onderbuik
---------------

*----------------------
PREPARING TO CONDUCT MI
-----------------------;

*Change character variable "ob_urgency" to numeric;
data refl_ind.reflux_test_merged;
set refl_ind.reflux_test_merged;
   ob_urgency_char = input(ob_urgency, 8.);
   drop ob_urgency;
   rename ob_urgency_char=ob_urgency;
run;

*Examine Missing Data Patterns among your variables of interest;
proc mi data=refl_ind.reflux_test_merged nimpute=0;
var ob_freq ob_invl ob_pressure_ob ob_cramp_ob ob_urgency ob_inc_stool ob_reflief_flat ob_bowelnoise ob_cramp_bb ob_relief_def ob_pain_ob ob_flatulence ob_hardstools ob_annoyingflatulence ob_diarrhea ob_bloated ob_belching ob_fullfeeling ob_blockage ob_wheezing;
ods select misspattern;
run;

*----------------------------------------
MI USING MULTIVARIATE NORMAL DISTRIBUTION
-----------------------------------------

1. Imputation Phase;
proc mi data=refl_ind.reflux_test_merged nimpute=50 out=reflux_test_merged_fcs_ob seed=54321 ;*simple minimum=(-0.5) maximum=(3.5);
class gender_imp marital_status_imp education_imp occupation_imp ob_pressure_ob ob_cramp_ob ob_urgency ob_inc_stool ob_reflief_flat ob_bowelnoise ob_cramp_bb ob_relief_def ob_pain_ob ob_flatulence ob_hardstools ob_annoyingflatulence ob_diarrhea ob_bloated ob_belching ob_fullfeeling ob_blockage ob_wheezing;
var  ob_freq ob_invl ob_pressure_ob ob_cramp_ob ob_urgency ob_inc_stool ob_reflief_flat ob_bowelnoise ob_cramp_bb ob_relief_def ob_pain_ob ob_flatulence ob_hardstools ob_annoyingflatulence ob_diarrhea ob_bloated ob_belching ob_fullfeeling ob_blockage ob_wheezing
wellbeing_imp RQ_zuur_imp RQ_bovenbuik_imp RQ_misselijkheid_imp RQ_slaapstoornissen_imp RQ_andere_imp CNAQtot_imp
MAAGtotaal_imp PHQ15som_imp PHQ9dep_imp LSAStot_imp PTSDtotaal_imp STAIStot_imp STAITtot_imp ASItot_imp VSItot_imp PASStot_imp 
PCCLcat_imp PCCLpco_imp PCCLint_imp PCCLext_imp IAStot_imp BAQtot_imp NEO_N_imp NEO_E_imp NEO_O_imp NEO_A_imp NEO_c_imp CIStot_imp CTQtot_imp 
age_imp gender_imp marital_status_imp education_imp occupation_imp weight_imp length_imp BMI_imp total_gastric_acid_exp_imp total_eso_acid_exp_imp tot_vol_exp_imp total_nr_acid_imp;
fcs discrim(gender_imp marital_status_imp education_imp occupation_imp ob_pressure_ob ob_cramp_ob ob_urgency ob_inc_stool ob_reflief_flat ob_bowelnoise ob_cramp_bb ob_relief_def ob_pain_ob ob_flatulence ob_hardstools ob_annoyingflatulence ob_diarrhea ob_bloated ob_belching ob_fullfeeling ob_blockage ob_wheezing /classeffects=include) nbiter =100; 
run;

*2. Analysis Phase;
proc means data=reflux_test_merged_fcs_ob nway mean;
var ob_freq ob_invl ob_pressure_ob ob_cramp_ob ob_urgency ob_inc_stool ob_reflief_flat ob_bowelnoise ob_cramp_bb ob_relief_def ob_pain_ob ob_flatulence ob_hardstools ob_annoyingflatulence ob_diarrhea ob_bloated ob_belching ob_fullfeeling ob_blockage ob_wheezing;
class subject;
output out = reflux_test_merged_fcs_ob_mean (drop = _TYPE_ _FREQ_);
run;

data reflux_test_merged_fcs_ob_mean;
set reflux_test_merged_fcs_ob_mean;
if _STAT_ NE 'MEAN' then delete;
drop _STAT_;
run;

*check distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_ob_mean;
var ob_freq ob_invl ob_pressure_ob ob_cramp_ob ob_urgency ob_inc_stool ob_reflief_flat ob_bowelnoise ob_cramp_bb ob_relief_def ob_pain_ob ob_flatulence ob_hardstools ob_annoyingflatulence ob_diarrhea ob_bloated ob_belching ob_fullfeeling ob_blockage ob_wheezing;
histogram ob_freq ob_invl ob_pressure_ob ob_cramp_ob ob_urgency ob_inc_stool ob_reflief_flat ob_bowelnoise ob_cramp_bb ob_relief_def ob_pain_ob ob_flatulence ob_hardstools ob_annoyingflatulence ob_diarrhea ob_bloated ob_belching ob_fullfeeling ob_blockage ob_wheezing;
run;

*Remove out of range/extreme values;
*Note: ob_freq and ob_invl have different ranges than the rest of the items;
data reflux_test_merged_fcs_ob_mean;
set reflux_test_merged_fcs_ob_mean;

array q  ob_freq ob_invl;
do i=1 to dim(q);
   if Q[i] < 0 then Q[i] = 0;
   if Q[i] > 10 then Q[i] = 10;
   end;
   drop i;
run;

*Remove out of range/extreme values;
data reflux_test_merged_fcs_ob_mean;
set reflux_test_merged_fcs_ob_mean;

array q  ob_pressure_ob ob_cramp_ob ob_urgency ob_inc_stool ob_reflief_flat ob_bowelnoise ob_cramp_bb ob_relief_def ob_pain_ob ob_flatulence ob_hardstools ob_annoyingflatulence ob_diarrhea ob_bloated ob_belching ob_fullfeeling ob_blockage ob_wheezing;
do i=1 to dim(q);
   if Q[i] < 0 then Q[i] = 0;
   if Q[i] > 1 then Q[i] = 1;
   end;
   drop i;
run;


*round categorical variables to nearest integer;
data reflux_test_merged_fcs_ob_mean;
set reflux_test_merged_fcs_ob_mean;

array q ob_pressure_ob ob_cramp_ob ob_urgency ob_inc_stool ob_reflief_flat ob_bowelnoise ob_cramp_bb ob_relief_def ob_pain_ob ob_flatulence ob_hardstools ob_annoyingflatulence ob_diarrhea ob_bloated ob_belching ob_fullfeeling ob_blockage ob_wheezing;
do i=1 to dim(q);
   Q[i] = round(Q[i]);
   end;
   drop i;
run;

*recheck distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_ob_mean;
var ob_freq ob_invl ob_pressure_ob ob_cramp_ob ob_urgency ob_inc_stool ob_reflief_flat ob_bowelnoise ob_cramp_bb ob_relief_def ob_pain_ob ob_flatulence ob_hardstools ob_annoyingflatulence ob_diarrhea ob_bloated ob_belching ob_fullfeeling ob_blockage ob_wheezing;
histogram ob_freq ob_invl ob_pressure_ob ob_cramp_ob ob_urgency ob_inc_stool ob_reflief_flat ob_bowelnoise ob_cramp_bb ob_relief_def ob_pain_ob ob_flatulence ob_hardstools ob_annoyingflatulence ob_diarrhea ob_bloated ob_belching ob_fullfeeling ob_blockage ob_wheezing;
run;

*Create new total scale score;
data reflux_test_merged_fcs_ob_mean;
set reflux_test_merged_fcs_ob_mean;
RQ_Onderbuik_imp_IT = ob_freq*ob_invl; 
run;

*Add suffix "_IMP_IT" to all variables except subject ID (per https://support.sas.com/kb/48/674.html);
proc sql noprint;
   select cats(name,'=',name,'_imp_IT')
          into :list
          separated by ' '
          from dictionary.columns
          where libname = 'WORK' and memname = 'REFLUX_TEST_MERGED_FCS_OB_MEAN'
          and upcase(name) like 'OB%';
quit;

*Rename using the macro variable you have created;
proc datasets library = work nolist;
   modify reflux_test_merged_fcs_ob_mean;
   rename &list;
quit;

*match label to new variable name (e.g., change label to reflect '_imp_IT' variable name);
proc datasets lib=work;
  modify reflux_test_merged_fcs_ob_mean;
  attrib _all_ label=' ';
run;

*save dataset; 
*libname reflux "C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\data\SAS Files\Individual_Variable_Datasets";
data refl_ind.reflux_test_RQOnderbuik;
  set work.reflux_test_merged_fcs_ob_mean;
run;


*------------------------------------------------------------------------------------

*--------------
RQ Misselijkheid
---------------

*----------------------
PREPARING TO CONDUCT MI
-----------------------;

*Examine Missing Data Patterns among your variables of interest;
proc mi data=refl_ind.reflux_test_merged nimpute=0;
var mis_freq mis_invl mis_throwup mis_choking mis_gagreflex mis_nausea mis_suffocatingfeeling mis_ifeelnauseous mis_nauseafeeling mis_antacid mis_quicklyfull mis_abdominalpressure mis_suffocatingfeeling_1 mis_sorethroat mis_swallowingcomplaints mis_appetiteloss;
ods select misspattern;
run;

*----------------------------------------
MI USING MULTIVARIATE NORMAL DISTRIBUTION
-----------------------------------------

1. Imputation Phase;
proc mi data=refl_ind.reflux_test_merged nimpute=50 out=reflux_test_merged_fcs_mis seed=54321 ;*simple minimum=(-0.5) maximum=(3.5);
class gender_imp marital_status_imp education_imp occupation_imp mis_throwup mis_choking mis_gagreflex mis_nausea mis_suffocatingfeeling mis_ifeelnauseous mis_nauseafeeling mis_antacid mis_quicklyfull mis_abdominalpressure mis_suffocatingfeeling_1 mis_sorethroat mis_swallowingcomplaints mis_appetiteloss;
var  mis_freq mis_invl mis_throwup mis_choking mis_gagreflex mis_nausea mis_suffocatingfeeling mis_ifeelnauseous mis_nauseafeeling mis_antacid mis_quicklyfull mis_abdominalpressure mis_suffocatingfeeling_1 mis_sorethroat mis_swallowingcomplaints mis_appetiteloss
wellbeing_imp RQ_zuur_imp RQ_bovenbuik_imp RQ_onderbuik_imp RQ_slaapstoornissen_imp RQ_andere_imp CNAQtot_imp
MAAGtotaal_imp PHQ15som_imp PHQ9dep_imp LSAStot_imp PTSDtotaal_imp STAIStot_imp STAITtot_imp ASItot_imp VSItot_imp PASStot_imp 
PCCLcat_imp PCCLpco_imp PCCLint_imp PCCLext_imp IAStot_imp BAQtot_imp NEO_N_imp NEO_E_imp NEO_O_imp NEO_A_imp NEO_c_imp CIStot_imp CTQtot_imp 
age_imp gender_imp marital_status_imp education_imp occupation_imp weight_imp length_imp BMI_imp total_gastric_acid_exp_imp total_eso_acid_exp_imp tot_vol_exp_imp total_nr_acid_imp;
fcs discrim(gender_imp marital_status_imp education_imp occupation_imp mis_throwup mis_choking mis_gagreflex mis_nausea mis_suffocatingfeeling mis_ifeelnauseous mis_nauseafeeling mis_antacid mis_quicklyfull mis_abdominalpressure mis_suffocatingfeeling_1 mis_sorethroat mis_swallowingcomplaints mis_appetiteloss /classeffects=include) nbiter =100; 
run;

*2. Analysis Phase;
proc means data=reflux_test_merged_fcs_mis nway mean;
var mis_freq mis_invl mis_throwup mis_choking mis_gagreflex mis_nausea mis_suffocatingfeeling mis_ifeelnauseous mis_nauseafeeling mis_antacid mis_quicklyfull mis_abdominalpressure mis_suffocatingfeeling_1 mis_sorethroat mis_swallowingcomplaints mis_appetiteloss;
class subject;
output out = reflux_test_merged_fcs_mis_mean (drop = _TYPE_ _FREQ_);
run;

data reflux_test_merged_fcs_mis_mean;
set reflux_test_merged_fcs_mis_mean;
if _STAT_ NE 'MEAN' then delete;
drop _STAT_;
run;

*check distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_mis_mean;
var mis_freq mis_invl mis_throwup mis_choking mis_gagreflex mis_nausea mis_suffocatingfeeling mis_ifeelnauseous mis_nauseafeeling mis_antacid mis_quicklyfull mis_abdominalpressure mis_suffocatingfeeling_1 mis_sorethroat mis_swallowingcomplaints mis_appetiteloss;
histogram mis_freq mis_invl mis_throwup mis_choking mis_gagreflex mis_nausea mis_suffocatingfeeling mis_ifeelnauseous mis_nauseafeeling mis_antacid mis_quicklyfull mis_abdominalpressure mis_suffocatingfeeling_1 mis_sorethroat mis_swallowingcomplaints mis_appetiteloss;
run;

*Remove out of range/extreme values;
*Note: mis_freq and mis_invl have different ranges than the rest of the items;
data reflux_test_merged_fcs_mis_mean;
set reflux_test_merged_fcs_mis_mean;

array q  mis_freq mis_invl;
do i=1 to dim(q);
   if Q[i] < 0 then Q[i] = 0;
   if Q[i] > 10 then Q[i] = 10;
   end;
   drop i;
run;

*Remove out of range/extreme values;
data reflux_test_merged_fcs_mis_mean;
set reflux_test_merged_fcs_mis_mean;

array q  mis_throwup mis_choking mis_gagreflex mis_nausea mis_suffocatingfeeling mis_ifeelnauseous mis_nauseafeeling mis_antacid mis_quicklyfull mis_abdominalpressure mis_suffocatingfeeling_1 mis_sorethroat mis_swallowingcomplaints mis_appetiteloss;
do i=1 to dim(q);
   if Q[i] < 0 then Q[i] = 0;
   if Q[i] > 1 then Q[i] = 1;
   end;
   drop i;
run;

*round categorical variables to nearest integer;
data reflux_test_merged_fcs_mis_mean;
set reflux_test_merged_fcs_mis_mean;

array q mis_throwup mis_choking mis_gagreflex mis_nausea mis_suffocatingfeeling mis_ifeelnauseous mis_nauseafeeling mis_antacid mis_quicklyfull mis_abdominalpressure mis_suffocatingfeeling_1 mis_sorethroat mis_swallowingcomplaints mis_appetiteloss;
do i=1 to dim(q);
   Q[i] = round(Q[i]);
   end;
   drop i;
run;

*recheck distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_mis_mean;
var mis_freq mis_invl mis_throwup mis_choking mis_gagreflex mis_nausea mis_suffocatingfeeling mis_ifeelnauseous mis_nauseafeeling mis_antacid mis_quicklyfull mis_abdominalpressure mis_suffocatingfeeling_1 mis_sorethroat mis_swallowingcomplaints mis_appetiteloss;
histogram mis_freq mis_invl mis_throwup mis_choking mis_gagreflex mis_nausea mis_suffocatingfeeling mis_ifeelnauseous mis_nauseafeeling mis_antacid mis_quicklyfull mis_abdominalpressure mis_suffocatingfeeling_1 mis_sorethroat mis_swallowingcomplaints mis_appetiteloss;
run;

*Create new total scale score;
data reflux_test_merged_fcs_mis_mean;
set reflux_test_merged_fcs_mis_mean;
RQ_Misselijkheid_imp_IT = mis_freq*mis_invl; 
run;

*Add suffix "_IMP_IT" to all variables except subject ID (per https://support.sas.com/kb/48/674.html);
proc sql noprint;
   select cats(name,'=',name,'_imp_IT')
          into :list
          separated by ' '
          from dictionary.columns
          where libname = 'WORK' and memname = 'REFLUX_TEST_MERGED_FCS_MIS_MEAN'
          and upcase(name) like 'MIS%';
quit;

*Rename using the macro variable you have created;
proc datasets library = work nolist;
   modify reflux_test_merged_fcs_mis_mean;
   rename &list;
quit;

*match label to new variable name (e.g., change label to reflect '_imp_IT' variable name);
proc datasets lib=work;
  modify reflux_test_merged_fcs_mis_mean;
  attrib _all_ label=' ';
run;

*save dataset; 
*libname reflux "C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\data\SAS Files\Individual_Variable_Datasets";
data refl_ind.reflux_test_RQMisselijkheid;
  set work.reflux_test_merged_fcs_mis_mean;
run;


*------------------------------------------------------------------------------------

*------------------
RQ Slapstoornissen
-------------------

*----------------------
PREPARING TO CONDUCT MI
-----------------------;

*Examine Missing Data Patterns among your variables of interest;
proc mi data=refl_ind.reflux_test_merged nimpute=0;
var ss_freq ss_invl ss_cough_n ss_pain_n ss_burn_n ss_insuff_rest ss_nightmare ss_prob_fall_sleep ss_waking ss_pain_bb_n ss_pain_bb_wake_n ss_hoarseness ss_cough;
ods select misspattern;
run;

*----------------------------------------
MI USING MULTIVARIATE NORMAL DISTRIBUTION
-----------------------------------------

1. Imputation Phase;
proc mi data=refl_ind.reflux_test_merged nimpute=50 out=reflux_test_merged_fcs_ss seed=54321 ;*simple minimum=(-0.5) maximum=(3.5);
class gender_imp marital_status_imp education_imp occupation_imp ss_cough_n ss_pain_n ss_burn_n ss_insuff_rest ss_nightmare ss_prob_fall_sleep ss_waking ss_pain_bb_n ss_pain_bb_wake_n ss_hoarseness ss_cough;
var  ss_freq ss_invl ss_cough_n ss_pain_n ss_burn_n ss_insuff_rest ss_nightmare ss_prob_fall_sleep ss_waking ss_pain_bb_n ss_pain_bb_wake_n ss_hoarseness ss_cough
wellbeing_imp RQ_zuur_imp RQ_bovenbuik_imp RQ_onderbuik_imp RQ_misselijkheid_imp RQ_andere_imp CNAQtot_imp
MAAGtotaal_imp PHQ15som_imp PHQ9dep_imp LSAStot_imp PTSDtotaal_imp STAIStot_imp STAITtot_imp ASItot_imp VSItot_imp PASStot_imp 
PCCLcat_imp PCCLpco_imp PCCLint_imp PCCLext_imp IAStot_imp BAQtot_imp NEO_N_imp NEO_E_imp NEO_O_imp NEO_A_imp NEO_c_imp CIStot_imp CTQtot_imp 
age_imp gender_imp marital_status_imp education_imp occupation_imp weight_imp length_imp BMI_imp total_gastric_acid_exp_imp total_eso_acid_exp_imp tot_vol_exp_imp total_nr_acid_imp;
fcs discrim(gender_imp marital_status_imp education_imp occupation_imp ss_cough_n ss_pain_n ss_burn_n ss_insuff_rest ss_nightmare ss_prob_fall_sleep ss_waking ss_pain_bb_n ss_pain_bb_wake_n ss_hoarseness ss_cough /classeffects=include) nbiter =100; 
run;

*2. Analysis Phase;
proc means data=reflux_test_merged_fcs_ss nway mean;
var ss_freq ss_invl ss_cough_n ss_pain_n ss_burn_n ss_insuff_rest ss_nightmare ss_prob_fall_sleep ss_waking ss_pain_bb_n ss_pain_bb_wake_n ss_hoarseness ss_cough;
class subject;
output out = reflux_test_merged_fcs_ss_mean (drop = _TYPE_ _FREQ_);
run;

data reflux_test_merged_fcs_ss_mean;
set reflux_test_merged_fcs_ss_mean;
if _STAT_ NE 'MEAN' then delete;
drop _STAT_;
run;

*check distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_ss_mean;
var ss_freq ss_invl ss_cough_n ss_pain_n ss_burn_n ss_insuff_rest ss_nightmare ss_prob_fall_sleep ss_waking ss_pain_bb_n ss_pain_bb_wake_n ss_hoarseness ss_cough;
histogram ss_freq ss_invl ss_cough_n ss_pain_n ss_burn_n ss_insuff_rest ss_nightmare ss_prob_fall_sleep ss_waking ss_pain_bb_n ss_pain_bb_wake_n ss_hoarseness ss_cough;
run;

*Remove out of range/extreme values;
data reflux_test_merged_fcs_ss_mean;
set reflux_test_merged_fcs_ss_mean;

array q  ss_freq ss_invl;
do i=1 to dim(q);
   if Q[i] < 0 then Q[i] = 0;
   if Q[i] > 10 then Q[i] = 10;
   end;
   drop i;
run;

*Remove out of range/extreme values;
data reflux_test_merged_fcs_ss_mean;
set reflux_test_merged_fcs_ss_mean;

array q  ss_cough_n ss_pain_n ss_burn_n ss_insuff_rest ss_nightmare ss_prob_fall_sleep ss_waking ss_pain_bb_n ss_pain_bb_wake_n ss_hoarseness ss_cough;
do i=1 to dim(q);
   if Q[i] < 0 then Q[i] = 0;
   if Q[i] > 1 then Q[i] = 1;
   end;
   drop i;
run;

*round categorical variables to nearest integer;
data reflux_test_merged_fcs_ss_mean;
set reflux_test_merged_fcs_ss_mean;

array q ss_cough_n ss_pain_n ss_burn_n ss_insuff_rest ss_nightmare ss_prob_fall_sleep ss_waking ss_pain_bb_n ss_pain_bb_wake_n ss_hoarseness ss_cough;
do i=1 to dim(q);
   Q[i] = round(Q[i]);
   end;
   drop i;
run;

*recheck distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_ss_mean;
var ss_freq ss_invl ss_cough_n ss_pain_n ss_burn_n ss_insuff_rest ss_nightmare ss_prob_fall_sleep ss_waking ss_pain_bb_n ss_pain_bb_wake_n ss_hoarseness ss_cough;
histogram ss_freq ss_invl ss_cough_n ss_pain_n ss_burn_n ss_insuff_rest ss_nightmare ss_prob_fall_sleep ss_waking ss_pain_bb_n ss_pain_bb_wake_n ss_hoarseness ss_cough;
run;

*Create new total scale score;
data reflux_test_merged_fcs_ss_mean;
set reflux_test_merged_fcs_ss_mean;
RQ_Slaapstoornissen_imp_IT = ss_freq*ss_invl; 
run;

*Add suffix "_IMP_IT" to all variables except subject ID (per https://support.sas.com/kb/48/674.html);
proc sql noprint;
   select cats(name,'=',name,'_imp_IT')
          into :list
          separated by ' '
          from dictionary.columns
          where libname = 'WORK' and memname = 'REFLUX_TEST_MERGED_FCS_SS_MEAN'
          and upcase(name) like 'SS%';
quit;

*Rename using the macro variable you have created;
proc datasets library = work nolist;
   modify reflux_test_merged_fcs_ss_mean;
   rename &list;
quit;

*match label to new variable name (e.g., change label to reflect '_imp_IT' variable name);
proc datasets lib=work;
  modify reflux_test_merged_fcs_ss_mean;
  attrib _all_ label=' ';
run;

*save dataset; 
*libname reflux "C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\data\SAS Files\Individual_Variable_Datasets";
data refl_ind.reflux_test_RQSlaap;
  set work.reflux_test_merged_fcs_ss_mean;
run;


*------------------------------------------------------------------------------------

*------------------
RQ Andere
-------------------

*----------------------
PREPARING TO CONDUCT MI
-----------------------;

*Examine Missing Data Patterns among your variables of interest;
proc mi data=refl_ind.reflux_test_merged nimpute=0;
var a_freq a_invl a_wheezing a_hoarseness a_headache a_cough a_sob a_throatclear a_sorethroat a_chokefeel a_br_tong a_respiratory a_lumpthroat a_swallow a_cough_n;
ods select misspattern;
run;

*----------------------------------------
MI USING MULTIVARIATE NORMAL DISTRIBUTION
-----------------------------------------

1. Imputation Phase;
proc mi data=refl_ind.reflux_test_merged nimpute=50 out=reflux_test_merged_fcs_a seed=54321 ;*simple minimum=(-0.5) maximum=(3.5);
class gender_imp marital_status_imp education_imp occupation_imp a_wheezing a_hoarseness a_headache a_cough a_sob a_throatclear a_sorethroat a_chokefeel a_br_tong a_respiratory a_lumpthroat a_swallow a_cough_n;
var  a_freq a_invl a_wheezing a_hoarseness a_headache a_cough a_sob a_throatclear a_sorethroat a_chokefeel a_br_tong a_respiratory a_lumpthroat a_swallow a_cough_n
wellbeing_imp RQ_zuur_imp RQ_bovenbuik_imp RQ_onderbuik_imp RQ_misselijkheid_imp RQ_slaapstoornissen_imp CNAQtot_imp
MAAGtotaal_imp PHQ15som_imp PHQ9dep_imp LSAStot_imp PTSDtotaal_imp STAIStot_imp STAITtot_imp ASItot_imp VSItot_imp PASStot_imp 
PCCLcat_imp PCCLpco_imp PCCLint_imp PCCLext_imp IAStot_imp BAQtot_imp NEO_N_imp NEO_E_imp NEO_O_imp NEO_A_imp NEO_c_imp CIStot_imp CTQtot_imp 
age_imp gender_imp marital_status_imp education_imp occupation_imp weight_imp length_imp BMI_imp total_gastric_acid_exp_imp total_eso_acid_exp_imp tot_vol_exp_imp total_nr_acid_imp;
fcs discrim(gender_imp marital_status_imp education_imp occupation_imp a_wheezing a_hoarseness a_headache a_cough a_sob a_throatclear a_sorethroat a_chokefeel a_br_tong a_respiratory a_lumpthroat a_swallow a_cough_n /classeffects=include) nbiter =100; 
run;

*2. Analysis Phase;
proc means data=reflux_test_merged_fcs_a nway mean;
var a_freq a_invl a_wheezing a_hoarseness a_headache a_cough a_sob a_throatclear a_sorethroat a_chokefeel a_br_tong a_respiratory a_lumpthroat a_swallow a_cough_n;
class subject;
output out = reflux_test_merged_fcs_a_mean (drop = _TYPE_ _FREQ_);
run;

data reflux_test_merged_fcs_a_mean;
set reflux_test_merged_fcs_a_mean;
if _STAT_ NE 'MEAN' then delete;
drop _STAT_;
run;

*check distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_a_mean;
var a_freq a_invl a_wheezing a_hoarseness a_headache a_cough a_sob a_throatclear a_sorethroat a_chokefeel a_br_tong a_respiratory a_lumpthroat a_swallow a_cough_n;
histogram a_freq a_invl a_wheezing a_hoarseness a_headache a_cough a_sob a_throatclear a_sorethroat a_chokefeel a_br_tong a_respiratory a_lumpthroat a_swallow a_cough_n;
run;

*Remove out of range/extreme values;
data reflux_test_merged_fcs_a_mean;
set reflux_test_merged_fcs_a_mean;

array q  a_freq a_invl;
do i=1 to dim(q);
   if Q[i] < 0 then Q[i] = 0;
   if Q[i] > 10 then Q[i] = 10;
   end;
   drop i;
run;

*Remove out of range/extreme values;
data reflux_test_merged_fcs_a_mean;
set reflux_test_merged_fcs_a_mean;

array q  a_wheezing a_hoarseness a_headache a_cough a_sob a_throatclear a_sorethroat a_chokefeel a_br_tong a_respiratory a_lumpthroat a_swallow a_cough_n;
do i=1 to dim(q);
   if Q[i] < 0 then Q[i] = 0;
   if Q[i] > 1 then Q[i] = 1;
   end;
   drop i;
run;

*round categorical variables to nearest integer;
data reflux_test_merged_fcs_a_mean;
set reflux_test_merged_fcs_a_mean;

array q a_wheezing a_hoarseness a_headache a_cough a_sob a_throatclear a_sorethroat a_chokefeel a_br_tong a_respiratory a_lumpthroat a_swallow a_cough_n;
do i=1 to dim(q);
   Q[i] = round(Q[i]);
   end;
   drop i;
run;

*recheck distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_a_mean;
var a_freq a_invl a_wheezing a_hoarseness a_headache a_cough a_sob a_throatclear a_sorethroat a_chokefeel a_br_tong a_respiratory a_lumpthroat a_swallow a_cough_n;
histogram a_freq a_invl a_wheezing a_hoarseness a_headache a_cough a_sob a_throatclear a_sorethroat a_chokefeel a_br_tong a_respiratory a_lumpthroat a_swallow a_cough_n;
run;

*Create new total scale score;
data reflux_test_merged_fcs_a_mean;
set reflux_test_merged_fcs_a_mean;
RQ_Andere_imp_IT = a_freq*a_invl; 
run;

*Add suffix "_IMP_IT" to all variables except subject ID (per https://support.sas.com/kb/48/674.html);
proc sql noprint;
   select cats(name,'=',name,'_imp_IT')
          into :list
          separated by ' '
          from dictionary.columns
          where libname = 'WORK' and memname = 'REFLUX_TEST_MERGED_FCS_A_MEAN'
          and upcase(name) like 'A%';
quit;

*Rename using the macro variable you have created;
proc datasets library = work nolist;
   modify reflux_test_merged_fcs_a_mean;
   rename &list;
quit;

*match label to new variable name (e.g., change label to reflect '_imp_IT' variable name);
proc datasets lib=work;
  modify reflux_test_merged_fcs_a_mean;
  attrib _all_ label=' ';
run;

*save dataset; 
*libname reflux "C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\data\SAS Files\Individual_Variable_Datasets";
data refl_ind.reflux_test_RQAndere;
  set work.reflux_test_merged_fcs_a_mean;
run;


*------------------------------------------------------------------------------------

*--------------
     LSAS
---------------

*----------------------
PREPARING TO CONDUCT MI
-----------------------;

proc mi data=refl_ind.reflux_test_merged nimpute=0;
var LSAS1a LSAS1v LSAS2a LSAS2v LSAS3a LSAS3v LSAS4a LSAS4v LSAS5a LSAS5v LSAS6a LSAS6v LSAS7a LSAS7v LSAS8a LSAS8v LSAS9a LSAS9v LSAS10a LSAS10v LSAS11a LSAS11v LSAS12a LSAS12v LSAS13a LSAS13v LSAS14a LSAS14v LSAS15a LSAS15v LSAS16a LSAS16v LSAS17a LSAS17v LSAS18a LSAS18v LSAS19a LSAS19v LSAS20a LSAS20v; 
ods select misspattern;
run;

*----------------------------------------
MI USING MULTIVARIATE NORMAL DISTRIBUTION
-----------------------------------------

1. Imputation Phase;
proc mi data=refl_ind.reflux_test_merged nimpute=50 out=reflux_test_merged_fcs_LSAS seed=54321 ;*simple minimum=(-.5) maximum=(4.5);
class gender_imp marital_status_imp education_imp occupation_imp;
var LSAS1a LSAS1v LSAS2a LSAS2v LSAS3a LSAS3v LSAS4a LSAS4v LSAS5a LSAS5v LSAS6a LSAS6v LSAS7a LSAS7v LSAS8a LSAS8v LSAS9a LSAS9v LSAS10a LSAS10v LSAS11a LSAS11v LSAS12a LSAS12v LSAS13a LSAS13v LSAS14a LSAS14v LSAS15a LSAS15v LSAS16a LSAS16v LSAS17a LSAS17v LSAS18a LSAS18v LSAS19a LSAS19v LSAS20a LSAS20v
wellbeing_imp RQ_zuur_imp RQ_bovenbuik_imp RQ_onderbuik_imp RQ_misselijkheid_imp RQ_slaapstoornissen_imp RQ_andere_imp CNAQtot_imp
MAAGtotaal_imp PHQ15som_imp PHQ9dep_imp PTSDtotaal_imp STAIStot_imp STAITtot_imp ASItot_imp VSItot_imp PASStot_imp 
PCCLcat_imp PCCLpco_imp PCCLint_imp PCCLext_imp IAStot_imp BAQtot_imp NEO_N_imp NEO_E_imp NEO_O_imp NEO_A_imp NEO_c_imp CIStot_imp CTQtot_imp 
age_imp gender_imp marital_status_imp education_imp occupation_imp weight_imp length_imp BMI_imp total_gastric_acid_exp_imp total_eso_acid_exp_imp tot_vol_exp_imp total_nr_acid_imp;
fcs discrim(gender_imp marital_status_imp education_imp occupation_imp /classeffects=include) nbiter =100; 
run;

*2. Analysis Phase;
proc means data=reflux_test_merged_fcs_LSAS nway mean;
var LSAS1a LSAS1v LSAS2a LSAS2v LSAS3a LSAS3v LSAS4a LSAS4v LSAS5a LSAS5v LSAS6a LSAS6v LSAS7a LSAS7v LSAS8a LSAS8v LSAS9a LSAS9v LSAS10a LSAS10v LSAS11a LSAS11v LSAS12a LSAS12v LSAS13a LSAS13v LSAS14a LSAS14v LSAS15a LSAS15v LSAS16a LSAS16v LSAS17a LSAS17v LSAS18a LSAS18v LSAS19a LSAS19v LSAS20a LSAS20v;
class subject;
output out = reflux_test_merged_fcs_LSAS_mean (drop = _TYPE_ _FREQ_);
run;

data reflux_test_merged_fcs_LSAS_mean;
set reflux_test_merged_fcs_LSAS_mean;
if _STAT_ NE 'MEAN' then delete;
drop _STAT_;
run;

*check distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_LSAS_mean;
var LSAS1a LSAS1v LSAS2a LSAS2v LSAS3a LSAS3v LSAS4a LSAS4v LSAS5a LSAS5v LSAS6a LSAS6v LSAS7a LSAS7v LSAS8a LSAS8v LSAS9a LSAS9v LSAS10a LSAS10v LSAS11a LSAS11v LSAS12a LSAS12v LSAS13a LSAS13v LSAS14a LSAS14v LSAS15a LSAS15v LSAS16a LSAS16v LSAS17a LSAS17v LSAS18a LSAS18v LSAS19a LSAS19v LSAS20a LSAS20v;
histogram LSAS1a LSAS1v LSAS2a LSAS2v LSAS3a LSAS3v LSAS4a LSAS4v LSAS5a LSAS5v LSAS6a LSAS6v LSAS7a LSAS7v LSAS8a LSAS8v LSAS9a LSAS9v LSAS10a LSAS10v LSAS11a LSAS11v LSAS12a LSAS12v LSAS13a LSAS13v LSAS14a LSAS14v LSAS15a LSAS15v LSAS16a LSAS16v LSAS17a LSAS17v LSAS18a LSAS18v LSAS19a LSAS19v LSAS20a LSAS20v;
run;

*Get rid of out of range/extreme values;
data reflux_test_merged_fcs_LSAS_mean;
set reflux_test_merged_fcs_LSAS_mean;

array q  LSAS1a LSAS1v LSAS2a LSAS2v LSAS3a LSAS3v LSAS4a LSAS4v LSAS5a LSAS5v LSAS6a LSAS6v LSAS7a LSAS7v LSAS8a LSAS8v LSAS9a LSAS9v LSAS10a LSAS10v LSAS11a LSAS11v LSAS12a LSAS12v LSAS13a LSAS13v LSAS14a LSAS14v LSAS15a LSAS15v LSAS16a LSAS16v LSAS17a LSAS17v LSAS18a LSAS18v LSAS19a LSAS19v LSAS20a LSAS20v;
do i=1 to dim(q);
   if Q[i] < 0 then Q[i] = 0;
   if Q[i] > 3 then Q[i] = 3;
   end;
   drop i;
run;

*recheck distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_LSAS_mean;
var LSAS1a LSAS1v LSAS2a LSAS2v LSAS3a LSAS3v LSAS4a LSAS4v LSAS5a LSAS5v LSAS6a LSAS6v LSAS7a LSAS7v LSAS8a LSAS8v LSAS9a LSAS9v LSAS10a LSAS10v LSAS11a LSAS11v LSAS12a LSAS12v LSAS13a LSAS13v LSAS14a LSAS14v LSAS15a LSAS15v LSAS16a LSAS16v LSAS17a LSAS17v LSAS18a LSAS18v LSAS19a LSAS19v LSAS20a LSAS20v;
histogram LSAS1a LSAS1v LSAS2a LSAS2v LSAS3a LSAS3v LSAS4a LSAS4v LSAS5a LSAS5v LSAS6a LSAS6v LSAS7a LSAS7v LSAS8a LSAS8v LSAS9a LSAS9v LSAS10a LSAS10v LSAS11a LSAS11v LSAS12a LSAS12v LSAS13a LSAS13v LSAS14a LSAS14v LSAS15a LSAS15v LSAS16a LSAS16v LSAS17a LSAS17v LSAS18a LSAS18v LSAS19a LSAS19v LSAS20a LSAS20v;
run;

*Create new total scale score;
data reflux_test_merged_fcs_LSAS_mean;
set reflux_test_merged_fcs_LSAS_mean;
LSAStot = LSAS1a + LSAS1v + LSAS2a + LSAS2v + LSAS3a + LSAS3v + LSAS4a + LSAS4v + LSAS5a + LSAS5v + LSAS6a + LSAS6v + LSAS7a + LSAS7v + LSAS8a + LSAS8v + LSAS9a + LSAS9v + LSAS10a + LSAS10v + LSAS11a + LSAS11v + LSAS12a + LSAS12v + LSAS13a + LSAS13v + LSAS14a + LSAS14v + LSAS15a + LSAS15v + LSAS16a + LSAS16v + LSAS17a + LSAS17v + LSAS18a + LSAS18v + LSAS19a + LSAS19v + LSAS20a + LSAS20v; 
run;

*Add suffix "_IMP_IT" to all variables except subject ID (per https://support.sas.com/kb/48/674.html);
proc sql noprint;
   select cats(name,'=',name,'_imp_IT')
          into :list
          separated by ' '
          from dictionary.columns
          where libname = 'WORK' and memname = 'REFLUX_TEST_MERGED_FCS_LSAS_MEAN'
          and upcase(name) like 'LSAS%';
quit;

*Rename using the macro variable you have created;
proc datasets library = work nolist;
   modify reflux_test_merged_fcs_LSAS_mean;
   rename &list;
quit;

*match label to new variable name (e.g., change label to reflect '_imp_IT' variable name;
proc datasets lib=work;
  modify reflux_test_merged_fcs_LSAS_mean;
  attrib _all_ label=' ';
run;

*save dataset; 
*libname reflux "C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\data\SAS Files\Individual_Variable_Datasets";
data refl_ind.reflux_test_LSAS;
  set work.reflux_test_merged_fcs_LSAS_mean;
run;


*------------------------------------------------------------------------------------

*--------------
      CNAQ
---------------

*----------------------
PREPARING TO CONDUCT MI
-----------------------;

*Examine Missing Data Patterns among your variables of interest;
proc mi data=refl_ind.reflux_test_merged nimpute=0;
var CNAQ1 CNAQ2 CNAQ3 CNAQ4 CNAQ5 CNAQ6 CNAQ7 CNAQ8;
ods select misspattern;
run;

*----------------------------------------
MI USING MULTIVARIATE NORMAL DISTRIBUTION
-----------------------------------------

1. Imputation Phase;
proc mi data=refl_ind.reflux_test_merged nimpute=50 out=reflux_test_merged_fcs_CNAQ seed=54321 ;*simple minimum=(-.5) maximum=(6.5);
class gender_imp marital_status_imp education_imp occupation_imp;
var CNAQ1 CNAQ2 CNAQ3 CNAQ4 CNAQ5 CNAQ6 CNAQ7 CNAQ8
wellbeing_imp RQ_zuur_imp RQ_bovenbuik_imp RQ_onderbuik_imp RQ_misselijkheid_imp RQ_slaapstoornissen_imp RQ_andere_imp
MAAGtotaal_imp PHQ15som_imp PHQ9dep_imp LSAStot_imp PTSDtotaal_imp STAIStot_imp STAITtot_imp ASItot_imp VSItot_imp PASStot_imp 
PCCLcat_imp PCCLpco_imp PCCLint_imp PCCLext_imp IAStot_imp BAQtot_imp NEO_N_imp NEO_E_imp NEO_O_imp NEO_A_imp NEO_c_imp CIStot_imp CTQtot_imp 
age_imp gender_imp marital_status_imp education_imp occupation_imp weight_imp length_imp BMI_imp total_gastric_acid_exp_imp total_eso_acid_exp_imp tot_vol_exp_imp total_nr_acid_imp;;
fcs discrim(gender_imp marital_status_imp education_imp occupation_imp /classeffects=include) nbiter =100; 
run;

*2. Analysis Phase;
proc means data=reflux_test_merged_fcs_CNAQ nway mean;
var CNAQ1 CNAQ2 CNAQ3 CNAQ4 CNAQ5 CNAQ6 CNAQ7 CNAQ8;
class subject;
output out = reflux_test_merged_fcs_CNAQ_mean (drop = _TYPE_ _FREQ_);
run;

data reflux_test_merged_fcs_CNAQ_mean;
set reflux_test_merged_fcs_CNAQ_mean;
if _STAT_ NE 'MEAN' then delete;
drop _STAT_;
run;

*check distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_CNAQ_mean;
var CNAQ1 CNAQ2 CNAQ3 CNAQ4 CNAQ5 CNAQ6 CNAQ7 CNAQ8;
histogram CNAQ1 CNAQ2 CNAQ3 CNAQ4 CNAQ5 CNAQ6 CNAQ7 CNAQ8;
run;

*Remove out of range/extreme values;
data reflux_test_merged_fcs_CNAQ_mean;
set reflux_test_merged_fcs_CNAQ_mean;

array q  CNAQ1 CNAQ2 CNAQ3 CNAQ4 CNAQ5 CNAQ6 CNAQ7 CNAQ8;
do i=1 to dim(q);
   if Q[i] < 1 then Q[i] = 1;
   if Q[i] > 5 then Q[i] = 5;
   end;
   drop i;
run;

*recheck distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_CNAQ_mean;
var CNAQ1 CNAQ2 CNAQ3 CNAQ4 CNAQ5 CNAQ6 CNAQ7 CNAQ8;
histogram CNAQ1 CNAQ2 CNAQ3 CNAQ4 CNAQ5 CNAQ6 CNAQ7 CNAQ8;
run;

*Create new total scale score;
data reflux_test_merged_fcs_CNAQ_mean;
set reflux_test_merged_fcs_CNAQ_mean;
CNAQtot = CNAQ1 + CNAQ2 + CNAQ3 + CNAQ4 + CNAQ5 + CNAQ6 + CNAQ7 + CNAQ8; 
run;

*Add suffix "_IMP_IT" to all variables except subject ID (per https://support.sas.com/kb/48/674.html);
proc sql noprint;
   select cats(name,'=',name,'_imp_IT')
          into :list
          separated by ' '
          from dictionary.columns
          where libname = 'WORK' and memname = 'REFLUX_TEST_MERGED_FCS_CNAQ_MEAN'
          and upcase(name) like 'CNAQ%';
quit;

*Rename using the macro variable you have created;
proc datasets library = work nolist;
   modify reflux_test_merged_fcs_CNAQ_mean;
   rename &list;
quit;

*match label to new variable name (e.g., change label to reflect '_imp_IT' variable name);
proc datasets lib=work;
  modify reflux_test_merged_fcs_CNAQ_mean;
  attrib _all_ label=' ';
run;

*save dataset; 
*libname reflux "C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\data\SAS Files\Individual_Variable_Datasets";
data refl_ind.reflux_test_CNAQ;
  set reflux_test_merged_fcs_CNAQ_mean;
run;


*------------------------------------------------------------------------------------

*--------------
     MAAG
---------------

*----------------------
PREPARING TO CONDUCT MI
-----------------------;

*Examine Missing Data Patterns among your variables of interest;
proc mi data=refl_ind.reflux_test_merged nimpute=0;
var MAAG1discomfort MAAG2pain MAAG3fullness MAAG4bloated MAAG5quicklyfull MAAG6nauseous MAAG7vomit MAAG8belchingair MAAG9heartburn MAAG10chestpain;
ods select misspattern;
run;

*----------------------------------------
MI USING MULTIVARIATE NORMAL DISTRIBUTION
-----------------------------------------

1. Imputation Phase;
proc mi data=refl_ind.reflux_test_merged nimpute=50 out=reflux_test_merged_fcs_MAAG seed=54321 ;*simple minimum=(-.5) maximum=(4.5);
class gender_imp marital_status_imp education_imp occupation_imp;
var MAAG1discomfort MAAG2pain MAAG3fullness MAAG4bloated MAAG5quicklyfull MAAG6nauseous MAAG7vomit MAAG8belchingair MAAG9heartburn MAAG10chestpain 
wellbeing_imp RQ_zuur_imp RQ_bovenbuik_imp RQ_onderbuik_imp RQ_misselijkheid_imp RQ_slaapstoornissen_imp RQ_andere_imp CNAQtot_imp
PHQ15som_imp PHQ9dep_imp LSAStot_imp PTSDtotaal_imp STAIStot_imp STAITtot_imp ASItot_imp VSItot_imp PASStot_imp 
PCCLcat_imp PCCLpco_imp PCCLint_imp PCCLext_imp IAStot_imp BAQtot_imp NEO_N_imp NEO_E_imp NEO_O_imp NEO_A_imp NEO_c_imp CIStot_imp CTQtot_imp 
age_imp gender_imp marital_status_imp education_imp occupation_imp weight_imp length_imp BMI_imp total_gastric_acid_exp_imp total_eso_acid_exp_imp tot_vol_exp_imp total_nr_acid_imp;
fcs discrim(gender_imp marital_status_imp education_imp occupation_imp /classeffects=include) nbiter =100; 
run;

*2. Analysis Phase;
proc means data=reflux_test_merged_fcs_MAAG nway mean;
var MAAG1discomfort MAAG2pain MAAG3fullness MAAG4bloated MAAG5quicklyfull MAAG6nauseous MAAG7vomit MAAG8belchingair MAAG9heartburn MAAG10chestpain;
class subject;
output out = reflux_test_merged_fcs_MAAG_mean (drop = _TYPE_ _FREQ_);
run;

data reflux_test_merged_fcs_MAAG_mean;
set reflux_test_merged_fcs_MAAG_mean;
if _STAT_ NE 'MEAN' then delete;
drop _STAT_;
run;

*check distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_MAAG_mean;
var MAAG1discomfort MAAG2pain MAAG3fullness MAAG4bloated MAAG5quicklyfull MAAG6nauseous MAAG7vomit MAAG8belchingair MAAG9heartburn MAAG10chestpain;
histogram MAAG1discomfort MAAG2pain MAAG3fullness MAAG4bloated MAAG5quicklyfull MAAG6nauseous MAAG7vomit MAAG8belchingair MAAG9heartburn MAAG10chestpain;
run;

*Remove out of range/extreme values;
data reflux_test_merged_fcs_MAAG_mean;
set reflux_test_merged_fcs_MAAG_mean;

array q  MAAG1discomfort MAAG2pain MAAG3fullness MAAG4bloated MAAG5quicklyfull MAAG6nauseous MAAG7vomit MAAG8belchingair MAAG9heartburn MAAG10chestpain;
do i=1 to dim(q);
   if Q[i] < 0 then Q[i] = 0;
   if Q[i] > 4 then Q[i] = 4;
   end;
   drop i;
run;

*recheck distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_MAAG_mean;
var MAAG1discomfort MAAG2pain MAAG3fullness MAAG4bloated MAAG5quicklyfull MAAG6nauseous MAAG7vomit MAAG8belchingair MAAG9heartburn MAAG10chestpain;
histogram MAAG1discomfort MAAG2pain MAAG3fullness MAAG4bloated MAAG5quicklyfull MAAG6nauseous MAAG7vomit MAAG8belchingair MAAG9heartburn MAAG10chestpain;
run;

*Create new total scale score;
data reflux_test_merged_fcs_MAAG_mean;
set reflux_test_merged_fcs_MAAG_mean;
MAAGtotaal = MAAG1discomfort + MAAG2pain + MAAG3fullness + MAAG4bloated + MAAG5quicklyfull + MAAG6nauseous + MAAG7vomit + MAAG8belchingair + MAAG9heartburn + MAAG10chestpain; 
run;

*Add suffix "_IMP_IT" to all variables except subject ID (per https://support.sas.com/kb/48/674.html);
proc sql noprint;
   select cats(name,'=',name,'_imp_IT')
          into :list
          separated by ' '
          from dictionary.columns
          where libname = 'WORK' and memname = 'REFLUX_TEST_MERGED_FCS_MAAG_MEAN'
          and upcase(name) like 'MAAG%';
quit;

*Rename using the macro variable you have created;
proc datasets library = work nolist;
   modify reflux_test_merged_fcs_MAAG_mean;
   rename &list;
quit;

*match label to new variable name (e.g., change label to reflect '_imp_IT' variable name);
proc datasets lib=work;
  modify reflux_test_merged_fcs_MAAG_mean;
  attrib _all_ label=' ';
run;

*save dataset; 
*libname reflux "C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\data\SAS Files\Individual_Variable_Datasets";
data refl_ind.reflux_test_MAAG;
  set reflux_test_merged_fcs_MAAG_mean;
run;

*--------------
 PHQ Somatic Sx
---------------

*----------------------
PREPARING TO CONDUCT MI
-----------------------;

*Examine Missing Data Patterns among your variables of interest;
proc mi data= refl_ind.reflux_test_merged nimpute=0;
var PHQ_1a PHQ1b PHQ1c PHQ1d PHQ1e PHQ1f PHQ1g PHQ1h PHQ1i PHQ1j PHQ1k PHQ1l PHQ1m PHQ2c PHQ2d;
ods select misspattern;
run;

*----------------------------------------
MI USING MULTIVARIATE NORMAL DISTRIBUTION
-----------------------------------------

1. Imputation Phase;
proc mi data=refl_ind.reflux_test_merged nimpute=50 out=reflux_test_merged_fcs_PHQ15 seed=54321 ;*simple minimum=(-.5) maximum=(6.5);
class gender_imp marital_status_imp education_imp occupation_imp;
var PHQ_1a PHQ1b PHQ1c PHQ1d PHQ1e PHQ1f PHQ1g PHQ1h PHQ1i PHQ1j PHQ1k PHQ1l PHQ1m PHQ2c PHQ2d
wellbeing_imp RQ_zuur_imp RQ_bovenbuik_imp RQ_onderbuik_imp RQ_misselijkheid_imp RQ_slaapstoornissen_imp RQ_andere_imp CNAQtot_imp
MAAGtotaal_imp PHQ9dep_imp LSAStot_imp PTSDtotaal_imp STAIStot_imp STAITtot_imp ASItot_imp VSItot_imp PASStot_imp 
PCCLcat_imp PCCLpco_imp PCCLint_imp PCCLext_imp IAStot_imp BAQtot_imp NEO_N_imp NEO_E_imp NEO_O_imp NEO_A_imp NEO_c_imp CIStot_imp CTQtot_imp 
age_imp gender_imp marital_status_imp education_imp occupation_imp weight_imp length_imp BMI_imp total_gastric_acid_exp_imp total_eso_acid_exp_imp tot_vol_exp_imp total_nr_acid_imp;
fcs discrim(gender_imp marital_status_imp education_imp occupation_imp /classeffects=include) nbiter =100; 
run;

*2. Analysis Phase;
proc means data=reflux_test_merged_fcs_PHQ15 nway mean;
var PHQ_1a PHQ1b PHQ1c PHQ1d PHQ1e PHQ1f PHQ1g PHQ1h PHQ1i PHQ1j PHQ1k PHQ1l PHQ1m PHQ2c PHQ2d;
class subject;
output out = reflux_test_merged_fcs_PHQ15_m (drop = _TYPE_ _FREQ_);
run;

data reflux_test_merged_fcs_PHQ15_m;
set reflux_test_merged_fcs_PHQ15_m;
if _STAT_ NE 'MEAN' then delete;
drop _STAT_;
run;

*check distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_PHQ15_m;
var PHQ_1a PHQ1b PHQ1c PHQ1d PHQ1e PHQ1f PHQ1g PHQ1h PHQ1i PHQ1j PHQ1k PHQ1l PHQ1m PHQ2c PHQ2d;
histogram PHQ_1a PHQ1b PHQ1c PHQ1d PHQ1e PHQ1f PHQ1g PHQ1h PHQ1i PHQ1j PHQ1k PHQ1l PHQ1m PHQ2c PHQ2d;
run;

*Remove out of range/extreme values;
data reflux_test_merged_fcs_PHQ15_m;
set reflux_test_merged_fcs_PHQ15_m;

array q  PHQ_1a PHQ1b PHQ1c PHQ1d PHQ1e PHQ1f PHQ1g PHQ1h PHQ1i PHQ1j PHQ1k PHQ1l PHQ1m PHQ2c PHQ2d;
do i=1 to dim(q);
   if Q[i] < 0 then Q[i] = 0;
   if Q[i] > 2 then Q[i] = 2;
   end;
   drop i;
run;

*recheck distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_PHQ15_m;
var PHQ_1a PHQ1b PHQ1c PHQ1d PHQ1e PHQ1f PHQ1g PHQ1h PHQ1i PHQ1j PHQ1k PHQ1l PHQ1m PHQ2c PHQ2d;
histogram PHQ_1a PHQ1b PHQ1c PHQ1d PHQ1e PHQ1f PHQ1g PHQ1h PHQ1i PHQ1j PHQ1k PHQ1l PHQ1m PHQ2c PHQ2d;
run;

*Create new total scale score;
data reflux_test_merged_fcs_PHQ15_m;
set reflux_test_merged_fcs_PHQ15_m;
PHQ15 = PHQ_1a + PHQ1b + PHQ1c + PHQ1d + PHQ1e + PHQ1f + PHQ1g + PHQ1h + PHQ1i + PHQ1j + PHQ1k + PHQ1l + PHQ1m + PHQ2c + PHQ2d;
PHQ15_14 = PHQ_1a + PHQ1b + PHQ1c + PHQ1e + PHQ1f + PHQ1g + PHQ1h + PHQ1i + PHQ1j + PHQ1k + PHQ1l + PHQ1m + PHQ2c + PHQ2d; 
run;

*Add suffix "_IMP_IT" to all variables except subject ID (per https://support.sas.com/kb/48/674.html);
proc sql noprint;
   select cats(name,'=',name,'_imp_IT')
          into :list
          separated by ' '
          from dictionary.columns
          where libname = 'WORK' and memname = 'REFLUX_TEST_MERGED_FCS_PHQ15_M'
          and upcase(name) like 'PHQ%';
quit;

*Rename using the macro variable you have created;
proc datasets library = work nolist;
   modify reflux_test_merged_fcs_PHQ15_m;
   rename &list;
quit;

*match label to new variable name (e.g., change label to reflect '_imp_IT' variable name);
proc datasets lib=work;
  modify reflux_test_merged_fcs_PHQ15_m;
  attrib _all_ label=' ';
run;

*save dataset; 
*libname reflux "C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\data\SAS Files\Individual_Variable_Datasets";
data refl_ind.reflux_test_PHQ15;
  set reflux_test_merged_fcs_PHQ15_m;
run;


*------------------------------------------------------------------------------------

*--------------
PHQ9 DEPRESSION
---------------

*----------------------
PREPARING TO CONDUCT MI
-----------------------;

*Examine Missing Data Patterns among your variables of interest;
proc mi data=refl_ind.reflux_test_merged nimpute=0;
var PHQ2a PHQ2b PHQ2c_1 PHQ2d_1 PHQ2e PHQ2f PHQ2g PHQ2h PHQ2i;
ods select misspattern;
run;

*----------------------------------------
MI USING MULTIVARIATE NORMAL DISTRIBUTION
-----------------------------------------

1. Imputation Phase;
proc mi data=refl_ind.reflux_test_merged nimpute=50 out=reflux_test_merged_fcs_phq9 seed=54321 simple minimum=(-0.5) maximum=(3.5);
class gender_imp marital_status_imp education_imp occupation_imp;
var PHQ2a PHQ2b PHQ2c_1 PHQ2d_1 PHQ2e PHQ2f PHQ2g PHQ2h PHQ2i 
wellbeing_imp RQ_zuur_imp RQ_bovenbuik_imp RQ_onderbuik_imp RQ_misselijkheid_imp RQ_slaapstoornissen_imp RQ_andere_imp CNAQtot_imp
MAAGtotaal_imp PHQ15som_imp LSAStot_imp PTSDtotaal_imp STAIStot_imp STAITtot_imp ASItot_imp VSItot_imp PASStot_imp 
PCCLcat_imp PCCLpco_imp PCCLint_imp PCCLext_imp IAStot_imp BAQtot_imp NEO_N_imp NEO_E_imp NEO_O_imp NEO_A_imp NEO_c_imp CIStot_imp CTQtot_imp 
age_imp gender_imp marital_status_imp education_imp occupation_imp weight_imp length_imp BMI_imp total_gastric_acid_exp_imp total_eso_acid_exp_imp tot_vol_exp_imp total_nr_acid_imp;
fcs discrim(gender_imp marital_status_imp education_imp occupation_imp /classeffects=include) nbiter =100; 
run;

*2. Analysis Phase
NOTE: in our case, this simply implies calculating the mean for each subject over the 50 imputations;
proc means data=reflux_test_merged_fcs_phq9 nway mean;
var PHQ2a PHQ2b PHQ2c_1 PHQ2d_1 PHQ2e PHQ2f PHQ2g PHQ2h PHQ2i;
class subject;
output out = reflux_test_merged_fcs_phq9_mean (drop = _TYPE_ _FREQ_);
run;

data reflux_test_merged_fcs_phq9_mean;
set reflux_test_merged_fcs_phq9_mean;
if _STAT_ NE 'MEAN' then delete;
drop _STAT_;
run;

*check distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_phq9_mean;
var PHQ2a PHQ2b PHQ2c_1 PHQ2d_1 PHQ2e PHQ2f PHQ2g PHQ2h PHQ2i;
histogram PHQ2a PHQ2b PHQ2c_1 PHQ2d_1 PHQ2e PHQ2f PHQ2g PHQ2h PHQ2i;
run;

*Remove out of range/extreme values;
data reflux_test_merged_fcs_phq9_mean;
set reflux_test_merged_fcs_phq9_mean;

array q  PHQ2a PHQ2b PHQ2c_1 PHQ2d_1 PHQ2e PHQ2f PHQ2g PHQ2h PHQ2i;
do i=1 to dim(q);
   if Q[i] < 0 then Q[i] = 0;
   if Q[i] > 3 then Q[i] = 3;
   end;
   drop i;
run;

*recheck distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_phq9_mean;
var PHQ2a PHQ2b PHQ2c_1 PHQ2d_1 PHQ2e PHQ2f PHQ2g PHQ2h PHQ2i;
histogram PHQ2a PHQ2b PHQ2c_1 PHQ2d_1 PHQ2e PHQ2f PHQ2g PHQ2h PHQ2i;
run;

*Create new total scale score;
data reflux_test_merged_fcs_phq9_mean;
set reflux_test_merged_fcs_phq9_mean;
PHQ9dep = PHQ2a + PHQ2b + PHQ2c_1 + PHQ2d_1 + PHQ2e + PHQ2f + PHQ2g + PHQ2h + PHQ2i; 
run;

*Add suffix "_IMP_IT" to all variables except subject ID (per https://support.sas.com/kb/48/674.html);
proc sql noprint;
   select cats(name,'=',name,'_imp_IT')
          into :list
          separated by ' '
          from dictionary.columns
          where libname = 'WORK' and memname = 'REFLUX_TEST_MERGED_FCS_PHQ9_MEAN'
          and upcase(name) like 'PHQ%';
quit;

*Rename using the macro variable you have created;
proc datasets library = work nolist;
   modify reflux_test_merged_fcs_phq9_mean;
   rename &list;
quit;

*match label to new variable name (e.g., change label to reflect '_imp_IT' variable name);
proc datasets lib=work;
  modify reflux_test_merged_fcs_phq9_mean;
  attrib _all_ label=' ';
run;

*save dataset; 
*libname reflux "C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\data\SAS Files\Individual_Variable_Datasets";
data refl_ind.reflux_test_phq9;
  set work.reflux_test_merged_fcs_phq9_mean;
run;


*------------------------------------------------------------------------------------

*--------------
     LSAS
---------------

*----------------------
PREPARING TO CONDUCT MI
-----------------------;

proc mi data=refl_ind.reflux_test_merged nimpute=0;
var LSAS1a LSAS1v LSAS2a LSAS2v LSAS3a LSAS3v LSAS4a LSAS4v LSAS5a LSAS5v LSAS6a LSAS6v LSAS7a LSAS7v LSAS8a LSAS8v LSAS9a LSAS9v LSAS10a LSAS10v LSAS11a LSAS11v LSAS12a LSAS12v LSAS13a LSAS13v LSAS14a LSAS14v LSAS15a LSAS15v LSAS16a LSAS16v LSAS17a LSAS17v LSAS18a LSAS18v LSAS19a LSAS19v LSAS20a LSAS20v LSAS21a LSAS21v LSAS22a LSAS22v LSAS23a LSAS23v LSAS24a LSAS24v; 
ods select misspattern;
run;

*----------------------------------------
MI USING MULTIVARIATE NORMAL DISTRIBUTION
-----------------------------------------

1. Imputation Phase;
proc mi data=refl_ind.reflux_test_merged nimpute=50 out=reflux_test_merged_fcs_LSAS seed=54321 ;*simple minimum=(-.5) maximum=(4.5);
class gender_imp marital_status_imp education_imp occupation_imp;
var LSAS1a LSAS1v LSAS2a LSAS2v LSAS3a LSAS3v LSAS4a LSAS4v LSAS5a LSAS5v LSAS6a LSAS6v LSAS7a LSAS7v LSAS8a LSAS8v LSAS9a LSAS9v LSAS10a LSAS10v LSAS11a LSAS11v LSAS12a LSAS12v LSAS13a LSAS13v LSAS14a LSAS14v LSAS15a LSAS15v LSAS16a LSAS16v LSAS17a LSAS17v LSAS18a LSAS18v LSAS19a LSAS19v LSAS20a LSAS20v LSAS21a LSAS21v LSAS22a LSAS22v LSAS23a LSAS23v LSAS24a LSAS24v
wellbeing_imp RQ_zuur_imp RQ_bovenbuik_imp RQ_onderbuik_imp RQ_misselijkheid_imp RQ_slaapstoornissen_imp RQ_andere_imp CNAQtot_imp
MAAGtotaal_imp PHQ15som_imp PHQ9dep_imp PTSDtotaal_imp STAIStot_imp STAITtot_imp ASItot_imp VSItot_imp PASStot_imp 
PCCLcat_imp PCCLpco_imp PCCLint_imp PCCLext_imp IAStot_imp BAQtot_imp NEO_N_imp NEO_E_imp NEO_O_imp NEO_A_imp NEO_c_imp CIStot_imp CTQtot_imp 
age_imp gender_imp marital_status_imp education_imp occupation_imp weight_imp length_imp BMI_imp total_gastric_acid_exp_imp total_eso_acid_exp_imp tot_vol_exp_imp total_nr_acid_imp;
fcs discrim(gender_imp marital_status_imp education_imp occupation_imp /classeffects=include) nbiter =100; 
run;

*2. Analysis Phase;
proc means data=reflux_test_merged_fcs_LSAS nway mean;
var LSAS1a LSAS1v LSAS2a LSAS2v LSAS3a LSAS3v LSAS4a LSAS4v LSAS5a LSAS5v LSAS6a LSAS6v LSAS7a LSAS7v LSAS8a LSAS8v LSAS9a LSAS9v LSAS10a LSAS10v LSAS11a LSAS11v LSAS12a LSAS12v LSAS13a LSAS13v LSAS14a LSAS14v LSAS15a LSAS15v LSAS16a LSAS16v LSAS17a LSAS17v LSAS18a LSAS18v LSAS19a LSAS19v LSAS20a LSAS20v LSAS21a LSAS21v LSAS22a LSAS22v LSAS23a LSAS23v LSAS24a LSAS24v;
class subject;
output out = reflux_test_merged_fcs_LSAS_mean (drop = _TYPE_ _FREQ_);
run;

data reflux_test_merged_fcs_LSAS_mean;
set reflux_test_merged_fcs_LSAS_mean;
if _STAT_ NE 'MEAN' then delete;
drop _STAT_;
run;

*check distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_LSAS_mean;
var LSAS1a LSAS1v LSAS2a LSAS2v LSAS3a LSAS3v LSAS4a LSAS4v LSAS5a LSAS5v LSAS6a LSAS6v LSAS7a LSAS7v LSAS8a LSAS8v LSAS9a LSAS9v LSAS10a LSAS10v LSAS11a LSAS11v LSAS12a LSAS12v LSAS13a LSAS13v LSAS14a LSAS14v LSAS15a LSAS15v LSAS16a LSAS16v LSAS17a LSAS17v LSAS18a LSAS18v LSAS19a LSAS19v LSAS20a LSAS20v LSAS21a LSAS21v LSAS22a LSAS22v LSAS23a LSAS23v LSAS24a LSAS24v;
histogram LSAS1a LSAS1v LSAS2a LSAS2v LSAS3a LSAS3v LSAS4a LSAS4v LSAS5a LSAS5v LSAS6a LSAS6v LSAS7a LSAS7v LSAS8a LSAS8v LSAS9a LSAS9v LSAS10a LSAS10v LSAS11a LSAS11v LSAS12a LSAS12v LSAS13a LSAS13v LSAS14a LSAS14v LSAS15a LSAS15v LSAS16a LSAS16v LSAS17a LSAS17v LSAS18a LSAS18v LSAS19a LSAS19v LSAS20a LSAS20v LSAS21a LSAS21v LSAS22a LSAS22v LSAS23a LSAS23v LSAS24a LSAS24v;
run;

*Get rid of out of range/extreme values;
data reflux_test_merged_fcs_LSAS_mean;
set reflux_test_merged_fcs_LSAS_mean;

array q  LSAS1a LSAS1v LSAS2a LSAS2v LSAS3a LSAS3v LSAS4a LSAS4v LSAS5a LSAS5v LSAS6a LSAS6v LSAS7a LSAS7v LSAS8a LSAS8v LSAS9a LSAS9v LSAS10a LSAS10v LSAS11a LSAS11v LSAS12a LSAS12v LSAS13a LSAS13v LSAS14a LSAS14v LSAS15a LSAS15v LSAS16a LSAS16v LSAS17a LSAS17v LSAS18a LSAS18v LSAS19a LSAS19v LSAS20a LSAS20v LSAS21a LSAS21v LSAS22a LSAS22v LSAS23a LSAS23v LSAS24a LSAS24v;
do i=1 to dim(q);
   if Q[i] < 0 then Q[i] = 0;
   if Q[i] > 3 then Q[i] = 3;
   end;
   drop i;
run;

*recheck distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_LSAS_mean;
var LSAS1a LSAS1v LSAS2a LSAS2v LSAS3a LSAS3v LSAS4a LSAS4v LSAS5a LSAS5v LSAS6a LSAS6v LSAS7a LSAS7v LSAS8a LSAS8v LSAS9a LSAS9v LSAS10a LSAS10v LSAS11a LSAS11v LSAS12a LSAS12v LSAS13a LSAS13v LSAS14a LSAS14v LSAS15a LSAS15v LSAS16a LSAS16v LSAS17a LSAS17v LSAS18a LSAS18v LSAS19a LSAS19v LSAS20a LSAS20v LSAS21a LSAS21v LSAS22a LSAS22v LSAS23a LSAS23v LSAS24a LSAS24v;
histogram LSAS1a LSAS1v LSAS2a LSAS2v LSAS3a LSAS3v LSAS4a LSAS4v LSAS5a LSAS5v LSAS6a LSAS6v LSAS7a LSAS7v LSAS8a LSAS8v LSAS9a LSAS9v LSAS10a LSAS10v LSAS11a LSAS11v LSAS12a LSAS12v LSAS13a LSAS13v LSAS14a LSAS14v LSAS15a LSAS15v LSAS16a LSAS16v LSAS17a LSAS17v LSAS18a LSAS18v LSAS19a LSAS19v LSAS20a LSAS20v LSAS21a LSAS21v LSAS22a LSAS22v LSAS23a LSAS23v LSAS24a LSAS24v;
run;

*Create new total scale score;
data reflux_test_merged_fcs_LSAS_mean;
set reflux_test_merged_fcs_LSAS_mean;
LSAStot = LSAS1a + LSAS1v + LSAS2a + LSAS2v + LSAS3a + LSAS3v + LSAS4a + LSAS4v + LSAS5a + LSAS5v + LSAS6a + LSAS6v + LSAS7a + LSAS7v + LSAS8a + LSAS8v + LSAS9a + LSAS9v + LSAS10a + LSAS10v + LSAS11a + LSAS11v + LSAS12a + LSAS12v + LSAS13a + LSAS13v + LSAS14a + LSAS14v + LSAS15a + LSAS15v + LSAS16a + LSAS16v + LSAS17a + LSAS17v + LSAS18a + LSAS18v + LSAS19a + LSAS19v + LSAS20a + LSAS20v + LSAS21a + LSAS21v + LSAS22a + LSAS22v + LSAS23a + LSAS23v + LSAS24a + LSAS24v; 
run;

*Add suffix "_IMP_IT" to all variables except subject ID (per https://support.sas.com/kb/48/674.html);
proc sql noprint;
   select cats(name,'=',name,'_imp_IT')
          into :list
          separated by ' '
          from dictionary.columns
          where libname = 'WORK' and memname = 'REFLUX_TEST_MERGED_FCS_LSAS_MEAN'
          and upcase(name) like 'LSAS%';
quit;

*Rename using the macro variable you have created;
proc datasets library = work nolist;
   modify reflux_test_merged_fcs_LSAS_mean;
   rename &list;
quit;

*match label to new variable name (e.g., change label to reflect '_imp_IT' variable name;
proc datasets lib=work;
  modify reflux_test_merged_fcs_LSAS_mean;
  attrib _all_ label=' ';
run;

*save dataset; 
*libname reflux "C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\data\SAS Files\Individual_Variable_Datasets";
data refl_ind.reflux_test_LSAS;
  set work.reflux_test_merged_fcs_LSAS_mean;
run;


*------------------------------------------------------------------------------------

*--------------
      PTSD
---------------

*----------------------
PREPARING TO CONDUCT MI
-----------------------;

*Examine Missing Data Patterns among your variables of interest;
proc mi data=refl_ind.reflux_test_merged nimpute=0;
var PTSD1 PTSD2 PTSD3 PTSD4 PTSD5 PTSD6 PTSD7 PTSD8 PTSD9 PTSD10 PTSD11 PTSD12 PTSD13 PTSD14 PTSD15 PTSD16 PTSD17 PTSD18 PTSD19 PTSD20 PTSD21 PTSD22; 
ods select misspattern;
run;

*----------------------------------------
MI USING MULTIVARIATE NORMAL DISTRIBUTION
-----------------------------------------

1. Imputation Phase;
proc mi data=refl_ind.reflux_test_merged nimpute=50 out=reflux_test_merged_fcs_PTSD seed=54321 simple minimum=(.5) maximum=(4.5);
class gender_imp marital_status_imp education_imp occupation_imp;
var PTSD1 PTSD2 PTSD3 PTSD4 PTSD5 PTSD6 PTSD7 PTSD8 PTSD9 PTSD10 PTSD11 PTSD12 PTSD13 PTSD14 PTSD15 PTSD16 PTSD17 PTSD18 PTSD19 PTSD20 PTSD21 PTSD22 
wellbeing_imp RQ_zuur_imp RQ_bovenbuik_imp RQ_onderbuik_imp RQ_misselijkheid_imp RQ_slaapstoornissen_imp RQ_andere_imp CNAQtot_imp
MAAGtotaal_imp PHQ15som_imp PHQ9dep_imp LSAStot_imp STAIStot_imp STAITtot_imp ASItot_imp VSItot_imp PASStot_imp 
PCCLcat_imp PCCLpco_imp PCCLint_imp PCCLext_imp IAStot_imp BAQtot_imp NEO_N_imp NEO_E_imp NEO_O_imp NEO_A_imp NEO_c_imp CIStot_imp CTQtot_imp 
age_imp gender_imp marital_status_imp education_imp occupation_imp weight_imp length_imp BMI_imp total_gastric_acid_exp_imp total_eso_acid_exp_imp tot_vol_exp_imp total_nr_acid_imp;
fcs discrim(gender_imp marital_status_imp education_imp occupation_imp /classeffects=include) nbiter =100; 
run;

*2. Analysis Phase;
proc means data=reflux_test_merged_fcs_PTSD nway mean;
var PTSD1 PTSD2 PTSD3 PTSD4 PTSD5 PTSD6 PTSD7 PTSD8 PTSD9 PTSD10 PTSD11 PTSD12 PTSD13 PTSD14 PTSD15 PTSD16 PTSD17 PTSD18 PTSD19 PTSD20 PTSD21 PTSD22;
class subject;
output out = reflux_test_merged_fcs_PTSD_mean (drop = _TYPE_ _FREQ_);
run;

data reflux_test_merged_fcs_PTSD_mean;
set reflux_test_merged_fcs_PTSD_mean;
if _STAT_ NE 'MEAN' then delete;
drop _STAT_;
run;

*check distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_PTSD_mean;
var PTSD1 PTSD2 PTSD3 PTSD4 PTSD5 PTSD6 PTSD7 PTSD8 PTSD9 PTSD10 PTSD11 PTSD12 PTSD13 PTSD14 PTSD15 PTSD16 PTSD17 PTSD18 PTSD19 PTSD20 PTSD21 PTSD22;
histogram PTSD1 PTSD2 PTSD3 PTSD4 PTSD5 PTSD6 PTSD7 PTSD8 PTSD9 PTSD10 PTSD11 PTSD12 PTSD13 PTSD14 PTSD15 PTSD16 PTSD17 PTSD18 PTSD19 PTSD20 PTSD21 PTSD22;
run;

*Remove out of range/extreme values;
data reflux_test_merged_fcs_PTSD_mean;
set reflux_test_merged_fcs_PTSD_mean;

array q  PTSD1 PTSD2 PTSD3 PTSD4 PTSD5 PTSD6 PTSD7 PTSD8 PTSD9 PTSD10 PTSD11 PTSD12 PTSD13 PTSD14 PTSD15 PTSD16 PTSD17 PTSD18 PTSD19 PTSD20 PTSD21 PTSD22;
do i=1 to dim(q);
   if Q[i] < 1 then Q[i] = 1;
   if Q[i] > 4 then Q[i] = 4;
   end;
   drop i;
run;

*recheck distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_PTSD_mean;
var PTSD1 PTSD2 PTSD3 PTSD4 PTSD5 PTSD6 PTSD7 PTSD8 PTSD9 PTSD10 PTSD11 PTSD12 PTSD13 PTSD14 PTSD15 PTSD16 PTSD17 PTSD18 PTSD19 PTSD20 PTSD21 PTSD22;
histogram PTSD1 PTSD2 PTSD3 PTSD4 PTSD5 PTSD6 PTSD7 PTSD8 PTSD9 PTSD10 PTSD11 PTSD12 PTSD13 PTSD14 PTSD15 PTSD16 PTSD17 PTSD18 PTSD19 PTSD20 PTSD21 PTSD22;
run;

*Create new total scale score;
data reflux_test_merged_fcs_PTSD_mean;
set reflux_test_merged_fcs_PTSD_mean;
PTSDtotaal = PTSD1 + PTSD2 + PTSD3 + PTSD4 + PTSD5 + PTSD6 + PTSD7 + PTSD8 + PTSD9 + PTSD10 + PTSD11 + PTSD12 + PTSD13 + PTSD14 + PTSD15 + PTSD16 + PTSD17 + PTSD18 + PTSD19 + PTSD20 + PTSD21 + PTSD22; 
run;

*Add suffix "_IMP_IT" to all variables except subject ID (per https://support.sas.com/kb/48/674.html);
proc sql noprint;
   select cats(name,'=',name,'_imp_IT')
          into :list
          separated by ' '
          from dictionary.columns
          where libname = 'WORK' and memname = 'REFLUX_TEST_MERGED_FCS_PTSD_MEAN'
          and upcase(name) like 'PTSD%';
quit;

*Rename using the macro variable you have created;
proc datasets library = work nolist;
   modify reflux_test_merged_fcs_PTSD_mean;
   rename &list;
quit;

*match label to new variable name (e.g., change label to reflect '_imp_IT' variable name;
proc datasets lib=work;
  modify reflux_test_merged_fcs_PTSD_mean;
  attrib _all_ label=' ';
run;

*save dataset; 
*libname reflux "C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\data\SAS Files\Individual_Variable_Datasets";
data refl_ind.reflux_test_PTSD;
  set work.reflux_test_merged_fcs_PTSD_mean;
run;


*------------------------------------------------------------------------------------

*--------------
  STAI STATE
---------------

*----------------------
PREPARING TO CONDUCT MI
-----------------------;

*Examine Missing Data Patterns among your variables of interest;
proc mi data=refl_ind.reflux_test_merged nimpute=0;
var STAIS1 STAIS2 STAIS3 STAIS4 STAIS5 STAIS6 STAIS7 STAIS8 STAIS9 STAIS10 STAIS11 STAIS12 STAIS13 STAIS14 STAIS15 STAIS16 STAIS17 STAIS18 STAIS19 STAIS20; 
ods select misspattern;
run;

*----------------------------------------
MI USING MULTIVARIATE NORMAL DISTRIBUTION
-----------------------------------------

1. Imputation Phase;
proc mi data=refl_ind.reflux_test_merged nimpute=50 out=reflux_test_merged_fcs_STAIS seed=54321 simple minimum=(.5) maximum=(4.5);
class gender_imp marital_status_imp education_imp occupation_imp;
var STAIS1 STAIS2 STAIS3 STAIS4 STAIS5 STAIS6 STAIS7 STAIS8 STAIS9 STAIS10 STAIS11 STAIS12 STAIS13 STAIS14 STAIS15 STAIS16 STAIS17 STAIS18 STAIS19 STAIS20
wellbeing_imp RQ_zuur_imp RQ_bovenbuik_imp RQ_onderbuik_imp RQ_misselijkheid_imp RQ_slaapstoornissen_imp RQ_andere_imp CNAQtot_imp
MAAGtotaal_imp PHQ15som_imp PHQ9dep_imp LSAStot_imp PTSDtotaal_imp STAITtot_imp ASItot_imp VSItot_imp PASStot_imp 
PCCLcat_imp PCCLpco_imp PCCLint_imp PCCLext_imp IAStot_imp BAQtot_imp NEO_N_imp NEO_E_imp NEO_O_imp NEO_A_imp NEO_c_imp CIStot_imp CTQtot_imp 
age_imp gender_imp marital_status_imp education_imp occupation_imp weight_imp length_imp BMI_imp total_gastric_acid_exp_imp total_eso_acid_exp_imp tot_vol_exp_imp total_nr_acid_imp;
fcs discrim(gender_imp marital_status_imp education_imp occupation_imp /classeffects=include) nbiter =100; 
run;

*2. Analysis Phase;
proc means data=reflux_test_merged_fcs_STAIS nway mean;
var STAIS1 STAIS2 STAIS3 STAIS4 STAIS5 STAIS6 STAIS7 STAIS8 STAIS9 STAIS10 STAIS11 STAIS12 STAIS13 STAIS14 STAIS15 STAIS16 STAIS17 STAIS18 STAIS19 STAIS20;
class subject;
output out = reflux_test_merged_fcs_STAIS_m (drop = _TYPE_ _FREQ_);
run;

data reflux_test_merged_fcs_STAIS_m;
set reflux_test_merged_fcs_STAIS_m;
if _STAT_ NE 'MEAN' then delete;
drop _STAT_;
run;

*check distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_STAIS_m;
var STAIS1 STAIS2 STAIS3 STAIS4 STAIS5 STAIS6 STAIS7 STAIS8 STAIS9 STAIS10 STAIS11 STAIS12 STAIS13 STAIS14 STAIS15 STAIS16 STAIS17 STAIS18 STAIS19 STAIS20;
histogram STAIS1 STAIS2 STAIS3 STAIS4 STAIS5 STAIS6 STAIS7 STAIS8 STAIS9 STAIS10 STAIS11 STAIS12 STAIS13 STAIS14 STAIS15 STAIS16 STAIS17 STAIS18 STAIS19 STAIS20;
run;
*No out of range/extreme values;

*Create new total scale score;
data reflux_test_merged_fcs_STAIS_m;
set reflux_test_merged_fcs_STAIS_m;
STAIStot = (5 - STAIS1) + (5 - STAIS2) + STAIS3 + STAIS4 + (5 - STAIS5) + STAIS6 + STAIS7 + (5 - STAIS8) + STAIS9 + (5 - STAIS10) + (5 - STAIS11) + STAIS12 + STAIS13 + STAIS14 + (5 - STAIS15) + (5 - STAIS16) + STAIS17 + STAIS18 + (5 - STAIS19) + (5 - STAIS20); 
run;

*Add suffix "_IMP_IT" to all variables except subject ID (per https://support.sas.com/kb/48/674.html);
proc sql noprint;
   select cats(name,'=',name,'_imp_IT')
          into :list
          separated by ' '
          from dictionary.columns
          where libname = 'WORK' and memname = 'REFLUX_TEST_MERGED_FCS_STAIS_M'
          and upcase(name) like 'STAIS%';
quit;

*Rename using the macro variable you have created;
proc datasets library = work nolist;
   modify reflux_test_merged_fcs_STAIS_m;
   rename &list;
quit;

*match label to new variable name (e.g., change label to reflect '_imp_IT' variable name);
proc datasets lib=work;
  modify reflux_test_merged_fcs_STAIS_m;
  attrib _all_ label=' ';
run;

*save dataset; 
*libname reflux "C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\data\SAS Files\Individual_Variable_Datasets";
data refl_ind.reflux_test_STAIS;
  set reflux_test_merged_fcs_STAIS_m;
run;

*------------------------------------------------------------------------------------

*--------------
  STAI TRAIT
---------------

*----------------------
PREPARING TO CONDUCT MI
-----------------------;

*Examine Missing Data Patterns among your variables of interest;
proc mi data=refl_ind.reflux_test_merged nimpute=0;
var STAIT1 STAIT2 STAIT3 STAIT4 STAIT5 STAIT6 STAIT7 STAIT8 STAIT9 STAIT10 STAIT11 STAIT12 STAIT13 STAIT14 STAIT15 STAIT16 STAIT17 STAIT18 STAIT19 STAIT20; 
ods select misspattern;
run;

*----------------------------------------
MI USING MULTIVARIATE NORMAL DISTRIBUTION
-----------------------------------------

1. Imputation Phase;
proc mi data=refl_ind.reflux_test_merged nimpute=50 out=reflux_test_merged_fcs_STAIT seed=54321 simple minimum=(.5) maximum=(4.5);
class gender_imp marital_status_imp education_imp occupation_imp;
var STAIT1 STAIT2 STAIT3 STAIT4 STAIT5 STAIT6 STAIT7 STAIT8 STAIT9 STAIT10 STAIT11 STAIT12 STAIT13 STAIT14 STAIT15 STAIT16 STAIT17 STAIT18 STAIT19 STAIT20
wellbeing_imp RQ_zuur_imp RQ_bovenbuik_imp RQ_onderbuik_imp RQ_misselijkheid_imp RQ_slaapstoornissen_imp RQ_andere_imp CNAQtot_imp
MAAGtotaal_imp PHQ15som_imp PHQ9dep_imp LSAStot_imp PTSDtotaal_imp STAIStot_imp ASItot_imp VSItot_imp PASStot_imp 
PCCLcat_imp PCCLpco_imp PCCLint_imp PCCLext_imp IAStot_imp BAQtot_imp NEO_N_imp NEO_E_imp NEO_O_imp NEO_A_imp NEO_c_imp CIStot_imp CTQtot_imp 
age_imp gender_imp marital_status_imp education_imp occupation_imp weight_imp length_imp BMI_imp total_gastric_acid_exp_imp total_eso_acid_exp_imp tot_vol_exp_imp total_nr_acid_imp;
fcs discrim(gender_imp marital_status_imp education_imp occupation_imp /classeffects=include) nbiter =100; 
run;

*2. Analysis Phase;
proc means data=reflux_test_merged_fcs_STAIT nway mean;
var STAIT1 STAIT2 STAIT3 STAIT4 STAIT5 STAIT6 STAIT7 STAIT8 STAIT9 STAIT10 STAIT11 STAIT12 STAIT13 STAIT14 STAIT15 STAIT16 STAIT17 STAIT18 STAIT19 STAIT20;
class subject;
output out = reflux_test_merged_fcs_STAIT_m (drop = _TYPE_ _FREQ_);
run;

data reflux_test_merged_fcs_STAIT_m;
set reflux_test_merged_fcs_STAIT_m;
if _STAT_ NE 'MEAN' then delete;
drop _STAT_;
run;

*check distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_STAIT_m;
var STAIT1 STAIT2 STAIT3 STAIT4 STAIT5 STAIT6 STAIT7 STAIT8 STAIT9 STAIT10 STAIT11 STAIT12 STAIT13 STAIT14 STAIT15 STAIT16 STAIT17 STAIT18 STAIT19 STAIT20;
histogram STAIT1 STAIT2 STAIT3 STAIT4 STAIT5 STAIT6 STAIT7 STAIT8 STAIT9 STAIT10 STAIT11 STAIT12 STAIT13 STAIT14 STAIT15 STAIT16 STAIT17 STAIT18 STAIT19 STAIT20;
run;

*Remove out of range/extreme values;
data reflux_test_merged_fcs_STAIT_m;
set reflux_test_merged_fcs_STAIT_m;

array q  STAIT1 STAIT2 STAIT3 STAIT4 STAIT5 STAIT6 STAIT7 STAIT8 STAIT9 STAIT10 STAIT11 STAIT12 STAIT13 STAIT14 STAIT15 STAIT16 STAIT17 STAIT18 STAIT19 STAIT20;
do i=1 to dim(q);
   if Q[i] < 1 then Q[i] = 1;
   if Q[i] > 4 then Q[i] = 4;
   end;
   drop i;
run;

*recheck distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_STAIT_m;
var STAIT1 STAIT2 STAIT3 STAIT4 STAIT5 STAIT6 STAIT7 STAIT8 STAIT9 STAIT10 STAIT11 STAIT12 STAIT13 STAIT14 STAIT15 STAIT16 STAIT17 STAIT18 STAIT19 STAIT20;
histogram STAIT1 STAIT2 STAIT3 STAIT4 STAIT5 STAIT6 STAIT7 STAIT8 STAIT9 STAIT10 STAIT11 STAIT12 STAIT13 STAIT14 STAIT15 STAIT16 STAIT17 STAIT18 STAIT19 STAIT20;
run;

*Create new total scale score;
data reflux_test_merged_fcs_STAIT_m;
set reflux_test_merged_fcs_STAIT_m;
STAITtot = (5 - STAIT1) + STAIT2 + (5 - STAIT3) + STAIT4 + STAIT5 + (5 - STAIT6) + (5 - STAIT7) + STAIT8 + STAIT9 + (5 - STAIT10) + STAIT11 + STAIT12 + (5 - STAIT13) + (5 - STAIT14) + (5 - STAIT15) + (5 - STAIT16) + STAIT17 + STAIT18 + (5 - STAIT19) + STAIT20; 
run;

*Add suffix "_IMP_IT" to all variables except subject ID (per https://support.sas.com/kb/48/674.html);
proc sql noprint;
   select cats(name,'=',name,'_imp_IT')
          into :list
          separated by ' '
          from dictionary.columns
          where libname = 'WORK' and memname = 'REFLUX_TEST_MERGED_FCS_STAIT_M'
          and upcase(name) like 'STAIT%';
quit;

*Rename using the macro variable you have created;
proc datasets library = work nolist;
   modify reflux_test_merged_fcs_STAIT_m;
   rename &list;
quit;

*match label to new variable name (e.g., change label to reflect '_imp_IT' variable name);
proc datasets lib=work;
  modify reflux_test_merged_fcs_STAIT_m;
  attrib _all_ label=' ';
run;

*save dataset; 
*libname reflux "C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\data\SAS Files\Individual_Variable_Datasets";
data refl_ind.reflux_test_STAIT;
  set work.reflux_test_merged_fcs_STAIT_m;
run;


*------------------------------------------------------------------------------------

*--------------
     ASI
---------------

*----------------------
PREPARING TO CONDUCT MI
-----------------------;

*Examine Missing Data Patterns among your variables of interest;
proc mi data=refl_ind.reflux_test_merged nimpute=0;
var ASI1 ASI2 ASI3 ASI4 ASI5 ASI6 ASI7 ASI8 ASI9 ASI10 ASI11 ASI12 ASI13 ASI14 ASI15 ASI16;
ods select misspattern;
run;

*----------------------------------------
MI USING MULTIVARIATE NORMAL DISTRIBUTION
-----------------------------------------

1. Imputation Phase;
proc mi data=refl_ind.reflux_test_merged nimpute=50 out=reflux_test_merged_fcs_ASI seed=54321 simple minimum=(-0.5) maximum=(4.5);
class gender_imp marital_status_imp education_imp occupation_imp;
var ASI1 ASI2 ASI3 ASI4 ASI5 ASI6 ASI7 ASI8 ASI9 ASI10 ASI11 ASI12 ASI13 ASI14 ASI15 ASI16 
wellbeing_imp RQ_zuur_imp RQ_bovenbuik_imp RQ_onderbuik_imp RQ_misselijkheid_imp RQ_slaapstoornissen_imp RQ_andere_imp CNAQtot_imp
MAAGtotaal_imp PHQ15som_imp PHQ9dep_imp LSAStot_imp PTSDtotaal_imp STAIStot_imp STAITtot_imp VSItot_imp PASStot_imp 
PCCLcat_imp PCCLpco_imp PCCLint_imp PCCLext_imp IAStot_imp BAQtot_imp NEO_N_imp NEO_E_imp NEO_O_imp NEO_A_imp NEO_c_imp CIStot_imp CTQtot_imp 
age_imp gender_imp marital_status_imp education_imp occupation_imp weight_imp length_imp BMI_imp total_gastric_acid_exp_imp total_eso_acid_exp_imp tot_vol_exp_imp total_nr_acid_imp;
fcs discrim(gender_imp marital_status_imp education_imp occupation_imp /classeffects=include) nbiter =100; 
run;

*2. Analysis Phase;
proc means data=reflux_test_merged_fcs_ASI nway mean;
var ASI1 ASI2 ASI3 ASI4 ASI5 ASI6 ASI7 ASI8 ASI9 ASI10 ASI11 ASI12 ASI13 ASI14 ASI15 ASI16;
class subject;
output out = reflux_test_merged_fcs_ASI_mean (drop = _TYPE_ _FREQ_);
run;

data reflux_test_merged_fcs_ASI_mean;
set reflux_test_merged_fcs_ASI_mean;
if _STAT_ NE 'MEAN' then delete;
drop _STAT_;
run;

*check distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_ASI_mean;
var ASI1 ASI2 ASI3 ASI4 ASI5 ASI6 ASI7 ASI8 ASI9 ASI10 ASI11 ASI12 ASI13 ASI14 ASI15 ASI16;
histogram ASI1 ASI2 ASI3 ASI4 ASI5 ASI6 ASI7 ASI8 ASI9 ASI10 ASI11 ASI12 ASI13 ASI14 ASI15 ASI16;
run;

*Remove out of range/extreme values;
data reflux_test_merged_fcs_ASI_mean;
set reflux_test_merged_fcs_ASI_mean;

array q  ASI1 ASI2 ASI3 ASI4 ASI5 ASI6 ASI7 ASI8 ASI9 ASI10 ASI11 ASI12 ASI13 ASI14 ASI15 ASI16;
do i=1 to dim(q);
   if Q[i] < 0 then Q[i] = 0;
   if Q[i] > 4 then Q[i] = 4;
   end;
   drop i;
run;

*recheck distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_ASI_mean;
var ASI1 ASI2 ASI3 ASI4 ASI5 ASI6 ASI7 ASI8 ASI9 ASI10 ASI11 ASI12 ASI13 ASI14 ASI15 ASI16;
histogram ASI1 ASI2 ASI3 ASI4 ASI5 ASI6 ASI7 ASI8 ASI9 ASI10 ASI11 ASI12 ASI13 ASI14 ASI15 ASI16;
run;

*Create new total scale score;
data reflux_test_merged_fcs_ASI_mean;
set reflux_test_merged_fcs_ASI_mean;
ASItot = ASI1 + ASI2 + ASI3 + ASI4 + ASI5 + ASI6 + ASI7 + ASI8 + ASI9 + ASI10 + ASI11 + ASI12 + ASI13 + ASI14 + ASI15 + ASI16; 
run;

*Add suffix "_IMP_IT" to all variables except subject ID (per https://support.sas.com/kb/48/674.html);
proc sql noprint;
   select cats(name,'=',name,'_imp_IT')
          into :list
          separated by ' '
          from dictionary.columns
          where libname = 'WORK' and memname = 'REFLUX_TEST_MERGED_FCS_ASI_MEAN'
          and upcase(name) like 'ASI%';
quit;

*Rename using the macro variable you have created;
proc datasets library = work nolist;
   modify reflux_test_merged_fcs_ASI_mean;
   rename &list;
quit;

*match label to new variable name (e.g., change label to reflect '_imp_IT' variable name);
proc datasets lib=work;
  modify reflux_test_merged_fcs_ASI_mean;
  attrib _all_ label=' ';
run;

*save dataset; 
*libname reflux "C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\data\SAS Files\Individual_Variable_Datasets";
data refl_ind.reflux_test_ASI;
  set work.reflux_test_merged_fcs_ASI_mean;
run;


*------------------------------------------------------------------------------------

*--------------
     VSI
---------------

*----------------------
PREPARING TO CONDUCT MI
-----------------------;

*Examine Missing Data Patterns among your variables of interest;
proc mi data=refl_ind.reflux_test_merged nimpute=0;
var VSI1 VSI2 VSI3 VSI4 VSI5 VSI6 VSI7 VSI8 VSI9 VSI10 VSI11 VSI12 VSI13 VSI14 VSI15;
ods select misspattern;
run;

*----------------------------------------
MI USING MULTIVARIATE NORMAL DISTRIBUTION
-----------------------------------------
NOTE: we choose this option because we only have continuous variables to impute

1. Imputation Phase;
proc mi data=refl_ind.reflux_test_merged nimpute=50 out=reflux_test_merged_fcs_VSI seed=54321 ;*simple minimum=(0) maximum=(7);
class gender_imp marital_status_imp education_imp occupation_imp;
var VSI1 VSI2 VSI3 VSI4 VSI5 VSI6 VSI7 VSI8 VSI9 VSI10 VSI11 VSI12 VSI13 VSI14 VSI15
wellbeing_imp RQ_zuur_imp RQ_bovenbuik_imp RQ_onderbuik_imp RQ_misselijkheid_imp RQ_slaapstoornissen_imp RQ_andere_imp CNAQtot_imp
MAAGtotaal_imp PHQ15som_imp PHQ9dep_imp LSAStot_imp PTSDtotaal_imp STAIStot_imp STAITtot_imp ASItot_imp PASStot_imp 
PCCLcat_imp PCCLpco_imp PCCLint_imp PCCLext_imp IAStot_imp BAQtot_imp NEO_N_imp NEO_E_imp NEO_O_imp NEO_A_imp NEO_c_imp CIStot_imp CTQtot_imp 
age_imp gender_imp marital_status_imp education_imp occupation_imp weight_imp length_imp BMI_imp total_gastric_acid_exp_imp total_eso_acid_exp_imp tot_vol_exp_imp total_nr_acid_imp;
fcs discrim(gender_imp marital_status_imp education_imp occupation_imp /classeffects=include) nbiter =100; 
run;

*2. Analysis Phase;
proc means data=reflux_test_merged_fcs_VSI nway mean;
var VSI1 VSI2 VSI3 VSI4 VSI5 VSI6 VSI7 VSI8 VSI9 VSI10 VSI11 VSI12 VSI13 VSI14 VSI15;
class subject;
output out = reflux_test_merged_fcs_VSI_mean (drop = _TYPE_ _FREQ_);
run;

data reflux_test_merged_fcs_VSI_mean;
set reflux_test_merged_fcs_VSI_mean;
if _STAT_ NE 'MEAN' then delete;
drop _STAT_;
run;

*check distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_VSI_mean;
var VSI1 VSI2 VSI3 VSI4 VSI5 VSI6 VSI7 VSI8 VSI9 VSI10 VSI11 VSI12 VSI13 VSI14 VSI15;
histogram VSI1 VSI2 VSI3 VSI4 VSI5 VSI6 VSI7 VSI8 VSI9 VSI10 VSI11 VSI12 VSI13 VSI14 VSI15;
run;

*Remove out of range/extreme values;
data reflux_test_merged_fcs_VSI_mean;
set reflux_test_merged_fcs_VSI_mean;

array q VSI1 VSI2 VSI3 VSI4 VSI5 VSI6 VSI7 VSI8 VSI9 VSI10 VSI11 VSI12 VSI13 VSI14 VSI15;
do i=1 to dim(q);
   if Q[i] < 1 then Q[i] = 1;
   if Q[i] > 6 then Q[i] = 6;
   end;
   drop i;
run;

*recheck distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_VSI_mean;
var VSI1 VSI2 VSI3 VSI4 VSI5 VSI6 VSI7 VSI8 VSI9 VSI10 VSI11 VSI12 VSI13 VSI14 VSI15;
histogram VSI1 VSI2 VSI3 VSI4 VSI5 VSI6 VSI7 VSI8 VSI9 VSI10 VSI11 VSI12 VSI13 VSI14 VSI15;
run;

*Create new total scale score;
data reflux_test_merged_fcs_VSI_mean;
set reflux_test_merged_fcs_VSI_mean;
VSItot = 90 - (VSI1 + VSI2 + VSI3 + VSI4 + VSI5 + VSI6 + VSI7 + VSI8 + VSI9 + VSI10 + VSI11 + VSI12 + VSI13 + VSI14 + VSI15); 
run;

*Add suffix "_IMP_IT" to all variables except subject ID (per https://support.sas.com/kb/48/674.html);
proc sql noprint;
   select cats(name,'=',name,'_imp_IT')
          into :list
          separated by ' '
          from dictionary.columns
          where libname = 'WORK' and memname = 'REFLUX_TEST_MERGED_FCS_VSI_MEAN'
          and upcase(name) like 'VSI%';
quit;

*Rename using the macro variable you have created;
proc datasets library = work nolist;
   modify reflux_test_merged_fcs_VSI_mean;
   rename &list;
quit;

*match label to new variable name (e.g., change label to reflect '_imp_IT' variable name);
proc datasets lib=work;
  modify reflux_test_merged_fcs_VSI_mean;
  attrib _all_ label=' ';
run;

*save dataset; 
*libname reflux "C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\data\SAS Files\Individual_Variable_Datasets";
data refl_ind.reflux_test_VSI;
  set work.reflux_test_merged_fcs_VSI_mean;
run;

*------------------------------------------------------------------------------------

*--------------
     PASS
---------------

*----------------------
PREPARING TO CONDUCT MI
-----------------------;

*Examine Missing Data Patterns among your variables of interest;
proc mi data=refl_ind.reflux_test_merged nimpute=0;
var PASS1 PASS2 PASS3 PASS4 PASS5 PASS6 PASS7 PASS8 PASS9 PASS10 PASS11 PASS12 PASS13 PASS14 PASS15 PASS16 PASS17 PASS18 PASS19 PASS20 PASS21 PASS22 PASS23 PASS24 PASS25 PASS26 PASS27 PASS28 PASS29 PASS30 PASS31 PASS32 PASS33 PASS34 PASS35 PASS36 PASS37 PASS38 PASS39 PASS40;
ods select misspattern;
run;

*----------------------------------------
MI USING MULTIVARIATE NORMAL DISTRIBUTION
-----------------------------------------

1. Imputation Phase;
proc mi data=refl_ind.reflux_test_merged nimpute=50 out=work.reflux_test_merged_fcs_PASS seed=54321 simple minimum=(-.5) maximum=(5.5);
class gender_imp marital_status_imp education_imp occupation_imp;
var PASS1 PASS2 PASS3 PASS4 PASS5 PASS6 PASS7 PASS8 PASS9 PASS10 PASS11 PASS12 PASS13 PASS14 PASS15 PASS16 PASS17 PASS18 PASS19 PASS20 PASS21 PASS22 PASS23 PASS24 PASS25 PASS26 PASS27 PASS28 PASS29 PASS30 PASS31 PASS32 PASS33 PASS34 PASS35 PASS36 PASS37 PASS38 PASS39 PASS40
wellbeing_imp RQ_zuur_imp RQ_bovenbuik_imp RQ_onderbuik_imp RQ_misselijkheid_imp RQ_slaapstoornissen_imp RQ_andere_imp CNAQtot_imp
MAAGtotaal_imp PHQ15som_imp PHQ9dep_imp LSAStot_imp PTSDtotaal_imp STAIStot_imp STAITtot_imp ASItot_imp VSItot_imp  
PCCLcat_imp PCCLpco_imp PCCLint_imp PCCLext_imp IAStot_imp BAQtot_imp NEO_N_imp NEO_E_imp NEO_O_imp NEO_A_imp NEO_c_imp CIStot_imp CTQtot_imp 
age_imp gender_imp marital_status_imp education_imp occupation_imp weight_imp length_imp BMI_imp total_gastric_acid_exp_imp total_eso_acid_exp_imp tot_vol_exp_imp total_nr_acid_imp;
fcs discrim(gender_imp marital_status_imp education_imp occupation_imp /classeffects=include) nbiter =100; 
run;

*2. Analysis Phase;
proc means data=reflux_test_merged_fcs_PASS nway mean;
var PASS1 PASS2 PASS3 PASS4 PASS5 PASS6 PASS7 PASS8 PASS9 PASS10 PASS11 PASS12 PASS13 PASS14 PASS15 PASS16 PASS17 PASS18 PASS19 PASS20 PASS21 PASS22 PASS23 PASS24 PASS25 PASS26 PASS27 PASS28 PASS29 PASS30 PASS31 PASS32 PASS33 PASS34 PASS35 PASS36 PASS37 PASS38 PASS39 PASS40;
class subject;
output out = reflux_test_merged_fcs_PASS_mean (drop = _TYPE_ _FREQ_);
run;

data reflux_test_merged_fcs_PASS_mean;
set reflux_test_merged_fcs_PASS_mean;
if _STAT_ NE 'MEAN' then delete;
drop _STAT_;
run;

*check distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_PASS_mean;
var PASS1 PASS2 PASS3 PASS4 PASS5 PASS6 PASS7 PASS8 PASS9 PASS10 PASS11 PASS12 PASS13 PASS14 PASS15 PASS16 PASS17 PASS18 PASS19 PASS20 PASS21 PASS22 PASS23 PASS24 PASS25 PASS26 PASS27 PASS28 PASS29 PASS30 PASS31 PASS32 PASS33 PASS34 PASS35 PASS36 PASS37 PASS38 PASS39 PASS40;
histogram PASS1 PASS2 PASS3 PASS4 PASS5 PASS6 PASS7 PASS8 PASS9 PASS10 PASS11 PASS12 PASS13 PASS14 PASS15 PASS16 PASS17 PASS18 PASS19 PASS20 PASS21 PASS22 PASS23 PASS24 PASS25 PASS26 PASS27 PASS28 PASS29 PASS30 PASS31 PASS32 PASS33 PASS34 PASS35 PASS36 PASS37 PASS38 PASS39 PASS40;
run;

*Remove out of range/extreme values;
data reflux_test_merged_fcs_PASS_mean;
set reflux_test_merged_fcs_PASS_mean;

array q  PASS1 PASS2 PASS3 PASS4 PASS5 PASS6 PASS7 PASS8 PASS9 PASS10 PASS11 PASS12 PASS13 PASS14 PASS15 PASS16 PASS17 PASS18 PASS19 PASS20 PASS21 PASS22 PASS23 PASS24 PASS25 PASS26 PASS27 PASS28 PASS29 PASS30 PASS31 PASS32 PASS33 PASS34 PASS35 PASS36 PASS37 PASS38 PASS39 PASS40;
do i=1 to dim(q);
   if Q[i] < 0 then Q[i] = 0;
   if Q[i] > 5 then Q[i] = 5;
   end;
   drop i;
run;

*recheck distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_PASS_mean;
var PASS1 PASS2 PASS3 PASS4 PASS5 PASS6 PASS7 PASS8 PASS9 PASS10 PASS11 PASS12 PASS13 PASS14 PASS15 PASS16 PASS17 PASS18 PASS19 PASS20 PASS21 PASS22 PASS23 PASS24 PASS25 PASS26 PASS27 PASS28 PASS29 PASS30 PASS31 PASS32 PASS33 PASS34 PASS35 PASS36 PASS37 PASS38 PASS39 PASS40;
histogram PASS1 PASS2 PASS3 PASS4 PASS5 PASS6 PASS7 PASS8 PASS9 PASS10 PASS11 PASS12 PASS13 PASS14 PASS15 PASS16 PASS17 PASS18 PASS19 PASS20 PASS21 PASS22 PASS23 PASS24 PASS25 PASS26 PASS27 PASS28 PASS29 PASS30 PASS31 PASS32 PASS33 PASS34 PASS35 PASS36 PASS37 PASS38 PASS39 PASS40;
run;

*Create new total scale score;
data reflux_test_merged_fcs_PASS_mean;
set reflux_test_merged_fcs_PASS_mean;
PASStot = PASS1 + (5 - PASS2) + PASS3 + PASS4 + PASS5 + PASS6 + PASS7 + (5 - PASS8) + PASS9 + PASS10 + PASS11 + PASS12 + PASS13 + PASS14 + PASS15 + (5 - PASS16) + PASS17 + PASS18 + PASS19 + PASS20 + PASS21 + PASS22 + PASS23 + PASS24 + PASS25 + PASS26 + PASS27 + PASS28 + PASS29 + PASS30 + (5 - PASS31) + PASS32 + PASS33 + PASS34 + PASS35 + PASS36 + PASS37 + PASS38 + PASS39 + (5 - PASS40); 
run;

*Add suffix "_IMP_IT" to all variables except subject ID (per https://support.sas.com/kb/48/674.html);
proc sql noprint;
   select cats(name,'=',name,'_imp_IT')
          into :list
          separated by ' '
          from dictionary.columns
          where libname = 'WORK' and memname = 'REFLUX_TEST_MERGED_FCS_PASS_MEAN'
          and upcase(name) like 'PASS%';
quit;

*Rename using the macro variable you have created;
proc datasets library = work nolist;
   modify reflux_test_merged_fcs_PASS_mean;
   rename &list;
quit;

*match label to new variable name (e.g., change label to reflect '_imp_IT' variable name);
proc datasets lib=work;
  modify reflux_test_merged_fcs_PASS_mean;
  attrib _all_ label=' ';
run;

*save dataset; 
*libname reflux "C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\data\SAS Files\Individual_Variable_Datasets";
data refl_ind.reflux_test_PASS;
  set work.reflux_test_merged_fcs_PASS_mean;
run;

*------------------------------------------------------------------------------------

*--------------
     PCCL
---------------

*----------------------
PREPARING TO CONDUCT MI
-----------------------;

*Examine Missing Data Patterns among your variables of interest;
proc mi data=refl_ind.reflux_test_merged nimpute=0;
var PCCL1 PCCL2 PCCL3 PCCL4 PCCL5 PCCL6 PCCL7 PCCL8 PCCL9 PCCL10 PCCL11 PCCL12 PCCL13 PCCL14 PCCL15 PCCL16 PCCL17 PCCL18 PCCL19 PCCL20 PCCL21 PCCL22 PCCL23 PCCL24 PCCL25 PCCL26 PCCL27 PCCL28 PCCL29 PCCL30 PCCL31 PCCL32 PCCL33 PCCL34 PCCL35 PCCL36 PCCL37 PCCL38 PCCL39 PCCL40 PCCL41 PCCL42;
ods select misspattern;
run;

*----------------------------------------
MI USING MULTIVARIATE NORMAL DISTRIBUTION
-----------------------------------------

1. Imputation Phase;
proc mi data=refl_ind.reflux_test_merged nimpute=50 out=reflux_test_merged_fcs_PCCL seed=54321 ;*simple minimum=(.5) maximum=(6.5);
class gender_imp marital_status_imp education_imp occupation_imp;
var PCCL1 PCCL2 PCCL3 PCCL4 PCCL5 PCCL6 PCCL7 PCCL8 PCCL9 PCCL10 PCCL11 PCCL12 PCCL13 PCCL14 PCCL15 PCCL16 PCCL17 PCCL18 PCCL19 PCCL20 PCCL21 PCCL22 PCCL23 PCCL24 PCCL25 PCCL26 PCCL27 PCCL28 PCCL29 PCCL30 PCCL31 PCCL32 PCCL33 PCCL34 PCCL35 PCCL36 PCCL37 PCCL38 PCCL39 PCCL40 PCCL41 PCCL42
wellbeing_imp RQ_zuur_imp RQ_bovenbuik_imp RQ_onderbuik_imp RQ_misselijkheid_imp RQ_slaapstoornissen_imp RQ_andere_imp CNAQtot_imp
MAAGtotaal_imp PHQ15som_imp PHQ9dep_imp LSAStot_imp PTSDtotaal_imp STAIStot_imp STAITtot_imp ASItot_imp VSItot_imp PASStot_imp 
IAStot_imp BAQtot_imp NEO_N_imp NEO_E_imp NEO_O_imp NEO_A_imp NEO_c_imp CIStot_imp CTQtot_imp 
age_imp gender_imp marital_status_imp education_imp occupation_imp weight_imp length_imp BMI_imp total_gastric_acid_exp_imp total_eso_acid_exp_imp tot_vol_exp_imp total_nr_acid_imp;
fcs discrim(gender_imp marital_status_imp education_imp occupation_imp /classeffects=include) nbiter =100; 
run;

*2. Analysis Phase;
proc means data=reflux_test_merged_fcs_PCCL nway mean;
var PCCL1 PCCL2 PCCL3 PCCL4 PCCL5 PCCL6 PCCL7 PCCL8 PCCL9 PCCL10 PCCL11 PCCL12 PCCL13 PCCL14 PCCL15 PCCL16 PCCL17 PCCL18 PCCL19 PCCL20 PCCL21 PCCL22 PCCL23 PCCL24 PCCL25 PCCL26 PCCL27 PCCL28 PCCL29 PCCL30 PCCL31 PCCL32 PCCL33 PCCL34 PCCL35 PCCL36 PCCL37 PCCL38 PCCL39 PCCL40 PCCL41 PCCL42;
class subject;
output out = reflux_test_merged_fcs_PCCL_mean (drop = _TYPE_ _FREQ_);
run;

data reflux_test_merged_fcs_PCCL_mean;
set reflux_test_merged_fcs_PCCL_mean;
if _STAT_ NE 'MEAN' then delete;
drop _STAT_;
run;

*check distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_PCCL_mean;
var PCCL1 PCCL2 PCCL3 PCCL4 PCCL5 PCCL6 PCCL7 PCCL8 PCCL9 PCCL10 PCCL11 PCCL12 PCCL13 PCCL14 PCCL15 PCCL16 PCCL17 PCCL18 PCCL19 PCCL20 PCCL21 PCCL22 PCCL23 PCCL24 PCCL25 PCCL26 PCCL27 PCCL28 PCCL29 PCCL30 PCCL31 PCCL32 PCCL33 PCCL34 PCCL35 PCCL36 PCCL37 PCCL38 PCCL39 PCCL40 PCCL41 PCCL42;
histogram PCCL1 PCCL2 PCCL3 PCCL4 PCCL5 PCCL6 PCCL7 PCCL8 PCCL9 PCCL10 PCCL11 PCCL12 PCCL13 PCCL14 PCCL15 PCCL16 PCCL17 PCCL18 PCCL19 PCCL20 PCCL21 PCCL22 PCCL23 PCCL24 PCCL25 PCCL26 PCCL27 PCCL28 PCCL29 PCCL30 PCCL31 PCCL32 PCCL33 PCCL34 PCCL35 PCCL36 PCCL37 PCCL38 PCCL39 PCCL40 PCCL41 PCCL42;
run;

*Remove out of range/extreme values;
data reflux_test_merged_fcs_PCCL_mean;
set reflux_test_merged_fcs_PCCL_mean;

array q  PCCL1 PCCL2 PCCL3 PCCL4 PCCL5 PCCL6 PCCL7 PCCL8 PCCL9 PCCL10 PCCL11 PCCL12 PCCL13 PCCL14 PCCL15 PCCL16 PCCL17 PCCL18 PCCL19 PCCL20 PCCL21 PCCL22 PCCL23 PCCL24 PCCL25 PCCL26 PCCL27 PCCL28 PCCL29 PCCL30 PCCL31 PCCL32 PCCL33 PCCL34 PCCL35 PCCL36 PCCL37 PCCL38 PCCL39 PCCL40 PCCL41 PCCL42;
do i=1 to dim(q);
   if Q[i] < 1 then Q[i] = 1;
   if Q[i] > 6 then Q[i] = 6;
   end;
   drop i;
run;

*recheck distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_PCCL_mean;
var PCCL1 PCCL2 PCCL3 PCCL4 PCCL5 PCCL6 PCCL7 PCCL8 PCCL9 PCCL10 PCCL11 PCCL12 PCCL13 PCCL14 PCCL15 PCCL16 PCCL17 PCCL18 PCCL19 PCCL20 PCCL21 PCCL22 PCCL23 PCCL24 PCCL25 PCCL26 PCCL27 PCCL28 PCCL29 PCCL30 PCCL31 PCCL32 PCCL33 PCCL34 PCCL35 PCCL36 PCCL37 PCCL38 PCCL39 PCCL40 PCCL41 PCCL42;
histogram PCCL1 PCCL2 PCCL3 PCCL4 PCCL5 PCCL6 PCCL7 PCCL8 PCCL9 PCCL10 PCCL11 PCCL12 PCCL13 PCCL14 PCCL15 PCCL16 PCCL17 PCCL18 PCCL19 PCCL20 PCCL21 PCCL22 PCCL23 PCCL24 PCCL25 PCCL26 PCCL27 PCCL28 PCCL29 PCCL30 PCCL31 PCCL32 PCCL33 PCCL34 PCCL35 PCCL36 PCCL37 PCCL38 PCCL39 PCCL40 PCCL41 PCCL42;
run;

*Create new total scale score;
data reflux_test_merged_fcs_PCCL_mean;
set reflux_test_merged_fcs_PCCL_mean;
PCCLcat = (PCCL18 + PCCL19 + PCCL20 + PCCL22 + PCCL24 + PCCL28 + PCCL29 + PCCL32 + PCCL40 + (7 - PCCL10) + (7 - PCCL13) + (7 - PCCL39))/12;
PCCLpco = (PCCL2 + PCCL6 + PCCL9 + PCCL11 + PCCL17 + PCCL23 + PCCL27 + PCCL30 + PCCL37 + PCCL41 + PCCL42)/11;
PCCLint = (PCCL1 + PCCL4 + PCCL7 + (7 - PCCL8) + PCCL14 + PCCL16 + PCCL25 + PCCL31 + PCCL33 + PCCL34 + PCCL38)/11;
PCCLext = (PCCL3 + PCCL5 + PCCL12 + PCCL15 + PCCL21 + PCCL26 + PCCL35 + PCCL36)/8;
run;

*Add suffix "_IMP_IT" to all variables except subject ID (per https://support.sas.com/kb/48/674.html);
proc sql noprint;
   select cats(name,'=',name,'_imp_IT')
          into :list
          separated by ' '
          from dictionary.columns
          where libname = 'WORK' and memname = 'REFLUX_TEST_MERGED_FCS_PCCL_MEAN'
          and upcase(name) like 'PCCL%';
quit;

*Rename using the macro variable you have created;
proc datasets library = work nolist;
   modify reflux_test_merged_fcs_PCCL_mean;
   rename &list;
quit;

*match label to new variable name (e.g., change label to reflect '_imp_IT' variable name);
proc datasets lib=work;
  modify reflux_test_merged_fcs_PCCL_mean;
  attrib _all_ label=' ';
run;

*save dataset; 
*libname reflux "C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\data\SAS Files\Individual_Variable_Datasets";
data refl_ind.reflux_test_PCCL;
  set work.reflux_test_merged_fcs_PCCL_mean;
run;


*------------------------------------------------------------------------------------

*--------------
     IAS
---------------

*----------------------
PREPARING TO CONDUCT MI
-----------------------;

*Change character variable "IAS18" to numeric;
data refl_ind.reflux_test_merged;
set refl_ind.reflux_test_merged;
   IAS18_char = input(IAS18, 8.);
   drop IAS18;
   rename IAS18_char=IAS18;
run;

*Change character variable "IAS23" to numeric;
data refl_ind.reflux_test_merged;
set refl_ind.reflux_test_merged;
   IAS23_char = input(IAS23, 8.);
   drop IAS23;
   rename IAS23_char=IAS23;
run;

*Change character variable "IAS25" to numeric;
data refl_ind.reflux_test_merged;
set refl_ind.reflux_test_merged;
   IAS25_char = input(IAS25, 8.);
   drop IAS25;
   rename IAS25_char=IAS25;
run;

*Examine Missing Data Patterns among your variables of interest;
proc mi data=refl_ind.reflux_test_merged nimpute=0;
var IAS1 IAS2 IAS3 IAS4 IAS5 IAS6 IAS7 IAS8 IAS9 IAS10 IAS11 IAS12 IAS13 IAS14 IAS15 IAS16 IAS17 IAS18 IAS19 IAS20 IAS21 IAS22 IAS23 IAS24 IAS25 IAS27 IAS28 IAS29;
ods select misspattern;
run;

*----------------------------------------
MI USING MULTIVARIATE NORMAL DISTRIBUTION
-----------------------------------------

1. Imputation Phase;
proc mi data=refl_ind.reflux_test_merged nimpute=50 out=reflux_test_merged_fcs_IAS seed=54321 ;*simple minimum=(-.5) maximum=(4.5);
class gender_imp marital_status_imp education_imp occupation_imp;
var  IAS1 IAS2 IAS3 IAS4 IAS5 IAS6 IAS7 IAS8 IAS9 IAS10 IAS11 IAS12 IAS13 IAS14 IAS15 IAS16 IAS17 IAS18 IAS19 IAS20 IAS21 IAS22 IAS23 IAS24 IAS25 IAS27 IAS28 IAS29
wellbeing_imp RQ_zuur_imp RQ_bovenbuik_imp RQ_onderbuik_imp RQ_misselijkheid_imp RQ_slaapstoornissen_imp RQ_andere_imp CNAQtot_imp
MAAGtotaal_imp PHQ15som_imp PHQ9dep_imp LSAStot_imp PTSDtotaal_imp STAIStot_imp STAITtot_imp ASItot_imp VSItot_imp PASStot_imp 
PCCLcat_imp PCCLpco_imp PCCLint_imp PCCLext_imp BAQtot_imp NEO_N_imp NEO_E_imp NEO_O_imp NEO_A_imp NEO_c_imp CIStot_imp CTQtot_imp 
age_imp gender_imp marital_status_imp education_imp occupation_imp weight_imp length_imp BMI_imp total_gastric_acid_exp_imp total_eso_acid_exp_imp tot_vol_exp_imp total_nr_acid_imp;
fcs discrim(gender_imp marital_status_imp education_imp occupation_imp /classeffects=include) nbiter =100; 
run;

*2. Analysis Phase;
proc means data=reflux_test_merged_fcs_IAS nway mean;
var IAS1 IAS2 IAS3 IAS4 IAS5 IAS6 IAS7 IAS8 IAS9 IAS10 IAS11 IAS12 IAS13 IAS14 IAS15 IAS16 IAS17 IAS18 IAS19 IAS20 IAS21 IAS22 IAS23 IAS24 IAS25 IAS27 IAS28 IAS29;
class subject;
output out = reflux_test_merged_fcs_IAS_mean (drop = _TYPE_ _FREQ_);
run;

data reflux_test_merged_fcs_IAS_mean;
set reflux_test_merged_fcs_IAS_mean;
if _STAT_ NE 'MEAN' then delete;
drop _STAT_;
run;

*check distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_IAS_mean;
var IAS1 IAS2 IAS3 IAS4 IAS5 IAS6 IAS7 IAS8 IAS9 IAS10 IAS11 IAS12 IAS13 IAS14 IAS15 IAS16 IAS17 IAS18 IAS19 IAS20 IAS21 IAS22 IAS23 IAS24 IAS25 IAS27 IAS28 IAS29;
histogram IAS1 IAS2 IAS3 IAS4 IAS5 IAS6 IAS7 IAS8 IAS9 IAS10 IAS11 IAS12 IAS13 IAS14 IAS15 IAS16 IAS17 IAS18 IAS19 IAS20 IAS21 IAS22 IAS23 IAS24 IAS25 IAS27 IAS28 IAS29;
run;

*Remove out of range/extreme values;
data reflux_test_merged_fcs_IAS_mean;
set reflux_test_merged_fcs_IAS_mean;

array q  IAS1 IAS2 IAS3 IAS4 IAS5 IAS6 IAS7 IAS8 IAS9 IAS10 IAS11 IAS12 IAS13 IAS14 IAS15 IAS16 IAS17 IAS18 IAS19 IAS20 IAS21 IAS22 IAS23 IAS24 IAS25 IAS27 IAS28 IAS29;
do i=1 to dim(q);
   if Q[i] < 0 then Q[i] = 0;
   if Q[i] > 4 then Q[i] = 4;
   end;
   drop i;
run;

*recheck distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_IAS_mean;
var IAS1 IAS2 IAS3 IAS4 IAS5 IAS6 IAS7 IAS8 IAS9 IAS10 IAS11 IAS12 IAS13 IAS14 IAS15 IAS16 IAS17 IAS18 IAS19 IAS20 IAS21 IAS22 IAS23 IAS24 IAS25 IAS27 IAS28 IAS29;
histogram IAS1 IAS2 IAS3 IAS4 IAS5 IAS6 IAS7 IAS8 IAS9 IAS10 IAS11 IAS12 IAS13 IAS14 IAS15 IAS16 IAS17 IAS18 IAS19 IAS20 IAS21 IAS22 IAS23 IAS24 IAS25 IAS27 IAS28 IAS29;
run;

*Create new total scale score;
data reflux_test_merged_fcs_IAS_mean;
set reflux_test_merged_fcs_IAS_mean;
IAStot = IAS1 + IAS2 + IAS3 + IAS4 + IAS5 + IAS6 + IAS7 + IAS8 + IAS9 + IAS10 + IAS11 + IAS12 + IAS13 + IAS14 + IAS15 + IAS16 + IAS17 + IAS18 + IAS19 + IAS20 + IAS21 + IAS22 + IAS23 + IAS24 + IAS25 + IAS27 + IAS28 + IAS29; 
run;

*Add suffix "_IMP_IT" to all variables except subject ID (per https://support.sas.com/kb/48/674.html);
proc sql noprint;
   select cats(name,'=',name,'_imp_IT')
          into :list
          separated by ' '
          from dictionary.columns
          where libname = 'WORK' and memname = 'REFLUX_TEST_MERGED_FCS_IAS_MEAN'
          and upcase(name) like 'IAS%';
quit;

*Rename using the macro variable you have created;
proc datasets library = work nolist;
   modify reflux_test_merged_fcs_IAS_mean;
   rename &list;
quit;

*match label to new variable name (e.g., change label to reflect '_imp_IT' variable name);
proc datasets lib=work;
  modify reflux_test_merged_fcs_IAS_mean;
  attrib _all_ label=' ';
run;

*save dataset; 
*libname reflux "C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\data\SAS Files\Individual_Variable_Datasets";
data refl_ind.reflux_test_IAS;
  set work.reflux_test_merged_fcs_IAS_mean;
run;



*------------------------------------------------------------------------------------

*--------------
     BAQ
---------------

*----------------------
PREPARING TO CONDUCT MI
-----------------------;

*Examine Missing Data Patterns among your variables of interest;
proc mi data=refl_ind.reflux_test_merged nimpute=0;
var BAQ1 BAQ2 BAQ3 BAQ4 BAQ5 BAQ6 BAQ7 BAQ8 BAQ9 BAQ10 BAQ11 BAQ12 BAQ13 BAQ14 BAQ15 BAQ16 BAQ17 BAQ18;
ods select misspattern;
run;

*----------------------------------------
MI USING MULTIVARIATE NORMAL DISTRIBUTION
-----------------------------------------

1. Imputation Phase;
proc mi data=refl_ind.reflux_test_merged nimpute=50 out=reflux_test_merged_fcs_BAQ seed=54321 ;*simple minimum=(-.5) maximum=(4.5);
class gender_imp marital_status_imp education_imp occupation_imp;
var  BAQ1 BAQ2 BAQ3 BAQ4 BAQ5 BAQ6 BAQ7 BAQ8 BAQ9 BAQ10 BAQ11 BAQ12 BAQ13 BAQ14 BAQ15 BAQ16 BAQ17 BAQ18
wellbeing_imp RQ_zuur_imp RQ_bovenbuik_imp RQ_onderbuik_imp RQ_misselijkheid_imp RQ_slaapstoornissen_imp RQ_andere_imp CNAQtot_imp
MAAGtotaal_imp PHQ15som_imp PHQ9dep_imp LSAStot_imp PTSDtotaal_imp STAIStot_imp STAITtot_imp ASItot_imp VSItot_imp PASStot_imp 
PCCLcat_imp PCCLpco_imp PCCLint_imp PCCLext_imp IAStot_imp NEO_N_imp NEO_E_imp NEO_O_imp NEO_A_imp NEO_c_imp CIStot_imp CTQtot_imp 
age_imp gender_imp marital_status_imp education_imp occupation_imp weight_imp length_imp BMI_imp total_gastric_acid_exp_imp total_eso_acid_exp_imp tot_vol_exp_imp total_nr_acid_imp;
fcs discrim(gender_imp marital_status_imp education_imp occupation_imp /classeffects=include) nbiter =100; 
run;

*2. Analysis Phase;
proc means data=reflux_test_merged_fcs_BAQ nway mean;
var  BAQ1 BAQ2 BAQ3 BAQ4 BAQ5 BAQ6 BAQ7 BAQ8 BAQ9 BAQ10 BAQ11 BAQ12 BAQ13 BAQ14 BAQ15 BAQ16 BAQ17 BAQ18;
class subject;
output out = reflux_test_merged_fcs_BAQ_mean (drop = _TYPE_ _FREQ_);
run;

data reflux_test_merged_fcs_BAQ_mean;
set reflux_test_merged_fcs_BAQ_mean;
if _STAT_ NE 'MEAN' then delete;
drop _STAT_;
run;

*check distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_BAQ_mean;
var BAQ1 BAQ2 BAQ3 BAQ4 BAQ5 BAQ6 BAQ7 BAQ8 BAQ9 BAQ10 BAQ11 BAQ12 BAQ13 BAQ14 BAQ15 BAQ16 BAQ17 BAQ18;
histogram BAQ1 BAQ2 BAQ3 BAQ4 BAQ5 BAQ6 BAQ7 BAQ8 BAQ9 BAQ10 BAQ11 BAQ12 BAQ13 BAQ14 BAQ15 BAQ16 BAQ17 BAQ18;
run;

*Remove out of range/extreme values;
data reflux_test_merged_fcs_BAQ_mean;
set reflux_test_merged_fcs_BAQ_mean;

array q BAQ1 BAQ2 BAQ3 BAQ4 BAQ5 BAQ6 BAQ7 BAQ8 BAQ9 BAQ10 BAQ11 BAQ12 BAQ13 BAQ14 BAQ15 BAQ16 BAQ17 BAQ18;
do i=1 to dim(q);
   if Q[i] < 1 then Q[i] = 1;
   if Q[i] > 7 then Q[i] = 7;
   end;
   drop i;
run;

*recheck distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_BAQ_mean;
var BAQ1 BAQ2 BAQ3 BAQ4 BAQ5 BAQ6 BAQ7 BAQ8 BAQ9 BAQ10 BAQ11 BAQ12 BAQ13 BAQ14 BAQ15 BAQ16 BAQ17 BAQ18;
histogram BAQ1 BAQ2 BAQ3 BAQ4 BAQ5 BAQ6 BAQ7 BAQ8 BAQ9 BAQ10 BAQ11 BAQ12 BAQ13 BAQ14 BAQ15 BAQ16 BAQ17 BAQ18;
run;

*Create new total scale score;
data reflux_test_merged_fcs_BAQ_mean;
set reflux_test_merged_fcs_BAQ_mean;
BAQtot = BAQ1 + BAQ2 + BAQ3 + BAQ4 + BAQ5 + BAQ6 + BAQ7 + BAQ8 + BAQ9 + (8-BAQ10) + BAQ11 + BAQ12 + BAQ13 + BAQ14 + BAQ15 + BAQ16 + BAQ17 + BAQ18; 
run;

*Add suffix "_IMP_IT" to all variables except subject ID (per https://support.sas.com/kb/48/674.html);
proc sql noprint;
   select cats(name,'=',name,'_imp_IT')
          into :list
          separated by ' '
          from dictionary.columns
          where libname = 'WORK' and memname = 'REFLUX_TEST_MERGED_FCS_BAQ_MEAN'
          and upcase(name) like 'BAQ%';
quit;

*Rename using the macro variable you have created;
proc datasets library = work nolist;
   modify reflux_test_merged_fcs_BAQ_mean;
   rename &list;
quit;

*match label to new variable name (e.g., change label to reflect '_imp_IT' variable name);
proc datasets lib=work;
  modify reflux_test_merged_fcs_BAQ_mean;
  attrib _all_ label=' ';
run;

*save dataset; 
*libname reflux "C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\data\SAS Files\Individual_Variable_Datasets";
data refl_ind.reflux_test_BAQ;
  set work.reflux_test_merged_fcs_BAQ_mean;
run;


*------------------------------------------------------------------------------------

*--------------
     NEO
---------------

*----------------------
PREPARING TO CONDUCT MI
-----------------------;

*Examine Missing Data Patterns among your variables of interest;
proc mi data=refl_ind.reflux_test_merged nimpute=0;
var NEO_FFI1 NEO_FFI2 NEO_FFI3 NEO_FFI4 NEO_FFI5 NEO_FFI6 NEO_FFI7 NEO_FFI8 NEO_FFI9 NEO_FFI10 NEO_FFI11 NEO_FFI12 NEO_FFI13 NEO_FFI14 NEO_FFI15 NEO_FFI16 NEO_FFI17 NEO_FFI18 NEO_FFI19 NEO_FFI20 NEO_FFI21 NEO_FFI22 NEO_FFI23 NEO_FFI24 NEO_FFI25 NEO_FFI26 NEO_FFI27 NEO_FFI28 NEO_FFI29 NEO_FFI30 NEO_FFI31 NEO_FFI32 NEO_FFI33 NEO_FFI34 NEO_FFI35 NEO_FFI36 NEO_FFI37 NEO_FFI38 NEO_FFI39 NEO_FFI40 NEO_FFI41 NEO_FFI42 NEO_FFI43 NEO_FFI44 NEO_FFI45 NEO_FFI46 NEO_FFI47 NEO_FFI48 NEO_FFI49 NEO_FFI50 NEO_FFI51 NEO_FFI52 NEO_FFI53 NEO_FFI54 NEO_FFI55 NEO_FFI56 NEO_FFI57 NEO_FFI58 NEO_FFI59 NEO_FFI60;
ods select misspattern;
run;

*----------------------------------------
MI USING MULTIVARIATE NORMAL DISTRIBUTION
-----------------------------------------

1. Imputation Phase;
proc mi data=refl_ind.reflux_test_merged nimpute=50 out=reflux_test_merged_fcs_NEO seed=54321 ;*simple minimum=(-.5) maximum=(4.5);
class gender_imp marital_status_imp education_imp occupation_imp;
var NEO_FFI1 NEO_FFI2 NEO_FFI3 NEO_FFI4 NEO_FFI5 NEO_FFI6 NEO_FFI7 NEO_FFI8 NEO_FFI9 NEO_FFI10 NEO_FFI11 NEO_FFI12 NEO_FFI13 NEO_FFI14 NEO_FFI15 NEO_FFI16 NEO_FFI17 NEO_FFI18 NEO_FFI19 NEO_FFI20 NEO_FFI21 NEO_FFI22 NEO_FFI23 NEO_FFI24 NEO_FFI25 NEO_FFI26 NEO_FFI27 NEO_FFI28 NEO_FFI29 NEO_FFI30 NEO_FFI31 NEO_FFI32 NEO_FFI33 NEO_FFI34 NEO_FFI35 NEO_FFI36 NEO_FFI37 NEO_FFI38 NEO_FFI39 NEO_FFI40 NEO_FFI41 NEO_FFI42 NEO_FFI43 NEO_FFI44 NEO_FFI45 NEO_FFI46 NEO_FFI47 NEO_FFI48 NEO_FFI49 NEO_FFI50 NEO_FFI51 NEO_FFI52 NEO_FFI53 NEO_FFI54 NEO_FFI55 NEO_FFI56 NEO_FFI57 NEO_FFI58 NEO_FFI59 NEO_FFI60
wellbeing_imp RQ_zuur_imp RQ_bovenbuik_imp RQ_onderbuik_imp RQ_misselijkheid_imp RQ_slaapstoornissen_imp RQ_andere_imp CNAQtot_imp
MAAGtotaal_imp PHQ15som_imp PHQ9dep_imp LSAStot_imp PTSDtotaal_imp STAIStot_imp STAITtot_imp ASItot_imp VSItot_imp PASStot_imp 
PCCLcat_imp PCCLpco_imp PCCLint_imp PCCLext_imp IAStot_imp BAQtot_imp CIStot_imp CTQtot_imp 
age_imp gender_imp marital_status_imp education_imp occupation_imp weight_imp length_imp BMI_imp total_gastric_acid_exp_imp total_eso_acid_exp_imp tot_vol_exp_imp total_nr_acid_imp;
fcs discrim(gender_imp marital_status_imp education_imp occupation_imp /classeffects=include) nbiter =100; 
run;

*2. Analysis Phase;
proc means data=reflux_test_merged_fcs_NEO nway mean;
var  NEO_FFI1 NEO_FFI2 NEO_FFI3 NEO_FFI4 NEO_FFI5 NEO_FFI6 NEO_FFI7 NEO_FFI8 NEO_FFI9 NEO_FFI10 NEO_FFI11 NEO_FFI12 NEO_FFI13 NEO_FFI14 NEO_FFI15 NEO_FFI16 NEO_FFI17 NEO_FFI18 NEO_FFI19 NEO_FFI20 NEO_FFI21 NEO_FFI22 NEO_FFI23 NEO_FFI24 NEO_FFI25 NEO_FFI26 NEO_FFI27 NEO_FFI28 NEO_FFI29 NEO_FFI30 NEO_FFI31 NEO_FFI32 NEO_FFI33 NEO_FFI34 NEO_FFI35 NEO_FFI36 NEO_FFI37 NEO_FFI38 NEO_FFI39 NEO_FFI40 NEO_FFI41 NEO_FFI42 NEO_FFI43 NEO_FFI44 NEO_FFI45 NEO_FFI46 NEO_FFI47 NEO_FFI48 NEO_FFI49 NEO_FFI50 NEO_FFI51 NEO_FFI52 NEO_FFI53 NEO_FFI54 NEO_FFI55 NEO_FFI56 NEO_FFI57 NEO_FFI58 NEO_FFI59 NEO_FFI60;
class subject;
output out = reflux_test_merged_fcs_NEO_mean (drop = _TYPE_ _FREQ_);
run;

data reflux_test_merged_fcs_NEO_mean;
set reflux_test_merged_fcs_NEO_mean;
if _STAT_ NE 'MEAN' then delete;
drop _STAT_;
run;

*check distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_NEO_mean;
var NEO_FFI1 NEO_FFI2 NEO_FFI3 NEO_FFI4 NEO_FFI5 NEO_FFI6 NEO_FFI7 NEO_FFI8 NEO_FFI9 NEO_FFI10 NEO_FFI11 NEO_FFI12 NEO_FFI13 NEO_FFI14 NEO_FFI15 NEO_FFI16 NEO_FFI17 NEO_FFI18 NEO_FFI19 NEO_FFI20 NEO_FFI21 NEO_FFI22 NEO_FFI23 NEO_FFI24 NEO_FFI25 NEO_FFI26 NEO_FFI27 NEO_FFI28 NEO_FFI29 NEO_FFI30 NEO_FFI31 NEO_FFI32 NEO_FFI33 NEO_FFI34 NEO_FFI35 NEO_FFI36 NEO_FFI37 NEO_FFI38 NEO_FFI39 NEO_FFI40 NEO_FFI41 NEO_FFI42 NEO_FFI43 NEO_FFI44 NEO_FFI45 NEO_FFI46 NEO_FFI47 NEO_FFI48 NEO_FFI49 NEO_FFI50 NEO_FFI51 NEO_FFI52 NEO_FFI53 NEO_FFI54 NEO_FFI55 NEO_FFI56 NEO_FFI57 NEO_FFI58 NEO_FFI59 NEO_FFI60;
histogram NEO_FFI1 NEO_FFI2 NEO_FFI3 NEO_FFI4 NEO_FFI5 NEO_FFI6 NEO_FFI7 NEO_FFI8 NEO_FFI9 NEO_FFI10 NEO_FFI11 NEO_FFI12 NEO_FFI13 NEO_FFI14 NEO_FFI15 NEO_FFI16 NEO_FFI17 NEO_FFI18 NEO_FFI19 NEO_FFI20 NEO_FFI21 NEO_FFI22 NEO_FFI23 NEO_FFI24 NEO_FFI25 NEO_FFI26 NEO_FFI27 NEO_FFI28 NEO_FFI29 NEO_FFI30 NEO_FFI31 NEO_FFI32 NEO_FFI33 NEO_FFI34 NEO_FFI35 NEO_FFI36 NEO_FFI37 NEO_FFI38 NEO_FFI39 NEO_FFI40 NEO_FFI41 NEO_FFI42 NEO_FFI43 NEO_FFI44 NEO_FFI45 NEO_FFI46 NEO_FFI47 NEO_FFI48 NEO_FFI49 NEO_FFI50 NEO_FFI51 NEO_FFI52 NEO_FFI53 NEO_FFI54 NEO_FFI55 NEO_FFI56 NEO_FFI57 NEO_FFI58 NEO_FFI59 NEO_FFI60;
run;

*Remove out of range/extreme values;
data reflux_test_merged_fcs_NEO_mean;
set reflux_test_merged_fcs_NEO_mean;

array q NEO_FFI1 NEO_FFI2 NEO_FFI3 NEO_FFI4 NEO_FFI5 NEO_FFI6 NEO_FFI7 NEO_FFI8 NEO_FFI9 NEO_FFI10 NEO_FFI11 NEO_FFI12 NEO_FFI13 NEO_FFI14 NEO_FFI15 NEO_FFI16 NEO_FFI17 NEO_FFI18 NEO_FFI19 NEO_FFI20 NEO_FFI21 NEO_FFI22 NEO_FFI23 NEO_FFI24 NEO_FFI25 NEO_FFI26 NEO_FFI27 NEO_FFI28 NEO_FFI29 NEO_FFI30 NEO_FFI31 NEO_FFI32 NEO_FFI33 NEO_FFI34 NEO_FFI35 NEO_FFI36 NEO_FFI37 NEO_FFI38 NEO_FFI39 NEO_FFI40 NEO_FFI41 NEO_FFI42 NEO_FFI43 NEO_FFI44 NEO_FFI45 NEO_FFI46 NEO_FFI47 NEO_FFI48 NEO_FFI49 NEO_FFI50 NEO_FFI51 NEO_FFI52 NEO_FFI53 NEO_FFI54 NEO_FFI55 NEO_FFI56 NEO_FFI57 NEO_FFI58 NEO_FFI59 NEO_FFI60;
do i=1 to dim(q);
   if Q[i] < 1 then Q[i] = 1;
   if Q[i] > 5 then Q[i] = 5;
   end;
   drop i;
run;

*recheck distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_NEO_mean;
var NEO_FFI1 NEO_FFI2 NEO_FFI3 NEO_FFI4 NEO_FFI5 NEO_FFI6 NEO_FFI7 NEO_FFI8 NEO_FFI9 NEO_FFI10 NEO_FFI11 NEO_FFI12 NEO_FFI13 NEO_FFI14 NEO_FFI15 NEO_FFI16 NEO_FFI17 NEO_FFI18 NEO_FFI19 NEO_FFI20 NEO_FFI21 NEO_FFI22 NEO_FFI23 NEO_FFI24 NEO_FFI25 NEO_FFI26 NEO_FFI27 NEO_FFI28 NEO_FFI29 NEO_FFI30 NEO_FFI31 NEO_FFI32 NEO_FFI33 NEO_FFI34 NEO_FFI35 NEO_FFI36 NEO_FFI37 NEO_FFI38 NEO_FFI39 NEO_FFI40 NEO_FFI41 NEO_FFI42 NEO_FFI43 NEO_FFI44 NEO_FFI45 NEO_FFI46 NEO_FFI47 NEO_FFI48 NEO_FFI49 NEO_FFI50 NEO_FFI51 NEO_FFI52 NEO_FFI53 NEO_FFI54 NEO_FFI55 NEO_FFI56 NEO_FFI57 NEO_FFI58 NEO_FFI59 NEO_FFI60;
histogram NEO_FFI1 NEO_FFI2 NEO_FFI3 NEO_FFI4 NEO_FFI5 NEO_FFI6 NEO_FFI7 NEO_FFI8 NEO_FFI9 NEO_FFI10 NEO_FFI11 NEO_FFI12 NEO_FFI13 NEO_FFI14 NEO_FFI15 NEO_FFI16 NEO_FFI17 NEO_FFI18 NEO_FFI19 NEO_FFI20 NEO_FFI21 NEO_FFI22 NEO_FFI23 NEO_FFI24 NEO_FFI25 NEO_FFI26 NEO_FFI27 NEO_FFI28 NEO_FFI29 NEO_FFI30 NEO_FFI31 NEO_FFI32 NEO_FFI33 NEO_FFI34 NEO_FFI35 NEO_FFI36 NEO_FFI37 NEO_FFI38 NEO_FFI39 NEO_FFI40 NEO_FFI41 NEO_FFI42 NEO_FFI43 NEO_FFI44 NEO_FFI45 NEO_FFI46 NEO_FFI47 NEO_FFI48 NEO_FFI49 NEO_FFI50 NEO_FFI51 NEO_FFI52 NEO_FFI53 NEO_FFI54 NEO_FFI55 NEO_FFI56 NEO_FFI57 NEO_FFI58 NEO_FFI59 NEO_FFI60;
run;

*Create new total scale score;
data reflux_test_merged_fcs_NEO_mean;
set reflux_test_merged_fcs_NEO_mean;
NEO_N = (6 - NEO_FFI1) + NEO_FFI6 + NEO_FFI11 + (6 - NEO_FFI16) + NEO_FFI21 + NEO_FFI26 + (6 - NEO_FFI31) + NEO_FFI36 + NEO_FFI41 + (6 - NEO_FFI46) + NEO_FFI51 + NEO_FFI56;
NEO_E = NEO_FFI2 + NEO_FFI7 + (6 - NEO_FFI12) + NEO_FFI17 + NEO_FFI22 + (6 - NEO_FFI27) + NEO_FFI32 + NEO_FFI37 + (6 - NEO_FFI42) + NEO_FFI47 + NEO_FFI52 + (6 - NEO_FFI57);
NEO_O = (6 - NEO_FFI3) + (6 - NEO_FFI8) + NEO_FFI13 + (6 - NEO_FFI18) + (6 - NEO_FFI23) + NEO_FFI28 + (6 - NEO_FFI33) + (6 - NEO_FFI38) + NEO_FFI43 + (6 - NEO_FFI48) + NEO_FFI53 + NEO_FFI58;
NEO_A = NEO_FFI4 + (6 - NEO_FFI9) + (6 - NEO_FFI14) + NEO_FFI19 + (6 - NEO_FFI24) + (6 - NEO_FFI29) + NEO_FFI34 + (6 - NEO_FFI39) + (6 - NEO_FFI44) + NEO_FFI49 + (6 - NEO_FFI54) + (6 - NEO_FFI59);
NEO_C = NEO_FFI5 + NEO_FFI10 + (6 - NEO_FFI15) + NEO_FFI20 + NEO_FFI25 + (6 - NEO_FFI30) + NEO_FFI35 + NEO_FFI40 + (6 - NEO_FFI45) + NEO_FFI50 + (6 - NEO_FFI55) + NEO_FFI60;
run;

*Add suffix "_IMP_IT" to all variables except subject ID (per https://support.sas.com/kb/48/674.html);
proc sql noprint;
   select cats(name,'=',name,'_imp_IT')
          into :list
          separated by ' '
          from dictionary.columns
          where libname = 'WORK' and memname = 'REFLUX_TEST_MERGED_FCS_NEO_MEAN'
          and upcase(name) like 'NEO%';
quit;

*Rename using the macro variable you have created;
proc datasets library = work nolist;
   modify reflux_test_merged_fcs_NEO_mean;
   rename &list;
quit;

*match label to new variable name (e.g., change label to reflect '_imp_IT' variable name);
proc datasets lib=work;
  modify reflux_test_merged_fcs_NEO_mean;
  attrib _all_ label=' ';
run;

*save dataset; 
*libname reflux "C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\data\SAS Files\Individual_Variable_Datasets";
data refl_ind.reflux_test_NEO;
  set work.reflux_test_merged_fcs_NEO_mean;
run;


*------------------------------------------------------------------------------------

*--------------
     CIS
---------------

*----------------------
PREPARING TO CONDUCT MI
-----------------------;

*Examine Missing Data Patterns among your variables of interest;
proc mi data=refl_ind.reflux_test_merged nimpute=0;
var CIS1 CIS2 CIS3 CIS4 CIS5 CIS6 CIS7 CIS8 CIS9 CIS10 CIS11 CIS12 CIS13 CIS14 CIS15 CIS16 CIS17 CIS18 CIS19 CIS20;
ods select misspattern;
run;

*----------------------------------------
MI USING MULTIVARIATE NORMAL DISTRIBUTION
-----------------------------------------

1. Imputation Phase;
proc mi data=refl_ind.reflux_test_merged nimpute=50 out=reflux_test_merged_fcs_CIS seed=54321 ;*simple minimum=(-.5) maximum=(4.5);
class gender_imp marital_status_imp education_imp occupation_imp;
var  CIS1 CIS2 CIS3 CIS4 CIS5 CIS6 CIS7 CIS8 CIS9 CIS10 CIS11 CIS12 CIS13 CIS14 CIS15 CIS16 CIS17 CIS18 CIS19 CIS20
wellbeing_imp RQ_zuur_imp RQ_bovenbuik_imp RQ_onderbuik_imp RQ_misselijkheid_imp RQ_slaapstoornissen_imp RQ_andere_imp CNAQtot_imp
MAAGtotaal_imp PHQ15som_imp PHQ9dep_imp LSAStot_imp PTSDtotaal_imp STAIStot_imp STAITtot_imp ASItot_imp VSItot_imp PASStot_imp 
PCCLcat_imp PCCLpco_imp PCCLint_imp PCCLext_imp IAStot_imp BAQtot_imp NEO_N_imp NEO_E_imp NEO_O_imp NEO_A_imp NEO_c_imp CTQtot_imp 
age_imp gender_imp marital_status_imp education_imp occupation_imp weight_imp length_imp BMI_imp total_gastric_acid_exp_imp total_eso_acid_exp_imp tot_vol_exp_imp total_nr_acid_imp;
fcs discrim(gender_imp marital_status_imp education_imp occupation_imp /classeffects=include) nbiter =100; 
run;

*2. Analysis Phase;
proc means data=reflux_test_merged_fcs_CIS nway mean;
var  CIS1 CIS2 CIS3 CIS4 CIS5 CIS6 CIS7 CIS8 CIS9 CIS10 CIS11 CIS12 CIS13 CIS14 CIS15 CIS16 CIS17 CIS18 CIS19 CIS20;
class subject;
output out = reflux_test_merged_fcs_CIS_mean (drop = _TYPE_ _FREQ_);
run;

data reflux_test_merged_fcs_CIS_mean;
set reflux_test_merged_fcs_CIS_mean;
if _STAT_ NE 'MEAN' then delete;
drop _STAT_;
run;

*check distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_CIS_mean;
var CIS1 CIS2 CIS3 CIS4 CIS5 CIS6 CIS7 CIS8 CIS9 CIS10 CIS11 CIS12 CIS13 CIS14 CIS15 CIS16 CIS17 CIS18 CIS19 CIS20;
histogram CIS1 CIS2 CIS3 CIS4 CIS5 CIS6 CIS7 CIS8 CIS9 CIS10 CIS11 CIS12 CIS13 CIS14 CIS15 CIS16 CIS17 CIS18 CIS19 CIS20;
run;

*Remove out of range/extreme values;
data reflux_test_merged_fcs_CIS_mean;
set reflux_test_merged_fcs_CIS_mean;

array q CIS1 CIS2 CIS3 CIS4 CIS5 CIS6 CIS7 CIS8 CIS9 CIS10 CIS11 CIS12 CIS13 CIS14 CIS15 CIS16 CIS17 CIS18 CIS19 CIS20;
do i=1 to dim(q);
   if Q[i] < 1 then Q[i] = 1;
   if Q[i] > 7 then Q[i] = 7;
   end;
   drop i;
run;

*recheck distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_CIS_mean;
var CIS1 CIS2 CIS3 CIS4 CIS5 CIS6 CIS7 CIS8 CIS9 CIS10 CIS11 CIS12 CIS13 CIS14 CIS15 CIS16 CIS17 CIS18 CIS19 CIS20;
histogram CIS1 CIS2 CIS3 CIS4 CIS5 CIS6 CIS7 CIS8 CIS9 CIS10 CIS11 CIS12 CIS13 CIS14 CIS15 CIS16 CIS17 CIS18 CIS19 CIS20;
run;

*Create new total scale score;
data reflux_test_merged_fcs_CIS_mean;
set reflux_test_merged_fcs_CIS_mean;
CIStot = CIS1 + CIS2 + (8 - CIS3) + (8 - CIS4) + CIS5 + (8 - CIS6) + CIS7 + CIS8 + (8 - CIS9) + (8 - CIS10) + CIS11 + CIS12 + (8 - CIS13) + (8 - CIS14) + CIS15 + (8 - CIS16) + (8 - CIS17) + (8 - CIS18) + (8 - CIS19) + CIS20; 
run;

*Add suffix "_IMP_IT" to all variables except subject ID (per https://support.sas.com/kb/48/674.html);
proc sql noprint;
   select cats(name,'=',name,'_imp_IT')
          into :list
          separated by ' '
          from dictionary.columns
          where libname = 'WORK' and memname = 'REFLUX_TEST_MERGED_FCS_CIS_MEAN'
          and upcase(name) like 'CIS%';
quit;

*Rename using the macro variable you have created;
proc datasets library = work nolist;
   modify reflux_test_merged_fcs_CIS_mean;
   rename &list;
quit;

*match label to new variable name (e.g., change label to reflect '_imp_IT' variable name);
proc datasets lib=work;
  modify reflux_test_merged_fcs_CIS_mean;
  attrib _all_ label=' ';
run;

*save dataset; 
*libname reflux "C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\data\SAS Files\Individual_Variable_Datasets";
data refl_ind.reflux_test_CIS;
  set work.reflux_test_merged_fcs_CIS_mean;
run;


*------------------------------------------------------------------------------------

*--------------
     CTQ
---------------

*----------------------
PREPARING TO CONDUCT MI
-----------------------;

*Examine Missing Data Patterns among your variables of interest;
proc mi data=refl_ind.reflux_test_merged nimpute=0;
var JTV1 JTV2 JTV3 JTV4 JTV5 JTV6 JTV7 JTV8 JTV9 JTV10 JTV11 JTV12 JTV13 JTV14 JTV15 JTV16 JTV17 JTV18 JTV19 JTV20 JTV21 JTV22 JTV23 JTV24 JTV25;
ods select misspattern;
run;

*----------------------------------------
MI USING MULTIVARIATE NORMAL DISTRIBUTION
-----------------------------------------

1. Imputation Phase;
proc mi data=refl_ind.reflux_test_merged nimpute=50 out=reflux_test_merged_fcs_CTQ seed=54321 ;*simple minimum=(-.5) maximum=(4.5);
class gender_imp marital_status_imp education_imp occupation_imp;
var JTV1 JTV2 JTV3 JTV4 JTV5 JTV6 JTV7 JTV8 JTV9 JTV10 JTV11 JTV12 JTV13 JTV14 JTV15 JTV16 JTV17 JTV18 JTV19 JTV20 JTV21 JTV22 JTV23 JTV24 JTV25
wellbeing_imp RQ_zuur_imp RQ_bovenbuik_imp RQ_onderbuik_imp RQ_misselijkheid_imp RQ_slaapstoornissen_imp RQ_andere_imp CNAQtot_imp
MAAGtotaal_imp PHQ15som_imp PHQ9dep_imp LSAStot_imp PTSDtotaal_imp STAIStot_imp STAITtot_imp ASItot_imp VSItot_imp PASStot_imp 
PCCLcat_imp PCCLpco_imp PCCLint_imp PCCLext_imp IAStot_imp BAQtot_imp NEO_N_imp NEO_E_imp NEO_O_imp NEO_A_imp NEO_c_imp CIStot_imp
age_imp gender_imp marital_status_imp education_imp occupation_imp weight_imp length_imp BMI_imp total_gastric_acid_exp_imp total_eso_acid_exp_imp tot_vol_exp_imp total_nr_acid_imp;
fcs discrim(gender_imp marital_status_imp education_imp occupation_imp /classeffects=include) nbiter =100; 
run;

*2. Analysis Phase;
proc means data=reflux_test_merged_fcs_CTQ nway mean;
var  JTV1 JTV2 JTV3 JTV4 JTV5 JTV6 JTV7 JTV8 JTV9 JTV10 JTV11 JTV12 JTV13 JTV14 JTV15 JTV16 JTV17 JTV18 JTV19 JTV20 JTV21 JTV22 JTV23 JTV24 JTV25;
class subject;
output out = reflux_test_merged_fcs_CTQ_mean (drop = _TYPE_ _FREQ_);
run;

data reflux_test_merged_fcs_CTQ_mean;
set reflux_test_merged_fcs_CTQ_mean;
if _STAT_ NE 'MEAN' then delete;
drop _STAT_;
run;

*check distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_CTQ_mean;
var JTV1 JTV2 JTV3 JTV4 JTV5 JTV6 JTV7 JTV8 JTV9 JTV10 JTV11 JTV12 JTV13 JTV14 JTV15 JTV16 JTV17 JTV18 JTV19 JTV20 JTV21 JTV22 JTV23 JTV24 JTV25;
histogram JTV1 JTV2 JTV3 JTV4 JTV5 JTV6 JTV7 JTV8 JTV9 JTV10 JTV11 JTV12 JTV13 JTV14 JTV15 JTV16 JTV17 JTV18 JTV19 JTV20 JTV21 JTV22 JTV23 JTV24 JTV25;
run;

*Remove out of range/extreme values;
data reflux_test_merged_fcs_CTQ_mean;
set reflux_test_merged_fcs_CTQ_mean;

array q JTV1 JTV2 JTV3 JTV4 JTV5 JTV6 JTV7 JTV8 JTV9 JTV10 JTV11 JTV12 JTV13 JTV14 JTV15 JTV16 JTV17 JTV18 JTV19 JTV20 JTV21 JTV22 JTV23 JTV24 JTV25;
do i=1 to dim(q);
   if Q[i] < 1 then Q[i] = 1;
   if Q[i] > 5 then Q[i] = 5;
   end;
   drop i;
run;

*recheck distributions and extreme/out of possible range values;
proc univariate data=reflux_test_merged_fcs_CTQ_mean;
var JTV1 JTV2 JTV3 JTV4 JTV5 JTV6 JTV7 JTV8 JTV9 JTV10 JTV11 JTV12 JTV13 JTV14 JTV15 JTV16 JTV17 JTV18 JTV19 JTV20 JTV21 JTV22 JTV23 JTV24 JTV25;
histogram JTV1 JTV2 JTV3 JTV4 JTV5 JTV6 JTV7 JTV8 JTV9 JTV10 JTV11 JTV12 JTV13 JTV14 JTV15 JTV16 JTV17 JTV18 JTV19 JTV20 JTV21 JTV22 JTV23 JTV24 JTV25;
run;

*Create new total scale score;
data reflux_test_merged_fcs_CTQ_mean;
set reflux_test_merged_fcs_CTQ_mean;
CTQtot_imp_IT = JTV1 + (6 - JTV2) + JTV3 + JTV4 + (6 - JTV5) + JTV6 + (6 - JTV7) + JTV8 + JTV9 + JTV10 + JTV11 + (6 - JTV12) + JTV13 + JTV14 + JTV15 + JTV16 + (6 - JTV17) + JTV18 + JTV19 + JTV20 + JTV21 + JTV22 + (6 - JTV23) + JTV24 + (6 - JTV25); 
run;

*Add suffix "_IMP_IT" to all variables except subject ID (per https://support.sas.com/kb/48/674.html);
proc sql noprint;
   select cats(name,'=',name,'_imp_IT')
          into :list
          separated by ' '
          from dictionary.columns
          where libname = 'WORK' and memname = 'REFLUX_TEST_MERGED_FCS_CTQ_MEAN'
          and upcase(name) like 'JTV%';
quit;

*Rename using the macro variable you have created;
proc datasets library = work nolist;
   modify reflux_test_merged_fcs_CTQ_mean;
   rename &list;
quit;

*match label to new variable name (e.g., change label to reflect '_imp_IT' variable name);
proc datasets lib=work;
  modify reflux_test_merged_fcs_CTQ_mean;
  attrib _all_ label=' ';
run;

*save dataset; 
*libname reflux "C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\data\SAS Files\Individual_Variable_Datasets";
data refl_ind.reflux_test_CTQ;
  set work.reflux_test_merged_fcs_CTQ_mean;
run;


****END OF MI PROCEDURE - at this point you can now create new imputed datasets 
by merging the individual imputed datasets that have just been created. 






