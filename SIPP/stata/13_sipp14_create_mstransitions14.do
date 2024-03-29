*-------------------------------------------------------------------------------
* BREADWINNER PROJECT
* create_mstransitions14.do
* Kelly Raley and Joanna Pepin
*-------------------------------------------------------------------------------
di "$S_DATE"

********************************************************************************
* DESCRIPTION
********************************************************************************
* This script runs a program to create data files for analysis by the lxpct_2 
* multi-state lifetable procedure

* The data file used in this script was produced by msltprep.do

* The resulting data files have estimates of the proportions remaining or transitioning
* between statuses by duration.
* p11 is the proportion in status 1 in the previous year (L) that remained in 
* status 1 at the end of that duration

********************************************************************************
* Create a program to generate the transitions
********************************************************************************

capture program drop create_mstransitions
program define create_mstransitions
   args cutoff subsample suffix // cutoff is either 50 or 60, subsample is like "keep if my_race==1" and suffix is a letter to distinquish save files

   use "$tempdir/msltprep14.dta", clear

   `subsample'

   * create weighted numerators
   egen trans=total(weight), by(durmom mbw`cutoff' mbw`cutoff'L)

   * create weighted denominators 
   egen den=total(weight), by(durmom mbw`cutoff'L)

   keep trans den mbw`cutoff'L mbw`cutoff' durmom
   
   tab mbw`cutoff'L mbw`cutoff'
 
   collapse (max) trans den, by(durmom mbw`cutoff'L mbw`cutoff') 

   * create rates
 
   gen p=trans/den
 
   keep p* durmom mbw`cutoff'L mbw`cutoff'

   egen combo=concat(mbw`cutoff'L mbw`cutoff')

   destring combo, replace
   
   format combo %-2.0f
 
   drop mbw`cutoff'L mbw`cutoff'

   reshape wide p  , i(durmom) j(combo)

   local allcombos "p11 p12 p13 p14 p21 p22 p23 p24 p31 p32 p33 p34 p41 p42 p43 p44"
      
   foreach var in `allcombos' {
       capture confirm variable `var', exact
	   if !_rc {
	    display "`var' exists"
	   }
	   else {
	    display "`var' does not exist"
		gen `var'=0
	   }
   }
   
   foreach var of varlist _all{
	replace `var'=0 if missing(`var')
   }

   rename durmom age
   
   save "$SIPP14keep/transrates`cutoff'`suffix'.dta", replace

end


*******************************************************************************
* Generate data files with measures of transition rates
*******************************************************************************
// Transition rate at the 50% threshold
create_mstransitions 50 "keep if 1==1" "t"
create_mstransitions 50 "keep if raceth==1" "w"
create_mstransitions 50 "keep if raceth==2" "b"
create_mstransitions 50 "keep if raceth==5" "h"
create_mstransitions 50 "keep if educ==1" "e1"
create_mstransitions 50 "keep if educ==2" "e2"
create_mstransitions 50 "keep if educ==3" "e3"
create_mstransitions 50 "keep if educ==4" "e4"
create_mstransitions 50 "keep if raceduc==1" "we1"
create_mstransitions 50 "keep if raceduc==2" "we2"
create_mstransitions 50 "keep if raceduc==3" "we3"
create_mstransitions 50 "keep if raceduc==4" "we4"
create_mstransitions 50 "keep if raceduc==5" "be1"
create_mstransitions 50 "keep if raceduc==6" "be2"
create_mstransitions 50 "keep if raceduc==7" "be3"
create_mstransitions 50 "keep if raceduc==8" "be4"
create_mstransitions 50 "keep if raceduc==9" "he1"
create_mstransitions 50 "keep if raceduc==10" "he2"
create_mstransitions 50 "keep if raceduc==11" "he3"
create_mstransitions 50 "keep if raceduc==12" "he4"
create_mstransitions 50 "keep if nmb==0" "nmb0"
create_mstransitions 50 "keep if nmb==1" "nmb1"

// Transition rate at the 60% threshold
create_mstransitions 60 "keep if 1==1" "t"
create_mstransitions 60 "keep if raceth==1" "w"
create_mstransitions 60 "keep if raceth==2" "b"
create_mstransitions 60 "keep if raceth==5" "h"
create_mstransitions 60 "keep if educ==1" "e1"
create_mstransitions 60 "keep if educ==2" "e2"
create_mstransitions 60 "keep if educ==3" "e3"
create_mstransitions 60 "keep if educ==4" "e4"
create_mstransitions 60 "keep if raceduc==1" "we1"
create_mstransitions 60 "keep if raceduc==2" "we2"
create_mstransitions 60 "keep if raceduc==3" "we3"
create_mstransitions 60 "keep if raceduc==4" "we4"
create_mstransitions 60 "keep if raceduc==5" "be1"
create_mstransitions 60 "keep if raceduc==6" "be2"
create_mstransitions 60 "keep if raceduc==7" "be3"
create_mstransitions 60 "keep if raceduc==8" "be4"
create_mstransitions 60 "keep if raceduc==9" "he1"
create_mstransitions 60 "keep if raceduc==10" "he2"
create_mstransitions 60 "keep if raceduc==11" "he3"
create_mstransitions 60 "keep if raceduc==12" "he4"
create_mstransitions 60 "keep if nmb==0" "nmb0"
create_mstransitions 60 "keep if nmb==1" "nmb1"

save "$SIPP14keep/transrates60be1.dta", replace


