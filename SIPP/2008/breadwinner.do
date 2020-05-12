log using "$logdir/extract_earnings.log", replace
do "$projcode/extract_earnings.do"
log close

log using "$logdir/refine_monthly.log", replace
do "$projcode/refine_monthly.do"
log close

log using "$logdir/create_relearn.log", replace
do "$projcode/create_relearn.do"
log close

log using "$logdir/create_yearearn.log", replace
do "$projcode/create_yearearn.do"
log close

log using "$logdir/yearearn_analysis.log", replace
do "$projcode/yearearn_analysis.do"
log close

log using "$logdir/byage5_analysis.log", replace
do "$projcode/byage5_analysis.do"
log close

log using "$logdir/yearearny4.log", replace
do "$projcode/yearearny4_analysis.do"
log close

log using "$logdir/msltprep.log", replace
do "$projcode/msltprep.do"
log close

log using "$logdir/create_mstransitions.log", replace
do "$projcode/create_mstransitions.do"
log close

dyndoc "$projcode/gen_mslt_results.do", replace
