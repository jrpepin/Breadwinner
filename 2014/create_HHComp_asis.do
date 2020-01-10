*-------------------------------------------------------------------------------
* BREADWINNER PROJECT
* extract_and_format.do
* Kelly Raley and Joanna Pepin
*-------------------------------------------------------------------------------
di "$S_DATE"

********************************************************************************
* DESCRIPTION
********************************************************************************
* Create a data file with one record for each coresident pair in each wave
* Merge onto the file the relationships data created by compute_relationships.

* The data files used in this script were produced by merge_waves & compute_relationships.do

********************************************************************************
* Create database with all pairs of coresident individuals in each wave
********************************************************************************
use "$SIPP14keep/allmonths14"

keep SSUID ERESIDENCEID PNUM panelmonth ERELRP TAGE ESEX

sort SSUID ERESIDENCEID panelmonth

// Create a variable with the number the people in the household at each wave.
by SSUID ERESIDENCEID panelmonth:  gen HHmembers = _N  

rename PNUM to_num
rename ERELRP ERRPto
rename TAGE to_age
rename ESEX to_sex

save "$tempdir/to", $replace

use "$SIPP14keep/allmonths14", clear

keep SSUID ERESIDENCEID PNUM panelmonth ERELRP TAGE ESEX

rename PNUM from_num
rename ERELRP ERRPfrom

// Reshape data
joinby SSUID ERESIDENCEID panelmonth using "$tempdir/to"  

// drop pairs of ego to self
drop if to_num==from_num

save "$tempdir/pairwise_bymonth", $replace

********************************************************************************
* Merge datasets
********************************************************************************

merge m:1 SSUID from_num to_num panelmonth using "$tempdir/relationship_pairs_bymonth"

replace relationship = .a if (_merge == 1) & (missing(relationship))
replace relationship = .m if (_merge == 3) & (missing(relationship))

gen err=1 if relationship==.
egen errors=count(err)

assert (errors < 100)
drop _merge err errors

tab relationship, m

rename from_num PNUM
rename to_num to_PNUM

tab relationship, m 

save "$SIPP14keep/HHComp_asis.dta", $replace
