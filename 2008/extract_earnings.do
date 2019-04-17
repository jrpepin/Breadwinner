***********************************************************************
* Extracts personal earnings from all SIPP 2008 Waves
* The result is in shared space and so you likely don't need to run this.
* If you do need to run it, you'll need to uncompress original data files.
*********************************************************************

forvalues w=1/15{
use "$SIPP2008/FullFile/sippl08puw`w'"

keep if srefmon==4

keep ssuid shhadid epppnum swave tpearn thearn tfearn thothinc tftotinc tbm* tpm* tmlmsum tprftb* eslryb1 eslryb2 eoincb1 eoincb2 tpprpinc tptrninc tpothinc
save "$tempdir/sipp08tpearn`w'", replace
}

clear
use "$tempdir/sipp08tpearn1"

forvalues w=2/15{
append using "$tempdir/sipp08tpearn`w'"
}

destring epppnum, replace


save "$SIPP08keep/sipp08tpearn_all", $replace
