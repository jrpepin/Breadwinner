*-------------------------------------------------------------------------------
* BREADWINNER PROJECT - NLSY97 Component
* nlsy97_bw_estimtaes_hh50.do
* Joanna Pepin and Kelly Raley
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
** The purpose of this analysis is to describe levels of breadwinning (bw)
** by 10 years after first birth. 

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

label var prevbreadwon "R breadwon at any prior duration"

* clean up observations created because reshape creates some number of observations for each (PUBID_1997)
drop if missing(year)

********************************************************************************
* Estimates of transitions into breadwinning (at each duration of motherhood)
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
* Risk of entering breadwinning, censoring on previous breadwinning
********************************************************************************
// Create ever breadwinning prior to this duration variable

bysort PUBID_1997 (time) : gen everbw = sum(hhe50_minus1_) // 
replace everbw = 1 if everbw >= 1
label var everbw "Ever breadwon (not censored)"

save "stata/bw50_analysis.dta", replace

tab time everbw, row // note that this does not yet censor on previous breadwinning

preserve
forvalues t = 0/9 {
	drop if prevbreadwon == 1 
	tab hhe50 if time == `t' [fweight=wt1997] // this does censor on previous bw
	}
restore

********************************************************************************
* Proportion breadwinning at each duration of motherhood that have previously breadwon
********************************************************************************
// Create a lagged ever bw variable (so current bw doesn't count)
*sort PUBID_1997 time 
*by PUBID_1997: gen ebwlag = everbw[_n-1]

forvalues t = 1/9 {
	tab everbw hhe50 if time ==`t', col
	}

table time prevbreadwon [fweight=wt1997], contents(mean hhe50) col

********************************************************************************
* Get frequency counts of transitions into breadwinning
********************************************************************************
* Limit the sample to those who were not breadwinning the previous year. 
* At time==0, no one was a breadwinning mother in the previous year 
* and hhe50_minus1_ is missing.

keep if hhe50_minus1_ == 0 | time==0

// Check n's 
tab time hhe50 

tab time everbw

cap drop countme*

gen 	countme1=1 if time==9							// Ns of moms observed at 9 years of motherhood
gen 	countme2=1 if time==9 & everbw==0				// Ns of moms never observed bw at year 9
gen 	countme3=1 if time==1 & everbw==0 & hhe50==1	// Ns of moms bw at time 1 but not at time 0 

egen 	numdur9uc	=count(countme1)
egen 	numdur9c	=count(countme2)
egen 	numbw9c 	=count(countme3)

global 	numdur9uc	=numdur9uc
global 	numdur9c	=numdur9c
global 	numbw9c 	=numbw9c

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
	global	per_bw50_atbirth=round(per_bw50_atbirth, .02)
	
// % NEVER BY by time first child reaches age 10
	global 	notbwc50 	= 	round(100*notbwc50, .02)

// % BW by time first child reaches age 10
	global 	bwc50_bydur9= round(100*(1-notbwc50), .02) // Take the inverse of the proportion not bw

di	"$per_bw50_atbirth""%"	// 50% bw at 1st year of birth
di	"$notbwc50""%"      	// % NEVER BW by time first child reaches age 10
di	"$bwc50_bydur9""%"  	// % BW by time first child reaches age 10

log close
