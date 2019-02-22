*****************************************************************************
*  create annual measures of earnings 
*****************************************************************************

* first, make the file wide

use "$tempdir/relearn.dta", clear

local i_variables " ssuid epppnum "
local j_variables " swave "
local other_variables "nmomto nbiomomto HHsize nHHkids spartner adj_age EBORNUS EMS EORIGIN ERRP thearn tfearn thothinc tpearn pHHearn momtoany momtoanyminor nHHadults bw50 bw60 fbw50 fbw60 WPFINWGT"

keep `j_variables' `i_variables' `other_variables' my_racealt my_sex

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
  gen nobsmom`y'=0
  gen nobsmomminor`y'=0
  forvalues o=1/3 {
    local w=(`y'-1)*3 + `o'
    replace inyear`y'=inyear`y'+1 if in`w'==1 
	replace nmpyear`y'=nmpyear`y'+1 if nmpearn`w'==1
	replace nmhyear`y'=nmhyear`y'+1 if nmhearn`w'==1
	replace nobsmom`y'=nobsmom`y'+1 if momtoany`w'==1
	replace nobsmomminor`y'=nobsmomminor`y'+1 if momtoanyminor`w'==1
  }
  tab inyear`y'
  tab nobsmomminor`y'
  }

 local y=0 
foreach w of numlist 1 4 7 8 13 {
   local y=`y'+1
   display `w'
   display `y'
   gen yearage`y'=adj_age`w'
   gen yearspartner`y'=spartner`w'
   gen weight`y'=WPFINWGT`w'
 }

* is there a lot of missing on earnings where interview present? 
  
* calculate earnings in each year first by summing non-missing values

forvalues y=1/5 {
  gen nmyear_pearn`y'=0
  gen nmyear_hearn`y'=0
  forvalues o=1/3 {
    local w=(`y'-1)*3 + `o'
    replace nmyear_pearn`y'=nmyear_pearn`y'+tpearn`w' if !missing(tpearn`w')
	replace nmyear_hearn`y'=nmyear_hearn`y'+thearn`w' if !missing(thearn`w')
  }
}
 * annualize (both to match variable name and to adjust for missing observations)
 
 forvalues y=1/5 {
   gen year_pearn`y'=nmyear_pearn`y'*4 if inyear`y'==3 /* if observed 3 times in the year */
   replace year_pearn`y'=nmyear_pearn`y'*6 if inyear`y'==2 /* if observed twice */
   replace year_pearn`y'=nmyear_pearn`y'*12 if inyear`y'==1 /* if observed once */
   
   gen year_hearn`y'=nmyear_hearn`y'*4 if inyear`y'==3 /* if observed 3 times in the year */
   replace year_hearn`y'=nmyear_hearn`y'*6 if inyear`y'==2 /* if observed twice */
   replace year_hearn`y'=nmyear_hearn`y'*12 if inyear`y'==1 /* if observed once */
 }
 
 * create breadwinner dummies at > 50% and > 60 % of household income
  
forvalues y=1/5 {
  gen yearbw50`y'=0 if !missing(year_pearn`y') & !missing(year_hearn`y')
  gen yearbw60`y'=0 if !missing(year_pearn`y') & !missing(year_hearn`y')
  replace yearbw50`y'=1 if year_pearn`y' > 0.5*year_hearn`y' & yearbw50`y'==0
  replace yearbw60`y'=1 if year_pearn`y' > 0.6*year_hearn`y' & yearbw60`y'==0
  
  sum year_pearn`y'
  sum year_hearn`y'
  tab yearbw50`y' 
  
  replace yearbw50`y'=9 if inyear`y'==0
  replace yearbw60`y'=9 if inyear`y'==0
 }
 
 forvalues y=1/4 {
   local z=`y'+1
   gen ybecome_bw50`y'=0 if !missing(yearbw50`y')
   replace ybecome_bw50`y'=1 if ybecome_bw50`y'==0 & yearbw50`y'==0 & yearbw50`z'==1
   replace ybecome_bw50`y'=2 if ybecome_bw50`y'==0 & yearbw50`y'==1
 }

egen momprofile = concat (nobsmom1 nobsmom2 nobsmom3 nobsmom4 nobsmom5)
egen momminorprofile = concat (nobsmomminor1 nobsmomminor2 nobsmomminor3 nobsmomminor4 nobsmomminor5)
egen bw50profile = concat (yearbw501 yearbw502 yearbw503 yearbw504 yearbw505)
egen bw60profile = concat (yearbw601 yearbw602 yearbw603 yearbw604 yearbw605)
 
 tab momminorprofile
 tab bw50profile
 tab bw60profile
 
 keep ssuid epppnum year_pearn* year_hearn* yearbw50* yearbw60* inyear* nmpyear* nmhyear* yearage* ybecome_bw50* nobsmom* yearspartner* my_racealt my_sex *profile weight*
 
 reshape long year_pearn year_hearn yearbw50 yearbw60 inyear nmpyear nmhyear yearage ybecome_bw50 nobsmom nobsmomminor yearspartner weight, i(`i_variables') j(year)
  
save "$tempdir/relearn_year.dta", replace




