use "$SIPP14keep/HHComp_asis.dta", clear

gen biochildren=1 if relationship==4
gen minorchildren=1 if inlist(relationship, 4, 6, 8) & to_age < 18
gen minorbiochildren=1 if relationship==4 & to_age < 18

gen childage=to_age if biochildren==1 

gen spouse=1 if relationship==1
gen partner=1 if relationship==2

gen numtype2=1 if pairtype==2

gen hhsize=1

collapse (count) minorchildren minorbiochildren spouse partner hhsize numtype2 (min) youngest_age=childage (max) oldest_age=childage, by(SSUID PNUM panelmonth)

save "$tempdir/hhcomp.dta", replace

sum youngest_age
sum oldest_age

