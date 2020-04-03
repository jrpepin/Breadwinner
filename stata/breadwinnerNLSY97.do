*-------------------------------------------------------------------------------
* BREADWINNER PROJECT - NLSY97 Component
* breadwinnnerNLSY97.do
* Joanna Pepin
*-------------------------------------------------------------------------------
* The goal of these files is to create estimates of breadwinning in order to
* better account for repeat breadwinning using the SIPP

********************************************************************************
* A. ENVIRONMENT
********************************************************************************
* There are two scripts users need to run before importing the data. 
* First, create a personal setup file using the setup_example.do script as a template
* and save this file in the base project directory.
* Second, run the setup_breadwinnerNLSY97_environment script to set the project filepaths and macros.

//------------------------------------------------------------------------------

// The current directory is assumed to be the base project directory.
// change to the directory before running breadwinnerNLSY97.do
*	cd "C:\Users\Joanna\Dropbox\Repositories\NLSY97_Breadwinning" 

// Run the setup script
	do "stata/setup_breadwinnerNLSY97_environment"
	
* The logs for these files are generated within each .do files.

********************************************************************************
* A. Data Import and Measures Creation
********************************************************************************

// Create sample and demographic variables
	do "stata/nlsy97_sample & demo.do"
	
// Create time-varying variables
	do "stata/nlsy97_time-varying.do"

********************************************************************************
* B. Risk of entering breadwinning for the first 10 years of motherhood
********************************************************************************

// Breadwinning estimates at the 50% threshold
    do "stata/nlsy97_hh50_pred.do"

// Breadwinning estimates at the 60% threshold
	do "stata/nlsy97_hh60_pred.do"

********************************************************************************
* C. Same as above, but with bw indicators created in Stata
********************************************************************************
// Look at descriptive statistics
	do "stata/nlsy97_descriptives"

// Create Breadwinning measures
	do "stata/nlsy97_bw measures"
	
// Breadwinning estimates at the 50% threshold
	 do "stata/nlsy97_hh50_stata_pred.do"
	 
// Breadwinning estimates at the 60% threshold
	 do "stata/nlsy97_hh60_stata_pred.do"
