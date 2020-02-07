*-------------------------------------------------------------------------------
* BREADWINNER PROJECT - NLSY97 Component
* nlsy97_hh50_dur.do
* Joanna Pepin
*-------------------------------------------------------------------------------
********************************************************************************
* Setup the log file
********************************************************************************
local logdate = string( d(`c(current_date)'), "%dCY.N.D" ) 	// create a macro for the date

local list : dir . files "$logdir\*nlsy97_hh50_*.log"		// Delete earlier versions of the log
foreach f of local list {
    erase "`f'"
}

log using "$logdir\nlsy97_hh50_dur_`logdate'.log", t replace

di "$S_DATE"

********************************************************************************
* DESCRIPTION
********************************************************************************
* This file predictes breadwinning status relative to the specific duration of motherhood

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
