use "$SIPP14keep/sipp14tpearn_all", clear

* create year of first birth from fertility history
gen yfb=9999
forvalues b=1/20 {
    replace yfb=tcbyr_`b' if tcbyr_`b' < yfb
}

merge 1:1 SSUID PNUM panelmonth using "$tempdir/hhcomp.dta"

********************************************
* measures of breadwinning
*******************************************

gen ratio=tpearn/thearn

gen bw50= (ratio > .5) if ~missing(ratio)
gen bw60= (ratio > .6) if ~missing(ratio)

keep if esex==2 & minorchildren > 0

save "$SIPP14keep/breadwinning14.dta"

sum ratio

tab bw50
tab bw60

tab yfb
tab oldest_age
tab youngest_age
