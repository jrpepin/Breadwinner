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

tab tage durmom

tab tage durmom [fweight=intweight], nofreq col

forvalues d=0/9 {
	gen dur`d'=intweight if durmom==`d'
	forvalues a=18/38 {
		gen age`a'dur`d'=intweight if tage==`a' & durmom==`d'
		
	}
}

forvalues d=0/9 {
	egen numdur`d'=sum(dur`d')
	forvalues a=18/38 {
		egen numage`a'dur`d'=sum(age`a'dur`d')
		gen propage`a'dur`d'=numage`a'dur`d'/numdur`d'
	}
}

keep propage*

keep if _n==1

gen one=1

reshape long propage18dur propage19dur propage20dur propage21dur propage22dur propage23dur propage24dur propage25dur propage26dur propage27dur propage28dur propage29dur propage30dur propage31dur propage32dur propage33dur propage34dur propage35dur propage36dur propage37dur propage38dur, i(one) j(durmom)

rename propage* Spropage*
rename Spropage??dur Spropage??

drop one

// read in NLSY age distribution data. Code is in separate repository.
merge 1:1 durmom using "$NLSYkeep/agedist.dta"

sum Spropage18-Spropage38
sum propage18-propage38

forvalues a=18/38 {
    gen w`a'=Spropage`a'/propage`a'
}

keep durmom w*

reshape long w, i(durmom) j(tage)

save "$SIPP14keep/NLSYageweights.dta", replace

* Check does adusting the weights make the age distribution of the SIPP look like that of the NLSY?

use "$SIPP14keep/bw_transitions.dta", clear

replace durmom=durmom-1

keep if durmom >= 0

merge m:1 durmom tage using "$SIPP14keep/NLSYageweights.dta"

gen intweight=int(wpfinwgt*10000)

gen adjwgt=intweight/w

tab tage durmom [aweight=adjwgt], nofreq col

save "$SIPP14keep/bw_transitions_NLSYwgt.dta", replace

* Compare this table to the age by time table in the NLSYagedist result. It's exactly the same!!
