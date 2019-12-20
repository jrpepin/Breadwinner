***
*
* USE RREL and RRELPUM variables to describe each person's relationship to every other person in the household by month
* 
* The RREL variables RREL1-RREL20 are for type 1 persons and RREL21-RREL30 are for type 2 persons

* Create a file with demographic information on type 2 people because it isn't in allpairs

use "$SIPP14keep/allmonths14_type2.dta", clear

keep SSUID ERESIDENCEID panelmonth PNUM ET2_LNO* ET2_SEX* TT2_AGE* TAGE

reshape long ET2_LNO ET2_SEX TT2_AGE, i(SSUID ERESIDENCEID panelmonth PNUM) j(lno)

rename PNUM from_num
rename TAGE from_age
rename ET2_LNO to_num
rename ET2_SEX to_sex
rename TT2_AGE to_age

drop if missing(to_num)

save "$tempdir/type2_pairs.dta", $replace

use "$SIPP14keep/allmonths14.dta", clear

keep SSUID ERESIDENCEID PNUM RREL* RREL_PNUM* panelmonth

reshape long RREL_PNUM RREL,i(SSUID ERESIDENCEID PNUM panelmonth) j(lno) 

keep if RREL !=99 & !missing(RREL) // don't keep relationship to self or empty lines

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

tab RREL, m

rename PNUM from_num
rename RREL_PNUM to_num

save "$tempdir/rel_pairs_bymonth", $replace

merge 1:1 SSUID ERESIDENCEID panelmonth from_num to_num using "$tempdir/allpairs"
* all in rel_pairs are matched in allpairs, but not vice versa.
* This is because type 2 people don't have observations in allpairs

keep if _merge==3

drop _merge
gen pairtype=1

save "$tempdir/t1.dta", $replace

use "$tempdir/rel_pairs_bymonth", clear

* We need to add type 2 people's demographic information
merge 1:1 SSUID ERESIDENCEID panelmonth from_num to_num using "$tempdir/type2_pairs"

keep if _merge==3

drop _merge
gen pairtype=2

append using "$tempdir/t1.dta"

label variable pairtype "Is the to person a type 1 or type 2 individual?"

tab from_age pairtype

recode RREL (1=1)(2=2)(3=1)(4=2)(5/19=.), gen(relationship) 
replace relationship=RREL+2 if RREL >=9 & RREL <=13 // bump rarer codes up to make room for common ones
replace relationship=16 if RREL==14 | RREL==15 // combine in-law categories
replace relationship=RREL+1 if RREL >=16 & RREL <=19 // bump rarer codes up to make room for common ones
replace relationship=3 if RREL==5 & to_age > from_age // parents must be older than children
replace relationship=4 if RREL==5 & to_age < from_age
replace relationship=5 if RREL==6 & to_age > from_age // Step
replace relationship=6 if RREL==6 & to_age < from_age // There are a small number of cases where ages are equal
replace relationship=7 if RREL==7 & to_age > from_age // Adoptive
replace relationship=8 if RREL==7 & to_age < from_age // There are a small number of cases where ages are equal
replace relationship=9 if RREL==8 & to_age > from_age // Grand
replace relationship=10 if RREL==8 & to_age < from_age

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

tab relationship, m
tab relationship if to_num < 100


save "$tempdir/relationship_pairs_bymonth", $replace
