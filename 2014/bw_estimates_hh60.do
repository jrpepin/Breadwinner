*-------------------------------------------------------------------------------
* BREADWINNER PROJECT - SIPP14 Component
* bw_estimates_hh60.do
* Kelly Raley and Joanna Pepin
*-------------------------------------------------------------------------------

********************************************************************************
* DESCRIPTION
********************************************************************************
** The purpose of this analysis is to describe levels of breadwinning (bw)

* This data used in this file were once created from the do file 
* "$SIPP2014_code/bw_transitions.do"

********************************************************************************
* Open and prep the data
********************************************************************************
clear
set more off

use "$SIPP14keep/bw_transitions.dta", clear

// drop wave 1 because we only know status, not transitions into breadwinning
drop if wave==1 // shouldn't actually drop anyone because bw_transitions drops wave 1

********************************************************************************
* Describe percent breadwinning in the first birth year
********************************************************************************
* durmom == 0 is when mother had first birth in reference year

// The percent breadwinning (60% threhold) in the first year. (~25%)
	sum bw60 if durmom	==0 [aweight=wpfinwgt] // Breadwinning in the year of the birth

cap drop 	per_bw60_atbirth
gen     	per_bw60_atbirth	=100*`r(mean)'

cap drop  	notbw60_atbirth
gen     	notbw60_atbirth		=1-`r(mean)'
	
	// by education
	forvalues e=1/4 {
		sum bw60 if durmom	==0 & educ==`e' [aweight=wpfinwgt] 
		gen prop_bw60_atbirth`e'=`r(mean)'
	}

// Capture sample size
tab durmom if inlist(trans_bw60,0,1), matcell(Ns60)

********************************************************************************
* adjusting file to prepare for lifetable estimation
********************************************************************************

// need to adjust durmom. Currently the transition variables describe transition
// into breadwinning between the previous year and this one. For example:
// 
//  durmom   trans_bw
//    4         0             
//    5         0          <- this case transitions to breadwinning between year
//    6         1              5 and year 6
//
// Lifetables usually would describe the risk of transition between this year and the next.
// For example
//  durmom   trans_bw
//    4         0             
//    5         1          <- this case transitions to breadwinning between year
//    6         2              5 and year 6
//
// to make the file as expected subtract 1 from durmom

replace durmom=durmom-1

* dropping first birth year observation, but it's ok because we have saved the percent
* breadwinning at birth year above

drop if durmom < 0

*******************************************************************************
* Estimating duration-specific transition rates overall and by education
*******************************************************************************

forvalues d=1/18 {
	mean durmom trans_bw60 [aweight=wpfinwgt] if trans_bw60 !=2 & durmom==`d'
	matrix firstbw60_`d' = e(b)
	forvalues e=1/4 {
		mean durmom trans_bw60 [aweight=wpfinwgt] if trans_bw60 !=2 & durmom==`d' & educ==`e'
		matrix firstbw60`e'_`d' = e(b)
	}
}

* Now, calculate the proportions not (not!) transitioning into breadwining.
* (calculating a cumulative risk of breadwinning by age 18 by multiplying rates
* of entry at each duration of breadwinning)

// initialize cumulative measure at birth
gen     	notbw60 = notbw60_atbirth

* the proportion who do not become breadwinners is the proportion not breadwinning at birth times
* the proportion who do not become breadwinners in the first year times....who do not become breadwinners
* in year 17.

forvalues d=1/17 {
  replace notbw60=notbw60*firstbw60_`d'[1,2]
  }

* Format into nice percents & create macros -----------------------------------

// 60% bw at 1st year of birth
global per_bw60_atbirth		= round(per_bw60_atbirth, .02)

// % NEVER BY by time first child is age 18
global notbw60bydur18		= round(100*(notbw60), .02)

* Take the inverse of the proportion not breadwinning to get the proportion breadwinning.
* Multiply by 100 to get a percent.
global bw60bydur18			= round(100*(1-notbw60), .02)

di	"$per_bw60_atbirth""%"	// 60% bw at 1st year of birth
di	"$notbw60bydur18""%"	// % NEVER BW by time first child is age 18 
di	"$bw60bydur18""%"   	// % BW by time first child is age 18


********************************************************************************
* Put results in an excel file
********************************************************************************

// Initialize excel file
putexcel set "$output/Descriptives60.xlsx", sheet(transitions) modify

// Create Shell
putexcel A14 = "SIPP"
putexcel B14:G14 = "Breadwinning > 60% threshold", merge border(bottom)
putexcel D15:G15 = ("Education"), merge border(bottom)
putexcel B16 = ("Total"), border(bottom)  
putexcel D16=("< HS"), border(bottom) 
putexcel E16=("HS"), border(bottom) 
putexcel F16=("Some college"), border(bottom) 
putexcel G16=("College Grad"), border(bottom)
putexcel I16=("Unweighted N"), border(bottom)
putexcel K16=("Proportion Survived"), border(bottom) 
putexcel L16=("Cumulative Survival"), border(bottom) 

putexcel A17 = 0
forvalues d=1/17 {
	local prow=`d'+16
	local row=`d'+17
	putexcel A`row'=formula(+A`prow'+1)
}

// fill in table with values
putexcel B17 = .01*$per_bw60_atbirth, nformat(number_d2)

local columns D E F G

forvalues e=1/4 {
	local col : word `e' of `columns'
	putexcel `col'17 = prop_bw60_atbirth`e', nformat(number_d2)
}

forvalues d=1/17 {
	local row = `d'+17
	putexcel B`row' = matrix(firstbw60_`d'[1,2]), nformat(number_d2)
	forvalues e=1/4 {
		local col : word `e' of `columns'
		putexcel `col'`row' = matrix(firstbw60`e'_`d'[1,2]), nformat(number_d2)
	}
}

// sample size matrix runs from birth to age 17
forvalues d=1/18 {
        local row = `d'+16
	putexcel I`row' = matrix(Ns60[`d',1])
}

// Doing a lifetable analysis in the excel spreadsheet to make the calculation visible

forvalues d=1/18 {
	local row = `d'+16
	putexcel K`row' = formula(+1-B`row'), nformat(number_d2)
}

// lifetable cumulates the probability never breadwinning by the produc of survival rates across 
// previous durations. The inital value is simply the survival rate at duration 0 (birth)
putexcel L17 = formula(+K17), nformat(number_d2)

*now calculate survival as product of survival to previous duration times survival at this duration
forvalues d=1/17 {
	local row = `d' +17
	local prow = `d' + 16
	putexcel L`row' = formula(+L`prow'*K`row'), nformat(number_d2)
}
