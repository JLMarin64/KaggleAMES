PROC IMPORT OUT= WORK.train 
            DATAFILE= "/home/marinfamily1010/sasuser.v94/Data/train.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;


data work.train1;
set work.train;
rename '1stFlrSF'n = FirstFlrSF '2ndFlrSF'n = SecondFlrSF '3SsnPorch'n = ThreesnPorch;
run;



options mlogic symbolgen; /**********Options are used to help see the & stuff*************/;

/*******Dealt with missing years for GarageYrBlt and also Converted LotFrontage to Numeric*******************/;
data kaggle;
set work.train1;/*Update to your imported data set*/
if LotFrontage ne "NA" then LotFrontage_clean = input(lotfrontage,8.);
if GarageYrBlt = . then GarageYrBlt = YearBuilt;
drop LotFrontage;
run;

/********This code replaces the missing data for LotFrontage_clean and MasVnrArea with the Median
Value**********************/
proc stdize data=kaggle out=kaggle_clean method=median missing=median reponly;
var LotFrontage_clean MasVnrArea;
run;


/********************A way to check for missing data*************************/;
proc contents data=kaggle_clean out=contents;
run;

/*************Pulls all the variables names that are categorical*****************/;
proc sql;
select name into: variables separated by " " from contents where format ="$";
quit;

/**************Pulls all the variable names that are numerical*****************/;
proc sql;
select name into: numerical separated by " " from contents where (format ne"$" and name ne "Id");
quit;
/**********************Pulls all variable names except ID and SalePrice*************/;
proc sql;
select name into: modelvariables separated by " " from contents where (name ne "Id" and name ne "SalePrice");
quit;



%put &variables;
/*************Raw Data Set**************************************/;


/*******************Looks at the Frequency count for categorical Variables***************/;
proc freq data=kaggle;
table &variables;
run;
/*******************Looks at some of the summary numbers for the numerical variables**********/;
proc means data=kaggle  n nmiss mean median std;
var &numerical;
run;

/********************Cleaned Data Set***************************/;
/*******Follows the same as above for check*********************/;
proc freq data=kaggle_clean;
table &variables;
run;

proc means data=kaggle_clean  n nmiss mean median std;
var &numerical;
run;

/**************The forward, backward, and stepwise selection*******************/;
proc glmselect data=kaggle_clean;
class &variables;
model SalePrice = &modelvariables / selection=forward(stop=CV) cvmethod=random(5) select = sl slentry = .1 
stats=adjrsq;
run;

proc glmselect data=kaggle_clean  ;
class &variables;
model SalePrice = &modelvariables / selection=backward(stop=CV) cvmethod=random(5) select = sl slstay = .1 stb showpvalues
stats=adjrsq;
run;

proc glmselect data=kaggle_clean;
class &variables;
model SalePrice = &modelvariables / selection=stepwise(stop=CV) cvmethod=random(5) select = sl slentry = .1 stb showpvalues
stats=adjrsq;
run;


proc glmselect data=kaggle_clean  ;
class &variables;
model SalePrice = BedroomAbvGr BsmtFinSF1 BsmtFinSF2 BsmtFullBath BsmtUnfSF Fireplaces FirstFlrSF FullBath GarageArea GarageCars GrLivArea KitchenAbvGr LotArea LotFrontage_clean LowQualFinSF MSSubClass MasVnrArea MoSold OverallCond OverallQual PoolArea ScreenPorch ThreesnPorch TotRmsAbvGrd WoodDeckSF YearBuilt YearRemodAdd YrSold  / selection=backward(stop=CV) cvmethod=random(5) select = sl slstay = .01 stb showpvalues
stats=adjrsq;
output out = slim;
run;





