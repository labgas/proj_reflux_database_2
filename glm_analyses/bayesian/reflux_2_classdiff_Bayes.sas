libname refl_bas "C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\Data_files\SAS_Files\Final_Base_Datasets"; 


*----------------------------------------------------------
Bayesian Logistic Regression w/ those with PPI use added in
-----------------------------------------------------------

*Multinomial logistic Regression
*https://communities.sas.com/t5/Statistical-Procedures/Bayesian-Multinomial-Logit-Model/td-p/125935;

proc contents data=refl_bas.reflux_question1;
run;

/* Recode classification into dummy variables */
data refl_bas.reflux_question1_Bayes;
set refl_bas.reflux_question1;
class_fh = 0;
class_rh = 0;
class_bg = 0;
class_tg = 0;
if classification eq -3 then class_fh = 1;
	else if classification eq -1 then class_rh = 1;
	else if classification eq 1 then class_bg = 1;
	else if classification eq 3 then class_tg = 1;
run;


/* Proc mcmc code full model */
proc mcmc data=refl_bas.reflux_question1_Bayes nmc=200000 nbi=40000 seed=1234 thin=5 outpost=posterior stats=all plots=all diagnostics=all dic;

*data;
array y[4] class_fh class_rh class_bg class_tg;

*parms;
array p[4];
array beta0[3];
array beta1[3];
array beta2[3];
array beta3[3];
array beta4[3];
array beta5[3];
array beta6[3];
parms beta:;

*priors;
*prior beta: ~cauchy(loc=0,scale=0.5);
* cauchy prior;
prior beta: ~normal(0,var=100);
* independent normal priors;
*prior beta: ~uniform(left=-100, right=100);
* uniform priors

*linear predictor;
array eta[3];
do i = 1 to 3;
	eta[i] = beta0[i] + beta1[i] * Factor1 + beta2[i] * Factor2 + beta3[i] * Factor3 + beta4[i] * Factor4 + beta5[i] * Factor5 + beta6[i] * BC_CTQtot_imp_IT;
end;

denominator = 1 + exp(eta[1]) + exp(eta[2]) + exp(eta[3]);

*inverse logit transformation;
do i = 1 to 3;
	p[i] = exp(eta[i]) / denominator;
end;
	p[4] = 1/denominator;

*sampling model;
model y ~ multinom(p);

run;


/* Proc mcmc code factor 1 model */
proc mcmc data=refl_bas.reflux_question1_Bayes nmc=200000 nbi=40000 seed=1234 thin=5 outpost=posterior stats=all plots=all diagnostics=all dic;

*data;
array y[4] class_fh class_rh class_bg class_tg;

*parms;
array p[4];
array beta0[3];
array beta1[3];
parms beta:;

*priors;
*prior beta: ~cauchy(loc=0,scale=0.5);
* cauchy prior;
prior beta: ~normal(0,var=100);
* independent normal priors;
*prior beta: ~uniform(left=-100, right=100);
* uniform priors

*linear predictor;
array eta[3];
do i = 1 to 3;
	eta[i] = beta0[i] + beta1[i] * Factor1;
end;

denominator = 1 + exp(eta[1]) + exp(eta[2]) + exp(eta[3]);

*inverse logit transformation;
do i = 1 to 3;
	p[i] = exp(eta[i]) / denominator;
end;
	p[4] = 1/denominator;

*sampling model;
model y ~ multinom(p);

run;


/* Proc mcmc code factor 2 model */
proc mcmc data=refl_bas.reflux_question1_Bayes nmc=200000 nbi=40000 seed=1234 thin=5 outpost=posterior stats=all plots=all diagnostics=all dic;

*data;
array y[4] class_fh class_rh class_bg class_tg;

*parms;
array p[4];
array beta0[3];
array beta1[3];
parms beta:;

*priors;
*prior beta: ~cauchy(loc=0,scale=0.5);
* cauchy prior;
prior beta: ~normal(0,var=100);
* independent normal priors;
*prior beta: ~uniform(left=-100, right=100);
* uniform priors

*linear predictor;
array eta[3];
do i = 1 to 3;
	eta[i] = beta0[i] + beta1[i] * Factor2;
end;

denominator = 1 + exp(eta[1]) + exp(eta[2]) + exp(eta[3]);

*inverse logit transformation;
do i = 1 to 3;
	p[i] = exp(eta[i]) / denominator;
end;
	p[4] = 1/denominator;

*sampling model;
model y ~ multinom(p);

run;


/* Proc mcmc code factor 3 model */
proc mcmc data=refl_bas.reflux_question1_Bayes nmc=200000 nbi=40000 seed=1234 thin=5 outpost=posterior stats=all plots=all diagnostics=all dic;

*data;
array y[4] class_fh class_rh class_bg class_tg;

*parms;
array p[4];
array beta0[3];
array beta1[3];
parms beta:;

*priors;
*prior beta: ~cauchy(loc=0,scale=0.5);
* cauchy prior;
prior beta: ~normal(0,var=100);
* independent normal priors;
*prior beta: ~uniform(left=-100, right=100);
* uniform priors

*linear predictor;
array eta[3];
do i = 1 to 3;
	eta[i] = beta0[i] + beta1[i] * Factor3;
end;

denominator = 1 + exp(eta[1]) + exp(eta[2]) + exp(eta[3]);

*inverse logit transformation;
do i = 1 to 3;
	p[i] = exp(eta[i]) / denominator;
end;
	p[4] = 1/denominator;

*sampling model;
model y ~ multinom(p);

run;


/* Proc mcmc code factor 4 model */
proc mcmc data=refl_bas.reflux_question1_Bayes nmc=200000 nbi=40000 seed=1234 thin=5 outpost=posterior stats=all plots=all diagnostics=all dic;

*data;
array y[4] class_fh class_rh class_bg class_tg;

*parms;
array p[4];
array beta0[3];
array beta1[3];
parms beta:;

*priors;
*prior beta: ~cauchy(loc=0,scale=0.5);
* cauchy prior;
prior beta: ~normal(0,var=100);
* independent normal priors;
*prior beta: ~uniform(left=-100, right=100);
* uniform priors

*linear predictor;
array eta[3];
do i = 1 to 3;
	eta[i] = beta0[i] + beta1[i] * Factor4;
end;

denominator = 1 + exp(eta[1]) + exp(eta[2]) + exp(eta[3]);

*inverse logit transformation;
do i = 1 to 3;
	p[i] = exp(eta[i]) / denominator;
end;
	p[4] = 1/denominator;

*sampling model;
model y ~ multinom(p);

run;


/* Proc mcmc code factor 5 model */
proc mcmc data=refl_bas.reflux_question1_Bayes nmc=200000 nbi=40000 seed=1234 thin=5 outpost=posterior stats=all plots=all diagnostics=all dic;

*data;
array y[4] class_fh class_rh class_bg class_tg;

*parms;
array p[4];
array beta0[3];
array beta1[3];
parms beta:;

*priors;
*prior beta: ~cauchy(loc=0,scale=0.5);
* cauchy prior;
prior beta: ~normal(0,var=100);
* independent normal priors;
*prior beta: ~uniform(left=-100, right=100);
* uniform priors

*linear predictor;
array eta[3];
do i = 1 to 3;
	eta[i] = beta0[i] + beta1[i] * Factor5;
end;

denominator = 1 + exp(eta[1]) + exp(eta[2]) + exp(eta[3]);

*inverse logit transformation;
do i = 1 to 3;
	p[i] = exp(eta[i]) / denominator;
end;
	p[4] = 1/denominator;

*sampling model;
model y ~ multinom(p);

run;


/* Proc mcmc code CTQ model */
proc mcmc data=refl_bas.reflux_question1_Bayes nmc=200000 nbi=40000 seed=1234 thin=5 outpost=posterior stats=all plots=all diagnostics=all dic;

*data;
array y[4] class_fh class_rh class_bg class_tg;

*parms;
array p[4];
array beta0[3];
array beta1[3];
parms beta:;

*priors;
*prior beta: ~cauchy(loc=0,scale=0.5);
* cauchy prior;
prior beta: ~normal(0,var=100);
* independent normal priors;
*prior beta: ~uniform(left=-100, right=100);
* uniform priors

*linear predictor;
array eta[3];
do i = 1 to 3;
	eta[i] = beta0[i] + beta1[i] * BC_CTQtot_imp_IT;
end;

denominator = 1 + exp(eta[1]) + exp(eta[2]) + exp(eta[3]);

*inverse logit transformation;
do i = 1 to 3;
	p[i] = exp(eta[i]) / denominator;
end;
	p[4] = 1/denominator;

*sampling model;
model y ~ multinom(p);

run;


/* Proc mcmc code null model */
proc mcmc data=refl_bas.reflux_question1_Bayes nmc=200000 nbi=40000 seed=1234 thin=5 outpost=posterior stats=all plots=all diagnostics=all dic;

*data;
array y[4] class_fh class_rh class_bg class_tg;

*parms;
array p[4];
array beta0[3];
parms beta:;

*priors;
*prior beta: ~cauchy(loc=0,scale=0.5);
* cauchy prior;
prior beta: ~normal(0,var=100);
* independent normal priors;
*prior beta: ~uniform(left=-100, right=100);
* uniform priors

*linear predictor;
array eta[3];
do i = 1 to 3;
	eta[i] = beta0[i];
end;

denominator = 1 + exp(eta[1]) + exp(eta[2]) + exp(eta[3]);

*inverse logit transformation;
do i = 1 to 3;
	p[i] = exp(eta[i]) / denominator;
end;
	p[4] = 1/denominator;

*sampling model;
model y ~ multinom(p);

run;
