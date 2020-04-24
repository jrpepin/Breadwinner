*-------------------------------------------------------------------------------
* BREADWINNER PROJECT - NLSY97 Component
* nlsy97_sample & demo.do
* Joanna Pepin
*-------------------------------------------------------------------------------
* The goal of this file is to create the breadwinning measures.

********************************************************************************
* Setup the log file
********************************************************************************
local logdate = string( d(`c(current_date)'), "%dCY.N.D" ) 		// create a macro for the date

local list : dir . files "$logdir/*nlsy97_sample & demo_*.log"	// Delete earlier versions of the log
foreach f of local list {
    erase "`f'"
}

log using "$logdir/nlsy97_sample & demo_`logdate'.log", t replace

di "$S_DATE"

********************************************************************************
* Open and prep the data
********************************************************************************
clear
set more off

infile using 	"data/nlsy9717.dct"

* Before running the next script, remove the comment markers so that variables are renamed
* Also had to delete all instances of "KEY!" so it will run.
do 				"data/nlsy9717-value-labels"

// Count respondents and check for wide file format.
duplicates report PUBID_1997
assert r(N) == r(unique_value)

// Create a macro with the total number of respondents in the dataset.
	egen all = nvals(PUBID_1997)
	global all_n = all
	di "$all_n"

********************************************************************************
* Limit to mothers
********************************************************************************

** Keep only women--------------------------------------------------------------
fre 		SEX_1997
rename 		SEX_1997 female
keep if 	female == 2 		// Keep only women
unique 		PUBID_1997			// Number of women in sample

	egen women = nvals(PUBID_1997)
	global women_n = women
	di "$women_n"

** Keep only mothers------------------------------------------------------------

// Recode birth year variables with missing for non-moms
cap drop mom_yr
foreach var of varlist CV_CHILD_BIRTH_DATE_01_Y_*{
    gen c_`var' = `var' if `var' >= 1992
}

egen 		mom_yr = rowmax(c_*)	// Identify the birth year of first child
drop 		c_*
fre 		mom_yr
label var	mom_yr "Birth year of 1st child"

keep if 	mom_yr !=.				// Keep only mothers
unique 		PUBID_1997				// Number of mothers in sample

	egen mom = nvals(PUBID_1997)
	global mom_n = mom
	di "$mom_n"
	
********************************************************************************
* Demographic Variables
********************************************************************************

** DOB--------------------------------------------------------------------------

fre BDATE*

label values BDATE_M_1997 . // Remove value labels
tostring BDATE*, replace	// Make them string variables

gen day = 1					// Create a day var

// Combine DOB vars and make them dates
cap drop 	dob_MDY
egen 		dob_MDY		= concat(BDATE_M_1997 day BDATE_Y_1997), punct(-)
gen 		datbirth	= date(dob_MDY, "MDY")
format %td 	datbirth
drop 		dob_MDY

** 1st Child DOB----------------------------------------------------------------

// Recode birth month variables with missing for non-yet-moms
cap drop mom_m
foreach var of varlist CV_CHILD_BIRTH_DATE_01_M_*{
    gen c_`var' = `var' if `var' >= 1 // 1 = January
}

egen 		mom_m = rowmax(c_*)	// Identify the birth month of first child
drop 		c_*
fre 		mom_m

// Convert and combine child DOB vars
describe mom_*
tostring mom_*, replace			// Make them string variables to create dob vars

cap drop 	dob_child1
egen 		dob_child1	= concat(mom_m day mom_yr), punct(-)
gen 		datchild1	= date(dob_child1, "MDY")
format %td 	datchild1
drop 		dob_child1

** Age at 1st birth-------------------------------------------------------------
cap drop 	age_birth
gen 		age_birth	=floor((datchild1 - datbirth)/365.25)
fre			age_birth
label var	age_birth "Moms age at 1st birth"

** Marital Status at 1st birth--------------------------------------------------
// Rs marital or cohabitation status as of the survey date.
summarize CV_MARSTAT_*

snapshot save, label("nlsy97_temp")		// Create a temporary copy of data in memory

// Reshape the data to generate marital status at time 1 var
	keep 		PUBID_1997 mom_yr CV_MARSTAT_*
	reshape long CV_MARSTAT_, i(PUBID_1997) j(year)

	destring 	mom_yr, replace

// Create marital status at year of fist birth var
	cap drop 	marst
	clonevar 	marst = CV_MARSTAT_ if year == mom_yr
	
// Process and label marst var
	cap drop	mar_t1
	recode 		marst (2=1)(1=2)(3/4=3)(5=2) (6 =4) (7=2) (8=4) (10=4) (else = .) , gen(mar_t1)

label define mar   1 "Never married"	///
                   2 "Cohabiting"		///
                   3 "Married"			///
                   4 "Sep/Div/Wid"
		
label values 	mar_t1 mar
label var 		mar_t1 "Marital status at time of 1st birth"
	
	keep PUBID_1997 mar_t1
	drop if 		mar_t1 ==.
	count
	
	save "$tempdir/nlsy97_marstat.dta", replace

// recall the original data in memory
	snapshot restore 1			

// Merge maritatl status at time 1 to original data
merge 1:1 PUBID_1997 using "$tempdir/nlsy97_marstat.dta"
// _merge==1 are moms with missing marital staus at birth year
drop _merge

// Remove temporary data
capture erase 	"$tempdir/nlsy97_marstat.dta"		
snapshot erase 	1

** Education completed at 1st birth---------------------------------------------
// What is the highest grade you have ever completed as of today?
summarize YSCH_3112_*

snapshot save, label("nlsy97_temp")	// Create a temporary copy of data in memory

// Reshape the data to generate marital status at time 1 var
	keep 		PUBID_1997 mom_yr YSCH_3112_*
	reshape long YSCH_3112_, i(PUBID_1997) j(year)

// Format vars for processing
	destring 	mom_yr, 	replace
	gen int 	educ = YSCH_3112_	// create integer var to use "max" command

// Create education attainment at year of fist birth var
	cap drop 				educ_t1
	by PUBID_1997: gen 		educ_t1 = educ if year <= mom_yr & YSCH_3112_ >= 0
	
	egen max_edu = max(educ_t1), by(PUBID_1997) // capture highest level of educ

// Process and label educ var
	drop	educ_t1
	recode max_edu (6/11=1)(12=2)(13/15=3)(16/20=4) (95 =.) , gen(educ_t1)

label define ed    1 "less than hs"		///
                   2 "high school"		///
                   3 "some college"		///
                   4 "college grad"
		
label values 	educ_t1 ed
label var 		educ_t1 "Education at time of 1st birth"

//Clean up and reshape data for merge
	keep if year == mom_yr // 1 row per respondent
	keep PUBID_1997 educ_t1

	save "$tempdir/nlsy97_educ.dta", replace
	
// recall the original data in memory
	snapshot restore 1			

// Merge education attainment at time 1 to original data
merge 1:1 PUBID_1997 using "$tempdir/nlsy97_educ.dta"
// _merge==1 are moms with missing educational attainment at birth year
drop _merge

// Remove temporary data
capture erase 	"$tempdir/nlsy97_educ.dta"		
snapshot erase 	1
********************************************************************************
* Sample Restrictions
********************************************************************************
fre 		age_birth 

// Create a macro with the total number of adult mothers in the dataset.
	egen 	mom18plus = nvals(PUBID_1997) 	if age_birth >= 18
	global 	mom18plus_n = mom18plus

// Create a macro with the total number of mothers < 30 yrs old at first birth.
	egen 	momunder30 = nvals(PUBID_1997)	if age_birth >=18 & age_birth <= 30
	global 	momunder30_n = momunder30		

// Limit to mothers 18 - 30 at first birth
keep if 	age_birth >= 18
keep if 	age_birth <= 30

// Display lost cases macros
di "$all_n" 		// Total # respondents
di "$women_n"		// Total # women
di "$mom_n" 		// Total # mothers
di "$mom18plus_n"	// Total # moms 18+ at first birth
di "$momunder30_n"	// Total # moms <30 at first birth

save "$tempdir/nlsy97_sample.dta", replace

log close
