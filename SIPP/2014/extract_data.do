
local boxdir "/Users/Robert/Box Sync"
local datadir "`boxdir'/SIPP/data/SIPP2014"

* Stata's confirm file command does not work for directories on all OS
* (specifically, it does not work on Windows).  We could use confirmdir
* but that is not built into Stata.  I'm going to cheat a bit and assume
* the current naming scheme, and so assume that aa exists.
capture confirm file "`datadir'/puw2014w1_frag_aa.raw.zip"
if (_rc) {
	display as error "`datadir' does not exist or does not contain the expected data."
	display as error "    We expect the puw2014w1_frag_*.zip files to be there."
	display ""
	display as error "You probably need to change the datadir macro, or more likely, the boxdir macro."
	display as error "If you are using Box Sync to get the data, change boxdir to point to your Box Sync directory."
	display as error "If you are not using Box Sync, ignore the boxdir macro and change the datadir macro."
	exit
}

args dictionary_file output_file

if ("`output_file'" == "") {
	display as error "Must have two arguments:  dictionary_file output_file"
	display as error "   The dictionary_file describes the fields to be extracted (see help infix)."
	display as error "       If you have a list of field names and column ranges you probably just need to add"
	display as error "           infix dictionary {"
	display as error "       at the top of the file and"
	display as error "           }"
	display as error "       at the bottom of the file."
	display as error "   The output_file is the name of the file to be created.  You may omit the .dta extension."
	display ""
	display as error "The file designations may include path, either absolute or relative."
	exit
}

local files : dir "`datadir'" files "puw2014w1_frag_*.zip"

local firstfile = 1

foreach f in `files' {
	local f_base = subinstr("`f'", ".zip", "", 1)
	unzipfile "`datadir'/`f'"

        clear
	infix using "`dictionary_file'", using("`f_base'")

	if (`firstfile' == 1) {
		save "`output_file'"
		local firstfile = 0
	}
	else {
		tempfile this_frag
		save `this_frag'

		use "`output_file'"
		append using `this_frag'
		rm `this_frag'
		save "`output_file'", replace
	}

	rm "`f_base'"
}

