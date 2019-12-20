/*
* First execute a series of scripts adapted from the childhh project
* to develop measures of household composition

     log using "$logdir/extract_and_format.log", replace
     do "$projcode/2014/extract_and_format.do"
     log close

     log using "$logdir/merge_waves.log", replace
     do "$projcode/2014/merge_waves.do"
     log close

     log using "$logdir/allpairs.log", replace
     do "$projcode/2014/allpairs.do"
     log close

     log using "$logdir/compute_relationships.log", replace
     do "$projcode/2014/compute_relationships.do"
     log close


     log using "$logdir/create_HHComp_asis.log", replace
     do "$projcode/2014/create_HHComp_asis.do"
     log close
*/
*Execute breadwinner scripts

log using "$logdir/extract_earnings.log", replace
do "$projcode/2014/extract_earnings.do"
log close

log using "$logdir/create_hhcomp.log", replace
do "$projcode/2014/create_hhcomp.do"
log close

