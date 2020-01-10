*-------------------------------------------------------------------------------
* BREADWINNER PROJECT
* extract_and_format.do
* Kelly Raley and Joanna Pepin
*-------------------------------------------------------------------------------
di "$today"

********************************************************************************
* DESCRIPTION
********************************************************************************
* Extracts personal earnings from all SIPP 2014 Waves

* The data files used in this script are the compressed data files that we
* created from the Census data files. 
* These files lack variable labels, unfortnuately.
*********************************************************************

********************************************************************************
* Read in each original, compressed, data set and extract the key variables
********************************************************************************
clear
set maxvar 5300

   forvalues w=1/4{
      use "$SIPP2014/pu2014w`w'_compressed.dta"
      keep 	swave 		monthcode		ssuid 		pnum 						/// /* TECHNICAL   */	
			shhadid 	eresidenceid 	wpfinwgt								///
			tpearn 		apearn 			tjb?_msum 	ajb?_msum 					/// /* FINANCIAL   */
			erace 		esex 			tage 		eeduc 		tceb 	tcbyr_* 	/* DEMOGRAPHIC */
      
	  gen year = 2012+`w'
      save "$tempdir/sipp14tpearn`w'", replace
   }

clear

********************************************************************************
* Stack all the extracts into a single file 
********************************************************************************

// Import first wave. 
   use "$tempdir/sipp14tpearn1"

// Append the remaining waves
   forvalues w=2/4{
      append using "$tempdir/sipp14tpearn`w'"
   }

********************************************************************************
* Create and format variables
********************************************************************************
// Create a panel month variable ranging from 1(01/2013) to 48 (12/2016)
	gen panelmonth = (swave-1)*12+monthcode
	
// Capitalize variables to be compatible with household composition indicators
	rename ssuid SSUID
	rename eresidenceid ERESIDENCEID
	rename pnum PNUM

// Create a measure of total household earnings per month (with allocated data)
	* Note that this approach omits the earnings of type 2 people.
    egen thearn = total(tpearn), 	by(SSUID ERESIDENCEID swave monthcode)

// Count number of earners in hh per month
    egen numearner = count(tpearn),	by(SSUID ERESIDENCEID swave monthcode)

// Create an indictor of the birth year of the first child 
    gen yrfirstbirth = tcbyr_1 

	* If a birth of the second child or later is earlier than the year of the first child's birth,
	* replace the yrfirstbirth with the date of the firstborn.
	forvalues birth = 2/12 {
		replace yrfirstbirth = tcbyr_`birth' if tcbyr_`birth' < yrfirstbirth
	}

// Create an indicator of how many years have elapsed since individual transitioned to parenthood
	* Note that we add 1 to year to reflect year of interview rather than calendar year 
	* of the reference month because year of birth measures are as of interview. 
	* This is why we add _atint (i.e. "at interview") to the variable.
   gen dursinceb1_atint=year+1-yrfirstbirth if !missing(yrfirstbirth)
	
// check that year of first birth is > respondents year of birth+9

   gen 		mybirthyear		= year-tage
   gen 		birthyear_error	= 1 			if mybirthyear+9  > yrfirstbirth & !missing(yrfirstbirth)  // too young
   replace 	birthyear_error	= 1 			if mybirthyear+50 < yrfirstbirth & !missing(yrfirstbirth)  // too old
   
      *?*?*?*?*?*?*?* Do we do anything with this besides generating it?
	  /*
	  Shouldn't we drop these peeps?
	  drop if birthyear_error == 1 
	  */
********************************************************************************
* Create the analytic sample
********************************************************************************
* Keep observations of women in first 18 years since first birth. 
	*?*?*? This seems like a different thing than first birth occuring within 
	* the 25 years prior to each interview.

// First, count the total number of respondents in the original sample.
	sort SSUID PNUM
	egen 	tagid 	= tag(SSUID PNUM)
	replace tagid	= . if tagid !=1 

	egen 	all		= count(tagid)

// Create a macro with the total number of respondents in the dataset.
	global allindividuals = all

* Then, keep only the respondents that meet sample criteria

// Keep only women
	tab 	esex 		if tagid==1
	replace tagid = . 	if esex ==1 // men
	egen	women = count(tagid)
	keep 				if esex==2
	
	// Creates a macro with the total number of women in the dataset.
	global women_n = women

// Only keep mothers
	tab 	dursinceb1_atint 	if tagid==1, m
	replace tagid = .  			if dursinceb1_atint ==. // not mothers
	egen	mothers = count(tagid)
	keep 						if dursinceb1_atint !=.
	
	// Creates a macro with the total number of mothers in the dataset.
	global mothers_n = mothers

// Keep only if first birth occurred at least 1 year prior to reference period
	replace tagid = . 			if dursinceb1_atint ==0	 // new mothers
	egen	notnew = count(tagid)
	drop 						if dursinceb1_atint ==0

	// Creates a macro with the total number of mothers left in the dataset.
	global minus_newmoms = notnew
	
// Keep only if first birth occurred less than 25 years prior to reference period
	replace tagid = . 			if dursinceb1_atint >25	 // old mothers
	egen	notold = count(tagid)
	drop 						if dursinceb1_atint >25

	// Creates a macro with the total number of mothers left in the dataset.
	global minus_oldmoms = notold

// Clean up dataset
	drop all women mothers notnew notold tagid
********************************************************************************
* Describe the analytic sample
********************************************************************************
sort SSUID PNUM
egen 	tagid = tag(SSUID PNUM)
replace tagid = . if tagid !=1 

	 egen mothers=count(tagid)

// create a global macro identifying mothers age 0 to 25
	 global mothers0to25 = mothers

	 drop mothers tagid 

save "$SIPP14keep/sipp14tpearn_all", $replace
