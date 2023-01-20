/*                          INSTRUCTIONS FOR USE 

   Version 1.1 or higher of the CtoN macro is required by the EmpiricalLogitPlot 
   macro and must be defined before using the EmpiricalLogitPlot macro. Download
   it from this location: http://support.sas.com/kb/60678 and see the Downloads 
   tab at that link. The code defining the CtoN macro and the code defining the 
   macros below must all be submitted in your SAS session to make the macros
   available for use in that SAS Session. Do not alter any of the macro code
   to ensure successful macro execution. After running the macro code, check
   your SAS log to verify that no errors were generated. 
*******************************************************************************/

%macro EmpiricalLogitPlot(version, data=, y=, x=, const=0.5, neighbors=50,
       smooth=.3, contcutoff=20, options=DESCENDING PANEL) / minoperator; 
/*--------------------------------------------------------------------------
  A macro extension of SAS Usage Note 37944 for both class and continuous
  covariates. Calls the OneContPlot macro to plot the empirical logits defined 
  using the NEIGHBORS/2 observed covariate values preceding and following each 
  observation against the levels of a covariate with more than CONTCUTOFF 
  levels. Calls the OneClassPlot macro to plot the empirical logits computed 
  within each level of a covariate with fewer than CONTCUTOFF levels.
  
  version  Optional. Any text immediately following the open parenthesis and 
           followed by a comma will display the macro version.
  data=    name of the input data set. Required.
  y=       name of the response variable. Required.
  x=       space-separated list of predictor variables. Required.
  const=   small value between 0 and 1 to prevent zero counts. Default: 0.5.
  neighbors= number of neighbors around each observation used to compute 
           logits for continuous effects. Default: Average population size but
           at least 1% of the sample size with a minimum of 2.
  smooth=  smoothing parameter used for loess curve fit to logits for 
           continuous effects. Default: 0.3.
  contcutoff= if an x= variable has more than the specified number of levels
           then logits are computed within sets of neighboring observations; 
           otherwise computed within each level of the variable. Default: 20.
  options= DESCENDING (high response levels are of interest), ASCENDING (low 
           response levels are of interest), DATAORDER (use for character 
           response after sorting data so that first occurrence of each level 
           is in logically ascending or descending order as desired with the
           first levels are of interest). Specify only one of DESCENDING, 
           ASCENDING, or DATAORDER. PANEL (single panel of all predictor 
           plots), NOPANEL (separate plot for each predictor). Default:
           DESCENDING PANEL.
  --------------------------------------------------------------------------*/ 

%macro existchk(data=, var=, dmsg=e, vmsg=e);
   %global status; %let status=ok;
   %if &dmsg=e %then %let dmsg=ERROR;
   %else %if &dmsg=w %then %let dmsg=WARNING;
   %else %let dmsg=NOTE;
   %if &vmsg=e %then %let vmsg=ERROR;
   %else %if &vmsg=w %then %let vmsg=WARNING;
   %else %let vmsg=NOTE;
   %if %quote(&data) ne %then %do;
     %if %sysfunc(exist(&data)) ne 1 %then %do;
       %put &dmsg: Data set %upcase(&data) not found.;
       %let status=nodata;
     %end;
     %else %if &var ne %then %do;
       %let dsid=%sysfunc(open(&data));
       %if &dsid %then %do;
         %let i=1;
         %do %while (%scan(&var,&i) ne %str() );
            %let var&i=%scan(&var,&i);
            %if %sysfunc(varnum(&dsid,&&var&i))=0 %then %do;
              %put &vmsg: Variable %upcase(&&var&i) not found in data %upcase(&data).;
              %let status=novar;
            %end;
            %let i=%eval(&i+1);
         %end;
         %let rc=%sysfunc(close(&dsid));
       %end;
       %else %put ERROR: Could not open data set &data.;
     %end;
   %end;
   %else %do;
     %put &dmsg: Data set not specified.;
     %let status=nodata;
   %end;   
%mend;

%let elptime = %sysfunc(datetime());
%let _version=1.2;
%if &version ne %then %put NOTE: &sysmacroname macro Version &_version;
%let _elpopts = %sysfunc(getoption(notes));
%let version=%upcase(&version);
%if %index(&version,DEBUG) %then %do;
  options notes mprint
    %if %index(&version,DEBUG2) %then mlogic symbolgen;
  ;  
  ods select all;
  %put _user_;
%end;
%else %do;
  options nonotes nomprint nomlogic nosymbolgen;
  ods exclude all;
%end;

/* Check for newer version */
%if %index(&version,NOCHECK)=0 %then %do;
   %let _notfound=0; %let _newver=0;
   filename _ver url 'http://ftp.sas.com/techsup/download/stat/versions.dat' 
            termstr=crlf;
   data _null_;
     infile _ver end=_eof;
     input name:$18. ver;
     if upcase(name)="&sysmacroname" then do;
       call symput("_newver",ver); stop;
     end;
     if _eof then call symput("_notfound",1);
     run;
   options notes;
   %if &syserr ne 0 or &_notfound=1 or &_newver=0 %then
     %put NOTE: Unable to check for newer version of &sysmacroname macro.;
   %else %if %sysevalf(&_newver > &_version) %then %do;
     %put NOTE: A newer version of the &sysmacroname macro is available at;
     %put NOTE- this location: http://support.sas.com/ ;
   %end;
   %if %index(%upcase(&version),DEBUG)=0 %then options nonotes;;
%end;

/* Input checks and process options */
%if %index(&y,/) %then %do;
  %put ERROR: Events/Trials syntax is not supported in Y=.;
  %goto exit;
%end;

%existchk(data=&data, var=&y &x);
%if &status=nodata or &status=novar %then %goto exit;

%if %quote(&y)= %then %do;
  %put ERROR: Y= is required.;
  %goto exit;
%end;

%if &x= %then %do;
  %put ERROR: One or more variables must be specified in X=.;
  %goto exit;
%end;

%if %sysevalf(&neighbors ne) %then %do;
  %if %sysevalf(%sysfunc(mod(&neighbors,1)) ne 0 or &neighbors<=0) %then %do;
    %put ERROR: NEIGHBORS= must be an integer value greater than zero.;
    %goto exit;
  %end;
%end;
%else %let neighbors=50;
%let nbhd=&neighbors;

%if %sysevalf(&contcutoff ne) %then %do;
  %if %sysevalf(%sysfunc(mod(&contcutoff,1)) ne 0 or &contcutoff<=0) %then %do;
    %let contcutoff=%sysfunc(ceil(%sysfunc(abs(&contcutoff))));
    %if %index(&version,DEBUG)=0 %then options notes;;
    %put NOTE: CONTCUTOFF= value must be a positive integer.;
    %put NOTE- CONTCUTOFF= set to &contcutoff;
    %if %index(&version,DEBUG)=0 %then options nonotes;;
  %end;
%end;
%else %let contcutoff=20;

%if %quote(&const) ne %then %do;
  %if (%sysfunc(verify(%sysfunc(catx( ,&const)),'0123456789.'))>0) + 
      (%sysfunc(count(&const,.))>1) %then %do;
    %put ERROR: The CONST= value must be a positive value less than 1.;
    %goto exit;
  %end;
  %else %if &const<0 or &const>=1 %then %do;
    %put ERROR: The CONST= value must be a positive value less than 1.;
    %goto exit;
  %end;
%end;
%else %do;
  %put ERROR: CONST= is required and must be a positive value less than 1.;
  %goto exit;
%end;

%if %quote(&smooth) ne %then %do;
  %if (%sysfunc(verify(%sysfunc(catx( ,&smooth)),'0123456789.'))>0) + 
      (%sysfunc(count(&smooth,.))>1) %then %do;
    %put ERROR: The SMOOTH= value must be a positive value.;
    %goto exit;
  %end;
  %else %if %sysevalf(&smooth<=0) %then %do;
    %put ERROR: The SMOOTH= value must be greater than zero.;
    %goto exit;
  %end;
%end;
%else %do;
  %put ERROR: SMOOTH= is required and must be positive value.;
  %goto exit;
%end;

%let validopts=ASCENDING DESCENDING DATAORDER PANEL NOPANEL;
%let panel=1; %let plot=0; %let hievent=1; %let dataorder=0;
%let i=1;
%do %while (%scan(&options,&i) ne %str() );
   %let option&i=%upcase(%scan(&options,&i));
   %if &&option&i=DATAORDER %then %do; 
      %let dataorder=1; %let hievent=0; 
   %end;
   %else %if &&option&i=ASCENDING %then %let hievent=0;
   %else %if &&option&i=NOPANEL %then %do; %let panel=0; %let plot=1; %end;
   %else %do;
    %let chk=%eval(&&option&i in &validopts);
    %if not &chk %then %do;
      %put ERROR: Valid values of OPTIONS= are &validopts..;
      %goto exit;
    %end;
   %end;
   %let i=%eval(&i+1);
%end;

%if %index(&version,DEBUG)=0 %then options notes;;
%put NOTE: Logits are computed over lower Ordered Values of &y..;
%if %index(&version,DEBUG)=0 %then options nonotes;;

proc sql; 
  select count(*) into :n from &data where &y is not missing; 
  quit;
ods graphics / loessmaxobs=%sysfunc(max(5000,%eval(&n+1000)));
data _tempdata;  
   set &data;
   run;

/* Order y= variable as requested */
%if &dataorder=0 %then %do;
   proc sort data=_tempdata;
     by %if &hievent %then descending; &y;
     run;
%end;
%let chary=0; %let yname=&y;
%let dsid=%sysfunc(open(_tempdata));
%if &dsid %then %do;
  %let varnum=%sysfunc(varnum(&dsid,&y));
  %if %sysfunc(vartype(&dsid,&varnum))=C %then %do;
    %let rc=%sysfunc(close(&dsid));
    %CtoN(&version,data=_tempdata,var=&y,out=_tempdata,order=data,
          options=noreplace noformat nodatanote nonewcheck)
    data _tempdata; set _tempdata(rename=(&y=_chary)); 
      label _chary='00'x;
      run;
    %let y=&y._N; %let chary=1;
  %end;
%let rc=%sysfunc(close(&dsid));
%end;
proc freq nlevels data=_tempdata 
  %if &hievent or &dataorder %then order=data;
;
   where not missing(&y);
   table &y %if &chary %then * _chary; / out=_ylevs noprint;
   ods exclude nlevels;
   ods output nlevels=_numy;
   run;
data _null_; 
   set _numy;
   call symputx('numy',nlevels);
   run;
%if &chary=0 %then %do;
 data _null_;
   set _ylevs nobs=nlev;
   call symputx(cats('l',_n_),&y);
   run;
 data _tempdata; 
   set _tempdata;
   select (&y);
     %do i=1 %to &numy;
       when (&&l&i) &y = &i;
     %end;
     otherwise &y = .;
   end;
   run;
%end;
%if &numy=2 %then %let lgtlabl=Logit; 
%else %let lgtlabl=CLogit;

/* Variables with > 50 levels will use neighborhood method to compute logits.
   Variables with <=50 levels will have logits computed within each level.
*/
%let cont=; %let class=;
proc freq data=_tempdata nlevels;
  table &x / noprint; 
  ods exclude nlevels;
  ods output nlevels=_nx;
  run;
data _null_; 
  set _nx; 
  call symputx(cats('nlev',_n_),nnonmisslevels); 
  run;
%let i=1;
%let dsid=%sysfunc(open(_tempdata));
%if &dsid %then %do %while (%scan(&x,&i) ne %str() );
  %let varnum=%sysfunc(varnum(&dsid,%scan(%upcase(&x),&i)));
  %if %sysfunc(vartype(&dsid,&varnum))=N and &&nlev&i>20 %then 
    %let cont=&cont %scan(&x,&i);
    %else %let class=&class %scan(&x,&i);
  %let i=%eval(&i+1);
%end;
%let rc=%sysfunc(close(&dsid));

ods select all;
%let num=1; 
%let numc=0; 
%let numd=0; 
%let totnum=1; 
%let doClass=1; 
%let numym1=%eval(&numy-1); 
%let var=%scan(&class,&num);                                  
%if (&var=) %then %do; 
   %let doClass=0; 
   %let var=%scan(&cont,&num);                                  
   %if (&var=) %then %goto stopit;  
%end;                                
data _ylevs;
  set _ylevs;
  ov=_n_;
  run;
proc print data=_ylevs label noobs split="/";
  %if &chary=0 %then %do;
    id ov; var &y; label ov="Ordered/Value/(O.V.)"; 
  %end;
  %else %do;
    id &y; var _chary; label &y="Ordered/Value/(O.V.)" _chary="&yname";
  %end;
  title "Response Profile";
  title2 "Logits are computed over the lower Ordered Values";
  run;
title;
%do %while(&var ne);                                             
   data _tempa(keep=&y &var);                                                          
      set _tempdata; 
      run;
   %if %eval(&doClass eq 1) %then %do; 
      %OneClassPlot(data=_tempa,x=&var,y=&y,numy=&numy,const=&const,plot=&plot); 
      %let numc= %eval(&numc+1); 
      data _tempc; 
         set %if %eval(&numc ne 1) %then _tempc; _temp2; 
         run; 
   %end; 
   %else %do; 
      %OneContPlot(data=_tempa,x=&var,y=&y,numy=&numy,const=&const,plot=&plot,
                   nbhd=&nbhd); 
      %let numd= %eval(&numd+1); 
      data _tempd; 
         set %if %eval(&numd ne 1) %then _tempd; _temp2; 
         run; 
   %end; 
   %let num=%eval(&num+1); 
   %let totnum=%eval(&totnum+1);; 
   %if %eval(&doClass eq 1) %then %do;                                          
      %let var=%scan(&class,&num); 
      %if (&var=) %then %do; 
          %let doClass=0; 
          %let num=1; 
      %end;
   %end; 
   %if %eval(&doClass eq 0) %then %do;            
      %let var=%scan(&cont,&num); 
      %if (&var=) %then %goto stopit; 
   %end;
%end;

%stopit: ; 
%if &panel %then %do;
   %if %eval(&numc>0) %then %do;
      proc sort data=_tempc; 
         by _group _x;
         run;
   %end;
   %if %eval(&numd>0) %then %do;
      proc sort data=_tempd; 
         by _group _x;
         run;
   %end;
   %if %eval(&numc>0 and &numd>0) %then %do;
      data _tempall;
         merge _tempd _tempc;
         by _group _x;
         run;
   %end;
   %else %if %eval(&numc>0) %then %do;
      data _tempall;
         set _tempc;
         run;
   %end;
   %else %do;
      data _tempall;
         set _tempd;
         run;
   %end;
   proc sort data=_tempall;  
      by _group; 
      run;
   data _tempa(keep=_group _minx _maxx);  
      set _tempall;  
      by _group;  
      retain _minx 1e100 _maxx -1e100; 
      if first._group then do;  
         _minx=_x;  
         _maxx=_x;  
      end; 
      _minx=min(_minx,_x);  
      _maxx=max(_maxx,_x); 
      if last._group then output;  
      run;
   data _tempall;  
      merge _tempall _tempa;  
      by _group;  
      _x=(_x-_minx)/(_maxx-_minx);  
      run;
   %if       ((&totnum-1)=1)   %then %do; %let rows=1; %let cols=1; %end;    
   %else %if ((&totnum-1)=2)   %then %do; %let rows=1; %let cols=2; %end;    
   %else %if ((&totnum-1)=3)   %then %do; %let rows=1; %let cols=3; %end;    
   %else %if ((&totnum-1)=4)   %then %do; %let rows=2; %let cols=2; %end;    
   %else %if ((&totnum-1)<=6)  %then %do; %let rows=2; %let cols=3; %end;    
   %else %if ((&totnum-1)<=9)  %then %do; %let rows=3; %let cols=3; %end;    
   %else %if ((&totnum-1)<=12) %then %do; %let rows=3; %let cols=4; %end;    
   %else %do; %let cols=4; %let rows=4;  %end;    
   proc sgpanel data=_tempall;                                           
      panelby _group / novarname columns=&cols rows=&rows 
                       uniscale=all skipemptycells;      
      rowaxis label=
         %if &numy>2 %then "Empirical Cumulative Logits";
         %else "Empirical Logit";
      ; 
      colaxis display=(nolabel noticks novalues);                     
      %if (&numd>0) %then %do i=1 %to &numym1; 
      loess y=d&i x=_x / smooth=&smooth legendlabel="&lgtlabl(O.V.<=&i)" 
            name="series&i" lineattrs=GraphData&i(thickness=3px) 
            markerattrs=GraphDataDefault(color=gray) nomarkers
      ; 
      %end; 
      %if (&numc>0) %then %do i=1 %to &numym1; 
      series y=c&i x=_x / legendlabel="&lgtlabl(O.V.<=&i)" name="series&i" 
             lineattrs=GraphData&i(thickness=3px); 
      %end;
      %if &numd %then inset neighbors / position=bottom;;
      keylegend %do i=1 %to &numym1; "series&i" %end;; 
      %if &numy>2 %then %str(title "Empirical Cumulative Logits";);
      %else %str(title "Empirical Logit";);
      %if &numd %then
      title2 "Smoothing parameter = &smooth for continuous predictors";;
      run;  
%end;

%exit:
%if %index(&version,DEBUG)=0 %then %do;
   proc datasets nolist; 
      delete _: ;
      run; quit;
%end;
%if %index(&version,DEBUG) %then %do;
  options nomprint nomlogic nosymbolgen;
  %put _user_;
%end;
options &_elpopts;
title;
%let elptime=%sysfunc(round(%sysevalf(%sysfunc(datetime()) - &elptime), 0.01));
%put NOTE: The &sysmacroname macro used &elptime seconds.;
%mend;                  

%macro OneClassPlot(data=,x=,y=,numy=,const=0.5,plot=1); 
/*-------------------------------------------------------------------------- 
  A macro version of SAS Usage Note 37944 for covariates with fewer than 
  CONTCUTOFF levels. Computes and/or plots the empirical logits of Y against 
  the levels of one X variable.  Called by the EmpiricalLogitPlot macro.

  data=    name of the input data set. 
  x=       name of the single CLASS covariate. 
  y=       name of the response variable.   
  numy=    number of levels of the response. 
  const=   small value in case of zero cells. 
  plot=    1=create the plot, 0=create data set only
  --------------------------------------------------------------------------*/ 
%let numym1=%eval(&numy-1);
%let zerosum=0;
proc freq data=&data noprint; 
   table &x*&y / sparse out=_temp2; 
run;
proc sort data=_temp2;                                                       
   by &x;  
run;
%let dsid=%sysfunc(open(_temp2));
%if &dsid %then %do;
  %let varnum=%sysfunc(varnum(&dsid,&x));
  %if %sysfunc(vartype(&dsid,&varnum))=C %then %do;
    %let rc=%sysfunc(close(&dsid));
    %CtoN(&version,data=_temp2,var=&x,out=_temp2,options=format nodatanote nonewcheck)
  %end;
  %let rc=%sysfunc(close(&dsid));
%end;
proc transpose data=_temp2 out=_temp; 
   by &x;  
   var count; 
   run;
data _temp2 ;  
   set _temp; 
   length _group $ 32;                                           
   if (_NAME_='COUNT');                                          
   _group="&x"; 
   _x=&x;         
   _const=%sysevalf(&const+0); 
   %do i=1 %to &numym1; %let j=%eval(&i+1); 
      _numsum=sum(of col1-col&i); _densum=sum(of col&j-col&numy);
      %if &const=0 %then %do;
        _const=0;
        if _numsum=0 or _densum=0 then do;
          _const=0.5; call symputx('zerosum',1);
        end;
      %end;
      c&i=log((_numsum + _const) / (_densum + _const)); 
   %end; 
   keep c1-c&numym1 _group _x &x;
   run; 
%if &zerosum %then %do;
  %if %index(&version,DEBUG)=0 %then options notes;;
  %put NOTE: Zero sum detected for &x.. CONST=0.5 used in affected logits.;
  %if %index(&version,DEBUG)=0 %then options nonotes;;
  %end;
%if &plot %then %do; 
   proc sgplot; 
      %do i=1 %to &numym1;  
      series y=c&i x=&x /
             legendlabel="&lgtlabl(O.V.<=&i)" name="series&i" 
             lineattrs=GraphData&i(thickness=3px);   
      %end; 
      yaxis label=
         %if &numy>2 %then "Empirical Cumulative Logits";
         %else "Empirical Logit";
      ; 
      xaxis label="&x";
      xaxis integer label="&x"; 
      keylegend %do i=1 %to &numym1; "series&i" %end;; 
      %if &numy>2 %then %str(title "Empirical Cumulative Logits";);
      %else %str(title "Empirical Logit";);
      title2;
      run; 
%end; 
%mend; 

%macro OneContPlot(data=,x=,y=,numy=,const=0.5,smooth=.3,plot=1,nbhd=); 
/*--------------------------------------------------------------------------
  A macro extension of SAS Usage Note 37944 for continuous covariates. Computes
  and/or plots the empirical logits defined using the NBHD/2 observed X values 
  preceding and following each observation against the levels of a single 
  continuous X variable, then smooths the result. Called by the 
  EmpiricalLogitPlot macro.

  data=    name of the input data set. 
  x=       name of the single continuous covariate. 
  y=       name of the response variable. y=1,2,3... 
  numy=    number of levels of the response. 
  const=   small value in case of zero cells. 
  nbhd=    total number of neighbors. 
  smooth=  smoothing parameter used for loess curve fit to logits for 
           continuous effects. Default: 0.3.
  plot=    1=create the plot, 0=create data set only
  --------------------------------------------------------------------------*/ 
%let zerosum=0; %let nbhderr=0;
data _temp;  
   set &data;
   run;
proc sort data=_temp;  
   by &x &y; 
   run;
proc sql noprint; 
  select count(*) into :nyx from &data 
  where &y is not missing and &x is not missing; 
  quit;
data _null_;
  set _nx;
  maxnbhd=max(ceil(sqrt(&nyx)),ceil(.01*&nyx));
  if &nbhd>maxnbhd then call symputx("nbhderr",maxnbhd);
  run;  
%if &nbhderr %then %do;
  %if %index(&version,DEBUG)=0 %then options notes;;
  %put NOTE: NEIGHBORS=&nbhd decreased to &nbhderr for X=&x..;
  %if %index(&version,DEBUG)=0 %then options nonotes;;
  %let nbhd=&nbhderr; %let neighbors=&nbhd;
  %end;
%let Full=%eval(&nbhd); 
%let Fullp1=%eval(&nbhd+1); 
%let Half=%eval(&nbhd/2); 
%let numym1=%eval(&numy-1); 
data _temp2;  
   set _temp; 
   retain %do i=1 %to &numy; _sum&i %end; 0; 
   _lagx=lag&Full(&x);  
   _lagHalfx=lag&Half(&x);  
   _lagy=lag&Fullp1(&y); 
   %do i=1 %to &numy; _sum&i=_sum&i+(&y=&i); %end; 
   if (_lagy^=.) then do; 
      %do i=1 %to &numy; _sum&i=_sum&i-(_lagy=&i); %end; 
   end; 
   run; 
data _temp; 
   set _temp2;  
   if (_n_<&Full) then delete; 
   run; 
data _temp2;  
   set _temp; 
   length _group $ 32;
   _const=%sysevalf(&const+0); 
   _x=_lagHalfx; 
   _group="&x"; 
   %do i=1 %to &numym1; %let j=%eval(&i+1); 
      _numsum=sum(of _sum1-_sum&i); _densum=sum(of _sum&j-_sum&numy);
      %if &const=0 %then %do;
        _const=0;
        if _numsum=0 or _densum=0 then do;
          _const=0.5; call symputx('zerosum',1);
        end;
      %end;
     d&i=log((_numsum + _const) / (_densum + _const)); 
   %end; 
   Neighbors=&nbhd;
   keep d1-d&numym1 _group _x neighbors;
   run; 
%if &zerosum %then %do;
  %if %index(&version,DEBUG)=0 %then options notes;;
  %put NOTE: Zero sum detected for &x.. CONST=0.5 used in affected logits.;
  %if %index(&version,DEBUG)=0 %then options nonotes;;
  %end;
%if &plot %then %do; 
   proc sgplot; 
      %do i=1 %to &numym1;  
      loess y=d&i x=_x /
            smooth=&smooth legendlabel="&lgtlabl(O.V.<=&i)" 
            lineattrs=GraphData&i(thickness=3px) 
            markerattrs=(color=gray) name="series&i" nomarkers
      ; 
      %end; 
      yaxis label=
         %if &numy>2 %then "Empirical Cumulative Logits";
         %else "Empirical Logit";
      ;
      xaxis label="&x";
      keylegend %do i=1 %to &numym1; "series&i" %end;;    
      %if &numy>2 %then %str(title "Empirical Cumulative Logits";);
      %else %str(title "Empirical Logit";);
      title2 "with &nbhd neighbors and smoothing parameter = &smooth";
      run; 
%end; 
%mend; 
