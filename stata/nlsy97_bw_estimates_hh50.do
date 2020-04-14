*-------------------------------------------------------------------------------
* BREADWINNER PROJECT - NLSY97 Component
* nlsy97_bw_estimtaes_hh50.do
* Joanna Pepin
*-------------------------------------------------------------------------------

********************************************************************************
* Setup the log file
********************************************************************************
local logdate = string( d(`c(current_date)'), "%dCY.N.D" ) 	// create a macro for the date

local list : dir . files "$logdir/*nlsy97_bw_estimtaes_hh50_*.log"	// Delete earlier versions of the log
foreach f of local list {
    erase "`f'"
}

log using "$logdir/nlsy97_bw_estimtaes_hh50_`logdate'.log", t replace

di "$S_DATE"

********************************************************************************
* DESCRIPTION
********************************************************************************
* This file predicts breadwinning status relative to the specific duration of motherhood

* This data used in this file were once created from the R script nlsy97_04_hhearn, 
* located in the project directory, but now are created in stata.

********************************************************************************
* Open and prep the data
********************************************************************************
clear
set more off

use 	"stata/NLSY97_bw.dta", clear
fre year // Make sure the data includes all survey years (1997 - 2017)

********************************************************************************
* Create lagged measures of breadwinning
********************************************************************************
* We only need one lag for transtion into breadwinning and measures of whether 
* any breadwinning up to this point in time
egen wt1997 = max(SAMPLING_WEIGHT_CC_1997), by(PUBID_1997) // fill in weight per person

// Reshape the data
keep  year hhe50 PUBID_1997 time wt1997
reshape wide year hhe50, i(PUBID_1997) j(time)

// Set the first lag to 0 because it is not possible to be a breadwinning mother
// before being a mother.
gen hh50_minus1_0=0

// Create the lagged measures
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

// Create indicators for whether R has been observed as a 
// breadwinning mother at any previous duration of motherhood

gen prevbreadwon0=0 // can't have previously breadwon at duration 0

forvalues t=1/9 {
	gen prevbreadwon`t'=0
	local s=`t'-1
    * loop over all earlier duratons looking for any breadwinning
	forvalues u=0/`s' { 
		replace prevbreadwon`t'=1 if hhe50`u'==1
	}
}

reshape long year hhe50 hhe50_minus1_ hhe50_minus2_ hhe50_minus3_ hhe50_minus4_ ///
             hhe50_minus5_ hhe50_minus6_ hhe50_minus7_ hhe50_minus8_  ///
			 hhe50_minus9_ prevbreadwon, i(PUBID_1997) j(time)

* clean up observations created because reshape creates some number of observations for each (PUBID_1997)
drop if missing(year)

********************************************************************************
* B1. Estimates of transitions into breadwinning (at each duration of motherhood)
********************************************************************************

display "The proportion breadwinning in year of birth."
tab hhe50 if time == 0 [fweight=wt1997]
* Note that it is impossible to be a breadwinning mother prior to birth and
* anyone breadwinning in this year is considered to have transitioned into
* breadwinning.

preserve
forvalues t = 1/9 {
	drop if hhe50_minus1_ == 1
	display "Estimate of (weighted) proportion transitioning into breadwinning at duration `t' without censoring on previous breadwinning"
	tab hhe50 if time == `t' & !missing(hhe50_minus1) [fweight=wt1997]
	}
restore

********************************************************************************
* B2. Risk of entering breadwinning, censoring on previous breadwinning
********************************************************************************
// Create ever breadwinning prior to this duration variable

bysort PUBID_1997 (time) : gen everbw = sum(hhe50_minus1_) // 
replace everbw = 1 if everbw >= 1 

save "stata/bw50_analysis.dta", replace

tab time everbw, row // note that this does not yet censor on previous breadwinning

preserve
forvalues t = 0/9 {
	drop if prevbreadwon == 1 
	tab hhe50 if time == `t' [fweight=wt1997] // this does censor on previous bw
	}
restore

********************************************************************************
* B3. Proportion breadwinning at each duration of motherhood that have previously breadwon
********************************************************************************
// Create a lagged ever bw variable (so current bw doesn't count)
*sort PUBID_1997 time 
*by PUBID_1997: gen ebwlag = everbw[_n-1]

forvalues t = 1/9 {
	tab everbw hhe50 if time ==`t', col
	}

table time prevbreadwon [fweight=wt1997], contents(mean hhe50) col

/*
********************************************************************************
* Create lifetable -- note that Kelly isn's sure that these canned packages do what we want
********************************************************************************
// Tell Stata the format of the survival data

* STS wants the time variable to start at 1
replace time=time+1 

stset time, id(PUBID_1997) failure(hhe50==1)

* why does sts think we start with 2371 observations unweighted. It's 1678.
* The problem is missing values for hhe50
sts list

sort PUBID_1997
list PUBID_1997 time year hhe50 _st _d _t _t0 in 1/20

stdescribe
stsum
stvary

ltable _t _d
ltable _t _d, hazard
ltable _t _d, failure

********************************************************************************
* Predict breadwinning
********************************************************************************
logit hhe50 hhe50_minus1_ i.time
logit hhe50 hhe50_minus1_ hhe50_minus2_ i.time
logit hhe50 hhe50_minus1_ hhe50_minus2_ hhe50_minus3_ i.time
logit hhe50 hhe50_minus1_ hhe50_minus2_ hhe50_minus3_ hhe50_minus4_ i.time
*/
log close
