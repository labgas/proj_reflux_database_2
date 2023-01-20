libname refl_bas "C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\Data_files\SAS_Files\Final_Base_Datasets"; /* Liv's path */
*libname refl_bas "C:\Users\lukas\OneDrive - KU Leuven\proj-reflux-database\Data_files\SAS_Files\Final_Base_Datasets"; /* Lukas' path */
*libname refl_bas "C:\Users\u0027997\OneDrive - KU Leuven\proj-reflux-database\Data_files\SAS_Files\Final_Base_Datasets"; /* Lukas' laptop path */
*I put my paths in my autoexec.sas under SASHome/SASFoundation/9.4;
options fmtsearch = (refl_bas.catalog);


*Descriptive stats: reflux variables - all; 
proc univariate data=refl_bas.reflux_test_imp_final;
   var 
total_gastric_acid_exp_imp
total_eso_acid_exp_imp
tot_vol_exp_imp
total_nr_acid_imp
up_gastr_acid_exp
Noct_gastric_acid_exp
Up_eso_acid_exp
Noct_eso_acid_exp
up_vol_exp
noct_vol_exp
up_nr_acid
up_nr_nonacid
up_total_nr
noct_nr_acid
noct_nr_nonacid
noct_total_nr
total_nr_nonacid
TOTAL_nr
__mixed
nr_prox_reflux

HB_0
regurg_0
cough_0
other_0
all_symptoms_0
atypical_sympt_0

SI_HB_acid
SI_HB_nonacid
SI_HB_total
SI_Regurg_acid
SI_regurg_nonacid
SI_regurg_total
SI_atypical_acid
SI_atypical_nonacid
SI_atypical_total

SAP_HB_acid
SAP_HB_nonacid
SAP_HB_total
SAP_Regurg_acid
SAP_regurg_nonacid
SAP_regurg_total
SAP_atypical_acid
SAP_atypical_NA
SAP_atypical_total;
   histogram / nmidpoints=50 normal (mu=est sigma=est) lognormal (theta=est sigma=est zeta=est) power (theta=est sigma=est alpha=est) gamma (theta=est sigma=est alpha=est) exponential (theta=est sigma=est);
run;


*Descriptive stats: ReQuest variables;
proc univariate data=refl_bas.reflux_test_imp_final;
   var 
wellbeing_imp
acid_acidfreq_imp_IT
acid_acidinvl_imp_IT
RQ_Acid_imp_IT
bb_freq_imp_IT
bb_invl_imp_IT
RQ_bovenbuik_imp_IT
mis_freq_imp_IT
mis_invl_imp_IT
RQ_misselijkheid_imp_IT
ob_freq_imp_IT
ob_invl_imp_IT
RQ_Onderbuik_imp_IT
ss_freq_imp_IT
ss_invl_imp_IT
RQ_Slaapstoornissen_imp_IT
a_freq_imp_IT
a_invl_imp_IT
RQ_Andere_imp_IT
RQ_Total;
	histogram / nmidpoints=50 normal (mu=est sigma=est) lognormal (theta=est sigma=est zeta=est) power (theta=est sigma=est alpha=est) gamma (theta=est sigma=est alpha=est) exponential (theta=est sigma=est);
run;


*Correlations: questionnaires;
ods html close;
ods rtf file='C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\SAS_analyses\Report\correlations_psych.rtf'; *Liv's path;

proc corr data=refl_bas.reflux_test_imp_final spearman plots=all;
    var 
ASItot_imp_IT
CTQtot_imp_IT
IAS_health_anx_imp_IT
IAS_illness_behav_imp_IT
NEO_N_imp_IT
NEO_E_imp_IT
NEO_O_imp_IT
NEO_A_imp_IT
NEO_C_imp_IT
STAITtot_imp_IT
BAQtot_imp_IT
CIStot_imp_IT
CNAQtot_imp_IT
LSAStot_imp_IT
MAAGtotaal_imp_IT
PASStot_imp_IT
PCCLcat_imp_IT
PCCLpco_imp_IT
PCCLint_imp_IT
PCCLext_imp_IT
PHQ15_imp_IT
PHQ9dep_imp_IT
PTSDtotaal_imp_IT
STAIStot_imp_IT
VSItot_imp_IT;
run;

ods rtf close;
ods html path="C:\Users\u0140676\AppData\Local\Temp\SAS Temporary Files";


*-----------------------------
Principal Components Analysis
------------------------------

*standardize dataset (we checked and it's not necessary to standardize);
proc standard DATA=refl_bas.Reflux_test_imp_final out = work.Reflux_test_imp_final_std mean = 0 STD = 1;
var 
ASItot_imp_IT
BAQtot_imp_IT
IAS_health_anx_imp_IT
IAS_illness_behav_imp_IT
NEO_N_imp_IT
NEO_E_imp_IT
NEO_O_imp_IT
NEO_A_imp_IT
NEO_C_imp_IT
STAITtot_imp_IT
LSAStot_imp_IT
PASStot_imp_IT
PCCLcat_imp_IT
PCCLpco_imp_IT
PCCLint_imp_IT
PCCLext_imp_IT
PHQ9dep_imp_IT
PTSDtotaal_imp_IT
VSItot_imp_IT;
run;

*PCA with orthogonal rotation;
PROC FACTOR DATA= refl_bas.Reflux_test_imp_final out = refl_bas.reflux_test_imp_final_pca_psych
 SIMPLE 
 METHOD=PRIN
 PRIORS=ONE
 SCREE
 ROTATE=VARIMAX
 ROUND
 NFACTORS = 5
REORDER 
FLAG=.40;
VAR
ASItot_imp_IT
BAQtot_imp_IT
IAS_health_anx_imp_IT
IAS_illness_behav_imp_IT
NEO_N_imp_IT
NEO_E_imp_IT
NEO_O_imp_IT
NEO_A_imp_IT
NEO_C_imp_IT
STAITtot_imp_IT
LSAStot_imp_IT
PASStot_imp_IT
PCCLcat_imp_IT
PCCLpco_imp_IT
PCCLint_imp_IT
PCCLext_imp_IT
PHQ9dep_imp_IT
PTSDtotaal_imp_IT
VSItot_imp_IT;
RUN;

*checking correlations of the factors; 
proc corr data = refl_bas.Reflux_test_imp_final_pca_psych;
var factor1-factor5;
run;


*------------------
Final data cleaning
-------------------;

* describe dataset using proc datasets;
proc datasets library=refl_bas nolist;
   contents data=Reflux_test_imp_final_pca_psych;
   title  'Reflux_test_imp_final_pca_psych';
run;
quit;
title;

* we need labels for all variables, and rename some of them;
data refl_bas.reflux_imp_final_pca_psy_clean;
	set refl_bas.reflux_test_imp_final_pca_psych;
	label 
		subject = 'subject number'
		classification = 'reflux subgroup'
		age_imp = 'age'
		gender_imp = 'sex'
		marital_status_imp = 'marital status'
		education_imp = 'educational status'
		occupation_imp = 'occupational status'
		weight_imp = 'weight (kg)'
		length_imp = 'length (m)'
		BMI_imp = 'body mass index (kg/m2)'
		OESOFAGITIS = 'oesofagitis grade'
		PH_MII__ON_or_OFF_PPI = 'PPI intake during pH-MII'
		PH_MII_ON_OFF_CODED = 'PPI intake during pH-MII'
		total_gastric_acid_exp_imp = 'total gastric acid exposure (%)'
		total_eso_acid_exp_imp = 'total esophageal acid exposure (%)'
		tot_vol_exp_imp = 'total volume exposure ()'
		total_nr_acid_imp = 'total number of acid reflux events'
		up_gastr_acid_exp = 'daytime gastric acid exposure (%)'
		Noct_gastric_acid_exp = 'nocturnal gastric acid exposure (%)'
		Up_eso_acid_exp = 'daytime esophageal acid exposure (%)'
		Noct_eso_acid_exp = 'nocturnal esophageal acid exposure (%)'
		up_vol_exp = 'daytime volume exposure ()'
		noct_vol_exp = 'nocturnal volume exposure ()'
		up_nr_acid = 'number of daytime acid reflux events'
		up_nr_nonacid = 'number of daytime non-acid reflux events'
		up_total_nr = 'total number of daytime reflux events'
		noct_nr_acid = 'number of nocturnal acid reflux events'
		noct_nr_nonacid = 'number of nocturnal non-acid reflux events'
		noct_total_nr = 'number of nocturnal daytime reflux events'
		total_nr_nonacid = 'total number of nonacid reflux events'
		TOTAL_nr = 'total number of reflux events'
		HB_0 = '# heartburn reports during pH-MII'
		regurg_0 = '# regurgitation reports during pH-MII'
		cough_0 = '# cough reports during pH-MII'
		other_0 = '# other symptom reports during pH-MII'
		all_symptoms_0 = '# symptom reports during pH-MII'
		atypical_sympt_0 = '# atypical symptom reports during pH-MII'
		SI_HB_total_Recode = 'symptom index (heartburn)'
		SAP_HB_total_Recode = 'symptom association probability (heartburn)'
		SI_regurg_total_Recode = 'symptom index (regurgitation)'
		SAP_regurg_total_Recode = 'symptom association probability (regurgitation)'
		SI_atypical_total_Recode = 'symptom index (atypical symptoms)'
		SAP_atypical_total_Recode = 'symptom association probability (atypical symptoms)'
		SI_sum_total = 'symptom index (any symptom)'
		SAP_sum_total = 'symptom association (any symptom)'
		wellbeing_imp = 'ReQuest (wellbeing subscale)'
		RQ_Acid_imp_IT = 'ReQuest (acid subscale)'
		RQ_Bovenbuik_imp_IT = 'ReQuest (upper abdomen subscale)'
		RQ_Misselijkheid_imp_IT = 'ReQuest (nausea subscale)'
		RQ_Onderbuik_imp_IT = 'ReQuest (lower abdomen subscale)'
		RQ_Slaapstoornissen_imp_IT = 'ReQuest (sleep subscale)'
		RQ_Andere_imp_IT = 'ReQuest (other subscale)'
		RQ_Total = 'ReQuest (total score)'
		ASItot_imp_IT = 'Anxiety Sensitivity Index'
		BAQtot_imp_IT = 'Body Awareness Questionnaire (total score)'
		BAQ_note_change_imp_IT = 'BAQ (note changes in body processes subscale)'
		BAQ_pred_react_imp_IT = 'BAQ (predict body reaction subscale)'
		BAQ_sleep_imp_IT = 'BAQ (sleep-wake cycle subscale)'
		BAQ_onset_imp_IT = 'BAQ (onset of illness subscale)'
		CIStot_imp_IT = 'Checklist Individual Strength (total score)'
		CIS_tired_imp_IT = 'Checklist Individual Strength (fatigue subscale)'
		CIS_motiv_imp_IT = 'Checklist Individual Strength (motivation subscale)'
		CIS_conc_imp_IT = 'Checklist Individual Strength (concentration subscale)'
		CIS_activ_imp_IT = 'Checklist Individual Strength (activity subscale)'
		CNAQtot_imp_IT = 'Council on Nutrition Appetite Questionnaire'
		CTQtot_imp_IT = 'Childhood Trauma Questionnaire (total score)'
		IAStot_imp_IT = 'Illness Attitude Scale (total score)'
		IAS_health_anx_imp_IT = 'IAS (health anxiety subscale)'
		IAS_illness_behav_imp_IT = 'IAS (illness behavior subscale)'
		LSAStot_imp_IT = 'Liebowitz Social Anxiety Scale (total score)'
		LSAScutoff_imp_IT = 'Liebowitz Social Anxiety Scale (ordinal)'
		LSAS_soc_int_imp_IT = 'LSAS (social interaction subscale)'
		LSAS_pub_spk_imp_IT = 'LSAS (public speaking subscale)'
		LSAS_eat_drink_imp_IT = 'LSAS (eating & drinking in front of others subscale)'
		LSAS_obs_imp_IT = 'LSAS (working/writing while being observed subscale)'
		MAAGtotaal_imp_IT = 'Dyspepsia Symptom Severity Scale'
		NEO_N_imp_IT = 'NEO-FFI (neuroticism subscale)'
		NEO_E_imp_IT = 'NEO-FFI (extraversion subscale)'
		NEO_O_imp_IT = 'NEO-FFI (openness to experience subscale')
		NEO_A_imp_IT = 'NEO-FFI (agreeableness subscale')
		NEO_C_imp_IT = 'NEO-FFI (conscientiousness subscale')
		PASStot_imp_IT = 'Pain Anxiety Symptoms Scale (total score)'
		PASS_fear_imp_IT = 'PASS (fear subscale)'
		PASS_cogn_imp_IT = 'PASS (cognitive anxiety subscale)'
		PASS_phys_imp_IT = 'PASS (physiology subscale)'
		PASS_esc_avo_imp_IT = 'PASS (escape/avoidance subscale)'
		PCCLcat_imp_IT = 'PCCL (catastrophizing subscale)'
		PCCLpco_imp_IT = 'PCCL (pain coping subscale)'
		PCCLint_imp_IT = 'PCCL (internal pain control subscale)'
		PCCLext_imp_IT = 'PCCL (external pain control subscale)'
		PHQ15_imp_IT = 'Patient Health Questionnaire 15 (somatic symptoms)'
		PHQ9dep_imp_IT = 'Patient Health Questionnaire 9 (depression)'
		PTSDtotaal_imp_IT = 'PTSD-ZIL (total score)'
		PTSD_relive_imp_IT = 'PTSD-ZIL (relive subscale)'
		PTSD_avoid_imp_IT = 'PTSD-ZIL (avoidance subscale)'
		PTSD_hyperarousal_imp_IT = 'PTSD-ZIL (hyperarousal subscale)'
		PTSD_cutoff_imp_IT = 'PTSD-ZIL (binary)'
		STAIStot_imp_IT = 'STAI (state subscale)'
		STAITtot_imp_IT = 'STAI (trait subscale)'
		VSItot_imp_IT = 'Visceral Sensitivity Index'
		Factor1 = 'health anxiety factor'
		Factor2 = 'general psychological distress factor'
		Factor3 = 'personality factor'
		Factor4 = 'pain coping factor'
		Factor5 = 'social functioning factor';
	rename 
		HB_0 = pH_imp_HB 
		regurg_0 = pH_imp_regurg 
		cough_0 = pH_imp_cough 
		other_0 = pH_imp_other 
		all_symptoms_0 = pH_imp_all 
		atypical_sympt_0 = pH_imp_atypical;
	drop 
		pH_measurement
		__mixed 
		SI_HB_acid 
		SI_HB_nonacid 
		SI_HB_total 
		SI_Regurg_acid 
		SI_regurg_nonacid 
		SI_regurg_total 
		SI_atypical_acid 
		SI_atypical_nonacid 
		SI_atypical_total 
		SAP_HB_acid 
		SAP_HB_nonacid 
		SAP_HB_total 
		SAP_Regurg_acid 
		SAP_regurg_nonacid 
		SAP_regurg_total 
		SAP_atypical_acid 
		SAP_atypical_NA 
		SAP_atypical_total 
		acid_acidfreq_imp_IT
		acid_acidinvl_imp_IT
		bb_freq_imp_IT
		bb_invl_imp_IT
		mis_freq_imp_IT
		mis_invl_imp_IT
		ob_freq_imp_IT
		ob_invl_imp_IT
		ss_freq_imp_IT
		ss_invl_imp_IT
		a_freq_imp_IT
		a_invl_imp_IT
		PHQ15_14_imp_IT;
run;

* describe dataset using proc datasets again to check the result of the above data step;
proc datasets library=refl_bas nolist;
   contents data=reflux_imp_final_pca_psy_clean;
   title  'reflux_imp_final_pca_psy_clean';
run;
quit;
title;

* search formats in the right place;
options fmtsearch = (refl_bas.catalog);

* recode character variables to numerical variables, and make sure they sum up to 0 for ordinal variables (this allows easy linear contrast testing)

INFO on coding options for categorical variables (nominal and ordinal)
https://stats.oarc.ucla.edu/spss/faq/coding-systems-for-categorical-variables-in-regression-analysis
https://stats.oarc.ucla.edu/sas/webbooks/reg/chapter5/regression-with-saschapter-5-additional-coding-systems-for-categorical-variables-in-regressionanalysis
https://communities.sas.com/t5/SAS-Communities-Library/Display-the-hidden-estimate-for-the-reference-category-in-EFFECT/ta-p/633865
https://phillipalday.com/stats/coding.html
https://stats.stackexchange.com/questions/113643/linear-trend-in-sas-using-contrast
https://support.sas.com/resources/papers/proceedings/proceedings/sugi29/194-29.pdf
https://communities.sas.com/t5/Statistical-Procedures/PROC-GLM-effects-coding/td-p/46482

LUKAS' programmer notes
1. if you format numerical vars with a character format, SAS will order them alphabetically i.e. based on the format, but you can use the order=internal option in the proc statement to order numerically
2. you can choose between reference and effects coding by using the global or variable option param=ref in the class statement of proc genmod, proc logistic, and others, but not proc glm
3. to use missing values as a class in your model, you can specify the missing global option in the class statement of similar procedures, but again not proc glm;

* classification - ordinal character var -> change to numerical, recode to sum up to 0, and format;
proc format library=refl_bas.catalog;
	value classification 
		-3='FH'
		-1='RHS'
		1='Borderline_GERD'
		3='True_GERD';
run;

data refl_bas.reflux_imp_final_pca_psy_clean;
	retain subject classification;
	set refl_bas.reflux_imp_final_pca_psy_clean (rename=(classification=old));
	if old = 'FH' then classification = -3;
	if old = 'RHS' then classification = -1;
	if old = 'Borderline_GERD' then classification = 1;
	if old = 'True_GERD' then classification = 3;
	if old = '' then classification = .;
	drop old;
	label classification = 'reflux subgroup';
	format classification classification.;
run;

* gender_imp - binary numeric variable -> format;
proc format library=refl_bas.catalog;
	value gender 
		-1='male'
		1='female';
run;

data refl_bas.reflux_imp_final_pca_psy_clean;
	set refl_bas.reflux_imp_final_pca_psy_clean;
	format gender_imp gender.;
run;

* marital status - nominal numeric variable -> format;
proc format library=refl_bas.catalog;
	value marital
		1='living with partner'
		2='living alone'
		3='living together not with partner';
run;

data refl_bas.reflux_imp_final_pca_psy_clean;
	set refl_bas.reflux_imp_final_pca_psy_clean;
	format marital_status_imp marital.;
run;

* education - ordinal numeric variable -> recode to sum up to 0, and format;
proc format library=refl_bas.catalog;
	value education
		-3='primary school'
		-1='secondary school, technical'
		1='secondary school, general'
		3='higher education';
run;

data refl_bas.reflux_imp_final_pca_psy_clean;
	set refl_bas.reflux_imp_final_pca_psy_clean;
	if education_imp = 1 then education_imp = -3;
	if education_imp = 2 then education_imp = -1;
	if education_imp = 3 then education_imp = 1;
	if education_imp = 4 then education_imp = 3;
	format education_imp education.;
run;

* occupation - nominal numeric variable -> format;
proc format library=refl_bas.catalog;
	value occupation
		1='work fulltime'
		2='work parttime'
		3='sick leave < 1 year'
		4='sick leave > 1 year'
		5='student or household work'
		6='unemployed'
		7='retired';
run;

data refl_bas.reflux_imp_final_pca_psy_clean;
	set refl_bas.reflux_imp_final_pca_psy_clean;
	format occupation_imp occupation.;
run;

* PPI use - binary numeric variable -> format;
proc format library=refl_bas.catalog;
	value ppi
		-1='off';
		1='on';
run;

data refl_bas.reflux_imp_final_pca_psy_clean;
	set refl_bas.reflux_imp_final_pca_psy_clean;
	format PH_MII_ON_OFF_CODED ppi.;
run;

* SAP & SI - binary numeric varlables -> format;
proc format library=refl_bas.catalog;
	value sap
		-1='negative'
		1='positive';
run;

data refl_bas.reflux_imp_final_pca_psy_clean;
	set refl_bas.reflux_imp_final_pca_psy_clean;
	format SI_HB_total_Recode SI_regurg_total_Recode SI_atypical_total_Recode SI_sum_total SAP_HB_total_Recode SAP_regurg_total_Recode SAP_atypical_total_Recode SAP_sum_total sap.;
run;

* describe dataset using proc datasets again to check the result of the above operations;
proc datasets library=refl_bas nolist;
   contents data=reflux_imp_final_pca_psy_clean;
   title  'reflux_imp_final_pca_psy_clean';
run;
quit;
title;
