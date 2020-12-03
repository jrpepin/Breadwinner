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
drop if wave==1

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

local raceth "white black asian other hispanic"
local ed "lesshs hs somecol univ"

// by race by education

foreach re in 1 2 5 {
	local race: word `re' of `raceth'
	forvalues e=1/4 {
		sum bw60 [aweight=wpfinwgt] if durmom==0 & educ==`e' & raceth==`re'
		gen prop_bw60_atbirth`e'_`race' = `r(mean)'
	}
}

// Capture sample size
tab durmom if inlist(trans_bw60,0,1), matcell(Ns60)
forvalues e=1/4 {
	tab durmom if inlist(trans_bw60,0,1) & educ==`e', matcell(Ns60e`e')
	foreach re in 1 2 5 {
		tab durmom if inlist(trans_bw60,0,1) & educ==`e' & raceth==`re', matcell(Ns60e`e're`re')
	}
}

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
* Estimating duration-specific transition rates overall and by education and by education
*******************************************************************************

forvalues d=1/17 {
	mean durmom trans_bw60 [aweight=wpfinwgt] if trans_bw60 !=2 & durmom==`d'
	matrix firstbw60_`d' = e(b)
	forvalues e=1/4 {
		mean durmom trans_bw60 [aweight=wpfinwgt] if trans_bw60 !=2 & durmom==`d' & educ==`e'
		matrix firstbw60`e'_`d' = e(b)
	}
	foreach re in 1 2 5 {
		local race: word `re' of `raceth'
		forvalues e=1/4 {
			mean durmom trans_bw60 [aweight=wpfinwgt] if trans_bw60 !=2 & durmom==`d' & educ==`e' & raceth==`re'
			matrix firstbw60`e'_`race'_`d' = e(b) 
		}
	}
}

*******************************************************************************
* Now, calculate the proportions not (not!) transitioning into breadwining.
* (calculating a cumulative risk of breadwinning by age 18 by multiplying rates
* of entry at each duration of breadwinning)
*******************************************************************************

// initialize cumulative measures at birth. The main measure will be cumulative by age 18, but
// we also create a cumulative measure by age 8 which has the d8 in the name.

gen     	notbw60 			= notbw60_atbirth // evenutally cumulative measure at 18 initialized at birth
gen		notbw60d8 			= notbw60_atbirth // measure at 8 initialized at birth

cap drop 	notbw60_*
cap drop 	notbw60d8_*

// initializing measures for sub population by education and by education by race/ethnicity

forvalues e=1/4{
	local edname:word `e' of `ed'
	gen notbw60_`edname' = (1-prop_bw60_atbirth`e')
	gen notbw60d8_`edname' = (1-prop_bw60_atbirth`e')

	foreach re in 1 2 5{
		local race:word `re' of `raceth'
		gen notbw60_`edname'_`race' = (1-prop_bw60_atbirth`e'_`race')
		gen notbw60d8_`edname'_`race' = (1-prop_bw60_atbirth`e'_`race')
	}
}

// now estimating cumulative proportion ever breadwinning 
* the proportion who do not become breadwinners is the proportion not breadwinning at birth times
* the proportion who do not become breadwinners in the first year times....who do not become breadwinners
* in year 18.

// Total (18 years)
forvalues d=1/17 {
  gen    	notbw60_`d' = 1-firstbw60_`d'[1,2]
  replace 	notbw60	= notbw60*notbw60_`d'
}

// By Education (18 years)
// by education by race (18 years)

forvalues d=1/17 {
	
	// by education 
	forvalues e=1/4{
		local edname:word `e' of `ed'
		
		// estimate the proportion transitioning into breadwinning at this duration
		gen notbw60_`edname'_`d' = 1-firstbw60`e'_`d'[1,2]
		
		// decrement the proportion never breadwinning by the probability of transitioning into bw at this duration
		replace notbw60_`edname' = notbw60_`edname'*notbw60_`edname'_`d'
	
		// by race/ethnicity
	
		foreach re in 1 2 5{
		
			local race : word `re' of `raceth'
		
			// estimate the proportion transitioning into breadwinning at this duration
			gen notbw60_`edname'_`race'_`d' = 1-firstbw60`e'_`race'_`d'[1,2]
						
			// decrement the proportion never breadwinning by the probability of transitioning into bw at this duration
			replace notbw60_`edname'_`race' = notbw60_`edname'_`race'*notbw60_`edname'_`race'_`d'
		display "The proportion not breadwinning and cumulative proportion not breadwinning for `race' with `edname'"
		tab notbw60_`edname'_`race'_`d'
		tab notbw60_`edname'_`race'
		}
	}

}

// Total (8 years)
forvalues d=1/7 {
  gen 		notbw60d8_`d'	=1-firstbw60_`d'[1,2]
  replace 	notbw60d8=notbw60d8*notbw60d8_`d'
}

// By Education (8 years)
// By education by race/ethnicity (8 years)

forvalues d=1/7 {
	
	// by education 
	forvalues e=1/4{
		local edname:word `e' of `ed'

		// be sure nothing hanging around from previous runs
		cap drop	notd8bw60_`edname'_*
		
		// estimate the proportion transitioning into breadwinning at this duration
		gen notbw60d8_`edname'_`d' = 1-firstbw60`e'_`d'[1,2]
		
		// decrement the proportion never breadwinning by the probability of transitioning into bw at this duration
		replace notbw60d8_`edname' = notbw60d8_`edname'*notbw60d8_`edname'_`d'
	
		// by race/ethnicity
	
		foreach re in 1 2 5{
		
			local race : word `re' of `raceth'
		
			// estimate the proportion transitioning into breadwinning at this duration
			gen notbw60d8_`edname'_`race'_`d' = 1-firstbw60`e'_`race'_`d'[1,2]
						
			// decrement the proportion never breadwinning by the probability of transitioning into bw at this duration
			replace notbw60d8_`edname'_`race' = notbw60d8_`edname'+`race'*notbw60d8_`edname'_`race'_`d'
		}
	}

}

*******************************************************************************
* Format into nice percents & create macros ------------------------------------
*******************************************************************************
*  NOTE: This analysis is without any adjustment for repeat breadwinning, which
*  is handled in the next file (11_)
**


// 60% BW at 1st year of birth
global per_bw60_atbirth				= round(per_bw60_atbirth		, .02)

// % NEVER BW by time first child is age 18
global notbw60bydur18			= round(100*(notbw60), .02)
global notbw60bydur18_lesshs		= round(100*(notbw60_lesshs), .02)
global notbw60bydur18_hs		= round(100*(notbw60_hs), .02)
global notbw60bydur18_somecol		= round(100*(notbw60_somecol), .02)
global notbw60bydur18_univ	    	= round(100*(notbw60_univ), .02)

// % BW by time first child is age 18
* Take the inverse of the proportion not breadwinning to get the proportion breadwinning.
* Multiply by 100 to get a percent.
global bw60bydur18			= round(100*(1-notbw60)	        , .02)
global bw60bydur18_lesshs		= round(100*(1-notbw60_lesshs)	, .02)
global bw60bydur18_hs	     		= round(100*(1-notbw60_hs)	, .02)
global bw60bydur18_somecol		= round(100*(1-notbw60_somecol)	, .02)
global bw60bydur18_univ		    	= round(100*(1-notbw60_univ)	, .02)

global bw60bydur18_lesshs_white		= round(100*(1-notbw60_lesshs_white)	, .02)
global bw60bydur18_hs_white	     	= round(100*(1-notbw60_hs_white)	, .02)
global bw60bydur18_somecol_white	= round(100*(1-notbw60_somecol_white)	, .02)
global bw60bydur18_univ_white		= round(100*(1-notbw60_univ_white)	, .02)

global bw60bydur18_lesshs_black		= round(100*(1-notbw60_lesshs_black)	, .02)
global bw60bydur18_hs_black     	= round(100*(1-notbw60_hs_black)	, .02)
global bw60bydur18_somecol_black	= round(100*(1-notbw60_somecol_black)	, .02)
global bw60bydur18_univ_black		= round(100*(1-notbw60_univ_black)	, .02)

global bw60bydur18_lesshs_hispanic	= round(100*(1-notbw60_lesshs_hispanic)	, .02)
global bw60bydur18_hs_hispanic	     	= round(100*(1-notbw60_hs_hispanic)	, .02)
global bw60bydur18_somecol_hispanic	= round(100*(1-notbw60_somecol_hispanic) , .02)
global bw60bydur18_univ_hispanic	= round(100*(1-notbw60_univ_hispanic)	, .02)


// % NEVER BW by time first child is age 8
global notbw60d8			= round(100*(notbw60d8)	, .02)
global notbw60bydur8_lesshs		= round(100*(notbw60_lesshs), .02)
global notbw60bydur8_hs		    	= round(100*(notbw60_hs), .02)
global notbw60bydur8_somecol		= round(100*(notbw60_somecol), .02)
global notbw60bydur8_univ	    	= round(100*(notbw60_univ), .02)

// % BW by time first child is age 8
* Take the inverse of the proportion not breadwinning to get the proportion breadwinning.
* Multiply by 100 to get a percent.
global notbw60d8			= round(100*(1-notbw60d8), .02)
global bw60bydurd8_lesshs		= round(100*(1-notbw60d8_lesshs), .02)
global bw60bydurd8_hs	     		= round(100*(1-notbw60d8_hs), .02)
global bw60bydurd8_somecol		= round(100*(1-notbw60d8_somecol), .02)
global bw60bydurd8_univ		    	= round(100*(1-notbw60d8_univ), .02)

// Totals (age 18)
	di	"$per_bw60_atbirth""%"		// 60% bw at 1st year of birth
	di	"$notbw60bydur18""%"		// % NEVER BW by time first child is age 18
	di	"$bw60bydur18""%"   		// % BW by time first child is age 18

// By education (age 18)
	di	"$bw60bydur18_lesshs""%"   	// % BW by time first child is age 18
	di	"$bw60bydur18_hs""%"   		// % BW by time first child is age 18
	di	"$bw60bydur18_somecol""%"   // % BW by time first child is age 18
	di	"$bw60bydur18_univ""%"   	// % BW by time first child is age 18
	
// by education by race/ethnicity (age 18)

	di	"$bw60bydur18_lesshs_white""%"   	// % BW by time first child is age 18
	di	"$bw60bydur18_hs_white""%"   		// % BW by time first child is age 18
	di	"$bw60bydur18_somecol_white""%"   // % BW by time first child is age 18
	di	"$bw60bydur18_univ_white""%"   	// % BW by time first child is age 18
	
	di	"$bw60bydur18_lesshs_black""%"   	// % BW by time first child is age 18
	di	"$bw60bydur18_hs_black""%"   		// % BW by time first child is age 18
	di	"$bw60bydur18_somecol_black""%"   // % BW by time first child is age 18
	di	"$bw60bydur18_univ_black""%"   	// % BW by time first child is age 18

	di	"$bw60bydur18_lesshs_hispanic""%"   	// % BW by time first child is age 18
	di	"$bw60bydur18_hs_hispanic""%"   		// % BW by time first child is age 18
	di	"$bw60bydur18_somecol_hispanic""%"   // % BW by time first child is age 18
	di	"$bw60bydur18_univ_hispanic""%"   	// % BW by time first child is age 18
	
// Totals & by education (age 8)
	di	"$bw60bydurd8""%"   		// % BW by time first child is age 8
	di	"$bw60bydurd8_lesshs""%"   	// % BW by time first child is age 8
	di	"$bw60bydurd8_hs""%"   		// % BW by time first child is age 8
	di	"$bw60bydurd8_somecol""%"   // % BW by time first child is age 8
	di	"$bw60bydurd8_univ""%"   	// % BW by time first child is age 8

// Create macros of censored bw by duration
forvalues d=1/17 {
	global SIPP60_t`d' = firstbw60_`d'[1,2]
}

	di %9.2f $SIPP60_t5
	di %9.2f $SIPP60_t6
	di %9.2f $SIPP60_t7
	
********************************************************************************
* Put results in an excel file
********************************************************************************

// Initialize excel file
putexcel set "$output/Descriptives60.xlsx", sheet(transitions) modify
putexcel A1 = "These are the estimates of primary earning not adjusted for repeat breadwinning. See the proportions sheet for adjusted estimates"
// Create Shell
putexcel A14 = "SIPP"
putexcel B14:G14 = "Breadwinning > 60% threshold unadjusted for repeat breadwinning", merge border(bottom)

foreach row in 15 36 57 {
	local nrow = `row'+1 
	putexcel D`row':G`row' = ("Education"), merge border(bottom)
	putexcel H`row':S`row' = ("Education by race"), merge border(bottom)
	putexcel B`nrow' = ("Total"), border(bottom)  
	putexcel D`nrow'=("< HS"), border(bottom) 
	putexcel E`nrow'=("HS"), border(bottom) 
	putexcel F`nrow'=("Some college"), border(bottom) 
	putexcel G`nrow'=("College Grad"), border(bottom)
	putexcel H`nrow'=("White < HS"), border(bottom) 
	putexcel I`nrow'=("White HS"), border(bottom) 
	putexcel J`nrow'=("White Some college"), border(bottom) 
	putexcel K`nrow'=("White College Grad"), border(bottom)
	putexcel L`nrow'=("Black < HS"), border(bottom) 
	putexcel M`nrow'=("Black HS"), border(bottom) 
	putexcel N`nrow'=("Black Some college"), border(bottom) 
	putexcel O`nrow'=("Black College Grad"), border(bottom)
	putexcel P`nrow'=("Hispanic < HS"), border(bottom) 
	putexcel Q`nrow'=("Hispanic HS"), border(bottom) 
	putexcel R`nrow'=("Hispanic Some college"), border(bottom) 
	putexcel S`nrow'=("Hispanic College Grad"), border(bottom)
	putexcel U`nrow'=("Unweighted N"), border(bottom)
}

putexcel A37 = "Proportion not primary earning"
putexcel A58 = "Cumulative proportion never primary earning"

local columns "D E F G "

local white_cols "H I J K" 
local black_cols "L M N O "
local hispanic_cols "P Q R S" 

putexcel A17 = 0
forvalues d=1/17 {
	local prow=`d'+16
	local row=`d'+17
	putexcel A`row'=formula(+A`prow'+1)
}

// fill in table with values 
// start with proportion breadwinning at birth
putexcel B17 = .01*$per_bw60_atbirth, nformat(number_d2)

// by education
forvalues e=1/4 {
	local col : word `e' of `columns'
	putexcel `col'17 = prop_bw60_atbirth`e', nformat(number_d2)	 
}

// by race/ethnicity by education
foreach re in 1 2 5{
	local racename: word `re' of `raceth'
	forvalues e=1/4{
		local col : word `e' of ``racename'_cols'
		putexcel `col'17 = prop_bw60_atbirth`e'_`racename', nformat(number_d2)
	}
}

// fill in rest of table with duration-specific transition rates into breadwinning at each duration in motherhood
// total
forvalues d=1/17 {
	local row = `d'+17
	putexcel B`row' = matrix(firstbw60_`d'[1,2]), nformat(number_d2)
	
// by education
	forvalues e=1/4 {
		local col : word `e' of `columns'
		putexcel `col'`row' = matrix(firstbw60`e'_`d'[1,2]), nformat(number_d2)
	}
// by race/ethnicity by education
	foreach re in 1 2 5{
		local racename: word `re' of `raceth'
		forvalues e=1/4{
			local col : word `e' of ``racename'_cols'
			putexcel `col'`row' = matrix(firstbw60`e'_`racename'_`d'[1,2]), nformat(number_d2)
		}
	}

}

putexcel A79 = "unweighted sample sizes"


// sample size matrix runs from birth to age 17
forvalues d=1/18 {
        local row = `d'+79
	putexcel A`row' = `d'
	putexcel B`row' = matrix(Ns60[`d',1])
	putexcel D`row' = matrix(Ns60e1[`d',1])
	putexcel E`row' = matrix(Ns60e2[`d',1])
	putexcel F`row' = matrix(Ns60e3[`d',1])
	putexcel G`row' = matrix(Ns60e4[`d',1])
	putexcel H`row' = matrix(Ns60e1re1[`d',1])
	putexcel I`row' = matrix(Ns60e2re1[`d',1])
	putexcel J`row' = matrix(Ns60e3re1[`d',1])
	putexcel K`row' = matrix(Ns60e4re1[`d',1])
	putexcel L`row' = matrix(Ns60e1re2[`d',1])
	putexcel M`row' = matrix(Ns60e2re2[`d',1])
	putexcel N`row' = matrix(Ns60e3re2[`d',1])
	putexcel O`row' = matrix(Ns60e4re2[`d',1])
	putexcel P`row' = matrix(Ns60e1re5[`d',1])
	putexcel Q`row' = matrix(Ns60e2re5[`d',1])
	putexcel R`row' = matrix(Ns60e3re5[`d',1])
	putexcel S`row' = matrix(Ns60e4re5[`d',1])
	
}

// Doing a lifetable analysis in the excel spreadsheet to make the calculation visible

* calculate the proportion NOT transitioning into primary earning at this duration
foreach col in B D E F G H I J K L M N  P Q R S {
	forvalues d=1/18 {
		local row = `d'+37
		local source_row = `d'+16
		putexcel `col'`row' = formula(+1-`col'`source_row'), nformat(number_d2)
	}
}

* calculate the cumulative proportion never primary earning by 18th year of motherhood
* lifetable cumulates the probability never breadwinning by the produc of survival rates across 
* previous durations. The inital value is simply the survival rate at duration 0 (birth)

foreach col in B D E F G H I J K L M N  P Q R S {
	putexcel `col'59 = formula(+`col'38) // start with initial levels of primary earning
	forvalues d=2/18 {
		local row = `d'+58
		local prev_row = `row'-1
		local source_row = `d'+37
		putexcel `col'`row' = formula(+`col'`source_row'*`col'`prev_row'), nformat(number_d2)
	}
}

* Descriptiive table: Proportion BW ----------------------------------------------------------------

// Create Shell
putexcel set "$output/Descriptives60.xlsx", sheet(proportions) modify
putexcel A3:Q3 = "Estimated percentage primary earner by 8 and 18 years, unadjusted and adjusted for repeat breadwinning", merge border(bottom)
putexcel C4:F4 = "By Education", merge border(bottom)
putexcel B5 = ("Total") C5= ("< HS") D5 = ("HS") E5 = ("Some College") F5 = ("College Grad+")
putexcel G4:J4 = "White by education", merge border(bottom)
putexcel G5= ("< HS") H5 = ("HS") I5 = ("Some College") J5 = ("College Grad+")
putexcel K4:N4 = "Black by education", merge border(bottom)
putexcel K5= ("< HS") L5 = ("HS") M5 = ("Some College") N5 = ("College Grad+")
putexcel O4:R4 = "Hispanic by education", merge border(bottom)
putexcel O5= ("< HS") P5 = ("HS") Q5 = ("Some College") R5 = ("College Grad+")
putexcel A6 = ("SIPP (8 yrs)")
putexcel A7 = ("SIPP (18 yrs)")
* Note that the adjusted estimates come from the next file (11_sipp14_reeatBW_hh60.do

// BW by age 8
putexcel B6 = (100*(1-notbw60d8))  			, nformat(number_d2) // Total
putexcel C6 = (100*(1-notbw60d8_lesshs)) 	, nformat(number_d2) // < HS
putexcel D6 = (100*(1-notbw60d8_hs))     	, nformat(number_d2) // HS
putexcel E6 = (100*(1-notbw60d8_somecol))	, nformat(number_d2) // Some col
putexcel F6 = (100*(1-notbw60d8_univ))   	, nformat(number_d2) // College

// BW by age 18
putexcel B7 = (100*(1-notbw60))  			, nformat(number_d2) // Total
putexcel C7 = (100*(1-notbw60_lesshs))  	, nformat(number_d2) // < HS
putexcel D7 = (100*(1-notbw60_hs))  		, nformat(number_d2) // HS
putexcel E7 = (100*(1-notbw60_somecol))  	, nformat(number_d2) // Some col
putexcel F7 = (100*(1-notbw60_univ))  		, nformat(number_d2) // College


local columns "G H I J K L M N O P Q R"

local c = 1

foreach re in 1 2 5{
	local race : word `re' of `raceth'
	forvalues e=1/4 {
		local col : word `c' of `columns'
		local educ : word `e' of `ed'
		putexcel `col'7 = (100*(1-notbw60_`educ'_`race')), nformat(number_d2)
		local c = `c' + 1
	}
	
}

* Description of personal and household earnings and their ratio
putexcel set "$output/Descriptives60.xlsx", sheet(earningsdetail) modify

gen trim_tpearn=tpearn
replace trim_tpearn=-1 if tpearn < 0
replace trim_tpearn=200000 if tpearn > 200000

gen trim_thearn=thearn
replace trim_thearn=-1 if thearn < 0
replace trim_thearn=200000 if thearn > 200000

gen trim_er=earnings_ratio if hh_noearnings==0
replace trim_er=0 if tpearn < 0 & hh_noearnings==0
replace trim_er=1 if thearn < 0 & hh_noearnings==0
replace trim_er=1 if earnings_ratio > 1 & tpearn > 0

gen catratio=0 if hh_noearnings==1
replace catratio=1 if trim_er==0
replace catratio=2 if trim_er > 0 & trim_er < .5
replace catratio=3 if trim_er >=.5 & trim_er <.6
replace catratio=4 if trim_er >= .6 & trim_er < 1
replace catratio=5 if trim_er==1

tab catratio [aweight=wpfinwgt], matcell(catratio)

putexcel A1 = "Details of earnings measures"
putexcel B2 = ("N") C2 = ("%")
putexcel B3 = matrix(catratio)
putexcel A3 = "No household earnings"
putexcel A4 = "Mother no earnings"
putexcel A5 = "Mother earns less than half of household income"
putexcel A6 = "Mother earns more than half, less than .6 of household income"
putexcel A7 = "Mother earnings more than .6 but less than all of household income"
putexcel A8 = "Mother earns all of household income"
putexcel A12 = "Plot of earnings ratio (trimmed)"
putexcel H12 = "Plot of maternal earnings (trimmed)"
putexcel R12 = "Plot of household earnings (trimmed)"

putexcel A9 = "Total"
putexcel B9 = formula(sum(B3:B8))

forvalues r=3/8 {
	putexcel C`r' = formula(100*B`r'/B9), nformat(##.#)
}

cdfplot(trim_er) [aweight=wpfinwgt], name(earningsratio, replace) 
graph export earningsratio.png, name(earningsratio) replace
putexcel A13 = picture(earningsratio.png)

/*
cdfplot(trim_thearn) [aweight=wpfinwgt], name(thearn, replace)
graph export thearn.png, name(thearn.png) replace
putexcel R13 = picture(thearn.png)

cdfplot(trim_tpearn) [aweight=wpfinwgt], name(tpearn, replace) 
graph export tpearn.png, name(tpearn.png) replace
putexcel H13 = picture(tpearn.png)


