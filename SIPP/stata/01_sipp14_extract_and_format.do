*-------------------------------------------------------------------------------
* BREADWINNER PROJECT
* extract_and_format.do
* Kelly Raley and Joanna Pepin
*-------------------------------------------------------------------------------
di "$S_DATE"

********************************************************************************
* DESCRIPTION
********************************************************************************
* The first extract selects and formats the project variables from the individual
	* household members (Type 1)
* The second extract pulls variables related to type 2 people.
	* Type 2 people: people who were living in the household that month, but no longer reside in the household

* The data files used in this script are the compressed data files that we
* created from the Census data files. 
* These files lack variable labels, unfortnuately.

********************************************************************************
* EXTRACT 1 -- Type 1 (interviewed household members) variables
********************************************************************************
clear

	
forvalues wave=1/4 {
    use "$SIPP2014/pu2014w`wave'_compressed"
	keep	swave  			einttype  		monthcode  		wpfinwgt  	ssuid  			pnum 			/// /* TECHNICAL */
			epnpar1  		epnpar2  		epnspouse 		rfamrefwt2  eresidenceid 	shhadid  		///
			erelrp  		epar1typ  		epar2typ   		rhnumper  	rhnumperwt2 	rhnumu18  		/// /* HOUSEHOLD */
			rhnumu18wt2		rhnum65over  	rhnum65ovrt2 	rrel*  		rrel_pnum*		aroutingsrop	///
			tftotinc 		thtotinc  																	/// /* FINANCIAL */
			tst_intv  		ems  			eorigin  		erace  		esex  			tage   			/// /* DEMOGRAPHIC */
			eeduc  			rged 			renroll  		eedgrade  	eedgrep  		rfoodr  		///
			rfoods  		rhpov 			rhpovt2 		thincpov  	thincpovt2  
	
// Make the person number identifier numeric
		 * destring pnum, replace /// Already numeric
	
// Make the six digit identifier for residence addresses numeric
		replace eresidenceid=subinstr(eresidenceid,"A","1",.)
        replace eresidenceid=subinstr(eresidenceid,"B","2",.)
        replace eresidenceid=subinstr(eresidenceid,"C","3",.)
        replace eresidenceid=subinstr(eresidenceid,"D","4",.)
        replace eresidenceid=subinstr(eresidenceid,"E","5",.)
        replace eresidenceid=subinstr(eresidenceid,"F","6",.)
        
	    destring eresidenceid, replace
	
// Make variables uppercase to match old code.
		rename *, upper
	
// Make wave variable lowercase 
		rename SWAVE swave
    
// Create a panelmonth variable
		gen panelmonth=MONTHCODE+(12*(`wave'-1))

		save "$SIPP14keep/wave`wave'_extract", replace
}

********************************************************************************
* EXTRACT 2 -- Type 2 (no longer residents) person variables
********************************************************************************
clear


forvalues wave=1/4 {
    use "$SIPP2014/pu2014w`wave'_compressed"
	keep 	swave			monthcode		ssuid 		pnum 	///	/* TECHNICAL */
			eresidenceid 	et2_lno* 							/// 
			et2_mth* 		rrel*			rrel_pnum*			/// /* HOUSEHOLD */
			et2_sex* 		tage			tt2_age* 				/* DEMOGRAPHIC */	
		
// Make the person number identifier numeric	
		 * destring pnum, replace /// Already numeric	 

// Make the six digit identifier for residence addresses numeric
		replace eresidenceid=subinstr(eresidenceid,"A","1",.)
        replace eresidenceid=subinstr(eresidenceid,"B","2",.)
        replace eresidenceid=subinstr(eresidenceid,"C","3",.)
        replace eresidenceid=subinstr(eresidenceid,"D","4",.)
        replace eresidenceid=subinstr(eresidenceid,"E","5",.)
        replace eresidenceid=subinstr(eresidenceid,"F","6",.)
       
        destring eresidenceid, replace
	
// Make variables uppercase to match old code.
		rename *, upper
	
// Make wave variable lowercase 
		rename SWAVE swave
     
// Create a panelmonth variable
		gen panelmonth=MONTHCODE+(12*(`wave'-1))

		save "$SIPP14keep/wave`wave'_type2_extract", replace
}
