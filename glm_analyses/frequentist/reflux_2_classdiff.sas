libname refl_bas "C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\Data_files\SAS_Files\Final_Base_Datasets"; 

*-----------------------------
Group means by classification
------------------------------;

*age;
proc means data=refl_bas.reflux_question1;
 by CLASSIFICATION;
 var age_imp;
run;

*gender;
proc freq data=refl_bas.reflux_question1;
by classification;
table gender_imp;
run;

*BMI;
proc means data=refl_bas.reflux_question1;
 by CLASSIFICATION;
 var BMI_imp;
run;

*PPI status (on/off/missing);
proc freq data=refl_bas.reflux_question1;
 by CLASSIFICATION;
 table pH_MII_ON_OFF_INF_MISS;
run;

*psychological questionnaires;
ODS graphics on;
ODS RTF FILE="C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\Paper\2_reflux_classifications\vartable.rtf"; /* when including macro variables, always use double quotes */
proc means data=refl_bas.reflux_question1;
 by CLASSIFICATION;
 var ASItot_imp_IT BAQtot_imp_IT CTQtot_imp_IT IAS_health_anx_imp_IT IAS_illness_behav_imp_IT NEO_N_imp_IT NEO_E_imp_IT NEO_O_imp_IT NEO_A_imp_IT NEO_C_imp_IT STAITtot_imp_IT LSAStot_imp_IT PASStot_imp_IT PCCLcat_imp_IT PCCLpco_imp_IT PCCLint_imp_IT PCCLext_imp_IT PHQ9dep_imp_IT PTSDtotaal_imp_IT VSItot_imp_IT;
run;
ODS RTF CLOSE;

*psychological factors;
proc means data=refl_bas.reflux_question1;
 by CLASSIFICATION;
 var Factor1 - Factor5;
run;

*-----------------------------
Group means overall sample
------------------------------;

*continuous variables;
ODS graphics on;
ODS RTF FILE="C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\Paper\2_reflux_classifications\logtable_fullsample.rtf"; /* when including macro variables, always use double quotes */
proc means data=refl_bas.reflux_question1;
 var age_imp BMI_imp ASItot_imp_IT BAQtot_imp_IT CTQtot_imp_IT IAS_health_anx_imp_IT IAS_illness_behav_imp_IT NEO_N_imp_IT NEO_E_imp_IT NEO_O_imp_IT NEO_A_imp_IT NEO_C_imp_IT STAITtot_imp_IT LSAStot_imp_IT PASStot_imp_IT PCCLcat_imp_IT PCCLpco_imp_IT PCCLint_imp_IT PCCLext_imp_IT PHQ9dep_imp_IT PTSDtotaal_imp_IT VSItot_imp_IT Factor1 - Factor5;
run;
ODS RTF CLOSE;

*categorical
*gender;
proc freq data=refl_bas.reflux_question1;
table gender_imp;
run;


*PPI status (on/off/missing);
proc freq data=refl_bas.reflux_question1;
 table pH_MII_ON_OFF_INF_MISS;
run;


*------------------------------------
Demographic/clinical 
differences between classifications
-------------------------------------;

*Differences in age, BMI between classifications;
proc glm data=refl_bas.reflux_question1;
class classification;
model age_imp bmi_imp = classification / solution p tolerance clparm;
manova h=_all_ / summary;
lsmeans classification / diff=all adjust=tukey;
run;

*Omnibus Chi Square - differences in gender;  
proc freq data=refl_bas.reflux_question1;
table gender_imp * CLASSIFICATION /chisq fisher;
run;

*post-hoc gender;
Proc freq data=refl_bas.reflux_question1; 
tables gender_imp*classification/chisq  nocol nopercent ;
where classification in (-3 -1);
run;
* FHxRHS not significant (p=.0521);

Proc freq data=refl_bas.reflux_question1; 
tables gender_imp*classification/chisq  nocol nopercent ;
where classification in (-3 1);
run;
* FHxBorderline GERD not significant (p= 0.5419);

Proc freq data=refl_bas.reflux_question1; 
tables gender_imp*classification/chisq  nocol nopercent ;
where classification in (-3 3);
run;
* FHxTrue GERD not significant (p=0.0844);

Proc freq data=refl_bas.reflux_question1; 
tables gender_imp*classification/chisq  nocol nopercent ;
where classification in (-1 1);
run;
* RHSxBorderline GERD not significant;

Proc freq data=refl_bas.reflux_question1; 
tables gender_imp*classification/chisq  nocol nopercent ;
where classification in (-1 3);
run;
* RHSxTrue GERD = SIGNIFICANT at 0.0009 (Bonferroni holm correction = 0.008, so it stays significant);

Proc freq data=refl_bas.reflux_question1; 
tables gender_imp*classification/chisq  nocol nopercent ;
where classification in (1 3);
run;
* Borderline GERDxTrue GERD = SIGNIFICANT at 0.0347 (Bonferroni holm correction = 0.0166, so not significant); 



*omnibus chi square - differenecs in PPI Use;  
proc freq data=refl_bas.reflux_question1;
table pH_MII_ON_OFF_INF_MISS * CLASSIFICATION /chisq fisher;
run;


*post-hoc PPI use OFFxON;
Proc freq data=refl_bas.reflux_question1; 
tables pH_MII_ON_OFF_INF_MISS*classification/chisq  nocol nopercent ;
where classification in (-3 -1) AND pH_MII_ON_OFF_INF_MISS in (-1 1);
run;
* FHxRHS not significant (p=0.3444);

Proc freq data=refl_bas.reflux_question1; 
tables pH_MII_ON_OFF_INF_MISS*classification/chisq  nocol nopercent ;
where classification in (-3 1) and pH_MII_ON_OFF_INF_MISS in (-1 1);
run;
* FHxBorderline GERD  significant (p<.0001) passes bonferroni correction;

Proc freq data=refl_bas.reflux_question1; 
tables pH_MII_ON_OFF_INF_MISS*classification/chisq  nocol nopercent ;
where classification in (-3 3) and pH_MII_ON_OFF_INF_MISS in (-1 1);
run;
* FHxTrue GERD  significant (p<.0290) does not pass bonferroni correction;

Proc freq data=refl_bas.reflux_question1; 
tables pH_MII_ON_OFF_INF_MISS*classification/chisq  nocol nopercent ;
where classification in (-1 1) and pH_MII_ON_OFF_INF_MISS in (-1 1);
run;
* RHSxBorderline GERD  significant (p<.0001) passes bonferroni correction;

Proc freq data=refl_bas.reflux_question1; 
tables pH_MII_ON_OFF_INF_MISS*classification/chisq  nocol nopercent ;
where classification in (-1 3) and pH_MII_ON_OFF_INF_MISS in (-1 1);
run;
* RHSxTrue GERD not significant (p=0.2813);

Proc freq data=refl_bas.reflux_question1; 
tables pH_MII_ON_OFF_INF_MISS*classification/chisq  nocol nopercent ;
where classification in (1 3) and pH_MII_ON_OFF_INF_MISS in (-1 1);
run;
* Borderline GERDxTrue GERD  significant (p<.0001) passes bonferroni correction;



*post-hoc PPI use OFFxMISSING;
Proc freq data=refl_bas.reflux_question1; 
tables pH_MII_ON_OFF_INF_MISS*classification/chisq  nocol nopercent ;
where classification in (-3 -1) AND pH_MII_ON_OFF_INF_MISS in (-1 0);
run;
* FHxRHS not significant (p=0.1906);

Proc freq data=refl_bas.reflux_question1; 
tables pH_MII_ON_OFF_INF_MISS*classification/chisq  nocol nopercent ;
where classification in (-3 1) and pH_MII_ON_OFF_INF_MISS in (-1 0);
run;
* FHxBorderline GERD  not significant (p=0.4573);

Proc freq data=refl_bas.reflux_question1; 
tables pH_MII_ON_OFF_INF_MISS*classification/chisq  nocol nopercent ;
where classification in (-3 3) and pH_MII_ON_OFF_INF_MISS in (-1 0);
run;
* FHxTrue GERD  not significant (p=0.6246);

Proc freq data=refl_bas.reflux_question1; 
tables pH_MII_ON_OFF_INF_MISS*classification/chisq  nocol nopercent ;
where classification in (-1 1) and pH_MII_ON_OFF_INF_MISS in (-1 0);
run;
* RHSxBorderline GERD not significant (p=.0896);

Proc freq data=refl_bas.reflux_question1; 
tables pH_MII_ON_OFF_INF_MISS*classification/chisq  nocol nopercent ;
where classification in (-1 3) and pH_MII_ON_OFF_INF_MISS in (-1 0);
run;
* RHSxTrue GERD not significant (p=0.3816);

Proc freq data=refl_bas.reflux_question1; 
tables pH_MII_ON_OFF_INF_MISS*classification/chisq  nocol nopercent ;
where classification in (1 3) and pH_MII_ON_OFF_INF_MISS in (-1 0);
run;
* Borderline GERDxTrue GERD not significant (p=0.2834);




*post-hoc PPI use OFFxMISSING;
Proc freq data=refl_bas.reflux_question1; 
tables pH_MII_ON_OFF_INF_MISS*classification/chisq  nocol nopercent ;
where classification in (-3 -1) AND pH_MII_ON_OFF_INF_MISS in (1 0);
run;
* FHxRHS not significant (p=0.8357);

Proc freq data=refl_bas.reflux_question1; 
tables pH_MII_ON_OFF_INF_MISS*classification/chisq  nocol nopercent ;
where classification in (-3 1) and pH_MII_ON_OFF_INF_MISS in (1 0);
run;
* FHxBorderline GERD   significant (p=0.0048) does not pass bonferroni correction;

Proc freq data=refl_bas.reflux_question1; 
tables pH_MII_ON_OFF_INF_MISS*classification/chisq  nocol nopercent ;
where classification in (-3 3) and pH_MII_ON_OFF_INF_MISS in (1 0);
run;
* FHxTrue GERD  not significant (p=0.3170;

Proc freq data=refl_bas.reflux_question1; 
tables pH_MII_ON_OFF_INF_MISS*classification/chisq  nocol nopercent ;
where classification in (-1 1) and pH_MII_ON_OFF_INF_MISS in (1 0);
run;
* RHSxBorderline GERD not significant (p=.1040);

Proc freq data=refl_bas.reflux_question1; 
tables pH_MII_ON_OFF_INF_MISS*classification/chisq  nocol nopercent ;
where classification in (-1 3) and pH_MII_ON_OFF_INF_MISS in (1 0);
run;
* RHSxTrue GERD not significant (p=0.1493);

Proc freq data=refl_bas.reflux_question1; 
tables pH_MII_ON_OFF_INF_MISS*classification/chisq  nocol nopercent ;
where classification in (1 3) and pH_MII_ON_OFF_INF_MISS in (1 0);
run;
* Borderline GERDxTrue GERD significant (p=0.0004) passes bonferroni correction;

*-------------------
Logistic Regression
--------------------;


*Multinomial logistic Regression;
proc logistic data=refl_bas.reflux_question1 plots=all order=data;
model classification = BC_CTQtot_imp_IT Factor1-Factor5 age_imp gender_imp BMI_imp  / link=glogit;
run; quit;
*No significant; 

*Ordinal Logistic Regression (cumulative logit function);
proc logistic data=refl_bas.reflux_question1 order=internal plots=all descending;
model classification = BC_CTQtot_imp_IT Factor1-Factor5 age_imp gender_imp BMI_imp  / link=cumlogit;
run; quit;
*

*macro to test the odds assumption for age/gender/BMI that has been violated in the model;
%EmpiricalLogitPlot(data=refl_bas.reflux_question1, y=classification, x=age_imp, options=DATAORDER nopanel)
%EmpiricalLogitPlot(data=refl_bas.reflux_question1, y=classification, x=gender_imp, options=DATAORDER nopanel)
%EmpiricalLogitPlot(data=refl_bas.reflux_question1, y=classification, x=BMI_imp, options=DATAORDER nopanel)
*lines are parallel for all of them, therefore we can make the case that the assumption is not actually violated
and continue using the cumulative logit results;


                                                         
                   