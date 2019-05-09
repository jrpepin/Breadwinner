cd "C:\Users\Joanna\Dropbox\Repositories\NLSY97_Breadwinning"
clear
set more off
local logdate = string( d(`c(current_date)'), "%dCY.N.D" )

log using "C:\Users\Joanna\Dropbox\Repositories\NLSY97_Breadwinning\logs\nlsy97_hh50_`logdate'.log", t replace

use 	"C:\Users\Joanna\Dropbox\Repositories\NLSY97_Breadwinning\nlsy97_hh50.dta", clear

*select only observations since first birth
// JP: Don't we want the breadwinning status for the two years BEFORE firstbirth?
// I changed this variable so 1 equals 2 years prior to first birth and every year after. Wrong?
keep if firstbirth==1 	

drop firstbirth 		// this variable has no variation now 

// NOTE: Time is lagged by 1 year because respondents reported earnings the year before survery year (year)

// Code won't run with negative values
replace time = time + 2
label define timelbl 	1 "Minus 2" 2 "Minus 1" 3 "Year of 1st Birth" 4 "Plus 1" 5 "Plus 2" 6 "Plus 3" ///
						7 "Plus 4"	8 "Plus 5"	9 "Plus 6"	10 "Plus 7" 11 "Plus 8" 12 "Plus 9" 13 "Plus 10"
label values time timelbl

drop if time == . 		// Can't run next code with missing time data

reshape wide year hhe50, i(PUBID_1997) j(time)

forvalues t=1/8{
    local s=`t'-1
    gen hhe50_minus1_`t'=hhe50`s' 
}

forvalues t=2/8{
    local r=`t'-2
    gen hhe50_minus2_`t'=hhe50`r' 
}

reshape long year hhe50 hhe50_minus1_ hhe50_minus2_, i(PUBID_1997) j(time)

* clean up observations created because reshape creates some number of observations for each (PUBID_1997)
drop if missing(year)

logit hhe50 hhe50_minus1 i.time
logit hhe50 hhe50_minus1 hhe50_minus2 i.time


log close
