*****************************************************************************
*  create annual measures of earnings 
*****************************************************************************

* first, make the file wide

use "$tempdir/relearn.dta", clear

local i_variables " ssuid epppnum "
local j_variables " swave "
local other_variables "nmomto nbiomomto HHsize nHHkids spartner SHHADID adj_age comp_change addr_change comp_change_reason EBORNUS EMS EORIGIN ERRP thearn thothinc tpearn pHHearn momtoany nHHadults onlyadult solomom bw50 bw60"

keep `j_variables' `i_variables' `other_variables' my_race my_race2 my_sex

reshape wide `other_variables', i(`i_variables') j(`j_variables')

* create inter-wave transition variables
forvalues w=1/14 {
local x=`w'+1
gen become_bw50`w'=1 if bw50`w'==0 & bw50`x'==1
replace become_bw50`w'=0 if !missing(bw50`w') & !missing(bw50`x') & (bw50`w'==1 | bw50`x'==0)

gen leave_bw50`w'=1 if bw50`w'==1 & bw50`x'==0
replace leave_bw50`w'=0 if !missing(bw50`w') & !missing(bw50`x') & (bw50`w'==0 | bw50`x'==1)

gen become_bw60`w'=1 if bw60`w'==0 & bw60`x'==1
replace become_bw60`w'=0 if !missing(bw60`w') & !missing(bw60`x') & (bw60`w'==1 | bw60`x'==0)

gen leave_bw60`w'=1 if bw60`w'==1 & bw60`x'==0
replace leave_bw60`w'=0 if !missing(bw60`w') & !missing(bw60`x') & (bw60`w'==0 | bw60`x'==1)
}


* create indicators for in each wave (w)

forvalues w=1/15 {
gen in`w'=0
gen nmpearn`w'=0
gen nmhearn`w'=0
replace in`w'=1 if !missing(ERRP`w')
replace nmpearn`w'=1 if !missing(tpearn`w')
replace nmhearn`w'=1 if !missing(thearn`w')
}

* create indicates of number of observations in each year, where a year is a collection 
* of three consecutive waves. (Does not correspond to calendar year)

forvalues y=1/5 {
  gen inyear`y'=0
  gen nmpyear`y'=0
  gen nmhyear`y'=0
  forvalues o=1/3 {
    local w=(`y'-1)*3 + `o'
    replace inyear`y'=inyear`y'+1 if in`w'==1 
	replace nmpyear`y'=nmpyear`y'+1 if nmpearn`w'==1
	replace nmhyear`y'=nmhyear`y'+1 if nmhearn`w'==1
  }
  tab inyear`y'
  tab nmpyear`y'
  tab nmhyear`y'
  }

 gen yearage1=adj_age1
 gen yearage2=adj_age4
 gen yearage3=adj_age7
 gen yearage4=adj_age8
 gen yearage5=adj_age13
  
* is there a lot of missing on earnings where interview present? 
  
* for individuals fully observed in a year, calculate an earnings ratio for the year

forvalues y=1/5 {
  gen year_pearn`y'=0
  gen year_hearn`y'=0
  forvalues o=1/3 {
    local w=(`y'-1)*3 + `o'
    replace year_pearn`y'=year_pearn`y'+tpearn`w' if inyear`y'==3 & nmpyear`y'==3
	replace year_hearn`y'=year_hearn`y'+thearn`w' if inyear`y'==3 & nmhyear`y'==3
  }
  gen yearbw50`y'=0 if !missing(year_pearn`y') & !missing(year_hearn`y')
  gen yearbw60`y'=0 if !missing(year_pearn`y') & !missing(year_hearn`y')
  replace yearbw50`y'=1 if year_pearn`y' > 0.5*year_hearn`y' & yearbw50`y'==0
  replace yearbw60`y'=1 if year_pearn`y' > 0.6*year_hearn`y' & yearbw60`y'==0
  
  sum year_pearn`y'
  sum year_hearn`y'
  tab yearbw50`y' if inyear`y'==3
 }
 
 forvalues y=1/4 {
   local z=`y'+1
   gen ybecome_bw50`y'=0 if !missing(yearbw50`y')
   replace ybecome_bw50`y'=1 if ybecome_bw50`y'==0 & yearbw50`y'==0 & yearbw50`z'==1
 }
 
 keep ssuid epppnum year_pearn* year_hearn* yearbw50* yearbw60* inyear* nmpyear* nmhyear* yearage* ybecome_bw50* my_race my_race2 my_sex
 
 reshape long year_pearn year_hearn yearbw50 yearbw60 inyear nmpyear nmhyear yearage ybecome_bw50, i(`i_variables') j(year)
  
save "$tempdir/relearn_year.dta", replace

tab yearbw50

keep if inyear==3

tab yearbw50
