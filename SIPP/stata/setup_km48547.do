* This is an example setup file. You should create your own setup file named
* setup_username.do that replaces the directories for project code, log files,
* etc to the location for these files on your computer

global homedir "T:"

* STANDARD PROJECT MACROS-------------------------------------------------------
global projcode 		"$homedir/github/Breadwinner/SIPP"
global logdir 			"$homedir/Research Projects/Breadwinner/logs"
global tempdir 			"$homedir/Research Projects/Breadwinner/data/temp"

// Where scripts and markdown documents analyze data goes
global results 		    "$projcode/results"

// Where you want html or putdoc files to go (NOT SHARED)
*  Make same as NLSY repository to compare
global output 			"$homedir/Research Projects/Breadwinner/results"

* PROJECT SPECIFIC MACROS-------------------------------------------------------
// SIPP 2014
global SIPP2014 		"/data/sipp/2014"
global SIPP2014_code 	"$projcode/stata"
global SIPP14keep 		"$homedir/Research Projects/Breadwinner/SIPP/data"
