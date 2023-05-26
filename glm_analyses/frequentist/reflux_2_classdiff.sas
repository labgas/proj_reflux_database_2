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

***AGE***

*Differences in age, BMI between classifications;
proc glm data=refl_bas.reflux_question1;
class classification;
model age_imp bmi_imp = classification / solution p tolerance clparm;
manova h=_all_ / summary;
lsmeans classification / diff=all adjust=tukey;
run;


***GENDER***

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


***PPI USE***

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




*post-hoc PPI use ONxMISSING;
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
class gender_imp;
model classification = BC_CTQtot_imp_IT Factor1-Factor5 age_imp gender_imp BMI_imp / link=glogit;
run; quit;


*Ordinal Logistic Regression (cumulative logit function);
proc logistic data=refl_bas.reflux_question1 order=internal plots=all descending;
class gender_imp;
model classification = BC_CTQtot_imp_IT Factor1-Factor5 age_imp gender_imp BMI_imp / link=cumlogit;
run; quit;

*macro to test the odds assumption for age/gender/BMI that has been violated in the model;
%EmpiricalLogitPlot(data=refl_bas.reflux_question1, y=classification, x=age_imp, options=DATAORDER nopanel)
%EmpiricalLogitPlot(data=refl_bas.reflux_question1, y=classification, x=gender_imp, options=DATAORDER nopanel)
%EmpiricalLogitPlot(data=refl_bas.reflux_question1, y=classification, x=BMI_imp, options=DATAORDER nopanel)
%EmpiricalLogitPlot(data=refl_bas.reflux_question1, y=classification, x=Factor1, options=DATAORDER nopanel)
%EmpiricalLogitPlot(data=refl_bas.reflux_question1, y=classification, x=Factor1, options=DATAORDER nopanel)
%EmpiricalLogitPlot(data=refl_bas.reflux_question1, y=classification, x=Factor2, options=DATAORDER nopanel)
%EmpiricalLogitPlot(data=refl_bas.reflux_question1, y=classification, x=Factor3, options=DATAORDER nopanel)
%EmpiricalLogitPlot(data=refl_bas.reflux_question1, y=classification, x=Factor4, options=DATAORDER nopanel)
%EmpiricalLogitPlot(data=refl_bas.reflux_question1, y=classification, x=Factor5, options=DATAORDER nopanel)
%EmpiricalLogitPlot(data=refl_bas.reflux_question1, y=classification, x=BC_CTQtot_imp_IT, options=DATAORDER nopanel)

*lines are parallel for all of them, therefore we can make the case that the assumption is not actually violated
and continue using the cumulative logit results;



* ------------------------------------
  Analyses based on reviewer response
--------------------------------------;

*Note: the following analyses were added following reviewer comments from our
submission to the journal Gut (February 2023). Analyses are organized by 
analysis type/reason for analysis and includes a heading;



*-----------------------
Type of Reflux Symptoms
------------------------

*subset dataset by those who had at least one symptom during reflux testing;
data work.reflux_question1_pH;
   set refl_bas.reflux_question1;
   if pH_imp_all >= 1;
run;
* 331 patients

*adding cough to atypical symptoms for 1 person where it is incorrect;
data work.reflux_question1_ph;
set work.reflux_question1_ph;
if subject = 201 then pH_imp_atypical = 59;
run;

*recode new variables for typical symptoms;
data work.Reflux_question1_pH;
set work.reflux_question1_pH;
if pH_imp_HB > 0 or pH_imp_regurg > 0 then pH_imp_typical = 1;
if pH_imp_HB = 0 and pH_imp_regurg = 0 then pH_imp_typical = 0;
run;

* frequency of typical symptoms;
proc freq data=work.Reflux_question1_pH;
tables pH_imp_typical;
run;
* 53 (16.01%)= 0 typical symptoms, 278 (83.99%) had either heartburn or regurgitation;

* frequency of heartburn symptoms;
proc freq data=work.Reflux_question1_pH;
tables pH_imp_HB;
run;
* 115 (34.74%)= 0 HB symptoms, 216 (65.26%) had heartburn;

* frequency of regurgitation symptoms;
proc freq data=work.Reflux_question1_pH;
tables pH_imp_regurg;
run;
* 142 (42.90%)= 0 regurgitation symptoms, 189 (57.09%) had regurgitation;

* recoding new variable with typical only, typical + atypical and atypical only symptoms;
data work.Reflux_question1_pH;
set work.Reflux_question1_pH;
if pH_imp_typical > 0 and pH_imp_atypical > 0 then pH_imp_coded = -1;
if pH_imp_typical > 0 and pH_imp_atypical = 0 then pH_imp_coded = 0;
if pH_imp_typical = 0 and pH_imp_atypical > 0 then pH_imp_coded = 1;
run;

* frequency of symptoms;
proc freq data=work.Reflux_question1_pH;
tables pH_imp_coded;
run;
* 182 (54.98%) both typical and atypical symptoms
* 96 (29%) typical symptoms only
* 53 (16%) had atypical symptoms only

*Omnibus Chi Square - differences by type of symptom (typical only vs. typical & atypical vs. atypical only);
proc freq data=work.Reflux_question1_pH;
table pH_imp_coded * CLASSIFICATION /chisq fisher;
run;
*278 (83.99%) w/typical symptoms, 53 (16.01%) w/atypical only
*significant differences across classification;

* recoding new variable with typical vs. atypical symptoms;
data work.Reflux_question1_pH;
set work.Reflux_question1_pH;
if pH_imp_typical > 0 and pH_imp_atypical > 0 then pH_imp_coded2group = 1;
if pH_imp_typical > 0 and pH_imp_atypical = 0 then pH_imp_coded2group = 1;
if pH_imp_typical = 0 and pH_imp_atypical > 0 then pH_imp_coded2group = 2;
run;

*Omnibus Chi Square - differences by type of symptom (typical & atypical vs. typical only);
proc freq data=work.Reflux_question1_pH;
table pH_imp_coded2group * CLASSIFICATION /chisq fisher;
run;
*278 (83.99%) w/typical symptoms, 53 (16.01%) w/atypical only
*significant differences across classification;

* recoding new variable with HB & regurg, HB only, regurg only, no HB or regurg;
data work.Reflux_question1_pH;
set work.Reflux_question1_pH;
if pH_imp_HB > 0 and pH_imp_regurg > 0 then pH_imp_HBregurg = 1;
if pH_imp_HB > 0 and pH_imp_regurg = 0 then pH_imp_HBregurg = 2;
if pH_imp_HB = 0 and pH_imp_regurg > 0 then pH_imp_HBregurg = 3;
if pH_imp_HB = 0 and pH_imp_regurg = 0 then pH_imp_HBregurg = 4;
run;

* frequency of symptoms;
proc freq data=work.Reflux_question1_pH;
tables pH_imp_HBregurg;
run;
*127 (38.37) HB & regurg 
 89 (26.89%) HB only
 62 (18.73%) regurg only
 53 (16.01%) no HB or regurg;

proc freq data=work.Reflux_question1_pH;
table pH_imp_HBregurg * CLASSIFICATION /chisq fisher;
run;

* ANOVA with Heartburn Severity;
proc glm data=refl_bas.reflux_question1;
class classification gender_imp pH_MII_ON_OFF_INF_MISS;
model BC_RQ_Acid_imp_IT  = classification  / solution p tolerance clparm;
manova h=_all_ / summary;
lsmeans classification / diff=all adjust=tukey;
run;

*-------------------------------------------------------------
Logistic Regression w/ those with information missing removed
--------------------------------------------------------------

*subset dataset by only those with PPI information;
data work.reflux_question1_PPIsubset;
   set refl_bas.reflux_question1;
   if pH_MII_ON_OFF_INF_MISS = -1 or pH_MII_ON_OFF_INF_MISS = 1;
run;
*357 patients total

*Multinomial logistic Regression with PPI missing removed;
proc logistic data=work.reflux_question1_PPIsubset plots=all order=data;
class gender_imp;
model classification = BC_CTQtot_imp_IT Factor1-Factor5 age_imp gender_imp BMI_imp / link=glogit;
run; quit;
*outcome = no differences in significant variables with missing PPI removed;

*Ordinal Logistic Regression (cumulative logit function) with PPI missing ;
proc logistic data=work.reflux_question1_PPIsubset order=internal plots=all descending;
class gender_imp;
model classification = BC_CTQtot_imp_IT Factor1-Factor5 age_imp gender_imp BMI_imp  / link=cumlogit;
run; quit;
*outcome = no differences in significant variables with missing PPI removed;


*--------------------------------------------------
Logistic Regression w/ those with PPI use added in
---------------------------------------------------

*Multinomial logistic Regression;
proc logistic data=refl_bas.reflux_question1 plots=all order=data;
class pH_MII_ON_OFF_INF_MISS gender_imp;
model classification = BC_CTQtot_imp_IT Factor1-Factor5 age_imp gender_imp BMI_imp pH_MII_ON_OFF_INF_MISS  / link=glogit;
run; quit;

*Ordinal Logistic Regression (cumulative logit function);
proc logistic data=refl_bas.reflux_question1 order=internal plots=all descending;
class pH_MII_ON_OFF_INF_MISS gender_imp;
model classification = BC_CTQtot_imp_IT Factor1-Factor5 age_imp gender_imp BMI_imp pH_MII_ON_OFF_INF_MISS / link=cumlogit;
run; quit;

*Multinomial logistic Regression (w/PPI Use interaction);
proc logistic data=refl_bas.reflux_question1 plots=all order=data;
class pH_MII_ON_OFF_INF_MISS gender_imp;
model classification = BC_CTQtot_imp_IT Factor1-Factor5 age_imp gender_imp BMI_imp pH_MII_ON_OFF_INF_MISS BC_CTQtot_imp_IT*pH_MII_ON_OFF_INF_MISS Factor1*pH_MII_ON_OFF_INF_MISS Factor2*pH_MII_ON_OFF_INF_MISS Factor3*pH_MII_ON_OFF_INF_MISS Factor4*pH_MII_ON_OFF_INF_MISS Factor5*pH_MII_ON_OFF_INF_MISS / link=glogit;
run; quit;


*-----------------------------------
ANOVA for each psych variable alone
    (mimics the Bayesian ANOVA)
------------------------------------

* ANOVA with CTQ;
proc glm data=refl_bas.reflux_question1;
class classification;
model BC_CTQtot_imp_IT = classification / solution p tolerance clparm;
manova h=_all_ / summary;
lsmeans classification / diff=all adjust=tukey;
run;
*model not significant (p = 0.9225)

* ANOVA with Factor1;
proc glm data=refl_bas.reflux_question1;
class classification;
model Factor1 = classification / solution p tolerance clparm;
manova h=_all_ / summary;
lsmeans classification / diff=all adjust=tukey;
run;
*model not significant (p = 0.6955)

* ANOVA with Factor2;
proc glm data=refl_bas.reflux_question1;
class classification;
model Factor2 = classification / solution p tolerance clparm;
manova h=_all_ / summary;
lsmeans classification / diff=all adjust=tukey;
run;
*model not significant (p = 0.0505)

* ANOVA with Factor3;
proc glm data=refl_bas.reflux_question1;
class classification;
model Factor3 = classification / solution p tolerance clparm;
manova h=_all_ / summary;
lsmeans classification / diff=all adjust=tukey;
run;
*model not significant (p = 0.3906)

* ANOVA with Factor4;
proc glm data=refl_bas.reflux_question1;
class classification;
model Factor4 = classification / solution p tolerance clparm;
manova h=_all_ / summary;
lsmeans classification / diff=all adjust=tukey;
run;
*model not significant (p = 0.8397)

* ANOVA with Factor5;
proc glm data=refl_bas.reflux_question1;
class classification;
model Factor5 = classification / solution p tolerance clparm;
manova h=_all_ / summary;
lsmeans classification / diff=all adjust=tukey;
run;
*model not significant (p = 0.3452)


*---------------------------------------
ANOVA for each psych variable w/controls
----------------------------------------

* ANOVA with CTQ;
proc glm data=refl_bas.reflux_question1;
class classification gender_imp pH_MII_ON_OFF_INF_MISS;
model BC_CTQtot_imp_IT  = classification age_imp gender_imp BMI_imp pH_MII_ON_OFF_INF_MISS / solution p tolerance clparm;
manova h=_all_ / summary;
lsmeans classification / diff=all adjust=tukey;
run;
*model not significant (p = 0.2386)

* ANOVA with Factor1;
proc glm data=refl_bas.reflux_question1;
class classification gender_imp pH_MII_ON_OFF_INF_MISS;
model Factor1  = classification age_imp gender_imp BMI_imp pH_MII_ON_OFF_INF_MISS / solution p tolerance clparm;
manova h=_all_ / summary;
lsmeans classification / diff=all adjust=tukey;
run;
*model significant (p = 0.0253), only sig variable = PPI use (p=0.0062)

* ANOVA with Factor2;
proc glm data=refl_bas.reflux_question1;
class classification gender_imp pH_MII_ON_OFF_INF_MISS;
model Factor2  = classification age_imp gender_imp BMI_imp pH_MII_ON_OFF_INF_MISS / solution p tolerance clparm;
manova h=_all_ / summary;
lsmeans classification / diff=all adjust=tukey;
run;
*model  significant (p = 0.0265), only sig variable = age (p=0.0287)

* ANOVA with Factor3;
proc glm data=refl_bas.reflux_question1;
class classification gender_imp pH_MII_ON_OFF_INF_MISS;
model Factor3  = classification age_imp gender_imp BMI_imp pH_MII_ON_OFF_INF_MISS / solution p tolerance clparm;
manova h=_all_ / summary;
lsmeans classification / diff=all adjust=tukey;
run;
*model not significant (p = 0.1436)

* ANOVA with Factor4;
proc glm data=refl_bas.reflux_question1;
class classification gender_imp pH_MII_ON_OFF_INF_MISS;
model Factor4  = classification age_imp gender_imp BMI_imp pH_MII_ON_OFF_INF_MISS / solution p tolerance clparm;
manova h=_all_ / summary;
lsmeans classification / diff=all adjust=tukey;
run;
*model not significant (p = 0.5054)

* ANOVA with Factor5;
proc glm data=refl_bas.reflux_question1;
class classification gender_imp pH_MII_ON_OFF_INF_MISS;
model Factor5  = classification age_imp gender_imp BMI_imp pH_MII_ON_OFF_INF_MISS / solution p tolerance clparm;
manova h=_all_ / summary;
lsmeans classification / diff=all adjust=tukey;
run;
*model significant (p = 0.0052), only sig variable = age (p=.0002)


*-----------------
       MANOVA
------------------;

*MANOVA with only psych variables;
proc glm data = refl_bas.reflux_question1;
  class classification;
  model BC_CTQtot_imp_IT Factor1-Factor5 = classification / SS3;
  manova h = classification;
run;
*model not significant (p=.5494)

*MANOVA with psych variables while controlling;
proc glm data = refl_bas.reflux_question1;
  class classification gender_imp pH_MII_ON_OFF_INF_MISS;
  model BC_CTQtot_imp_IT Factor1-Factor5 = classification age_imp gender_imp BMI_imp pH_MII_ON_OFF_INF_MISS / SS3;
  manova h = classification;
run;
*model not significant (p=.4058)



*-------------------------------------------------------------------
Number and proportion of missing values among variables of interest
--------------------------------------------------------------------

*import dataset that only includes variables of interest (done via deleting excess columsn in excel;
proc import
	datafile="C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\Data_files\Excel_Files\Reflux_Database_GutRevisionSubset.xlsx"
	out=work.reflux_test
	dbms=xlsx;
run;


*count missing and create new columns "nvalues" showing the # of total values and "nmiss" showing # of missing/person;
data work.reflux_test;
set work.reflux_test;
nvalues = N(of PHQ2a--JTV25);
nmiss = nmiss(of PHQ2a--JTV25);
proc print;
run;

*sum together the number of missing items across all participants;
proc sql;
    select sum(nmiss) as Sum_nmiss
    from work.reflux_test;
quit;
*5,265 missing of 134,799 (343 total items*393 participants)total items = 0.039 --> 4% missing