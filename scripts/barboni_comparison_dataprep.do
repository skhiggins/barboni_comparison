**INFO ------------------------------------------------------------------------
** File name: 	        	barboni_comparison_dataprep.do	      
** Creation date:        	08/05/2021
** Last modified date:   	08/30/2021
** Author:          		Sean Higgins
** Research Assistance:		Erick Molina
** Modifications:        
**         
** Purpose:					Compare estimates from various papers
**	                   
**-----------------------------------------------------------------------------

***************
** DIRECTORY **
***************
clear all
global directory "C:/Dropbox/Discussing/2021/NBER/2/barboni_comparison" // "C:/Users/erick/Dropbox/NBER/2/barboni_comparison" //Write here your directory

tokenize `"$S_ADO"', parse(";")
while `"`1'"' != "" { // "
	if `"`1'"' != "BASE" cap adopath - `"`1'"' // "
	macro shift
}

adopath ++ "$directory/scripts/programs"
sysdir set PLUS "$directory/scripts/programs"
sysdir set PERSONAL "$directory/scripts/programs"

*********
** LOG **
*********

time // saves locals `date' (YYYYMMDD) and `time' (YYYYMMDD_HHMMSS)
local project barboni_comparison_figure
cap log close
set linesize 200
log using "$directory/logs/`project'_`time'.log", text replace
di "`c(current_date)' `c(current_time)'"
pwd

************
** LOCALS **
************
// List of studies
local a = 0 // counter
#delimit ;
local auth_list
	angelucci15
	augsburg15
	banerjee15
	crepon15
	bruhn14
	stein20
	breza21
	barboni21
	callen19
;
#delimit cr
tokenize `auth_list'
local estimate_list "" 

/* 
// For results display
local te "Treatment Effect"
local se "Standard error"
*/

// Matrix for results
	// Columns will be: 
	//  1) te_levels
	//  2) se_levels
	//  3) control_mean
	//  4) te_logs
	//  5) se_logs

matrix incomes = J(9,5,.)
local rr = 0 // row counter
local te_levels_col  1
local se_levels_col 2
local control_mean_col 3
local te_logs_col 4
local se_logs_col  5
matrix colnames incomes = "te_levels" "se_levels" "control_mean" "te_logs" "se_logs"
scalar _alpha = 0.05 // significance level

******************************
** ESTIMATES FOR EACH STUDY **
******************************
** Reset study counter to 0
local a = 0

** Metadata from studies to merge in later
clear
import excel using "$directory/data/barboni_comparison_metadata.xlsx", ///
	firstrow allstring
	rename authors auth
	/*lower*/
tempfile tomerge 
save `tomerge', replace

**********************
** ANGELUCCI (2015) **
**********************

** NOTES: Part of the replication code is used

** Load and merge data:
use if survey == "Endline" using "$directory/data/angelucci15/analysis_data_AEJ_pub.dta", clear

** Estimation:
xi i.supercluster_xi
unab sc_controls : _Isuper*
gen total_income = Q13_3_amount + Q13_jobincome + remitandtrans + Q13_5_amount_mo
qui reg total_income Treatment `sc_controls', vce(cl cluster)

local ++a
local auth "``a''"

scalar _te_levels_ =  _b[Treatment]
scalar _se_levels_ =  _se[Treatment]

** Obtaining control mean:
sum total_income if Treatment == 0
scalar _control_mean_ = r(mean)

local T ""
local ++rr
local rownames `rownames' `auth'

scalar _te_levels_`auth'_`T' = _te_levels_
scalar _se_levels_`auth'_`T' = _se_levels_
scalar _control_mean_`auth'_`T' = _control_mean_

foreach est in te_levels se_levels control_mean {
	matrix incomes[`rr',``est'_col']= _`est'_`auth'_`T'
}

*********************
** AUGSBURG (2015) **
*********************

** NOTES: Part of the replication code is used						

** Load and merge data:
use "$directory/data/augsburg15/Baseline/Covariates-Bosnia-Baseline.dta", clear
qui merge 1:1 intervid using "$directory/data/augsburg15/indicator-reinterviewed.dta", nogen
qui merge 1:1 intervid using "$directory/data/augsburg15/Followup/Employment-status-respondent.dta", nogen keepusing(resp_es2)
qui merge 1:1 intervid using "$directory/data/augsburg15/Followup/SECTION-2---Loans-cl.dta", nogen
qui merge 1:1 intervid using "$directory/data/augsburg15/Followup/SECTION-3---Consumption-cl.dta", nogen /*keepusing(durablec nondc foodc_h foodc_o cigalcc foodc)*/
qui merge 1:1 intervid using "$directory/data/augsburg15/Followup/SECTION-4---Assets-cl.dta",  nogen
qui merge 1:1 intervid using "$directory/data/augsburg15/Followup/SECTION-5---Income-cl.dta", nogen 
qui merge 1:1 intervid using "$directory/data/augsburg15/Followup/SECTION-6---Business-cl.dta", nogen keepusing(bm_own bm_expenses bm_revenue bm_profit bm_staff_FT bm_staff_PT bm_staff_T  bm_staffsalary   bm_staff_hhft bm_staff_hhpt bm_staff_hht bm_staff_hhpay bm_staff_outft bm_staff_outpt bm_staff_outt bm_staff_outpay bm_trade bm_service bm_agric bm_prod  bm_reg)
qui merge 1:1 intervid using "$directory/data/augsburg15/Followup/SECTION-7---Savingscl.dta", nogen keepusing(savings_avg savings_yn contrib_weekly contrib_monthly contrib_yearly contrib_no sav_busexp sav_edu sav_med sav_old sav_repair sav_emergency sav_cons sav_bequest sav_debt sav_festival sav_other)
qui merge 1:1 intervid using "$directory/data/augsburg15/Followup/SECTION-8---Household-roster-cl.dta", nogen
qui merge 1:1 intervid using "$directory/data/augsburg15/Followup/SECTION-9---Shocks-cl.dta", nogen keepusing(jobloss_yn jobgain_yn othergain_yn badharvest_yn illnessearn_yn illnessnonearn_yn deathearn_yn deathnonearn_yn emplleft_yn crime_yn compet_yn otherloss_yn jobgain_yn othergain_yn jobloss_ydec badharvest_ydec illnessearn_ydec illnessnonearn_ydec deathearn_ydec deathnonearn_ydec emplleft_ydec crime_ydec compet_ydec otherloss_ydec)
qui merge 1:1 intervid using "$directory/data/augsburg15/Followup/SECTION-10---Stress-cl.dta", nogen
qui merge 1:1 intervid using "$directory/data/augsburg15/incentive-given.dta", nogen


** Create globals:
#d ;
	global Xvar "b_resp_female b_resp_age b_resp_age2 b_resp_ms1 b_resp_ms4 b_resp_ms5  b_resp_ss b_resp_ul
		 b_kids_05 b_kids_610 b_kids_1116 b_hhmem_female  b_hhmem_employed b_hhmem_school b_hhmem_retired";
	global Edu "t_edul t_eduh respedu_l";
	global Busi "t_busi t_nobus b_bm_own";
	global Xvaredu "b_resp_female b_resp_age b_resp_age2 b_resp_ms1 b_resp_ms4 b_resp_ms5  
		 b_kids_05 b_kids_610 b_kids_1116 b_hhmem_female  b_hhmem_employed b_hhmem_school b_hhmem_retired";
#d cr	
	
** Clean and prepare data:
gen b_resp_age2=b_resp_age*b_resp_age 
// Variables for heterogeneous impacts
gen respedu_l=b_resp_ps==1
gen respedu_h=b_resp_ps==0
gen t_edul=treatment*respedu_l
gen t_eduh=treatment*respedu_h
gen nobus=b_bm_own==0
gen t_busin=treatment*b_bm_own
gen t_nobus=treatment*nobus

global T4Income01 "y_selfempl yval_selfempl y_wages yval_wages y_remit yval_remit y_benefit yval_benefit yval_total"
	
foreach x of varlist y_selfempl y_agric y_shop y_manuf  y_privb y_governmnt y_remit y_benefit y_pension y_rent {
	qui replace `x'=0 if `x'==.
	qui replace `x'=. if followup==0
}
egen y_wages=rowmax(y_agric y_shop y_manuf  y_privb y_governmnt)
egen yval_wages=rowtotal(yval_agric yval_shop yval_manuf yval_privb yval_governmnt)
	
** Calculate total income:	
gen yval_total = yval_selfempl + yval_wages + yval_remit + yval_benefit	
	
** Estimation:
qui reg yval_total treat $Xvar if followup==1, robust

local ++a
local auth "``a''"

scalar _te_levels_ = _b[treatment]
scalar _se_levels_ = _se[treatment]

** Obtaining control mean:
sum yval_total if followup==1 & treatment==0
scalar _control_mean_ = r(mean)

local T ""
local ++rr
local rownames `rownames' `auth'

scalar _te_levels_`auth'_`T' = _te_levels_
scalar _se_levels_`auth'_`T' = _se_levels_
scalar _control_mean_`auth'_`T' = _control_mean_

foreach est in te_levels se_levels control_mean {
	matrix incomes[`rr',``est'_col']= _`est'_`auth'_`T'
}

*********************
** BANERJEE (2015) **
*********************

** NOTES: Part of the replication code is used

** Load data and create globals:
use "$directory/data/banerjee15/2013-0533_data_endlines1and2.dta", clear
global area_controls "area_pop_base area_debt_total_base area_business_total_base area_exp_pc_mean_base area_literate_head_base area_literate_base"

** Create total_income by adding bizprofit and waager_nonbiz
/*gen total_income_1 = bizprofit_1 + wages_nonbiz_1 */
gen total_income_2 = bizprofit_2 + wages_nonbiz_2

** Estimation:
est clear
qui reg total_income_2 treatment $area_controls [pweight=w2], cluster(areaid)

local ++a
local auth "``a''"

scalar _te_levels_ =  _b[treatment]
scalar _se_levels_ =  _se[treatment]

** Obtaining control mean:
sum total_income_2 if treatment==0 & e(sample)
scalar _control_mean_ = r(mean)

local T ""
local ++rr
local rownames `rownames' `auth'

scalar _te_levels_`auth'_`T' = _te_levels_
scalar _se_levels_`auth'_`T' = _se_levels_
scalar _control_mean_`auth'_`T' = _control_mean_

foreach est in te_levels se_levels control_mean {
	matrix incomes[`rr',``est'_col']= _`est'_`auth'_`T'
}
	
***************************
** CREPON ET. AL. (2015) **
***************************

** NOTES: Part of the replication code is used

**Load data:

#delimit;
use "$directory/data/crepon15/Output/endline_baseline_outcomes.dta", clear;

** Create Household and Respondent variables; 

** Household Controls;

global householdcontrols 
	members_resid_bl nadults_resid_bl head_age_bl act_livestock_bl act_business_bl borrowed_total_bl
	members_resid_d_bl nadults_resid_d_bl head_age_d_bl act_livestock_d_bl act_business_d_bl borrowed_total_d_bl;

foreach var in members_resid nadults_resid head_age act_livestock act_business borrowed_total {;
	replace `var'_d_bl=1 if `var'_m==0 & `var'_d_bl==.;
};  	

global respondentcontrols ccm_resp_activ other_resp_activ ccm_resp_activ_d other_resp_activ_d;

gen ccm_resp_activ_d=(ccm_resp_activ==.);
replace ccm_resp_activ=0 if ccm_resp_activ_d==1; 
label var ccm_resp_activ_d "1 if ccm_resp_activ missing"; 

gen other_resp_activ_d=(other_resp_activ==.);
replace other_resp_activ=0 if other_resp_activ_d==1; 
label var other_resp_activ_d "1 if other_resp_activ missing"; 

global variables_income /*table 4*/
	income;

local weightversion="noweight";
local sample="samplemodel";

global main_reg
	variables_income;

local j 1;
foreach group in $main_reg {;

if `j'==1 | `j'==4 | `j'==8 | `j'==11 | `j'==14 | `j'==16 {;
	local digit=3;
};

if `j'==2 | `j'==3 | `j'==5 | `j'==7 | `j'==10 | `j'==13 | `j'==15 {;
	local digit=0;
}; 

if `j'==9 | `j'==12  {;
	local digit=2;
}; 

if `j'==6 {;
	local digit=1;
}; 

	local i 1;
	foreach var in $`group' {;

		if `i'==1 {;
			local append_replace="replace";
			};
		if `i'!=1 {;
			local append_replace="append";
			};


 qui xi: reg `var' treatment ${householdcontrols} ${respondentcontrols} i.paire if `sample'==1, cluster(demi_paire) ;

local i=`i'+1;
}; 
local j=`j'+1;
}; 

#delimit cr

local ++a
local auth "``a''"

scalar _te_levels_ =   _b[treatment]
scalar _se_levels_ =  _se[treatment]

** Calculate control mean:
sum income if treatment == 0 & samplemodel == 1
scalar _control_mean_ = r(mean)

local T ""
local ++rr
local rownames `rownames' `auth'

scalar _te_levels_`auth'_`T' = _te_levels_
scalar _se_levels_`auth'_`T' = _se_levels_
scalar _control_mean_`auth'_`T' = _control_mean_

foreach est in te_levels se_levels control_mean {
		matrix incomes[`rr',``est'_col']= _`est'_`auth'_`T'
}
	
***********************
** BRUHN LOVE (2014) **
***********************

** NOTES: No replication data available, data taken from the paper

local ++a
local auth "``a''"

scalar _te_logs_ = 0.0739 // Column 4, Table 7b, Page 5363
scalar _se_logs_ = 0.0274 

local T ""
local ++rr
local rownames `rownames' `auth'

scalar _te_logs_`auth'_`T' = _te_logs_
scalar _se_logs_`auth'_`T' = _se_logs_

foreach est in te_logs se_logs {
		matrix incomes[`rr',``est'_col']= _`est'_`auth'_`T'
}

***************************
** STEIN YANNELIS (2020) **
***************************

** NOTES: No replication data available, data taken from the paper

local ++a
local auth "``a''"

scalar _te_logs_ = 0.0385 // Column 4, Table 7b, Page 5363
scalar _se_logs_ = 0.00917 

local T ""
local ++rr
local rownames `rownames' `auth'

scalar _te_logs_`auth'_`T' = _te_logs_
scalar _se_logs_`auth'_`T' = _se_logs_

foreach est in te_logs se_logs {
		matrix incomes[`rr',``est'_col']= _`est'_`auth'_`T'
}

*************************
** BREZA KINNAN (2021) **
*************************

** NOTES: No replication data available, data taken from the paper

local ++a
local auth "``a''"

scalar _te_levels_ =   86.227 // Column 4, Table 4, Page 1477
					   // Main Regression
scalar _se_levels_ =  30.333 
scalar _control_mean_ = 836.465

local T ""
local ++rr
local rownames `rownames' `auth'

scalar _te_levels_`auth'_`T' = _te_levels_
scalar _se_levels_`auth'_`T' = _se_levels_
scalar _control_mean_`auth'_`T' = _control_mean_

foreach est in te_levels se_levels control_mean {
		matrix incomes[`rr',``est'_col']= _`est'_`auth'_`T'
}

***************************
** BARBONI ET. AL.(2021) **
***************************

** NOTES: No replication data available, data taken from the paper

local ++a
local auth "``a''"

scalar _te_logs_ = 0.13 
scalar _se_logs_ = 0.05 

local T ""
local ++rr
local rownames `rownames' `auth'

scalar _te_logs_`auth'_`T' = _te_logs_
scalar _se_logs_`auth'_`T' = _se_logs_

foreach est in te_logs se_logs {
		matrix incomes[`rr',``est'_col']= _`est'_`auth'_`T'
}

***************************
** CALLEN ET. AL. (2019) **
***************************

** NOTES: No replication data available, data taken from the paper

local ++a
local auth "``a''"

scalar _te_levels_ =   3185.3 // Column 3, Table V, Page 1365
					   //  Control municipality time trend but does not
					   // control group time trend - Main Regression
scalar _se_levels_ =  1241 
scalar _control_mean_ = 29393.4

local T ""
local ++rr
local rownames `rownames' `auth'

scalar _te_levels_`auth'_`T' = _te_levels_
scalar _se_levels_`auth'_`T' = _se_levels_
scalar _control_mean_`auth'_`T' = _control_mean_

foreach est in te_levels se_levels control_mean {
		matrix incomes[`rr',``est'_col']= _`est'_`auth'_`T'
}

*****************
** OUTPUT DATA **
*****************

matrix rownames incomes = `rownames'
clear
svmat2 incomes, names(col) rnames(auth) // !user! written by Nick Cox
	// (unlike -svmat-, allows row names to be saved as variable)
gen byte barboni = 0
replace barboni = 1 if strpos(auth, "barboni21")
** drop if mi(se_levels) // extra rows

** Merge in metadata
merge 1:1 auth using `tomerge' // , assert(match)
drop if _merge!=3
drop _merge 
order auth* intervention country outcome notes 

**********
** SAVE **
**********
export delimited using "$directory/proc/barboni_comparison.csv", replace

*************
** WRAP UP **
*************

log close
exit
	



