***
*
* USE RREL and RRELPUM variables to describe each person's relationship to every other person in the household by month
* 
* The RREL variables RREL1-RREL20 are for type 1 persons and RREL21-RREL30 are for type 2 persons
* This file creates pairs only between two type 2 people. 

use "$SIPP14keep/allmonths14", clear

keep SSUID ERESIDENCEID PNUM panelmonth TAGE ESEX ERACE

save "$tempdir/onehalf", $replace

rename PNUM from_num
rename TAGE from_age
rename ESEX from_sex
rename ERACE from_race

joinby SSUID ERESIDENCEID panelmonth using "$tempdir/onehalf"

rename PNUM to_num
rename TAGE to_age
rename ESEX to_sex
rename ERACE to_race

sort SSUID ERESIDENCEID panelmonth from_num to_num

drop if from_num==to_num

save "$tempdir/allpairs", $replace

* want to merge this onto the relationship_pairs data to refine relationship variables
