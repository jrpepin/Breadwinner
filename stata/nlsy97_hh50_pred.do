*-------------------------------------------------------------------------------
* BREADWINNER PROJECT - NLSY97 Component
* nlsy97_hh50_pred.do
* Joanna Pepin
*-------------------------------------------------------------------------------

********************************************************************************
* Setup the log file
********************************************************************************
local logdate = string( d(`c(current_date)'), "%dCY.N.D" ) 	// create a macro for the date

local list : dir . files "$logdir\*nlsy97_hh50_pred_*.log"	// Delete earlier versions of the log
foreach f of local list {
    erase "`f'"
}

log using "$logdir\nlsy97_hh50_pred_`logdate'.log", t replace

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

********************************************************************************
* Generate basic descriptives
********************************************************************************
tab time 		hhe50, row
tab time 		hhe50 [fweight=wt1997], row
tab marst 		hhe50, row
tab age_birth 	hhe50, row

table time marst, contents(mean hhe50) col	// BW by duration of motherhood & marst
table age_birth marst, contents(mean hhe50) // BW by age at first birth & marst


// Select only observations since first birth
keep if firstbirth==1 			// selected on this in R already
drop firstbirth 				// this variable has no variation now
drop age_birth age marst		// These variables get in the way for this analysis

********************************************************************************
* Reshape the data
********************************************************************************
reshape wide year hhe50, i(PUBID_1997) j(time)

// create lagged measures of breadwinning. We only need one lag for transtion
//  into breadwinning and measres of whether any breadwinning up to this point in time

* set the first lag to 0 because it is not possible to be a breadwinning mother
* before being a mother.
gen hhe50_minus1_0=0

forvalues t=1/9{
    local s=`t'-1
    gen hhe50_minus1_`t'=hhe50`s' 
}

forvalues t=2/9{
    local r=`t'-2
    gen hhe50_minus2_`t'=hhe50`r' 
}

forvalues t=3/9{
    local u=`t'-3
    gen hhe50_minus3_`t'=hhe50`u' 
}

forvalues t=4/9{
    local v=`t'-4
    gen hhe50_minus4_`t'=hhe50`v' 
}

forvalues t=5/9{
    local v=`t'-5
    gen hhe50_minus5_`t'=hhe50`v' 
}

forvalues t=6/9{
    local v=`t'-6
    gen hhe50_minus6_`t'=hhe50`v' 
}

forvalues t=7/9{
    local v=`t'-7
    gen hhe50_minus7_`t'=hhe50`v' 
}

forvalues t=8/9{
    local v=`t'-8
    gen hhe50_minus8_`t'=hhe50`v' 
}

forvalues t=9/9{
    local v=`t'-9
    gen hhe50_minus9_`t'=hhe50`v' 
}

save "stata/widebw.dta", replace

reshape long year hhe50 hhe50_minus1_ hhe50_minus2_ hhe50_minus3_ hhe50_minus4_ ///
             hhe50_minus5_ hhe50_minus6_ hhe50_minus7_ hhe50_minus8_  ///
			 hhe50_minus9_, i(PUBID_1997) j(time)

* clean up observations created because reshape creates some number of observations for each (PUBID_1997)
drop if missing(year)

// Create ever breadwinning prior to this duration variable

bysort PUBID_1997 (time) : gen everbw = sum(hhe50_minus1_) // 
replace everbw = 1 if everbw >= 1 

save "stata/bw50_analysis.dta", replace

********************************************************************************
* B1. Estimates of transitions into breadwinning (at each duration of motherhood)
********************************************************************************

preserve
	keep if hhe50_minus1_ == 0
	tab time hhe50 [fweight=wt1997], row
	tab time hhe50, row


********************************************************************************
* B2. Risk of entering breadwinning, censoring on previous breadwinning
********************************************************************************

	drop if everbw == 1 

	tab time hhe50 [fweight=wt1997], row

restore

********************************************************************************
* B3. Proportion breadwinning at each duration of motherhood that have previously breadwon
********************************************************************************

forvalues t = 1/9 {
	tab everbw hhe50 if time ==`t', col
	}

table time everbw, contents(mean hhe50) col

********************************************************************************
* Create lifetable
********************************************************************************
// Tell Stata the format of the survival data
gen momyr=time+1
keep if hhe50_minus1_==0
drop if hhe50==.

stset momyr, id(PUBID_1997) failure(hhe50==1)

tab momyr hhe50, row

* The sts list result doesn't look like our lifetable result because 
* some observations that are missing at birth appear in the data later.
* sts counts these observations in the denominator until they are observed breadwinning
sts list

sort PUBID_1997
list PUBID_1997 time year hhe50 _st _d _t _t0 in 1/20

stdescribe
stsum
stvary

* ltable works only with individual-level data (i.e. with each record representing
* an individual or aggregation of individuals. It is not designed for person-year
* data.
*ltable time hhe50
*ltable _t _d, hazard
*ltable _t _d, failure

/*
********************************************************************************
* Predict breadwinning
********************************************************************************

keep if hhe50_minus1_ ==0

logit hhe50 i.time
logit hhe50 hhe50_minus2_ i.time
logit hhe50 hhe50_minus2_ hhe50_minus3_ i.time
logit hhe50 hhe50_minus2_ hhe50_minus3_ hhe50_minus4_ i.time

log close
