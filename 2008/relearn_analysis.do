*********************************************
* relative earnings analysis
*******************************************

log using "$logdir/relearn_analsis.log", $replace

use "$tempdir/relearn.dta", clear

tab adj_age momtoany

tab adj_age spartner if momtoany==1

sort momtoany onlyadult

by momtoany onlyadult: sum pHHearn

table adj_age, c(mean pHHearn)

keep if momtoany==1

table adj_age, c(mean pHHearn)


preserve

keep if momtoany==1 & spartner==1

table adj_age, c(mean pHHearn)


restore

keep if momtoany==1 & spartner==0

table adj_age, c(mean pHHearn)




log close
