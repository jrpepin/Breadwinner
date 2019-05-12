*need to add n's to results table

use "$tempdir/relearn_year.dta", clear

* select if started observation a mother or became a mother during observation window
keep if nobsmomminor > 0 

gen negpinc=1 if year_pearn < 0
gen neghinc=1 if year_hearn < 0

* drop cases with negative household income
drop if neghinc==1

* calculate year of first birth with both wave 2 and household roster data

gen yearb1=.
gen year=2008 if y==1
forvalues y=1/5{
	replace yearb1=2007+`y'-ageoldest if y==`y'
	replace year=2007+`y' if y==`y'
}

* firstbirth based on transitioning into household with minor child
* not really sure why ageoldest didn't work.
replace yearb1=2009 if missing(yearb1) & firstbirth >=2 & firstbirth <=4
replace yearb1=2010 if missing(yearb1) & firstbirth >=5 & firstbirth <=7
replace yearb1=2011 if missing(yearb1) & firstbirth >=8 & firstbirth <=10
replace yearb1=2012 if missing(yearb1) & firstbirth >=11 & firstbirth <=13
replace yearb1=2013 if missing(yearb1) & firstbirth >=14 & firstbirth <=15

egen yearbir1=min(yearb1), by(ssuid epppnum)

gen durmom=year-tfbrthyr+1 if tfbrthyr > 1900
replace durmom=year-yearbir1+1 if missing(durmom)

drop if durmom < 0

gen ageb1=yearage-durmom
recode ageb1 (0/17=1)(18/22=2)(23/29=3)(30/56=4), gen(agebir1)
*******************************************************************************
* calculate cumulative risk of breadwinning 
*******************************************************************************

putexcel set "$results/LifetimeBreadwin.xlsx", sheet(byAge5) modify
putexcel A1="Estimates of Breadwinning in first 5 years of Motherhood"
putexcel B2=("All Years") F2=("Year 4 to 5")
putexcel B3=("50%") D3=("60%") F3=("50%") H3=("60%") J3=("n")
putexcel A4=("Total")

keep if durmom < 5 

*In any given year -- that is, in the cross-section -- the percentage breadwinning is higher with the actual reports and with allocated data and reports.
*But they are less likely to transition into breadwinning with unallocated data. This suggests that the data allocations are introducing random error and
*creating artificial instability. We should limit the analysis to measuring using only unallocated data.

tab durmom ubecbw50 if inlist(ubecbw50,0,1), nofreq row 
tab durmom ubecbw60 if inlist(ubecbw50,0,1), nofreq row 

*Create dummy indicators for whether woman entered breadwinning between year when oldest child
* is aged a and aged a+1. Note that by limiting analysis to `var' = 0 or 1 (ie. !=2), we are in essence
* dropping cases that were breadwinning in year 1.
* We haven't yet dropped cases that were ever previously observed breadwinning.
* That would probably be best calculated back where we create ybecome_bw50 in create_yearearn.do

preserve

local transition "ubecbw50 ubecbw60"

gen ubw50atbir=uyearbw50 if durmom==0
gen ubw60atbir=uyearbw60 if durmom==0
	
foreach var in `transition'{
	forvalues a=0/4{
		quietly egen `var'`a'=mean(`var') if durmom==`a' & `var' !=2
		tab `var'`a'
	}
}

collapse (max) ubecbw50* ubecbw60* (mean) ubw50atbir ubw60atbir

gen eubecbw50=1-ubw50atbir
gen eubecbw60=1-ubw60atbir  

foreach var in `transition'{
	forvalues a=0/4{
		replace e`var'=(e`var')*(1-`var'`a')
	}
	tab e`var'
}

local bw50=eubecbw50
local bw60=eubecbw60

putexcel B4=(1-`bw50') D4=(1-`bw60')

restore
preserve

keep if y==4

local transition "ubecbw50 ubecbw60"

gen ubw50atbir=uyearbw50 if durmom==0
gen ubw60atbir=uyearbw60 if durmom==0
	
foreach var in `transition'{
	forvalues a=0/4{
		quietly egen `var'`a'=mean(`var') if durmom==`a' & `var' !=2
		tab `var'`a'
	}
}

collapse (max) ubecbw50* ubecbw60* (mean) ubw50atbir ubw60atbir

gen eubecbw50=1-ubw50atbir
gen eubecbw60=1-ubw60atbir  

foreach var in `transition'{
	forvalues a=0/4{
		replace e`var'=(e`var')*(1-`var'`a')
	}
	tab e`var'
}

local bw50=eubecbw50
local bw60=eubecbw60

putexcel F4=(1-`bw50') H4=(1-`bw60')

restore
preserve

tab durmom

putexcel set "$results/LifetimeBreadwin.xlsx", sheet(Table 2) modify
putexcel A1="Table 2: Estimates of Breadwinning in first 5 years of Motherhood" 
putexcel B2=("Panel A: Unadjusted")
putexcel B3=("n's") F3=("rates")
putexcel B4=("Not") C4=("Breadwinning") D4=("already bw") G4=("not enter bw") H4=("cumulative survival")
putexcel A5="1st Birth" 
tab uyearbw50 if durmom==0, matcell(atbir50)
putexcel B24=matrix(atbir50)
putexcel B5=formula(B24)
putexcel C5=formula(B25)
putexcel F5=formula(B25/(B24+B25))
tab durmom ubecbw50, matcell(trans50)
putexcel B6=matrix(trans50)

keep if y==4

putexcel set "$results/LifetimeBreadwin.xlsx", sheet(Table 2) modify
putexcel B11=("Panel B: Only Transitions Year 4 to 5")
putexcel B12=("Not") C12=("Breadwinning") D12=("already bw") G12=("not enter bw") H12=("cumulative survival")
putexcel A13="1st Birth" 
tab durmom ubecbw50, m
tab uyearbw50 if durmom==0, matcell(atbir50)
putexcel B27=matrix(atbir50)
putexcel B13=formula(B27)
putexcel C13=formula(B28)
putexcel F13=formula(B28/(B27+B28))
tab durmom ubecbw50, matcell(trans50)
putexcel B14=matrix(trans50)


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

