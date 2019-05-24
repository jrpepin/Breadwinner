*****************************************************************************
*  create annual measures of earnings 
*****************************************************************************

* first, make the file wide

use "$tempdir/relearn.dta", clear

tab educ, m

local i_variables " ssuid epppnum "
local j_variables " swave "
local other_variables "nmomto nbiomomto HHsize nHHkids spartner adj_age EBORNUS EMS EORIGIN ERRP thearn tfearn thtotinc tpearn momtoany momtoanyminor nHHadults WPFINWGT altpearn altfearn althearn ualtpearn ualtfearn ualthearn anyallocate ageoldest educ"

keep `j_variables' `i_variables' `other_variables' my_race msbirth tfbrthyr

reshape wide `other_variables', i(`i_variables') j(`j_variables')

gen hieduc=educ1
forvalues w=2/15{
 replace hieduc=educ`w' if educ`w' > hieduc & !missing(educ`w')
}

 *******************************************************************************
 * Indicators for transitions into motherhood (1st births during panel)
 *******************************************************************************

 gen firstbirth=.
 forvalues y=1/15{
	replace firstbirth=`y' if missing(firstbirth) &  momtoanyminor`y'==1
}
	
*******************************************************************************
* indicators for in each wave (w)
*******************************************************************************

forvalues w=1/15 {
gen in`w'=0
gen nmpearn`w'=0
gen nmhearn`w'=0
gen nmupearn`w'=0
gen nmuhearn`w'=0
gen anyhhinc`w'=0
replace in`w'=1 if !missing(ERRP`w')
replace nmpearn`w'=1 if !missing(altpearn`w')
replace nmhearn`w'=1 if !missing(althearn`w')
replace nmupearn`w'=1 if !missing(ualtpearn`w')
replace nmuhearn`w'=1 if !missing(ualthearn`w')
replace anyhhinc`w'=1 if thtotinc`w' > 0 & !missing(thtotinc`w')
}

* create indicators of number of observations in each year, where a year is a collection 
* of three consecutive waves. (Does not correspond to calendar year)

forvalues y=1/5 {
  gen inyear`y'=0
  gen nmpyear`y'=0
  gen nmhyear`y'=0
  gen nmpuyear`y'=0
  gen nmhuyear`y'=0
  gen nobsmom`y'=0
  gen nobsmomminor`y'=0
  gen yanyhhinc`y'=0
  forvalues o=1/3 {
    local w=(`y'-1)*3 + `o'
    replace inyear`y'=inyear`y'+1 if in`w'==1 
    replace nmpyear`y'=nmpyear`y'+1 if nmpearn`w'==1
    replace nmhyear`y'=nmhyear`y'+1 if nmhearn`w'==1
    replace nmpuyear`y'=nmpuyear`y'+1 if nmupearn`w'==1
    replace nmhuyear`y'=nmhuyear`y'+1 if nmuhearn`w'==1
    replace nobsmom`y'=nobsmom`y'+1 if momtoany`w'==1
    replace nobsmomminor`y'=nobsmomminor`y'+1 if momtoanyminor`w'==1
    replace yanyhhinc`y'=yanyhhinc`y'+1 if anyhhinc`w'==1
  }
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
  gen nmyear_upearn`y'=0
  gen nmyear_uhearn`y'=0
  forvalues o=1/3 {
    local w=(`y'-1)*3 + `o'
    replace nmyear_pearn`y'=nmyear_pearn`y'+altpearn`w' if !missing(altpearn`w')
    replace nmyear_hearn`y'=nmyear_hearn`y'+althearn`w' if !missing(althearn`w')
    replace nmyear_upearn`y'=nmyear_upearn`y'+ualtpearn`w' if !missing(ualtpearn`w')
    replace nmyear_uhearn`y'=nmyear_uhearn`y'+ualthearn`w' if !missing(ualthearn`w')   
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

   gen year_upearn`y'=nmyear_upearn`y'*4 if nmpuyear`y'==3 /* if observed 3 times in the year */
   replace year_upearn`y'=nmyear_upearn`y'*6 if nmpuyear`y'==2 /* if observed twice */
   replace year_upearn`y'=nmyear_upearn`y'*12 if nmpuyear`y'==1 /* if observed once */
   
   gen year_uhearn`y'=nmyear_uhearn`y'*4 if nmhuyear`y'==3 /* if observed 3 times in the year */
   replace year_uhearn`y'=nmyear_uhearn`y'*6 if nmhuyear`y'==2 /* if observed twice */
   replace year_uhearn`y'=nmyear_uhearn`y'*12 if nmhuyear`y'==1 /* if observed once */
 }
 
 * create breadwinner dummies at > 50% and > 60 % of household income
  
forvalues y=1/5 {
  gen yearbw50`y'=0 if !missing(year_pearn`y') & !missing(year_hearn`y')
  gen yearbw60`y'=0 if !missing(year_pearn`y') & !missing(year_hearn`y')

  replace yearbw50`y'=1 if year_pearn`y' >= 0.5*year_hearn`y' & yearbw50`y'==0
  replace yearbw60`y'=1 if year_pearn`y' >= 0.6*year_hearn`y' & yearbw60`y'==0
  
  replace yearbw50`y'=. if nmhyear`y'==0
  replace yearbw60`y'=. if nmhyear`y'==0
  
  * variables limited to unallocated data
  
  gen uyearbw50`y'=0 if !missing(year_upearn`y') & !missing(year_uhearn`y')
  gen uyearbw60`y'=0 if !missing(year_upearn`y') & !missing(year_uhearn`y')

  replace uyearbw50`y'=1 if year_upearn`y' >= 0.5*year_uhearn`y' & uyearbw50`y'==0 // Primary earning
  replace uyearbw60`y'=1 if year_upearn`y' >= 0.6*year_uhearn`y' & uyearbw60`y'==0

  replace uyearbw50`y'=2 if year_upearn`y'==year_uhearn`y' & uyearbw50`y'==1 // Sole earning
  replace uyearbw60`y'=2 if year_upearn`y'==year_uhearn`y' & uyearbw60`y'==1

  replace uyearbw50`y'=0 if uyearbw50`y'==1 & year_uhearn`y'==0 // if household income is zero, then not breadwinning
  replace uyearbw60`y'=0 if uyearbw60`y'==1 & year_uhearn`y'==0 
  
  replace uyearbw50`y'=. if nmhuyear`y'==0
  replace uyearbw60`y'=. if nmhuyear`y'==0
 }

* Create lagged measures of breadwinning

forvalues y=2/5 {
	local x=`y'-1
	gen uybw50L1_`y'=uyearbw50`x'
        gen uybw60L1_`y'=uyearbw60`x'
	gen nobsmomminorL1_`y'=nobsmomminor`x'
}

forvalues y=3/5 {
	local x=`y'-2
	gen uybw50L2_`y'=uyearbw50`x'
        gen uybw60L2_`y'=uyearbw60`x'
}

forvalues y=4/5 {
	local x=`y'-3
	gen uybw50L3_`y'=uyearbw50`x'
        gen uybw60L3_`y'=uyearbw60`x'
}

gen uybw50L4_5=uyearbw501
gen uybw60L4_5=uyearbw601


* Indicators of ever having breadwon (to censor at first breadwinning in single-decrement analysis)
* The multistate lifetable does not use these measures

gen everbw50=.
gen everbw60=.
gen ueverbw50=.
gen ueverbw60=.

 forvalues y=1/4 {
     local z=`y'+1
   replace everbw50=0 if missing(everbw50) & !missing(yearbw50`y') 
   gen becbw50`y'=0 if !missing(yearbw50`y') & everbw50!=1
   replace becbw50`y'=1 if becbw50`y'==0 & yearbw50`y'==0 & yearbw50`z'==1 
   replace becbw50`y'=2 if becbw50`y'==0 & yearbw50`y'==1
   replace becbw50`y'=2 if everbw50==1
   replace everbw50=1 if inlist(becbw50`y',1,2) // marking so that ineligble to become bw again

   replace everbw60=0 if missing(everbw60) & !missing(yearbw60`y')
   gen becbw60`y'=0 if !missing(yearbw60`y') & everbw60!=1
   replace becbw60`y'=1 if becbw60`y'==0 & yearbw60`y'==0 & yearbw60`z'==1 
   replace becbw60`y'=2 if becbw60`y'==0 & yearbw60`y'==1
   replace becbw60`y'=2 if everbw60==1
   replace everbw60=1 if inlist(becbw60`y',1,2) // marking so that ineligble to become bw again

   replace ueverbw50=0 if missing(ueverbw50) & !missing(uyearbw50`y')
   gen ubecbw50`y'=0 if !missing(yearbw50`y') & ueverbw50!=1
   replace ubecbw50`y'=1 if ubecbw50`y'==0 & uyearbw50`y'==0 & uyearbw50`z'==1 
   replace ubecbw50`y'=2 if ubecbw50`y'==0 & uyearbw50`y'==1
   replace ubecbw50`y'=2 if ueverbw50==1
   replace ueverbw50=1 if inlist(ubecbw50`y',1,2) // marking so that ineligble to become bw again

   replace ueverbw60=0 if missing(ueverbw60) & !missing(uyearbw60`y')
   gen ubecbw60`y'=0 if !missing(yearbw60`y') & ueverbw60!=1
   replace ubecbw60`y'=1 if ubecbw60`y'==0 & uyearbw60`y'==0 & uyearbw60`z'==1
   replace ubecbw60`y'=2 if ubecbw60`y'==0 & uyearbw60`y'==1
   replace ubecbw60`y'=2 if ueverbw60==1
   replace ueverbw60=1 if inlist(ubecbw60`y',1,2) // marking so that ineligble to become bw again
 }

 keep ssuid epppnum year_pearn* year_hearn* year_upearn* year_uhearn* yearbw50* yearbw60* uyearbw50* uyearbw60* inyear* nmpyear* nmhyear* yearage* becbw50* becbw60* ubecbw50* ubecbw60* nobsmom* yearspartner* my_race hieduc weight* ageoldest* msbirth tfbrthyr uybw50L* uybw60L* nobsmomminorL1_* firstbirth yanyhhinc*
 
 reshape long year_pearn year_hearn yearbw50 yearbw60 inyear nmpyear nmhyear yearage becbw50 becbw60 ubecbw50 ubecbw60 nobsmom nobsmomminor yearspartner weight year_upearn year_uhearn uyearbw50 uyearbw60 ageoldest uybw50L1_ uybw50L2_ uybw50L3_ uybw50L4_ uybw60L1_ uybw60L2_ uybw60L3_ uybw60L4_ nobsmomminorL1_ yanyhhinc, i(`i_variables') j(y)

* drops cases not observed in a year plus all the data organized by wave
drop if missing(inyear)
 
label define trans 0 "Not breadwinner" 1 "Became breadwinner" 2 "Already breadwinner"

label values becbw50 becbw60 trans

label variable uyearbw50 "Breadwinning status (> 50%) without allocated data"
label variable uyearbw60 "Breadwinning status (> 60%) without allocated data"

label variable yearbw50 "Breadwinning status (> 50%) with allocated data"
label variable yearbw60 "Breadwinning status (> 60%) with allocated data"

label define y 1 "Q4 08" 2 "Q4 09" 3 "Q4 10" 4 "Q4 11" 5 "Q4 12"
label variable y "year of observation"

gen ratio=year_pearn/year_hearn
gen uratio=year_upearn/year_uhearn

gen catratio=int(ratio*10) if ratio >= 0 & ratio <= 1
replace catratio=-1 if ratio < 0
replace catratio=20 if ratio > 1

tab uybw50L1_, m
tab uybw50L1_ uyearbw50, m

save "$tempdir/relearn_year.dta", replace




