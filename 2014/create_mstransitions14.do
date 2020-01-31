*-------------------------------------------------------------------------------
* BREADWINNER PROJECT
* bw_transitions.do
* Kelly Raley and Joanna Pepin
*-------------------------------------------------------------------------------
di "$S_DATE"

********************************************************************************
* DESCRIPTION
********************************************************************************
* This script runs a program to create data files for analysis by the lxpct_2 
* multi-state lifetable procedure

* The data file used in this script was produced by msltprep.do

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
 
   collapse (max) trans den, by(durmom mbw`cutoff'L mbw`cutoff')

   * create rates
 
   gen p=trans/den
 
   keep p* durmom mbw`cutoff'L mbw`cutoff'

   egen combo=concat(mbw`cutoff'L mbw`cutoff')

   destring combo, replace

   format combo %-2.0f
 
   drop mbw`cutoff'L mbw`cutoff'

   reshape wide p  , i(durmom) j(combo)

   foreach var of varlist _all{
	replace `var'=0 if missing(`var')
   }

   rename durmom age
   
   save "$SIPP14keep/transrates`cutoff'`suffix'.dta", $replace

end


*******************************************************************************
* Generate data files with measures of transition rates
*******************************************************************************
// Transition rate at the 50% threshold
create_mstransitions 50 "keep if 1==1" "t"
create_mstransitions 50 "keep if race==1" "w"
create_mstransitions 50 "keep if race==2" "b"
create_mstransitions 50 "keep if race==5" "h"
create_mstransitions 50 "keep if educ==1" "e1"
create_mstransitions 50 "keep if educ==2" "e2"
create_mstransitions 50 "keep if educ==3" "e3"
create_mstransitions 50 "keep if educ==4" "e4"

// Transition rate at the 60% threshold
create_mstransitions 60 "keep if 1==1" "t"
create_mstransitions 60 "keep if race==1" "w"
create_mstransitions 60 "keep if race==2" "b"
create_mstransitions 60 "keep if race==5" "h"
create_mstransitions 60 "keep if educ==1" "e1"
create_mstransitions 60 "keep if educ==2" "e2"
create_mstransitions 60 "keep if educ==3" "e3"
create_mstransitions 60 "keep if educ==4" "e4"
