*-------------------------------------------------------------------------------
* BREADWINNER PROJECT - NLSY97 Component
* nlsy97_hh50_risk.do
* Joanna Pepin
*-------------------------------------------------------------------------------

********************************************************************************
* Setup the log file
********************************************************************************
local logdate = string( d(`c(current_date)'), "%dCY.N.D" ) 	// create a macro for the date

local list : dir . files "$logdir\*nlsy97_hh50_risk_*.log"	// Delete earlier versions of the log
foreach f of local list {
    erase "`f'"
}

log using "$logdir\nlsy97_hh50_risk_`logdate'.log", t replace

di "$S_DATE"

********************************************************************************
* DESCRIPTION
********************************************************************************
/*
The goal of this file is to create three types of estimates 
for the first 10 years of motherhood:
	1. Risk of entering breadwinning (at each duration of motherhood)
	2. Risk of entering breadwinning, censoring on previous breadwinning
	3. Proportion of breadwinning at each duration of motherhood that have previously breadwon
		D -- women who are breadwinning N -- proportion who had previously breadwon (only for each time)
*/

* This data used in this file were created from the R script nlsy97_04_hhearn, 
* located in the project directory.

********************************************************************************
* Open and prep the data
********************************************************************************
clear
set more off

use 	"stata\nlsy97_hh50.dta", clear
fre year // Make sure the data includes all survey years (1997 - 2017)

// Select only observations since first birth
keep if firstbirth==1 	// selected on this in R already
drop firstbirth 		// this variable has no variation now

********************************************************************************
* B1. Estimates of breadwinning (at each duration of motherhood)
********************************************************************************
tab time hhe50, r
logit hhe50 i.time, or

********************************************************************************
* B2. Risk of entering breadwinning, censoring on previous breadwinning
********************************************************************************

preserve
forvalues t = 0/10 {
	tab hhe50 if time == `t'
	drop if time == `t' & hhe50 ==1
	}
restore

********************************************************************************
* B3. Proportion of breadwinning at each age that have previously breadwon
********************************************************************************

// Look at proportion of breadwinning at each age, censored on previously breadwon

preserve
forvalues a = 18/30 {
	tab hhe50 if age == `a'
	drop if age == `a' & hhe50 ==1
	}
restore

// Create ever breadwinning variable
bysort PUBID_1997 (age) : gen everbw = sum(hhe50)
replace everbw = 1 if everbw >= 1

tab age everbw, r
logit everbw i.age, or

log close
