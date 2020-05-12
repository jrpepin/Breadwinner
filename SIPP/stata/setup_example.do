* This is an example setup file. You should create your own setup file named
* setup_username.do that replaces the directories for project code, log files,
* etc to the location for these files on your computer

* STANDARD PROJECT MACROS-------------------------------------------------------
global projcode 		"$homedir/github/breadwinning/SIPP"
global logdir 			"$homedir/logs/breadwinner"
global tempdir 			"$projcode/data/tmp"

// Where scripts and markdown documents analyze data goes
global results 		    "$projcode/results"

// Where you want html or putdoc files to go (NOT SHARED)
*  Make same as NLSY repository to compare
global output 			"$homedir/projects/breadwinner/results"

* PROJECT SPECIFIC MACROS-------------------------------------------------------
// SIPP 2014
global SIPP2014 		"/data/sipp/2014"
global sipp2014_code 	"$projcode/stata"
global SIPP14keep 		"$homedir/projects/breadwinner/SIPP/data/keep"
