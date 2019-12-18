*need to add n's to results table

use "$tempdir/relearn_year.dta", clear

* select if started observation a mother or became a mother during observation window
keep if nobsmomminor > 0 

gen negpinc=1 if year_pearn < 0 // negative personal income
gen neghinc=1 if year_hearn < 0 // negative household income

* drop cases with negative household income
drop if neghinc==1

* calculate year of first birth with both wave 2 and household roster data

gen yearb1=.
gen year=2008
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
* Basic Descriptive Table 
*******************************************************************************

putexcel set "$results/LifetimeBreadwin.xlsx", sheet(Table 1) modify
putexcel A1="Table 1. Mothers' Earnings Relative to Household Earnings by Partnership Status at Start of Year"
putexcel B2=("All") C2=("Partnered") D2=("No Partner")
putexcel A3=("Personal Earnings(median)")
putexcel A4=("Household Earnings(median)")
putexcel A5=("Ratio")
putexcel A7=("% Breadwinning (> 50%)")
putexcel A8=("% Breadwinning(> 60%)")

* Total 
sum year_upearn, detail
local median_personal: di %9.0fc = r(p50)
putexcel B3=("`median_personal'")
sum year_uhearn, detail
local median_household: di %9.0fc = r(p50)
putexcel B4=("`median_household'")
sum ratio
local ratio: di %4.2f = r(mean)
putexcel B5=("`ratio'")

sum uyearbw50 if inlist(uyearbw50, 0, 1)
local mean50: di %4.1f = r(mean)*100
putexcel B7=("`mean50'")
sum uyearbw60 if inlist(uyearbw60, 0, 1)
local mean60: di %4.1f = r(mean)*100
putexcel B8=("`mean60'")

* Partnered

sum year_upearn if yearspartner==1, detail
local median_personal: di %9.0fc = r(p50)
putexcel C3=("`median_personal'")
sum year_uhearn if yearspartner==1, detail
local median_household: di %9.0fc = r(p50)
putexcel C4=("`median_household'")
sum ratio if yearspartner==1
local ratio: di %4.2f = r(mean)
putexcel C5=("`ratio'")

sum uyearbw50 if inlist(uyearbw50, 0, 1) & yearspartner==1
local mean50: di %4.1f = r(mean)*100
putexcel C7=("`mean50'")
sum uyearbw60 if inlist(uyearbw60, 0, 1) & yearspartner==1
local mean60: di %4.1f = r(mean)*100
putexcel C8=("`mean60'")

* Not Partnered

sum year_upearn if yearspartner==0, detail
local median_personal: di %9.0fc = r(p50)
putexcel D3=("`median_personal'")
sum year_uhearn if yearspartner==0, detail
local median_household: di %9.0fc = r(p50)
putexcel D4=("`median_household'")
sum ratio if yearspartner==0
local ratio: di %4.2f = r(mean)
putexcel D5=("`ratio'")

sum uyearbw50 if inlist(uyearbw50, 0, 1) & yearspartner==0
local mean50: di %4.1f = r(mean)*100
putexcel D7=("`mean50'")
sum uyearbw60 if inlist(uyearbw60, 0, 1) & yearspartner==0
local mean60: di %4.1f = r(mean)*100
putexcel D8=("`mean60'")

*******************************************************************************
* calculate cumulative risk of breadwinning 
*******************************************************************************

putexcel set "$results/LifetimeBreadwin.xlsx", sheet(Table 3) modify
putexcel A1="Table 3. Estimates of Breadwinning in first 18 years of Motherhood"
putexcel B2=("All years") F2=("Year 4 to 5")
putexcel B3=("50%") D3=("60%") F3=("50%") H3=("60%") J3=("n")
putexcel A4=("Total")
putexcel A5=("Race-Ethnicity")
putexcel A6=(" Non-Hispanic White")
putexcel A7=(" Black")
putexcel A8=(" Non-Black Hispanic")
putexcel A9=(" Asian")
putexcel A10=(" Other")
putexcel A12=("Educational Attainment")
putexcel A13=(" Less than High School")
putexcel A14=(" High School")
putexcel A15=(" Some College")
putexcel A16=(" College Grad")
putexcel A18=("Partnered")
putexcel A19=(" Not Partnered")
putexcel A20=(" Partnered")
putexcel A21=("Age at first birth")
putexcel A22=(" < 18")
putexcel A23=(" 19-22")
putexcel A24=(" 23-29")
putexcel A25=(" 30+")

keep if durmom < 18 

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
	forvalues a=0/17{
		quietly egen `var'`a'=mean(`var') if durmom==`a' & `var' !=2
		tab `var'`a'
	}
}

collapse (max) ubecbw50* ubecbw60* (mean) ubw50atbir ubw60atbir

gen eubecbw50=1-ubw50atbir
gen eubecbw60=1-ubw60atbir  

foreach var in `transition'{
	forvalues a=0/17{
		replace e`var'=(e`var')*(1-`var'`a')
	}
	tab e`var'
}

local bw50=eubecbw50
local bw60=eubecbw60

putexcel B4=(1-`bw50') D4=(1-`bw60')

restore
preserve

keep if my_race==1

local transition "ubecbw50 ubecbw60"

gen ubw50atbir=uyearbw50 if durmom==0
gen ubw60atbir=uyearbw60 if durmom==0
	
foreach var in `transition'{
	forvalues a=0/17{
		quietly egen `var'`a'=mean(`var') if durmom==`a' & `var' !=2
		tab `var'`a'
	}
}

collapse (max) ubecbw50* ubecbw60* (mean) ubw50atbir ubw60atbir

gen eubecbw50=1-ubw50atbir
gen eubecbw60=1-ubw60atbir  

foreach var in `transition'{
	forvalues a=0/17{
		replace e`var'=(e`var')*(1-`var'`a')
	}
	tab e`var'
}

local bw50=eubecbw50
local bw60=eubecbw60

putexcel B6=(1-`bw50') D6=(1-`bw60')

restore
preserve

keep if my_race==2

local transition "ubecbw50 ubecbw60"

gen ubw50atbir=uyearbw50 if durmom==0
gen ubw60atbir=uyearbw60 if durmom==0
	
foreach var in `transition'{
	forvalues a=0/17{
		quietly egen `var'`a'=mean(`var') if durmom==`a' & `var' !=2
		tab `var'`a'
	}
}

collapse (max) ubecbw50* ubecbw60* (mean) ubw50atbir ubw60atbir

gen eubecbw50=1-ubw50atbir
gen eubecbw60=1-ubw60atbir  

foreach var in `transition'{
	forvalues a=0/17{
		replace e`var'=(e`var')*(1-`var'`a')
	}
	tab e`var'
}

local bw50=eubecbw50
local bw60=eubecbw60

putexcel B7=(1-`bw50') D7=(1-`bw60')

restore
preserve

keep if my_race==3

local transition "ubecbw50 ubecbw60"

gen ubw50atbir=uyearbw50 if durmom==0
gen ubw60atbir=uyearbw60 if durmom==0
	
foreach var in `transition'{
	forvalues a=0/17{
		quietly egen `var'`a'=mean(`var') if durmom==`a' & `var' !=2
		tab `var'`a'
	}
}

collapse (max) ubecbw50* ubecbw60* (mean) ubw50atbir ubw60atbir

gen eubecbw50=1-ubw50atbir
gen eubecbw60=1-ubw60atbir  

foreach var in `transition'{
	forvalues a=0/17{
		replace e`var'=(e`var')*(1-`var'`a')
	}
	tab e`var'
}

local bw50=eubecbw50
local bw60=eubecbw60

putexcel B8=(1-`bw50') D8=(1-`bw60')

restore
preserve

keep if my_race==4

local transition "ubecbw50 ubecbw60"

gen ubw50atbir=uyearbw50 if durmom==0
gen ubw60atbir=uyearbw60 if durmom==0
	
foreach var in `transition'{
	forvalues a=0/17{
		quietly egen `var'`a'=mean(`var') if durmom==`a' & `var' !=2
		tab `var'`a'
	}
}

collapse (max) ubecbw50* ubecbw60* (mean) ubw50atbir ubw60atbir

gen eubecbw50=1-ubw50atbir
gen eubecbw60=1-ubw60atbir  

foreach var in `transition'{
	forvalues a=0/17{
		replace e`var'=(e`var')*(1-`var'`a')
	}
	tab e`var'
}

local bw50=eubecbw50
local bw60=eubecbw60

putexcel B9=(1-`bw50') D9=(1-`bw60')

restore
preserve

keep if my_race==5

local transition "ubecbw50 ubecbw60"

gen ubw50atbir=uyearbw50 if durmom==0
gen ubw60atbir=uyearbw60 if durmom==0
	
foreach var in `transition'{
	forvalues a=0/17{
		quietly egen `var'`a'=mean(`var') if durmom==`a' & `var' !=2
		tab `var'`a'
	}
}

collapse (max) ubecbw50* ubecbw60* (mean) ubw50atbir ubw60atbir

gen eubecbw50=1-ubw50atbir
gen eubecbw60=1-ubw60atbir  

foreach var in `transition'{
	forvalues a=0/17{
		replace e`var'=(e`var')*(1-`var'`a')
	}
	tab e`var'
}

local bw50=eubecbw50
local bw60=eubecbw60

putexcel B10=(1-`bw50') D10=(1-`bw60')

restore
preserve

keep if hieduc==1

local transition "ubecbw50 ubecbw60"

gen ubw50atbir=uyearbw50 if durmom==0
gen ubw60atbir=uyearbw60 if durmom==0
	
foreach var in `transition'{
	forvalues a=0/17{
		quietly egen `var'`a'=mean(`var') if durmom==`a' & `var' !=2
		tab `var'`a'
	}
}

collapse (max) ubecbw50* ubecbw60* (mean) ubw50atbir ubw60atbir

gen eubecbw50=1-ubw50atbir
gen eubecbw60=1-ubw60atbir  

foreach var in `transition'{
	forvalues a=0/17{
		replace e`var'=(e`var')*(1-`var'`a')
	}
	tab e`var'
}

local bw50=eubecbw50
local bw60=eubecbw60

putexcel B13=(1-`bw50') D13=(1-`bw60')

restore
preserve

keep if hieduc==2

local transition "ubecbw50 ubecbw60"

gen ubw50atbir=uyearbw50 if durmom==0
gen ubw60atbir=uyearbw60 if durmom==0
	
foreach var in `transition'{
	forvalues a=0/17{
		quietly egen `var'`a'=mean(`var') if durmom==`a' & `var' !=2
		tab `var'`a'
	}
}

collapse (max) ubecbw50* ubecbw60* (mean) ubw50atbir ubw60atbir

gen eubecbw50=1-ubw50atbir
gen eubecbw60=1-ubw60atbir  

foreach var in `transition'{
	forvalues a=0/17{
		replace e`var'=(e`var')*(1-`var'`a')
	}
	tab e`var'
}

local bw50=eubecbw50
local bw60=eubecbw60

putexcel B14=(1-`bw50') D14=(1-`bw60')

restore
preserve

keep if hieduc==3

local transition "ubecbw50 ubecbw60"

gen ubw50atbir=uyearbw50 if durmom==0
gen ubw60atbir=uyearbw60 if durmom==0
	
foreach var in `transition'{
	forvalues a=0/17{
		quietly egen `var'`a'=mean(`var') if durmom==`a' & `var' !=2
		tab `var'`a'
	}
}

collapse (max) ubecbw50* ubecbw60* (mean) ubw50atbir ubw60atbir

gen eubecbw50=1-ubw50atbir
gen eubecbw60=1-ubw60atbir  

foreach var in `transition'{
	forvalues a=0/17{
		replace e`var'=(e`var')*(1-`var'`a')
	}
	tab e`var'
}

local bw50=eubecbw50
local bw60=eubecbw60

putexcel B15=(1-`bw50') D15=(1-`bw60')

restore
preserve

keep if hieduc==4

local transition "ubecbw50 ubecbw60"

gen ubw50atbir=uyearbw50 if durmom==0
gen ubw60atbir=uyearbw60 if durmom==0
	
foreach var in `transition'{
	forvalues a=0/17{
		quietly egen `var'`a'=mean(`var') if durmom==`a' & `var' !=2
		tab `var'`a'
	}
}

collapse (max) ubecbw50* ubecbw60* (mean) ubw50atbir ubw60atbir

gen eubecbw50=1-ubw50atbir
gen eubecbw60=1-ubw60atbir  

foreach var in `transition'{
	forvalues a=0/17{
		replace e`var'=(e`var')*(1-`var'`a')
	}
	tab e`var'
}

local bw50=eubecbw50
local bw60=eubecbw60

putexcel B16=(1-`bw50') D16=(1-`bw60')

restore
preserve

keep if yearspartner==0

local transition "ubecbw50 ubecbw60"

gen ubw50atbir=uyearbw50 if durmom==0
gen ubw60atbir=uyearbw60 if durmom==0
	
foreach var in `transition'{
	forvalues a=0/17{
		quietly egen `var'`a'=mean(`var') if durmom==`a' & `var' !=2
		tab `var'`a'
	}
}

collapse (max) ubecbw50* ubecbw60* (mean) ubw50atbir ubw60atbir

gen eubecbw50=1-ubw50atbir
gen eubecbw60=1-ubw60atbir  

foreach var in `transition'{
	forvalues a=0/17{
		replace e`var'=(e`var')*(1-`var'`a')
	}
	tab e`var'
}

local bw50=eubecbw50
local bw60=eubecbw60

putexcel B19=(1-`bw50') D19=(1-`bw60')

restore
preserve

keep if yearspartner==1

local transition "ubecbw50 ubecbw60"

gen ubw50atbir=uyearbw50 if durmom==0
gen ubw60atbir=uyearbw60 if durmom==0
	
foreach var in `transition'{
	forvalues a=0/17{
		quietly egen `var'`a'=mean(`var') if durmom==`a' & `var' !=2
		tab `var'`a'
	}
}

collapse (max) ubecbw50* ubecbw60* (mean) ubw50atbir ubw60atbir

gen eubecbw50=1-ubw50atbir
gen eubecbw60=1-ubw60atbir  

foreach var in `transition'{
	forvalues a=0/17{
		replace e`var'=(e`var')*(1-`var'`a')
	}
	tab e`var'
}

local bw50=eubecbw50
local bw60=eubecbw60

putexcel B20=(1-`bw50') D20=(1-`bw60')

restore
preserve

keep if agebir1==1

local transition "ubecbw50 ubecbw60"

gen ubw50atbir=uyearbw50 if durmom==0
gen ubw60atbir=uyearbw60 if durmom==0

tab ubw50atbir
tab ubw60atbir

	
foreach var in `transition'{
	forvalues a=0/17{
		quietly egen `var'`a'=mean(`var') if durmom==`a' & `var' !=2
		tab `var'`a'
	}
}

collapse (max) ubecbw50* ubecbw60* (mean) ubw50atbir ubw60atbir

gen eubecbw50=1-ubw50atbir
gen eubecbw60=1-ubw60atbir  

foreach var in `transition'{
	forvalues a=0/17{
		replace e`var'=(e`var')*(1-`var'`a')
	}
	tab e`var'
}

local bw50=eubecbw50
local bw60=eubecbw60

putexcel B22=(1-`bw50') D22=(1-`bw60')

restore
preserve

keep if agebir1==2

local transition "ubecbw50 ubecbw60"

gen ubw50atbir=uyearbw50 if durmom==0
gen ubw60atbir=uyearbw60 if durmom==0
	
foreach var in `transition'{
	forvalues a=0/17{
		quietly egen `var'`a'=mean(`var') if durmom==`a' & `var' !=2
		tab `var'`a'
	}
}

collapse (max) ubecbw50* ubecbw60* (mean) ubw50atbir ubw60atbir

gen eubecbw50=1-ubw50atbir
gen eubecbw60=1-ubw60atbir  

foreach var in `transition'{
	forvalues a=0/17{
		replace e`var'=(e`var')*(1-`var'`a')
	}
	tab e`var'
}

local bw50=eubecbw50
local bw60=eubecbw60

putexcel B23=(1-`bw50') D23=(1-`bw60')

restore
preserve

keep if agebir1==3

local transition "ubecbw50 ubecbw60"

gen ubw50atbir=uyearbw50 if durmom==0
gen ubw60atbir=uyearbw60 if durmom==0
	
foreach var in `transition'{
	forvalues a=0/17{
		quietly egen `var'`a'=mean(`var') if durmom==`a' & `var' !=2
		tab `var'`a'
	}
}

collapse (max) ubecbw50* ubecbw60* (mean) ubw50atbir ubw60atbir

gen eubecbw50=1-ubw50atbir
gen eubecbw60=1-ubw60atbir  

foreach var in `transition'{
	forvalues a=0/17{
		replace e`var'=(e`var')*(1-`var'`a')
	}
	tab e`var'
}

local bw50=eubecbw50
local bw60=eubecbw60

putexcel B24=(1-`bw50') D24=(1-`bw60')

restore
preserve

keep if agebir1==4

local transition "ubecbw50 ubecbw60"

gen ubw50atbir=uyearbw50 if durmom==0
gen ubw60atbir=uyearbw60 if durmom==0
	
foreach var in `transition'{
	forvalues a=0/17{
		quietly egen `var'`a'=mean(`var') if durmom==`a' & `var' !=2
		tab `var'`a'
	}
}

collapse (max) ubecbw50* ubecbw60* (mean) ubw50atbir ubw60atbir

gen eubecbw50=1-ubw50atbir
gen eubecbw60=1-ubw60atbir  

foreach var in `transition'{
	forvalues a=0/17{
		replace e`var'=(e`var')*(1-`var'`a')
	}
	tab e`var'
}

local bw50=eubecbw50
local bw60=eubecbw60

putexcel B25=(1-`bw50') D25=(1-`bw60')

restore

tab my_race
tab hieduc
tab yearspartner
tab agebir1
tab uyearbw50, m

putexcel set "$results/LifetimeBreadwin.xlsx", sheet(BW50detail) modify
putexcel B2=("Not") C2=("Breadwinning") D2=("already bw") G2=("not enter bw") H2=("cumulative survival")
putexcel A3="Birth" 
tab durmom ubecbw50, m
tab uyearbw50 if durmom==0, matcell(atbir50)
putexcel B24=matrix(atbir50)
putexcel B3=formula(B25)
putexcel C3=formula(B24)
putexcel G3=formula(B24/(B24+B25))
putexcel F3=formula(B25/(B24+B25))
tab durmom ubecbw50, matcell(trans50)
putexcel B4=matrix(trans50)

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

