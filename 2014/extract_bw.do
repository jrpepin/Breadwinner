
use "$SIPP2014/pu2014w1.dta", clear

keep ssuid monthcode epar1typ tage_ehc esex epncohab rfamkind rfamkindwt2 tftotinct2 thhldstatus shhadid ems epnpar2 eorigin epar_scrnr tage_fb rfamref trace thtotinc swave epnspouse epar2typ erace tceb tyear_fb rhnumu18 tpearn tptotinc pnum epnpar1 tage eeduc tcbyr_1 rfamnum rfamnumwt2  tftotinc erp

rename *, upper

save "$SIPP14keep//breadwinning_extract_SIPP14.dta", $replace
