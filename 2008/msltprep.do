*need to add n's to results table

use "$tempdir/relearn_year.dta", clear

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

drop if durmom < -1

gen ageb1=yearage-durmom
recode ageb1 (0/17=1)(18/22=2)(23/29=3)(30/56=4), gen(agebir1)

tab uybw50L1_ y, m

********************************************************************************
* adjust variables for transitions analysis
********************************************************************************

rename uybw50L1_ uybw50L1
rename uybw60L1_ uybw60L1
rename nobsmomminorL1_ nobsmomminorL1

local nowvars "uyearbw50 uyearbw60"

foreach var in `nowvars'{
	replace `var'=3 if !missing(`var') & nobsmomminor==0 
	replace `var'=3 if durmom >=18
	replace `var'=4 if missing(`var')
}

local thenvars  "uybw50L1 uybw60L1"

foreach var in `thenvars'{
	replace `var'=3 if !missing(`var') & nobsmomminorL1==0
	replace `var'=3 if durmom >=19
	replace `var'=4 if missing(`var')
}
keep if durmom <= 18 

*******************************************************************************
* Table of breadwinning status this year by breadwinning status previous year
*******************************************************************************
putexcel set "$results/transitions.xlsx", sheet(50%) modify
putexcel A1="breadwinning status this year by breadwinning status previous year (50%)"
putexcel A2=("duration") B2=("Not Breadwinning Mom") C2=("Became Breadwinning Mom") D2=("Not Breadwinning to non-mom") E2=("not breadwinning to missing")
putexcel F2=("Became not breadwinning") G2=("Still Breadwinning") H2=("Breadwinning to non-mother") I2=("Breadwinning to missing") J2=("non-mother to non-breadwinning")
putexcel K2=("non-mother to breadwinning") L2=("non-mother") M2=("non-mother to missing") N2=("missing to non-breadwinning") O2=("missing to breadwinning") 
putexcel P2=("missing to non-mother") Q2=("missing")

forvalues d=0/18{
	local row=`d'+3
	putexcel A`row'=`d'
	forvalues cs=0/4{
		forvalues ls=0/4{
			egen t`ls'`cs'_`d'=count(y) if durmom==`d' & uyearbw50==`cs' & uybw50L1==`ls'
		}
	}
}

collapse (max) t00_0-t00_18 t-t444

/*
forvalues d=0/18{
	local row=`d'+3
	putexcel B`row'=t00`d'
	putexcel C`row'=t01`d'
	putexcel D`row'=t02`d'
}
	
/*	
	
restore

putexcel set "$results/transitions.xlsx", sheet(60%) modify
putexcel A1="breadwinning status this year by breadwinning status previous year (60%)"
putexcel A2=("duration") B2=("Not Breadwinning Mom") C2=("Became Breadwinning Mom") D2=("Not Breadwinning to non-mom") E2=("not breadwinning to missing")
putexcel F2=("Became not breadwinning") G2=("Still Breadwinning") H2=("Breadwinning to non-mother") I2=("Breadwinning to missing") J2=("non-mother to non-breadwinning")
putexcel K2=("non-mother to breadwinning") L2=("non-mother") M2=("non-mother to missing") N2=("missing to non-breadwinning") O2=("missing to breadwinning") 
putexcel P2=("missing to non-mother") Q2=("missing")




