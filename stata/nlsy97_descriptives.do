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

use "stata/NLSY97.dta", clear

// Keep only mothers in first 10 years of motherhood
unique 	PUBID_1997 
keep if time >=0 & time <= 10 & firstbirth ==1 // Need 10 until income vars are lagged
unique 	PUBID_1997

order PUBID_1997 year birth_year time momearn wages mombiz totinc hhearn

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

// Lag the income variables for analysis by time
sort PUBID_1997 time

foreach var of varlist 	momearn hhearn						///
						wages mombiz chsup dvdend gftinc 	///
						govpro1 govpro2 govpro3 inhinc 		///
						intrst othinc rntinc wcomp 			///
						hhinc totinc spwages spbiz wcomp_sp{
	by PUBID_1997:  replace `var' = `var'[_n+1]
}

drop if time==10

// Summary statistics-----------------------------------------------------------
foreach var of varlist wages mombiz spwages spbiz hhinc{
	sum `var'
	}

// Summary stats of key vars by time
univar wages mombiz spwages spbiz hhinc, by(time)

// Percent of each component
* Note: Some of these are over 1. Looked back at raw data, and they really are impossible proportions.
foreach var of varlist wages mombiz spwages spbiz hhinc{
	cap drop 	per_`var'
	gen 		per_`var'= round(`var'/hhearn, .1)
}

univar per_wages per_mombiz per_spwages per_spbiz per_hhinc, by(time)

foreach var of varlist per_wages per_mombiz per_spwages per_spbiz per_hhinc {
tab time `var'  if `var' <= 1, row
}

log close
