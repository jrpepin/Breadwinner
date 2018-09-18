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
use "$tempdir/HHcomp.dta", clear

* Create a dummy indicator for whether ego is a mother to anyone in the household
* by collapsing all records for same person (ssuid epppnum swave)

* 2, 5, and 8 are bio, step, and adoptive mom respectively
* 22 and 23 are parent codes
gen nmomto=1 if inlist(unified_rel,2,5,8)
replace nmomto=1 if my_sex==2 & inlist(unified_rel,22,23)

gen nmomtominor=1 if inlist(unified_rel,2,5,8) & to_age < 18
replace nmomtominor=1 if my_sex==2 & inlist(unified_rel,22,23) & to_age < 18

gen nbiomomto=1 if unified_rel==2

* Create indicators for other aspects of household composition
gen nHHkids=1 if adj_age < 18

gen HHsize=1

* spouse or partner
gen spartner=1 if inlist(unified_rel,12,18)

* collapse across all people in ego's (EPPPNUM's) household to create a person-level file
* with information on that person's household composition in the wave.
collapse (count) nmomto nmomtominor nbiomomto HHsize nHHkids spartner, by(SSUID EPPPNUM SWAVE)

* some have more than one person in the household coded as spouse or partner. 
recode spartner (0=0)(1/20=1)

tab spartner, m

* add in self as a household member.
replace HHsize=HHsize+1

replace nHHkids=nHHkids+1 if adj_age < 18

keep SSUID EPPPNUM SWAVE nmomto nmomtominor nbiomomto HHsize nHHkids spartner

*******************************************************************************
* Section: merging to children's households long demographic file, 
* a person-level data file, to get basic demographic information about ego.
*******************************************************************************
merge 1:1 SSUID EPPPNUM SWAVE using "$tempdir/demo_long_interviews.dta"

keep if !missing(ERRP)

rename SSUID ssuid
rename EPPPNUM epppnum
rename SWAVE swave

* fixing records living alone
replace HHsize=1 if missing(HHsize)
replace nHHkids=0 if missing(nHHkids) & adj_age > 17
replace nHHkids=1 if missing(nHHkids) & adj_age < 18
replace nmomto=0 if missing(nmomto)
replace nmomtominor=0 if missing(nmomtominor)
replace nbiomomto=0 if missing(nbiomomto)

drop _merge

sort ssuid epppnum swave

* merging in a person-level data file with personal earnings and household earnings.
merge 1:1 ssuid epppnum swave using "$SIPP2008/IncomeAndEarnings/sipp08tpearn_all"

tab nmomto

gen pHHearn=tpearn/thearn if !missing(tpearn) & !missing(thearn) & tpearn > 0 & thearn > 0
replace tpearn=0 if !missing(tpearn) & !missing(thearn) & tpearn < 0 & thearn > 0
replace pHHearn=. if tpearn > thearn

gen momtoany=0 if nmomto==0
replace momtoany=1 if nmomto > 0 & !missing(nmomto)

gen momtoanyminor=0 if nmomtominor==0
replace momtoanyminor=1 if nmomtominor > 0 & !missing(nmomtominor)

gen nHHadults=HHsize-nHHkids

sum nHHadults

gen bw50=1 if pHHearn > .5 & !missing(pHHearn)
replace bw50=0 if pHHearn <=.5 & !missing(pHHearn)

gen bw60=1 if pHHearn > .6 & !missing(pHHearn)
replace bw60=0 if pHHearn <=.6 & !missing(pHHearn)

keep if adj_age >= 18 & adj_age < 70
keep if my_sex==2

save "$tempdir/relearn.dta", replace


