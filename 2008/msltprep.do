* This file creates transition rates based on status changes between years at duration durmom

use "$tempdir/relearn_year.dta", clear // a file produces by create_yearearn.do

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
*   - separate breadwinners into sole breadwinners versus primary breadwinners
*	- create value for not living with a minor child (4)
*   - create value for missing (5)
********************************************************************************

rename uybw50L1_ uybw50L1
rename uybw60L1_ uybw60L1
rename nobsmomminorL1_ nobsmomminorL1

local nowvars "uyearbw50 uyearbw60"

foreach var in `nowvars'{
	replace `var'=0 if `var'==1 & year_upearn <= 0 // can't be breadwinner if earnings are 0
	replace `var'=2 if !missing(`var') & `var'==1 & year_upearn==year_uhearn // sole breadwinner
	replace `var'=3 if !missing(`var') & nobsmomminor==0 
	replace `var'=3 if !missing(`var') & durmom < 0 
	replace `var'=3 if durmom >=18
	replace `var'=4 if missing(`var')
}

local thenvars  "uybw50L1 uybw60L1"

foreach var in `thenvars'{
	replace `var'=0 if `var'==1 & year_upearn <= 0 // can't be breadwinner if earnings are 0
	replace `var'=2 if !missing(`var') & `var'==1 & year_upearn==year_uhearn // sole breadwinner
	replace `var'=3 if !missing(`var') & nobsmomminorL1==0
	replace `var'=3 if !missing(`var') & durmom < 1 
	replace `var'=3 if durmom >=19
	replace `var'=4 if missing(`var')
}
keep if durmom <= 19 

#delimit ;

label define bwstat 0 "non breadwinning mother"
					1 "primary breadwinning mother"
					2 "sole breadwinning mother"
					3 "non-mother, oldest child > 18"
					4 "missing";
					
# delimit cr

label values uyearbw50 bwstat
label values uyearbw60 bwstat
label values uybw50L1 bwstat
label values uybw60L1 bwstat

* drop cases missing at either side of the interval
* remove this to see how many years observations are missing (a lot)
drop if uybw50L1==4 | uyearbw50==4

*******************************************************************************
* generate data files with measures of transition rates
*******************************************************************************

* Primary earner (50%)

preserve

*create numerators

forvalues d=0/18{
	forvalues cs=0/4{
		forvalues ls=0/4{
			egen trans`ls'`cs'_`d'=count(y) if durmom==`d' & uyearbw50==`cs' & uybw50L1==`ls'
		}
	}
}

* create denominators

forvalues d=0/18{
	forvalues ls=0/4{
		egen den`ls'_`d'=count(y) if durmom==`d' & uybw50L1==`ls'
	}
}

keep trans* den* 

collapse _all

* create rates

forvalues d=0/18{
	forvalues cs=0/4{
		local fc=`cs'+1
		forvalues ls=0/4{
			local fl=`ls'+1
			gen p`fl'`fc'`d'=trans`ls'`cs'_`d'/den`ls'_`d'
		}
	}
}

keep p*

gen constant=1

reshape long p11 p12 p13 p14 p15 p21 p22 p23 p24 p25 p31 p32 p33 p34 p35 p41 p42 p43 p44 p45 p51 p52 p53 p54 p55 , i(constant) j(age)

foreach var of varlist _all{
	replace `var'=0 if missing(`var')
}

* The life table does not have distribution across states at birth, just transition rates. So, the first transition is from not a mother (at time 0) to a mother (at time 1)
* Thus, the duration variables are not age of oldest child, but age of oldest child - 1. We need the life table up to duration 17, which represents the year the oldest child 
* transitions to age 18

save "$SIPP08keep/transrates50.dta", $replace

restore
preserve

keep if my_race==1

*create numerators

forvalues d=0/18{
	forvalues cs=0/4{
		forvalues ls=0/4{
			egen trans`ls'`cs'_`d'=count(y) if durmom==`d' & uyearbw50==`cs' & uybw50L1==`ls'
		}
	}
}

* create denominators

forvalues d=0/18{
	forvalues ls=0/4{
		egen den`ls'_`d'=count(y) if durmom==`d' & uybw50L1==`ls'
	}
}

keep trans* den* 
collapse _all

* create rates

forvalues d=0/18{
	forvalues cs=0/4{
		local fc=`cs'+1
		forvalues ls=0/4{
			local fl=`ls'+1
			gen p`fl'`fc'`d'=trans`ls'`cs'_`d'/den`ls'_`d'
		}
	}
}

keep p*

gen constant=1

reshape long p11 p12 p13 p14 p15 p21 p22 p23 p24 p25 p31 p32 p33 p34 p35 p41 p42 p43 p44 p45 p51 p52 p53 p54 p55 , i(constant) j(age)

foreach var of varlist _all{
	replace `var'=0 if missing(`var')
}

* The life table does not have distribution across states at birth, just transition rates. So, the first transition is from not a mother (at time 0) to a mother (at time 1)
* Thus, the duration variables are not age of oldest child, but age of oldest child - 1. We need the life table up to duration 17, which represents the year the oldest child 
* transitions to age 18

save "$SIPP08keep/transrates50w.dta", $replace

restore
preserve

keep if my_race==2

*create numerators

forvalues d=0/18{
	forvalues cs=0/4{
		forvalues ls=0/4{
			egen trans`ls'`cs'_`d'=count(y) if durmom==`d' & uyearbw50==`cs' & uybw50L1==`ls'
		}
	}
}

* create denominators

forvalues d=0/18{
	forvalues ls=0/4{
		egen den`ls'_`d'=count(y) if durmom==`d' & uybw50L1==`ls'
	}
}

keep trans* den* 
collapse _all

* create rates

forvalues d=0/18{
	forvalues cs=0/4{
		local fc=`cs'+1
		forvalues ls=0/4{
			local fl=`ls'+1
			gen p`fl'`fc'`d'=trans`ls'`cs'_`d'/den`ls'_`d'
		}
	}
}

keep p*

gen constant=1

reshape long p11 p12 p13 p14 p15 p21 p22 p23 p24 p25 p31 p32 p33 p34 p35 p41 p42 p43 p44 p45 p51 p52 p53 p54 p55 , i(constant) j(age)

foreach var of varlist _all{
	replace `var'=0 if missing(`var')
}

* The life table does not have distribution across states at birth, just transition rates. So, the first transition is from not a mother (at time 0) to a mother (at time 1)
* Thus, the duration variables are not age of oldest child, but age of oldest child - 1. We need the life table up to duration 17, which represents the year the oldest child 
* transitions to age 18

save "$SIPP08keep/transrates50b.dta", $replace

restore
preserve

keep if my_race==3

*create numerators

forvalues d=0/18{
	forvalues cs=0/4{
		forvalues ls=0/4{
			egen trans`ls'`cs'_`d'=count(y) if durmom==`d' & uyearbw50==`cs' & uybw50L1==`ls'
		}
	}
}

* create denominators

forvalues d=0/18{
	forvalues ls=0/4{
		egen den`ls'_`d'=count(y) if durmom==`d' & uybw50L1==`ls'
	}
}

keep trans* den* 
collapse _all

* create rates

forvalues d=0/18{
	forvalues cs=0/4{
		local fc=`cs'+1
		forvalues ls=0/4{
			local fl=`ls'+1
			gen p`fl'`fc'`d'=trans`ls'`cs'_`d'/den`ls'_`d'
		}
	}
}

keep p*

gen constant=1

reshape long p11 p12 p13 p14 p15 p21 p22 p23 p24 p25 p31 p32 p33 p34 p35 p41 p42 p43 p44 p45 p51 p52 p53 p54 p55 , i(constant) j(age)

foreach var of varlist _all{
	replace `var'=0 if missing(`var')
}

* The life table does not have distribution across states at birth, just transition rates. So, the first transition is from not a mother (at time 0) to a mother (at time 1)
* Thus, the duration variables are not age of oldest child, but age of oldest child - 1. We need the life table up to duration 17, which represents the year the oldest child 
* transitions to age 18

save "$SIPP08keep/transrates50h.dta", $replace

restore
preserve

keep if hieduc==1

*create numerators

forvalues d=0/18{
	forvalues cs=0/4{
		forvalues ls=0/4{
			egen trans`ls'`cs'_`d'=count(y) if durmom==`d' & uyearbw50==`cs' & uybw50L1==`ls'
		}
	}
}

* create denominators

forvalues d=0/18{
	forvalues ls=0/4{
		egen den`ls'_`d'=count(y) if durmom==`d' & uybw50L1==`ls'
	}
}

keep trans* den* 
collapse _all

* create rates

forvalues d=0/18{
	forvalues cs=0/4{
		local fc=`cs'+1
		forvalues ls=0/4{
			local fl=`ls'+1
			gen p`fl'`fc'`d'=trans`ls'`cs'_`d'/den`ls'_`d'
		}
	}
}

keep p*

gen constant=1

reshape long p11 p12 p13 p14 p15 p21 p22 p23 p24 p25 p31 p32 p33 p34 p35 p41 p42 p43 p44 p45 p51 p52 p53 p54 p55 , i(constant) j(age)

foreach var of varlist _all{
	replace `var'=0 if missing(`var')
}

* The life table does not have distribution across states at birth, just transition rates. So, the first transition is from not a mother (at time 0) to a mother (at time 1)
* Thus, the duration variables are not age of oldest child, but age of oldest child - 1. We need the life table up to duration 17, which represents the year the oldest child 
* transitions to age 18

save "$SIPP08keep/transrates50e1.dta", $replace

restore
preserve

keep if hieduc==2

*create numerators

forvalues d=0/18{
	forvalues cs=0/4{
		forvalues ls=0/4{
			egen trans`ls'`cs'_`d'=count(y) if durmom==`d' & uyearbw50==`cs' & uybw50L1==`ls'
		}
	}
}

* create denominators

forvalues d=0/18{
	forvalues ls=0/4{
		egen den`ls'_`d'=count(y) if durmom==`d' & uybw50L1==`ls'
	}
}

keep trans* den* 
collapse _all

* create rates

forvalues d=0/18{
	forvalues cs=0/4{
		local fc=`cs'+1
		forvalues ls=0/4{
			local fl=`ls'+1
			gen p`fl'`fc'`d'=trans`ls'`cs'_`d'/den`ls'_`d'
		}
	}
}

keep p*

gen constant=1

reshape long p11 p12 p13 p14 p15 p21 p22 p23 p24 p25 p31 p32 p33 p34 p35 p41 p42 p43 p44 p45 p51 p52 p53 p54 p55 , i(constant) j(age)

foreach var of varlist _all{
	replace `var'=0 if missing(`var')
}

* The life table does not have distribution across states at birth, just transition rates. So, the first transition is from not a mother (at time 0) to a mother (at time 1)
* Thus, the duration variables are not age of oldest child, but age of oldest child - 1. We need the life table up to duration 17, which represents the year the oldest child 
* transitions to age 18

save "$SIPP08keep/transrates50e2.dta", $replace

restore
preserve

keep if hieduc==3

*create numerators

forvalues d=0/18{
	forvalues cs=0/4{
		forvalues ls=0/4{
			egen trans`ls'`cs'_`d'=count(y) if durmom==`d' & uyearbw50==`cs' & uybw50L1==`ls'
		}
	}
}

* create denominators

forvalues d=0/18{
	forvalues ls=0/4{
		egen den`ls'_`d'=count(y) if durmom==`d' & uybw50L1==`ls'
	}
}

keep trans* den* 
collapse _all

* create rates

forvalues d=0/18{
	forvalues cs=0/4{
		local fc=`cs'+1
		forvalues ls=0/4{
			local fl=`ls'+1
			gen p`fl'`fc'`d'=trans`ls'`cs'_`d'/den`ls'_`d'
		}
	}
}

keep p*

gen constant=1

reshape long p11 p12 p13 p14 p15 p21 p22 p23 p24 p25 p31 p32 p33 p34 p35 p41 p42 p43 p44 p45 p51 p52 p53 p54 p55 , i(constant) j(age)

foreach var of varlist _all{
	replace `var'=0 if missing(`var')
}

* The life table does not have distribution across states at birth, just transition rates. So, the first transition is from not a mother (at time 0) to a mother (at time 1)
* Thus, the duration variables are not age of oldest child, but age of oldest child - 1. We need the life table up to duration 17, which represents the year the oldest child 
* transitions to age 18

save "$SIPP08keep/transrates50e3.dta", $replace

restore
preserve

keep if hieduc==4

*create numerators

forvalues d=0/18{
	forvalues cs=0/4{
		forvalues ls=0/4{
			egen trans`ls'`cs'_`d'=count(y) if durmom==`d' & uyearbw50==`cs' & uybw50L1==`ls'
		}
	}
}

* create denominators

forvalues d=0/18{
	forvalues ls=0/4{
		egen den`ls'_`d'=count(y) if durmom==`d' & uybw50L1==`ls'
	}
}

keep trans* den* 
collapse _all

* create rates

forvalues d=0/18{
	forvalues cs=0/4{
		local fc=`cs'+1
		forvalues ls=0/4{
			local fl=`ls'+1
			gen p`fl'`fc'`d'=trans`ls'`cs'_`d'/den`ls'_`d'
		}
	}
}

keep p*

gen constant=1

reshape long p11 p12 p13 p14 p15 p21 p22 p23 p24 p25 p31 p32 p33 p34 p35 p41 p42 p43 p44 p45 p51 p52 p53 p54 p55 , i(constant) j(age)

foreach var of varlist _all{
	replace `var'=0 if missing(`var')
}

* The life table does not have distribution across states at birth, just transition rates. So, the first transition is from not a mother (at time 0) to a mother (at time 1)
* Thus, the duration variables are not age of oldest child, but age of oldest child - 1. We need the life table up to duration 17, which represents the year the oldest child 
* transitions to age 18

save "$SIPP08keep/transrates50e4.dta", $replace








