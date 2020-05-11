*-------------------------------------------------------------------------------
* BREADWINNER PROJECT
* extract_and_format.do
* Kelly Raley and Joanna Pepin
*-------------------------------------------------------------------------------
di "$S_DATE"

********************************************************************************
* DESCRIPTION
********************************************************************************
* This script creates two datasets: 
	* 1) All waves for Type 1 people
	* 2) All waves for Type 2 people

* The data files used in this script were produced by extract_and_format.do

********************************************************************************
* Merge waves for type 1 (interviewed respondents)
********************************************************************************

// Import first wave. 
use "$SIPP14keep/wave1_extract", clear 

// Append the first wave with waves from the second to last
forvalues wave = 2/4 {
    append using "$SIPP14keep/wave`wave'_extract"
}

// allmonths14.dta is a long-form dataset including all the waves from SIPP2014
save "$SIPP14keep/allmonths14.dta", replace

********************************************************************************
* Merge waves for type 2 (former household residents)
********************************************************************************

** Import first wave. 
use "$SIPP14keep/wave1_type2_extract", clear 

// Append the first wave with waves from the second to last
forvalues wave = 2/4 {
    append using "$SIPP14keep/wave`wave'_type2_extract"
}

// allmonths14.dta is a long-form dataset including all the waves from SIPP2014
save "$SIPP14keep/allmonths14_type2.dta", replace
