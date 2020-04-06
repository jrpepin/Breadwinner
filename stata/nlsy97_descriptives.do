*-------------------------------------------------------------------------------
* BREADWINNER PROJECT - NLSY97 Component
* nlsy97_desriptives.do
* Joanna Pepin
*-------------------------------------------------------------------------------

********************************************************************************
* Setup the log file
********************************************************************************
local logdate = string( d(`c(current_date)'), "%dCY.N.D" ) 	// create a macro for the date

local list : dir . files "$logdir\*nlsy97_descriptives_*.log"	// Delete earlier versions of the log
foreach f of local list {
    erase "`f'"
}

log using "$logdir\nlsy97_descriptives_`logdate'.log", t replace

di "$S_DATE"

********************************************************************************
* DESCRIPTION
********************************************************************************
* This file provides basic descriptive information about mothers' income.
* The data used in this file was produced from nlsy97_measures.do

clear
set more off

use "stata/NLSY97_bw.dta", clear

// Count number of respondents
unique 	PUBID_1997

// Make sure the data includes all survey years (1997 - 2017)
fre year

********************************************************************************
* Describe percent breadwinning in the first year
********************************************************************************
// The percent breadwinning (50% threhold) in the first year. (~25%)
	sum hhe50 if time		==0 // Breadwinning in the year of the birth

	gen per_hhe50_atbirth	=100*`r(mean)'
	gen nothhe50_atbirth	=1-`r(mean)'

// The percent breadwinning (60% threhold) in the first year. (~17%)
	sum hhe60 if time		==0 // Breadwinning in the year of the birth

	gen per_hhe60_atbirth	=100*`r(mean)'
	gen nothhe60_atbirth	=1-`r(mean)'

/*	
*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?
	This is sample code to use to verify I can replicate the NLSY's total hh income
	variable with all its components. Spoiler, I can't. 

	// Create a hh total income variable
	cap drop 	hhtot
	egen 		hhtot= rowtotal(wages mombiz chsup dvdend gftinc 	///
								govpro1 govpro2 govpro3 			///
								inhinc intrst othinc rntinc 		///
								wcomp hhinc spwages spbiz  			///
								wcomp_sp)
	replace 	hhtot 	=. if totinc==.

	* My constructed total hh income variable doesn't match the NLSY provided one.
	unique 	PUBID_1997
	unique 	PUBID_1997 if totinc != hhtot

	sum totinc
	sum hhtot

	browse 	PUBID_1997 year time momearn momwages mombiz totinc hhtot if totinc != hhtot
	list 	PUBID_1997 year time momearn momwages mombiz totinc hhtot if totinc != hhtot in 1/50

********************************************************************************
* Evaluate component variables
********************************************************************************
* wages		- R'S TOTAL INCOME FROM WAGES AND SALARY IN PAST YEAR
* mombiz	- R'S TOTAL INCOME FROM BUSINESS OR FARM IN PAST YEAR
* spwages	- SP/P'S TOTAL INCOME FROM WAGES AND SALARY IN PAST YEAR
* spbiz		- SP/P'S TOTAL INCOME FROM BUSINESS OR FARM IN PAST YEAR
* hhinc		- TOTAL COMBINED INCOME OTHER ADULT HOUSEHOLD FAMILY MEMBERS IN PAST YEAR

* momearn	- sum of wages and mombiz
* hhearn	- copy of totinc (NLSY provided R's Total Household Income by year)


*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?
*/

// Summary statistics-----------------------------------------------------------
foreach var of varlist momwages mombiz momearn totinc hhe50 hhe60{
	sum `var'
	}

// Summary stats of key vars by time
univar momwages mombiz momearn totinc hhe50 hhe60, by(time)

// Percent of each component
* Note: Some of these are over 1. Looked back at raw data, and they really are impossible proportions.
foreach var of varlist momwages mombiz momearn totinc{
	cap drop 	per_`var'
	gen 		per_`var'= round(`var'/totinc, .1)
}

univar per_momwages per_mombiz per_momearn per_totinc, by(time)

tab PUBID_1997 if per_momwages > 1 & per_momwages < .

foreach var of varlist per_momwages per_mombiz per_momearn per_totinc {
tab time `var'  if `var' <= 1, row
}

log close
