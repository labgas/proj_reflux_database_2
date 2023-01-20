*libname refl_ind "C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\Data_files\SAS_Files\Individual_Variable_Datasets"; /* Liv's path */
libname refl_ind "C:\Users\lukas\OneDrive - KU Leuven\proj-reflux-database\Data_files\SAS_Files\Individual_Variable_Datasets"; /* Lukas' path */

*--------------------
---------------------
Preparing New Datasets
---------------------
--------------------;

*Note: This code reflects how we created new datasets from the datasets created during the Multiple Imputation procedure.
It  includes the creation of 2 "base" datastes and recoding/relabeling and creation of several variables (e.g., PPI On/Off)

***********************
Create Subscale Totals
***********************

*Create subscale total scores for variables that have subscales;
*LSAS;
Data refl_ind.reflux_test_lsas;
set refl_ind.reflux_test_lsas;
if LSAStot_imp_IT < 30 then LSAScutoff_imp_IT = 0;
if LSAStot_imp_IT >= 30 then LSAScutoff_imp_IT = 1;
if LSAStot_imp_IT >= 60 then LSAScutoff_imp_IT = 2;
LSAS_soc_int_imp_IT = LSAS5a_imp_IT + LSAS5v_imp_IT + LSAS7a_imp_IT + LSAS7v_imp_IT + LSAS10a_imp_IT + LSAS10v_imp_IT + LSAS11a_imp_IT + LSAS11v_imp_IT + LSAS12a_imp_IT + LSAS12v_imp_IT + LSAS14a_imp_IT + LSAS14v_imp_IT + LSAS18a_imp_IT + LSAS18v_imp_IT + LSAS19a_imp_IT + LSAS19v_imp_IT + LSAS21a_imp_IT + LSAS21v_imp_IT + LSAS22a_imp_IT + LSAS22v_imp_IT + LSAS23a_imp_IT + LSAS23v_imp_IT + LSAS24a_imp_IT + LSAS24v_imp_IT;
LSAS_pub_spk_imp_IT = LSAS2a_imp_IT + LSAS2v_imp_IT + LSAS6a_imp_IT + LSAS6v_imp_IT + LSAS15a_imp_IT + LSAS15v_imp_IT + LSAS16a_imp_IT + LSAS16v_imp_IT + LSAS20a_imp_IT + LSAS20v_imp_IT;
LSAS_eat_drink_imp_IT = LSAS3a_imp_IT + LSAS3v_imp_IT + LSAS4a_imp_IT + LSAS4v_imp_IT;
LSAS_obs_imp_IT = LSAS1a_imp_IT + LSAS1v_imp_IT + LSAS8a_imp_IT + LSAS8v_imp_IT + LSAS9a_imp_IT + LSAS9v_imp_IT + LSAS13a_imp_IT + LSAS13v_imp_IT + LSAS17a_imp_IT + LSAS17v_imp_IT;
run;

*PTSD;
Data refl_ind.reflux_test_ptsd;
set refl_ind.reflux_test_ptsd;
PTSD_relive_imp_IT = PTSD5_imp_IT + PTSD7_imp_IT + PTSD9_imp_IT + PTSD10_imp_IT + PTSD18_imp_IT + PTSD21_imp_IT;
PTSD_avoid_imp_IT = PTSD1_imp_IT + PTSD2_imp_IT + PTSD3_imp_IT + PTSD8_imp_IT + PTSD11_imp_IT + PTSD14_imp_IT + PTSD15_imp_IT + PTSD19_imp_IT + PTSD22_imp_IT;
PTSD_hyperarousal_imp_IT = PTSD4_imp_IT + PTSD6_imp_IT + PTSD12_imp_IT + PTSD13_imp_IT + PTSD16_imp_IT + PTSD17_imp_IT + PTSD20_imp_IT;
if PTSDtotaal_imp_IT >= 51 then PTSD_cutoff_imp_IT = 1;
if PTSDtotaal_imp_IT < 51 then PTSD_cutoff_imp_IT = 0;
run;

*PASS;
Data refl_ind.reflux_test_PASS;
set refl_ind.reflux_test_PASS;
PASS_fear_imp_IT = PASS1_imp_IT + PASS5_imp_IT + PASS13_imp_IT + PASS18_imp_IT + PASS21_imp_IT + PASS25_imp_IT + PASS29_imp_IT + PASS33_imp_IT + (5-PASS8_imp_IT) + (5-PASS16_imp_IT);
PASS_cogn_imp_IT = PASS6_imp_IT + PASS10_imp_IT + PASS14_imp_IT + PASS22_imp_IT + PASS26_imp_IT + PASS30_imp_IT + PASS34_imp_IT + PASS37_imp_IT + (5-PASS2_imp_IT) + (5-PASS40_imp_IT);
PASS_phys_imp_IT = PASS4_imp_IT + PASS9_imp_IT + PASS12_imp_IT + PASS17_imp_IT + PASS20_imp_IT + PASS24_imp_IT + PASS28_imp_IT + PASS32_imp_IT + PASS36_imp_IT + PASS38_imp_IT;
PASS_esc_avo_imp_IT = PASS3_imp_IT + PASS7_imp_IT + PASS11_imp_IT + PASS15_imp_IT + PASS19_imp_IT + PASS23_imp_IT + PASS27_imp_IT + PASS35_imp_IT + PASS39_imp_IT + (5-PASS31_imp_IT);
run;

*IAS; 
Data refl_ind.reflux_test_IAS;
set refl_ind.reflux_test_IAS;
IAS_health_anx_imp_IT = IAS2_imp_IT + IAS3_imp_IT + IAS4_imp_IT + IAS6_imp_IT + IAS13_imp_IT + IAS14_imp_IT + IAS15_imp_IT + IAS16_imp_IT + IAS17_imp_IT + IAS19_imp_IT + IAS21_imp_IT;
IAS_illness_behav_imp_IT = IAS23_imp_IT + IAS24_imp_IT + IAS25_imp_IT + IAS27_imp_IT + IAS28_imp_IT + IAS29_imp_IT;
run;

*BAQ;
Data refl_ind.reflux_test_BAQ;
set refl_ind.reflux_test_BAQ;
BAQ_note_change_imp_IT = BAQ1_imp_IT + BAQ4_imp_IT + BAQ13_imp_IT + BAQ14_imp_IT + BAQ16_imp_IT + (8-BAQ10_imp_IT);
BAQ_pred_react_imp_IT = BAQ2_imp_IT + BAQ3_imp_IT + BAQ8_imp_IT + BAQ11_imp_IT + BAQ12_imp_IT + BAQ15_imp_IT + BAQ16_imp_IT;
BAQ_sleep_imp_IT = BAQ7_imp_IT + BAQ8_imp_IT + BAQ9_imp_IT + BAQ15_imp_IT + BAQ17_imp_IT + BAQ18_imp_IT;
BAQ_onset_imp_IT = BAQ5_imp_IT + BAQ6_imp_IT + BAQ7_imp_IT + (8-BAQ10_imp_IT);
run;

*CIS;
Data refl_ind.reflux_test_CIS;
set refl_ind.reflux_test_CIS;
CIS_tired_imp_IT = (8 - CIS4_imp_IT) + (8 - CIS6_imp_IT) + (8 - CIS9_imp_IT) + (8 - CIS14_imp_IT) + (8 - CIS16_imp_IT) + CIS1_imp_IT + CIS12_imp_IT + CIS20_imp_IT;
CIS_motiv_imp_IT = (8 - CIS18_imp_IT) + CIS2_imp_IT + CIS5_imp_IT + CIS15_imp_IT;
CIS_conc_imp_IT = (8 - CIS3_imp_IT) + (8 - CIS13_imp_IT) + (8 - CIS19_imp_IT) + CIS8_imp_IT + CIS11_imp_IT;
CIS_activ_imp_IT = (8 - CIS10_imp_IT) + (8 - CIS17_imp_IT) + CIS7_imp_IT;
run;

*CTQ;
Data refl_ind.reflux_test_CTQ;
set refl_ind.reflux_test_CTQ;
CTQsa_imp_IT = JTV18_imp_IT + JTV19_imp_IT + JTV20_imp_IT + JTV21_imp_IT + JTV24_imp_IT;
CTQpn_imp_IT = JTV1_imp_IT + JTV4_imp_IT + JTV6_imp_IT + (6 - JTV2_imp_IT) + (6 - JTV23_imp_IT);
CTQpa_imp_IT = JTV9_imp_IT + JTV10_imp_IT + JTV11_imp_IT + JTV14_imp_IT + JTV15_imp_IT;
CTQen_imp_IT = (6 - JTV5_imp_IT) + (6 - JTV7_imp_IT) + (6 - JTV12_imp_IT) + (6 - JTV17_imp_IT) + (6 - JTV25_imp_IT);
CTQea_imp_IT = JTV3_imp_IT + JTV8_imp_IT + JTV13_imp_IT + JTV16_imp_IT + JTV22_imp_IT;
run;


*******************************************
Merge MI Item-Level Questionnaire Datasets
*******************************************

*Merge individual imputed item-level datasets into one imputed dataset;
data work.Reflux_test_imputedmerge;
 merge 
refl_ind.reflux_test_rqacid
refl_ind.reflux_test_rqbovenbuik
refl_ind.reflux_test_rqmisselijkheid
refl_ind.reflux_test_rqonderbuik
refl_ind.reflux_test_rqslaap
refl_ind.reflux_test_rqandere
refl_ind.reflux_test_asi
refl_ind.reflux_test_baq
refl_ind.reflux_test_cis
refl_ind.reflux_test_cnaq
refl_ind.reflux_test_ctq
refl_ind.reflux_test_ias
refl_ind.reflux_test_lsas
refl_ind.reflux_test_maag
refl_ind.reflux_test_neo
refl_ind.reflux_test_pass
refl_ind.reflux_test_pccl
refl_ind.reflux_test_phq15
refl_ind.reflux_test_phq9
refl_ind.reflux_test_ptsd
refl_ind.reflux_test_stais
refl_ind.reflux_test_stait
refl_ind.reflux_test_vsi;
 by subject;
 run;

*********************************
Create Demographic/Reflux Dataset
*********************************

*As a preparation for next merge we run PROC CONTENTS on the "reflux_merged" dataset (dataset created after MI of placeholder scale scores) with the VARNUM option to give the variable number;
proc contents data=refl_ind.Reflux_test_merged varnum;
run;

*Create new dataset called "reflux_test_merged_subset" which is a subset of the "reflux_merged" dataset created after the MI that only includes demo & relfux vars. 
The reason for doing this is so that we have one dataset of just demographic & reflux variables that can then be merged with other datasets containing
either the full questionnaire (item & total scores) or just the total scores.

First step is to drop the range of variables between the variables (demo and reflux) we want to keep;
data work.reflux_test_merged_subset;
set refl_ind.Reflux_test_merged (drop=wellbeing--CTQtot_flag);
drop age gender marital_status education occupation weight length BMI _rowstate_;
run;

*Again, drop range of variables between demo and reflux variables & delete top two blank rows. 
Note: This had to be done again because the range variables we wanted to drop was not consecutive; 
data work.reflux_test_merged_subset;
set work.reflux_test_merged_subset (drop = RQ_zuur_imp--CTQtot_imp);
if subject = . then DELETE;
run;

*Again, again, drop range of variables we do not need (these were variables misread as character and had to be changed to numeric during MI and got placed at the end of the dataset);
data work.reflux_test_merged_subset;
set work.reflux_test_merged_subset (drop = ob_urgency--IAS25);
run;

*reorder demographic/reflux variables;
data work.reflux_test_merged_subset;
   retain subject pH_measurement classification age_imp gender_imp marital_status_imp education_imp occupation_imp weight_imp length_imp BMI_imp OESOFAGITIS pH_MII__ON_or_OFF_PPI pH_MII_ON_OFF_CODED total_gastric_acid_exp_imp total_eso_acid_exp_imp tot_vol_exp_imp total_nr_acid_imp;
   set work.reflux_test_merged_subset;
run;

*drop the original four pH variables, as we have new imputed versions of these variables;
data work.reflux_test_merged_subset;
set work.reflux_test_merged_subset;
drop Total_gastric_acid_exp Total_eso_acid_exp Tot_vol_exp Total_nr_acid;
run;

*****************************
   Create "Full" Dataset
*****************************

*Merge imputed dataset (e.g., dataset with all of the imputed questionnaires) with subset dataset (demographic & reflux variables)
*this now creates a dataset with all demographics, reflux variables, item and scale level variables, hence "full" dataset;
data work.Reflux_test_imp_full;
merge 
work.reflux_test_merged_subset
work.reflux_test_imputedmerge;
by subject;
 run;
 
**********************
   MISC. Changes
**********************
*Note:The following are any miscellanious changes that needed to be made to the "full" dataset (e.g., recoding variables, creating new total scores, etc.)
*Any future changes that need to be done to the entire dataset should be done at this step so that they are carried through all subsequent datasets/analysis;

*Total PHQ15 (needed to be done after the merge because we needed the variable "gender" to calculate total score);
data work.Reflux_test_imp_full;
set work.Reflux_test_imp_full;
if gender_imp = 0 then PHQ15_imp_IT = (PHQ_1a_imp_IT + PHQ1b_imp_IT + PHQ1c_imp_IT + PHQ1e_imp_IT + PHQ1f_imp_IT + PHQ1g_imp_IT + PHQ1h_imp_IT + PHQ1i_imp_IT + PHQ1j_imp_IT + PHQ1k_imp_IT + PHQ1l_imp_IT + PHQ1m_imp_IT + PHQ2c_imp_IT + PHQ2d_imp_IT)/14;
if gender_imp = 1 then PHQ15_imp_IT = (PHQ_1a_imp_IT + PHQ1b_imp_IT + PHQ1c_imp_IT + PHQ1d_imp_IT + PHQ1e_imp_IT + PHQ1f_imp_IT + PHQ1g_imp_IT + PHQ1h_imp_IT + PHQ1i_imp_IT + PHQ1j_imp_IT + PHQ1k_imp_IT + PHQ1l_imp_IT + PHQ1m_imp_IT + PHQ2c_imp_IT + PHQ2d_imp_IT)/15;
run;

*Change gender from 0/1 to -1/1;
data work.Reflux_test_imp_full;
  set work.Reflux_test_imp_full;
if gender_imp = 0 then gender_imp = -1;
run;

*EDITED (20/12/2021): Cacluate Request Total Score;
data work.Reflux_test_imp_full;
set work.Reflux_test_imp_full;
RQ_Total = (wellbeing_imp*0.4) + 
((acid_acidfreq_imp_IT/(acid_acidfreq_imp_IT+3))*(acid_acidinvl_imp_IT)) +
((bb_freq_imp_IT/(bb_freq_imp_IT+3))*(bb_invl_imp_IT)) +
((mis_freq_imp_IT/(mis_freq_imp_IT+3))*(mis_invl_imp_IT)) +
((ob_freq_imp_IT/(ob_freq_imp_IT+3))*(ob_invl_imp_IT)) +
((ss_freq_imp_IT/(ss_freq_imp_IT+6))*(ss_invl_imp_IT)) +
((a_freq_imp_IT/(a_freq_imp_IT+9))*(a_invl_imp_IT));
run;

*EDITED (20/01/2022): Create recoded SI variable for HB, Regurgitation, Atypical that indicates if SI was positive or negative;
*recode SI Heartburn;
Data work.Reflux_test_imp_full;
set work.Reflux_test_imp_full;
if SI_HB_total < 50 then SI_HB_total_Recode = -1;
if  SI_HB_total >= 50 then SI_HB_total_Recode = 1;
if SI_HB_total = "" then SI_HB_total_Recode = "";
*recode SI Regurgitation;
if SI_regurg_total < 50 then SI_regurg_total_Recode = -1;
if  SI_regurg_total >= 50 then SI_regurg_total_Recode = 1;
if SI_regurg_total = "" then SI_regurg_total_Recode = "";
*recorde SI atypical;
if SI_atypical_total < 50 then SI_atypical_total_Recode = -1;
if  SI_atypical_total >= 50 then SI_atypical_total_Recode = 1;
if SI_atypical_total = "" then SI_atypical_total_Recode = "";
run;

*EDITED (20/01/2022): Create recoded SAP variable for HB, Regurgitation, Atypical that indicates if SAP was positive or negative;
Data work.Reflux_test_imp_full;
set work.Reflux_test_imp_full;
if SAP_HB_total < 95 then SAP_HB_total_Recode = -1;
if SAP_HB_total >= 95 then SAP_HB_total_Recode = 1;
if SAP_HB_total = "" then SAP_HB_total_Recode = "";
*recode SAP Regurgitation;
if SAP_regurg_total < 95 then SAP_regurg_total_Recode = -1;
if SAP_regurg_total >= 95 then SAP_regurg_total_Recode = 1;
if SAP_regurg_total = "" then SAP_regurg_total_Recode = "";
*recode SAP atypical;
if SAP_atypical_total < 95 then SAP_atypical_total_Recode = -1;
if SAP_atypical_total >= 95 then SAP_atypical_total_Recode = 1;
if SAP_atypical_total = "" then SAP_atypical_total_Recode = "";
run;

*EDITED (20/01/20222): Create new SI and SAP sum total variables to reflect if ANY of the SI/SAP (HB, regurg, atypical) variables were positive;
*SI Total variable;
Data work.Reflux_test_imp_full;
set work.Reflux_test_imp_full;
if SI_HB_total_Recode = 1 OR SI_regurg_total_Recode = 1 OR SI_atypical_total_Recode = 1 then SI_sum_total = 1;
if SI_HB_total_Recode = "" AND SI_regurg_total_Recode = "" AND SI_atypical_total_Recode = "" then SI_sum_total = "";
if (SI_HB_total_Recode = -1 OR SI_regurg_total_Recode = -1 OR SI_atypical_total_Recode = -1) AND (SI_HB_total_Recode NE 1 AND SI_regurg_total_Recode NE 1 AND SI_atypical_total_Recode NE 1) then SI_sum_total = -1;
run;
*SAP Total variable;
Data work.Reflux_test_imp_full;
set work.Reflux_test_imp_full;
if SAP_HB_total_Recode = 1 OR SAP_regurg_total_Recode = 1 OR SAP_atypical_total_Recode = 1 then SAP_sum_total = 1;
if SAP_HB_total_Recode = "" AND SAP_regurg_total_Recode = "" AND SAP_atypical_total_Recode = "" then SAP_sum_total = "";
if (SAP_HB_total_Recode = -1 OR SAP_regurg_total_Recode = -1 OR SAP_atypical_total_Recode = -1) AND (SAP_HB_total_Recode NE 1 AND SAP_regurg_total_Recode NE 1 AND SAP_atypical_total_Recode NE 1) then SAP_sum_total = -1;
run;

*EDITED (20/01/2022): Add 0 to missing values for variables "all_symptoms" and "atypical_symptoms" & rename to reflect the change;
Data work.reflux_test_imp_full;
set work.reflux_test_imp_full;
if all_symptoms = "" then all_symptoms = 0;
if atypical_sympt = "" then atypical_sympt = 0;
rename all_symptoms = all_symptoms_0;
rename atypical_sympt = atypical_sympt_0;
run;

*save reflux_test_full dataset to the refl_bas library;
*libname refl_bas "C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\Data_files\SAS_Files\Final_Base_Datasets"; /* Liv's path */
libname refl_bas "C:\Users\lukas\OneDrive - KU Leuven\proj-reflux-database\Data_files\SAS_Files\Final_Base_Datasets"; /* Lukas' path */

data refl_bas.reflux_test_imp_full;
  set work.reflux_test_imp_full;
run;


*****************************
   Create "Final" Dataset
*****************************
*Note: this dataset will contain all demographic & reflux variables but ONLY the total score for relevant questionnaires
It is different than the "Full" dataset as the "Full" dataset includes the questionnaire items & total scores.
Everytime there is a change to the "Full" dataset, the "Final" dataset needs to be re-run to make sure the changes are carried through into analyses

*Create new subset dataset that only includes demo and reflux variables;
data work.reflux_test_imp_demo_acid;
set refl_bas.reflux_test_imp_full (drop = wellbeing_imp--RQ_Total);
run;

*Next select the total scores for each variable;
data work.reflux_test_imp_totalscore;
set refl_bas.reflux_test_imp_full;
keep subject wellbeing_imp acid_acidfreq_imp_IT acid_acidinvl_imp_IT RQ_Acid_imp_IT bb_freq_imp_IT bb_invl_imp_IT RQ_Bovenbuik_imp_IT mis_freq_imp_IT mis_invl_imp_IT RQ_Misselijkheid_imp_IT ob_freq_imp_IT ob_invl_imp_IT RQ_Onderbuik_imp_IT 
ss_freq_imp_IT ss_invl_imp_IT RQ_Slaapstoornissen_imp_IT a_freq_imp_IT a_invl_imp_IT RQ_Andere_imp_IT RQ_Total ASItot_imp_IT BAQtot_imp_IT BAQ_note_change_imp_IT BAQ_pred_react_imp_IT BAQ_sleep_imp_IT BAQ_onset_imp_IT
CIStot_imp_IT CIS_tired_imp_IT CIS_motiv_imp_IT CIS_conc_imp_IT CIS_activ_imp_IT CNAQtot_imp_IT CTQtot_imp_IT IAStot_imp_IT IAS_health_anx_imp_IT IAS_illness_behav_imp_IT
LSAStot_imp_IT LSAScutoff_imp_IT LSAS_soc_int_imp_IT LSAS_pub_spk_imp_IT LSAS_eat_drink_imp_IT LSAS_obs_imp_IT MAAGtotaal_imp_IT NEO_N_imp_IT NEO_E_imp_IT NEO_O_imp_IT NEO_A_imp_IT NEO_C_imp_IT
PASStot_imp_IT PASS_fear_imp_IT PASS_cogn_imp_IT PASS_phys_imp_IT PASS_esc_avo_imp_IT PCCLcat_imp_IT PCCLpco_imp_IT PCCLint_imp_IT PCCLext_imp_IT PHQ15_14_imp_IT PHQ15_imp_IT PHQ9dep_imp_IT
PTSDtotaal_imp_IT PTSD_relive_imp_IT PTSD_avoid_imp_IT PTSD_hyperarousal_imp_IT PTSD_cutoff_imp_IT STAIStot_imp_IT STAITtot_imp_IT VSItot_imp_IT;
run;

*reorder variables;
data work.reflux_test_imp_totalscore;
   retain subject wellbeing_imp acid_acidfreq_imp_IT acid_acidinvl_imp_IT RQ_Acid_imp_IT bb_freq_imp_IT bb_invl_imp_IT RQ_Bovenbuik_imp_IT mis_freq_imp_IT mis_invl_imp_IT RQ_Misselijkheid_imp_IT ob_freq_imp_IT ob_invl_imp_IT RQ_Onderbuik_imp_IT 
ss_freq_imp_IT ss_invl_imp_IT RQ_Slaapstoornissen_imp_IT a_freq_imp_IT a_invl_imp_IT RQ_Andere_imp_IT RQ_Total;
   set work.reflux_test_imp_totalscore;
run;

*Merge two datasets to create a dataset with demographics, reflux variables, and total scores only;
data work.Reflux_test_imp_final;
 merge work.reflux_test_imp_demo_acid
 work.reflux_test_imp_totalscore;
 by subject;
 run;

*save dataset; 
data Refl_bas.Reflux_test_imp_final;
  set work.Reflux_test_imp_final;
run;

****************END OF CODE;






