*-------------------------------------------------------------------------------
* BREADWINNER PROJECT - NLSY97 Component
* nlsy97_hh60_pred.do
* Joanna Pepin
*-------------------------------------------------------------------------------

********************************************************************************
* Setup the log file
********************************************************************************
local logdate = string( d(`c(current_date)'), "%dCY.N.D" ) 	// create a macro for the date

local list : dir . files "$logdir\*nlsy97_hh60_pred_*.log"	// Delete earlier versions of the log
foreach f of local list {
    erase "`f'"
}

log using "$logdir\nlsy97_hh60_pred_`logdate'.log", t replace

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

use 	"stata\nlsy97_hh60.dta", clear
fre year // Make sure the data includes all survey years (1997 - 2017)

// Select only observations since first birth
keep if firstbirth==1 			// selected on this in R already
drop firstbirth 				// this variable has no variation now
drop age_birth age marst		// These variables get in the way for this analysis

********************************************************************************
* Reshape the data
********************************************************************************
reshape wide year hhe60, i(PUBID_1997) j(time)

forvalues t=1/8{
    local s=`t'-1
    gen hhe60_minus1_`t'=hhe60`s' 
}

forvalues t=2/8{
    local r=`t'-2
    gen hhe60_minus2_`t'=hhe60`r' 
}

forvalues t=3/8{
    local u=`t'-3
    gen hhe60_minus3_`t'=hhe60`u' 
}

forvalues t=4/8{
    local v=`t'-4
    gen hhe60_minus4_`t'=hhe60`v' 
}

reshape long year hhe60 hhe60_minus1_ hhe60_minus2_ hhe60_minus3_ hhe60_minus4_, i(PUBID_1997) j(time)

* clean up observations created because reshape creates some number of observations for each (PUBID_1997)
drop if missing(year)

********************************************************************************
* Estimate breadwinning
********************************************************************************
logit hhe60 hhe60_minus1 i.time
logit hhe60 hhe60_minus1 hhe60_minus2 i.time
logit hhe60 hhe60_minus1 hhe60_minus2 hhe60_minus3 i.time
logit hhe60 hhe60_minus1 hhe60_minus2 hhe60_minus3 hhe60_minus4 i.time

log close
