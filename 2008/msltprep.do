* This file creates transition rates based on status changes between years at duration durmom

use "$tempdir/relearn_year.dta", clear // a file produces by create_yearearn.do

gen neghinc=1 if year_uhearn < 0

* drop cases with negative household income
drop if neghinc==1
drop neghinc

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
drop if durmom > 18

gen ageb1=yearage-durmom
recode ageb1 (0/17=1)(18/22=2)(23/29=3)(30/56=4), gen(agebir1)

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

* add 1 to make the "p" variables start with "p11" not "p00"
foreach var in `nowvars'{
   replace `var'=`var'+1
}

* Note that uyearbw50 can be missing either because of missing data (most cases) or because
* income data are not available. Missing does not mean zero income. Households with no income
* are coded as 9 on breadwinning. Households with negative household income were dropped
* at the top of this file.

foreach var in `nowvars'{
        replace `var'=5 if !missing(`var') & nobsmomminor==0 // ignore spells where mother isn't living with her children
	replace `var'=4 if !missing(`var') & durmom < 0 
	replace `var'=4 if durmom >=18
	replace `var'=5 if missing(`var')
}

local thenvars  "uybw50L1 uybw60L1"

* add 1 to make the "p" variables start with "p11" not "p00"
foreach var in `thenvars'{
    replace `var'=`var'+1
}

foreach var in `thenvars'{
	replace `var'=5 if !missing(`var') & nobsmomminorL1==0
	replace `var'=4 if !missing(`var') & durmom < 1 
	replace `var'=4 if durmom >=19
	replace `var'=5 if missing(`var')
}


*#delimit ;
*
*label define bwstat 0 "non breadwinning mother"
*                                        1 "non-breadwinning mother"
*                                        2 "primary breadwinning mother"
*                                        3 "sole earner"
*                                        4 " not living with children or first child > 18"
*                                        5 "missing";
*					
*# delimit cr
*
*label values uyearbw50 bwstat
*label values uyearbw60 bwstat
*label values uybw50L1 bwstat
*label values uybw60L1 bwstat

save "$tempdir/msltprep.dta", $replace








