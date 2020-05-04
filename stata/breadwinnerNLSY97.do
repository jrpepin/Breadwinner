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
	* First, create a personal setup file using the setup_example.do script as a 
	* template and save this file in the base project directory.

	* Second, run the setup_breadwinnerNLSY97_environment script to set the project 
	* filepaths and macros.

//------------------------------------------------------------------------------

* The current directory is assumed to be the stata directory within the repository.
* cd "C:\Users\Joanna\Dropbox\Repositories\NLSY97_Breadwinning\stata" 

// Run the setup script
	do "00_nlsy97_setup_breadwinner_environment"
	
* The logs for these files are generated within each .do file.

********************************************************************************
* A. Data Import and Measures Creation
********************************************************************************

// Create sample and demographic variables
	do "01_nlsy97_sample & demo.do"
	
// Create time-varying variables
	do "02_nlsy97_time_varying.do"
	
// Look at descriptive statistics
	do "03_nlsy97_descriptives.do"

********************************************************************************
* B. Risk of entering breadwinning for the first 10 years of motherhood
********************************************************************************
// Breadwinning estimates at the 50% threshold
	 do "04_nlsy97_bw_estimates_hh50.do"

// output results into excel tables to give to Jennifer
	 
// Breadwinning estimates at the 60% threshold
	 do "05_nlsy97_bw_estimates_hh60.do"
	  
********************************************************************************
* C. Dynamic document with results & notes on logic
********************************************************************************
* NOTE: This dynamic document will only work if the other do files were run in
*		in the same stata session.

// Generate global macros for the current date and time
	local c_date = c(current_date)
	local c_time = c(current_time)
	local c_time_date = "`c_date'"+"_" +"`c_time'" 				// concatenate the two string variables
	local time_string = subinstr("`c_time_date'", ":", "_", .) 	// clean up our string
	global time_string = subinstr("`time_string'", " ", "_", .) // clean up our string
	di "$time_string"

// Delete earlier versions of the html output
local list : dir . files "$results/bw_analysis_NLSY97_*.html"	
foreach f of local list {
    erase "`f'"
}

// Create the new html document describing sample and aspects of analysis
dyndoc "bw_analysis_NLSY97.md", saving($results/bw_analysis_NLSY97_$time_string.html) replace



