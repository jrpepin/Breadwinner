* This is an example setup file. You should create your own setup file named
* setup_username.do that replaces the directories for project code, log files,
* etc to the location for these files on your computer

* STANDARD PROJECT MACROS-------------------------------------------------------
global projcode 		"$homedir/github/Breadwinner/NLSY97"
global logdir 			"$homedir/logs/breadwinner" 
global tempdir 			"$homedir/data/temp"

// Where scripts and markdown documents analyze data goes
global results 			"$projcode/results"

// Where you want html or putdoc files to go (NOT SHARED)
*  Make same as SIPP repository to compare
global output 			"$homedir/projects/breadwinner/results"

* PROJECT SPECIFIC MACROS-------------------------------------------------------
global datadir			"$projcode/data"
global NLSYkeep			"$projcode/data"
