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
* It is restricted to mothers living with minor children.
********************************************************************************
* Create descrptive statistics to prep for annualized variables
********************************************************************************
use "$SIPP14keep/sipp14tpearn_all", clear

// Create variables with the first and last month of observation by year
   egen startmonth=min(monthcode), by(SSUID PNUM year)
   egen lastmonth =max(monthcode), by(SSUID PNUM year)
   
   * All months have the same number of observations (12) within year
   * so this wasn't necessary.
   order 	SSUID PNUM year startmonth lastmonth
   list 	SSUID PNUM year startmonth lastmonth in 1/5, clean

* Prep for counting the total number of months breadwinning for the year. 
* NOTE: This isn't our primary measure.
   gen mbw50=1 if tpearn > .5*thearn & !missing(tpearn) & !missing(thearn)	// 50% threshold
   gen mbw60=1 if tpearn > .6*thearn & !missing(tpearn) & !missing(thearn)	// 60% threshold
   
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
			(sum) 	tpearn thearn 												///
			(mean) 	spouse partner numtype2 wpfinwgt 							///
			(max) 	minorchildren minorbiochildren raceth educ tceb oldest_age 	///
					start_spartner last_spartner tage ageb1						///
			(min) 	durmom youngest_age first_wave,								///
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
	
	gen earnings_ratio=tpearn/thearn if hh_noearnings !=1 & !missing(tpearn) 

	// 50% breadwinning threshold
	* Note that this measure was missing for no (or negative) earnings households, but that is now changed
	gen 	bw50= (tpearn > .5*thearn) 	if hh_noearnings !=1 & !missing(tpearn) 
	replace bw50= 0 					if hh_noearnings==1
		/* *?*?* WE DON'T HAVE ANY MISSING TPEARN | THEARN. IS THAT EXPECTED? */
		/* yes. We are now using allocated data. The SIPP 2014 doesn't have codes */
		/* for whether the summary measure includes allocated data */


	// 60% breadwinning threshold
	gen 	bw60= (tpearn > .6*thearn) 	if hh_noearnings !=1 & !missing(tpearn)
	replace bw60= 0 					if hh_noearnings==1
	
gen wave=year-2012
	
save "$SIPP14keep/bwstatus.dta", replace
