*-------------------------------------------------------------------------------
* BREADWINNER PROJECT - NLSY97 Component
* breadwinnnerNLSY97.do
* Joanna Pepin
*-------------------------------------------------------------------------------
/*
The goal of these scripts are to create three types of estimates 
for the first 10 years of motherhood:
	1. Risk of entering breadwinning (at each duration of motherhood)
	2. Risk of entering breadwinning, censoring on previous breadwinning
	3. Proportion of breadwinning at each age that have previously breadwon
*/
********************************************************************************
* A1. ENVIRONMENT
********************************************************************************
* There are two scripts users need to run before importing the data. 
* First, create a personal setup file using the setup_example.do script as a template
* and save this file in the base project directory.
* Second, run the setup_breadwinnerNLSY97_environment script to set the project filepaths and macros.

// The current directory is assumed to be the base project directory.
// change to the directory before running breadwinnerNLSY97.do
*	cd "C:\Users\Joanna\Dropbox\Repositories\NLSY97_Breadwinning" 

// Run the setup script
	do "stata/setup_breadwinnerNLSY97_environment"
	
* The logs for these files are generated within each .do files.

********************************************************************************
* B1. Risk of entering breadwinning (at each duration of motherhood)
********************************************************************************
** This is just the proportion breadwinning at each duration, right?
	
// Breadwinning estimates at the 50% threshold
    do "stata/nlsy97_hh50_dur.do"
	
********************************************************************************
* B2. Risk of entering breadwinning, censoring on previous breadwinning
********************************************************************************
*?*?* JP : This is what we did before. Is that the same as censored breadwinning?

// Breadwinning estimates at the 50% threshold
    do "stata/nlsy97_hh50.do"

// Breadwinning estimates at the 50% threshold
    do "stata/nlsy97_hh60.do"

********************************************************************************
* B3. Proportion of breadwinning at each age that have previously breadwon
********************************************************************************
