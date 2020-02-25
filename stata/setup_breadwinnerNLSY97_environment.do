*-------------------------------------------------------------------------------
* BREADWINNER PROJECT - NLSY97 Component
* setup_breadwinner_environment.do
* Kelly Raley and Joanna Pepin
*-------------------------------------------------------------------------------

* NOTE: This assumes that you have egenmore installed. If you do not have
* egenmore installed ssc install the program.

* The current directory is assumed to be the base project directory.
*  cd "C:\Users\Joanna\Dropbox\Repositories\NLSY97_Breadwinning"

********************************************************************************
* Setup project macros
********************************************************************************
global bw_base_code "`c(pwd)'" 	/// Creating macro of project working directory


********************************************************************************
* Setup personal file paths
********************************************************************************
* Use setup_example to set your local filepath macros. 
* This file should be named named setup_<username>.do
* and saved in the base project directory.

// Create a home directory macro, depending on OS.
if ("`c(os)'" == "Windows") {
    local temp_drive : env HOMEDRIVE
    local temp_dir : env HOMEPATH
    global homedir "`temp_drive'`temp_dir'"
    macro drop _temp_drive _temp_dir`
}
else {
    if ("`c(os)'" == "MacOSX") | ("`c(os)'" == "Unix") {
        global homedir : env HOME
    }
    else {
        display "Unknown operating system:  `c(os)'"
        exit
    }
}


// Checks that the setup file exists and runs it.
capture confirm file "stata/setup_`c(username)'.do"
if _rc==0 {
    do stata/setup_`c(username)'
      }
  else {
    display as error "The file setup_`c(username)'.do does not exist"
	exit
  }

// We require a logdir for the project be set.
if ("$logdir" == "") {
    display as error "logdir macro not set."
    exit
}

********************************************************************************
* Check for package dependencies 
********************************************************************************
* This checks for packages that the user should install prior to running the project do files.


// fre: https://ideas.repec.org/c/boc/bocode/s456835.html
capture : which fre
if (_rc) {
    display as error in smcl `"Please install package {it:fre} from SSC in order to run these do-files;"' _newline ///
        `"you can do so by clicking this link: {stata "ssc install fre":auto-install fre}"'
    exit 199
}

capture : which univar
if (_rc) {
    display as error in smcl `"Please install package {it:univar} from SSC in order to run these do-files;"' _newline ///
        `"you can do so by clicking this link: {stata "ssc install univar":auto-install univar}"'
    exit 199
}
