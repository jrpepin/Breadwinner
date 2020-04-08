*-------------------------------------------------------------------------------
* BREADWINNER PROJECT - NLSY97 Component
* nlsy97_time_varying.do
* Joanna Pepin
*-------------------------------------------------------------------------------

* The goal of this file is to create the time-varying covariates.
* Data was produced by "nlsy97_sample & demo.do"

********************************************************************************
* Setup the log file
********************************************************************************
local logdate = string( d(`c(current_date)'), "%dCY.N.D" ) 		// create a macro for the date

local list : dir . files "$logdir/*nlsy97_time-varying_*.log"	// Delete earlier versions of the log
foreach f of local list {
    erase "`f'"
}

log using "$logdir/nlsy97_time-varying_`logdate'.log", t replace

di "$S_DATE"

********************************************************************************
* Create long mini-data files for processing
********************************************************************************
use "$tempdir/nlsy97_sample.dta", clear

foreach var in 	YINC_1400 YINC_1500 YINC_1700 YINC_1800 ///
				YINC_2000 YINC_2100 YINC_2200 			///
				CV_INCOME_GROSS_YR CV_INCOME_FAMILY {
preserve
	keep PUBID_1997 `var'_*
	reshape long `var'_, i( PUBID_1997 ) j(year)
	save "$tempdir/nlsy97_`var'.dta", replace
restore
}

********************************************************************************
* Merge them all together and process
********************************************************************************
use "$tempdir/nlsy97_YINC_1400.dta", clear

foreach var in 	YINC_1500 YINC_1700 YINC_1800 			///
				YINC_2000 YINC_2100 YINC_2200 			///
				CV_INCOME_GROSS_YR CV_INCOME_FAMILY {
merge 1:1 PUBID_1997 year using "$tempdir/nlsy97_`var'.dta"
drop _merge
}

** MISSING CODES----------------------------------------------------------------

* -1 Refused
* -2 Dont know
* -3 Invalid missing
* -4 Valid missing
* -5 Non-interview

********************************************************************************
* Create BW ratio components
********************************************************************************

** Moms' Income Variables-------------------------------------------------------

* YINC-1400 - R RECEIVE INCOME FROM JOB IN PAST YEAR? (incd)
* YINC-1500 - INCOME IN WAGES, SALARY, TIPS FROM REGULAR OR ODD JOBS (incd2)
* YINC-1700 - TOTAL INCOME FROM WAGES AND SALARY IN PAST YEAR (wages)
* YINC-1800 - ESTIMATED INCOME FROM WAGES AND SALARY IN PAST YEAR (wages_est)

rename 		YINC_1400_ incd
rename 		YINC_1500_ incd2
rename 		YINC_1700_ wages
rename 		YINC_1800_ wages_est

cap drop 	momwages
clonevar 	momwages = wages 	if incd 		!= 0	// has wages
replace		momwages = 0 		if incd 		== 0	// doesn't have wages
replace		momwages = 0 		if incd2 		== 0	// doesn't have wages if answered dk to incd

replace		momwages = 2500 	if wages_est	== 1	// A. $1 - $5,000
replace		momwages = 7500 	if wages_est	== 2	// B. $5,001 - $10,000
replace		momwages = 17500 	if wages_est	== 3	// C. $10,001 - $25,000
replace		momwages = 37500 	if wages_est	== 4	// D. $25,001 - $50,000
replace		momwages = 75000 	if wages_est	== 5	// E. $50,001 - $100,000
replace		momwages = 175000	if wages_est	== 6	// F. $100,001 - $250,000
replace		momwages = 250001	if wages_est	== 7	// G. More than $250,000

replace		momwages = . 		if momwages		<  0	// Address missing	

** Moms' Business earnings------------------------------------------------------

* YINC-2000 - ANY INCOME FROM OWN BUSINESS OR FARM IN PAST YEAR (bizd)
* YINC-2100 - TOTAL INCOME FROM BUSINESS OR FARM IN PAST YEAR (bizinc)
* YINC-2200 - ESTIMATED INCOME FROM BUSINESS OR FARM IN PAST YEAR (biz_est)

rename 		YINC_2000_ bizd
rename 		YINC_2100_ bizinc
rename 		YINC_2200_ biz_est

cap drop 	mombiz
clonevar	mombiz = bizinc if bizd			!=0		// has business income
replace		mombiz = 0		if bizd			==0		// doesn't have business income

replace 	mombiz = 0		if biz_est		==1		// A. LOST/WOULD LOSE MONEY
replace		mombiz = 2500	if biz_est		==2		// B. $1 - $5,000
replace		mombiz = 7500	if biz_est		==3		// C. $5,001 - $10,000
replace		mombiz = 17500	if biz_est		==4		// D. $10,001 - $25,000
replace		mombiz = 37500	if biz_est		==5		// E. $25,001 - $50,000
replace		mombiz = 75000	if biz_est		==6		// F. $50,001 - $100,000
replace		mombiz = 175000	if biz_est		==7		// G. $100,001 - $250,000
replace		mombiz = 250001	if biz_est		==8		// H. More than $250,000

replace		mombiz = . 		if mombiz		<  0	// Address missing

** Mom's total earnings (wages + business income)-------------------------------
cap drop 	momearn
egen 		momearn		= rowtotal(wages mombiz)
replace 	momearn 	=. if momwages ==. | mombiz ==.

** Total Household Income Variables---------------------------------------------
* CV_INCOME_GROSS_YR
* CV_INCOME_FAMILY

cap drop	totinc
gen			totinc = .
replace		totinc = CV_INCOME_GROSS_YR 	if CV_INCOME_GROSS_YR_ !=.
replace		totinc = CV_INCOME_FAMILY_ 		if CV_INCOME_FAMILY_   !=.

replace		totinc = . 		if totinc		<  0	// Address missing

// Create indicator for negative household earnings & no earnings.
cap drop 	hh_noearnings
gen 		hh_noearnings= (totinc <= 0 | totinc ==.)

********************************************************************************
* Merge with wide file data
********************************************************************************
// Clean up datafile
keep PUBID_1997 year momwages mombiz momearn totinc hh_noearnings

// Add back the original datafile
merge m:1 PUBID_1997 using "$tempdir/nlsy97_sample.dta"
assert 	_merge==3 		//all records matched
drop 	_merge

// Clean up temporary datafiles
foreach var in 	YINC_1500 YINC_1700 YINC_1800 			///
				YINC_2000 YINC_2100 YINC_2200 			///
				CV_INCOME_GROSS_YR CV_INCOME_FAMILY {
erase "$tempdir/nlsy97_`var'.dta"
}

********************************************************************************
* Create and process motherhood duration 
********************************************************************************

** Time since first child was born----------------------------------------------
destring 	mom_yr, replace

cap drop 	time
gen			time = .
replace		time = 0 if year == mom_yr

forvalues i = 1/18 {
replace time = `i' if year == mom_yr + `i'
}

** Keep only mothers in first 10 years of motherhood----------------------------
egen 		allrecords 	= count(_N)
keep if 	time <= 9				// Keep only first 10 years of motherhood
egen 		records10 	= count(_N)

global 	allrecords_n	= allrecords
global 	records10_n 	= records10

di "$allrecords_n"	// Total # records
di "$records10_n"	// Total # records for moms in first 10 years of motherhood

********************************************************************************
* Create BW Ratios and save datafile
********************************************************************************
sort 	PUBID_1997 year
tsset 	PUBID_1997 year	// Set as time-series data
tsfill					// Expand to include all years

// Complete mom_yr data for new rows
bysort PUBID_1997 : replace mom_yr = mom_yr[_N] if missing(mom_yr) 

// Fix time var for new rows
cap drop 	time
gen			time = .
replace		time = 0 if year == mom_yr

forvalues i = 1/18 {
replace time = `i' if year == mom_yr + `i'
}

// Lag the income variables because R reports income for prior year

list  PUBID_1997 year time mom_yr momearn totinc momwages mombiz in 1/30

foreach var of varlist 	momearn totinc	momwages mombiz		///
						hh_noearnings{
		by PUBID_1997:  replace `var' = `var'[_n+1]
}

list  PUBID_1997 year time mom_yr momearn totinc momwages mombiz in 1/30

** 50% breadwinning threshold---------------------------------------------------

cap drop hhe50
gen 	 hhe50 = (momearn > .5*totinc) if  hh_noearnings !=1 & !missing(momearn)

** 60% breadwinning threshold---------------------------------------------------

cap drop hhe60
gen 	 hhe60 = (momearn > .6*totinc) if  hh_noearnings !=1 & !missing(momearn)

fre hhe50
fre hhe60

// Order and save the new data file
order PUBID_1997 year mom_yr time momearn totinc hhe50 hhe60 momwages mombiz mar_t1 educ_t1 age_birth
list  PUBID_1997 year mom_yr time momearn totinc hhe50 hhe60 momwages mombiz mar_t1 educ_t1 age_birth in 1/30

save "stata/nlsy97_bw.dta", replace

log close
