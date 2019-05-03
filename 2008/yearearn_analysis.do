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
gen uratio=year_upearn/year_uhearn

gen catratio=int(ratio*10) if ratio >= 0 & ratio <= 1
replace catratio=-1 if ratio < 0
replace catratio=20 if ratio > 1

*sort year

sum yearbw50 yearbw60 uyearbw50 uyearbw60 if ageoldest >=0 & ageoldest <=17

*******************************************************************************
* calculate cumulative risk of breadwinning 
*******************************************************************************

rename ybecome_bw50 becbw50
rename ybecome_bw60 becbw60
rename uybecome_bw50 ubecbw50
rename uybecome_bw60 ubecbw60

local transition "becbw50 becbw60 ubecbw50 ubecbw60"

foreach var in `transition'{
	forvalues a=0/17{
		egen `var'`a'=mean(`var') if ageoldest==`a' & `var' !=2
		tab `var'`a'
	}
}

foreach var in `transition'{
	gen e`var'=1-`var'0
}

tab ebecbw50
replace ebecbw50=becbw50*1-becbw501
tab ebecbw50
replace ebecbw50=becbw50*1-becbw502
tab ebecbw50
replace ebecbw50=becbw50*1-becbw503
tab ebecbw50

/*

	forvalues a=1/17{
		tab `var'`a'
		replace e`var'=(e`var')*(1-`var'`a')
	}
	tab e`var'
}
sort yearspartner

by yearspartner: sum year_pearn year_hearn year_pHHearn [aweight=weight], detail

tab yearspartner yearbw50 [aweight=weight], nofreq row

tab yearspartner yearbw60 [aweight=weight], nofreq row

tab yearage yearbw60 [aweight=weight], nofreq row

tab yearage yearbw60 if yearspartner==1 [aweight=weight], nofreq row

tab yearage yearbw60 if yearspartner==0 [aweight=weight], nofreq row

