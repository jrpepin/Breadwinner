*-------------------------------------------------------------------------------
* BREADWINNER PROJECT 
* SIPP14agedist.do
* Kelly Raley
*-------------------------------------------------------------------------------
***
* Creating a data file describing the age distribution of the SIPP14
* sample by each duration of motherhood to compare to NLSY and
* eventually reweight SIPP to match the NLSY distribition.
***

use "$SIPP14keep/bw_transitions.dta", clear

replace durmom=durmom-1

keep if durmom >= 0

gen intweight=int(wpfinwgt*10000)

tab durmom bw50 [fweight=intweight], row

tab ageb1 durmom [fweight=intweight], col

forvalues d=0/9 {
	gen dur`d'=intweight if durmom==`d'
	forvalues a=18/31 {
		gen age`a'dur`d'=intweight if ageb1==`a' & durmom==`d'
		
	}
}

forvalues d=0/9 {
	egen numdur`d'=sum(dur`d')
	forvalues a=18/31 {
		egen numage`a'dur`d'=sum(age`a'dur`d')
		gen propage`a'dur`d'=numage`a'dur`d'/numdur`d'
	}
}

keep propage*

keep if _n==1

gen one=1

reshape long propage18dur propage19dur propage20dur propage21dur propage22dur propage23dur propage24dur propage25dur propage26dur propage27dur propage28dur propage29dur propage30dur propage31dur, i(one) j(durmom)

rename propage* Spropage*
rename Spropage??dur Spropage??

drop one

// read in NLSY age distribution data. Code is in separate repository.
merge 1:1 durmom using "$NLSYkeep/agedist.dta"

sum Spropage18-Spropage31
sum propage18-propage31

forvalues a=18/31 {
    gen w`a'=Spropage`a'/propage`a'
}

keep durmom w*

reshape long w, i(durmom) j(ageb1)

save "$SIPP14keep/NLSYageweights.dta", replace

* Check does adusting the weights make the age distribution of the SIPP look like that of the NLSY?

use "$SIPP14keep/bw_transitions.dta", clear

replace durmom=durmom-1

keep if durmom >= 0

merge m:1 durmom ageb1 using "$SIPP14keep/NLSYageweights.dta"

gen intweight=int(wpfinwgt*10000)

gen adjwgt=intweight/w

tab tage durmom [aweight=adjwgt], nofreq col

save "$SIPP14keep/bw_transitions_NLSYwgt.dta", replace

* Compare this table to the age by time table in the NLSYagedist result. It's exactly the same!!
