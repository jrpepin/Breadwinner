*-------------------------------------------------------------------------------
* BREADWINNER PROJECT - NLSY97 Component
* nlsy97_hh50_pred.do
* Joanna Pepin & Kelly Raley
*-------------------------------------------------------------------------------

***
* Creating a data file describing the age distribution of the NLSY
* respondents by each duration of motherhood so that I can reweight SIPP
* to match this distribition.
***

* NEED TO ADD NLSY weights

clear
set more off

use 	"stata/NLSY97_hh50.dta", clear

keep if !missing(hhe50)

tab age time [fweight=wt1997], nofreq col

forvalues d=0/9 {
	gen dur`d'=wt1997 if time==`d'
	forvalues a=18/38 {
		gen age`a'dur`d'=wt1997 if age==`a' & time==`d'
		
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


reshape long propage18dur propage19dur propage20dur propage21dur propage22dur propage23dur propage24dur propage25dur propage26dur propage27dur propage28dur propage29dur propage30dur propage31dur propage32dur propage33dur propage34dur propage35dur propage36dur propage37dur propage38dur, i(one) j(time)

rename propage??dur propage??
rename time durmom

drop one

save "$NLSYkeep/agedist.dta", replace
