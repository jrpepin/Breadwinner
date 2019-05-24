do "$projcode/extract_earnings.do"
do "$projcode/refine_monthly.do"
do "$projcode/create_relearn.do"
do "$projcode/create_yearearn.do"
do "$projcode/yearearn_analysis.do"
do "$projcode/byage5_analysis.do"
do "$projcode/yearearny4_analysis.do"

do "$projcode/msltprep.do"
do "$projcode/create_mstransitions.do"
dyndoc "$projcode/gen_mslt_results.do", replace
