cd "C:\Users\Joanna\Dropbox\Repositories\NLSY97_Breadwinning\stata"
clear
set more off
local logdate = string( d(`c(current_date)'), "%dCY.N.D" )

log using "C:\Users\Joanna\Dropbox\Repositories\NLSY97_Breadwinning\logs\nlsy97_hh60_`logdate'.log", t replace

use 	"C:\Users\Joanna\Dropbox\Repositories\NLSY97_Breadwinning\stata\nlsy97_hh60.dta", clear

*select only observations since first birth
keep if firstbirth==1 	// selected on this in R already

drop firstbirth 		// this variable has no variation now 

reshape wide year hhe60, i(PUBID_1997) j(time)

forvalues t=1/8{
    local s=`t'-1
    gen hhe60_minus1_`t'=hhe60`s' 
}

forvalues t=2/8{
    local r=`t'-2
    gen hhe60_minus2_`t'=hhe60`r' 
}

forvalues t=3/8{
    local r=`t'-3
    gen hhe60_minus3_`t'=hhe60`r' 
}

reshape long year hhe60 hhe60_minus1_ hhe60_minus2_ hhe60_minus3_, i(PUBID_1997) j(time)

* clean up observations created because reshape creates some number of observations for each (PUBID_1997)
drop if missing(year)

logit hhe60 hhe60_minus1 i.time
logit hhe60 hhe60_minus1 hhe60_minus2 i.time
logit hhe60 hhe60_minus1 hhe60_minus2 hhe60_minus3 i.time

log close
