*-------------------------------------------------------------------------------
* BREADWINNER PROJECT - NLSY97 Component
* nlsy97_bw measures.do
* Joanna Pepin
*-------------------------------------------------------------------------------
* The goal of these files is to create the breadwinning measures to corroborate
* creation of measures in R.

********************************************************************************
* Setup the log file
********************************************************************************
local logdate = string( d(`c(current_date)'), "%dCY.N.D" ) 	// create a macro for the date

local list : dir . files "$logdir/*nlsy97_bw_measures_*.log"	// Delete earlier versions of the log
foreach f of local list {
    erase "`f'"
}

log using "$logdir/nlsy97_bw_measures_`logdate'.log", t replace

di "$S_DATE"

********************************************************************************
* Open and prep the data
********************************************************************************
clear
set more off

use 	"stata/NLSY97.dta", clear
fre year // Make sure the data includes all survey years (1997 - 2017)

// Keep only mothers in first 10 years of motherhood
unique 	PUBID_1997 
keep if time >=0 & time <= 10 & firstbirth ==1
unique 	PUBID_1997

order PUBID_1997 year birth_year time momearn wages mombiz totinc hhearn

********************************************************************************
* Create BW variables
********************************************************************************
cap drop 	momtot
egen 		momtot	=rowtotal(wages mombiz)
replace 	momtot 	=. if wages ==. | mombiz ==.

// Make sure new mom income var matches the one created in Stata
assert 		momearn == momtot
assert 		hhearn  == totinc // totinc is NLSY provided var. hhearn is same var

// Create a hh total income variable
cap drop 	hhtot
egen 		hhtot= rowtotal(wages mombiz chsup dvdend gftinc govpro1 govpro2 govpro3 	///
							inhinc intrst othinc rntinc wcomp hhinc spwages spbiz  		///
							wcomp_sp)
replace 	hhtot 	=. if totinc==.

*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?
*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?*?
* My constructed total household income variable doesn't match the NLSY provided one.
unique 	PUBID_1997
unique 	PUBID_1997 if totinc != hhtot

sum totinc
sum hhtot

browse 	PUBID_1997 year time momearn momtot wages mombiz totinc hhtot if totinc != hhtot
list 	PUBID_1997 year time momearn momtot wages mombiz totinc hhtot if totinc != hhtot in 1/50


// Create indicator for negative household earnings & no earnings. 
cap drop hh_noearnings
gen 	hh_noearnings= (hhearn <= 0 | hhearn ==.)

// 50% breadwinning threshold
* There are lagged because R reports income for prior year
cap drop hhe50lag
gen 	 hhe50lag = (momearn > .5*hhearn) if  hh_noearnings !=1 & !missing(momearn)

	// Fix the lagged variable
	sort PUBID_1997 time
	by PUBID_1997: gen hhe50 = hhe50lag[_n+1]

	* Not doing this like in SIPP. It would make missing not a breadwinner and we don't know.
	* replace  hhe50= 0 					if hh_noearnings==1 


// 60% breadwinning threshold
cap drop hhe60lag
gen 	 hhe60lag = (momearn > .6*hhearn) if  hh_noearnings !=1 & !missing(momearn)


	// Fix the lagged variable
	sort PUBID_1997 time
	by PUBID_1997: gen hhe60 = hhe60lag[_n+1]

	* Not doing this like in SIPP. It would make missing not a breadwinner and we don't know.
	* replace  hhe60= 0 					if hh_noearnings==1 

order PUBID_1997 year birth_year time momearn hhearn hhe50 hhe60 wages mombiz
browse

tab hhe50
tab hhe60

keep if time <=9 // Keep only first 10 years of motherhood
********************************************************************************
* Describe percent breadwinning in the first year
********************************************************************************
// The percent breadwinning (50% threhold) in the first year. (~25%)
	sum hhe50 if time		==0 // Breadwinning in the year of the birth

	gen per_hhe50_atbirth	=100*`r(mean)'
	gen nothhe50_atbirth		=1-`r(mean)'

// The percent breadwinning (60% threhold) in the first year. (~17%)
	sum hhe60 if time		==0 // Breadwinning in the year of the birth

	gen per_hhe60_atbirth	=100*`r(mean)'
	gen nothhe60_atbirth		=1-`r(mean)'

save "stata/NLSY97_processed.dta", replace

log close
