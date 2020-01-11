*-------------------------------------------------------------------------------
* BREADWINNER PROJECT
* setup_breadwinner_environment.do
* Kelly Raley and Joanna Pepin
*-------------------------------------------------------------------------------

* The current directory is assumed to be the base project directory.
**  cd "C:\Users\Joanna\Dropbox\Repositories\SIPP_Breadwinner"

********************************************************************************
* Setup project macros
********************************************************************************
global bw_base_code "`c(pwd)'" 	/// Creating macro of project working directory

global today `c(current_date)'	/// Creating a macro of today's date.

* Project default is that we don't write over existing files.
* Change this in your project setup file if you really want,
* but for archiving replace is (generally) not allowed.
global replace ""

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
capture confirm file "setup_`c(username)'.do"
if _rc==0 {
    do setup_`c(username)'
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

// Fre: https://ideas.repec.org/c/boc/bocode/s456835.html
capture : which fre
if (_rc) {
    display as result in smcl `"Please install package {it:fre} from SSC in order to run this do-file;"' _newline ///
        `"you can do so by clicking this link: {stata "ssc install fre":auto-install fre}"'
    exit 199
}
