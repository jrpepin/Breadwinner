*-------------------------------------------------------------------------------
* BREADWINNER PROJECT - NLSY97 Component
* nlsy97_time-varying.do
* Joanna Pepin
*-------------------------------------------------------------------------------

* The goal of this file is to create the time-varying covariates.
* Data comes from working memory produced by "nlsy97_sample & demo.do"

********************************************************************************
* Setup the log file
********************************************************************************
local logdate = string( d(`c(current_date)'), "%dCY.N.D" ) 		// create a macro for the date

local list : dir . files "$logdir/*nlsy97_time-varying_*.log"	// Delete earlier versions of the log
foreach f of local list {
    erase "`f'"
}

log using "$logdir/nlsy97_time-varying_`logdate'.log", t replace

di "$S_DATE"

********************************************************************************
* Create long mini-data files for processing
********************************************************************************

foreach var in 	YINC_1400 YINC_1500 YINC_1700 YINC_1800 ///
				YINC_2000 YINC_2100 YINC_2200 			///
				CV_INCOME_GROSS_YR CV_INCOME_FAMILY {
preserve
	keep PUBID_1997 `var'_*
	reshape long `var'_, i( PUBID_1997 ) j(year)
	save "$tempdir/nlsy97_`var'.dta", replace
restore
}

********************************************************************************
* Merge them all together and process
********************************************************************************
use "$tempdir/nlsy97_YINC_1400.dta", clear

merge 1:1 PUBID_1997 year using "$tempdir/nlsy97_YINC_1500.dta"
drop _merge
merge 1:1 PUBID_1997 year using "$tempdir/nlsy97_YINC_1700.dta"

// Moms' Income Variables-------------------------------------------------------

// YINC-1400 - R RECEIVE INCOME FROM JOB IN PAST YEAR? (incd)
// YINC-1500 - INCOME IN WAGES, SALARY, TIPS FROM REGULAR OR ODD JOBS (incd2)
// YINC-1700 - TOTAL INCOME FROM WAGES AND SALARY IN PAST YEAR (wages)
// YINC-1800 - ESTIMATED INCOME FROM WAGES AND SALARY IN PAST YEAR (wages_est)


// Moms' Business earnings------------------------------------------------------

// YINC-2000 - ANY INCOME FROM OWN BUSINESS OR FARM IN PAST YEAR (mombizd)
// YINC-2100 - TOTAL INCOME FROM BUSINESS OR FARM IN PAST YEAR (mombiz)
// YINC-2200 - ESTIMATED INCOME FROM BUSINESS OR FARM IN PAST YEAR (mombiz_est)


********************************************************************************
* Merge with wide file data
********************************************************************************

// Then create a "time -- motherhood duration variable" limit to moms with duration <= 10
