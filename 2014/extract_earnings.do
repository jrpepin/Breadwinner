***********************************************************************
* Extracts personal earnings from all SIPP 2014 Waves
*********************************************************************
clear
set maxvar 5300

* read in each original, compressed, data set and extract the variables we want
   forvalues w=1/4{
      use "$SIPP2014/pu2014w`w'_compressed.dta"

      keep ssuid pnum shhadid eresidenceid swave monthcode tpearn apearn tjb?_msum ajb?_msum erace esex tage eeduc tceb tcbyr_* wpfinwgt

      gen year=2012+`w'

      save "$tempdir/sipp14tpearn`w'", replace
   }

clear

* stack all the extracts into a single file 
   use "$tempdir/sipp14tpearn1"

   forvalues w=2/4{
      append using "$tempdir/sipp14tpearn`w'"
   }

* describe sample
	 sort ssuid pnum
	 egen tagid = tag(ssuid pnum)
	 replace tagid=. if tagid !=1 

	 egen all=count(tagid)

	 global allindividuals = all

	 drop all tagid 

* a measure of total household earnings in this month (with allocated data)
* Note that this approach omits the earnings of type 2 people.
    egen thearn=total(tpearn), by(ssuid eresidenceid swave monthcode)

*count number of earners in hh
    egen numearner=count(tpearn), by(ssuid eresidenceid swave monthcode)

* we need an indicator for how many months have elapsed since individual transitioned to parenthood
    gen yrfirstbirth=tcbyr_1

    forvalues birth=2/12 {
        replace yrfirstbirth=tcbyr_`birth' if tcbyr_`birth' < yrfirstbirth
    }

gen panelmonth=(swave-1)*12+monthcode

rename ssuid SSUID
rename eresidenceid ERESIDENCEID
rename pnum PNUM

* keep observations of women in first 18 years since first birth. Note that we add 1 to year to reflect year of interview
* rather than calendar year of the reference month because year of birth measures are as of interview. This
* is why we add _atint to the variable.
   gen dursinceb1_atint=year+1-yrfirstbirth if !missing(yrfirstbirth)

keep if esex==2

* check that year of first birth is > respondents year of birth+9
   gen mybirthyear=year-tage
   gen birthyear_error=1 if mybirthyear+9 > yrfirstbirth & !missing(yrfirstbirth)      // too young
   replace birthyear_error=1 if mybirthyear+50 < yrfirstbirth & !missing(yrfirstbirth) // too old

drop if dursinceb1_atint==0 // first birth occurred after the reference period
drop if dursinceb1_atint > 25

* describe sample
	 sort SSUID PNUM
	 egen tagid = tag(SSUID PNUM)
	 replace tagid=. if tagid !=1 

	 egen mothers=count(tagid)

	 global mothers0to25 = mothers

	 drop mothers tagid 


save "$SIPP14keep/sipp14tpearn_all", $replace
