use "$tempdir/relearn_year.dta", clear

* select if started observation a mother or became a mother during observation window
tab nobsmomminor

keep if nobsmomminor > 0 

gen negpinc=1 if year_pearn < 0
gen neghinc=1 if year_hearn < 0

tab negpinc
tab neghinc

* drop cases with negative household income
drop if neghinc==1

gen ratio=year_pearn/year_hearn

gen catratio=int(ratio*10) if ratio >= 0 & ratio <= 1
replace catratio=-1 if ratio < 0
replace catratio=20 if ratio > 1

*sort year

sum yearbw50 year_pearn year_hearn ratio if ageoldest >=0 & ageoldest <=17

tab catratio if ageoldest >=0 & ageoldest <=17

/*
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

tab ageoldest yearbw50 [aweight=weight] if ageoldest <=17, nofreq row 
tab ageoldest yearbw60 [aweight=weight] if ageoldest <=17, nofreq row

tab ageoldest uyearbw50 [aweight=weight] if ageoldest <=17, nofreq row 
tab ageoldest uyearbw60 [aweight=weight] if ageoldest <=17, nofreq row
