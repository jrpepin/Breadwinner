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
* calculate cumulative risk of breadwinning 
*******************************************************************************

putexcel set "$results/LifetimeBreadwin.xlsx", sheet(Table 3) modify
putexcel B2=("All years") F2=("Year 4 to 5")

keep if durmom < 18 & y==4

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

putexcel F4=(1-`bw50') H4=(1-`bw60')

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

putexcel F6=(1-`bw50') H6=(1-`bw60')

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

putexcel F7=(1-`bw50') H7=(1-`bw60')

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

putexcel F8=(1-`bw50') H8=(1-`bw60')

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

putexcel F9=(1-`bw50') DH9=(1-`bw60')

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

putexcel F10=(1-`bw50') H10=(1-`bw60')

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

putexcel F13=(1-`bw50') H13=(1-`bw60')

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

putexcel F14=(1-`bw50') H14=(1-`bw60')

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

putexcel F15=(1-`bw50') H15=(1-`bw60')

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

putexcel F16=(1-`bw50') H16=(1-`bw60')

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

putexcel F19=(1-`bw50') H19=(1-`bw60')

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

putexcel F20=(1-`bw50') H20=(1-`bw60')

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

putexcel F22=(1-`bw50') H22=(1-`bw60')

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

putexcel F23=(1-`bw50') H23=(1-`bw60')

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

putexcel F24=(1-`bw50') H24=(1-`bw60')

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

putexcel F25=(1-`bw50') H25=(1-`bw60')
