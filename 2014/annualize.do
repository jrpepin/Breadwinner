*-------------------------------------------------------------------------------
* BREADWINNER PROJECT
* annualize.do
* Kelly Raley and Joanna Pepin
*-------------------------------------------------------------------------------
di "$S_DATE"

********************************************************************************
* DESCRIPTION
********************************************************************************
* Create annual measures of breadwinning.

* The data file used in this script was produced by measures_and_sample.do

********************************************************************************
* Create descrptive statistics to prep for annualized variables
********************************************************************************
use "$SIPP14keep/sipp14tpearn_all", clear

// Create variables with the first and last month of observation by year
   egen startmonth=min(monthcode), by(SSUID PNUM year)
   egen lastmonth =max(monthcode), by(SSUID PNUM year)
   
   order 	SSUID PNUM year startmonth lastmonth
   list 	SSUID PNUM year startmonth lastmonth in 1/5, clean

* Prep for counting the total number of months breadwinning for the year. 
* NOTE: This isn't our primary measure.
   gen mbw50=1 if tpearn > .5*thearn & !missing(tpearn) & !missing(thearn)	// 50% threshold
   gen mbw60=1 if tpearn > .6*thearn & !missing(tpearn) & !missing(thearn)	// 60% threshold

/*
	// Create indicators of whether the household experienced an increase or decrease in number of earners
	* These variables indicate whether an earner move out or moved in OR whether there was a change 
	* in the earnings status of anyone in the household.
   
		gen start_earners	=numearner 	if monthcode==startmonth
		gen last_earners 	=numearner 	if monthcode==lastmonth
	
	* Mismeasurement of timing of changes in household composition may distort our measurement of breadwinning. 
	* So, instead, let's use partnership transitions
*/
   
// Create indicators of transitions into marriage/cohabitation or out of marriage/cohabitation
	replace spouse	=1 	if spouse 	> 1 // one case has 2 spouses
	replace partner	=1 	if partner 	> 1 // 36 cases of 2-3 partners

	// Create a combined spouse & partner indicator
	gen 	spartner=1 	if spouse==1 | partner==1
	replace spartner=0 	if spouse==0 & partner==0
	
	// Create indicators of partner presence at the first and last month of observation by year
	gen 	start_spartner=spartner if monthcode==startmonth
	gen 	last_spartner=spartner 	if monthcode==lastmonth

// Create basic indictor to identify months observed when data is collapsed
	gen one=1

********************************************************************************
* Create annual measures
********************************************************************************
// Collapse the data by year to create annual measures
collapse 	(count) monthsobserved=one  nmos_bw50=mbw50 nmos_bw60=mbw60 		///
			(sum) 	tpearn thearn 						///
			(mean) 	spouse partner numtype2 wpfinwgt 			///
			(max) 	minorchildren minorbiochildren erace eeduc tceb oldest_age 	///
					start_spartner last_spartner 			///
			(min) 	durmom youngest_age,  					///
			by(SSUID PNUM year)
			
// Fix Type 2 people identifier
	gen 	anytype2 = (numtype2 > 0)
	drop 	numtype2

// Create indicators for partner changes
	gen 	gain_partner=0 				if !missing(start_spartner) & !missing(last_spartner)
	replace gain_partner=1 				if start_spartner==0 		& last_spartner==1

	gen 	lost_partner=0 				if !missing(start_spartner) & !missing(last_spartner)
	replace lost_partner=1 				if start_spartner==1 		& last_spartner==0

// Create indicator for incomple annual observations
	gen partial_year= (monthsobserved < 12)

// Create annual breadwinning indicators

	// Create indicator for negative household earnings & no earnings. 
	gen hh_noearnings= (thearn <= 0)

	// 50% breadwinning threshold
	gen 	bw50= (tpearn > .5*thearn) 	if !missing(tpearn) 		& hh_noearnings !=1
	replace bw50=0 						if missing(tpearn) 			& !missing(thearn)
		/* *?*?* WE DON'T HAVE ANY MISSING TPEARN | THEARN. IS THAT EXPECTED? */

	// 60% breadwinning threshold
	gen 	bw60= (tpearn > .6*thearn) 	if !missing(tpearn) 		& hh_noearnings !=1
	replace bw60=0 						if missing(tpearn) 			& !missing(thearn)

********************************************************************************
* Describe percent breadwinning in the first year
********************************************************************************
// The percent breadwinning (50% threhold) in the first year. (~25%)
	sum bw50 if durmom==0 /**?*?* Should this be 0 OR 1 ?. It should be 0 */

	gen per_bw50_atbirth	=100*`r(mean)'
	gen notbw50_atbirth		=1-`r(mean)'

// The percent breadwinning (60% threhold) in the first year. (~17%)
	sum bw60 if durmom==0 /**?*?* Should this be 0 OR 1 ?. 0 only. Breadwinning in the year of the birth */

	gen per_bw60_atbirth=100*`r(mean)'
	gen notbw60_atbirth=1-`r(mean)'

save "$SIPP14keep/bwstatus.dta", replace
