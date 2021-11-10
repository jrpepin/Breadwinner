*-------------------------------------------------------------------------------
* BREADWINNER PROJECT
* msltprep.do
* Kelly Raley and Joanna Pepin
*-------------------------------------------------------------------------------
di "$S_DATE"

********************************************************************************
* DESCRIPTION
********************************************************************************
* This file creates lagged variables for breadwinning status in the year prior to this on (bw?0L)
* and adds categories of values for not living with minor bio children or aged out to prep for
* multi-state lifetable analysis

* The data file used in this script was produced by bw_transitions.do

********************************************************************************
* Reshape data to make the file wide
********************************************************************************
use "$SIPP14keep/bwstatus.dta", clear

// Drop respondents who have been mothers for longer than 18 years
drop if durmom > 18 

* List of variables that should be constants:
	* per_bw50_atbirth notbw50_atbirth pper_bw60_atbirth notbw50_atbirth first_wave

	// Indicator for whether mother lives with no other adults

gen adult_others= minadults==0
replace adult_others=0 if minadults==1 & tage < 18 // there's one adult in the hh and it's not the mother.
	
// List of variables that change over time
local change_variables 	year monthsobserved nmos_bw50 nmos_bw60 tpearn thearn spouse ///
			partner	wpfinwgt minorchildren minorbiochildren tceb ///
			oldest_age start_spartner last_spartner durmom  ///
			youngest_age anytype2 hh_noearnings bw50 bw60 	///
			gain_partner lost_partner partial_year raceth nmb  ///
			educ tage ageb1 earnings_ratio minadults maxadults ///
			adult_others 


			
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
gen minadultsL1=.
gen adult_othersL1=.

    forvalues w=2/4{
       local v					=`w'-1
       gen bw50L`w'				=bw50`v' 
       gen bw60L`w'				=bw60`v' 
	   gen minadultsL`w'		=minadults`v'
	   gen monthsobservedL`w'	=monthsobserved`v'
	   gen minorbiochildrenL`w'	=minorbiochildren`v'
	   gen adult_othersL`w' = adult_others`v'
    }

********************************************************************************
* Reshape data to back to long format
********************************************************************************
reshape long `change_variables' trans_bw50 trans_bw60 bw50L bw60L minadultsL monthsobservedL minorbiochildrenL adult_othersL, i(`i_vars') j(`j_vars')

//* delete observations created by reshape
keep if !missing(monthsobserved)

********************************************************************************
* Create breadwinning states
********************************************************************************

// Correct breadwinning indictors by adding 2
* First add 1 to make the "p" variables start with "p11" not "p00"
* then add another 1 to make the non-mother state the first one because the lifetable
* program appears to assume that everyone starts in state 1.
gen mbw50=bw50+2
gen mbw60=bw60+2
gen mbw50L=bw50L+2
gen mbw60L=bw60L+2

* finally, add one if mother spent some time in the year with no (other) adults
replace mbw50=4 if mbw50==3 & adult_others==0 
replace mbw60=4 if mbw60==3 & adult_others==0
replace mbw50L=4 if mbw60L==3 & adult_othersL==0 
replace mbw60L=4 if mbw60L==3 & adult_othersL==0

tab bw50L, m

tab mbw50L, m

// Set state indicators to 1 if not a mom
local nowvars "mbw50 mbw60"
foreach var in `nowvars'{
	replace `var'=1 if minorbiochildren==0 		// not residential mom -- different than in measures_and_sample.do
}

local thenvars  "mbw50L mbw60L"
foreach var in `thenvars'{
	replace `var'=1 if minorbiochildrenL==0 	// not residential mom -- different than in measures_and_sample.do
	replace `var'=1 if durmom==0 & year > 2013 	// forcing not mom in year prior to first birth
}

************************
* create a variable combining race and education
************************

gen raceduc=educ if raceth==1
replace raceduc=educ+4 if raceth==2
replace raceduc=educ+8 if raceth==5


// Label the breadwinning state variable values
#delimit ;
label define bwstat 1 "not living with children or first child > 18"
                    2 "non-breadwinning mother"
                    3 "breadwinning mother other adults"
		    4 "breadwinning mother sometimes alone"; 		
# delimit cr

label values mbw50 bwstat
label values mbw60 bwstat
label values mbw50L bwstat
label values mbw60L bwstat

// Drop if cases missing on mbw50L
* we could have missing as a state in the lifetable if we had cases
* missing on mbw50, but if we don't then it doesn't help to include
* observations missing on the lagged variable. Mising is all due to non
* interview. Little obvious to be gained by including.
drop if missing(mbw50L)

*** JP: ADD ANOTHER SAMPLE SIZE MACRO HERE.

// scale the weight to have an average of 1
sum wpfinwgt
gen weight=wpfinwgt/`r(mean)'
sum weight

save "$tempdir/msltprep14.dta", replace
