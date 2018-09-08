*******************************************************************************
* merge earnings and income data to hh_change data files
*******************************************************************************

* Note that this file is created using code from the childhh project.
* run do_childrens_household_core
use "$tempdir/HHcomp.dta", clear

* Create a dummy indicator for whether ego is a mother to anyone in the household
* by collapsing all records for same person (ssuid epppnum swave)


gen nmomto=1 if inlist(unified_rel,2,5,8)
replace nmomto=1 if my_sex==2 & inlist(unified_rel,22,23)

gen nbiomomto=1 if unified_rel==2

gen nHHkids=1 if adj_age < 18

gen HHsize=1

gen spartner=1 if inlist(unified_rel,12,18)

collapse (count) nmomto nbiomomto HHsize nHHkids spartner, by(SSUID EPPPNUM SWAVE)

recode spartner (0=0)(1/20=1)

tab spartner, m

keep SSUID EPPPNUM SWAVE nmomto nbiomomto HHsize nHHkids spartner

merge SSUID EPPPNUM SWAVE using "$tempdir/hh_change.dta"

keep if !missing(ERRP)

rename SSUID ssuid
rename EPPPNUM epppnum
rename SWAVE swave

drop _merge

sort ssuid epppnum swave

merge 1:1 ssuid epppnum swave using "$SIPP2008/IncomeAndEarnings/sipp08tpearn_all"

tab nmomto

gen pHHearn=tpearn/thearn if !missing(tpearn) & !missing(thearn) & tpearn > 0 & thearn > 0
replace tpearn=0 if !missing(tpearn) & !missing(thearn) & tpearn < 0 & thearn > 0
replace pHHearn=. if tpearn > thearn

gen momtoany=0 if nmomto==0
replace momtoany=1 if nmomto > 0 & !missing(nmomto)

gen nHHadults=HHsize-nHHkids

sum nHHadults

gen onlyadult=0
replace onlyadult=1 if nHHadults==1

gen solomom=0
replace solomom=1 if onlyadult==1 & momtoany==1

keep if adj_age > 18 & adj_age < 70
keep if my_sex==2

save "$tempdir/relearn.dta", replace
