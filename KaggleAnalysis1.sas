libname training '/folders/myfolders/sasuser.v94'; /*Jason Lin way of pulling data*/

/* data training.train; */
/* set train; */
/* run; */
/*  */
/* data training.test; */
/* set test; */
/* run; */

proc means data=training.train;
run;

data analysis1;
set training.train; /*Update this for your imported data set*/
NAmes = 0;
Edwards = 0;
BrkSide = 0;
if Neighborhood = "NAmes" then NAmes = 1;
if Neighborhood = "Edwards" then Edwards = 1;
if Neighborhood = "BrkSide" then BrkSide =1;
GrLIvArea_per100 = GrLIvArea / 100;
NAmes_GRLIvArea = NAmes * GrLIvArea_per100;
Edwards_GRLIvArea = Edwards * GrLIvArea_per100;
BrkSide_GRLIvArea = BrkSide * GrLIvArea_per100;
log_saleprice = log(SalePrice);
log_GrLIvArea_per100 = log(GrLIvArea_per100);
logNAmes_GRLIvArea = NAmes * log_GrLIvArea_per100;
logEdwards_GRLIvArea = Edwards * log_GrLIvArea_per100;
logBrkSide_GRLIvArea = BrkSide * log_GrLIvArea_per100;
run;

data analysis2;
set analysis1;
if Neighborhood in ("NAmes" "Edwards" "BrkSide" );
if id in(1299 524) then delete;
run;

proc sgscatter data=analysis1;
matrix SalePrice log_saleprice NAmes Edwards BrkSide GrLIvArea_per100 log_GrLIvArea_per100;
run;
proc sgscatter data=analysis1;
matrix SalePrice log_saleprice GrLIvArea_per100 log_GrLIvArea_per100;
run;
proc means data=analysis1 ;
var NAmes Edwards BrkSide GrLIvArea GrLIvArea_per100 saleprice;
run;

proc sgscatter data=analysis2;
matrix SalePrice log_saleprice NAmes Edwards BrkSide GrLIvArea_per100 log_GrLIvArea_per100;
run;
proc sgscatter data=analysis2;
matrix SalePrice log_saleprice GrLIvArea_per100 log_GrLIvArea_per100;
run;
proc means data=analysis2 ;
var NAmes Edwards BrkSide GrLIvArea GrLIvArea_per100 saleprice;
run;


proc reg data=analysis2 ;
model saleprice = Edwards BrkSide GrLIvArea_per100 Edwards_GRLIvArea BrkSide_GRLIvArea ;
output out = test2 cookd=cooks;
run;

proc reg data=analysis1;
model saleprice = NAmes Edwards BrkSide GrLIvArea_per100 NAmes_GRLIvArea Edwards_GRLIvArea BrkSide_GRLIvArea ;
run;
proc reg data=analysis1;
model log_saleprice = NAmes Edwards BrkSide log_GrLIvArea_per100 logNAmes_GRLIvArea logEdwards_GRLIvArea 
logBrkSide_GRLIvArea ;
run;
proc reg data=analysis1;
model log_saleprice = NAmes Edwards BrkSide GrLIvArea_per100 NAmes_GRLIvArea Edwards_GRLIvArea BrkSide_GRLIvArea ;
run;
proc reg data=analysis1;
model saleprice = NAmes Edwards BrkSide log_GrLIvArea_per100 logNAmes_GRLIvArea logEdwards_GRLIvArea 
logBrkSide_GRLIvArea ;
run;




/****************************************************************************************/;
/* libname training '/folders/myfolders/sasuser.v94'; */
/*  */
/*  */
/* data kaggle; */
/* set training.train; */
/* if LotFrontage ne "NA" then LotFrontage_clean = input(lotfrontage,3.); */
/* if GarageYrBlt = . then GarageYrBlt = YearBuilt; */
/* drop LotFrontage; */
/* run; */
/*  */
/* proc stdize data=kaggle out=kaggle_clean method=median missing=median reponly; */
/* var LotFrontage_clean MasVnrArea; */
/* run; */
/*  */
/* proc contents data=kaggle_clean out=contents; */
/* run; */
/*  */
/* proc sql; */
/* select name into: variables separated by " " from contents where format ="$"; */
/* quit; */
/* proc sql; */
/* select name into: numerical separated by " " from contents where (format ne"$" and name ne "Id"); */
/* quit; */
/* proc sql; */
/* select name into: modelvariables separated by " " from contents where (name ne "Id" and name ne "SalePrice"); */
/* quit; */
/* options mlogic symbolgen; */
/*  */
/* %put &variables; */
/*  */
/*  */
/* proc freq data=kaggle_clean; */
/* table &variables; */
/* run; */
/* proc means data=kaggle_clean  n nmiss mean median std; */
/* var &numerical; */
/* run; */
/*  */
/* proc glmselect data=kaggle_clean; */
/* class &variables; */
/* model SalePrice = &modelvariables / selection=forward(stop=CV) cvmethod=random(5) */
/* stats=adjrsq; */
/* run; */
/* proc glmselect data=kaggle_clean; */
/* class &variables; */
/* model SalePrice = &modelvariables / selection=backward(stop=CV) cvmethod=random(5) */
/* stats=adjrsq; */
/* run; */
/* proc glmselect data=kaggle_clean; */
/* class &variables; */
/* model SalePrice = &modelvariables / selection=stepwise(stop=CV) cvmethod=random(5) */
/* stats=adjrsq; */
/* run; */

