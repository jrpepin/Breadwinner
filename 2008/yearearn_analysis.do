use "$tempdir/relearn_year.dta", clear

* select if started observation a mother or became a mother during observation window

tab nobsmomminor

keep if nobsmomminor > 0 

gen year_pHHearn=year_pearn/year_hearn if !missing(year_pearn) & !missing(year_hearn) & year_pearn > 0 & year_hearn > 0
replace year_pearn=0 if !missing(year_pearn) & !missing(year_hearn) & year_pearn < 0 & year_hearn > 0
replace year_pHHearn=. if year_pearn > year_hearn

gen year_upHHearn=year_upearn/year_uhearn if !missing(year_upearn) & !missing(year_uhearn) & year_upearn > 0 & year_uhearn > 0
replace year_upearn=0 if !missing(year_upearn) & !missing(year_uhearn) & year_upearn < 0 & year_uhearn > 0
replace year_upHHearn=. if year_upearn > year_uhearn

sort yearspartner

by yearspartner: sum year_pearn year_hearn year_pHHearn [aweight=weight], detail

tab yearspartner yearbw50 [aweight=weight], nofreq row

tab yearspartner yearbw60 [aweight=weight], nofreq row

tab yearage yearbw60 [aweight=weight], nofreq row

tab yearage yearbw60 if yearspartner==1 [aweight=weight], nofreq row

tab yearage yearbw60 if yearspartner==0 [aweight=weight], nofreq row

tab yearage ybecome_bw50, nofreq row

sort yearspartner

by yearspartner: tab yearage ybecome_bw50, nofreq row

tab ageoldest yearbw50 [aweight=weight] if ageoldest <=10, nofreq row 
tab ageoldest yearbw60 [aweight=weight] if ageoldest <=10, nofreq row

tab ageoldest uyearbw50 [aweight=weight] if ageoldest <=10, nofreq row 
tab ageoldest uyearbw60 [aweight=weight] if ageoldest <=10, nofreq row
