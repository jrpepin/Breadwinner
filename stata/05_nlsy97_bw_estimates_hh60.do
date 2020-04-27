*-------------------------------------------------------------------------------
* BREADWINNER PROJECT - NLSY97 Component
* nlsy97_bw_estimtaes_hh60.do
* Joanna Pepin and Kelly Raley
*-------------------------------------------------------------------------------

********************************************************************************
* Setup the log file
********************************************************************************
local logdate = string( d(`c(current_date)'), "%dCY.N.D" ) 	// create a macro for the date

local list : dir . files "$logdir/*nlsy97_bw_estimtaes_hh60_*.log"	// Delete earlier versions of the log
foreach f of local list {
    erase "`f'"
}

log using "$logdir/nlsy97_bw_estimtaes_hh60_`logdate'.log", t replace

di "$S_DATE"

********************************************************************************
* DESCRIPTION
********************************************************************************
** The purpose of this analysis is to describe levels of breadwinning (bw)
** by 10 years after first birth. 

* This data used in this file were once created from the do file "02_nlsy97_time_varying".

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
keep  year hhe60 PUBID_1997 time wt1997
reshape wide year hhe60, i(PUBID_1997) j(time)

// Set the first lag to 0 because it is not possible to be a breadwinning mother
// before being a mother.
gen hh60_minus1_0=0

// Create the lagged measures
forvalues t=1/9{
    local s=`t'-1
    gen hhe60_minus1_`t'=hhe60`s' 
}

forvalues t=2/9{
    local r=`t'-2
    gen hhe60_minus2_`t'=hhe60`r' 
}

forvalues t=3/9{
    local u=`t'-3
    gen hhe60_minus3_`t'=hhe60`u' 
}

forvalues t=4/9{
    local v=`t'-4
    gen hhe60_minus4_`t'=hhe60`v' 
}

forvalues t=5/9{
    local v=`t'-5
    gen hhe60_minus5_`t'=hhe60`v' 
}

forvalues t=6/9{
    local v=`t'-6
    gen hhe60_minus6_`t'=hhe60`v' 
}

forvalues t=7/9{
    local v=`t'-7
    gen hhe60_minus7_`t'=hhe60`v' 
}

forvalues t=8/9{
    local v=`t'-8
    gen hhe60_minus8_`t'=hhe60`v' 
}

forvalues t=9/9{
    local v=`t'-9
    gen hhe60_minus9_`t'=hhe60`v' 
}

// Create indicators for whether R has been observed as a 
// breadwinning mother at any previous duration of motherhood

gen prevbreadwon0=0 // can't have previously breadwon at duration 0

forvalues t=1/9 {
	gen prevbreadwon`t'=0
	local s=`t'-1
    * loop over all earlier duratons looking for any breadwinning
	forvalues u=0/`s' { 
		replace prevbreadwon`t'=1 if hhe60`u'==1
	}
}

reshape long year hhe60 hhe60_minus1_ hhe60_minus2_ hhe60_minus3_ hhe60_minus4_ ///
             hhe60_minus5_ hhe60_minus6_ hhe60_minus7_ hhe60_minus8_  ///
			 hhe60_minus9_ prevbreadwon, i(PUBID_1997) j(time)

label var prevbreadwon "R breadwon at any prior duration"

* clean up observations created because reshape creates some number of observations for each (PUBID_1997)
drop if missing(year)

********************************************************************************
* Estimates of transitions into breadwinning (at each duration of motherhood)
********************************************************************************

display "The proportion breadwinning in year of birth."
tab hhe60 if time == 0 [fweight=wt1997]
* Note that it is impossible to be a breadwinning mother prior to birth and
* anyone breadwinning in this year is considered to have transitioned into
* breadwinning.

preserve
forvalues t = 1/9 {
	drop if hhe60_minus1_ == 1
	display "Estimate of (weighted) proportion transitioning into breadwinning at duration `t' without censoring on previous breadwinning"
	tab hhe60 if time == `t' & !missing(hhe60_minus1) [fweight=wt1997]
	}
restore

********************************************************************************
* Risk of entering breadwinning, censoring on previous breadwinning
********************************************************************************
// Create ever breadwinning prior to this duration variable

bysort PUBID_1997 (time) : gen everbw = sum(hhe60_minus1_) // 
replace everbw = 1 if everbw >= 1
label var everbw "Ever breadwon (not censored)"

save "stata/bw60_analysis.dta", replace

tab time everbw, row // note that this does not yet censor on previous breadwinning

preserve
forvalues t = 0/9 {
	drop if prevbreadwon == 1 
	tab hhe60 if time == `t' [fweight=wt1997] // this does censor on previous bw
	}
restore

********************************************************************************
* Proportion breadwinning at each duration of motherhood that have previously breadwon
********************************************************************************
// Create a lagged ever bw variable (so current bw doesn't count)
*sort PUBID_1997 time 
*by PUBID_1997: gen ebwlag = everbw[_n-1]

forvalues t = 1/9 {
	tab everbw hhe60 if time ==`t', col
	}

table time prevbreadwon [fweight=wt1997], contents(mean hhe60) col

********************************************************************************
* Get frequency counts of transitions into breadwinning
********************************************************************************
* Limit the sample to those who were not breadwinning the previous year. 
* At time==0, no one was a breadwinning mother in the previous year 
* and hhe60_minus1_ is missing.

keep if hhe60_minus1_ == 0 | time==0

// Check n's 
tab time hhe60 

tab time everbw

cap drop countme*

gen 	countme1=1 if time==9							// Ns of moms observed at 9 years of motherhood
gen 	countme2=1 if time==9 & everbw==0				// Ns of moms never observed bw at year 9
gen 	countme3=1 if time==1 & everbw==0 & hhe60==1	// Ns of moms bw at time 1 but not at time 0 

egen 	numdur9uc	=count(countme1)
egen 	numdur9c	=count(countme2)
egen 	numbw9c 	=count(countme3)

local 	numdur9uc	=numdur9uc
local 	numdur9c	=numdur9c
local 	numbw9c 	=numbw9c

drop countme1 countme2 countme3 numdur9uc numdur9c numbw9c

********************************************************************************
* Produce an initial table describing transition rates at all durations 
********************************************************************************
* The first table shows the risk of becoming a bw mother, among women who were 
* not breadwinning mothers in the previous year, by year since first birth

// Table 1
tab time hhe60 [fweight=wt1997], matcell(bw60wnc) nofreq row

********************************************************************************
* % of mothers ever previously bw by # years since becoming a bw.
********************************************************************************
* At year 0 it is impossible to have been a breadwinning mother previously. 
* At duration 1 it is impossible to experience a repeat transition into breadwinning. 
* After that, the proportion who have previously breadwon grows (a lot). 

// Table 2
tab time everbw [fweight=wt1997], nofreq row

********************************************************************************
* Risk of becoming a bw mother among women who had never previously been a bw mother.
********************************************************************************
// Drop moms who have previously been a breadwinner
drop if everbw == 1

// Table 3
tab time hhe60 [fweight=wt1997], matcell(bw60wc) nofreq row // estimates saved in bw60wc

/*
INTERPRETATION: The proportion becoming a bw mother is smaller in the third table 
than in the first. This suggests that repeat bw does lead to an overestimate of 
lifetime breadwinning unless one censors on previous bw. 
*/

********************************************************************************
* Calculate the proportions not (not!) transitioning into bw.
********************************************************************************
* Table 3 presents the information we need to calculate the % of women 
* (n)ever bw 10 years after becoming a mother.

// Estimate censored on prior bw using Table 3 estimates saved in bw60wc
forvalues d=1/9 {
   gen nbbwc60_rate`d'=bw60wc[`d',1]/(bw60wc[`d',1]+bw60wc[`d',2])
}

* Calculate a cumulative risk of breadwinning by multiplying rates of entry at 
* each duration of bw.
* the proportion who do not become bw is the proportion not bw at birth times
* the proportion who do not become bw in the first year times....who do not become bw
* in year 9.

// Initialize cumulative measures
gen notbwc60 = 1

forvalues d=1/9 {
  replace notbwc60=notbwc60*nbbwc60_rate`d'
}

// Format into nice percents & create macros -----------------------------------

// 60% bw at 1st year of birth
	gen 	per_bw60_atbirth=100*(1-bw60wc[1,1]/(bw60wc[1,1]+bw60wc[1,2])) 
	global	per_bw60_atbirth=round(per_bw60_atbirth, .02)
	
// % NEVER BY by time first child reaches age 10
	global 	notbwc60 	= 	round(100*notbwc60, .02)

// % BW by time first child reaches age 10
	global 	bwc60_bydur9= round(100*(1-notbwc60), .02) // Take the inverse of the proportion not bw

di	"$per_bw60_atbirth""%"	// 60% bw at 1st year of birth
di	"$notbwc60""%"      	// % NEVER BW by time first child reaches age 10
di	"$bwc60_bydur9""%"  	// % BW by time first child reaches age 10

log close
