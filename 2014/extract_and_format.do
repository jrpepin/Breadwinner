* This file extracts the needed data from the compressed data files that we
* created from the Census data files. These files lack variable labels, unfortnuately.

* The first extract is similar to extracts for earlier panels. The second extract pulls variables related
* to type 2 people -- those people who don't have a record in the data because they don't live in the household at
* the time of interivew but they do live with sample members at some point during the reference period.

forvalues wave=1/4 {
        clear
	set maxvar 5500
	use "$SIPP2014/pu2014w`wave'_compressed"
	keep tftotinc thtotinc tst_intv ems eorigin epnpar1 epnpar2 epnspouse ///
	erace erelrp esex epar1typ epar1typ epar2typ  tage  rhnumperwt2  ///
	rfamrefwt2 thtotinc eresidenceid einttype pnum  ///
	shhadid monthcode aroutingsrop swave wpfinwgt eeduc ssuid rged ///
	renroll eedgrade eedgrep rfoodr rfoods rhnumper rhnumperwt2 rhnumu18 rhnumu18wt2 rhnum65over rhnum65ovrt2 rhpov rhpovt2 thincpov thincpovt2 eresidenceid rrel* rrel_pnum*

        drop rrelig // an rrel* variable I didn't intend to grab

        replace eresidenceid=subinstr(eresidenceid,"A","1",.)
        replace eresidenceid=subinstr(eresidenceid,"B","2",.)
        replace eresidenceid=subinstr(eresidenceid,"C","3",.)
        replace eresidenceid=subinstr(eresidenceid,"D","4",.)
        replace eresidenceid=subinstr(eresidenceid,"E","5",.)
        replace eresidenceid=subinstr(eresidenceid,"F","6",.)
        
	destring pnum, replace
        destring eresidenceid, replace
	rename *, upper
	
     rename SWAVE swave
     gen panelmonth=MONTHCODE+(12*(`wave'-1))

	save "$SIPP14keep/wave`wave'_extract", $replace
}

/// type 2 person variables

clear

forvalues wave=1/4 {
        clear
	set maxvar 5500
	use "$SIPP2014/pu2014w`wave'_compressed"
	keep ssuid pnum eresidenceid monthcode swave et2_lno* et2_mth* et2_sex* tt2_age* rrel* rrel_pnum* tage

        replace eresidenceid=subinstr(eresidenceid,"A","1",.)
        replace eresidenceid=subinstr(eresidenceid,"B","2",.)
        replace eresidenceid=subinstr(eresidenceid,"C","3",.)
        replace eresidenceid=subinstr(eresidenceid,"D","4",.)
        replace eresidenceid=subinstr(eresidenceid,"E","5",.)
        replace eresidenceid=subinstr(eresidenceid,"F","6",.)
       
	destring pnum, replace
        destring eresidenceid, replace
	rename *, upper
	
     rename SWAVE swave
     gen panelmonth=MONTHCODE+(12*(`wave'-1))

	save "$SIPP14keep/wave`wave'_type2_extract", $replace
}
