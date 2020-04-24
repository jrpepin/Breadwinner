*-------------------------------------------------------------------------------
* BREADWINNER PROJECT - NLSY97 Component
* nlsy97_bw_estimtaes_hh50-bydur9.do
* Joanna Pepin and Kelly Raley
*-------------------------------------------------------------------------------

********************************************************************************
* Setup the log file
********************************************************************************
local logdate = string( d(`c(current_date)'), "%dCY.N.D" ) 					// create a macro for the date

local list : dir . files "$logdir/*nlsy97_bw_estimtaes_hh50_bydur9_*.log"	// Delete earlier versions of the log
foreach f of local list {
    erase "`f'"
}

log using "$logdir/nlsy97_bw_estimtaes_hh50_bydur9_`logdate'.log", t replace

di "$S_DATE"

********************************************************************************
* DESCRIPTION
********************************************************************************
** The purpose of this analysis is to describe levels of breadwinning (bw)
** by 10 years after first birth. 

* This data used in this file were produced by nlsy97_bw_estimates_hh50.do 

********************************************************************************
* Open and prep the data
********************************************************************************
clear
set more off

use "stata/bw50_analysis.dta", clear

* Measure transitions into breadwinning ----------------------------------------
// Limit the sample to those who were not breadwinning the previous year. 
// At time==0, no one was a breadwinning mother in the previous year 
// and hhe50_minus1_ is missing.

keep if hhe50_minus1_ == 0 | time==0

// Check n's 
tab time hhe50 

********************************************************************************
* WHAT'S HAPPENING HERE? DO WE EVEN NEED THIS SECTION?
********************************************************************************
tab time everbw

cap drop countme*

gen 	countme1=1 if time==9							// Ns of moms observed at 9 years of motherhood
gen 	countme2=1 if time==9 & everbw==0				// Ns of moms never observed bw at year 9
gen 	countme3=1 if time==1 & everbw==0 & hhe50==1	// Ns of moms bw at time 1 but not at time 0 

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
tab time hhe50 [fweight=wt1997], matcell(bw50wnc) nofreq row

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
tab time hhe50 [fweight=wt1997], matcell(bw50wc) nofreq row // estimates saved in bw50wc

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

// Estimate censored on prior bw using Table 3 estimates saved in bw50wc
forvalues d=1/9 {
   gen nbbwc50_rate`d'=bw50wc[`d',1]/(bw50wc[`d',1]+bw50wc[`d',2])
}

* Calculate a cumulative risk of breadwinning by multiplying rates of entry at 
* each duration of bw.
* the proportion who do not become bw is the proportion not bw at birth times
* the proportion who do not become bw in the first year times....who do not become bw
* in year 9.

// Initialize cumulative measures
gen notbwc50 = 1

forvalues d=1/9 {
  replace notbwc50=notbwc50*nbbwc50_rate`d'
}

// Format into nice percents & create macros -----------------------------------

// 50% bw at 1st year of birth
	gen 	per_bw50_atbirth=100*(1-bw50wc[1,1]/(bw50wc[1,1]+bw50wc[1,2])) 
	local	per_bw50_atbirth=per_bw50_atbirth

// % NEVER BY by time first child reaches age 10
	local 	notbwc50 	= 	100*notbwc50

// % BW by time first child reaches age 10
	local 	bwc50_bydur9=	100*(1-notbwc50) // Take the inverse of the proportion not bw
