*-------------------------------------------------------------------------------
* BREADWINNER PROJECT
* allpairs.do
* Kelly Raley and Joanna Pepin
*-------------------------------------------------------------------------------
di "$today"

********************************************************************************
* DESCRIPTION
********************************************************************************
*?*?* THIS WAS THE DESCRIPTION, BUT THESE VARIABLES AREN'T USED......

* This script will create a dataset that we will use to merge onto the rel_pairs_bymonth 
* data created in the compute_relationships script.

* The data files used in this script were produced by merge_waves.do

********************************************************************************
* Reshape data
********************************************************************************

// Import data 
use "$SIPP14keep/allmonths14", clear

// Select only necessary variables
keep SSUID ERESIDENCEID PNUM panelmonth TAGE ESEX ERACE

save "$tempdir/onehalf", $replace

rename PNUM from_num
rename TAGE from_age
rename ESEX from_sex
rename ERACE from_race

// Reshape the data ?*?* I don't understand what this command is doing */
joinby SSUID ERESIDENCEID panelmonth using "$tempdir/onehalf" 

rename PNUM to_num
rename TAGE to_age
rename ESEX to_sex
rename ERACE to_race

sort SSUID ERESIDENCEID panelmonth from_num to_num

// delete variables no longer needed
drop if from_num==to_num

save "$tempdir/allpairs", $replace
