*******************************************************************************
* merge earnings and income data to hh_change data files
*******************************************************************************

* Note that this file is created using code from the childhh project.
* run do_childrens_household_core
use "$tempdir/HHcomp.dta", clear

* Create a dummy indicator for whether ego is a mother to anyone in the household
* by collapsing all records for same person (ssuid epppnum swave)

gen anymom=0
replace anymom=1 if inlist(unified_rel,2,5,8)
replace anymom=1 if my_sex==2 & inlist(unified_rel,22,23)

gen biomom=0
replace biomom=1 if unified_rel==2

gen nkids=0
replace nkids=1 if adj_age < 18

gen hhsize=1

collapse (count) anymom biomom hhsize nkids, by(SSUID EPPPNUM SWAVE)

keep SSUID EPPPNUM SWAVE anymom biomom hhsize nkids

merge SSUID EPPPNUM SWAVE using "$tempdir/hh_change.dta"

rename SSUID ssuid
rename EPPPNUM epppnum
rename SWAVE swave

drop _merge

tab adj_age anymom

merge ssuid epppnum swave using "$SIPP2008/IncomeAndEarnings/sipp08tpearn_all"

gen pHHearn=tpearn/thearn

sort anymom

by anymom: sum pHHearn

keep if anymom==1

sort adj_age
by adj_age: sum pHHearn

