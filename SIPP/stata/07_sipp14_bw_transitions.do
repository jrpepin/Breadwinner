*-------------------------------------------------------------------------------
* BREADWINNER PROJECT
* bw_transitions.do
* Kelly Raley and Joanna Pepin
*-------------------------------------------------------------------------------
di "$S_DATE"

********************************************************************************
* DESCRIPTION
********************************************************************************
* Creates measures of transitions into breadwinning status

* The data file used in this script was produced by annualize.do
* It is restricted to mothers living with minor children.

********************************************************************************
* Reshape data to make the file wide
********************************************************************************
use "$SIPP14keep/bwstatus.dta", clear

// Look at how many respondents first appeared in each wave
tab first_wave wave 

// Look at percent breadwinning (50%) by wave and years of motherhood
table durmom wave, contents(mean bw50) format(%3.2g)

* List of variables that should be constants:
	* notbw50_atbirth first_wave

// List of variables that change over time
local change_variables 	year monthsobserved nmos_bw50 nmos_bw60 tpearn thearn earnings_ratio spouse partner	///
						wpfinwgt minorchildren minorbiochildren tceb oldest_age start_spartner 	///
						last_spartner durmom youngest_age anytype2 hh_noearnings bw50 bw60 		///
						gain_partner lost_partner partial_year raceth educ tage ageb1
						
// Create macros for reshape command
local i_vars "SSUID PNUM"
local j_vars "wave"

// Reshape the data wide (1 person per row)
reshape wide `change_variables', i(`i_vars') j(`j_vars')

********************************************************************************
* Create breadwinning measures
********************************************************************************
// Create a lagged measure of breadwinning

gen bw50L1=. // in wave 1 we have no measure of breadwinning in previous wave
gen bw60L1=. 

    forvalues w=2/4{
       local v					=`w'-1
       gen bw50L`w'				=bw50`v' 
       gen bw60L`w'				=bw60`v' 
       gen monthsobservedL`w'	=monthsobserved`v'
       gen minorbiochildrenL`w'	=minorbiochildren`v'
    }



// Create an indicators for whether individual transitioned into breadwinning for the first time (1) 
*  or has been observed breadwinning in the past (2). There is no measure for wave 1 because
* we cant know whether those breadwinning at wave 1 transitioned or were continuing
* in that status...except for women who became mothers in 2013, but there isn't a good
* reason to adjust code just for duration 0.

gen nprevbw501=0
gen nprevbw601=0

forvalues w=2/4{
   local v				=`w'-1
   gen nprevbw50`w'=nprevbw50`v'
   gen nprevbw60`w'=nprevbw60`v'
   replace nprevbw50`w'=nprevbw50`w'+1 if bw50`v'==1
   replace nprevbw60`w'=nprevbw50`w'+1 if bw60`v'==1
 
   gen trans_bw50`w'	=0 				if bw50`w'==0 & nprevbw50`w'==0
   gen trans_bw60`w'	=0 				if bw60`w'==0 & nprevbw60`w'==0
   replace trans_bw50`w'=1 				if bw50`w'==1 & nprevbw50`w'==0
   replace trans_bw60`w'=1 				if bw60`w'==1 & nprevbw60`w'==0

   // code those who previously transitioned into breadwinning

   replace trans_bw50`w'=2 				if nprevbw50`w' > 0
   replace trans_bw60`w'=2 				if nprevbw60`w' > 0
}

drop nprevbw50* nprevbw60*
	
********************************************************************************
* Reshape data to back to long format
********************************************************************************

// Reshape data back to long format
reshape long `change_variables' trans_bw50 trans_bw60 bw50L bw60L monthsobservedL minorbiochildrenL, i(`i_vars') j(`j_vars')

********************************************************************************
* Address missing data
********************************************************************************
// 	Create a tempory unique person id variable
	sort SSUID PNUM
	
	egen id = concat (SSUID PNUM)
	destring id, gen(idnum)
	format idnum %20.0f
	drop id
	
	unique 	idnum 
	
// Make sure starting sample size is consistent.
	egen newsample2 = nvals(idnum) 
	global newsamplesize2 = newsample2
	di "$newsamplesize2"

	di "$newsamplesize"
	di "$newsamplesize2"

	if ("$newsamplesize" == "$newsamplesize2") {
		display "Success! Sample sizes consistent."
		}
		else {
		display as error "The sample size is different than annualize."
		exit
		}
		
* Create table describing full sample of mothers and analytical sample.

putexcel set "$output/Descriptives60.xlsx", sheet(sample) replace
putexcel A1:D1 = "Characteristics of full sample of mothers and analytical sample", merge border(bottom)
putexcel B2 = ("All Mothers") D2 = ("Analytical sample"), border(bottom)
putexcel B3 = ("percent") D3 = ("percent"), border(bottom)
putexcel A4 = "Marital Status"
putexcel A5 = " Spouse"
putexcel A6 = " Partner"
putexcel A7 = "Race/Ethnicity"
putexcel A8 = " Non-Hispanic White"
putexcel A9 = " Black"
putexcel A10 = " Asian"
putexcel A11 = " Other"
putexcel A12 = " Hispanic"
putexcel A13 = "Education"
putexcel A14 = "Less than High School"
putexcel A15 = "Diploma/GED"
putexcel A16 = "Some College"
putexcel A17 = "College Grad+"
putexcel A18 = "Primary Earner (60%)"


putexcel B19 = ("mean") D19 = ("mean"), border(bottom)
putexcel A20 = "age"
putexcel A21 = "Years since first birth"
putexcel A22 = "personal earnings"
putexcel A23 = "household earnings"
putexcel A24 = "personal to household earnings ratio", border(bottom)

putexcel A25 = "unweighted N (individuals)"
// Fill in table for full sample

recode spouse (0=0) (.001/1=1)
recode partner (0=0) (.001/1=1)

mean spouse [aweight=wpfinwgt] 
matrix spouse = 100*e(b)
local pspouse = spouse[1,1]

mean partner [aweight=wpfinwgt] 
matrix partner = 100*e(b)
local ppartner = partner[1,1]

putexcel B5 = `pspouse', nformat(##.#)
putexcel B6 = `ppartner', nformat(##.#)

** Full sample

local raceth "white black asian other hispanic"

forvalues r=1/5 {
   local re: word `r' of `raceth'
   gen `re' = raceth==`r'
   mean `re' [aweight=wpfinwgt] 
   matrix m`re' = 100*e(b)
   local p`re' = m`re'[1,1]
   local row = 7+`r'
   putexcel B`row' = `p`re'', nformat(##.#)
}

local ed "lesshs hs somecol univ"

forvalues e=1/4 {
   local educ : word `e' of `ed'
   gen `educ' = educ==`e'
   mean `educ' [aweight=wpfinwgt] 
   matrix m`educ' = 100*e(b)
   local p`educ' = m`educ'[1,1]
   local row = 14+`e'
   putexcel B`row' = `p`educ'', nformat(##.#)
}

mean bw60 [aweight=wpfinwgt] 
matrix mbw60 = 100*e(b)
local pbw60 = mbw60[1,1]
putexcel B18 = `pbw60', nformat(##.#)

local means "age durmom tpearn thearn earnings_ratio"

forvalues m=1/5{
    local var: word `m' of `means'
    mean `var' [aweight=wpfinwgt] 
    matrix m`var' = e(b)
    local v`m' = m`var'[1,1]
    local row = `m'+19
    putexcel B`row' = `v`m'', nformat(##.#)
}

egen	obvsfs 	= nvals(idnum)
local fs = obvsfs

putexcel B25 = `fs'

// keep only observations with data in the current waves
keep if !missing(monthsobserved)

tab durmom

	egen	obvsnow 	= nvals(idnum)
	global 	obvsnow_n 	= obvsnow
	di "$obvsnow_n"

// and the previous wave, the only cases where we know about a *transition*
// except in year where woman becomes a mother. 
keep if !missing(monthsobservedL) | durmom==0

tab durmom

	egen	obvsprev 	= nvals(idnum)
	global 	obvsprev_n 	= obvsprev
	di "$obvsprev_n"

	drop idnum obvsnow obvsprev

** Analytical sample

mean spouse [aweight=wpfinwgt] 
matrix sspouse = 100*e(b)
local pspouse = sspouse[1,1]

mean partner [aweight=wpfinwgt] 
matrix spartner = 100*e(b)
local ppartner = spartner[1,1]

putexcel D5 = `pspouse', nformat(##.#)
putexcel D6 = `ppartner', nformat(##.#)

forvalues r=1/5 {
   local re: word `r' of `raceth'
   mean `re' [aweight=wpfinwgt] 
   matrix sm`re' = 100*e(b)
   local p`re' = sm`re'[1,1]
   local row = 7+`r'
   putexcel D`row' = `p`re'', nformat(##.#)
}

forvalues e=1/4 {
   local educ : word `e' of `ed'
   mean `educ' [aweight=wpfinwgt] 
   matrix m`educ' = 100*e(b)
   local p`educ' = m`educ'[1,1]
   local row = 14+`e'
   putexcel D`row' = `p`educ'', nformat(##.#)
}

mean bw60 [aweight=wpfinwgt] 
matrix mbw60 = 100*e(b)
local pbw60 = mbw60[1,1]
putexcel D18 = `pbw60'


forvalues m=1/5{
    local var: word `m' of `means'
    mean `var' [aweight=wpfinwgt] 
    matrix sm`var' = e(b)
    local v`m' = sm`var'[1,1]
    local row = `m'+19
    putexcel D`row' = `v`m'', nformat(##.#)
}

putexcel D25 = $obvsprev_n

save "$SIPP14keep/bw_transitions.dta", replace
