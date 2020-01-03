* merge together measures of earning and demographic characteristics with measures of household composition and then collapse to
* create annual measures

use "$SIPP14keep/sipp14tpearn_all", clear

merge 1:1 SSUID PNUM panelmonth using "$tempdir/hhcomp.dta"

keep if _merge==3

drop _merge

* we want to limit to measurement of earnings to observations where women live with minor own children
keep if minorbiochildren >= 1

* describe sample
	 sort SSUID PNUM
	 egen tagid = tag(SSUID PNUM)
	 replace tagid=. if tagid !=1 

	 egen mothers_cores_minor=count(tagid)

	 global mothers_cores_minor = mothers_cores_minor

	 drop mothers_cores_minor tagid

* Now I want to know what the first and last month of observation in this year is
   egen startmonth=min(monthcode), by(SSUID PNUM year)
   egen lastmonth=max(monthcode), by(SSUID PNUM year)

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

collapse (count) monthsobserved=one  nmos_bw50=mbw50 nmos_bw60=mbw60 (sum) tpearn thearn (mean) spouse partner numtype2 wpfinwgt (max) minorchildren minorbiochildren erace eeduc tceb oldest_age start_spartner last_spartner (min) dursinceb1_atint youngest_age,  by(SSUID PNUM year)

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

sum bw50 if dursinceb1_atint==1 

gen per_bw50_atbirth=100*`r(mean)'
gen notbw50_atbirth=1-`r(mean)'

sum bw60 if dursinceb1_atint==1 

gen per_bw60_atbirth=100*`r(mean)'
gen notbw60_atbirth=1-`r(mean)'

save "$SIPP14keep/bwstatus.dta", replace



