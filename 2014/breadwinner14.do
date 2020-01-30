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
* B1. DEMOGRAPHICS AND ANALYTIC SAMPLE
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
	
// Create a monthly file with earnings & demographic measures. Create analytic sample.
	log using "$logdir/measures_and_sample.log", replace
	do "$SIPP2014_code/measures_and_sample.do"
	log close
	
********************************************************************************
* B2. BREADWINNER INDICATORS
********************************************************************************
*Execute breadwinner scripts

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

    * NOTE: I don't think it is a great idea to put the results in the repository. The markdown file, yes,
    * but maybe not the results. It becomes hard to tell if I'm replicating or copying.
	
	* JP: How do you feel about it if we save the file with the date/time?
		* Problem with this approach, I don't know how to automatically delete the earlier outputs.
	
// Remove old output
 *tmp*.dta
	shell erase $results/bw_analysis_2014*.html

// generate local macros for the current date and time
	local c_date = c(current_date)
	local c_time = c(current_time)
	local c_time_date = "`c_date'"+"_" +"`c_time'" 				// concatenate the two string variables
	local time_string = subinstr("`c_time_date'", ":", "_", .) 	// clean up our string
	local time_string = subinstr("`time_string'", " ", "_", .) 	// clean up our string
	di "`time_string'"
	
	dyndoc "$results/bw_analysis_2014.md", saving($results/bw_analysis_2014__`time_string'.html) replace

********************************************************************************
* Multistate lifetable analysis
********************************************************************************

// file needs to be set up a little differently for lxpct2 (JP: What is lxpct2?)
	log using "$logdir/msltprep.log", replace
	do "$SIPP2014_code/msltprep.do"
	log close

	// create small data files with transition rates pXX 
	log using "$logdir/create_mstransitions14.log", replace
	do "$SIPP2014_code/create_mstransitions14.do"
	log close

	// generate a matrix with estimates of expected number of years
	// in each state from "birth"
	log using "$logdir/.log", replace
	do "$results/gen_mslt_results.do"
	log close	
