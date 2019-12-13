
/*WORK AROUND NOTES:
for checking data and extreme results in the Un-adjusted population
data Extrem_Ori;
set UnAdj_YT3;
where PRJ_VOL_DWB>=2200;based on the random VRI, NFI AND CMI DATA, IT IS SET AS A THRESHOLD
run;
*/

/*WORK AROUND NOTES:
for checking abnormal results due to the backgrow functions
data Abnorm_UnAdj;
set UnAdj_YT3;
where PRJ_TOTAL_AGE in (50,60, 70,80,90,100, 110) ;
keep FEATURE_ID PRJ_VOL_DWB PRJ_TOTAL_AGE;
run;
proc transpose data =Abnorm_UnAdj  out =Abnorm_UnAdj2 (drop = _name_)
  prefix =Vol;    VAR PRJ_VOL_DWB;   by FEATURE_ID;  run;
data Abnorm_UnAdj3;
set  Abnorm_UnAdj2;
where Vol1-Vol2>20 or Vol2-Vol3>20  or Vol3-Vol4>20  or Vol4-Vol5>20
 or Vol5-Vol6>20  or Vol6-Vol7>20;run;
*/


/*WORK AROUND NOTES:
for later assign average yield curve purpose, both the extreme volume and the
abnormality stands
data Extrem_Ori1;
set  Extrem_Ori
  DKL.Abnorm_UnAdj4;

  proc sort; by FEATURE_ID ;  run;
data Extrem_Ori2;
set  Extrem_Ori1;
if first.FEATURE_ID;by FEATURE_ID ; keep FEATURE_ID Strata; run;
*/

/*WORK AROUND NOTES:
for assigning average yield curve purpose, both the extreme volume and the abnormality stands
THIS WAY WORKED
proc sql;
 create table Extrem_Ori6 as
 select * 
 from Extrem_Ori4 left join Extrem_Ori2
 on Extrem_Ori4.Strata=Extrem_Ori2.Strata;
quit;
*/

/*WORK AROUND NOTES:
Dec.15, 2018
Since some issues were found in Haida Gwaii(assigned YT maximum volume is <250 m3/ha) for the following
approach, this new MAI approach is going to be applied temporary for now until the BACKGROW
issue will be solved

for estimating the volum at  reference year for later use
	 
data V7_Step1_YT1_Ref;
set  V7_Step1_YT1;

if PRJ_MODE="Ref";

 array miss_to_zero(12) PRJ_PCNT_STOCK  PRJ_SITE_INDEX  PRJ_DOM_HT  PRJ_LOREY_HT PRJ_DIAMETER   PRJ_TPH  PRJ_BA  PRJ_VOL_WS     
PRJ_VOL_CU PRJ_VOL_D  PRJ_VOL_DW  PRJ_VOL_DWB;
do i = 1 to 12; if miss_to_zero(i)=. then do; miss_to_zero(i)=0; end; end;
if FEATURE_ID=88888888 then delete;
if FEATURE_ID=1000000 then delete;RUN;
run;
*/


/*WORK AROUND NOTES:
for later assign average yield curve purpose, for the extreme volume stands,cap them to the 
maximum 2000 m3/ha, AND then proportion reduce the yields in each Ageclass
data Extrem_Prop_Cap1;
set  Extrem_Ori;run;
proc sort; by FEATURE_ID PRJ_VOL_DWB;  run; 

data Extrem_Prop_Cap2;
set  Extrem_Prop_Cap1;
if last.FEATURE_ID;
by FEATURE_ID;  

CAP_FAC_DWB=round(PRJ_VOL_DWB/2000,0.001);
run;
*/



/*WORK AROUND NOTES:
Dec.15, 2018
Since some issues were found in Haida Gwaii(assigned YT maximum volume is <250 m3/ha) for the following
approach, this new MAI approach is going to be applied temporary for now until the BACKGROW
issue will be solved

data UnAdj_YT69;
MERGE UnAdj_YT3(in=a)  
      Extrem_Prop_Cap3(in=b  keep=FEATURE_ID)  
      Abnorm_MAI2(in=c keep=FEATURE_ID);

if a and not (b or c);
by FEATURE_ID;run;

here to get ride off the extreme and abnormal yield polygons 
(and will be adjusted and add back later)
*/


/*WORK AROUND NOTES:
for those unprojected polygons in the Unadjusted population
due to data issues or projection issues
proc means data =UnAdj_YT7;
CLASS Strata PRJ_TOTAL_AGE;
var  PRJ_PCNT_STOCK  PRJ_SITE_INDEX  PRJ_DOM_HT PRJ_LOREY_HT PRJ_DIAMETER PRJ_TPH  PRJ_BA PRJ_VOL_WS PRJ_VOL_CU PRJ_VOL_D PRJ_VOL_DW PRJ_VOL_DWB;
OUTPUT OUT =UnAdj_YT_Pop4  mean=  n=n;
*weight POLYGON_AREA; 
run;
*/



/*WORK AROUND NOTES:
for those projected, but got zero volumes

The logic will be:

First, assign it to the proportional adjusted volume (based on the projected volume of 2017);
Second, if the projectioned volume of 2017 still zero or missing, 
     then assign it to the proportional adjusted volume (based on the projected volume of reference year);
Third, if the reference year volume still missing or zero, then keep the yt zero for all ages.

PLEASE PAY ATTENTION, SOME MAY BE DUE TO VERY LOW SITE INDEX

data Zero_Vol;
set UnAdj_YT7;

if PRJ_TOTAL_AGE=200 and PRJ_VOL_DWB=0;
run;
data Zero_Vol2;
set  Zero_Vol;
if first.FEATURE_ID;
by FEATURE_ID;
run;
*/


/*WORK AROUND NOTES:
for estimating the total layer volume sum at  year 2017 for later use

data V7_2017_DKL_Chk1_Zero;
set  V7_2017_DKL_Chk1;

 array miss_to_zero(12) PRJ_PCNT_STOCK  PRJ_SITE_INDEX  PRJ_DOM_HT  PRJ_LOREY_HT PRJ_DIAMETER   PRJ_TPH  PRJ_BA  PRJ_VOL_WS     
PRJ_VOL_CU PRJ_VOL_D  PRJ_VOL_DW  PRJ_VOL_DWB;
do i = 1 to 12; if miss_to_zero(i)=. then do; miss_to_zero(i)=0; end; end;
if FEATURE_ID=88888888 then delete;
if FEATURE_ID=1000000 then delete;RUN;
run;
proc sort; by  FEATURE_ID  PROJECTION_YEAR  LAYER_ID ; run;

proc summary data=V7_2017_DKL_Chk1_Zero;
var PRJ_PCNT_STOCK  PRJ_SITE_INDEX  PRJ_DOM_HT  PRJ_LOREY_HT PRJ_DIAMETER   PRJ_TPH  PRJ_BA  PRJ_VOL_WS     
PRJ_VOL_CU PRJ_VOL_D  PRJ_VOL_DW  PRJ_VOL_DWB;
output out=V7_2017_DKL_Chk1_Zero1 MEAN=  n=n;
by  FEATURE_ID  PROJECTION_YEAR  LAYER_ID ; run;
run;
*/


/*WORK AROUND NOTES:
HERE TO KEEP BOTH of those that have projected volumes of the 2017 and reference year
data  V7_2017_DKL_Chk3;
set   V7_2017_DKL_Chk2
      V7_RefYr_DKL_Chk03;
run;
*/


/*WORK AROUND NOTES:
this is the final Unadjusted and capped yield table 
data DKL.UnAdj_YT7;
set 
    UnAdj_YT73
    UnProj_YT7

 Zero_Vol68; 
run;
*/


/*WORK AROUND NOTES:
Spot check of the final adjusted yield curves for those projected, but got zero volumes at age 200 due to low SI, or other not normal attributes
data fid_test_2963107;
set UNADJ_YT8;
where FEATURE_ID=2963107;
run;
*/


%clearlog;  		
%clr_work;  
%mac_dlet; 		
%mac_refs (sys1 = vdyp_macros); 

dm "output;clear;log;clear";

%let    dir_v7 =E:\\VDYP7_YT_TSR_Prod\KootenayLake; 
libname UATPGDB "E:\\UAT_Test\LRDW";
libname DKL "E:\\VDYP7_YT_TSR_Prod\KootenayLake";

%let district=DKL;
%let utilization=125175;
%let dir_graph=E:\\VDYP7_YT_TSR_Prod\KootenayLake\Graphs;


libname LookUpTa "H:\RDW_USER\Macros\Lookups_Origin";

/*HERE TO FORMAT SPECIES_CD_1 to be consistent with those from Layer table*/
data SPV_SPK;
set  LookUpTa.SPV_SPK;

*format SPECIES_CD_1 $3. ;
format SPECIES_CD_1 $10. ;

*R1_SPECIES_CD_1=SP_VEGI;
SPECIES_CD_1=SP_VEGI;
SP0=SP_KOZ;
spp_grp=SP_KOZ;
run;

/*KL_vriFID_inCFLB.csv is from Rhian Davies on Oct. 15, 2019*/

PROC IMPORT OUT=POLY_FID_Asked  DATAFILE= "&dir_v7\KL_vriFID_inCFLB.csv" 
 DBMS=csv REPLACE;  RUN;
/*
NOTE: WORK.POLY_FID_ASKED data set was successfully created.
NOTE: The data set WORK.POLY_FID_ASKED has 707961 observations and 1
*/
proc sort; by FEATURE_ID; run;
 data POLY_FID_Asked2;
 set  POLY_FID_Asked;
 if first.FEATURE_ID; 
by FEATURE_ID; run;
/*
NOTE: There were 707961 observations read from the data set
      WORK.POLY_FID_ASKED.
NOTE: The data set WORK.POLY_FID_ASKED2 has 48949 observations and 1
*/



 /*Kootenay_VDYP_input_poly_ToSAS.csv is from Mark Perdue on Sept 23, 2019
PROC IMPORT OUT=POLY0  DATAFILE= "&dir_v7\Kootenay_VDYP_input_poly_ToSAS.csv" 
 DBMS=csv REPLACE;  RUN;
 */

 /* VEG_COMP_VDYP7_INPUT_POLY_TBL_2017_ToSAS.csv is from Iaian on Nov. 1, 2019*/
PROC IMPORT OUT=POLY0  DATAFILE= "&dir_v7\VEG_COMP_VDYP7_INPUT_POLY_TBL_2017_ToSAS.csv" 
 DBMS=csv REPLACE;  RUN;
/*
NOTE: WORK.POLY0 data set was successfully created.
NOTE: The data set WORK.POLY0 has 176125 observations and 43 variables.
*/


 /*
NOTE: 338548 records were read from the infile
      'E:\\VDYP7_YT_TSR_Prod\KootenayLake\VEG_COMP_VDYP7_INPUT_POLY_TBL_ToSAS.csv'.
      The minimum record length was 90.
      The maximum record length was 151.
NOTE: The data set WORK.POLY0 has 338548 observations and 42 variables.
*/

 /*Kootenay_VDYP_input_layer_ToSAS.csv is from Mark Perdue on Sept 23, 2019
PROC IMPORT OUT=LAYER0  DATAFILE= "&dir_v7\Kootenay_VDYP_input_layer_ToSAS.csv" 
 DBMS=csv REPLACE;  RUN;
*/

 
 /* VEG_COMP_VDYP7_INPUT_LAYER_TBL_2017_ToSAS.csv is from Iaian on Nov. 1, 2019*/
PROC IMPORT OUT=LAYER0  DATAFILE= "&dir_v7\VEG_COMP_VDYP7_INPUT_LAYER_TBL_2017_ToSAS.csv" 
 DBMS=csv REPLACE;  RUN;
/*
NOTE: WORK.LAYER0 data set was successfully created.
NOTE: The data set WORK.LAYER0 has 219352 observations and 38 variables.
*/



 /*
*/

PROC SORT  DATA=POLY0; BY FEATURE_ID;RUN;


/*HERE use Rhian provided data and merged with Iaian porvided data*/
  DATA POLY01 AskedButNotIn;
  *SET  POLY0;
 merge POLY0(in=a)   POLY_FID_Asked2(in=b);
 if a and b then output POLY01;
 if b and not a then output AskedButNotIn;
 BY FEATURE_ID;RUN;
/*
NOTE: There were 176125 observations read from the data set WORK.POLY0.
NOTE: There were 48949 observations read from the data set
      WORK.POLY_FID_ASKED2.
NOTE: The data set WORK.POLY01 has 48406 observations and 43 variables.
NOTE: The data set WORK.ASKEDBUTNOTIN has 543 observations and 43
*/


DATA POLY01;
set  POLY01;
if first.FEATURE_ID;
by FEATURE_ID;
run;
/*
NOTE: There were 48406 observations read from the data set WORK.POLY01.
NOTE: The data set WORK.POLY01 has 48406 observations and 43 variables.

*/


 DATA LAYER01;
 SET  LAYER0;
IF FEATURE_ID=88888888 THEN DELETE;

if SPECIES_CD_1="" THEN DELETE;

RUN;
/*
NOTE: There were 437942 observations read from the data set WORK.LAYER0.
NOTE: The data set WORK.LAYER01 has 437941 observations and 38 variables.
*/

PROC SORT; BY FEATURE_ID TREE_COVER_LAYER_ESTIMATED_ID;RUN;

DATA POLY_AND_LAYER0  POLYNOTLAYER LAYERNOTPOLY;
MERGE POLY01(IN=A) LAYER01(IN=B);
IF A AND B THEN OUTPUT POLY_AND_LAYER0;
IF A AND NOT B THEN OUTPUT POLYNOTLAYER;
IF B AND NOT A THEN OUTPUT LAYERNOTPOLY;
by FEATURE_ID;
run;
/*
NOTE: There were 330958 observations read from the data set WORK.POLY01.
NOTE: There were 437941 observations read from the data set WORK.LAYER01.
NOTE: The data set WORK.POLY_AND_LAYER0 has 429110 observations and 77 variables.
NOTE: The data set WORK.POLYNOTLAYER has 0 observations and 77 variables.
NOTE: The data set WORK.LAYERNOTPOLY has 8831 observations and 77 variables.

*/

DATA POLY_AND_LAYER;
set  POLY_AND_LAYER0;
if first.FEATURE_ID;
by FEATURE_ID;
run;
/*
NOTE: There were 429110 observations read from the data set WORK.POLY_AND_LAYER0.
NOTE: The data set WORK.POLY_AND_LAYER has 330958 observations and 77 variables.

*/

DATA POLY;
MERGE POLY_AND_LAYER(IN=A KEEP=FEATURE_ID) POLY01(IN=B);
IF A AND B ;
by FEATURE_ID;
run;
/*
NOTE: There were 330958 observations read from the data set WORK.POLY_AND_LAYER.
NOTE: There were 330958 observations read from the data set WORK.POLY01.
NOTE: The data set WORK.POLY has 330958 observations and 43 variables.
*/

DATA LAYER;
MERGE POLY(IN=A KEEP=FEATURE_ID) LAYER01(IN=B);
IF A AND B ;
by FEATURE_ID;
run;
/*
NOTE: There were 48406 observations read from the data set WORK.POLY.
NOTE: There were 219351 observations read from the data set WORK.LAYER01.
NOTE: The data set WORK.LAYER has 55764 observations and 38 variables.

*/

data POLY;
retain FEATURE_ID	MAP_ID	POLYGON_NUMBER	ORG_UNIT	TSA_NAME	TFL_NAME	
INVENTORY_STANDARD_CODE TSA_NUMBER SHRUB_HEIGHT	SHRUB_CROWN_CLOSURE	SHRUB_COVER_PATTERN	
HERB_COVER_TYPE_CODE	HERB_COVER_PCT	HERB_COVER_PATTERN_CODE	BRYOID_COVER_PCT	
BEC_ZONE_CODE	PRE_DISTURBANCE_STOCKABILITY	YIELD_FACTOR	NON_PRODUCTIVE_DESCRIPTOR_CD
BCLCS_LEVEL1_CODE	BCLCS_LEVEL2_CODE	BCLCS_LEVEL3_CODE	BCLCS_LEVEL4_CODE	BCLCS_LEVEL5_CODE
PHOTO_ESTIMATION_BASE_YEAR	REFERENCE_YEAR	PCT_DEAD	NON_VEG_COVER_TYPE_1	NON_VEG_COVER_PCT_1	
NON_VEG_COVER_PATTERN_1	NON_VEG_COVER_TYPE_2	NON_VEG_COVER_PCT_2	NON_VEG_COVER_PATTERN_2
NON_VEG_COVER_TYPE_3	NON_VEG_COVER_PCT_3	NON_VEG_COVER_PATTERN_3	LAND_COVER_CLASS_CD_1	
LAND_COVER_PCT_1	LAND_COVER_CLASS_CD_2	LAND_COVER_PCT_2	LAND_COVER_CLASS_CD_3	LAND_COVER_PCT_3;

set  POLY;
keep  FEATURE_ID	MAP_ID	POLYGON_NUMBER	ORG_UNIT	TSA_NAME	TFL_NAME	
INVENTORY_STANDARD_CODE TSA_NUMBER SHRUB_HEIGHT	SHRUB_CROWN_CLOSURE	SHRUB_COVER_PATTERN	
HERB_COVER_TYPE_CODE	HERB_COVER_PCT	HERB_COVER_PATTERN_CODE	BRYOID_COVER_PCT	
BEC_ZONE_CODE	PRE_DISTURBANCE_STOCKABILITY	YIELD_FACTOR	NON_PRODUCTIVE_DESCRIPTOR_CD
BCLCS_LEVEL1_CODE	BCLCS_LEVEL2_CODE	BCLCS_LEVEL3_CODE	BCLCS_LEVEL4_CODE	BCLCS_LEVEL5_CODE
PHOTO_ESTIMATION_BASE_YEAR	REFERENCE_YEAR	PCT_DEAD	NON_VEG_COVER_TYPE_1	NON_VEG_COVER_PCT_1	
NON_VEG_COVER_PATTERN_1	NON_VEG_COVER_TYPE_2	NON_VEG_COVER_PCT_2	NON_VEG_COVER_PATTERN_2
NON_VEG_COVER_TYPE_3	NON_VEG_COVER_PCT_3	NON_VEG_COVER_PATTERN_3	LAND_COVER_CLASS_CD_1	
LAND_COVER_PCT_1	LAND_COVER_CLASS_CD_2	LAND_COVER_PCT_2	LAND_COVER_CLASS_CD_3	LAND_COVER_PCT_3;
run;

 PROC EXPORT DATA=POLY
 OUTFILE= "&dir_v7\POLY.CSV"  DBMS=CSV REPLACE;
RUN;
data LAYER;
retain FEATURE_ID	TREE_COVER_LAYER_ESTIMATED_ID	MAP_ID	POLYGON_NUMBER	LAYER_LEVEL_CODE	
VDYP7_LAYER_CD	LAYER_STOCKABILITY	FOREST_COVER_RANK_CODE	NON_FOREST_DESCRIPTOR_CODE	
EST_SITE_INDEX_SPECIES_CD	ESTIMATED_SITE_INDEX	CROWN_CLOSURE	BASAL_AREA_75	
STEMS_PER_HA_75	SPECIES_CD_1	SPECIES_PCT_1	SPECIES_CD_2	SPECIES_PCT_2	
SPECIES_CD_3	SPECIES_PCT_3	SPECIES_CD_4	SPECIES_PCT_4	SPECIES_CD_5	
SPECIES_PCT_5	SPECIES_CD_6	SPECIES_PCT_6	EST_AGE_SPP1	EST_HEIGHT_SPP1	EST_AGE_SPP2
EST_HEIGHT_SPP2	ADJ_IND	LOREY_HEIGHT_75	BASAL_AREA_125	WS_VOL_PER_HA_75	WS_VOL_PER_HA_125
CU_VOL_PER_HA_125	D_VOL_PER_HA_125	DW_VOL_PER_HA_125;
set LAYER;

keep  FEATURE_ID	TREE_COVER_LAYER_ESTIMATED_ID	MAP_ID	POLYGON_NUMBER	LAYER_LEVEL_CODE	
VDYP7_LAYER_CD	LAYER_STOCKABILITY	FOREST_COVER_RANK_CODE	NON_FOREST_DESCRIPTOR_CODE	
EST_SITE_INDEX_SPECIES_CD	ESTIMATED_SITE_INDEX	CROWN_CLOSURE	BASAL_AREA_75	
STEMS_PER_HA_75	SPECIES_CD_1	SPECIES_PCT_1	SPECIES_CD_2	SPECIES_PCT_2	
SPECIES_CD_3	SPECIES_PCT_3	SPECIES_CD_4	SPECIES_PCT_4	SPECIES_CD_5	
SPECIES_PCT_5	SPECIES_CD_6	SPECIES_PCT_6	EST_AGE_SPP1	EST_HEIGHT_SPP1	EST_AGE_SPP2
EST_HEIGHT_SPP2	ADJ_IND	LOREY_HEIGHT_75	BASAL_AREA_125	WS_VOL_PER_HA_75	WS_VOL_PER_HA_125
CU_VOL_PER_HA_125	D_VOL_PER_HA_125	DW_VOL_PER_HA_125;
run;
 PROC EXPORT DATA=LAYER
 OUTFILE= "&dir_v7\LAYER.CSV"  DBMS=CSV REPLACE;
RUN;




proc summary data=LAYER/*LAYER00*/;
WHERE VDYP7_LAYER_CD NE "D";
var TREE_COVER_LAYER_ESTIMATED_ID;
output out=L_N MEAN=  n=n;
by  FEATURE_ID ; run;
run;
/*HERE INCLUDED VT and non-VT polygons*/
/*
NOTE: There were 333535 observations read from the data set WORK.LAYER.
      WHERE VDYP7_LAYER_CD not = 'D';
NOTE: The data set WORK.L_N has 330958 observations and 5 variables.
*/

DATA L_N1 L_N2;
SET  L_N;
if N=1 then output L_N1;
if N>1 then output L_N2; RUN;
/*
NOTE: There were 176124 observations read from the data set WORK.L_N.
NOTE: The data set WORK.L_N1 has 335936 observations and 5 variables.
NOTE: The data set WORK.L_N2 has 2611 observations and 5 variables.

*/

DATA POLY_N1;
MERGE L_N1(IN=A KEEP=FEATURE_ID)  POLY(IN=B);
IF A AND B;
by FEATURE_ID;
RUN; RUN;
/*
NOTE: There were 335936 observations read from the data set WORK.L_N1.
NOTE: There were 176124 observations read from the data set WORK.POLY.
NOTE: The data set WORK.POLY_N1 has 335936 observations and 42 variables.
*/
DATA POLY_N2;
MERGE L_N2(IN=A KEEP=FEATURE_ID)  POLY(IN=B);
IF A AND B;
by FEATURE_ID;
RUN; RUN;
/*
NOTE: There were 330958 observations read from the data set WORK.L_N.
NOTE: The data set WORK.L_N1 has 328391 observations and 5 variables.
NOTE: The data set WORK.L_N2 has 2567 observations and 5 variables.
*/


DATA LAYER_N1;
MERGE L_N1(IN=A KEEP=FEATURE_ID)  LAYER(IN=B);
IF A AND B;
by FEATURE_ID;
RUN; RUN;
/*
NOTE: There were 328391 observations read from the data set WORK.L_N1.
NOTE: There were 330958 observations read from the data set WORK.POLY.
NOTE: The data set WORK.POLY_N1 has 328391 observations and 42 variables.

*/
DATA LAYER_N2;
MERGE L_N2(IN=A KEEP=FEATURE_ID)  LAYER(IN=B);
IF A AND B;
by FEATURE_ID;
RUN; RUN;
/*
NOTE: There were 2567 observations read from the data set WORK.L_N2.
NOTE: There were 330958 observations read from the data set WORK.POLY.
NOTE: The data set WORK.POLY_N2 has 2567 observations and 42 variables.

*/


/*TO GET THE MAX AGE OF THE LAYERS FOR SETTING THE PROJ YEAR, CONSIDER BACK GROWTH*/
proc means data =LAYER_N2;

VAR  EST_AGE_SPP1; 
OUTPUT OUT =LAYER_N2_MaxAge
mean =EST_AGE_SPP1_Mean 
max  =EST_AGE_SPP1_Max
min  =EST_AGE_SPP1_Min;

run;
/*Analysis Variable : EST_AGE_SPP1 EST_AGE_SPP1 
N Mean Std Dev Minimum Maximum 
19248 103.1082190 75.7233055 1.0000000 400.0000000 
*/


 PROC EXPORT DATA=POLY_N1
 OUTFILE= "&dir_v7\POLY_N1.CSV"  DBMS=CSV REPLACE;
RUN;
/*HERE INCLUDED VT and non-VT polygons*/
 PROC EXPORT DATA=LAYER_N1
 OUTFILE= "&dir_v7\LAYER_N1.CSV"  DBMS=CSV REPLACE;
RUN;

 PROC EXPORT DATA=POLY_N2
 OUTFILE= "&dir_v7\POLY_N2.CSV"  DBMS=CSV REPLACE;
RUN;
/*HERE INCLUDED VT and non-VT polygons*/
 PROC EXPORT DATA=LAYER_N2
 OUTFILE= "&dir_v7\LAYER_N2.CSV"  DBMS=CSV REPLACE;
RUN;




data PolyAndLayer PolyNotLayer LayerNotPoly ;
merge POLY(in=a /*keep=FEATURE_ID*/)   
      LAYER(in=b /*keep=FEATURE_ID	TREE_COVER_LAYER_ESTIMATED_ID*/);
if a  and b     then output PolyAndLayer;
if a  and not b then output PolyNotLayer;
if b  and not a then output LayerNotPoly;
by FEATURE_ID;
run;
/*
NOTE: There were 176124 observations read from the data set WORK.POLY.
NOTE: There were 219326 observations read from the data set WORK.LAYER.
NOTE: The data set WORK.POLYANDLAYER has 219326 observations and 77 variables.
NOTE: The data set WORK.POLYNOTLAYER has 0 observations and 77 variables.
NOTE: The data set WORK.LAYERNOTPOLY has 0 observations and 77 variables.
*/

data V F I L;
set POLY;
if INVENTORY_STANDARD_CODE="V"     then output V;
if INVENTORY_STANDARD_CODE="F"     then output F;
if INVENTORY_STANDARD_CODE="I"     then output I;
if INVENTORY_STANDARD_CODE="L"     then output L;
run;
/*HERE INCLUDED VT and non-VT polygons*/
/*
NOTE: There were 176124 observations read from the data set WORK.POLY.
NOTE: The data set WORK.V has 93444 observations and 42 variables.
NOTE: The data set WORK.F has 63852 observations and 42 variables.
NOTE: The data set WORK.I has 18828 observations and 42 variables.
NOTE: The data set WORK.L has 0 observations and 42 variables.


*/



/*to check DATA ISSUES*/

/*FOR CHECKING THE MPB damaged stands that in both poly and layer 
tables and be consistent!!*/
data POLY_D;
set POLY;
where PCT_DEAD>0;
run;
/*
NOTE: There were 34105 observations read from the data set WORK.POLY.
      WHERE PCT_DEAD>0;
NOTE: The data set WORK.POLY_D has 34105 observations and 42 varia

*/

data LAYER_D;
set LAYER;
where LAYER_LEVEL_CODE="D" OR VDYP7_LAYER_CD="D";
run;
/*

NOTE: There were 24557 observations read from the data set WORK.LAYER.
      WHERE (LAYER_LEVEL_CODE='D') or (VDYP7_LAYER_CD='D');
NOTE: The data set WORK.LAYER_D has 24557 observations and 38 variables.

*/
data D_POLY_LAYER  D_inP_notL  D_inL_notP;
MERGE POLY_D(IN=A)  LAYER_D(IN=B);
IF A AND B THEN OUTPUT D_POLY_LAYER;
IF A AND NOT B THEN OUTPUT D_inP_notL;
IF B AND NOT A THEN OUTPUT D_inL_notP;
by FEATURE_ID;
RUN;
/*
NOTE: There were 34105 observations read from the data set WORK.POLY_D.
NOTE: There were 24557 observations read from the data set WORK.LAYER_D.
NOTE: The data set WORK.D_POLY_LAYER has 24557 observations and 77
      variables.
NOTE: The data set WORK.D_INP_NOTL has 9548 observations and 77
      variables.
NOTE: The data set WORK.D_INL_NOTP has 0 observations and 77 variables.

*/


data D_inP_notL3;
set D_inP_notL;
if PCT_DEAD>=10;RUN;
/*
NOTE: There were 9548 observations read from the data set
      WORK.D_INP_NOTL.
NOTE: The data set WORK.D_INP_NOTL3 has 2243 observations and 77

*/


PROC EXPORT DATA=D_inP_notL(KEEP=FEATURE_ID) dbms=EXCEL OUTFILE= "&dir_v7\DKL_Data Issues Check.xlsx" replace; SHEET="D_inP_notL"; RUN; 

PROC EXPORT DATA=D_inL_notP(KEEP=FEATURE_ID LAYER_LEVEL_CODE) dbms=EXCEL OUTFILE= "&dir_v7\DKL_Data Issues Check.xlsx" replace; 
                  SHEET="D_inL_notP"; RUN; 



data Task_data0;
merge POLY(IN=A)  LAYER(IN=B);
IF A AND B;
BY FEATURE_ID;
SPECIES_CD_1=UPCASE(SPECIES_CD_1);
RUN;
/*HERE INCLUDED VT and non-VT polygons*/
/*
NOTE: There were 176124 observations read from the data set WORK.POLY.
NOTE: There were 219326 observations read from the data set WORK.LAYER.
NOTE: The data set WORK.TASK_DATA0 has 219326 observations and 77

*/


/*CAN NOT DO THIS IN THIS STEP,NEED SEPERATE STEP, OTHERWISE IT IS WRONG that 
some age<30 were also assigned Strata!!!*/
/*retain SPECIES_CD_1 Strata PRJ_SITE_INDEX Age_SmpYr YEAR_REF EST_AGE_SPP1;*/
/*
merge Task_data01(in=a)  SI(in=b);
if a;
by  FEATURE_ID;
*/

/*FOR MERGING TO GET SP0 OR spp_grp*/
PROC SORT data=spv_spk;
BY SPECIES_CD_1;RUN;

PROC SORT data=Task_data0;
BY SPECIES_CD_1;RUN;


/*here ONLY VT POLYGONS, AND ONLY STANDS OF Age_SmpYr>50 YEARS
ARE ASSIGNED Strata, SINCE THE SAMPLE POPULATION WAS DEFINED AS VT STANDS,
but for the Step1 and step3 final runs, they include VT polygons here*/

data Task_data00;

/*RETAIN SPECIES_CD_1 spp_grp Strata; 
!!!!MUST NOT DO THIS WAY RETAIN IN THE ONE STEP, IT CAUSED ISSUES!!!!!!!*/
*set  Task_data0;

MERGE  Task_data0(IN=AA)  spv_spk;
IF AA;
BY SPECIES_CD_1;

*format REFERENCE_DATE $10.;/*to be the same format from step2 and 3*/
*REFERENCE_DATE=compress("01/"||"01/"||YEAR_REF);

*YEAR_REF=YEAR(REFERENCE_DATE);
YEAR_REF=REFERENCE_YEAR;
/*here REFERENCE_DATE format is mmddyy10., need to convert $. to avoid issues later*/
*drop REFERENCE_DATE;

Age_SmpYr=2016-YEAR_REF+EST_AGE_SPP1;
Age_now=2017-YEAR_REF+EST_AGE_SPP1;

FORMAT LAYER_ID $1.;
LAYER_ID=LAYER_LEVEL_CODE;

format Strata $6. ;

IF Age_SmpYr>50 AND BCLCS_LEVEL1_CODE='V' AND BCLCS_LEVEL2_CODE='T' THEN DO;

*spp_grp=substr(SPECIES_CD_1,1,1);
*spp_grp=PUT (UPCASE(SPECIES_CD_1), $SPV_SPK.);
*if spp_grp in ('PL','P', 'p') then Strata='Pine';

/*
if spp_grp in ("P", 'p', "PL", "PY", "PW","PA") then DO; Strata="Pine";END;
if spp_grp in ('F')  then DO; Strata="Fd"; END;
if spp_grp in ('S', 's', 'B', 'b')  then DO; Strata="SandB"; END;
if spp_grp in ('AC','AT','C','D','E','H','L','MB','Y')  then DO; Strata="Other"; END;
*/

if SPECIES_CD_1 in ("CW", "CY") then DO; Strata="Cw_Yc";END;
if SPECIES_CD_1 in ('HM', 'HW', 'HXM', 'SS')  then DO; Strata="HwHmSS"; END;
/*if Strata=''  then DO; Strata="NoAdj"; END;*/


if LAYER_LEVEL_CODE="D" then DO; Strata="Dlayer"; END;
/*THIS WAY WILL INCLUDE THE D-LAYERS IN 
THE LAYER TABLE FOR PROCESSES IF THE P LAYER IS ASSIGNED AN EFFECTIVE Strata*/

/*if LAYER_LEVEL_CODE="" then DO; Strata='';END;*/
/*if Strata='' then DO; Strata='NoAdj';END;*/
/*since it will cause issues in the process. its re_layer will be treated as R1 layer
after run VDYP7, if the LAYER_LEVEL_CODE missing. then cause double count for this polygon */

END;

if Strata='' then DO; Strata="NoAdj";END;
*IF Age_now<30 THEN Strata='';
*IF Age_now=<50 THEN Strata='';
/*here is for the sample data only include VRI and CMI/NFI,
and they are all >50 years old, and apply to the age+50 population*/
run;


/*here ONLY VT POLYGONS, AND ONLY STANDS OF Age_SmpYr>50 YEARS
ARE ASSIGNED Strata, SINCE THE SAMPLE POPULATION WAS DEFINED AS VT STANDS,
but for the Step1 and step3 final runs, they include VT polygons here*/

data Task_data01;
RETAIN SPECIES_CD_1 spp_grp Strata  Age_SmpYr  BCLCS_LEVEL1_CODE  BCLCS_LEVEL2_CODE ; 

/*!!!!MUST NOT DO THIS WAY IN THE PREVIOUS ONE STEP, IT CAUSED ISSUES!!!!!!*/

set  Task_data00;
RUN;

/*SINCE THE SAMPLE POPULATION WAS DEFINED AS VT STANDS AND AGE 50 YEARS*/
/*
NOTE: There were 219326 observations read from the data set WORK.TASK_DATA00.
NOTE: The data set WORK.TASK_DATA01 has 219326 observations and 86 variable

*/
PROC SORT;  BY FEATURE_ID;RUN;

data Task_data1; /*PRIMARY LAYER ONLY*/
set  Task_data01; 

*WHERE VDYP7_LAYER_CD="P";
IF VDYP7_LAYER_CD="P";
*KEEP FEATURE_ID  Strata LAYER_LEVEL_CODE LAYER_ID VDYP7_LAYER_CD FOREST_COVER_RANK_CODE;

run;
/*
NOTE: There were 219326 observations read from the data set
      WORK.TASK_DATA01.
NOTE: The data set WORK.TASK_DATA1 has 175580 observations and 86

NOTE: There were 219326 observations read from the data set WORK.TASK_DATA01.
NOTE: The data set WORK.TASK_DATA1 has 175580 observations and 86 variables.
*/



/*CAN NOT DO THIS IN the previous STEP,NEED SEPERATE STEP, OTHERWISE IT IS WRONG that 
some age<30 were also assigned Strata!!!WHY???*/
data Task_data1;
retain SPECIES_CD_1 Strata PRJ_SITE_INDEX Age_SmpYr YEAR_REF EST_AGE_SPP1;
SET  Task_data1; 
RUN;




DATA Task_data01_VT_POLY;
retain FEATURE_ID	MAP_ID	POLYGON_NUMBER	ORG_UNIT	TSA_NAME	TFL_NAME	
INVENTORY_STANDARD_CODE TSA_NUMBER SHRUB_HEIGHT	SHRUB_CROWN_CLOSURE	SHRUB_COVER_PATTERN	
HERB_COVER_TYPE_CODE	HERB_COVER_PCT	HERB_COVER_PATTERN_CODE	BRYOID_COVER_PCT	
BEC_ZONE_CODE	PRE_DISTURBANCE_STOCKABILITY	YIELD_FACTOR	NON_PRODUCTIVE_DESCRIPTOR_CD
BCLCS_LEVEL1_CODE	BCLCS_LEVEL2_CODE	BCLCS_LEVEL3_CODE	BCLCS_LEVEL4_CODE	BCLCS_LEVEL5_CODE
PHOTO_ESTIMATION_BASE_YEAR	REFERENCE_YEAR	PCT_DEAD	NON_VEG_COVER_TYPE_1	NON_VEG_COVER_PCT_1	
NON_VEG_COVER_PATTERN_1	NON_VEG_COVER_TYPE_2	NON_VEG_COVER_PCT_2	NON_VEG_COVER_PATTERN_2
NON_VEG_COVER_TYPE_3	NON_VEG_COVER_PCT_3	NON_VEG_COVER_PATTERN_3	LAND_COVER_CLASS_CD_1	
LAND_COVER_PCT_1	LAND_COVER_CLASS_CD_2	LAND_COVER_PCT_2	LAND_COVER_CLASS_CD_3	LAND_COVER_PCT_3;

*SET  Task_data1;/*PRIMARY LAYER ONLY*/
SET  Task_data01;/*VT POLYGONS and non-VT polygons too here*/
/*IF FIRST.FEATURE_ID;
BY FEATURE_ID;*/
if VDYP7_LAYER_CD="P";
/*both ways got the same obs, but this way is better to avoid issues, especially for adjustment
process later steps different layer may have different REFERENCE_YEAR.
please note the REFERENCE_YEAR may differ at different layers if the adjustment process due to 
some layers are adjusted, and some may not be adjusted*/

keep  FEATURE_ID	MAP_ID	POLYGON_NUMBER	ORG_UNIT	TSA_NAME	TFL_NAME	
INVENTORY_STANDARD_CODE TSA_NUMBER SHRUB_HEIGHT	SHRUB_CROWN_CLOSURE	SHRUB_COVER_PATTERN	
HERB_COVER_TYPE_CODE	HERB_COVER_PCT	HERB_COVER_PATTERN_CODE	BRYOID_COVER_PCT	
BEC_ZONE_CODE	PRE_DISTURBANCE_STOCKABILITY	YIELD_FACTOR	NON_PRODUCTIVE_DESCRIPTOR_CD
BCLCS_LEVEL1_CODE	BCLCS_LEVEL2_CODE	BCLCS_LEVEL3_CODE	BCLCS_LEVEL4_CODE	BCLCS_LEVEL5_CODE
PHOTO_ESTIMATION_BASE_YEAR	REFERENCE_YEAR	PCT_DEAD	NON_VEG_COVER_TYPE_1	NON_VEG_COVER_PCT_1	
NON_VEG_COVER_PATTERN_1	NON_VEG_COVER_TYPE_2	NON_VEG_COVER_PCT_2	NON_VEG_COVER_PATTERN_2
NON_VEG_COVER_TYPE_3	NON_VEG_COVER_PCT_3	NON_VEG_COVER_PATTERN_3	LAND_COVER_CLASS_CD_1	
LAND_COVER_PCT_1	LAND_COVER_CLASS_CD_2	LAND_COVER_PCT_2	LAND_COVER_CLASS_CD_3	LAND_COVER_PCT_3;
RUN;
/*
NOTE: There were 219326 observations read from the data set WORK.TASK_DATA01.
NOTE: The data set WORK.TASK_DATA01_VT_POLY has 175580 observations and 43 variables.

*/


DATA Task_data01_VT_LAYER;
retain FEATURE_ID	TREE_COVER_LAYER_ESTIMATED_ID	MAP_ID	POLYGON_NUMBER	LAYER_LEVEL_CODE	
VDYP7_LAYER_CD	LAYER_STOCKABILITY	FOREST_COVER_RANK_CODE	NON_FOREST_DESCRIPTOR_CODE	
EST_SITE_INDEX_SPECIES_CD	ESTIMATED_SITE_INDEX	CROWN_CLOSURE	BASAL_AREA_75	
STEMS_PER_HA_75	SPECIES_CD_1	SPECIES_PCT_1	SPECIES_CD_2	SPECIES_PCT_2	
SPECIES_CD_3	SPECIES_PCT_3	SPECIES_CD_4	SPECIES_PCT_4	SPECIES_CD_5	
SPECIES_PCT_5	SPECIES_CD_6	SPECIES_PCT_6	EST_AGE_SPP1	EST_HEIGHT_SPP1	EST_AGE_SPP2
EST_HEIGHT_SPP2	ADJ_IND	LOREY_HEIGHT_75	BASAL_AREA_125	WS_VOL_PER_HA_75	WS_VOL_PER_HA_125
CU_VOL_PER_HA_125	D_VOL_PER_HA_125	DW_VOL_PER_HA_125;

*SET  Task_data1;/*PRIMARY LAYER ONLY*/
SET  Task_data01;/*VT POLYGONS and non-VT polygons too here*/

keep  FEATURE_ID	TREE_COVER_LAYER_ESTIMATED_ID	MAP_ID	POLYGON_NUMBER	LAYER_LEVEL_CODE	
VDYP7_LAYER_CD	LAYER_STOCKABILITY	FOREST_COVER_RANK_CODE	NON_FOREST_DESCRIPTOR_CODE	
EST_SITE_INDEX_SPECIES_CD	ESTIMATED_SITE_INDEX	CROWN_CLOSURE	BASAL_AREA_75	
STEMS_PER_HA_75	SPECIES_CD_1	SPECIES_PCT_1	SPECIES_CD_2	SPECIES_PCT_2	
SPECIES_CD_3	SPECIES_PCT_3	SPECIES_CD_4	SPECIES_PCT_4	SPECIES_CD_5	
SPECIES_PCT_5	SPECIES_CD_6	SPECIES_PCT_6	EST_AGE_SPP1	EST_HEIGHT_SPP1	EST_AGE_SPP2
EST_HEIGHT_SPP2	ADJ_IND	LOREY_HEIGHT_75	BASAL_AREA_125	WS_VOL_PER_HA_75	WS_VOL_PER_HA_125
CU_VOL_PER_HA_125	D_VOL_PER_HA_125	DW_VOL_PER_HA_125;
RUN;
PROC SORT; BY FEATURE_ID	TREE_COVER_LAYER_ESTIMATED_ID; RUN;


 PROC EXPORT DATA=Task_data01_VT_POLY 
 OUTFILE= "E:\\VDYP7_YT_TSR_Prod\KootenayLake\Step1_Task_POLY.CSV"
 DBMS=CSV REPLACE;
RUN;

 PROC EXPORT DATA=Task_data01_VT_LAYER 
 OUTFILE= "E:\\VDYP7_YT_TSR_Prod\KootenayLake\Step1_Task_LAYER.CSV"
 DBMS=CSV REPLACE;
RUN;

/*run the Unadjusted yield table for comparison purpose and sensitivity analysis.
actually, this was runned at the beginning useds the vdyp7_input_flat_2.csv file input*/
 /*
PROC EXPORT DATA=Task_data03 
 OUTFILE= "E:\\VDYP7_YT_TSR_Prod\KootenayLake\Step1_UnAdj.CSV"
 DBMS=CSV REPLACE;
RUN;*/



/*inventory data summary*/
data Photo_yr;
set Task_data1;
format Photo_year $12.;
if YEAR_REF<1970 then Photo_year='1970-';
if 1970<=YEAR_REF<1980 then Photo_year='1970-1979';
if 1980<=YEAR_REF<1990 then Photo_year='1980-1989';

if 1990<=YEAR_REF<2000 then Photo_year='1990-2000';
if 2000<=YEAR_REF<2010 then Photo_year='2000-2010';
if 2000<=YEAR_REF      then Photo_year='2000+';
run;

/*by year*/
proc freq data=Photo_yr;
table Photo_year / out=Photo_yr3; run;
data Photo_yr4;
set Photo_yr3 (rename=(count=Polygons));

Percent=round(percent, .1); run;

PROC EXPORT DATA=Photo_yr4 dbms=EXCEL 
OUTFILE= "E:\\VDYP7_YT_TSR_Prod\KootenayLake\Adj_Unadj_Population.xlsx" replace; SHEET="Photo_year"; RUN;

/*by Strata*/
proc freq data=Photo_yr;
table Strata / out=Photo_Str3; run;
data Photo_Str4;
set Photo_Str3 (rename=(count=Polygons));

Percent=round(percent, .1); run;

PROC EXPORT DATA=Photo_Str4 dbms=EXCEL 
OUTFILE= "E:\\VDYP7_YT_TSR_Prod\KootenayLake\Adj_Unadj_Population.xlsx" replace; SHEET="Strata"; RUN;


data test3;
set Task_data1;
if LAYER_LEVEL_CODE="" ;run;
/*
NOTE: There were 175580 observations read from the data set WORK.TASK_DATA1.
NOTE: The data set WORK.TEST3 has 0 observations and 87 variables.
*/

data test4;
set Task_data1;
if LAYER_LEVEL_CODE="" and SPECIES_CD_1 ne '' ;run;
/*
NOTE: There were 175580 observations read from the data set WORK.TASK_DATA1.
NOTE: The data set WORK.TEST4 has 0 observations and 87 variables.

*/


data test; set Task_data1; 
where STEMS_PER_HA_75=0;run;
/*
NOTE: There were 143 observations read from the data set WORK.TASK_DATA1.
      WHERE STEMS_PER_HA_75=0;
NOTE: The data set WORK.TEST has 143 observations and 87 variables.
*/

data test3; set Task_data1; where BCLCS_LEVEL1_CODE='V' AND	BCLCS_LEVEL2_CODE='T' 
AND STEMS_PER_HA_75=0 AND BASAL_AREA_75>0;run;
/*  The data set WORK.TEST3 has 0 observations and 134 variables*/


/*ASSIGN ADJ AND NON-ADJ POPULATIONS*/
data Adj_Y0 ;
*set Task_data1;   /*PRIMARY LAYER ONLY*/
set Task_data01;/*ALL LAYERS, but only VT and age>50 were assigned Strata*/

*if  Strata ne "" and VDYP7_LAYER_CD="P" ;
*if  Strata in ("Fd", "Pine","SandB", "Other") and VDYP7_LAYER_CD="P" ;
if  Strata in ("Cw_Yc", "HwHmSS") and VDYP7_LAYER_CD="P" ;

keep FEATURE_ID VDYP7_LAYER_CD LAYER_LEVEL_CODE LAYER_ID Strata ;
run; 
/*WITH SOME D-LAYERS THAT HAVE Strata due to the previous process
no primary layer Strata polygons not included in the adj processes. 
but should be included in the final projection

NOTE: There were 219326 observations read from the data set WORK.TASK_DATA01.
NOTE: The data set WORK.ADJ_Y0 has 30720 observations and 5 variables.

*/
/*
data Adj_Y;
MERGE Adj_Y0(IN=A KEEP=FEATURE_ID)  Task_data01(IN=B);
IF A AND B; BY FEATURE_ID;
RUN;
THIS WAY CAUSED THAT THE SAME POLYGON, DIFFERENT LAYER GOT DIFFERENT Strata*/


data Adj_Y;
MERGE Adj_Y0(IN=A KEEP=FEATURE_ID  Strata)  Task_data01(IN=B  DROP=Strata);
IF A AND B; BY FEATURE_ID;
RUN;
/*THIS WAY assume THE SAME POLYGON, DIFFERENT LAYER GOT SAME Strata, 
EVEN THOUGH DIFFERENT LEADING SPECIES*/
/*

NOTE: There were 30720 observations read from the data set WORK.ADJ_Y0.
NOTE: There were 219326 observations read from the data set WORK.TASK_DATA01.
NOTE: The data set WORK.ADJ_Y has 28937 observations and 86 variables.

*/

data Adj_N;
MERGE Adj_Y0(IN=A KEEP=FEATURE_ID)  Task_data01(IN=B);
IF B AND NOT A; BY FEATURE_ID;
RUN;
/*WITH SOME D-LAYERS THAT HAVE Strata due to the previous process
no primary layer Strata polygons not included in the adj processes. 
but should be included in the final projection.

NOTE: There were 30720 observations read from the data set WORK.ADJ_Y0.
NOTE: There were 219326 observations read from the data set WORK.TASK_DATA01.
NOTE: The data set WORK.ADJ_N has 40862 observations and 87 variables.
*/

/*
data Adj_Y  Adj_N;
set Task_data01;
if  Strata ne '' then output Adj_Y;
if  Strata = ''  then output Adj_N;
run; */

data DKL.Adj_N;
set Adj_N; run; /*for further checking purpose, and later added to the final projection*/
/*
NOTE: There were 40862 observations read from the data set WORK.ADJ_N.
NOTE: The data set POP_YT.ADJ_N has 40862 observations and 86 variables

*/


data Feat_Stra;/*only P layer with Strata assigned polygons will be adjusted and use
the P layer  as the stand Strata assignment, BUT SHOULD NOT INCLUDE THE D-layer, 
i.e., no D-layer adjustment*/

/*set   Adj_Y;
if first.FEATURE_ID;
by FEATURE_ID;
*/
set   Adj_Y0;

*keep FEATURE_ID VDYP7_LAYER_CD Strata ;
keep FEATURE_ID Strata; 
run; 
/*
NOTE: There were 30720 observations read from the data set WORK.ADJ_Y0.
NOTE: The data set WORK.FEAT_STRA has 30720 observations and 2 variables

*/
 proc sort; by Strata; run;



/*followinf is based on NEW REGION AND DISTRICT CODE from ED FONG, 
 BUT THE UATPGDB.R1_LAYER_ALL IS BASED ON THE 2016 LRDW, NOT 2017 LRDW!! */
DATA POLY_AREA;
SET UATPGDB.R1_LAYER_ALL;

*where FEATURE_ID in (9009243,9009264,9009288,9009291,9009333,9009239,9009405,9009739,9012065,9023302);
*if FEATURE_ID in (9278597, 9009239,9009264,9009288,9009291,9009333,9009405,9009739,9012065,9023302,9915707);
FORMAT TSA_N $6.  C_I $ 2.;
/*DNI, DSE,DQC*/
if ORG_UNIT_CODE in ("DNI") THEN TSA_N="NorIsl";
if ORG_UNIT_CODE in ("DQC") THEN TSA_N="Haida";

if ORG_UNIT_CODE in ("DSI") THEN TSA_N="38";
if ORG_UNIT_CODE in ("DCK") THEN TSA_N="30";

if ORG_UNIT_CODE in ("DSQ") THEN TSA_N="31";
if ORG_UNIT_CODE in ("DSC") THEN TSA_N="39";
if ORG_UNIT_CODE in ("DCR") THEN TSA_N="37";

*if ORG_UNIT_CODE in ("DIC") THEN TSA_N="1933";
*if ORG_UNIT_CODE in ("DNC") THEN TSA_N="21";
*if ORG_UNIT_CODE in ("DHG") THEN TSA_N="25";
if ORG_UNIT_CODE in ("DNI","DQC","DSI", "DCK","DSQ","DCR","DSC") THEN C_I="C";


if ORG_UNIT_CODE in ("DSS") THEN TSA_N="120304";/*12,03 AND 04*/
if ORG_UNIT_CODE in ("DPC") THEN TSA_N="4041";
if ORG_UNIT_CODE in ("DFN") THEN TSA_N="08";
if ORG_UNIT_CODE in ("DKM") THEN TSA_N="1043";
if ORG_UNIT_CODE in ("DND") THEN TSA_N="1420";
if ORG_UNIT_CODE in ("DMK") THEN TSA_N="16";

if ORG_UNIT_CODE in ("DJA","DPG","DVA") THEN TSA_N="24";
*if ORG_UNIT_CODE in ("DPG") THEN TSA_N="24";
if ORG_UNIT_CODE in ("DSN") THEN TSA_N="DSN";/*DSN 0 OBS??*/
if ORG_UNIT_CODE in ("DSS","DPC","DFN","DKM","DND","DMK","DPG","DJA","DVA","DSN")THEN C_I="NI";


if ORG_UNIT_CODE in ("DSE") THEN TSA_N="Selkir";
if ORG_UNIT_CODE in ("DMH") THEN TSA_N="23";
*if ORG_UNIT_CODE in ("DAB") THEN TSA_N="0102";
if ORG_UNIT_CODE in ("DRM") THEN TSA_N="0509";
*if ORG_UNIT_CODE in ("DCO") THEN TSA_N="07";
if ORG_UNIT_CODE in ("DKA"/*,"DHW"*/) THEN TSA_N="1117";
*if ORG_UNIT_CODE in ("DKL") THEN TSA_N="13";
if ORG_UNIT_CODE in ("DCS") THEN TSA_N="1518";
if ORG_UNIT_CODE in ("DOS") THEN TSA_N="22";
if ORG_UNIT_CODE in ("DQU") THEN TSA_N="26";
*if ORG_UNIT_CODE in ("DCO") THEN TSA_N="27";
if ORG_UNIT_CODE in (/*"DCH",*/"DCC") THEN TSA_N="29";
if ORG_UNIT_CODE in ("DSE","DMH","DRM","DKA",/*"DHW","DAB","DCO","DKL","DCO","DCH",*/
    "DCS","DOS","DQU", "DCC")THEN C_I="SI";

KEEP FEATURE_ID POLYGON_AREA  BEC_ZONE_CODE ORG_UNIT_CODE TSA_N C_I;
RUN;
/*
NOTE: There were 4677411 observations read from the data set UATPGDB.R1_LAYER_ALL.
NOTE: The data set WORK.POLY_AREA has 4677411 observations and 6 variables.
*/
PROC SORT; BY FEATURE_ID ;RUN;

data Wt_Feat;
*set Task_data1;/*P layer only*/
merge Task_data1(in=a  )  POLY_AREA(in=b);
if a and b;
BY FEATURE_ID ;
*POLYGON_AREA=1;

drop  D_VOL_PER_HA_125  DW_VOL_PER_HA_125  DWB_VOL_PER_HA_125;
/*to add Strata to the Wt_Feat since it will be used later by the proc means process
HERE MUST DROP OR NOT INCLUDE D_VOL_PER_HA_125	DW_VOL_PER_HA_125. OTHERWISE, IT WILL GET WRONG IN THE LATER PROCESS!!!!!!!*/

RUN;
/*

WARNING: The variable DWB_VOL_PER_HA_125 in the DROP, KEEP, or RENAME
         list has never been referenced.

NOTE: There were 175580 observations read from the data set
      WORK.TASK_DATA1.
NOTE: There were 4677411 observations read from the data set
      WORK.POLY_AREA.
NOTE: The data set WORK.WT_FEAT has 164028 observations and 88 variables.


*/
proc sort; by FEATURE_ID; run;



 /*check REFERENCE_YEAR*/
data REFERENCE_YEAR; set PolyAndLayer;
where REFERENCE_YEAR < PHOTO_ESTIMATION_BASE_YEAR;  RUN;
/**/
PROC EXPORT DATA=REFERENCE_YEAR dbms=EXCEL OUTFILE= "&dir_v7\DKL_Data Issues Check.xlsx" replace; SHEET="REFERENCE_YEAR"; RUN; 

 
 /*check VDYP7_LAYER_CD*/
data VDYP7_LAYER_CD; set PolyAndLayer;
IF VDYP7_LAYER_CD="" AND FOREST_COVER_RANK_CODE NE .;  RUN;
/**/
PROC EXPORT DATA=VDYP7_LAYER_CD dbms=EXCEL OUTFILE= "&dir_v7\DKL_Data Issues Check.xlsx" replace; SHEET="VDYP7_LAYER_CD"; RUN; 

 
 /*check FOREST_COVER_RANK_CODE*/
data Dlayer_RANK1; set PolyAndLayer;
IF VDYP7_LAYER_CD="D" AND FOREST_COVER_RANK_CODE IN (1);  RUN;
/**/
PROC EXPORT DATA=Dlayer_RANK1 dbms=EXCEL OUTFILE= "&dir_v7\DKL_Data Issues Check.xlsx" replace; SHEET="Dlayer_RANK1"; RUN; 

 /*check HT*/
data ext_Ht; set PolyAndLayer;
where EST_HEIGHT_SPP1>60  or EST_HEIGHT_SPP2>=60;  RUN;
/*
NOTE: There were 3 observations read from the data set WORK.POLYANDLAYER.
      WHERE (EST_HEIGHT_SPP1>60) or (EST_HEIGHT_SPP2>=60);
NOTE: The data set WORK.EXT_HT has 3 observations and 78 variables.

*/
PROC EXPORT DATA=ext_Ht dbms=EXCEL OUTFILE= "&dir_v7\DKL_Data Issues Check.xlsx" replace;  SHEET="ext_Ht"; RUN; 

 /*check AGE*/
data Age_big; set PolyAndLayer;
where EST_AGE_SPP1>400;  RUN;
/*
NOTE: There were 22 observations read from the data set WORK.POLYANDLAYER.
      WHERE EST_AGE_SPP1>400;
NOTE: The data set WORK.AGE_BIG has 22 observations and 78 variables.

*/
PROC EXPORT DATA=Age_big dbms=EXCEL OUTFILE= "&dir_v7\DKL_Data Issues Check.xlsx" replace;  SHEET="Age_big"; RUN; 
data Age1Young30Age2100;
set PolyAndLayer  ;
if EST_AGE_SPP1<EST_AGE_SPP2 and (EST_AGE_SPP1<=30 and EST_AGE_SPP2>100);run;
/*
NOTE: There were 219326 observations read from the data set
      WORK.POLYANDLAYER.
NOTE: The data set WORK.AGE1YOUNG30AGE2100 has 6 observations and 77


*/
PROC EXPORT DATA=Age1Young30Age2100 dbms=EXCEL OUTFILE= "&dir_v7\DKL_Data Issues Check.xlsx" replace; SHEET="Age1Young30Age2100"; RUN; 
data Age1Young30;
set PolyAndLayer  ;
if EST_AGE_SPP1<=30;run;
/*
NOTE: There were 219326 observations read from the data set WORK.POLYANDLAYER.
NOTE: The data set WORK.AGE1YOUNG30 has 22357 observations and 78 variables.

*/
PROC EXPORT DATA=Age1Young30 dbms=EXCEL OUTFILE= "&dir_v7\DKL_Data Issues Check.xlsx" replace; SHEET="Age1Young30"; RUN; 


 /*check BA*/
data ext_BA; set PolyAndLayer;
where BASAL_AREA_75>200;  RUN;
/*0 */

data ext_BA_zero; set PolyAndLayer;
where INVENTORY_STANDARD_CODE in ("V") and BASAL_AREA_75 in (0, .);  RUN;
/*may have some data issues???
most are the dead layers, but pct_dead=0 or missing, 

NOTE: There were 3126 observations read from the data set
      WORK.POLYANDLAYER.
      WHERE (INVENTORY_STANDARD_CODE='V') and BASAL_AREA_75 in (., 0);
NOTE: The data set WORK.EXT_BA_ZERO has 3126 observations and 77


*/

PROC EXPORT DATA=ext_BA dbms=EXCEL OUTFILE= "&dir_v7\DKL_Data Issues Check.xlsx" replace;      SHEET="ext_BA"; RUN; 
PROC EXPORT DATA=ext_BA_zero dbms=EXCEL OUTFILE= "&dir_v7\DKL_Data Issues Check.xlsx" replace; SHEET="ext_BA_zero"; RUN; 
 
data BA_VnoBATPH;
set PolyAndLayer;
if INVENTORY_STANDARD_CODE='V' and (BASAL_AREA_75 in (., 0) or STEMS_PER_HA_75 in (., 0));
keep FEATURE_ID INVENTORY_STANDARD_CODE  BASAL_AREA_75  STEMS_PER_HA_75;
run;
/*
NOTE: There were 219326 observations read from the data set
      WORK.POLYANDLAYER.
NOTE: The data set WORK.BA_VNOBATPH has 3129 observations and 4

*/

data BA_noFnoBATPH;
set PolyAndLayer;
if INVENTORY_STANDARD_CODE ne 'F' and (BASAL_AREA_75 in (., 0) or STEMS_PER_HA_75 in (., 0));
keep FEATURE_ID INVENTORY_STANDARD_CODE  BASAL_AREA_75  STEMS_PER_HA_75;
run;
/*
NOTE: There were 219326 observations read from the data set
      WORK.POLYANDLAYER.
NOTE: The data set WORK.BA_NOFNOBATPH has 21516 observations and 4

*/

data BA_FwithBATPH;
set PolyAndLayer;
if INVENTORY_STANDARD_CODE='F' and (BASAL_AREA_75>0 or STEMS_PER_HA_75>0);
keep FEATURE_ID INVENTORY_STANDARD_CODE  BASAL_AREA_75  STEMS_PER_HA_75;
run;
/*
NOTE: There were 219326 observations read from the data set
      WORK.POLYANDLAYER.
NOTE: The data set WORK.BA_FWITHBATPH has 79707 observations and 4

*/

 PROC EXPORT DATA=BA_VnoBATPH
 OUTFILE= "&dir_v7\DKL_Data Issues Check.xlsx"  DBMS=EXCEL2000 REPLACE;     SHEET="BA_VnoBATPH"; RUN; 
 PROC EXPORT DATA=BA_noFnoBATPH
 OUTFILE= "&dir_v7\DKL_Data Issues Check.xlsx"  DBMS=EXCEL2000 REPLACE;     SHEET="BA_noFnoBATPH"; RUN; 
 PROC EXPORT DATA=BA_FwithBATPH
 OUTFILE= "&dir_v7\DKL_Data Issues Check.xlsx"  DBMS=EXCEL2000 REPLACE;     SHEET="BA_FwithBATPH"; RUN; 


 /*check TPH*/
data TPH_big; set PolyAndLayer;
where STEMS_PER_HA_75>10000;	RUN;
/**/

data TPH_big2; set PolyAndLayer;
if STEMS_PER_HA_75>5000 and EST_AGE_SPP1>30;	RUN;
/*
NOTE: There were 219326 observations read from the data set
      WORK.POLYANDLAYER.
NOTE: The data set WORK.TPH_BIG2 has 114 observations and 77 variables.

*/


data TPH_zero; set PolyAndLayer;
where INVENTORY_STANDARD_CODE in ("V") and  STEMS_PER_HA_75 in (0, .);	RUN;
/*
NOTE: There were 63 observations read from the data set
      WORK.POLYANDLAYER.
      WHERE (INVENTORY_STANDARD_CODE='V') and STEMS_PER_HA_75 in (., 0);
NOTE: The data set WORK.TPH_ZERO has 63 observations and 77 variables.


*/

PROC EXPORT DATA=TPH_big2 dbms=EXCEL OUTFILE= "&dir_v7\DKL_Data Issues Check.xlsx" replace; SHEET="TPH_big2"; RUN; 
PROC EXPORT DATA=TPH_zero dbms=EXCEL OUTFILE= "&dir_v7\DKL_Data Issues Check.xlsx" replace; SHEET="TPH_zero"; RUN; 
 
data TPH_small;
set PolyAndLayer  ;
if  0<STEMS_PER_HA_75<=20;run;
/*FIP STANDS HAVE NO TPH*/
/*
NOTE: There were 219326 observations read from the data set
      WORK.POLYANDLAYER.
NOTE: The data set WORK.TPH_SMALL has 6191 observations and 77 variables.

*/
PROC EXPORT DATA=TPH_small dbms=EXCEL OUTFILE= "&dir_v7\DKL_Data Issues Check.xlsx" replace;  SHEET="TPH_small"; RUN; 

 
 /*check CC*/
 data CC;
set PolyAndLayer  ;
if CROWN_CLOSURE in (. ,0);run;
/* some are due to I inventory standard, no CC and NO Basal Area???

will cause some differences in Stockability.

NOTE: There were 219326 observations read from the data set
      WORK.POLYANDLAYER.
NOTE: The data set WORK.CC has 936 observations and 77 variables.


*/
PROC EXPORT DATA=CC dbms=EXCEL OUTFILE= "&dir_v7\DKL_Data Issues Check.xlsx" replace;  SHEET="CC"; RUN; 

 /*SI check*/
data SIest;
set PolyAndLayer  ;
if EST_AGE_SPP1<=30 AND (EST_SITE_INDEX_SPECIES_CD='' OR   ESTIMATED_SITE_INDEX=. );run;
/*
NOTE: There were 219326 observations read from the data set
      WORK.POLYANDLAYER.
NOTE: The data set WORK.SIEST has 3037 observations and 77 variables.


*/
PROC EXPORT DATA=SIest dbms=EXCEL OUTFILE= "&dir_v7\DKL_Data Issues Check.xlsx" replace;   SHEET="SIest"; RUN; 



 /*check INVENTORY_STANDARD_CODE*/
data INV_noVF; set PolyAndLayer;
where INVENTORY_STANDARD_CODE not in ("V", "F");	RUN;
/* I STANDARD inventory

NOTE: There were 26042 observations read from the data set
      WORK.POLYANDLAYER.
      WHERE INVENTORY_STANDARD_CODE not in ('F', 'V');
NOTE: The data set WORK.INV_NOVF has 26042 observations and 77 variables.

*/
PROC EXPORT DATA=INV_noVF dbms=EXCEL OUTFILE= "&dir_v7\DKL_Data Issues Check.xlsx" replace; SHEET="INV_noVF"; RUN; 

 
 /*check PRE_DISTURBANCE_STOCKABILITY*/
 data STK;
set PolyAndLayer  ;
if PRE_DISTURBANCE_STOCKABILITY IN (. ,0);run;
/* 
*/
 data STK5;
set PolyAndLayer  ;
if PRE_DISTURBANCE_STOCKABILITY<=5;run;
PROC EXPORT DATA=STK dbms=EXCEL OUTFILE= "&dir_v7\DKL_Data Issues Check.xlsx" replace; SHEET="STK"; RUN; 
/*
NOTE: There were 219326 observations read from the data set
      WORK.POLYANDLAYER.
NOTE: The data set WORK.STK5 has 3298 observations and 77 variabl
*/


 /*Disturbance check*/
 data Dist;
set PolyAndLayer  ;
if DISTURBANCE_START_DATE='' and DISTURBANCE_END_DATE='' 
         and DISTURBANCE_METHOD ne ''  ;run;
/**/
PROC EXPORT DATA=Dist dbms=EXCEL OUTFILE= "&dir_v7\DKL_Data Issues Check.xlsx" replace; SHEET="Dist"; RUN; 




 /*check Spp*/
 data SPP1;
set PolyAndLayer  ;
if /*BCLCS_LEVEL1_CODE not in ('V', 'v') or   BCLCS_LEVEL2_CODE not in ('T', 't') or*/
SPECIES_CD_1="" ;run;
/*
*/
PROC EXPORT DATA=SPP1 dbms=EXCEL 
OUTFILE= "&dir_v7\DKL_Data Issues Check.xlsx" replace;
 SHEET="SPP1_TEST"; RUN; 
data err_PCT;
set PolyAndLayer;
array miss_to_zero(6) SPECIES_PCT_1 SPECIES_PCT_2  SPECIES_PCT_3  SPECIES_PCT_4  SPECIES_PCT_5
   SPECIES_PCT_6;
do i = 1 to 6; if miss_to_zero(i)=. then do; miss_to_zero(i)=0; end; end;

Pct=SPECIES_PCT_1+SPECIES_PCT_2+SPECIES_PCT_3+SPECIES_PCT_4+SPECIES_PCT_5+SPECIES_PCT_6 ;
if   pct = 100 then delete;
run;
/*
NOTE: There were 219326 observations read from the data set
      WORK.POLYANDLAYER.
NOTE: The data set WORK.ERR_PCT has 35 observations and 79 variables.

*/
data err_PCT2;
set  err_PCT;
if SPECIES_CD_1 ne "" ;run;
/*
NOTE: There were 35 observations read from the data set WORK.ERR_PCT.
NOTE: The data set WORK.ERR_PCT2 has 35 observations and 79 variables.

*/
PROC EXPORT DATA=err_PCT2 dbms=EXCEL OUTFILE= "&dir_v7\DKL_Data Issues Check.xlsx" replace;   SHEET="err_PCT"; RUN; 



 /*check BCLCS*/
data BCLCS;
set PolyAndLayer;
if BCLCS_LEVEL1_CODE='' or BCLCS_LEVEL2_CODE='';
keep FEATURE_ID BEC_ZONE_CODE  BCLCS_LEVEL1_CODE  BCLCS_LEVEL2_CODE;
run;
/*
*/
 PROC EXPORT DATA=BCLCS  OUTFILE= "&dir_v7\DKL_Data Issues Check.xlsx"  DBMS=EXCEL2000 REPLACE;     SHEET="BCLCS"; RUN; 


 /*check BEC*/
data BEC;
set PolyAndLayer;
if BEC_ZONE_CODE='' or BEC_ZONE_CODE='IMA';
keep FEATURE_ID BEC_ZONE_CODE  BCLCS_LEVEL1_CODE  BCLCS_LEVEL2_CODE;
run;
/*
NOTE: There were 219326 observations read from the data set
      WORK.POLYANDLAYER.
NOTE: The data set WORK.BCLCS has 8 observations and 4 variables.

*/

 PROC EXPORT DATA=BEC  OUTFILE= "&dir_v7\DKL_Data Issues Check.xlsx"  DBMS=EXCEL2000 REPLACE;     SHEET="BEC"; RUN; 

data summ;
set  PolyAndLayer;
if BCLCS_LEVEL1_CODE='V' and BCLCS_LEVEL2_CODE='T' and  BEC_ZONE_CODE not in ('', 'IMA');
 run;
/*
NOTE: There were 219326 observations read from the data set
      WORK.POLYANDLAYER.
NOTE: The data set WORK.SUMM has 201496 observations and 77 variables.

*/

proc summary data=summ;  var BASAL_AREA_75 ; output out=summ4 
mean=BA_mean max=BA_max min=BA_min  std=BA_std n=n;  *class Stratum2; run;

 PROC EXPORT DATA=summ4  OUTFILE= "&dir_v7\Summary Data.xls"    DBMS=EXCEL2000 REPLACE;     SHEET="BA"; RUN;

/*check potential data issues*/
data BEC_old;
set PolyAndLayer  ;
IF BEC_ZONE_CODE NOT in ( 'CDF', 'CWH', 'MH', 'CMA', 'AT' , 'PP', 'BWBS', 'ESSF' , 'ICH', 'BG'
                          'IDF', 'MS', 'SBPS', 'SBS'  , 'SWB'  );  run;
/**/
 PROC EXPORT DATA=BEC_old  OUTFILE= "&dir_v7\DKL_Data Issues Check.xlsx"  DBMS=EXCEL2000 REPLACE;     SHEET="BEC_old"; RUN; 

	/*EXCLUDED 'AT','BG','IMA','CMA','BAFA'???
if bec_zone in ('IMA','CMA','BAFA') then bec_zone = 'AT'; the AT is the old classification*/
data BEC_old2;
set PolyAndLayer  ;
IF BEC_ZONE_CODE NOT in ( 'CDF', 'CWH', 'MH', 'CMA', 'AT' , 'PP', 'BWBS', 'ESSF' , 'ICH', 'BG'
                 'IDF', 'MS', 'SBPS', 'SBS'  , 'SWB', 'IMA','CMA','BAFA'  );
 run;
/*these are missing BEC_ZONE_CODE OR WRONG BEC_ZONE_CODE*/ 
 PROC EXPORT DATA=BEC_old2  OUTFILE= "&dir_v7\DKL_Data Issues Check.xlsx"  DBMS=EXCEL2000 REPLACE;     SHEET="BEC_old2"; RUN; 




OPTIONS NOXWAIT;
RUN;
X cd E:\\VDYP7_YT_TSR_Prod\KootenayLake;

X DKL_125175_0To250_byLayerSpp_N1.cmd;        /*ONLY 1 LAYER POLYS*/
X DKL_125175_1516To2316Inc1_byLayerSpp_N2.cmd;/*MULTI LAYERS POLYS*/



/*for GET the VDYP7 OUTPUT from csv output WITH SPP LEVEL DETAILS
for the the VDYP7 CFSbiom version, for the volumes only, the same format of the CFS biomass version and MBP version*/
%macro Import_CSVOUT_BySpp(dir_v7, file_in, file_out);

      data &file_out;                                  ;
   %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
    infile "&dir_v7\&file_in..csv" delimiter = ',' MISSOVER DSD lrecl=32767 ;

informat	TABLE_NUM	best32.;
informat	FEATURE_ID	best32.;
informat	DISTRICT	$15.;
informat	MAP_ID	$15.;
informat	POLYGON_ID	best32.;
informat	LAYER_ID	$1.;
informat	PROJECTION_YEAR	best32.;
informat	PRJ_TOTAL_AGE	best32.;
informat	SPECIES_1_CODE	$3.;
informat	SPECIES_1_PCNT	best32.;
informat	SPECIES_2_CODE	$3.;
informat	SPECIES_2_PCNT	best32.;
informat	SPECIES_3_CODE	$3.;
informat	SPECIES_3_PCNT	best32.;
informat	SPECIES_4_CODE	$3.;
informat	SPECIES_4_PCNT	best32.;
informat	SPECIES_5_CODE	$3.;
informat	SPECIES_5_PCNT	best32.;
informat	SPECIES_6_CODE	$3.;
informat	SPECIES_6_PCNT	best32.;
informat	PRJ_PCNT_STOCK	best32.;
informat	PRJ_SITE_INDEX	best32.;
informat	PRJ_DOM_HT	best32.;
informat	PRJ_LOREY_HT	best32.;
informat	PRJ_DIAMETER	best32.;
informat	PRJ_TPH	best32.;
informat	PRJ_BA	best32.;
informat	PRJ_VOL_WS	best32.;
informat	PRJ_VOL_CU	best32.;
informat	PRJ_VOL_D	best32.;
informat	PRJ_VOL_DW	best32.;
informat	PRJ_VOL_DWB	best32.;
informat	PRJ_SP1_VOL_WS	best32.;
informat	PRJ_SP1_VOL_CU	best32.;
informat	PRJ_SP1_VOL_D	best32.;
informat	PRJ_SP1_VOL_DW	best32.;
informat	PRJ_SP1_VOL_DWB	best32.;
informat	PRJ_SP2_VOL_WS	best32.;
informat	PRJ_SP2_VOL_CU	best32.;
informat	PRJ_SP2_VOL_D	best32.;
informat	PRJ_SP2_VOL_DW	best32.;
informat	PRJ_SP2_VOL_DWB	best32.;
informat	PRJ_SP3_VOL_WS	best32.;
informat	PRJ_SP3_VOL_CU	best32.;
informat	PRJ_SP3_VOL_D	best32.;
informat	PRJ_SP3_VOL_DW	best32.;
informat	PRJ_SP3_VOL_DWB	best32.;
informat	PRJ_SP4_VOL_WS	best32.;
informat	PRJ_SP4_VOL_CU	best32.;
informat	PRJ_SP4_VOL_D	best32.;
informat	PRJ_SP4_VOL_DW	best32.;
informat	PRJ_SP4_VOL_DWB	best32.;
informat	PRJ_SP5_VOL_WS	best32.;
informat	PRJ_SP5_VOL_CU	best32.;
informat	PRJ_SP5_VOL_D	best32.;
informat	PRJ_SP5_VOL_DW	best32.;
informat	PRJ_SP5_VOL_DWB	best32.;
informat	PRJ_SP6_VOL_WS	best32.;
informat	PRJ_SP6_VOL_CU	best32.;
informat	PRJ_SP6_VOL_D	best32.;
informat	PRJ_SP6_VOL_DW	best32.;
informat	PRJ_SP6_VOL_DWB	best32.;
informat	PRJ_MODE	$4.;
format	TABLE_NUM	best12.;
format	FEATURE_ID	best12.;
format	DISTRICT	$15.;
format	MAP_ID	$15.;
format	POLYGON_ID	best12.;
format	LAYER_ID	$1.;
format	PROJECTION_YEAR	best12.;
format	PRJ_TOTAL_AGE	best12.;
format	SPECIES_1_CODE	$3.;
format	SPECIES_1_PCNT	best12.;
format	SPECIES_2_CODE	$3.;
format	SPECIES_2_PCNT	best12.;
format	SPECIES_3_CODE	$3.;
format	SPECIES_3_PCNT	best12.;
format	SPECIES_4_CODE	$3.;
format	SPECIES_4_PCNT	best12.;
format	SPECIES_5_CODE	$3.;
format	SPECIES_5_PCNT	best12.;
format	SPECIES_6_CODE	$3.;
format	SPECIES_6_PCNT	best12.;
format	PRJ_PCNT_STOCK	best12.;
format	PRJ_SITE_INDEX	best12.;
format	PRJ_DOM_HT	best12.;
format	PRJ_LOREY_HT	best12.;
format	PRJ_DIAMETER	best12.;
format	PRJ_TPH	best12.;
format	PRJ_BA	best12.;
format	PRJ_VOL_WS	best12.;
format	PRJ_VOL_CU	best12.;
format	PRJ_VOL_D	best12.;
format	PRJ_VOL_DW	best12.;
format	PRJ_VOL_DWB	best12.;
format	PRJ_SP1_VOL_WS	best12.;
format	PRJ_SP1_VOL_CU	best12.;
format	PRJ_SP1_VOL_D	best12.;
format	PRJ_SP1_VOL_DW	best12.;
format	PRJ_SP1_VOL_DWB	best12.;
format	PRJ_SP2_VOL_WS	best12.;
format	PRJ_SP2_VOL_CU	best12.;
format	PRJ_SP2_VOL_D	best12.;
format	PRJ_SP2_VOL_DW	best12.;
format	PRJ_SP2_VOL_DWB	best12.;
format	PRJ_SP3_VOL_WS	best12.;
format	PRJ_SP3_VOL_CU	best12.;
format	PRJ_SP3_VOL_D	best12.;
format	PRJ_SP3_VOL_DW	best12.;
format	PRJ_SP3_VOL_DWB	best12.;
format	PRJ_SP4_VOL_WS	best12.;
format	PRJ_SP4_VOL_CU	best12.;
format	PRJ_SP4_VOL_D	best12.;
format	PRJ_SP4_VOL_DW	best12.;
format	PRJ_SP4_VOL_DWB	best12.;
format	PRJ_SP5_VOL_WS	best12.;
format	PRJ_SP5_VOL_CU	best12.;
format	PRJ_SP5_VOL_D	best12.;
format	PRJ_SP5_VOL_DW	best12.;
format	PRJ_SP5_VOL_DWB	best12.;
format	PRJ_SP6_VOL_WS	best12.;
format	PRJ_SP6_VOL_CU	best12.;
format	PRJ_SP6_VOL_D	best12.;
format	PRJ_SP6_VOL_DW	best12.;
format	PRJ_SP6_VOL_DWB	best12.;
format	PRJ_MODE	$4.;


      input

 TABLE_NUM	
FEATURE_ID	
DISTRICT	$
MAP_ID	$
POLYGON_ID	
LAYER_ID	$
PROJECTION_YEAR	
PRJ_TOTAL_AGE	
SPECIES_1_CODE	$
SPECIES_1_PCNT	
SPECIES_2_CODE	$
SPECIES_2_PCNT	
SPECIES_3_CODE	$
SPECIES_3_PCNT	
SPECIES_4_CODE	$
SPECIES_4_PCNT	
SPECIES_5_CODE	$
SPECIES_5_PCNT	
SPECIES_6_CODE	$
SPECIES_6_PCNT	
PRJ_PCNT_STOCK	
PRJ_SITE_INDEX	
PRJ_DOM_HT	
PRJ_LOREY_HT	
PRJ_DIAMETER	
PRJ_TPH	
PRJ_BA	
PRJ_VOL_WS	
PRJ_VOL_CU	
PRJ_VOL_D	
PRJ_VOL_DW	
PRJ_VOL_DWB	
PRJ_SP1_VOL_WS	
PRJ_SP1_VOL_CU	
PRJ_SP1_VOL_D	
PRJ_SP1_VOL_DW	
PRJ_SP1_VOL_DWB	
PRJ_SP2_VOL_WS	
PRJ_SP2_VOL_CU	
PRJ_SP2_VOL_D	
PRJ_SP2_VOL_DW	
PRJ_SP2_VOL_DWB	
PRJ_SP3_VOL_WS	
PRJ_SP3_VOL_CU	
PRJ_SP3_VOL_D	
PRJ_SP3_VOL_DW	
PRJ_SP3_VOL_DWB	
PRJ_SP4_VOL_WS	
PRJ_SP4_VOL_CU	
PRJ_SP4_VOL_D	
PRJ_SP4_VOL_DW	
PRJ_SP4_VOL_DWB	
PRJ_SP5_VOL_WS	
PRJ_SP5_VOL_CU	
PRJ_SP5_VOL_D	
PRJ_SP5_VOL_DW	
PRJ_SP5_VOL_DWB	
PRJ_SP6_VOL_WS	
PRJ_SP6_VOL_CU	
PRJ_SP6_VOL_D	
PRJ_SP6_VOL_DW	
PRJ_SP6_VOL_DWB	
PRJ_MODE	$
;
      if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
      run;
%mend;


/*for GET the VDYP7 OUTPUT from csv output WITH SPP LEVEL DETAILS*/
%macro Import_CSVO_SCND_HT_BySpp(dir_v7, file_in, file_out);

      data &file_out;                                  ;
   %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
    infile "&dir_v7\&file_in..csv" delimiter = ',' MISSOVER DSD lrecl=32767 ;

informat	TABLE_NUM	best32.;
informat	FEATURE_ID	best32.;
informat	DISTRICT	$15.;
informat	MAP_ID	$15.;
informat	POLYGON_ID	best32.;
informat	LAYER_ID	$1.;
informat	PROJECTION_YEAR	best32.;
informat	PRJ_TOTAL_AGE	best32.;
informat	SPECIES_1_CODE	$3.;
informat	SPECIES_1_PCNT	best32.;
informat	SPECIES_2_CODE	$3.;
informat	SPECIES_2_PCNT	best32.;
informat	SPECIES_3_CODE	$3.;
informat	SPECIES_3_PCNT	best32.;
informat	SPECIES_4_CODE	$3.;
informat	SPECIES_4_PCNT	best32.;
informat	SPECIES_5_CODE	$3.;
informat	SPECIES_5_PCNT	best32.;
informat	SPECIES_6_CODE	$3.;
informat	SPECIES_6_PCNT	best32.;
informat	PRJ_PCNT_STOCK	best32.;
informat	PRJ_SITE_INDEX	best32.;
informat	PRJ_DOM_HT	best32.;
informat	PRJ_SCND_HT	best32.;

informat	PRJ_LOREY_HT	best32.;
informat	PRJ_DIAMETER	best32.;
informat	PRJ_TPH	best32.;
informat	PRJ_BA	best32.;
informat	PRJ_VOL_WS	best32.;
informat	PRJ_VOL_CU	best32.;
informat	PRJ_VOL_D	best32.;
informat	PRJ_VOL_DW	best32.;
informat	PRJ_VOL_DWB	best32.;
informat	PRJ_SP1_VOL_WS	best32.;
informat	PRJ_SP1_VOL_CU	best32.;
informat	PRJ_SP1_VOL_D	best32.;
informat	PRJ_SP1_VOL_DW	best32.;
informat	PRJ_SP1_VOL_DWB	best32.;
informat	PRJ_SP2_VOL_WS	best32.;
informat	PRJ_SP2_VOL_CU	best32.;
informat	PRJ_SP2_VOL_D	best32.;
informat	PRJ_SP2_VOL_DW	best32.;
informat	PRJ_SP2_VOL_DWB	best32.;
informat	PRJ_SP3_VOL_WS	best32.;
informat	PRJ_SP3_VOL_CU	best32.;
informat	PRJ_SP3_VOL_D	best32.;
informat	PRJ_SP3_VOL_DW	best32.;
informat	PRJ_SP3_VOL_DWB	best32.;
informat	PRJ_SP4_VOL_WS	best32.;
informat	PRJ_SP4_VOL_CU	best32.;
informat	PRJ_SP4_VOL_D	best32.;
informat	PRJ_SP4_VOL_DW	best32.;
informat	PRJ_SP4_VOL_DWB	best32.;
informat	PRJ_SP5_VOL_WS	best32.;
informat	PRJ_SP5_VOL_CU	best32.;
informat	PRJ_SP5_VOL_D	best32.;
informat	PRJ_SP5_VOL_DW	best32.;
informat	PRJ_SP5_VOL_DWB	best32.;
informat	PRJ_SP6_VOL_WS	best32.;
informat	PRJ_SP6_VOL_CU	best32.;
informat	PRJ_SP6_VOL_D	best32.;
informat	PRJ_SP6_VOL_DW	best32.;
informat	PRJ_SP6_VOL_DWB	best32.;
informat	PRJ_MODE	$4.;
format	TABLE_NUM	best12.;
format	FEATURE_ID	best12.;
format	DISTRICT	$15.;
format	MAP_ID	$15.;
format	POLYGON_ID	best12.;
format	LAYER_ID	$1.;
format	PROJECTION_YEAR	best12.;
format	PRJ_TOTAL_AGE	best12.;
format	SPECIES_1_CODE	$3.;
format	SPECIES_1_PCNT	best12.;
format	SPECIES_2_CODE	$3.;
format	SPECIES_2_PCNT	best12.;
format	SPECIES_3_CODE	$3.;
format	SPECIES_3_PCNT	best12.;
format	SPECIES_4_CODE	$3.;
format	SPECIES_4_PCNT	best12.;
format	SPECIES_5_CODE	$3.;
format	SPECIES_5_PCNT	best12.;
format	SPECIES_6_CODE	$3.;
format	SPECIES_6_PCNT	best12.;
format	PRJ_PCNT_STOCK	best12.;
format	PRJ_SITE_INDEX	best12.;
format	PRJ_DOM_HT	best12.;
format	PRJ_SCND_HT	best12.;

format	PRJ_LOREY_HT	best12.;
format	PRJ_DIAMETER	best12.;
format	PRJ_TPH	best12.;
format	PRJ_BA	best12.;
format	PRJ_VOL_WS	best12.;
format	PRJ_VOL_CU	best12.;
format	PRJ_VOL_D	best12.;
format	PRJ_VOL_DW	best12.;
format	PRJ_VOL_DWB	best12.;
format	PRJ_SP1_VOL_WS	best12.;
format	PRJ_SP1_VOL_CU	best12.;
format	PRJ_SP1_VOL_D	best12.;
format	PRJ_SP1_VOL_DW	best12.;
format	PRJ_SP1_VOL_DWB	best12.;
format	PRJ_SP2_VOL_WS	best12.;
format	PRJ_SP2_VOL_CU	best12.;
format	PRJ_SP2_VOL_D	best12.;
format	PRJ_SP2_VOL_DW	best12.;
format	PRJ_SP2_VOL_DWB	best12.;
format	PRJ_SP3_VOL_WS	best12.;
format	PRJ_SP3_VOL_CU	best12.;
format	PRJ_SP3_VOL_D	best12.;
format	PRJ_SP3_VOL_DW	best12.;
format	PRJ_SP3_VOL_DWB	best12.;
format	PRJ_SP4_VOL_WS	best12.;
format	PRJ_SP4_VOL_CU	best12.;
format	PRJ_SP4_VOL_D	best12.;
format	PRJ_SP4_VOL_DW	best12.;
format	PRJ_SP4_VOL_DWB	best12.;
format	PRJ_SP5_VOL_WS	best12.;
format	PRJ_SP5_VOL_CU	best12.;
format	PRJ_SP5_VOL_D	best12.;
format	PRJ_SP5_VOL_DW	best12.;
format	PRJ_SP5_VOL_DWB	best12.;
format	PRJ_SP6_VOL_WS	best12.;
format	PRJ_SP6_VOL_CU	best12.;
format	PRJ_SP6_VOL_D	best12.;
format	PRJ_SP6_VOL_DW	best12.;
format	PRJ_SP6_VOL_DWB	best12.;
format	PRJ_MODE	$4.;


      input

 TABLE_NUM	
FEATURE_ID	
DISTRICT	$
MAP_ID	$
POLYGON_ID	
LAYER_ID	$
PROJECTION_YEAR	
PRJ_TOTAL_AGE	
SPECIES_1_CODE	$
SPECIES_1_PCNT	
SPECIES_2_CODE	$
SPECIES_2_PCNT	
SPECIES_3_CODE	$
SPECIES_3_PCNT	
SPECIES_4_CODE	$
SPECIES_4_PCNT	
SPECIES_5_CODE	$
SPECIES_5_PCNT	
SPECIES_6_CODE	$
SPECIES_6_PCNT	
PRJ_PCNT_STOCK	
PRJ_SITE_INDEX	
PRJ_DOM_HT	
PRJ_SCND_HT
PRJ_LOREY_HT	
PRJ_DIAMETER	
PRJ_TPH	
PRJ_BA	
PRJ_VOL_WS	
PRJ_VOL_CU	
PRJ_VOL_D	
PRJ_VOL_DW	
PRJ_VOL_DWB	
PRJ_SP1_VOL_WS	
PRJ_SP1_VOL_CU	
PRJ_SP1_VOL_D	
PRJ_SP1_VOL_DW	
PRJ_SP1_VOL_DWB	
PRJ_SP2_VOL_WS	
PRJ_SP2_VOL_CU	
PRJ_SP2_VOL_D	
PRJ_SP2_VOL_DW	
PRJ_SP2_VOL_DWB	
PRJ_SP3_VOL_WS	
PRJ_SP3_VOL_CU	
PRJ_SP3_VOL_D	
PRJ_SP3_VOL_DW	
PRJ_SP3_VOL_DWB	
PRJ_SP4_VOL_WS	
PRJ_SP4_VOL_CU	
PRJ_SP4_VOL_D	
PRJ_SP4_VOL_DW	
PRJ_SP4_VOL_DWB	
PRJ_SP5_VOL_WS	
PRJ_SP5_VOL_CU	
PRJ_SP5_VOL_D	
PRJ_SP5_VOL_DW	
PRJ_SP5_VOL_DWB	
PRJ_SP6_VOL_WS	
PRJ_SP6_VOL_CU	
PRJ_SP6_VOL_D	
PRJ_SP6_VOL_DW	
PRJ_SP6_VOL_DWB	
PRJ_MODE	$
;
      if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
      run;
%mend;


/*for GET the VDYP7 OUTPUT from csv output WITHOUT SPP LEVEL DETAILS*/
%macro Import_CSVO_SCND_HT_NoSpp(dir_v7, file_in, file_out);

      data &file_out;                                  ;
   %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
    infile "&dir_v7\&file_in..csv" delimiter = ',' MISSOVER DSD lrecl=32767 ;

informat	TABLE_NUM	best32.;
informat	FEATURE_ID	best32.;
informat	DISTRICT	$15.;
informat	MAP_ID	$15.;
informat	POLYGON_ID	best32.;
informat	LAYER_ID	$1.;
informat	PROJECTION_YEAR	best32.;
informat	PRJ_TOTAL_AGE	best32.;
informat	SPECIES_1_CODE	$3.;
informat	SPECIES_1_PCNT	best32.;
informat	SPECIES_2_CODE	$3.;
informat	SPECIES_2_PCNT	best32.;
informat	SPECIES_3_CODE	$3.;
informat	SPECIES_3_PCNT	best32.;
informat	SPECIES_4_CODE	$3.;
informat	SPECIES_4_PCNT	best32.;
informat	SPECIES_5_CODE	$3.;
informat	SPECIES_5_PCNT	best32.;
informat	SPECIES_6_CODE	$3.;
informat	SPECIES_6_PCNT	best32.;
informat	PRJ_PCNT_STOCK	best32.;
informat	PRJ_SITE_INDEX	best32.;
informat	PRJ_DOM_HT	best32.;
informat	PRJ_SCND_HT	best32.;

informat	PRJ_LOREY_HT	best32.;
informat	PRJ_DIAMETER	best32.;
informat	PRJ_TPH	best32.;
informat	PRJ_BA	best32.;
informat	PRJ_VOL_WS	best32.;
informat	PRJ_VOL_CU	best32.;
informat	PRJ_VOL_D	best32.;
informat	PRJ_VOL_DW	best32.;
informat	PRJ_VOL_DWB	best32.;
informat	PRJ_MODE	$4.;
format	TABLE_NUM	best12.;
format	FEATURE_ID	best12.;
format	DISTRICT	$15.;
format	MAP_ID	$15.;
format	POLYGON_ID	best12.;
format	LAYER_ID	$1.;
format	PROJECTION_YEAR	best12.;
format	PRJ_TOTAL_AGE	best12.;
format	SPECIES_1_CODE	$3.;
format	SPECIES_1_PCNT	best12.;
format	SPECIES_2_CODE	$3.;
format	SPECIES_2_PCNT	best12.;
format	SPECIES_3_CODE	$3.;
format	SPECIES_3_PCNT	best12.;
format	SPECIES_4_CODE	$3.;
format	SPECIES_4_PCNT	best12.;
format	SPECIES_5_CODE	$3.;
format	SPECIES_5_PCNT	best12.;
format	SPECIES_6_CODE	$3.;
format	SPECIES_6_PCNT	best12.;
format	PRJ_PCNT_STOCK	best12.;
format	PRJ_SITE_INDEX	best12.;
format	PRJ_DOM_HT	best12.;
format	PRJ_SCND_HT	best12.;

format	PRJ_LOREY_HT	best12.;
format	PRJ_DIAMETER	best12.;
format	PRJ_TPH	best12.;
format	PRJ_BA	best12.;
format	PRJ_VOL_WS	best12.;
format	PRJ_VOL_CU	best12.;
format	PRJ_VOL_D	best12.;
format	PRJ_VOL_DW	best12.;
format	PRJ_VOL_DWB	best12.;
format	PRJ_MODE	$4.;


      input

 TABLE_NUM	
FEATURE_ID	
DISTRICT	$
MAP_ID	$
POLYGON_ID	
LAYER_ID	$
PROJECTION_YEAR	
PRJ_TOTAL_AGE	
SPECIES_1_CODE	$
SPECIES_1_PCNT	
SPECIES_2_CODE	$
SPECIES_2_PCNT	
SPECIES_3_CODE	$
SPECIES_3_PCNT	
SPECIES_4_CODE	$
SPECIES_4_PCNT	
SPECIES_5_CODE	$
SPECIES_5_PCNT	
SPECIES_6_CODE	$
SPECIES_6_PCNT	
PRJ_PCNT_STOCK	
PRJ_SITE_INDEX	
PRJ_DOM_HT	
PRJ_SCND_HT
PRJ_LOREY_HT	
PRJ_DIAMETER	
PRJ_TPH	
PRJ_BA	
PRJ_VOL_WS	
PRJ_VOL_CU	
PRJ_VOL_D	
PRJ_VOL_DW	
PRJ_VOL_DWB	
PRJ_MODE	$
;
      if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
      run;
%mend;

/* for the UNADJUSTED YT from Step1*/


%Import_CSVOUT_BySpp(&dir_v7, HCSV-YldTbl_125175_0To250_DKL_N1, V7_Step1_YT0_N1);
/*ONLY 1 LAYER POLYS*/

%Import_CSVOUT_BySpp(&dir_v7, HCSV-YldTbl_125175_YearToYearInc1_DKL_N2, V7_Step1_YT0_N2);
/*MULTI LAYERS POLYS*/
/*here use YEAR 1566 to 2216 by inc=1 year to get the year, age of different layers resolved*/

data V7_Step1_YT1  Dlayer_Step1_YT;
set  V7_Step1_YT0_N1(firstobs=2)
     V7_Step1_YT0_N2(firstobs=2);
*set  V7_Step1_YT0(firstobs=2 obs=10000);

*where FEATURE_ID IN (9009243,9009264, 9012065,9023302);

if FEATURE_ID=88888888 THEN DELETE;
if LAYER_ID ne "D" then output V7_Step1_YT1;/*only live layers, no D-layer*/
if LAYER_ID="D" then output    Dlayer_Step1_YT;
run;
/*
NOTE: There were 4209486 observations read from the data set
      WORK.V7_STEP1_YT0_N1.
NOTE: There were 8762243 observations read from the data set
      WORK.V7_STEP1_YT0_N2.
NOTE: The data set WORK.V7_STEP1_YT1 has 12947172 observations and 63
      variables.
NOTE: The data set WORK.DLAYER_STEP1_YT has 24557 observations and 63

*/
proc sort data=V7_Step1_YT1;  by FEATURE_ID  LAYER_ID;run;

data FID2;
set V7_Step1_YT1;
if first.FEATURE_ID;
by FEATURE_ID;run;
/*
NOTE: There were 12947172 observations read from the data set
      WORK.V7_STEP1_YT1.
NOTE: The data set WORK.FID2 has 175805 observations and 63 variables.

*/


/*FOR MERGING TO GET SP0 OR spp_grp*/
PROC SORT data=spv_spk;
BY SPECIES_CD_1;RUN;

PROC SORT data=LAYER;
BY SPECIES_CD_1;RUN;


data L_Step1_YT_P;
*RETAIN SPECIES_CD_1 spp_grp Strata;
*set  LAYER;
MERGE  LAYER(IN=AA)  spv_spk;
*IF AA;
IF AA  and VDYP7_LAYER_CD="P";
BY SPECIES_CD_1;

FORMAT LAYER_ID $1.;
LAYER_ID=LAYER_LEVEL_CODE;

format Strata $6. ;

format Strata $6. ;
*spp_grp=PUT (UPCASE(SPECIES_CD_1), $SPV_SPK.);

if   spp_grp  in  ('AC')  then  Strata='AC';
if   spp_grp  in  ('AT')  then  Strata='AT';
if   spp_grp  in  ('B')  then  Strata='B';
if   spp_grp  in  ('C')  then  Strata='C';
if   spp_grp  in  ('D')  then  Strata='D';
if   spp_grp  in  ('E')  then  Strata='E';
if   spp_grp  in  ('F')  then  Strata='F';
if   spp_grp  in  ('H')  then  Strata='H';
if   spp_grp  in  ('L')  then  Strata='L';
if   spp_grp  in  ('MB')  then  Strata='MB';
if   spp_grp  in  ('PA')  then  Strata='PA';
if   spp_grp  in  ('PL')  then  Strata='PL';
if   spp_grp  in  ('PW')  then  Strata='PW';
if   spp_grp  in  ('PY')  then  Strata='PY';
if   spp_grp  in  ('S')  then  Strata='S';
if   spp_grp  in  ('Y')  then  Strata='Y';

if Strata='' then DO; Strata="NoAdj";END;

*WHERE VDYP7_LAYER_CD="P";
KEEP FEATURE_ID  Strata LAYER_LEVEL_CODE LAYER_ID VDYP7_LAYER_CD FOREST_COVER_RANK_CODE;
RUN;
/*
NOTE: There were 219326 observations read from the data set WORK.LAYER.
NOTE: There were 132 observations read from the data set WORK.SPV_SPK.
NOTE: The data set WORK.L_STEP1_YT_P has 175580 observations and 6

*/
proc sort;  by FEATURE_ID  LAYER_ID;run;

PROC SORT data=LAYER;
by FEATURE_ID  TREE_COVER_LAYER_ESTIMATED_ID;run;


DATA  L_Step1_YT_P2;
MERGE L_Step1_YT_P(IN=A)  V7_Step1_YT1(IN=B KEEP=FEATURE_ID LAYER_ID PRJ_TOTAL_AGE PROJECTION_YEAR);
IF A AND B;
by FEATURE_ID  LAYER_ID;
run;
/* 
NOTE: There were 175580 observations read from the data set      WORK.L_STEP1_YT_P.
NOTE: There were 12947172 observations read from the data set      WORK.V7_STEP1_YT1.
NOTE: The data set WORK.L_STEP1_YT_P2 has 9935833 observations and 8

*/
DATA  L_Step1_YT_P3;
SET   L_Step1_YT_P2;

where PRJ_TOTAL_AGE IN (10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,
160,170,180,190,200,210,220,230,240,250);
KEEP FEATURE_ID  Strata  PRJ_TOTAL_AGE PROJECTION_YEAR;
RUN;
/*
NOTE: There were 4380650 observations read from the data set WORK.L_STEP1_YT_P2.
      WHERE PRJ_TOTAL_AGE in (10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150,
      160, 170, 180, 190, 200, 210, 220, 230, 240, 250);
NOTE: The data set WORK.L_STEP1_YT_P3 has 4380650 observations and 4 variables.
*/

proc sort;  by FEATURE_ID  PROJECTION_YEAR;run;
proc sort  DATA=V7_Step1_YT1;  by FEATURE_ID  PROJECTION_YEAR;run;


/*HERE MUST RUN VDYP7 BY EACH YEAR, OTHERWISE DIFFERENT LAYERS MAY GET AGE/YEAR COMBINATIONS, AND WHEN ADD OR SUM 
THE VOLUMES OF LAYERS AT THE SAME YEAR, MAY MISSING SOME LAYERS IN SOME YEARS*/
data V7_Step1_YT1_AgeYear;
MERGE L_Step1_YT_P3(IN=A  KEEP=FEATURE_ID  PROJECTION_YEAR)  V7_Step1_YT1(IN=B);
IF A AND B;
by FEATURE_ID  PROJECTION_YEAR;run;
/*
NOTE: There were 4380650 observations read from the data set WORK.L_STEP1_YT_P3.
NOTE: There were 12947172 observations read from the data set WORK.V7_STEP1_YT1.
NOTE: The data set WORK.V7_STEP1_YT1_AGEYEAR has 4539661 observations and 63 variables

*/


DATA V7_Step1_YT1_AgeYear0;
SET  V7_Step1_YT1_AgeYear;
 array miss_to_zero(12) PRJ_PCNT_STOCK  PRJ_SITE_INDEX  PRJ_DOM_HT  PRJ_LOREY_HT PRJ_DIAMETER   PRJ_TPH  PRJ_BA  PRJ_VOL_WS     
PRJ_VOL_CU PRJ_VOL_D  PRJ_VOL_DW  PRJ_VOL_DWB;
do i = 1 to 12; if miss_to_zero(i)=. then do; miss_to_zero(i)=0; end; end;
if FEATURE_ID=88888888 then delete;
if FEATURE_ID=1000000 then delete;RUN;

proc sort; by  FEATURE_ID  PROJECTION_YEAR  LAYER_ID ; run;

proc summary data=V7_Step1_YT1_AgeYear0;
var PRJ_PCNT_STOCK  PRJ_SITE_INDEX  PRJ_DOM_HT  PRJ_LOREY_HT PRJ_DIAMETER   PRJ_TPH  PRJ_BA  PRJ_VOL_WS     
PRJ_VOL_CU PRJ_VOL_D  PRJ_VOL_DW  PRJ_VOL_DWB;
output out=V7_Step1_YT1_AgeYear1 MEAN=  n=n;
*by FEATURE_ID  PRJ_TOTAL_AGE   LAYER_ID;
by  FEATURE_ID  PROJECTION_YEAR  LAYER_ID ; run;
run;
/*have MULTI LAYER POLYGONS OR DUPLICATED POLYGONS,
HERE MUST USE MEAN , NOT SUM!!!!!!!!!!!!!!

NOTE: There were 4539661 observations read from the data set WORK.V7_STEP1_YT1_AGEYEAR0.
NOTE: The data set WORK.V7_STEP1_YT1_AGEYEAR1 has 4539661 observations and 18 variables.
*/

data test;
set V7_Step1_YT1_AgeYear1;
where n>1;
run;


proc summary data=V7_Step1_YT1_AgeYear1;
var PRJ_PCNT_STOCK  PRJ_SITE_INDEX  PRJ_DOM_HT  PRJ_LOREY_HT PRJ_DIAMETER   PRJ_TPH  PRJ_BA  PRJ_VOL_WS     
PRJ_VOL_CU PRJ_VOL_D  PRJ_VOL_DW  PRJ_VOL_DWB;

output out=V7_Step1_YT1_AgeYear2 
mean (PRJ_PCNT_STOCK  PRJ_SITE_INDEX  PRJ_DOM_HT  PRJ_LOREY_HT PRJ_DIAMETER )
     =PRJ_PCNT_STOCK  PRJ_SITE_INDEX  PRJ_DOM_HT  PRJ_LOREY_HT PRJ_DIAMETER 
sum (PRJ_TPH  PRJ_BA  PRJ_VOL_WS  PRJ_VOL_CU PRJ_VOL_D  PRJ_VOL_DW  PRJ_VOL_DWB)
    =PRJ_TPH  PRJ_BA  PRJ_VOL_WS  PRJ_VOL_CU PRJ_VOL_D  PRJ_VOL_DW  PRJ_VOL_DWB  
n=n2;
*by FEATURE_ID PRJ_TOTAL_AGE;
by FEATURE_ID PROJECTION_YEAR;
*ID PRJ_TOTAL_AGE; run;
/*SOME TWO LAYERS (PRIMARY AND VETERAN LAYERS) SUM FOR THIS DATASET at the SAME YEAR, 
NOT THE SAME AGE!

NOTE: There were 4539661 observations read from the data set
      WORK.V7_STEP1_YT1_AGEYEAR1.
NOTE: The data set WORK.V7_STEP1_YT1_AGEYEAR2 has 4380650 observations

*/

data  V7_Step1_YT1_AgeYear3;
merge L_Step1_YT_P3(in=a keep=FEATURE_ID  Strata  PRJ_TOTAL_AGE PROJECTION_YEAR) 
      V7_Step1_YT1_AgeYear2(in=b);
IF A AND B;
by FEATURE_ID  PROJECTION_YEAR;

*POLYGON_AREA=1; /*ASSUME TO EQUAL WEIGHT=1 HERE*/
drop  _freq_  _type_; run;
/*
NOTE: There were 4380650 observations read from the data set WORK.L_STEP1_YT_P3.
NOTE: There were 4380650 observations read from the data set WORK.V7_STEP1_YT1_AGEYEAR2.
NOTE: The data set WORK.V7_STEP1_YT1_AGEYEAR3 has 4380650 observations and 17 variables.

*/

/*here the PRJ_TOTAL_AGE in L_Step1_YT_P3 is the Primary layer age of the polygon, and
applied approximately as the stand yield table age*/

PROC SORT; 
by FEATURE_ID   PRJ_TOTAL_AGE ;
run;

data test0;
set V7_Step1_YT1_AgeYear3;
where PRJ_TOTAL_AGE<=20 and PRJ_VOL_DWB>50;
RUN;

data test;
set V7_Step1_YT1_AgeYear3;
where FEATURE_ID IN (9009243,9009264, 9012065,9023302);
RUN;
PROC SORT; 
by FEATURE_ID   PRJ_TOTAL_AGE PROJECTION_YEAR;
run;



data UnAdj_YT3;
/*MERGE V7_Step1_YT1_AgeYear3(in=a) Wt_Feat(in=b);
if a and b;
by FEATURE_ID;*/
set  V7_Step1_YT1_AgeYear3;
run;
/*
NOT TO USE THE Wt_Feat to merge, since it will cause some data loss 

NOTE: There were 4380650 observations read from the data set WORK.V7_STEP1_YT1_AGEYEAR3.
NOTE: The data set WORK.UNADJ_YT3 has 4380650 observations and 17 variables.

*/



data  UnAdj_YT_Check; 
set   UnAdj_YT3;
where FEATURE_ID in (9463515,9909947);  
format data_id $10.; data_id='Original'; run;




/*WORK AROUND NOTES:
for checking data and extreme results in the Un-adjusted population*/
data Extrem_Ori;
set UnAdj_YT3;
*where PRJ_VOL_DWB>=2000;
where PRJ_VOL_DWB>=2200;/*based on the random VRI, NFI AND CMI DATA, IT IS SET AS A THRESHOLD*/
run;
/*
NOTE: There were 0 observations read from the data set WORK.UNADJ_YT3.
      WHERE PRJ_VOL_DWB>=2200;
NOTE: The data set WORK.EXTREM_ORI has 0 observations and 103 variables

*/
proc sort; by FEATURE_ID PRJ_TOTAL_AGE; run;


/*For report the main stats of the volumes*/
proc means data =UnAdj_YT3;

VAR  PRJ_PCNT_STOCK  PRJ_SITE_INDEX  PRJ_DOM_HT  PRJ_LOREY_HT   PRJ_DIAMETER  PRJ_TPH  PRJ_BA  PRJ_VOL_WS  
      PRJ_VOL_CU  PRJ_VOL_D   PRJ_VOL_DW  PRJ_VOL_DWB; 
OUTPUT OUT =DKL.UnAdj_YT3_m
mean =PRJ_PCNT_STOCK_Mean  PRJ_SITE_INDEX_Mean  PRJ_DOM_HT_Mean  PRJ_LOREY_HT_Mean   PRJ_DIAMETER_Mean  PRJ_TPH_Mean  PRJ_BA_Mean  PRJ_VOL_WS_Mean  
      PRJ_VOL_CU_Mean  PRJ_VOL_D_Mean   PRJ_VOL_DW_Mean  PRJ_VOL_DWB_Mean
max  =PRJ_PCNT_STOCK_Max  PRJ_SITE_INDEX_Max  PRJ_DOM_HT_Max  PRJ_LOREY_HT_Max   PRJ_DIAMETER_Max  PRJ_TPH_Max  PRJ_BA_Max  PRJ_VOL_WS_Max  
      PRJ_VOL_CU_Max  PRJ_VOL_D_Max   PRJ_VOL_DW_Max  PRJ_VOL_DWB_Max
min  =PRJ_PCNT_STOCK_Min  PRJ_SITE_INDEX_Min  PRJ_DOM_HT_Min  PRJ_LOREY_HT_Min   PRJ_DIAMETER_Min  PRJ_TPH_Min  PRJ_BA_Min  PRJ_VOL_WS_Min  
      PRJ_VOL_CU_Min  PRJ_VOL_D_Min   PRJ_VOL_DW_Min  PRJ_VOL_DWB_Min
std  =PRJ_PCNT_STOCK_Std  PRJ_SITE_INDEX_Std  PRJ_DOM_HT_Std  PRJ_LOREY_HT_Std   PRJ_DIAMETER_Std  PRJ_TPH_Std  PRJ_BA_Std  PRJ_VOL_WS_Std  
      PRJ_VOL_CU_Std  PRJ_VOL_D_Std   PRJ_VOL_DW_Std  PRJ_VOL_DWB_Std;
*weight POLYGON_AREA;
run;

PROC EXPORT DATA=DKL.UnAdj_YT3_m dbms=EXCEL 
OUTFILE= "E:\\VDYP7_YT_TSR_Prod\KootenayLake\Adj_Unadj_Population.xlsx" replace;
 SHEET="UnAdj3_Stat"; RUN; 


/*for checking data and extreme results in the Un-adjusted population*/
data Extrem_Ori_1500;
set UnAdj_YT3;
where PRJ_VOL_DWB>=1500;
run;
/* NOTE: There were 12 observations read from the data set WORK.UNADJ_YT3.
      WHERE PRJ_VOL_DWB>=1500;
NOTE: The data set WORK.EXTREM_ORI_1500 has 12 observations and 104 variables.
*/
proc sort; by FEATURE_ID PRJ_TOTAL_AGE; run;


/*WORK AROUND NOTES:
for checking abnormal results due to the backgrow functions*/
data Abnorm_UnAdj;
set UnAdj_YT3;
where PRJ_TOTAL_AGE in (50,60, 70,80,90,100, 110) ;
keep FEATURE_ID PRJ_VOL_DWB PRJ_TOTAL_AGE;
run;

proc transpose data =Abnorm_UnAdj  out =Abnorm_UnAdj2 (drop = _name_)
  prefix =Vol;    VAR PRJ_VOL_DWB;   by FEATURE_ID;  run;
  /*
NOTE: There were 1226582 observations read from the data set
      WORK.ABNORM_UNADJ.
NOTE: The data set WORK.ABNORM_UNADJ2 has 175226 observations and 8

*/

data Abnorm_UnAdj3;
set  Abnorm_UnAdj2;
where Vol1-Vol2>20 or Vol2-Vol3>20  or Vol3-Vol4>20  or Vol4-Vol5>20
/*  or Vol5-Vol6>20  or Vol6-Vol7>20*/;run;
/*
NOTE: There were 0 observations read from the data set WORK.ABNORM_UNADJ2.
      WHERE ((Vol1-Vol2)>20) or ((Vol2-Vol3)>20) or ((Vol3-Vol4)>20) or ((Vol4-Vol5)>20);
NOTE: The data set WORK.ABNORM_UNADJ3 has 0 observations and 8 variables.

*/

/*to check the VDYP7 input for these abnormality polygons*/
data Abnorm_UnAdj3_input;
MERGE  Abnorm_UnAdj3(in=a) Task_data01(in=b);
if a ;by FEATURE_ID ;  RUN;
data DKL.Abnorm_UnAdj3_input;
set Abnorm_UnAdj3_input; run;

PROC EXPORT DATA=DKL.Abnorm_UnAdj3_input dbms=EXCEL 
OUTFILE= "E:\\VDYP7_YT_TSR_Prod\KootenayLake\Adj_Unadj_Population.xlsx" replace;
 SHEET="Abnorm_UnAdj3_input"; RUN; 

data DKL.Abnorm_UnAdj4; 
MERGE  Abnorm_UnAdj3(in=a keep=FEATURE_ID)  UnAdj_YT3(in=b);  
if a and b; by FEATURE_ID;run;
/*
*/


proc sort; by FEATURE_ID Strata;  RUN;
proc gplot data=DKL.Abnorm_UnAdj4 (obs=500);
plot  PRJ_VOL_DWB * PRJ_TOTAL_AGE; by FEATURE_ID Strata;  RUN;QUIT;


/*WORK AROUND NOTES:
for later assign average yield curve purpose, both the extreme volume and the
abnormality stands*/
data Extrem_Ori1;
set  Extrem_Ori
  DKL.Abnorm_UnAdj4;
  /*
NOTE: There were 0 observations read from the data set WORK.EXTREM_ORI.
NOTE: There were 0 observations read from the data set DKL.ABNORM_UNADJ4.
NOTE: The data set WORK.EXTREM_ORI1 has 0 observations and 17 variables.

*/
  proc sort; by FEATURE_ID ;  run;
data Extrem_Ori2;
set  Extrem_Ori1;
if first.FEATURE_ID;by FEATURE_ID ; keep FEATURE_ID Strata; run;
/*
NOTE: There were 0 observations read from the data set WORK.EXTREM_ORI1.
NOTE: The data set WORK.EXTREM_ORI2 has 2 observations and 2 variables

*/

proc sort; by Strata; run;
data Extrem_Ori3;
set  Extrem_Ori2;
if first.Strata;by Strata; keep Strata; run;
/*
NOTE: There were 2 observations read from the data set WORK.EXTREM_ORI2.
NOTE: The data set WORK.EXTREM_ORI3 has 1 observations and 1 variables.

*/


/*For dealing with extreme volumes for some  polygons (volume>3000m3/ha) due to input 
data issues or VDYP7 lorey height issue.
Temporary solution is that this polygon will be treated as non-adjusted or will be assigned 
a yield curve of the weighted average curve of the stratum that this polygon belongs to; 
if no Strata for the polygon, then it is assigned the population weighted average yield curve,
and to avoid the extreme yields involved in the composite yield curve*/
proc sort data=Extrem_Ori2;by FEATURE_ID;run;
proc sort data=UnAdj_YT3;by FEATURE_ID;run;
data UnAdj_YT62;
MERGE UnAdj_YT3(in=a) Extrem_Ori2(in=b);
if a and not b;
by FEATURE_ID;run;
/*to avoid the extreme yields involved in the composite yield curve

NOTE: There were 4380650 observations read from the data set
      WORK.UNADJ_YT3.
NOTE: There were 0 observations read from the data set WORK.EXTREM_ORI2.
NOTE: The data set WORK.UNADJ_YT62 has 4380650 observations and 17

*/


proc means data =UnAdj_YT62;
CLASS Strata  PRJ_TOTAL_AGE;
var  PRJ_PCNT_STOCK  PRJ_SITE_INDEX  PRJ_DOM_HT PRJ_LOREY_HT PRJ_DIAMETER PRJ_TPH  PRJ_BA PRJ_VOL_WS PRJ_VOL_CU PRJ_VOL_D PRJ_VOL_DW PRJ_VOL_DWB;
OUTPUT OUT =UnAdj_YT_Str  mean=  n=n;
*weight POLYGON_AREA; 
run;
/*
NOTE: There were 4380650 observations read from the data set WORK.UNADJ_YT62.
NOTE: The data set WORK.UNADJ_YT_STR has 416 observations and 17 variables.
*/
proc means data =UnAdj_YT62;
CLASS /*Strata*/ PRJ_TOTAL_AGE;
var  PRJ_PCNT_STOCK  PRJ_SITE_INDEX  PRJ_DOM_HT PRJ_LOREY_HT PRJ_DIAMETER PRJ_TPH  PRJ_BA PRJ_VOL_WS PRJ_VOL_CU PRJ_VOL_D PRJ_VOL_DW PRJ_VOL_DWB;
OUTPUT OUT =UnAdj_YT_Pop  mean=  n=n;
*weight POLYGON_AREA; 
run;
/*
NOTE: There were 4380650 observations read from the data set WORK.UNADJ_YT62.
NOTE: The data set WORK.UNADJ_YT_POP has 26 observations and 16 variables.
*/
data UnAdj_YT_Str2;
set  UnAdj_YT_Str;
where _Type_=3; run;
/*
NOTE: There were 375 observations read from the data set WORK.UNADJ_YT_STR.
      WHERE _Type_=3;
NOTE: The data set WORK.UNADJ_YT_STR2 has 375 observations and 17 variables.
*/
proc sort data=Extrem_Ori3; by Strata; run;
data Extrem_Ori4;
MERGE Extrem_Ori3 (in=a keep=Strata) UnAdj_YT_Str2(in=b);
by Strata;
if a and b;
DROP _FREQ_  _TYPE_ N; run;
/*
NOTE: There were 0 observations read from the data set WORK.EXTREM_ORI3.
NOTE: There were 375 observations read from the data set WORK.UNADJ_YT_STR2.
NOTE: The data set WORK.EXTREM_ORI4 has 0 observations and 14 variables.

*/
proc sort data=Extrem_Ori2; by Strata;
/*
data Extrem_Ori5;
MERGE Extrem_Ori2 (in=a ) Extrem_Ori4(in=b);
by Strata;
if a; run;
THIS WAY IS NOT WORKING!!!!!
*/


/*WORK AROUND NOTES:
for assigning average yield curve purpose, both the extreme volume and the abnormality stands
THIS WAY WORKED*/
proc sql;
 create table Extrem_Ori6 as
 select * 
 from Extrem_Ori4 left join Extrem_Ori2
 on Extrem_Ori4.Strata=Extrem_Ori2.Strata;
quit;
/*
WARNING: Variable Strata already exists on file WORK.EXTREM_ORI6.
NOTE: Table WORK.EXTREM_ORI6 created, with 0 rows and 15 columns.

*/
proc sort;  by FEATURE_ID PRJ_TOTAL_AGE;run;


/*WORK AROUND NOTES:
Dec.15, 2018
Since some issues were found in Haida Gwaii(assigned YT maximum volume is <250 m3/ha) for the following
approach, this new MAI approach is going to be applied temporary for now until the BACKGROW
issue will be solved*/

/*for estimating the volum at  reference year for later use*/
	 
data V7_Step1_YT1_Ref;
set  V7_Step1_YT1;

if PRJ_MODE="Ref";

 array miss_to_zero(12) PRJ_PCNT_STOCK  PRJ_SITE_INDEX  PRJ_DOM_HT  PRJ_LOREY_HT PRJ_DIAMETER   PRJ_TPH  PRJ_BA  PRJ_VOL_WS     
PRJ_VOL_CU PRJ_VOL_D  PRJ_VOL_DW  PRJ_VOL_DWB;
do i = 1 to 12; if miss_to_zero(i)=. then do; miss_to_zero(i)=0; end; end;
if FEATURE_ID=88888888 then delete;
if FEATURE_ID=1000000 then delete;RUN;
run;
/*
NOTE: There were 12947172 observations read from the data set WORK.V7_STEP1_YT1.
NOTE: The data set WORK.V7_STEP1_YT1_REF has 129306 observations and 64 variables

*/

proc sort; by  FEATURE_ID  PROJECTION_YEAR  LAYER_ID ; run;

proc summary data=V7_Step1_YT1_Ref;
var PRJ_PCNT_STOCK  PRJ_SITE_INDEX  PRJ_DOM_HT  PRJ_LOREY_HT PRJ_DIAMETER   PRJ_TPH  PRJ_BA  PRJ_VOL_WS     
PRJ_VOL_CU PRJ_VOL_D  PRJ_VOL_DW  PRJ_VOL_DWB;
output out=V7_Step1_YT1_Ref1 MEAN=  n=n;
*by FEATURE_ID  PRJ_TOTAL_AGE   LAYER_ID;
by  FEATURE_ID  PROJECTION_YEAR  LAYER_ID ; run;
run;
/*have MULTI LAYER POLYGONS OR DUPLICATED POLYGONS,
HERE MUST USE MEAN , NOT SUM!!!!!!!!!!!!!!

NOTE: There were 129306 observations read from the data set WORK.V7_STEP1_YT1_REF.
NOTE: The data set WORK.V7_STEP1_YT1_REF1 has 129306 observations and 18 variables.

*/

data test;
set V7_Step1_YT1_Ref1;
where n>1;
run;


proc summary data=V7_Step1_YT1_Ref1;
var PRJ_PCNT_STOCK  PRJ_SITE_INDEX  PRJ_DOM_HT  PRJ_LOREY_HT PRJ_DIAMETER   PRJ_TPH  PRJ_BA  PRJ_VOL_WS     
PRJ_VOL_CU PRJ_VOL_D  PRJ_VOL_DW  PRJ_VOL_DWB;

output out=V7_Step1_YT1_Ref2 
mean (PRJ_PCNT_STOCK  PRJ_SITE_INDEX  PRJ_DOM_HT  PRJ_LOREY_HT PRJ_DIAMETER )
     =PRJ_PCNT_STOCK  PRJ_SITE_INDEX  PRJ_DOM_HT  PRJ_LOREY_HT PRJ_DIAMETER 
sum (PRJ_TPH  PRJ_BA  PRJ_VOL_WS  PRJ_VOL_CU PRJ_VOL_D  PRJ_VOL_DW  PRJ_VOL_DWB)
    =PRJ_TPH  PRJ_BA  PRJ_VOL_WS  PRJ_VOL_CU PRJ_VOL_D  PRJ_VOL_DW  PRJ_VOL_DWB  
n=n2;
*by FEATURE_ID PRJ_TOTAL_AGE;
by FEATURE_ID PROJECTION_YEAR;
*ID PRJ_TOTAL_AGE; run;
/*SOME TWO LAYERS (PRIMARY AND VETERAN LAYERS) SUM FOR THIS DATASET at the SAME YEAR, 
NOT THE SAME AGE!

NOTE: There were 129306 observations read from the data set
      WORK.V7_STEP1_YT1_REF1.
NOTE: The data set WORK.V7_STEP1_YT1_REF2 has 122935 observations and 17


*/


proc sort data=L_Step1_YT_P2;
by FEATURE_ID  PROJECTION_YEAR;run;

data  V7_Step1_YT1_Ref3;
merge /*L_Step1_YT_P3  THIS WAY NOT WORK HERE, SINCE THE PROJECTION_YEAR in dataset 
L_Step1_YT_P3 have been only 10, 20, 30,..., need to use the L_Step1_YT_P2 here*/
      L_Step1_YT_P2(in=a keep=FEATURE_ID  Strata  PRJ_TOTAL_AGE PROJECTION_YEAR) 
      V7_Step1_YT1_Ref2 (in=b);
IF A AND B;
by FEATURE_ID  PROJECTION_YEAR;

*POLYGON_AREA=1; /*ASSUME TO EQUAL WEIGHT=1 HERE*/
drop  _freq_  _type_; 

MAI_DWB_Ref=round(PRJ_VOL_DWB/PRJ_TOTAL_AGE,0.01);

*Ageclass_Ref=round(PRJ_TOTAL_AGE/5,1)*5;
Ageclass_Ref=round(PRJ_TOTAL_AGE/10,1)*10;/*round to Ageclass 10*/
run;
/*this V7_Step1_YT1_Ref3 will be used later for extreme volume and abnormal 
stands replacement

NOTE: There were 9598712 observations read from the data set WORK.L_STEP1_YT_P2.
NOTE: There were 122935 observations read from the data set WORK.V7_STEP1_YT1_REF2.
NOTE: The data set WORK.V7_STEP1_YT1_REF3 has 122420 observations and 19 variables.

*/



/*here the PRJ_TOTAL_AGE in L_Step1_YT_P3 is the Primary layer age of the polygon, and
applied approximately as the stand yield table age*/

data  V7_Step1_YT1_Ref3_MAIzero;
set  V7_Step1_YT1_Ref3;
if MAI_DWB_Ref=0;
RUN;
/*
NOTE: There were 122420 observations read from the data set  WORK.V7_STEP1_YT1_REF3.
NOTE: The data set WORK.V7_STEP1_YT1_REF3_MAIZERO has 8320 observations

*/


data  V7_Step1_YT1_Ref3_MAIzero_Y;
set  V7_Step1_YT1_Ref3;
if MAI_DWB_Ref=0 AND PRJ_TOTAL_AGE=<30;
RUN;
/*Young stands

NOTE: There were 122420 observations read from the data set      WORK.V7_STEP1_YT1_REF3.
NOTE: The data set WORK.V7_STEP1_YT1_REF3_MAIZERO_Y has 4708

*/


/*WORK AROUND NOTES:
for later assign average yield curve purpose, for the extreme volume stands,cap them to the 
maximum 2000 m3/ha, AND then proportion reduce the yields in each Ageclass*/
data Extrem_Prop_Cap1;
set  Extrem_Ori;run;
proc sort; by FEATURE_ID PRJ_VOL_DWB;  run; 

data Extrem_Prop_Cap2;
set  Extrem_Prop_Cap1;
if last.FEATURE_ID;
by FEATURE_ID;  

CAP_FAC_DWB=round(PRJ_VOL_DWB/2000,0.001);
run;/*to get the max volume AND CAP RATIO*/
/*
NOTE: There were 0 observations read from the data set WORK.EXTREM_PROP_ORI1.
NOTE: The data set WORK.EXTREM_PROP_ORI2 has 0 observations and 103 variables.
*/

data Extrem_Prop_Cap3;
set  Extrem_Prop_Cap2;
KEEP FEATURE_ID  CAP_FAC_DWB;  
run;
data Extrem_Prop_Cap4;
merge  Extrem_Prop_Cap3(in=a)  UnAdj_YT3(in=b);
if a and b;
by FEATURE_ID ; 

if CAP_FAC_DWB ne . then do;

PRJ_VOL_DWB_0=PRJ_VOL_DWB;

PRJ_VOL_DWB=PRJ_VOL_DWB/CAP_FAC_DWB;
PRJ_VOL_DW=PRJ_VOL_DW/CAP_FAC_DWB;
PRJ_VOL_D=PRJ_VOL_D/CAP_FAC_DWB;
                     end; 
run;
/*
NOTE: There were 0 observations read from the data set WORK.EXTREM_PROP_CAP3.
NOTE: There were 4380650 observations read from the data set WORK.UNADJ_YT3.
NOTE: The data set WORK.EXTREM_PROP_CAP4 has 0 observations and 104 variable
*/
proc sort; by FEATURE_ID PRJ_TOTAL_AGE;  run;

ods listing close;
ods html ;

goptions device=png ftext="Arial" xmax=6.6in ymax=6.6 in xpixels=5400 ypixels=5400
gsfname=output gsfmode=replace;
AXIS1 LABEL=(A=90 R=0 F=swissB H=0.40 CM 'Volume_dwb (m^3/ha)');
AXIS2 order=(0 to 360 by 20)  LABEL=(F=swissB H=0.4 CM 'Total Age (Years)');
SYMBOL1  V=dot       C=green     H=0.4 CM  I=join l=1 w=0.1 r=1;
SYMBOL2  V=triangle  C=Blue    H=0.4 CM  I=join l=1 w=0.1 r=1;
Title1 "Capped vs Orig"; 

proc gplot  data=Extrem_Prop_Cap4(obs=200);
*where feature_id=9942367;
plot  PRJ_VOL_DWB*PRJ_TOTAL_AGE  PRJ_VOL_DWB_0*PRJ_TOTAL_AGE/overlay noframe /*href=100 vref=100*/haxis=axis2 vaxis=axis1 nolegend;
NOTE HEIGHT=1.5  FONT=SWISSB A=0  MOVE=(25,43) 'Green dot-Capped' MOVE=(25,41)'Blue triangle-Orig.' ; 
by FEATURE_ID ;
RUN;QUIT;

/*for later assign average yield curve purpose, for the abnormality stands, for projected age 
younger than reference year age, then use the MAI at the refernce year time the projected age
 for those yields at younger than the reference ages*/
data Abnorm_MAI;
set  DKL.Abnorm_UnAdj4;run;
  /*
NOTE: There were 0 observations read from the data set POP_YT.ABNORM_UNADJ4.
NOTE: The data set WORK.ABNORM_MAI has 0 observations and 103 variables.

*/

proc sort; by FEATURE_ID ;  run;
data Abnorm_MAI2;
set  Abnorm_MAI;
if first.FEATURE_ID;by FEATURE_ID ; *keep FEATURE_ID Strata; run;
/*
NOTE: There were 0 observations read from the data set WORK.ABNORM_MAI.
NOTE: The data set WORK.ABNORM_MAI2 has 0 observations and 2 variables.
*/
data Abnorm_MAI3;
merge V7_Step1_YT1_Ref3(in=a  keep=FEATURE_ID  Strata  MAI_DWB_Ref  Ageclass_Ref)
       Abnorm_MAI(in=b)  ;
*if a and b;
if b;
by FEATURE_ID ;  run;
/*
NOTE: There were 0 observations read from the data set WORK.ABNORM_MAI.
NOTE: There were 122420 observations read from the data set WORK.V7_STEP1_YT1_REF3.
NOTE: The data set WORK.ABNORM_MAI3 has 0 observations and 105 variables
*/

data Abnorm_MAI4;
retain FEATURE_ID  Strata  MAI_DWB_Ref PRJ_TOTAL_AGE Ageclass_Ref  PRJ_VOL_DWB PRJ_VOL_DWB_0;
set  Abnorm_MAI3;

PRJ_VOL_DWB_0=PRJ_VOL_DWB;

if PRJ_TOTAL_AGE =< Ageclass_Ref then do;
    PRJ_VOL_DWB=MAI_DWB_Ref*PRJ_TOTAL_AGE; end;
run;

proc sort; by FEATURE_ID PRJ_TOTAL_AGE;  run;

ods listing close;
ods html ;

goptions device=png ftext="Arial" xmax=6.6in ymax=6.6 in xpixels=5400 ypixels=5400
gsfname=output gsfmode=replace;
AXIS1 LABEL=(A=90 R=0 F=swissB H=0.40 CM 'Volume_dwb (m^3/ha)');
AXIS2 order=(0 to 360 by 20)  LABEL=(F=swissB H=0.4 CM 'Total Age (Years)');
SYMBOL1  V=dot       C=green     H=0.4 CM  I=join l=1 w=0.1 r=1;
SYMBOL2  V=triangle  C=Blue    H=0.4 CM  I=join l=1 w=0.1 r=1;
Title1 "Capped vs Orig"; 

proc gplot  data=Abnorm_MAI4(obs=200);
where feature_id=9942367;
plot  PRJ_VOL_DWB*PRJ_TOTAL_AGE  PRJ_VOL_DWB_0*PRJ_TOTAL_AGE/overlay noframe /*href=100 vref=100*/haxis=axis2 vaxis=axis1 nolegend;
NOTE HEIGHT=1.5  FONT=SWISSB A=0  MOVE=(25,43) 'Green dot-Adj.' MOVE=(25,41)'Blue triangle-Orig.' ; 
by FEATURE_ID ;
RUN;QUIT;

proc gplot  data=Abnorm_MAI4(obs=200);
*where feature_id=9942367;
plot  PRJ_VOL_DWB*PRJ_TOTAL_AGE  PRJ_VOL_DWB_0*PRJ_TOTAL_AGE/overlay noframe /*href=100 vref=100*/haxis=axis2 vaxis=axis1 nolegend;
NOTE HEIGHT=1.5  FONT=SWISSB A=0  MOVE=(25,43) 'Green dot-Adj.' MOVE=(25,41)'Blue triangle-Orig.' ; 
by FEATURE_ID ;
RUN;QUIT;



/*WORK AROUND NOTES:
Dec.15, 2018
Since some issues were found in Haida Gwaii(assigned YT maximum volume is <250 m3/ha) for the following
approach, this new MAI approach is going to be applied temporary for now until the BACKGROW
issue will be solved*/
/*
data UnAdj_YT7;
MERGE UnAdj_YT3(in=a)  Extrem_Ori6(in=b);
by FEATURE_ID PRJ_TOTAL_AGE;run;*/
/*this way use the yields from Extrem_Ori6 to replace the extreme values in the 
original yield table.


NOTE: There were 1210025 observations read from the data set
      WORK.UNADJ_YT69.
NOTE: There were 0 observations read from the data set
      WORK.EXTREM_PROP_CAP4.
NOTE: There were 0 observations read from the data set WORK.ABNORM_MAI4.
NOTE: The data set WORK.UNADJ_YT7 has 1210025 observations and 21

*/

data UnAdj_YT69;
MERGE UnAdj_YT3(in=a)  
      Extrem_Prop_Cap3(in=b  keep=FEATURE_ID)  
      Abnorm_MAI2(in=c keep=FEATURE_ID);

if a and not (b or c);
by FEATURE_ID;run;
/*
here to get ride off the extreme and abnormal yield polygons 
(and will be adjusted and add back later)

NOTE: There were 1210025 observations read from the data set
      WORK.UNADJ_YT3.
NOTE: There were 0 observations read from the data set
      WORK.EXTREM_PROP_CAP3.
NOTE: There were 0 observations read from the data set WORK.ABNORM_MAI2.
NOTE: The data set WORK.UNADJ_YT69 has 1210025 observations and 17

*/

data UnAdj_YT7;
set UnAdj_YT69
    Extrem_Prop_Cap4
     Abnorm_MAI4;
run;
/*
NOTE: There were 1210025 observations read from the data set      WORK.UNADJ_YT69.
NOTE: There were 0 observations read from the data set      WORK.EXTREM_PROP_CAP4.
NOTE: There were 0 observations read from the data set WORK.ABNORM_MAI4.
NOTE: The data set WORK.UNADJ_YT7 has 1210025 observations and 21


*/
proc sort; by FEATURE_ID PRJ_TOTAL_AGE;run;




data FIDS;
SET UnAdj_YT7;
IF FIRST.FEATURE_ID;
BY FEATURE_ID;
RUN;
/*

NOTE: There were 1210025 observations read from the data set
      WORK.UNADJ_YT7.
NOTE: The data set WORK.FIDS has 48401 observations and 21 variables.
*/





/*WORK AROUND NOTES:
for those unprojected polygons in the Unadjusted population
due to data issues or projection issues*/
proc means data =UnAdj_YT7;
CLASS Strata PRJ_TOTAL_AGE;
var  PRJ_PCNT_STOCK  PRJ_SITE_INDEX  PRJ_DOM_HT PRJ_LOREY_HT PRJ_DIAMETER PRJ_TPH  PRJ_BA PRJ_VOL_WS PRJ_VOL_CU PRJ_VOL_D PRJ_VOL_DW PRJ_VOL_DWB;
OUTPUT OUT =UnAdj_YT_Pop4  mean=  n=n;
*weight POLYGON_AREA; 
run;
/*
NOTE: There were 4380650 observations read from the data set
      WORK.UNADJ_YT7.
NOTE: The data set WORK.UNADJ_YT_POP4 has 416 observations and 1
*/
data UnAdj_YT_Pop5;
set  UnAdj_YT_Pop4;
where _Type_=1; 

if PRJ_TOTAL_AGE<=20 then do;
PRJ_VOL_WS=0; PRJ_VOL_CU=0; PRJ_VOL_D=0; PRJ_VOL_DW=0; PRJ_VOL_DWB=0;
 end;

run;
/*
NOTE: There were 25 observations read from the data set
      WORK.UNADJ_YT_POP4.
      WHERE _Type_=1;
NOTE: The data set WORK.UNADJ_YT_POP5 has 25 observations and 17      variables.
*/

/*here is for the ZERO volume POLYGONS*/
data UnAdj_YT_Pop5_Str;
set  UnAdj_YT_Pop4;
where _Type_=3; 

if PRJ_TOTAL_AGE<=20 then do;
PRJ_VOL_WS=0; PRJ_VOL_CU=0; PRJ_VOL_D=0; PRJ_VOL_DW=0; PRJ_VOL_DWB=0;
 end;
run;
/*NOTE: There were 375 observations read from the data set
      WORK.UNADJ_YT_POP4.
      WHERE _Type_=3;
NOTE: The data set WORK.UNADJ_YT_POP5_STR has 375 observations and 17
*/


data UnProj_YT2;
set UnAdj_YT7;
if first.FEATURE_ID;
by FEATURE_ID ;
keep FEATURE_ID;run;
/*
NOTE: There were 4380650 observations read from the data set
      WORK.UNADJ_YT7.
NOTE: The data set WORK.UNPROJ_YT2 has 175226 observations and

*/
data   UnProj_YT3;
merge  UnProj_YT2(in=a) Task_data01(in=b);
if b and NOT a; by FEATURE_ID;run;
/*
NOTE: There were 175226 observations read from the data set
      WORK.UNPROJ_YT2.
NOTE: There were 219326 observations read from the data set
      WORK.TASK_DATA01.
NOTE: The data set WORK.UNPROJ_YT3 has 1018 observations and 86

*/

data   UnProj_YT4;
set    UnProj_YT3;
if BCLCS_LEVEL1_CODE="V" AND BCLCS_LEVEL2_CODE="T"  AND SPECIES_CD_1 NE ""
/*AND Age_now>30  AND */;
RUN;
/*
NOTE: There were 1018 observations read from the data set
      WORK.UNPROJ_YT3.
NOTE: The data set WORK.UNPROJ_YT4 has 392 observations and 86 variables.

*/

PROC SORT; by FEATURE_ID ;
data   UnProj_YT5;
set    UnProj_YT4;
if first.FEATURE_ID;
by FEATURE_ID ;

UnProj_ID=2;
keep FEATURE_ID  UnProj_ID;run;
/*
NOTE: There were 392 observations read from the data set WORK.UNPROJ_YT4.
NOTE: The data set WORK.UNPROJ_YT5 has 322 observations and 2 variables.

*/

proc sort;  by UnProj_ID ;run;


data UnAdj_YT_Pop6;
set UnAdj_YT_Pop5;/*poly area weighted*/
UnProj_ID=2;
run;
proc sort;  by UnProj_ID PRJ_TOTAL_AGE;run;

/*
data   UnProj_YT6;
merge    UnProj_YT5(in=a)   UnAdj_YT_Pop6(in=b);
if a and b;
by UnProj_ID ;run;

*/

/*THIS WAY WORKED*/
proc sql;
 create table UnProj_YT6 as
 select * 
 from UnProj_YT5 left join UnAdj_YT_Pop6
 on UnProj_YT5.UnProj_ID=UnAdj_YT_Pop6.UnProj_ID;
quit;
/*
WARNING: Variable UnProj_ID already exists on file WORK.UNPROJ_YT6.
NOTE: Table WORK.UNPROJ_YT6 created, with 8050 rows and 19 columns.

*/

data   UnProj_YT7;
set    UnProj_YT6;
if PRJ_TOTAL_AGE IN (10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,
160,170,180,190,200,210,220,230,240,250);
run;
/*
NOTE: There were 8050 observations read from the data set
      WORK.UNPROJ_YT6.
NOTE: The data set WORK.UNPROJ_YT7 has 8050 observations and 19

*/
proc sort; 
by FEATURE_ID PRJ_TOTAL_AGE;run;






/*WORK AROUND NOTES:
for those projected, but got zero volumes

The logic will be:

First, assign it to the proportional adjusted volume (based on the projected volume of 2017);
Second, if the projectioned volume of 2017 still zero or missing, 
     then assign it to the proportional adjusted volume (based on the projected volume of reference year);
Third, if the reference year volume still missing or zero, then keep the yt zero for all ages.

PLEASE PAY ATTENTION, SOME MAY BE DUE TO VERY LOW SITE INDEX
*/
data Zero_Vol;
set UnAdj_YT7;

if PRJ_TOTAL_AGE=200 and PRJ_VOL_DWB=0;
run;
/*
NOTE: There were 4380650 observations read from the data set
      WORK.UNADJ_YT7.
NOTE: The data set WORK.ZERO_VOL has 356 observations and 21 variables.

*/
data Zero_Vol2;
set  Zero_Vol;
if first.FEATURE_ID;
by FEATURE_ID;
run;
/*
NOTE: There were 356 observations read from the data set WORK.ZERO_VOL.
NOTE: The data set WORK.ZERO_VOL2 has 356 observations and 21 variables.

*/

/*TO CHECK THE ERROR POLYGONS after the runs*/

/*
PROC IMPORT DATAFILE="&dir_v7\Check1_NI.xlsx"
dbms=EXCEL
out=VRI_check2;
SHEET="VRI-check";
RUN;
NOTE: WORK.VRI_CHECK2 data set was successfully created.
NOTE: The data set WORK.VRI_CHECK2 has 99 observations and 5 variables.

proc sort; by FEATURE_ID; RUN;
*/

data Zero_Vol3;
/*merge Zero_Vol2(in=a)  VRI_check2(in=b);
if a and b;  by FEATURE_ID; */
SET Zero_Vol2;RUN;
/*
NOTE: There were 356 observations read from the data set WORK.ZERO_VOL2.
NOTE: The data set WORK.ZERO_VOL3 has 356 observations and 107

*/

proc sort; by FEATURE_ID; RUN;

data VRI_check2_2;
merge  Zero_Vol2(in=a)  LAYER(in=b);
if a and b;
by FEATURE_ID; RUN;
/*
NOTE: There were 356 observations read from the data set WORK.ZERO_VOL2.
NOTE: There were 219326 observations read from the data set WORK.LAYER.
NOTE: The data set WORK.VRI_CHECK2_2 has 388 observations and 58

*/

data POLY_Chk;
merge  Zero_Vol2(in=a  keep=FEATURE_ID)  POLY(in=b);
if a and b;
by FEATURE_ID; RUN;
/*
NOTE: There were 356 observations read from the data set WORK.ZERO_VOL2.
NOTE: There were 176124 observations read from the data set WORK.POLY.
NOTE: The data set WORK.POLY_CHK has 356 observations and 42 variables.

*/
data LAYER_Chk;
merge  Zero_Vol2(in=a  keep=FEATURE_ID)  LAYER(in=b);
if a and b;
by FEATURE_ID; RUN;
/*
NOTE: There were 356 observations read from the data set WORK.ZERO_VOL2.
NOTE: There were 219326 observations read from the data set WORK.LAYER.
NOTE: The data set WORK.LAYER_CHK has 388 observations and 38 variables.

*/


data POLYLAYER_Chk;
merge POLY_Chk(in=a)   LAYER_Chk(in=b);
if a and b;
by FEATURE_ID; RUN;

data POLYLAYER_Chk_313907967;
set  POLYLAYER_Chk;
where FEATURE_ID=13907967;
run;
data POLYLAYER_Chk3_2963107;
set  POLYLAYER_Chk;
where FEATURE_ID=2963107;
run;




 PROC EXPORT DATA=POLY_Chk OUTFILE= "&dir_v7\POLY_Chk.CSV"  DBMS=CSV REPLACE;RUN;
 PROC EXPORT DATA=LAYER_Chk OUTFILE= "&dir_v7\LAYER_Chk.CSV"  DBMS=CSV REPLACE;RUN;

 
OPTIONS NOXWAIT;
RUN;
X cd E:\\VDYP7_YT_TSR_Prod\KootenayLake;
X DKL_125175_2017_byLayerSpp_Chk.cmd;/*check non-projected polygons*/

%Import_CSVOUT_BySpp(&dir_v7, HCSV-YldTbl_125175_2017_DKL_Chk, V7_2017_DKL_Chk);

data V7_2017_DKL_Chk1  Dlayer_2017_DKL_Chk;
set  V7_2017_DKL_Chk(firstobs=2);

*where FEATURE_ID IN (9009243,9009264, 9012065,9023302);

if FEATURE_ID=88888888 THEN DELETE;
if LAYER_ID ne "D" then output V7_2017_DKL_Chk1;/*only live layers, no D-layer*/
if LAYER_ID="D" then output    Dlayer_2017_DKL_Chk;
run;
/*
NOTE: There were 364 observations read from the data set
      WORK.V7_2017_DKL_CHK.
NOTE: The data set WORK.V7_2017_DKL_CHK1 has 356 observations and 63
      variables.
NOTE: The data set WORK.DLAYER_2017_DKL_CHK has 8 observations and 63

*/


/*WORK AROUND NOTES:
for estimating the total layer volume sum at  year 2017 for later use*/
	 
data V7_2017_DKL_Chk1_Zero;
set  V7_2017_DKL_Chk1;

 array miss_to_zero(12) PRJ_PCNT_STOCK  PRJ_SITE_INDEX  PRJ_DOM_HT  PRJ_LOREY_HT PRJ_DIAMETER   PRJ_TPH  PRJ_BA  PRJ_VOL_WS     
PRJ_VOL_CU PRJ_VOL_D  PRJ_VOL_DW  PRJ_VOL_DWB;
do i = 1 to 12; if miss_to_zero(i)=. then do; miss_to_zero(i)=0; end; end;
if FEATURE_ID=88888888 then delete;
if FEATURE_ID=1000000 then delete;RUN;
run;
/*
NOTE: There were 356 observations read from the data set      WORK.V7_2017_DKL_CHK1.
NOTE: The data set WORK.V7_2017_DKL_CHK1_ZERO has 356 observations and

*/

proc sort; by  FEATURE_ID  PROJECTION_YEAR  LAYER_ID ; run;

proc summary data=V7_2017_DKL_Chk1_Zero;
var PRJ_PCNT_STOCK  PRJ_SITE_INDEX  PRJ_DOM_HT  PRJ_LOREY_HT PRJ_DIAMETER   PRJ_TPH  PRJ_BA  PRJ_VOL_WS     
PRJ_VOL_CU PRJ_VOL_D  PRJ_VOL_DW  PRJ_VOL_DWB;
output out=V7_2017_DKL_Chk1_Zero1 MEAN=  n=n;
*by FEATURE_ID  PRJ_TOTAL_AGE   LAYER_ID;
by  FEATURE_ID  PROJECTION_YEAR  LAYER_ID ; run;
run;
/*have MULTI LAYER POLYGONS OR DUPLICATED POLYGONS,
HERE MUST USE MEAN , NOT SUM!!!!!!!!!!!!!!

NOTE: There were 356 observations read from the data set WORK.V7_STEP1_YT1_REF.
NOTE: The data set WORK.V7_STEP1_YT1_REF1 has 356 observations and 18 variables.

*/

data test;
set V7_2017_DKL_Chk1_Zero1;
where n>1;
run;


proc summary data=V7_2017_DKL_Chk1_Zero1;
var PRJ_PCNT_STOCK  PRJ_SITE_INDEX  PRJ_DOM_HT  PRJ_LOREY_HT PRJ_DIAMETER   PRJ_TPH  PRJ_BA  PRJ_VOL_WS     
PRJ_VOL_CU PRJ_VOL_D  PRJ_VOL_DW  PRJ_VOL_DWB;

output out=V7_2017_DKL_Chk1_Zero2 
mean (PRJ_PCNT_STOCK  PRJ_SITE_INDEX  PRJ_DOM_HT  PRJ_LOREY_HT PRJ_DIAMETER )
     =PRJ_PCNT_STOCK  PRJ_SITE_INDEX  PRJ_DOM_HT  PRJ_LOREY_HT PRJ_DIAMETER 
sum (PRJ_TPH  PRJ_BA  PRJ_VOL_WS  PRJ_VOL_CU PRJ_VOL_D  PRJ_VOL_DW  PRJ_VOL_DWB)
    =PRJ_TPH  PRJ_BA  PRJ_VOL_WS  PRJ_VOL_CU PRJ_VOL_D  PRJ_VOL_DW  PRJ_VOL_DWB  
n=n2;
*by FEATURE_ID PRJ_TOTAL_AGE;
by FEATURE_ID PROJECTION_YEAR;
*ID PRJ_TOTAL_AGE; run;
/*SOME TWO LAYERS (PRIMARY AND VETERAN LAYERS) SUM FOR THIS DATASET at the SAME YEAR, 
NOT THE SAME AGE!

NOTE: There were 356 observations read from the data set
      WORK.V7_2017_DKL_CHK1_ZERO1.
NOTE: The data set WORK.V7_2017_DKL_CHK1_ZERO2 has 356 observations and

*/


DATA V7_2017_DKL_Chk2   V7_RefYr_DKL_Chk0;
SET  V7_2017_DKL_Chk1_Zero2;

PRJ_VOL_DWB_2017=PRJ_VOL_DWB;

if PRJ_VOL_DWB_2017>0 then output  V7_2017_DKL_Chk2;/*here for those that have projected volumes in year 2017*/

if PRJ_VOL_DWB_2017<=0 then output  V7_RefYr_DKL_Chk0;/*here for those that have projected volumes in reference year, but not likely*/

KEEP  FEATURE_ID   PRJ_VOL_DWB_2017;run;
/*

NOTE: There were 356 observations read from the data set
      WORK.V7_2017_DKL_CHK1_ZERO2.
NOTE: The data set WORK.V7_2017_DKL_CHK2 has 146 observations and 2
      variables.
NOTE: The data set WORK.V7_REFYR_DKL_CHK0 has 210 observations and 2

*/

proc sort  data=V7_2017_DKL_Chk2; by FEATURE_ID; RUN;
proc sort  data=V7_RefYr_DKL_Chk0; by FEATURE_ID; RUN;
data V7_RefYr_DKL_Chk02;
merge V7_RefYr_DKL_Chk0(in=a) V7_Step1_YT1_Ref2(in=b);
if a and b;
 by FEATURE_ID; RUN;

data V7_RefYr_DKL_Chk03    V7_RefYr_DKL_Chk06;
set  V7_RefYr_DKL_Chk02;

     PRJ_VOL_DWB_2017=PRJ_VOL_DWB;

if   PRJ_VOL_DWB>0  then output  V7_RefYr_DKL_Chk03;
if   PRJ_VOL_DWB<=0  then output  V7_RefYr_DKL_Chk06;
run;
/*
NOTE: There were 119 observations read from the data set
      WORK.V7_REFYR_DKL_CHK02.
NOTE: The data set WORK.V7_REFYR_DKL_CHK03 has 0 observations and 18
      variables.
NOTE: The data set WORK.V7_REFYR_DKL_CHK06 has 119 observations and 18
*/

/*WORK AROUND NOTES:
HERE TO KEEP BOTH of those that have projected volumes of the 2017 and reference year*/
data  V7_2017_DKL_Chk3;
set   V7_2017_DKL_Chk2
      V7_RefYr_DKL_Chk03;
run;
/*
NOTE: There were 146 observations read from the data set      WORK.V7_2017_DKL_CHK2.
NOTE: There were 0 observations read from the data set      WORK.V7_REFYR_DKL_CHK03.
NOTE: The data set WORK.V7_2017_DKL_CHK3 has 146 observations and 18

*/

proc sort data=V7_RefYr_DKL_Chk06;
by FEATURE_ID; 
run;


/*to check why these have no projected volumes in year 2017*/
data  V7_RefYr_DKL_Chk07;
merge    V7_RefYr_DKL_Chk06(in=a)  POLY(in=b)  LAYER(in=c);
if a and b and c;

by FEATURE_ID; 
run;
/*
NOTE: There were 28366 observations read from the data set
      WORK.V7_REFYR_DKL_CHK06.
NOTE: There were 119 observations read from the data set
      WORK.V7_REFYR_DKL_CHK06.
NOTE: There were 176124 observations read from the data set WORK.POLY.
NOTE: There were 219326 observations read from the data set WORK.LAYER.
NOTE: The data set WORK.V7_REFYR_DKL_CHK07 has 143 observations and 94

*/



ods listing close;
ods html ;

title "Data checking";
 proc g3d data=V7_RefYr_DKL_Chk07; 
      *format EST_HEIGHT_SPP1 f6.3; 
      plot BASAL_AREA_75*EST_AGE_SPP1=EST_HEIGHT_SPP1 /zmin=0 /*zmax=30*/ zticknum=5; 
   run; 


 proc g3d data=V7_RefYr_DKL_Chk07; 
      *format EST_HEIGHT_SPP1 f6.3; 
      plot BASAL_AREA_75*EST_HEIGHT_SPP1=EST_AGE_SPP1 /zmin=0 /*zmax=30*/ zticknum=5; 
   run; 

   
 proc gplot data=V7_RefYr_DKL_Chk07; 
SYMBOL1  V=dot       C=green     H=0.4 CM  I=no l=1 w=0.1 r=1;

plot EST_HEIGHT_SPP1*EST_AGE_SPP1; 
   run; quit;

 proc gplot data=V7_RefYr_DKL_Chk07; 
SYMBOL1  V=dot       C=green     H=0.4 CM  I=no l=1 w=0.1 r=1;

plot BASAL_AREA_75*EST_AGE_SPP1; 
   run; quit;
/*most of them are old stands, but with very heights due to high elevations, or very low productivity stands*/

ods html close;
ods listing;



data LAYER_Chk2;
set  LAYER_Chk;
if EST_AGE_SPP1<=250 and EST_AGE_SPP2<=250;
run;
/*

NOTE: There were 31736 observations read from the data set WORK.LAYER_CHK.
NOTE: The data set WORK.LAYER_CHK2 has 30200 observations and 38

*/


data POLY_Chk2;
merge  POLY_Chk(in=a )  LAYER_Chk(in=b);
if a and b;
by FEATURE_ID; 
EST_AGE_SPP1_2017=EST_AGE_SPP1+2017-reference_year;
EST_AGE_SPP2_2017=EST_AGE_SPP2+2017-reference_year;

if EST_AGE_SPP1_2017<=250 and EST_AGE_SPP2_2017<=250;


RUN;


proc sort data=Zero_Vol3;by Strata; run;
PROC SORT DATA=UnAdj_YT_Pop5_Str; by Strata; run;

data Zero_Vol4;
MERGE  Zero_Vol3(IN=a )  UnAdj_YT_Pop5_Str(in=b);
if a and b;
by Strata; run;
/*THIS WAY NOT WORK!!!
NOTE: MERGE statement has more than one data set with repeats of BY
      values.

NOTE: MERGE statement has more than one data set with repeats of BY
      values.
NOTE: There were 356 observations read from the data set WORK.ZERO_VOL3.
NOTE: There were 375 observations read from the data set
      WORK.UNADJ_YT_POP5_STR.
NOTE: The data set WORK.ZERO_VOL4 has 488 observations and 24 variables.

*/


/*THIS WAY WORKED, assign Strata level mean yield curve, 
then ratio adjusted based on the projected yields of year 2017 or reference year*/
data Zero_Vol5;
set  Zero_Vol3;
keep  Strata  FEATURE_ID;RUN;

proc sql;
 create table Zero_Vol6 as
 select * from Zero_Vol5 left join UnAdj_YT_Pop5_Str
 on Zero_Vol5.Strata=UnAdj_YT_Pop5_Str.Strata;
quit;
/*
NOTE: Table WORK.ZERO_VOL6 created, with 8900 rows and 18 columns.

*/


proc sort data=Zero_Vol6; 
by FEATURE_ID PRJ_TOTAL_AGE;run;
DATA  Zero_Vol61;
MERGE Zero_Vol6 (IN=A)  V7_2017_DKL_Chk3(IN=B );
IF A AND B;
by FEATURE_ID;run;

DATA  Zero_Vol62;
SET   Zero_Vol61;

R_VOL_2017=PRJ_VOL_DWB/PRJ_VOL_DWB_2017;
/*ratio adjustment*/
WHERE PRJ_TOTAL_AGE=250;
KEEP  FEATURE_ID  R_VOL_2017  PRJ_VOL_DWB_2017;

RUN;


DATA  Zero_Vol63;
MERGE   Zero_Vol62(IN=A)   Zero_Vol6(IN=B);
IF A AND B;
by FEATURE_ID;


PRJ_VOL_DWB=PRJ_VOL_DWB/R_VOL_2017;

run;


DATA  Zero_Vol64;
set   Zero_Vol63;
if PRJ_TOTAL_AGE=250 and PRJ_VOL_DWB in (0,.) ;
run;
/*
NOTE: There were 3650 observations read from the data set
      WORK.ZERO_VOL63.
NOTE: The data set WORK.ZERO_VOL64 has 0 observations and 20 variabl

*/

DATA  Zero_Vol65;
set   Zero_Vol64;
keep  FEATURE_ID;
run;

DATA  Zero_Vol66;
merge   Zero_Vol65(in=a)   Zero_Vol6(in=b) ;
if a and b;
by FEATURE_ID;run;

DATA  Zero_Vol67;
merge Zero_Vol63(in=a) Zero_Vol65(in=b) ;
if a and not b;
by FEATURE_ID;run;
/*
NOTE: There were 3650 observations read from the data set
      WORK.ZERO_VOL63.
NOTE: There were 0 observations read from the data set WORK.ZERO_VOL65.
NOTE: The data set WORK.ZERO_VOL67 has 3650 observations and 20

*/

DATA  Zero_Vol68;
set   Zero_Vol67
      Zero_Vol66;
run;
proc sort ;
by FEATURE_ID;run;
/*
NOTE: There were 3650 observations read from the data set
      WORK.ZERO_VOL67.
NOTE: There were 0 observations read from the data set WORK.ZERO_VOL66.
NOTE: The data set WORK.ZERO_VOL68 has 3650 observations and 20

*/


/*11059210*/

DATA  Zero_Vol69;
set   Zero_Vol68;
if last.FEATURE_ID;
by FEATURE_ID;
KEEP FEATURE_ID;
run;
/*
NOTE: There were 79575 observations read from the data set    WORK.ZERO_VOL68.
NOTE: The data set WORK.ZERO_VOL69 has 3183 observations and 1 variables.

*/

data UnAdj_YT73;
merge UnAdj_YT7(in=a)   Zero_Vol69(in=b);
if a and not b;
by FEATURE_ID;run;
/*
NOTE: There were 3650 observations read from the data set
      WORK.ZERO_VOL68.
NOTE: The data set WORK.ZERO_VOL69 has 146 observations and 1 variables.

*/


/*WORK AROUND NOTES:
this is the final Unadjusted and capped yield table */
data DKL.UnAdj_YT7;
set /*UnAdj_YT73*/
    UnAdj_YT73
    UnProj_YT7

 Zero_Vol68; 
run;


/*
NOTE: There were 4377000 observations read from the data set      WORK.UNADJ_YT73.
NOTE: There were 8050 observations read from the data set      WORK.UNPROJ_YT7.
NOTE: There were 3650 observations read from the data set      WORK.ZERO_VOL68.
NOTE: The data set DKL.UNADJ_YT7 has 4388700 observations and 27

*/

proc sort; 
by FEATURE_ID PRJ_TOTAL_AGE;run;

/*this version use EXTREME VOLUME POLYGONS AND ABNORMALITY
where Vol1-Vol2>20 or Vol2-Vol3>20  or Vol3-Vol4>20  or Vol4-Vol5>20;
POLYGONS WERE ASSIGNED STRATA MEAN YIELD CURVES TO REDUCE POTENTIAL BIAS.*/



data UnAdj_YT7_2963107;
set  UnAdj_YT7;
where FEATURE_ID=2963107;
run;

data UnAdj_YT7_2963107_adj;
set  DKL.UnAdj_YT7;
where FEATURE_ID=2963107;
run;



data Zero_Vol7;
set  Zero_Vol68;
PRJ_VOL_DWB=round(PRJ_VOL_DWB,.1);
keep FEATURE_ID PRJ_TOTAL_AGE  PRJ_VOL_DWB;

RUN;
/*
NOTE: There were 3650 observations read from the data set
      WORK.ZERO_VOL68.
NOTE: The data set WORK.ZERO_VOL7 has 3650 observations and 3 variables.

*/



 PROC EXPORT DATA=Zero_Vol7 
 OUTFILE= "&dir_v7\DKL_NaturalStand_YT_NotPrjPolys.CSV"
 DBMS=CSV REPLACE; RUN;

/*
%macro Export_mdb(f1,f2);
PROC EXPORT DATA= &f1
            OUTTABLE= "&f2"
            DBMS=ACCESS2000 REPLACE;
     DATABASE="E:\\VDYP7_YT_TSR_Prod\KootenayLake_976\DKL_NaturalStand_YT_V1.mdb";
RUN;
%mend;
%Export_mdb(UnAdj_YT8,Yields);*/

data Extrem_Ori8;
set  UnAdj_YT7;
where PRJ_VOL_DWB>2000;run;
/*NOTE: There were 0 observations read from the data set WORK.UnAdj_YT7.
      WHERE PRJ_VOL_DWB>3000;
NOTE: The data set WORK.Extrem_Ori8 has 0 observations and 18 variables.*/


/*check for abnormality volumes again after manipualation*/
data Abnorm_UnAdj6;
set UnAdj_YT7;
where PRJ_TOTAL_AGE in (50,60, 70,80,90,100, 110) ;keep FEATURE_ID PRJ_VOL_DWB PRJ_TOTAL_AGE;run;
proc transpose data =Abnorm_UnAdj6  out =Abnorm_UnAdj7 (drop = _name_)
  prefix =Vol;    VAR PRJ_VOL_DWB;   by FEATURE_ID;  run;
/*
NOTE: There were 1226582 observations read from the data set
      WORK.ABNORM_UNADJ6.
NOTE: The data set WORK.ABNORM_UNADJ7 has 175226 observations and 8

*/

data Abnorm_UnAdj8;
set  Abnorm_UnAdj7;
where Vol1-Vol2>20 or Vol2-Vol3>20  or Vol3-Vol4>20  or Vol4-Vol5>20 
/*  or Vol5-Vol6>20  or Vol6-Vol7>20*/;run;
/*check for extreme volumes again after manipualation

NOTE: The data set WORK.Abnorm_UnAdj8 has 0 observations and 8 variable
*/


proc means data =DKL.UnAdj_YT7;
CLASS Strata PRJ_TOTAL_AGE;
var  PRJ_PCNT_STOCK  PRJ_SITE_INDEX  PRJ_DOM_HT PRJ_LOREY_HT PRJ_DIAMETER PRJ_TPH  PRJ_BA PRJ_VOL_WS PRJ_VOL_CU PRJ_VOL_D PRJ_VOL_DW PRJ_VOL_DWB;
OUTPUT OUT =UnAdj_YT_Str4  mean=  n=n;
*weight POLYGON_AREA; 
run;
data UnAdj_YT_Str5;
set  UnAdj_YT_Str4;
where _Type_=3; run;


proc means data =DKL.UnAdj_YT7;
CLASS PRJ_TOTAL_AGE;
var  PRJ_PCNT_STOCK  PRJ_SITE_INDEX  PRJ_DOM_HT PRJ_LOREY_HT PRJ_DIAMETER PRJ_TPH  PRJ_BA PRJ_VOL_WS PRJ_VOL_CU PRJ_VOL_D PRJ_VOL_DW PRJ_VOL_DWB;
OUTPUT OUT =UnAdj_YT_Pop4  mean=  n=n;
*weight POLYGON_AREA; 
run;
data UnAdj_YT_Pop5;
set  UnAdj_YT_Pop4;
where _Type_=1; run;

 /*for general Yield curve graphing, check it may write to  H:\RDW_USER\Jobs folder or
 C:\Users\wxu\AppData\Local\Temp\SAS Temporary Files folder*/
AXIS1 LABEL=(A=90 R=0 F=swissB H=0.40 CM 'Volume_DWB (m3/ha)');
AXIS2 order=(0 to 300 by 20)  LABEL=(F=swissB H=0.4 CM 'Total Age (Years)');
SYMBOL1  V=dot       C=Green  H=0.4 CM  I=join l=1 w=0.1 r=1;
SYMBOL2  V=triangle  C=Blue    H=0.4 CM I=join l=1 w=0.1 r=1;
Title "Unadjusted Composit Yield Curve by Strata (Weighted)";
proc gplot data=UnAdj_YT_Str5;
*where _Type_=3;
plot  PRJ_VOL_DWB * PRJ_TOTAL_AGE /overlay noframe /*href=100 vref=100*/haxis=axis2 vaxis=axis1 nolegend;
NOTE HEIGHT=2  FONT=SWISSB A=0  MOVE=(25,40)  ; 
by Strata;
 RUN;QUIT;
 
Title "Unadjusted Overall Composit Yield Curve (Weighted)";
proc gplot data=UnAdj_YT_Pop5;
*where _Type_=1;
plot  PRJ_VOL_DWB * PRJ_TOTAL_AGE /overlay noframe /*href=100 vref=100*/haxis=axis2 vaxis=axis1 nolegend;
NOTE HEIGHT=2  FONT=SWISSB A=0  MOVE=(25,40)  ; 
 RUN;QUIT;



 
/*Box plot Without extreme volumes for the Adjusted and Un-adjusted populations*/

 /*for the UnAdjusted yield tables*/

data UnAdj_YT90;
set  DKL.UnAdj_YT7;/*this is the final Unadjusted and capped yield table */ 
format Vol_Grp $18.;
    if PRJ_VOL_DWB  <200    then Vol_Grp = 'Vol<200';
    if PRJ_VOL_DWB >=200    then Vol_Grp = 'Vol200+';
     label    Strata = 'Strata'
     Vol_Grp = 'Vdwb Group'; 
RUN;

proc template;
          define style mystyle;
           parent = styles.printer;          class graphdata1 / 
                     color = grayaa 
                     contrastcolor = gray00 
                     markersymbol = 'circle';          class graphdata2 / 
                     color = graycc 
                     contrastcolor = grayaa 
                     markersymbol = 'square';
           end;
run;

Title 'PRJ_VOL_DWB (m3/ha) Box plot--UnAdj. ';
ods pdf file = 'E:\\VDYP7_YT_TSR_Prod\KootenayLake\UnAdj_BoxPlot_Grp_NoExtrem.pdf' 
           notoc style = mystyle;
proc sgplot 
           data = UnAdj_YT90;
           vbox PRJ_VOL_DWB / 
                     category = Strata
                     group =Vol_Grp;
run; 

/*ods pdf file = 'INSERT YOUR DIRECTORY PATH HERE\UnAdj_YT90.pdf' */
ods pdf file = 'E:\\VDYP7_YT_TSR_Prod\KootenayLake\UnAdj_BoxPlot_NoGrp_NoExtrem.pdf' 
           notoc style = mystyle;
proc sgplot 
           data = UnAdj_YT90;
           vbox PRJ_VOL_DWB / 
                     category = Strata
                     /*group =Vol_Grp*/;
run; 


*LIBNAME test "E:\\VDYP7_YT_TSR_Prod\KootenayLake_F88_976";
data test;
set DKL.UNADJ_YT7;
where PRJ_TOTAL_AGE<=30 and PRJ_VOL_DWB>0; run;
/*
NOTE: There were 61153 observations read from the data set DKL.UNADJ_YT7.
      WHERE (PRJ_TOTAL_AGE<=30) and (PRJ_VOL_DWB>0);
NOTE: The data set WORK.TEST has 61153 observations and 27 variables.


*/

data UNADJ_YT8;
set DKL.UNADJ_YT7;
  if PRJ_TOTAL_AGE<=20 and PRJ_VOL_DWB>0 then do;
PRJ_VOL_WS=0; PRJ_VOL_CU=0; PRJ_VOL_D=0; PRJ_VOL_DW=0; PRJ_VOL_DWB=0; END;

keep FEATURE_ID PRJ_TOTAL_AGE PRJ_VOL_DWB; 
run;
/*HERE TO assign the volumes to zero at very young age for those polygons that 
with data issues. Since VDYP7 volume is mainly derivered from basal area, dom height and
lorey height, indirectly related to age. if the polygon is given unreasonable BA and height 
at a young age, VDYP7 read the data and will think  it is a stand thta will generate some 
yields based on the input data. Also, the backgrow process may also contribute to the issues.

In addition, the lorey height miscalculation bug may also cause some of the issues.
So , to avoid misleading, here assign them to zero to be safe. Actually, TSR process will not
use the volume at young ages, say 60 years.

NOTE: There were 4388700 observations read from the data set
      DKL.UNADJ_YT7.
NOTE: The data set WORK.UNADJ_YT8 has 4388700 observations and 3


*/

/*to create a mean curve for those not get projected polygons due to different 
data issues or projection issues*/

 PROC EXPORT DATA=UNADJ_YT8 
 OUTFILE= "E:\\VDYP7_YT_TSR_Prod\KootenayLake\DKL_NaturalStand_YT_V2.CSV"
 DBMS=CSV REPLACE; RUN;
 /*unAdjusted,capped for young age <=20 years merchantable volume*/


data fid_test;
set UNADJ_YT8;
if first.FEATURE_ID;
by FEATURE_ID;
run;
/*
NOTE: There were 4388700 observations read from the data set
      WORK.UNADJ_YT8.
NOTE: The data set WORK.FID_TEST has 175548 observations and 3 variables


*/



/*WORK AROUND NOTES:
Spot check of the final adjusted yield curves for those projected, but got zero volumes at age 200 due to low SI, or other not normal attributes*/
data fid_test_2963107;
set UNADJ_YT8;
where FEATURE_ID=2963107;
run;


 /*check extreme heights*/
Data Chk_Ext_UNADJ_Ht;
set  DKL.UNADJ_YT7;
where PRJ_DOM_HT>70;
run;
/*
NOTE: There were 31 observations read from the data set DKL.UNADJ_YT7.
      WHERE PRJ_DOM_HT>70;
NOTE: The data set WORK.CHK_EXT_UNADJ_HT has 31 observations and 27

*/

Data Chk_Ext_UNADJ_Ht2;
set  Chk_Ext_UNADJ_Ht;
if first.FEATURE_ID;
by FEATURE_ID;
run;
/*NOTE: There were 6 observations read from the data set
      WORK.CHK_EXT_UNADJ_HT.
NOTE: The data set WORK.CHK_EXT_UNADJ_HT2 has 6 observations and 27

*/

Data Chk_Ext_UNADJ_Ht2;
set  DKL.UNADJ_YT7;
where FEATURE_ID=9283550;
run;
/*
NOTE: There were 0 observations read from the data set
      POP_YT.UNADJ_FINAL_YT7.
      WHERE FEATURE_ID=9283550;
NOTE: The data set WORK.Chk_Ext_UNADJ_Ht2 has 0 observations and 108 variables.
*/



/*this is the final capped Height table to be sent to analyst
HERE TO cap the extreme values of the heights due to sindex issue*/
data UNADJ_Final_StandHTs;
set DKL.UNADJ_YT7;
  if PRJ_DOM_HT>70 then do;PRJ_DOM_HT=0; END;

keep FEATURE_ID PRJ_TOTAL_AGE PRJ_DOM_HT; 
run;
/*
NOTE: There were 8273625 observations read from the data set  DKL.UNADJ_YT7.
NOTE: The data set WORK.UNADJ_FINAL_STANDHTS has 8273625 observations and

NOTE: There were 9062350 observations read from the data set   DKL.UNADJ_YT7.
NOTE: The data set WORK.UNADJ_FINAL_STANDHTS has 9062350 observations and
*/

 PROC EXPORT DATA=UNADJ_Final_StandHTs
 OUTFILE= "E:\\VDYP7_YT_TSR_Prod\KootenayLake\DKL_UNADJ_NaturalStand_Hts_V2.CSV"
 DBMS=CSV REPLACE; RUN;
/*
NOTE: 1713519 records were written to the file
      'E:\\VDYP7_YT_TSR_Prod\KootenayLake\DKL_UNADJ_NaturalStand_Hts_V2.CSV'.
      The minimum record length was 12.
      The maximum record length was 35.
NOTE: There were 1713518 observations read from the data set WORK.UNADJ_FINAL_STANDHTS.

*/

/*TO CHECK THE ERROR POLYGONS after the runs*/

%let err      =AA_Final_err.log;
%let csv_out  =DKL_Adjusted_YT_125175;


%let err1      =HCSV-Err_125175_0To250_DKL_N1.txt;
%let err2      =HCSV-Err_125175_YearToYearInc1_DKL_N2.txt;
                
filename table3 "&dir_v7\&err1" ;run ;
/*these are the NEW LENGTH*/
DATA ERROR1 ;
format  District $3. MAP_ID $7. POLYGON_ID 8.0  FEATURE_ID 8.0  LAYER_ID $1.;
INFILE TABLE3 LRECL=180 PAD  ;
  INPUT @1 HEADER $80.
        @52 err_type $1.
        @53 msg $90.
        ; 
District = substr(header,1,3);

*MAP_ID = substr(header,4,7);
MAP_ID = substr(header,1,7);
POLYGON_ID = substr(header,13,9);

*FEATURE_ID = substr(header,37,7);
FEATURE_ID = substr(header,33,9);

*LAYER_ID = substr(header,48,1);
LAYER_ID = substr(header,44,1);
*error_type= substr(header,52,1);
error_type= substr(header,48,1);
run;

filename table3 "&dir_v7\&err2" ;run ;

/*these are the NEW LENGTH*/
DATA ERROR2 ;
format  District $3. MAP_ID $7. POLYGON_ID 8.0  FEATURE_ID 8.0  LAYER_ID $1.;
INFILE TABLE3 LRECL=180 PAD  ;
  INPUT @1 HEADER $80.
        @52 err_type $1.
        @53 msg $90.
        ; 
District = substr(header,1,3);

*MAP_ID = substr(header,4,7);
MAP_ID = substr(header,1,7);
POLYGON_ID = substr(header,13,9);

*FEATURE_ID = substr(header,37,7);
FEATURE_ID = substr(header,33,9);

*LAYER_ID = substr(header,48,1);
LAYER_ID = substr(header,44,1);
*error_type= substr(header,52,1);
error_type= substr(header,48,1);
run;

data ERROR ;
SET ERROR1 ERROR2;
RUN;
/*

NOTE: There were 516296 observations read from the data set WORK.ERROR1.
NOTE: There were 87859 observations read from the data set WORK.ERROR2.
NOTE: The data set WORK.ERROR has 604155 observations and 9 variables.


*/


proc sort; by FEATURE_ID;run;

DATA NSR  other;
SET ERROR ;
IF MSG='able to project layer due to Non-Forest Descriptor'
and  ERR_TYPE='n'  then output  NSR;/*None-Satisfied regeneration?*/
else output other;
run;
/*
*/

/*Error message from Step1*/
Title "Error message from Step1";
proc freq data = ERROR ;
table err_type *msg  / list missing missprint  nopercent ; run;

proc print data = ERROR  (where = (err_type = 'E') obs=100); run;
/*proc print data = ERROR  (where = (err_type = 'E') ); run;*/

data err_poly;
set ERROR ;
if err_type="E";
run;
/* 
NOTE: There were 604155 observations read from the data set WORK.ERROR.
NOTE: The data set WORK.ERR_POLY has 141 observations and 9 variables.


*/


ods html close;
ods listing;
proc freq data =err_poly;
table err_type *msg  / list missing missprint  nopercent ; run;
/*PRJ_VOL_DWB (m3/ha) Box plot--UnAdj.  
The FREQ Procedure
err_type msg Frequency Cumulative
Frequency 
*/

/*TO GET THE INPUT TABLES OF THESE POLYGONS THAT GOT ERROR MESSAGE*/
data err_poly_FID;
set  err_poly;
if first.FEATURE_ID; by FEATURE_ID;
run;
/* 
NOTE: There were 141 observations read from the data set WORK.ERR_POLY.
NOTE: The data set WORK.ERR_POLY_FID has 141 observations and 9


*/



DATA BA75_LESS125;
SET err_poly ;
MSG1=SUBSTR(MSG,1,40);
/*IF MSG1='INVALIDSTANDADJUSTMENT - Layer BA 7.5cm+';
INVALIDPARAMETER - Minimum possible TPH between 7.5cm+*/
run;
proc freq data =BA75_LESS125;
table err_type *msg1  / list missing missprint  nopercent ; run;
/*            
  err_type  MSG1                                      Frequency   Frequency
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
E         CORELIBRARYERROR - An error occurred pro       107         107
E         INVALIDSITEINFO - Very low or null site          4         111
E         PERCENTNOT100 - Layer '1' Percent did no        29         140
E         PERCENTNOT100 - Layer '2' Percent did no         1         141

*/



data err_INPUT_POLY;
MERGE  err_poly_FID(in=a  keep=FEATURE_ID)  POLY(in=b);
if a and b;
by FEATURE_ID;
run;
/*
NOTE: There were 55 observations read from the data set WORK.ERR_POLY_FID.
NOTE: There were 330958 observations read from the data set WORK.POLY.
NOTE: The data set WORK.ERR_INPUT_POLY has 55 observations and 42

*/
data err_INPUT_LAYER;
MERGE  err_poly_FID(in=a  keep=FEATURE_ID)  LAYER(in=b);
if a and b;
by FEATURE_ID;
run;
/*
NOTE: There were 55 observations read from the data set WORK.ERR_POLY_FID.
NOTE: There were 429110 observations read from the data set WORK.LAYER.
NOTE: The data set WORK.ERR_INPUT_LAYER has 97 observations and 38

*/

 PROC EXPORT DATA=err_INPUT_POLY 
 OUTFILE= "&dir_v7\err_INPUT_POLY_AllObs.CSV"  DBMS=CSV REPLACE;
RUN;
 PROC EXPORT DATA=err_INPUT_LAYER 
 OUTFILE= "&dir_v7\err_INPUT_LAYER_AllObs.CSV"  DBMS=CSV REPLACE;
RUN;





proc sort  data=Task_data01;by FEATURE_ID;
data err_poly3;
MERGE  err_poly(in=a  drop= LAYER_ID) Task_data01(in=b);
by FEATURE_ID;
if a and b;
run;
/*
*/

data err_poly30;
set  err_poly3;
if msg="INVALID_PARAM - Input Field DISTURBANCE_START_DATE expects dates with a 4 digit year in t"  or
msg="INVALID_PARAM - Input Field DISTURBANCE_END_DATE expects dates with a 4 digit year in the" then delete;run;

/*
*/

data err_poly31;
set  err_poly30;
if first.FEATURE_ID;
by FEATURE_ID;
run;
/*
NOTE: There were 101 observations read from the data set WORK.ERR_POLY30.
NOTE: The data set WORK.ERR_POLY31 has 55 observations and 92 variables

*/


data err_poly32;
MERGE  err_poly31(in=a  /*drop= LAYER_ID*/) Task_data01(in=b);
by FEATURE_ID;
if a and b;
run;
/*
*/





data err_poly4;
set  err_poly3;
if first.FEATURE_ID;
by FEATURE_ID;
drop header District MAP_ID POLYGON_ID  Layer_ID error_type  /*err_type  msg*/;
run;
/*
*/


PROC EXPORT DATA=err_poly4
OUTFILE= "&dir_v7\Fatal Error polygons  &sysdate." 
   DBMS=EXCEL2000 REPLACE;
   SHEET="FatalError"; 
RUN;




