~~~~
<<dd_do>>

* This file both documents the sample and sample selection and starts the analysis

use "$tempdir/relearn_year.dta", clear 

* describe sample
	 sort ssuid epppnum
	 egen tagid = tag(ssuid epppnum)
	 replace tagid=. if tagid !=1 

	 egen all_p4=count(tagid)

	 local allindividuals4 = all_p4

	 drop all_p4 tagid 


* select if started observation a mother or became a mother during observation window
keep if nobsmomminor > 0 

* describe sample
	 sort ssuid epppnum
	 egen tagid = tag(ssuid epppnum)
	 replace tagid=. if tagid !=1 

	 egen all_p5=count(tagid)

	 local allindividuals5 = all_p5

	 drop all_p5 tagid 


gen negpinc=1 if year_pearn < 0 // negative personal income
gen neghinc=1 if year_hearn < 0 // negative household income

* drop cases with negative household income
drop if neghinc==1

* describe sample
	 sort ssuid epppnum
	 egen tagid = tag(ssuid epppnum)
	 replace tagid=. if tagid !=1 

	 egen all_p6=count(tagid)

	 local allindividuals6 = all_p6

	 drop all_p6 tagid 


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

recode uyearbw50 (0=0)(1/2=1)
recode uyearbw60 (0=0)(1/2=1)

* describe sample
	 sort ssuid epppnum
	 egen tagid = tag(ssuid epppnum)
	 replace tagid=. if tagid !=1 

	 egen all_p7=count(tagid)

	 local allindividuals7 = all_p7

         local hincneg=`allindividuals5'-`allindividuals6'
         local noageb1=`allindividuals6'-`allindividuals7'

         egen all_years=count(1)

	 local allyears = all_years


         drop all_p7 tagid all_years

save "$SIPP08keep/breadwinning_analysis.dta", replace

<</dd_do>>
~~~~

Data and Method
---------------

The data come from the 2008 panel of the Survey of Income and Propgram participation which is a probability sample of the non-institutionalized population in the United States interviewed from lat 2008 through 2013. We begin by extracting a sample of women age 15-69 (N= <<dd_display: %6.0fc `allindividuals4'>>). We further limit the sample to <<dd_display:%6.0fc `allindividuals5'>> women observed at any point living with minor children. From this sample, we dropped those who were never observed with a positive household income (<<dd_display: %5.0fc `hincneg'>> cases) or who lacked information on age at first birth (<<dd_display: %5.0fc `noageb1'>> cases). After these restrictions, we have a sample of <<dd_display: %6.0fc `allindividuals7'>> women and <<dd_display: %8.0fc `allyears'>>.

~~~~
<<dd_do>>

*******************************************************************************
* Basic Descriptive Table 
*******************************************************************************
* I put some descriptives in an excel file, but also produce the output in yearearn_describe_data.html
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
local median_pers: di %9.0fc = r(p50)
putexcel B3=("`median_pers'")
sum year_uhearn, detail
local median_hh: di %9.0fc = r(p50)
putexcel B4=("`median_hh'")
sum uratio
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
local median_pers_p: di %9.0fc = r(p50)
putexcel C3=("`median_pers_p'")
sum year_uhearn if yearspartner==1, detail
local median_hh_p: di %9.0fc = r(p50)
putexcel C4=("`median_hh_p'")
sum uratio if yearspartner==1
local ratio_p: di %4.2f = r(mean)
putexcel C5=("`ratio_p'")

sum uyearbw50 if inlist(uyearbw50, 0, 1) & yearspartner==1
local mean50_p: di %4.1f = r(mean)*100
putexcel C7=("`mean50_p'")
sum uyearbw60 if inlist(uyearbw60, 0, 1) & yearspartner==1
local mean60_p: di %4.1f = r(mean)*100
putexcel C8=("`mean60_p'")

* Not Partnered

sum year_upearn if yearspartner==0, detail
local median_pers_s: di %9.0fc = r(p50)
putexcel D3=("`median_pers_s'")
sum year_uhearn if yearspartner==0, detail
local median_hh_s: di %9.0fc = r(p50)
putexcel D4=("`median_hh_s'")
sum uratio if yearspartner==0
local ratio_s: di %4.2f = r(mean)
putexcel D5=("`ratio_s'")

sum uyearbw50 if inlist(uyearbw50, 0, 1) & yearspartner==0
local mean50_s: di %4.1f = r(mean)*100
putexcel D7=("`mean50_s'")
sum uyearbw60 if inlist(uyearbw60, 0, 1) & yearspartner==0
local mean60_s: di %4.1f = r(mean)*100
putexcel D8=("`mean60_s'")

<</dd_do>>
~~~~


Table 1. Mothers' Earnings Relative to Household Earnings by Partnership Status at Start of Year <br>
All       Partnered         No Partner <br>
Personal Earnings(median)  <<dd_di: %6.0fc `median_pers' `median_pers_p' `median_pers_s'>> <br>
Household Earnings(median) <<dd_di: %6.0fc `median_hh' `median_hh_p' `median_hh_s'>> <br>
Ratio                      <<dd_di: %4.2f `ratio' `ratio_p' `ratio_s'>> <br>
% Breadwinning (> 50%)     <<dd_di: %4.1f `mean50' `mean50_p' `mean50_s'>> <br>
% Breadwinning(> 60%)       <dd_di: %4.1f `mean60' `mean60_p' `mean60_s'>> <br>

