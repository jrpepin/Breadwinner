* This is an example setup file. You should create your own setup file named
* setup_username.do that replaces the directories for project code, log files,
* etc to the location for these files on your computer

* STANDARD PROJECT MACROS-------------------------------------------------------
global projcode 		"$homedir/github/breadwinner"
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
global sipp2014_code 	"$projcode/2014"
global SIPP14keep 		"$homedir/projects/breadwinner/data/keep"

// SIPP 2008
global SIPP2008 		"/data/sipp/2008_Core"
global SIPP2008TM 		"/data/sipp/2008_TM/StataData"
global sipp2008_code 	"$projcode/2008"
global SIPP08keep 		"$homedir/projects/breadwinner/data/keep"

// NLSY
global NLSYkeep			"T:/GitHub/NLSY_Breadwinning/data"
