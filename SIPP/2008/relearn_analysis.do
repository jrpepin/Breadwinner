*********************************************
* relative earnings analysis
*******************************************

*relearn stands for relative earnings (not re-learn)

use "$tempdir/relearn.dta", clear

tab momtoanyminor spartner, nofreq row col

drop if thearn < 0

gen ratio=tpearn/thearn

sum bw50 tpearn thearn ratio if ageoldest > 0 & ageoldest < 18, detail


/*
sum tpearn thearn pHHearn, detail

sum tpearn thearn pHHearn if momtoanyminor==1, detail

sort spartner

by spartner: sum tpearn thearn pHHearn if momtoanyminor==1, detail

tab spartner bw50 if momtoanyminor==1, nofreq row
tab spartner bw60 if momtoanyminor==1, nofreq row

tab adj_age momtoanyminor

tab adj_age momtoanyminor if spartner==1

keep if momtoanyminor==1

tab adj_age bw50, nofreq row

tab adj_age bw60, nofreq row

tab adj_age bw50 if spartner==1, nofreq row

tab adj_age bw60 if spartner==1, nofreq row

tab adj_age bw50 if spartner==0, nofreq row

tab adj_age bw60 if spartner==0, nofreq row

/*

sum adj_age

tab adj_age spartner if momtoany==1



table adj_age, c(mean pHHearn)

keep if momtoany==1

table adj_age, c(mean pHHearn)

// Count number of mothers
preserve
collapse adj_age, by(ssuid)
count if adj_age <=65
restore

preserve

keep if momtoany==1 & spartner==1

table adj_age, c(mean pHHearn)

restore

preserve
keep if momtoany==1 & spartner==0

table adj_age, c(mean pHHearn)

restore

* Dummy indicators of breadwinning status

tab adj_age bw50, nofreq row

tab adj_age bw60, nofreq row

tab adj_age bw50 if spartner==1, nofreq row

tab adj_age bw60 if spartner==1, nofreq row

tab adj_age bw50 if spartner==0, nofreq row

tab adj_age bw60 if spartner==0, nofreq row

log close
