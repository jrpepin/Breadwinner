*******************************************************************************
*******************************************************************************
* Create Household Composition variables and merge earnings and income data to hh_change data files
*******************************************************************************
*******************************************************************************

*******************************************************************************
* Section: Create Household Composition variables
*******************************************************************************
*
* Note that this file is created using code from the childhh project.
* run do_childrens_household_core to create.
* The file has one observation per person in ego's (EPPPNUM's) household. 
* It does not include a record for self and thus does not include people living alone.
use "$childhh/HHComp_asis.dta", clear

* Create a dummy indicator for whether ego is a mother to anyone in the household
* by collapsing all records for same person (ssuid epppnum swave)

* 2, 5, and 8 are bio, step, and adoptive mom respectively
* 22 and 23 are parent codes, without info on specific type of relationship (or gender)
gen nmomto=1 if inlist(relationship,2,5,8)
replace nmomto=1 if my_sex==2 & inlist(relationship,22,23)

gen nmomtominor=1 if inlist(relationship,2,5,8) & to_age < 18
replace nmomtominor=1 if my_sex==2 & inlist(relationship,22,23) & to_age < 18

gen nbiomomto=1 if relationship==2

* Create indicators for other aspects of household composition
gen nHHkids=1 if adj_age < 18

gen HHsize=1

* age of youngest son or daughter in the household
gen agechild=to_age if inlist(relationship,2,3,8,22,23)

* spouse or partner
gen spartner=1 if inlist(relationship,12,18)

* collapse across all people in ego's (EPPPNUM's) household to create a person-level file
* with information on that person's household composition in the wave.
collapse (count) nmomto nmomtominor nbiomomto HHsize nHHkids spartner (max) agechild, by(SSUID EPPPNUM SWAVE)

rename agechild ageoldest
tab spartner, m
tab ageoldest


* some have more than one person in the household coded as spouse or partner. 
recode spartner (0=0)(1/20=1)

* add in self as a household member.
replace HHsize=HHsize+1

keep SSUID EPPPNUM SWAVE nmomto nmomtominor nbiomomto HHsize nHHkids spartner ageoldest

*******************************************************************************
* Section: merging to children's households long demographic file, 
* a person-level data file, to get basic demographic information about ego.
*******************************************************************************
merge 1:1 SSUID EPPPNUM SWAVE using "$childhh/demo_long_interviews.dta"

keep if !missing(ERRP)

rename SSUID ssuid
rename EPPPNUM epppnum
rename SWAVE swave

* adding self to count of household kids if self is < 18
replace nHHkids=nHHkids+1 if adj_age < 18

* fixing records living alone
replace HHsize=1 if missing(HHsize)
replace nHHkids=0 if missing(nHHkids) & adj_age > 17
replace nHHkids=1 if missing(nHHkids) & adj_age < 18
replace nmomto=0 if missing(nmomto)
replace nmomtominor=0 if missing(nmomtominor)
replace nbiomomto=0 if missing(nbiomomto)
replace spartner=0 if missing(spartner)

drop _merge

sort ssuid epppnum swave

* merging in a person-level data file with personal earnings and household earnings.
merge 1:1 ssuid epppnum swave using "$tempdir/altearn.dta"

gen momtoany=0 if nmomto==0
replace momtoany=1 if nmomto > 0 & !missing(nmomto)

gen momtoanyminor=0 if nmomtominor==0
replace momtoanyminor=1 if nmomtominor > 0 & !missing(nmomtominor)

gen nHHadults=HHsize-nHHkids

sum nHHadults

keep if adj_age >= 18 & adj_age < 70
keep if my_sex==2

save "$tempdir/relearn.dta", replace


