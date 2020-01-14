*-------------------------------------------------------------------------------
* BREADWINNER PROJECT
* breadwinnner14.do
* Kelly Raley and Joanna Pepin
*-------------------------------------------------------------------------------

********************************************************************************
* A1. ENVIRONMENT
********************************************************************************
* There are two scripts users need to run before importing the data. 
* First, create a personal setup file using the setup_example.do script as a template
* and save this file in the base project directory.
* Second, run the setup_breadwinner_environment script to set the project filepaths and macros.

// The current directory is assumed to be the base project directory.
*	cd "C:\Users\Joanna\Dropbox\Repositories\SIPP_Breadwinner" // change to the directory before running
*       breadwinner14.do

// Run the setup script
	do "setup_breadwinner_environment"

********************************************************************************
* A2. DATA
********************************************************************************
* This project uses Wave 1-4 of the 2014 SIPP data files. They can be downloaded here:
* https://www.census.gov/programs-surveys/sipp/data/datasets.html

	*?*?* How did the Stata data files get compressed *?*?*
	** JP: I cheated a copied the compressed files from the PRC stats server onto my personal computer.

// Extract the variables for this project
    log using "$logdir/extract_and_format.log",	replace 
    do "$SIPP2014_code/extract_and_format.do"
    log close

// Merge the waves of data to create two datafiles (type 1 and type 2 records)
    log using "$logdir/merge_waves.log", replace
    do "$SIPP2014_code/merge_waves.do"
    log close

********************************************************************************
* B1. HOUSEHOLD COMPOSITION
********************************************************************************
* Execute a series of scripts to develop measures of household composition
* This script was adapted from the supplementary materials for the journal article 
* [10.1007/s13524-019-00806-1]
* (https://link.springer.com/article/10.1007/s13524-019-00806-1#SupplementaryMaterial).

// Create a file with demographic information and relationship types
    log using "$logdir/compute_relationships.log", replace
    do "$SIPP2014_code/compute_relationships.do"
    log close

// Create a monthly file with just household composition, includes type2 people
	log using "$logdir/create_hhcomp.log", replace
	do "$SIPP2014_code/create_hhcomp.do"
	log close
	
********************************************************************************
* B2. BREADWINNER INDICATORS
********************************************************************************
*Execute breadwinner scripts

// Create a monthly file with earnings and other information on individuals
	log using "$logdir/extract_earnings.log", replace
	do "$SIPP2014_code/extract_earnings.do"
	log close

// Create annual measures of breadwinning
	log using "$logdir/annualize.log", replace
	do "$SIPP2014_code/annualize.do"
	log close

// Create indicators of transitions into and out of breadwinning
	log using "$logdir/bw_transitions.log", replace
	do "$SIPP2014_code/bw_transitions.do"
	log close

********************************************************************************
* Create a file describing sample and initial "lifetime" estimates of breadwinning.
********************************************************************************
	dyndoc "$results/bw_analysis_2014.md", saving($results/bw_analysis_2014.html) replace
