cd "C:\Users\Joanna\Dropbox\Repositories\NLSY97_Breadwinning\logs"
clear
set more off
local logdate = string( d(`c(current_date)'), "%dCY.N.D" )

local list : dir . files "*nlsy97_hh60_*.log"
foreach f of local list {
    erase "`f'"
}

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
    local u=`t'-3
    gen hhe60_minus3_`t'=hhe60`u' 
}

forvalues t=4/8{
    local v=`t'-4
    gen hhe60_minus4_`t'=hhe60`v' 
}

reshape long year hhe60 hhe60_minus1_ hhe60_minus2_ hhe60_minus3_ hhe60_minus4_, i(PUBID_1997) j(time)

* clean up observations created because reshape creates some number of observations for each (PUBID_1997)
drop if missing(year)

logit hhe60 i.hhe60_minus1 i.time, or
logit hhe60 i.hhe60_minus1 i.hhe60_minus2 i.time, or
logit hhe60 i.hhe60_minus1 i.hhe60_minus2 i.hhe60_minus3 i.time, or
logit hhe60 i.hhe60_minus1 i.hhe60_minus2 i.hhe60_minus3 i.hhe60_minus4 i.time, or

margins hhe60_minus1_
margins hhe60_minus2_
margins hhe60_minus3_
margins hhe60_minus4_


log close
