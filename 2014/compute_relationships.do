*-------------------------------------------------------------------------------
* BREADWINNER PROJECT
* compute_relationships.do
* Kelly Raley and Joanna Pepin
*-------------------------------------------------------------------------------
di "$S_DATE"

********************************************************************************
* DESCRIPTION
********************************************************************************
* This script uses the RREL and RRELPUM variables to describe each person's relationship 
* to every other person in the household by month

* The RREL variables RREL1-RREL20 are for type 1 persons and RREL21-RREL30 are for type 2 persons

* The data file used in this script was produced by merge_waves.do

********************************************************************************
* Reshape relationship data from a file with one record for each (type 1) person
* to a file with one record for each person a type 1 individual lives with
* (including type 2 people).
********************************************************************************

// Import relationship data
use "$SIPP14keep/allmonths14.dta", clear

// Select only necessary variables
keep SSUID ERESIDENCEID PNUM RREL* RREL_PNUM* panelmonth

// Resahpe the data
reshape long RREL_PNUM RREL,i(SSUID ERESIDENCEID PNUM panelmonth) j(lno) 

// Don't keep relationship to self or empty lines
keep if RREL !=99 & !missing(RREL) 

// Add value labels to relationship variables
#delimit ;
label define rel  1 " Opposite sex spouse"
                  2 " Opposite sex unmarried partner"
                  3 "Same sex spouse"
                  4 "Same sex unmarried partner"
                  5 "Biological parent/child"
                  6 "Step parent/child"
                  7 "Adoptive parent/child"
                  8 "Grandparent/Grandchild"
                  9 "Biological siblings"
                 10 "Half siblings"
                 11 "Step siblings"
                 12 "Adopted siblings"
                 13 "Other siblings"
                 14 "Parent/Child-in-law"
                 15 "Brother/Sister-in-law"
                 16 "Aunt, Uncle, Niece, Nephew"
                 17 "Other relative"
                 18 "Foster parent/Child"
                 19 "Other non-relative"
                 99 "self" ;

#delimit cr

label values RREL  rel

// Peek at the labels and values
fre RREL

// Rename vars
rename PNUM from_num
rename RREL_PNUM to_num

save "$tempdir/rel_pairs_bymonth.dta", replace

********************************************************************************
* Reshape data on type 1 individuals,
* creating two records for each pair of coresident
* type 1 people using joinby
********************************************************************************

// Import relationship data, a file with one record per type 1 individual 
use "$SIPP14keep/allmonths14.dta", clear

// Select only necessary variables
keep SSUID ERESIDENCEID PNUM panelmonth TAGE ESEX ERACE

save "$tempdir/onehalf.dta", replace

rename PNUM from_num
rename TAGE from_age
rename ESEX from_sex
rename ERACE from_race

// Reshape the data
joinby SSUID ERESIDENCEID panelmonth using "$tempdir/onehalf.dta" 

rename PNUM to_num
rename TAGE to_age
rename ESEX to_sex
rename ERACE to_race

// Organize the data to make it easier to see the merged results
sort SSUID ERESIDENCEID panelmonth from_num to_num
order  SSUID ERESIDENCEID panelmonth from_num to_num from_age to_age from_sex to_sex from_race to_race 

* browse // look at the results

// Delete record of individual living with herself
drop if from_num==to_num 

save "$tempdir/allt1pairs.dta", replace

********************************************************************************
* Identify Type 1 people
********************************************************************************
* all in rel_pairs_bymonth are matched in allt1pairs, but not vice versa.
* This is because type 2 people don't have observations in allt1pairs

use "$tempdir/rel_pairs_bymonth.dta", clear

// Combine relationship data with Type 1 data
merge 1:1 SSUID ERESIDENCEID panelmonth from_num to_num using "$tempdir/allt1pairs.dta"

keep if _merge==3
drop 	_merge

// Create a variable identifying these individuals as Type 1
gen pairtype =1

save "$tempdir/t1.dta", replace

********************************************************************************
* Reshape Type 2 data
********************************************************************************

** Import data on type 2 people
use "$SIPP14keep/allmonths14_type2.dta", clear

** Select only necessary variables
keep SSUID ERESIDENCEID panelmonth PNUM ET2_LNO* ET2_SEX* TT2_AGE* TAGE

** reshape the data to have one record for each type 2 person living in a type 1 person's household
reshape long ET2_LNO ET2_SEX TT2_AGE, i(SSUID ERESIDENCEID panelmonth PNUM) j(lno)

rename PNUM from_num
rename TAGE from_age
rename ET2_LNO to_num
rename ET2_SEX to_sex
rename TT2_AGE to_age

** delete variables no longer needed
drop if missing(to_num)

save "$tempdir/type2_pairs.dta", replace

********************************************************************************
* Add type 2 people's demographic information
********************************************************************************

use "$tempdir/rel_pairs_bymonth.dta", clear

// Combine datasets
merge 1:1 SSUID ERESIDENCEID panelmonth from_num to_num using "$tempdir/type2_pairs.dta"

keep if _merge	==3
drop 	_merge

// Create a variable identifying these individuals at Type 1
gen pairtype=2

// Merge type 2 people's data with type 1 people
append using "$tempdir/t1.dta"

label variable pairtype "Is the person a type 1 or type 2 individual?"

tab from_age pairtype

// Recode relationship variable
recode RREL (1=1)(2=2)(3=1)(4=2)(5/19=.), gen(relationship) 
replace relationship=RREL+2 if RREL >=9 & RREL <=13 		// bump rarer codes up to make room for common ones
replace relationship=16 	if RREL==14 | RREL==15 			// combine in-law categories
replace relationship=RREL+1 if RREL >=16 & RREL <=19 		// bump rarer codes up to make room for common ones
replace relationship=3  	if RREL==5 & to_age > from_age 	// parents must be older than children
replace relationship=4  	if RREL==5 & to_age < from_age	// bio child
replace relationship=5  	if RREL==6 & to_age > from_age 	// Step
replace relationship=6  	if RREL==6 & to_age < from_age 	// There are a small number of cases where ages are equal
replace relationship=7  	if RREL==7 & to_age > from_age 	// Adoptive
replace relationship=8  	if RREL==7 & to_age < from_age 	// There are a small number of cases where ages are equal
replace relationship=9  	if RREL==8 & to_age > from_age 	// Grandparent
replace relationship=10 	if RREL==8 & to_age < from_age	// Grandchild

#delimit ;
label define arel 1 "Spouse"
                  2 "Unmarried partner"
                  3 "Biological parent"
                  4 "Biological child"
                  5 "Step parent"
                  6 "Step child"
                  7 "Adoptive parent"
                  8 "Adoptive child"
                  9 "Grandparent"
                 10 "Grandchild"
                 11 "Biological siblings"
                 12 "Half siblings"
                 13 "Step siblings"
                 14 "Adopted siblings"
                 15 "Other siblings"
                 16 "In-law"
                 17 "Aunt, Uncle, Niece, Nephew"
                 18 "Other relationship"   
                 19 "Foster parent/Child"
                 20 "Other non-relative"
                 99 "self" ;

#delimit cr

label values relationship arel

// Peek at the labels and values
fre relationship
fre relationship if to_num < 100

save "$tempdir/relationship_pairs_bymonth.dta", replace
