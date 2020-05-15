*-------------------------------------------------------------------------------
* BREADWINNER PROJECT - NLSY97 Component
* nlsy97_bw_estimates_hh50.do
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
** by 9 years after first birth. 

* This data used in this file were once created from the do file "02_nlsy97_time_varying".

********************************************************************************
* Open and prep the data
********************************************************************************
clear
set more off

use 	"NLSY97_bw.dta", clear
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

* lagged one year
forvalues t=1/9{
    local s=`t'-1
    gen hhe50_minus1_`t'=hhe50`s' 
}

* lagged two years
forvalues t=2/9{
    local r=`t'-2
    gen hhe50_minus2_`t'=hhe50`r' 
}

*lagged three years
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

// Create ever breadwinning prior to this duration variable
bysort PUBID_1997 (time) : gen everbw = sum(hhe50_minus1_) 
replace everbw = 1 if everbw >= 1
label var everbw "Ever breadwon (not censored)"

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
* Describe transition rates at all durations 
********************************************************************************
* First, estimates for breadwinning at birth
display "The proportion breadwinning in year of birth."
mean hhe50 if time == 0 [fweight=wt1997]
matrix peratbirth50 = e(b)


* Note that it is impossible to be a breadwinning mother prior to birth and
* anyone breadwinning in this year is considered to have transitioned into
* breadwinning.

* The first table shows the risk of becoming a bw mother, among women who were 
* not breadwinning mothers in the previous year, by year since first birth

* It is impossible to be a breadwinning mother prior to birth and
* anyone breadwinning in this year is considered to have transitioned into
* breadwinning.

forvalues t = 1/9 {
	drop if hhe50_minus1_ == 1 
	display "Estimate of (weighted) proportion transitioning into breadwinning at duration `t' without censoring on previous breadwinning"
	tab hhe50 if time == `t' & !missing(hhe50_minus1_) [fweight=wt1997]
	* store table in a matrix
	matrix transbw50_`t' = e(Prop)
}

********************************************************************************
* Risk of entering breadwinning, censoring on previous breadwinning
********************************************************************************

preserve

forvalues t = 1/7 {
	drop if prevbreadwon == 1 
	display "Estimate of (weighted) proportion transitioning into breadwinning at duration `t' censoring on previous breadwinning"
	mean hhe50 if time == `t' & !missing(hhe50_minus1_) [fweight=wt1997] 
	matrix firstbw50_`t' = e(b)
}

// capture sample size
tab time if !missing(hhe50) & !missing(hhe50_minus1_), matcell(Ns50)

restore

*INTERPRETATION: The proportion becoming a bw mother is smaller in the this table 
*than in the first. This suggests that repeat bw does lead to an overestimate of 
*lifetime breadwinning unless one censors on previous bw. 

********************************************************************************
* % of mothers ever previously bw by # years since becoming a bw.
********************************************************************************
* At year 0 it is impossible to have been a breadwinning mother previously. 
* At duration 1 it is impossible to experience a repeat transition into breadwinning. 
* After that, the proportion who have previously breadwon grows (a lot). 

tab time everbw [fweight=wt1997], nofreq row

********************************************************************************
* Calculate the proportions not (not!) transitioning into bw.
********************************************************************************
* The censored analysis above has the information we need to calculate the % of women 
* (n)ever bw 8 years after becoming a mother.

* Calculate a cumulative risk of breadwinning by multiplying rates of entry at 
* each duration of bw, starting with breadwinning at birth.
* the proportion who do not become bw is the proportion not bw at birth times
* the proportion who do not become bw in the first year times....who do not become bw
* in year 8.

// Initialize cumulative measure
cap drop 	notbw50dur7
gen 		notbw50dur7 = 1

// discount the proprotion never breadwinning by using the proportion
// not breadwinning at birth.

replace notbw50dur7=notbw50dur7*(1-peratbirth50[1,1])

tab notbw50dur7

//  Take the proportion not transitioning into breadwinning at time/duration `d'
// from the matrix stored above and multiply the cumulative proportion 
// not breadwining at the previous duration by the proportion not transitioning
// into breadwinning at this duration. Go up to duration 8, when first child is 
// age 8 (child is in 9th year on the planet). 

 forvalues d=1/7 {
 replace notbw50dur7=notbw50dur7*(1-firstbw50_`d'[1,1])
}

tab notbw50dur7                            

* Format into nice percents & create macros -----------------------------------

// 50% bw at 1st year of birth
	global	per_bw50_atbirth=round(100*peratbirth50[1,1], .02)
	
// % NEVER BY by time first child is age 7 (in 8th year of life) 
	global notbw50dur7	= 	round(100*notbw50dur7, .02)

// % BW by time first child is age 7 (in 8th year of life)
	global 	bwc50_bydur7= round(100*(1-notbw50dur7), .02) // Take the inverse of the proportion not bw

di	"$per_bw50_atbirth""%"	// 50% bw at 1st year of birth
di	"$notbw50dur7""%"      	// % NEVER BW by time first child is age 7 (in 8th year of life)
di	"$bwc50_bydur7""%"  	// % BW by time first child is age 7 (in 8th year of life)

// Create macros of censored bw by duration
forvalues d=1/7  {
       global NLSY50_t`d' = firstbw50_`d'[1,1]
}

	di %9.2f $NLSY50_t5
	di %9.2f $NLSY50_t6
	di %9.2f $NLSY50_t7

********************************************************************************
* BY EDUCATION: Calculate the proportions not (not!) transitioning into bw.
********************************************************************************

// Merge and clean up the education variable
merge m:1 PUBID_1997 using "$tempdir/nlsy97_sample.dta", keepusing(educ_t1)

egen educ = max(educ_t1), by(PUBID_1997) 	// fill in education per person

label define edlbl  1 "less than hs"		///
					2 "high school"			///
					3 "some college"		///
					4 "college grad"
		
label values 	educ edlbl
label var 		educ "Education at time of 1st birth"

drop if _merge ==2	// data only in using
drop educ_t1 _merge	

********************************************************************************
* Generate estimates of breadwinning using same logic as above, separately by educ
********************************************************************************

* Estimates for breadwinning at birth
forvalues e=1/4 {
	mean hhe50 if time == 0 & educ == `e' [fweight=wt1997]
	matrix peratbirth50_`e' = e(b)
}

* estimates of transitions into breadwinning (not censored on previous breadwinning)
forvalues e=1/4 {
	forvalues t = 1/7 {
		mean hhe50 if time == `t' & !missing(hhe50_minus1_) & educ==`e' [fweight=wt1997] 
		matrix transbw50`e'_`t' = e(b)
	}
}

* estimates of transitions into breadwinning (censored on previous breadwinning)
forvalues e=1/4 {
	forvalues t = 1/7 {
		drop if prevbreadwon == 1 
		mean hhe50 if time == `t' & !missing(hhe50_minus1_) & educ==`e' [fweight=wt1997] 
		matrix firstbw50`e'_`t' = e(b)
	}
}

// Initialize cumulative measures at percent not breadwinning at birth
cap drop 	notbw50_*
gen     	notbw50_lesshs 		= (1-peratbirth50_1[1,1])
gen     	notbw50_hs      	= (1-peratbirth50_2[1,1])
gen     	notbw50_somecol 	= (1-peratbirth50_3[1,1])
gen     	notbw50_univ   		= (1-peratbirth50_4[1,1])

forvalues d=1/7 {
  replace notbw50_lesshs	=notbw50_lesshs		*(1-firstbw501_`d'[1,1])
  replace notbw50_hs   		=notbw50_hs			*(1-firstbw502_`d'[1,1])
  replace notbw50_somecol	=notbw50_somecol	*(1-firstbw503_`d'[1,1])
  replace notbw50_univ		=notbw50_univ		*(1-firstbw504_`d'[1,1])
}

// % BW by time first child is age 7 (in 8th year of life)
	global 	bwc50_bydur7_lesshs		= round(100*(1-notbw50_lesshs), 	.02)
	global 	bwc50_bydur7_hs   		= round(100*(1-notbw50_hs), 		.02)
	global 	bwc50_bydur7_somecol	= round(100*(1-notbw50_somecol), 	.02)
	global 	bwc50_bydur7_univ		= round(100*(1-notbw50_univ), 		.02)

di	"$bwc50_bydur7_lesshs""%"  		// Less than hs at time of first birth
di	"$bwc50_bydur7_hs""%"  			// High school at time of first birth
di	"$bwc50_bydur7_somecol""%"  	// Some College at time of first birth
di	"$bwc50_bydur7_univ""%"  		// College at time of first birth

********************************************************************************
* Put results in an excel file
********************************************************************************
* Initialize excel file

* BW transitions ---------------------------------------------------------------

// Initialize excel file
putexcel set "$output/Descriptives50.xlsx", sheet(transitions) replace

// Create Shell
putexcel A1:I1 = "Describe breadwinning at birth and subsequent transitions into breadwinning by duration mother, total and by education", merge border(bottom) 
putexcel A2 = "NLSY"
putexcel B2:G2 = "Breadwinning > 50% threshold", merge border(bottom)
putexcel D3:G3 = ("Education"), merge border(bottom)
putexcel B4 = ("Total"), border(bottom)  
putexcel D4=("< HS"), border(bottom) 
putexcel E4=("HS"), border(bottom) 
putexcel F4=("Some college"), border(bottom) 
putexcel G4=("College Grad"), border(bottom)
putexcel I4=("Unweighted N"), border(bottom)
putexcel K4=("Proportion Survived"), border(bottom) 
putexcel L4=("Cumulative Survival"), border(bottom) 
putexcel A5 = 0
forvalues d=1/7 {
	local prow=`d'+4
	local row=`d'+5
	putexcel A`row'=formula(+A`prow'+1)
}

// fill in table with values

putexcel B5 = .01*$per_bw50_atbirth, nformat(number_d2)

local columns D E F G

forvalues e=1/4 {
	local col : word `e' of `columns'
	putexcel `col'5 = peratbirth50_`e'[1,1], nformat(number_d2)
}

forvalues d=1/7  {
        local row=`d'+5
	putexcel B`row' = firstbw50_`d'[1,1], nformat(number_d2)
	forvalues e=1/4 {
		local col : word `e' of `columns'
		putexcel `col'`row' = firstbw50`e'_`d'[1,1], nformat(number_d2)
	}
}

// place sample size, which starts at birth rather
putexcel I5 = matrix(Ns50)

// Doing a lifetable analysis in the excel spreadsheet to make the calculation visible

forvalues d=1/8 {
	local row = `d'+4
	putexcel K`row' = formula(+1-B`row'), nformat(number_d2)
}

// lifetable cumulates the probability never breadwinning by the produc of survival rates across 
// previous durations. The inital value is simply the survival rate at duration 0 (birth)
putexcel L5 = formula(+K5), nformat(number_d2)

*now calculate survival as product of survival to previous duration times survival at this duration
forvalues d=1/7 {
	local row = `d' +5
	local prow = `d' + 4
	putexcel L`row' = formula(+L`prow'*K`row'), nformat(number_d2)
}

* Proportion BW ----------------------------------------------------------------
// Create Shell
putexcel set "$output/Descriptives50.xlsx", sheet(proportions, replace) modify

putexcel A1:F1 = "Proportion Breadwinning (50% Threshold)"  , merge border(bottom) 
putexcel A2:F2 = "(50% Threshold)"							, merge border(bottom) 
putexcel B3:F3 = "Education (%)"							, merge border(bottom) 

putexcel B4 = ("Total")      	, border(bottom)  
putexcel C4 = ("< HS")       	, border(bottom) 
putexcel D4 = ("HS")         	, border(bottom) 
putexcel E4 = ("Some college")	, border(bottom) 
putexcel F4 = ("College Grad")	, border(bottom)

putexcel A5 = ("NLSY (8 yrs)")

putexcel B5 = (100*(1-notbw50dur7))  	, nformat(number_d2) // Total
putexcel C5 = (100*(1-notbw50_lesshs)) 	, nformat(number_d2) // < HS
putexcel D5 = (100*(1-notbw50_hs))     	, nformat(number_d2) // HS
putexcel E5 = (100*(1-notbw50_somecol))	, nformat(number_d2) // Some col
putexcel F5 = (100*(1-notbw50_univ))   	, nformat(number_d2) // College

log close
