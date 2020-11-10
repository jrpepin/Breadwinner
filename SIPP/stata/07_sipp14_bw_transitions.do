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

save "$SIPP14keep/bw_transitions.dta", replace
