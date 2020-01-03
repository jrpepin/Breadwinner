/*
* First execute a series of scripts adapted from the childhh project
* to develop measures of household composition

     log using "$logdir/extract_and_format.log", replace
     do "$projcode/extract_and_format.do"
     log close

     log using "$logdir/merge_waves.log", replace
     do "$projcode/merge_waves.do"
     log close

     log using "$logdir/allpairs.log", replace
     do "$projcode/allpairs.do"
     log close

     log using "$logdir/compute_relationships.log", replace
     do "$projcode/compute_relationships.do"
     log close


     log using "$logdir/create_HHComp_asis.log", replace
     do "$projcode/create_HHComp_asis.do"
     log close
*/
*Execute breadwinner scripts

* a monthly file with earnings and other information on individuals
log using "$logdir/extract_earnings.log", replace
do "$projcode/extract_earnings.do"
log close

* a monthly file with just household composition, including number of type2 people
log using "$logdir/create_hhcomp.log", replace
do "$projcode/create_hhcomp.do"
log close

* merge files together and collapse to annual measures of breadwinning,
log using "$logdir/annualize.log", replace
do "$projcode/annualize.do"
log close

* create indicators of transitions into and out of breadwinning
log using "$logdir/bw_transitions.log", replace
do "$projcode/bw_transitions.do"
log close

* create a file describing sample and initial "lifetime" estimates of breadwinning.
dyndoc "$projcode/bw_analysis.md", replace
