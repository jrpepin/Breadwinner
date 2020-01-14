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

* The data files used in this script were produced by extract_earnings.do & create_hhcomp.do

********************************************************************************
* Merge  measures of earning, demographic characteristics and household composition
********************************************************************************
use "$SIPP14keep/sipp14tpearn_all", clear

// 	Create a tempory unique person id variable
	sort SSUID PNUM
	egen id = concat (SSUID PNUM)
	destring id, gen(idnum)
	format idnum %20.0f
	drop id
	
	egen sample=nvals(idnum)
	global samplesize = sample
	di "$samplesize"

// Make sure starting with consistent sample size.
	assert "$mothers0to25" == "$samplesize"
	
	drop sample idnum // clear variables to recreate again after merge.

// Merge this data with household composition data.
merge 1:1 SSUID PNUM panelmonth using "$tempdir/hhcomp.dta"

// Fix variables for unmatched individuals who live alone (_merge==1)
* Relationship_pairs_bymonth has one record per person living with PNUM. 
* We deleted records where "from_num==to_num." (compute_relationships.do)
* So, individuals living alone are not in the data.

	// Make relationship variables equal to zero
	local hhcompvars "minorchildren minorbiochildren spouse partner numtype2"

	foreach var of local hhcompvars{
		replace `var'=0 if _merge==1 & missing(`var') 
	}
	
	// Make household size = 1
	replace hhsize = 1 if _merge==1

// 	Create a tempory unique person id variable
	sort SSUID PNUM
	egen id = concat (SSUID PNUM)
	destring id, gen(idnum)
	format idnum %20.0f
	drop id
	
	unique 	idnum 	if _merge!=2

* Now, let's make sure we have the same number of mothers as before.
	egen newsample=nvals(idnum) if _merge!=2
	global newsamplesize = newsample
	di "$newsamplesize"

// Make sure starting sample size is consistent.
di "$mothers0to25"
di "$newsamplesize"

	if ("$mothers0to25" == "$newsamplesize") {
		display "Success! Sample sizes consistent."
		}
		else {
		display as error "The sample size is different than extract_earnings."
		exit
		}
		
	keep if _merge!=2 
	drop 	_merge

********************************************************************************
* Restrict sample to women who live with their own minor children
********************************************************************************
*!*!*! JP START HERE -- RECODE USING SYNTAX EXAMPLE FROM EXTRACT_EARNINGS
// Keep mothers who reside with their biological children
	fre minorbiochildren // if tagid==1 (CHANGE TO NEW WAY TO SEE UNIQUE RECORDS)
	
	cap drop notmom
	gen notmom = 1 if minorbiochildren < 1
	
*	replace tagid = . if minorbiochildren < 1 // No minor children in the household.
*	egen mothers_cores_minor = count(tagid)
	keep if minorbiochildren >= 1   // *?*?* How many cases are we dropping and why?? 

// Creates a macro with the total number of residential mothers in the dataset.	 
*	global mothers_cores_minor = mothers_cores_minor

	drop idnum mothers_cores_minor 
		
********************************************************************************
* Create descrptive statistics to prep for annualized variables
********************************************************************************

// Now I want to know what the first and last month of observation in this year is
   egen startmonth=min(monthcode), by(SSUID PNUM year)
   egen lastmonth =max(monthcode), by(SSUID PNUM year)

* preparing to count of the total number of months breadwinning for the year. (won't be our primary measure)

   gen mbw50=1 if tpearn > .5*thearn & !missing(tpearn) & !missing(thearn)
   gen mbw60=1 if tpearn > .6*thearn & !missing(tpearn) & !missing(thearn)

* preparing to create indicators of whether the household experienced an increase or decrease in number of earners
* I wanted these to indicate whether an earner move out or moved in, but it could be that or it could be
* because of a change in earnings status of anyone in the household. It would be harder to create the measure we wanted for
* the evaluation of whether mismeasurement of timing of changes in household composition might distort our measurement
* of breadwinning. So, instead, let's use partnership transitions
   gen start_earners=numearner if monthcode==startmonth
   gen last_earners=numearner if monthcode==lastmonth

* preparing to create indicators of transitions into marriage/cohabitation or out of marriage/cohabitation

  replace spouse=1 if spouse > 1 // one case has 2 spouses
  replace partner=1 if partner > 1 // about 40 cases of 300k

  gen spartner=1 if spouse==1 | partner==1
  replace spartner=0 if spouse==0 & partner==0

  gen start_spartner=spartner if monthcode==startmonth
  gen last_spartner=spartner if monthcode==lastmonth


gen one=1

*************** collapsing to year *************************************
*  and then collapse to create annual measures

collapse (count) monthsobserved=one  nmos_bw50=mbw50 nmos_bw60=mbw60 (sum) tpearn thearn (mean) spouse partner numtype2 wpfinwgt (max) minorchildren minorbiochildren erace eeduc tceb oldest_age start_spartner last_spartner (min) durmom youngest_age,  by(SSUID PNUM year)

gen anytype2= (numtype2 > 0)

drop numtype2

gen hh_noearnings= (thearn <= 0)

gen bw50= (tpearn > .5*thearn) if !missing(tpearn) & hh_noearnings !=1
replace bw50=0 if missing(tpearn) & !missing(thearn)

gen bw60= (tpearn > .6*thearn) if !missing(tpearn) & hh_noearnings !=1
replace bw60=0 if missing(tpearn) & !missing(thearn)

gen gain_partner=0 if !missing(start_spartner) & !missing(last_spartner)
replace gain_partner=1 if start_spartner==0 & last_spartner==1

gen lost_partner=0 if !missing(start_spartner) & !missing(last_spartner)
replace lost_partner=1 if start_spartner==1 & last_spartner==0

gen partial_year= (monthsobserved < 12)

* the key number is the percent breadwinning in the first year. (~25%)

sum bw50 if durmom==1 

gen per_bw50_atbirth=100*`r(mean)'
gen notbw50_atbirth=1-`r(mean)'

sum bw60 if dursinceb1_atint==1 

gen per_bw60_atbirth=100*`r(mean)'
gen notbw60_atbirth=1-`r(mean)'

save "$SIPP14keep/bwstatus.dta", replace
