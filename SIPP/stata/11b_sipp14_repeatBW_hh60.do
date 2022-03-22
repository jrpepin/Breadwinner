*-------------------------------------------------------------------------------
* BREADWINNER PROJECT - SIPP14 Component
* sipp14_repeatBW_hh60.do
* Kelly Raley and Joanna Pepin
*-------------------------------------------------------------------------------

********************************************************************************
* DESCRIPTION
********************************************************************************
* The purpose of this analysis is to account for repeat bw unobserved in the SIPP
* using the observed bw estimates generated from the NLSY

* This file will only work after breadwinnerNLSY97 AND breadwinnerSIPP14 files
* have been run in the same Stata session.

********************************************************************************
* Calculate the alternative "Repeat BW discount"
********************************************************************************

//Calculate the ratio of the NLSY to the SIPP for duration 4-5, when SIPP starts to diverge
	global disco60 = $NLSY60_t5/$SIPP60_t5
	di %9.2f $disco60

// Calculate the trajectory of change in the ratio
	global interval1 = 1-(($NLSY60_t6/$SIPP60_t6)/($NLSY60_t5/$SIPP60_t5))
	global interval2 = 1-(($NLSY60_t7/$SIPP60_t7)/($NLSY60_t6/$SIPP60_t6)) 
	
	local chd60 = ($interval1+$interval2)/2
	di %9.2f `chd60'

local raceth "white black asian other hispanic"
local ed "lesshs hs somecol univ"
local nmbst "marital nonmar"

********************************************************************************
* Apply the "Alternative Repeat BW discount" for years 5 - 17
********************************************************************************

* initialize new cumulative measure at birth -----------------------------------
cap drop		notbw60adjb_*
gen 		notbw60adjb_0 		= 1 - (.01*$per_bw60_atbirth)
gen     	notbw60adjb_lesshs 	= (1-prop_bw60_atbirth1)
gen     	notbw60adjb_hs      	= (1-prop_bw60_atbirth2)
gen     	notbw60adjb_somecol 	= (1-prop_bw60_atbirth3)
gen     	notbw60adjb_univ   	= (1-prop_bw60_atbirth4)
gen     	notbw60adjb_marital   	= (1-prop_bw60_atbirth_nmb0)
gen     	notbw60adjb_nonmar   	= (1-prop_bw60_atbirth_nmb1)

gen     	notbw60adjb_white 		= (1-prop_bw60_atbirth_r1)
gen     	notbw60adjb_black      	= (1-prop_bw60_atbirth_r2)
gen     	notbw60adjb_asian 		= (1-prop_bw60_atbirth_r3)
gen     	notbw60adjb_other   	= (1-prop_bw60_atbirth_r4)
gen     	notbw60adjb_hispanic   	= (1-prop_bw60_atbirth_r5)

foreach re in 1 2 5{
	local race : word `re' of `raceth'
	gen     	notbw60adjb_lesshs_`race' 	= (1-prop_bw60_atbirth1_`race')
	gen     	notbw60adjb_hs_`race'      	= (1-prop_bw60_atbirth2_`race')
	gen     	notbw60adjb_somecol_`race' 	= (1-prop_bw60_atbirth3_`race')
	gen     	notbw60adjb_univ_`race'   	= (1-prop_bw60_atbirth4_`race')
}

* the proportion who do not become bw ------------------------------------------

// These stay the same
forvalues d=1/4 {
 
    gen notbw60adjb_`d' 	= 1 - firstbw60_`d'[1,2]   
	
	// by education
	forvalues e=1/4{
		local educ : word `e' of `ed'
		gen notbw60adjb_`educ'_`d' 	= 1 - firstbw60`e'_`d'[1,2]
	// by education by race
		foreach re in 1 2 5{
			local race: word `re' of `raceth'
			gen notbw60adjb_`educ'_`race'_`d' = 1-firstbw60`e'_`race'_`d'[1,2]
		}
	}
	
	// by race
	forvalues r=1/5{
		local race : word `r' of `raceth'
		gen notbw60adjb_`race'_`d' 	= 1 - firstbw60_r`r'_`d'[1,2]
	}
	
	// by marital status at first birth
		forvalues fb=0/1 {
			local nextword = `fb' + 1
			local nmb: word `nextword' of `nmbst'
			gen notbw60adjb_`nmb'_`d' = 1 - firstbw60_nmb`fb'_`d'[1,2]
		}
}
	

	
// Apply the repeat bw discount

local disco60_4 = $disco60/(1-`chd60') // projecting discount backwards to have a t-1 estimate

display `disco60_4'

forvalues d=5/17 {
	local c = `d' - 1
	local reduce = `disco60_`c'' * `chd60'
	local disco60_`d' = `disco60_`c'' - `reduce' // the discount now increases by an additional 15% each duration
	display "discount equals `disco60_`d'' at duration `d'" 

	gen notbw60adjb_`d' 		= 1 - firstbw60_`d'[1,2] 	* (`disco60_`d'')
	
	// by education
	forvalues e=1/4{
		local educ : word `e' of `ed'
		gen notbw60adjb_`educ'_`d' 	= 1 - firstbw60`e'_`d'[1,2] * (`disco60_`d'')
	// by education by race
		foreach re in 1 2 5{
			local race: word `re' of `raceth'
			gen notbw60adjb_`educ'_`race'_`d' = 1-firstbw60`e'_`race'_`d'[1,2] * (`disco60_`d'')
		}
	}	
	// by race
	forvalues r=1/5{
		local race : word `r' of `raceth'
		gen notbw60adjb_`race'_`d' 	= 1 - firstbw60_r`r'_`d'[1,2] * (`disco60_`d'')
	}
	// by marital status at first birth
		forvalues fb=0/1 {
			local nextword = `fb' + 1
			local nmb: word `nextword' of `nmbst'
			gen notbw60adjb_`nmb'_`d' = 1 - firstbw60_nmb`fb'_`d'[1,2]*(`disco60_`d'')
		}
}

* Create the total macros (adjusted bw) _---------------------------------------
global adjb_60_0 = .01*$per_bw60_atbirth

forvalues d=1/4 {
	global adj60b_`d' = firstbw60_`d'[1,2]
}
forvalues d=5/17 {
	global adj60b_`d' = firstbw60_`d'[1,2] * (`disco60_`d'')
}
	
* Calculate adjusted survival rates --------------------------------------------

cap drop sur_*
	gen  sur_0        	= 	notbw60adjb_0
	
	// by education
	forvalues e=1/4{
		local educ : word `e' of `ed'
		gen  sur_`educ'_0  	=  	notbw60adjb_`educ'
	// by education by race	
		foreach re in 1 2 5{
			local race : word `re' of `raceth'
			gen  sur_`educ'_`race'_0  	=  	notbw60adjb_`educ'_`race'
		}
	}
	
	// by race
	forvalues r=1/5{
		local race : word `r' of `raceth'
		gen  sur_`race'_0  	=  	notbw60adjb_`race'
	}
		
	// by marital status at first birth
		forvalues fb=0/1 {
			local nextword = `fb' + 1
			local nmb: word `nextword' of `nmbst'
			gen sur_`nmb'_0 = notbw60adjb_`nmb'
		}

forvalues d=1/17 {
	local lag = `d'-1
	gen sur_`d' 	  	= (sur_`lag')       	* (notbw60adjb_`d')
	
	// by education
	forvalues e=1/4{
		local educ : word `e' of `ed'
		gen sur_`educ'_`d' 	= (sur_`educ'_`lag') 	* (notbw60adjb_`educ'_`d')
		foreach re in 1 2 5{
			local race : word `re' of `raceth'
			gen sur_`educ'_`race'_`d' 	= (sur_`educ'_`race'_`lag') 	* (notbw60adjb_`educ'_`race'_`d')
		}
	}
	
	// by race
	forvalues r=1/5{
		local race : word `r' of `raceth'
		gen sur_`race'_`d' 	= (sur_`race'_`lag') 	* (notbw60adjb_`race'_`d')
	}
	
	// by marital status at first birth
		forvalues fb=0/1 {
			local nextword = `fb' + 1
			local nmb: word `nextword' of `nmbst'
			gen sur_`nmb'_`d' = (sur_`nmb'_`lag') *  (notbw60adjb_`nmb'_`d')
		}
}

********************************************************************************
* Put results in an excel file
********************************************************************************

// Create Shell
putexcel set "$output/Descriptives60.xlsx", sheet(proportions) modify
* Note that parts of this tables are written in the previous file (10_sipp14_bw_estimates_hh60.do)
putexcel A9 = ("SIPP Adjusted alternate (18 yrs)")

// ADJUSTED BW by age 18
putexcel B9 = (100*(1-sur_17))  		, nformat(number_d2) // Total
putexcel C9 = (100*(1-sur_lesshs_17))  		, nformat(number_d2) // < HS
putexcel D9 = (100*(1-sur_hs_17))  		, nformat(number_d2) // HS
putexcel E9 = (100*(1-sur_somecol_17))  	, nformat(number_d2) // Some col
putexcel F9 = (100*(1-sur_univ_17))  		, nformat(number_d2) // College
putexcel U9 = (100*(1-sur_white_17))  		, nformat(number_d2) // White
putexcel V9 = (100*(1-sur_black_17))  		, nformat(number_d2) // Black
putexcel W9 = (100*(1-sur_asian_17))  		, nformat(number_d2) // Asian
putexcel X9 = (100*(1-sur_other_17))  		, nformat(number_d2) // Other
putexcel Y9 = (100*(1-sur_hispanic_17))  	, nformat(number_d2) // Hispanic

local columns "G H I J K L M N O P Q R"

local c = 1

foreach re in 1 2 5{
	local race : word `re' of `raceth'
	forvalues e=1/4{
		local col : word `c' of `columns'
		local educ : word `e' of `ed'
		putexcel `col'9 = (100*(1-sur_`educ'_`race'_17)), nformat(number_d2)
		local c = `c' + 1
	}
}

local columns "S T"

forvalues fb = 0/1 {
	local nextword = `fb' + 1
	local nmb: word `nextword' of `nmbst'
	local col: word `nextword' of `columns'
	putexcel `col'9 = (100*(1-sur_`nmb'_17)), nformat(number_d2)
}

	
			
