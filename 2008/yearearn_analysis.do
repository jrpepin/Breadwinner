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

keep if ageoldest < 19

rename ybecome_bw50 becbw50
rename ybecome_bw60 becbw60
rename uybecome_bw50 ubecbw50
rename uybecome_bw60 ubecbw60

tab yearbw50 uyearbw50, m

tab becbw50 ubecbw50, m

*In any given year -- that is, in the cross-section -- the percentage breadwinning is higher with the actual reports and with allocated data and reports.
*But they are less likely to transition into breadwinning with unallocated data. This suggests that the data allocations are introducing random error and
*creating artificial instability. I do not think we should limit the analysis to measuring using only unallocated data.

tab ageoldest ubecbw50 if inlist(ubecbw50,0,1), nofreq row 
tab ageoldest ubecbw60 if inlist(ubecbw50,0,1), nofreq row 

local transition "ubecbw50 ubecbw60"


*Create dummy indicators for whether woman entered breadwinning between year when oldest child
* is aged a and aged a+1. Note that by limiting analysis to `var' = 0 or 1 (ie. !=2), we are in essence
* dropping cases that were breadwinning in year 1.
* We haven't yet dropped cases that were ever previously observed breadwinning.
* That would probably be best calculated back where we create ybecome_bw50 in create_yearearn.do

preserve

foreach var in `transition'{
	forvalues a=0/17{
		quietly egen `var'`a'=mean(`var') if ageoldest==`a' & `var' !=2
		tab `var'`a'
	}
}

collapse (max) ubecbw50* ubecbw60*

foreach var in `transition'{
	quietly gen e`var'=1-`var'0
	forvalues a=1/17{
		quietly replace e`var'=(e`var')*(1-`var'`a')
	}
	tab e`var'
}

restore
preserve

keep if my_race==1

foreach var in `transition'{
	forvalues a=0/17{
		quietly egen `var'`a'=mean(`var') if ageoldest==`a' & `var' !=2
		tab `var'`a'
	}
}

collapse (max) ubecbw50* ubecbw60* 

foreach var in `transition'{
	quietly gen e`var'=1-`var'0
	forvalues a=1/17{
		quietly replace e`var'=(e`var')*(1-`var'`a')
	}
	tab e`var'
}

restore
preserve

keep if my_race==2

foreach var in `transition'{
	forvalues a=0/17{
		quietly egen `var'`a'=mean(`var') if ageoldest==`a' & `var' !=2
		tab `var'`a'
	}
}

collapse (max) ubecbw50* ubecbw60* 

foreach var in `transition'{
	quietly gen e`var'=1-`var'0
	forvalues a=1/17{
		quietly replace e`var'=(e`var')*(1-`var'`a')
	}
	tab e`var'
}

restore
preserve

keep if my_race==3

foreach var in `transition'{
	forvalues a=0/17{
		quietly egen `var'`a'=mean(`var') if ageoldest==`a' & `var' !=2
		tab `var'`a'
	}
}

collapse (max) ubecbw50* ubecbw60* 

foreach var in `transition'{
	quietly gen e`var'=1-`var'0
	forvalues a=1/17{
		quietly replace e`var'=(e`var')*(1-`var'`a')
	}
	tab e`var'
}

restore
preserve

keep if my_race==4

foreach var in `transition'{
	forvalues a=0/17{
		quietly egen `var'`a'=mean(`var') if ageoldest==`a' & `var' !=2
		tab `var'`a'
	}
}

collapse (max) ubecbw50* ubecbw60* 

foreach var in `transition'{
	quietly gen e`var'=1-`var'0
	forvalues a=1/17{
		quietly replace e`var'=(e`var')*(1-`var'`a')
	}
	tab e`var'
}



/*

sort yearspartner

by yearspartner: sum year_pearn year_hearn year_pHHearn [aweight=weight], detail

tab yearspartner yearbw50 [aweight=weight], nofreq row

tab yearspartner yearbw60 [aweight=weight], nofreq row

tab yearage yearbw60 [aweight=weight], nofreq row

tab yearage yearbw60 if yearspartner==1 [aweight=weight], nofreq row

tab yearage yearbw60 if yearspartner==0 [aweight=weight], nofreq row

*
*
*
*
*Percent never breadwinning in first 18 years of motherhood (50%, 60%)
*
*Total .22 .27
*
* Non-Hispanic White .24 .30
* Black .13 .14
* Non-black Hispanic .18 .23
* Asian .32 .36

* Want estimates by educational attainment and marital status at first birth

