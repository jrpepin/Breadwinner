* This script runs a program to create data files for analysis by the lxpct_2 multi-state lifetable procedure

capture program drop create_mstransitions
program define create_mstransitions
   args cutoff subsample suffix // cutoff is either 50 or 60, subsample is like "keep if my_race==1" and suffix is a letter to distinquish save files

   use "$tempdir/msltprep.dta", clear

   `subsample'

   * drop cases missing at either side of the interval
   * remove this to see how many years observations are missing (a lot)
   * except that this doesn't work without adding a new layer of pXX variables

    drop if uybw`cutoff'L1==5 | uyearbw`cutoff'==5

   *create numerators
   egen trans=count(y), by(durmom uyearbw`cutoff' uybw`cutoff'L1)

   * create denominators 
   egen den=count(y), by(durmom uybw`cutoff'L1)

   keep trans den uybw`cutoff'L1 uyearbw`cutoff' durmom
 
   collapse (max) trans den, by(durmom uybw`cutoff'L1 uyearbw`cutoff')

   * create rates
 
   gen p=trans/den
 
   keep p* durmom uybw`cutoff'L1 uyearbw`cutoff'

   rename durmom age

   egen combo=concat(uybw`cutoff'L1 uyearbw`cutoff')

   destring combo, replace

   format combo %-2.0f
 
   drop uybw`cutoff'L1 uyearbw`cutoff'

   reshape wide p  , i(age) j(combo)

   foreach var of varlist _all{
	replace `var'=0 if missing(`var')
   }

   forvalues s=1/3{
       gen sump`s'=p`s'1
       replace sump`s'=sump`s'+p`s'2
       replace sump`s'=sump`s'+p`s'3
   }

   * The life table does not have distribution across states at birth, just transition rates.
   * So, the first transition is from not a mother (at time 0) to a mother (at time 1)
   * Thus, the duration variables are not age of oldest child, but age of oldest child - 1.
   * We need the life table up to duration 17, which represents the year the oldest child 
   * transitions to age 18

   drop if age==-1

   * adjusting the first year so that it is a status, not a transition.
   replace p11=p41 if age==0
   replace p12=p42 if age==0
   replace p13=p43 if age==0

   drop p4*


   save "$SIPP08keep/transrates`cutoff'`suffix'.dta", $replace

end


*******************************************************************************
* generate data files with measures of transition rates
*******************************************************************************

create_mstransitions 50 "keep if 1==1" ""
create_mstransitions 50 "keep if my_race==1" "w"
create_mstransitions 50 "keep if my_race==2" "b"
create_mstransitions 50 "keep if my_race==3" "h"
create_mstransitions 50 "keep if hieduc==1" "e1"
create_mstransitions 50 "keep if hieduc==2" "e2"
create_mstransitions 50 "keep if hieduc==3" "e3"
create_mstransitions 50 "keep if hieduc==4" "e4"
create_mstransitions 60 "keep if 1==1" ""
create_mstransitions 60 "keep if my_race==1" "w"
create_mstransitions 60 "keep if my_race==2" "b"
create_mstransitions 60 "keep if my_race==3" "h"
create_mstransitions 60 "keep if hieduc==1" "e1"
create_mstransitions 60 "keep if hieduc==2" "e2"
create_mstransitions 60 "keep if hieduc==3" "e3"
create_mstransitions 60 "keep if hieduc==4" "e4"











