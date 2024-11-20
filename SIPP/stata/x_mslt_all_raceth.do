*-------------------------------------------------------------------------------
* BREADWINNER PROJECT
* create_mstransitions14.do
* Kelly Raley and Joanna Pepin
*-------------------------------------------------------------------------------
di "$S_DATE"

********************************************************************************
* DESCRIPTION
********************************************************************************
* This script runs a program to create data files for analysis by the lxpct_2 
* multi-state lifetable procedure

* The data file used in this script was produced by msltprep.do

* The resulting data files have estimates of the proportions remaining or transitioning
* between statuses by duration.
* p11 is the proportion in status 1 in the previous year (L) that remained in 
* status 1 at the end of that duration

********************************************************************************
* Create a program to generate the transitions
********************************************************************************

capture program drop create_mstransitions
program define create_mstransitions
   args cutoff subsample suffix // cutoff is either 50 or 60, subsample is like "keep if my_race==1" and suffix is a letter to distinquish save files

   use "$tempdir/msltprep14.dta", clear

   `subsample'

   * create weighted numerators
   egen trans=total(weight), by(durmom mbw`cutoff' mbw`cutoff'L)

   * create weighted denominators 
   egen den=total(weight), by(durmom mbw`cutoff'L)

   keep trans den mbw`cutoff'L mbw`cutoff' durmom
   
   tab mbw`cutoff'L mbw`cutoff'
 
   collapse (max) trans den, by(durmom mbw`cutoff'L mbw`cutoff') 

   * create rates
 
   gen p=trans/den
 
   keep p* durmom mbw`cutoff'L mbw`cutoff'

   egen combo=concat(mbw`cutoff'L mbw`cutoff')

   destring combo, replace
   
   format combo %-2.0f
 
   drop mbw`cutoff'L mbw`cutoff'

   reshape wide p  , i(durmom) j(combo)

   local allcombos "p11 p12 p13 p14 p21 p22 p23 p24 p31 p32 p33 p34 p41 p42 p43 p44"
      
   foreach var in `allcombos' {
       capture confirm variable `var', exact
	   if !_rc {
	    display "`var' exists"
	   }
	   else {
	    display "`var' does not exist"
		gen `var'=0
	   }
   }
   
   foreach var of varlist _all{
	replace `var'=0 if missing(`var')
   }

   rename durmom age
   
   save "$SIPP14keep/transrates`cutoff'`suffix'.dta", replace

end


*******************************************************************************
* Generate data files with measures of transition rates
*******************************************************************************
// from file 10: local raceth "white black asian other hispanic" (bc raceth not labelled)

// Transition rate at the 60% threshold
create_mstransitions 60 "keep if 1==1" "t"
create_mstransitions 60 "keep if raceth==1" "w"
create_mstransitions 60 "keep if raceth==2" "b"
create_mstransitions 60 "keep if raceth==5" "h"
create_mstransitions 60 "keep if raceth==3" "a"
create_mstransitions 60 "keep if raceth==4" "o"
create_mstransitions 60 "keep if educ==1" "e1"
create_mstransitions 60 "keep if educ==2" "e2"
create_mstransitions 60 "keep if educ==3" "e3"
create_mstransitions 60 "keep if educ==4" "e4"
create_mstransitions 60 "keep if raceduc==1" "we1"
create_mstransitions 60 "keep if raceduc==2" "we2"
create_mstransitions 60 "keep if raceduc==3" "we3"
create_mstransitions 60 "keep if raceduc==4" "we4"
create_mstransitions 60 "keep if raceduc==5" "be1"
create_mstransitions 60 "keep if raceduc==6" "be2"
create_mstransitions 60 "keep if raceduc==7" "be3"
create_mstransitions 60 "keep if raceduc==8" "be4"
create_mstransitions 60 "keep if raceduc==9" "he1"
create_mstransitions 60 "keep if raceduc==10" "he2"
create_mstransitions 60 "keep if raceduc==11" "he3"
create_mstransitions 60 "keep if raceduc==12" "he4"
create_mstransitions 60 "keep if nmb==0" "nmb0"
create_mstransitions 60 "keep if nmb==1" "nmb1"

save "$SIPP14keep/kmtmp_transrates60be1.dta", replace

*******************************************************************************
* Otuput duration
*******************************************************************************
// Run the lifetable analysis using lxpct_2

local cutoffs "60"
local groups "t w b h a o e1 e2 e3 e4 we1 we2 we3 we4 be1 be2 be3 be4 he1 he2 he3 he4 nmb0 nmb1"

foreach c of local cutoffs {
    foreach g of local groups {
    
    display "reading in transrates`c'`g'.dta"
       use "$SIPP14keep/transrates`c'`g'.dta", clear

       lxpct_2, i(4) d(0)
	   
	   // take the first row and column 2 to the end  
	   matrix first=e_x[1,2...]

       cap matrix drop m`c'`g'
       matrix rename first m`c'`g'
	   matrix rowname m`c'`g' = `c'`g'
    }
 }
matrix estimates=m50t
 
 foreach c of local cutoffs {
    foreach g of local groups {
	matrix estimates=(estimates \ m`c'`g')
	}
}

matrix colnames estimates = Not_mom Not_breadwinning Breadwinning

matrix list estimates

// 60 % threshold

putexcel set "$output/Descriptives60.xlsx", sheet(mslt_v2) modify
putexcel A1:L1 = "Multi-State Lifetable estimates of number of years and proportion of years spent breadwinning", merge border("bottom")
putexcel B2:F2 = "Years", merge border("bottom")
putexcel H2:K2 = "Proportion", merge border("bottom")
putexcel M2:N2 = "Proportion of years living with children", merge border("bottom")
putexcel B3 = ("Not Coresiding with Children") C3 = ("Not Breadwinning") D3 = ("Breadinning w/others") E3=("Breadinning alone")  F3 = ("Total")
putexcel H3 = ("Not Coresiding with Children") I3 = ("Not Breadwinning") J3 = ("Breadinning w/others") K3=("Breadwinning alone")
putexcel M3 = ("Not Breadwinning") N2 = ("Breadinning")
putexcel A4 = "Total "
putexcel B4 = matrix(m60t), nformat(number_d2)
putexcel A5 = "White"
putexcel B5 = matrix(m60w), nformat(number_d2)
putexcel A6 = "Black"
putexcel B6 = matrix(m60b), nformat(number_d2)
putexcel A7 = "Hispanic"
putexcel B7 = matrix(m60h), nformat(number_d2)
putexcel A8 = "Asian"
putexcel B8 = matrix(m60a), nformat(number_d2)
putexcel A9 = "Other"
putexcel B9 = matrix(m60o), nformat(number_d2)
putexcel A10 = "Less than High School"
putexcel B10 = matrix(m60e1), nformat(number_d2)
putexcel A11 = "High School"
putexcel B11 = matrix(m60e2), nformat(number_d2)
putexcel A12 = "Some College"
putexcel B12 = matrix(m60e3), nformat(number_d2)
putexcel A13 = "College Grad"
putexcel B13 = matrix(m60e4), nformat(number_d2)
putexcel A14 = "White -Less than High School"
putexcel B14 = matrix(m60we1), nformat(number_d2)
putexcel A15 = "White -High School"
putexcel B15 = matrix(m60we2), nformat(number_d2)
putexcel A16 = "White- Some College"
putexcel B16 = matrix(m60we3), nformat(number_d2)
putexcel A17 = "Whiite- College Grad"
putexcel B17 = matrix(m60we4), nformat(number_d2)
putexcel A18 = "Black - Less than High School"
putexcel B18 = matrix(m60be1), nformat(number_d2)
putexcel A19 = "Black - High School"
putexcel B19 = matrix(m60be2), nformat(number_d2)
putexcel A20 = "Black - Some College"
putexcel B20 = matrix(m60be3), nformat(number_d2)
putexcel A21 = "Black - College Grad"
putexcel B21 = matrix(m60be4), nformat(number_d2)
putexcel A22 = "Hispanic - Less than High School"
putexcel B22 = matrix(m60he1), nformat(number_d2)
putexcel A23 = "Hispanic - High School"
putexcel B23 = matrix(m60he2), nformat(number_d2)
putexcel A24 = "Hispanic - Some College"
putexcel B24 = matrix(m60he3), nformat(number_d2)
putexcel A25 = "Hispanic - College Grad"
putexcel B25 = matrix(m60he4), nformat(number_d2)
putexcel A26 = "Marital first birth"
putexcel B26 = matrix(m60nmb0), nformat(number_d2)
putexcel A27 = "Non-marital first birth"
putexcel B27 = matrix(m60nmb1), nformat(number_d2)

local Ycolumns B C D E
local Pcolumns H I J K
local Qcolumns M N O

* Calculate sum and proportions for all years 
forvalues r=4/27 {
        putexcel F`r' = formula (+B`r' + C`r' + D`r'+E`r'), nformat(number_d2) // sum of years
	forvalues c=1/4 {
		local col : word `c' of `Pcolumns'
		local ycol : word `c' of `Ycolumns'
		putexcel `col'`r' = formula(+`ycol'`r'/F`r'), nformat(number_d2)
	}
}

* Calculate proportions for years living with minor children
forvalues r=4/27 {
	forvalues c=1/3 {
		local col : word `c' of `Qcolumns'
		local d=`c'+ 1
		local ycol : word `d' of `Ycolumns'
		putexcel `col'`r' = formula(=+`ycol'`r'/(+C`r'+D`r'+E`r')), nformat(number_d2)
	}
}
