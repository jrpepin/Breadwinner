*********************************************
* relative earnings analysis
*******************************************

*relearn stands for relative earnings (not re-learn)
log using "$logdir/relearn_analysis.log", $replace

use "$tempdir/relearn.dta", clear

tab adj_age momtoany

tab adj_age spartner if momtoany==1

sort momtoany onlyadult

by momtoany onlyadult: sum pHHearn

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
