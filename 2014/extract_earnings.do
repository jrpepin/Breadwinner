***********************************************************************
* Extracts personal earnings from all SIPP 2014 Waves
*********************************************************************

set maxvar 5300

forvalues w=1/4{
use "$SIPP2014/pu2014w`w'_compressed.dta"

keep ssuid pnum shhadid eresidenceid swave monthcode tpearn apearn tjb?_msum ajb?_msum erace esex tage eeduc tceb tcbyr*

save "$tempdir/sipp14tpearn`w'", replace
}

clear
use "$tempdir/sipp14tpearn1"

forvalues w=2/4{
append using "$tempdir/sipp14tpearn`w'"
}

destring pnum, replace

* Note that this approach omits the earnings of type 2 people.
egen thearn=total(tpearn), by(ssuid eresidenceid swave monthcode)

save "$SIPP14keep/sipp14tpearn_all", $replace
