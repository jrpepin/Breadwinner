*******************************************************************************
*******************************************************************************
* Create Household Composition variables and merge earnings and income data to hh_change data files
*******************************************************************************
*******************************************************************************

********************************************************************************
* Create an extract with year of first birth and marital history
********************************************************************************
use "$SIPP2008/sippp08putm2", clear

keep ssuid epppnum tfmyear tfsyear tftyear tsmyear tssyear tstyear tlmyear tlsyear tltyear tfbrthyr exmar ewidiv1 ewidiv2 ems esex tmomchl tage

keep if esex==2

gen anybirth=0
replace anybirth=1 if tmomchl==1

gen yrmar1=tlmyear if exmar==1
replace yrmar1=tfmyear if exmar > 1
replace yrmar1=999 if exmar < 1

*gen yrmar1end=tlsyear if exmar==1 & tlsyear > 0
*replace yrmar1end=tltyear if exmar==1 & tltyear < tlsyear & tltyear > 0
*replace yrmar


gen msbirth=-1 if tage >= 65
replace msbirth=0 if ems==6 // never married
replace msbirth=0 if tfbrthyr < yrmar1 & tfbrthyr > 0 // birth happened before first marriage
replace msbirth=1 if tfbrthyr >= yrmar1 // birth happened after (or year of) first marriage
replace msbirth=9 if anybirth==0

destring epppnum, replace

save "$SIPP08keep/famhis.dta", $replace

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

* age of oldest son or daughter in the household
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

assert _merge==3

drop _merge

gen momtoany=0 if nmomto==0
replace momtoany=1 if nmomto > 0 & !missing(nmomto)

gen momtoanyminor=0 if nmomtominor==0
replace momtoanyminor=1 if nmomtominor > 0 & !missing(nmomtominor)

gen nHHadults=HHsize-nHHkids

sum nHHadults

keep if adj_age >= 18 & adj_age < 70
keep if my_sex==2

merge m:1 ssuid epppnum using "$SIPP08keep/famhis.dta"

drop if _merge ==2

* Those without msbirth because not matched in famhis were generally not observed in wave 2
rename _merge mergefam

save "$tempdir/relearn.dta", replace


