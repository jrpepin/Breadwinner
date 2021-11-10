*-------------------------------------------------------------------------------
* BREADWINNER PROJECT
* gen_mslt_results.do
* Kelly Raley and Joanna Pepin
*-------------------------------------------------------------------------------
di "$S_DATE"

********************************************************************************
* DESCRIPTION
********************************************************************************
* This script outputs a descriptive table for total describing bw60 statuses and transition rates by age
* and then runs the lifetable analysis for each group at each cutoff

* The data file used in this script was produced by sipp14_create_mstransitions14.do

********************************************************************************
* Create descriptive table 
********************************************************************************

// Create shell
putexcel set "$output/Descriptives60.xlsx", sheet(StatusbyDuration) modify
putexcel A3:J3 = "Estimates of maternal primary earning transition rates by duration (60% cuttoff)", merge border("bottom")
putexcel A4 = ("Age") 

local columns "B C D E F G H I J K L M N O P Q"
forvalues a=1/4{
	forvalues b=1/4{
		local c=(`a'-1)*4+`b'
		local col: word `c' of `columns'
		putexcel `col'4 = "p`a'`b'"
		display "col is `col' and pxy is p`a'`b'"
	}
}

// Fill in shell

* Transition rates
use "$SIPP14keep/transrates60t.dta"

export excel using "$output/Descriptives60.xlsx", sheet("StatusbyDuration") sheetmodify cell(A5)

// add note
putexcel A24:Q24 = "pxy refers to the transition rate from status x at the previous duration to status y at this duration 1 = not living with children, 2 = living with children, not primary earner 3 = primary earning mother with other adults 4 = primary earning mother sometimes no adult others", merge


********************************************************************************
* Run the lifetable analysis using lxpct_2
********************************************************************************

local cutoffs "50 60"
local groups "t w b h e1 e2 e3 e4 we1 we2 we3 we4 be1 be2 be3 be4 he1 he2 he3 he4 nmb0 nmb1"

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

* 50 % threshold

putexcel set "$output/Descriptives50.xlsx", sheet(mslt) modify
putexcel A1:L1 = "Multi-State Lifetable estimates of number of years and proportion of years spent breadwinning", merge border("bottom")
putexcel B2:F2 = "Years", merge border("bottom")
putexcel H2:K2 = "Proportion", merge border("bottom")
putexcel M2:N2 = "Proportion of years living with children", merge border("bottom")
putexcel B3 = ("Not Coresiding with Children") C3 = ("Not Breadwinning") D3 = ("Breadinning w/others") E3=("Breadinning alone")  F3 = ("Total")
putexcel H3 = ("Not Coresiding with Children") I3 = ("Not Breadwinning") J3 = ("Breadinning w/others") K3=("Breadwinning alone")
putexcel M3 = ("Not Breadwinning") N2 = ("Breadinning")
putexcel A4 = "Total "
putexcel B4 = matrix(m50t), nformat(number_d2)
putexcel A5 = "White"
putexcel B5 = matrix(m50w), nformat(number_d2)
putexcel A6 = "Black"
putexcel B6 = matrix(m50b), nformat(number_d2)
putexcel A7 = "Hispanic"
putexcel B7 = matrix(m50h), nformat(number_d2)
putexcel A8 = "Less than High School"
putexcel B8 = matrix(m50e1), nformat(number_d2)
putexcel A9 = "High School"
putexcel B9 = matrix(m50e2), nformat(number_d2)
putexcel A10 = "Some College"
putexcel B10 = matrix(m50e3), nformat(number_d2)
putexcel A11 = "College Grad"
putexcel B11 = matrix(m50e4), nformat(number_d2)
putexcel A12 = "White -Less than High School"
putexcel B12 = matrix(m50we1), nformat(number_d2)
putexcel A13 = "White -High School"
putexcel B13 = matrix(m50we2), nformat(number_d2)
putexcel A14 = "White- Some College"
putexcel B14 = matrix(m50we3), nformat(number_d2)
putexcel A15 = "Whiite- College Grad"
putexcel B15 = matrix(m50we4), nformat(number_d2)
putexcel A16 = "Black - Less than High School"
putexcel B16 = matrix(m50be1), nformat(number_d2)
putexcel A17 = "Black - High School"
putexcel B17 = matrix(m50be2), nformat(number_d2)
putexcel A18 = "Black - Some College"
putexcel B18 = matrix(m50be3), nformat(number_d2)
putexcel A19 = "Black - College Grad"
putexcel B19 = matrix(m50be4), nformat(number_d2)
putexcel A20 = "Hispanic - Less than High School"
putexcel B20 = matrix(m50he1), nformat(number_d2)
putexcel A21 = "Hispanic - High School"
putexcel B21 = matrix(m50he2), nformat(number_d2)
putexcel A22 = "Hispanic - Some College"
putexcel B22 = matrix(m50he3), nformat(number_d2)
putexcel A23 = "Hispanic - College Grad"
putexcel B23 = matrix(m50he4), nformat(number_d2)

local Ycolumns B C D E
local Pcolumns H I J K
local Qcolumns M N O P

* Calculate sum and proportions for all years 
forvalues r=4/23 {
        putexcel F`r' = formula (+B`r' + C`r' + D`r'+E`r'), nformat(number_d2) // sum of years
	forvalues c=1/4 {
		local col : word `c' of `Pcolumns'
		local ycol : word `c' of `Ycolumns'
		putexcel `col'`r' = formula(+`ycol'`r'/F`r'), nformat(number_d2)
	}
}

* Calculate proportions for years living with minor children
forvalues r=4/23 {
	forvalues c=1/3 {
		local col : word `c' of `Qcolumns'
		local d=`c'+ 1
		local ycol : word `d' of `Ycolumns'
		display "At column `col' and row `r'"
		putexcel `col'`r' = formula(=+`ycol'`r'/(+C`r'+D`r'+E`r')), nformat(number_d2)
	}
}

* 60 % threshold

putexcel set "$output/Descriptives60.xlsx", sheet(mslt) modify
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
putexcel A8 = "Less than High School"
putexcel B8 = matrix(m60e1), nformat(number_d2)
putexcel A9 = "High School"
putexcel B9 = matrix(m60e2), nformat(number_d2)
putexcel A10 = "Some College"
putexcel B10 = matrix(m60e3), nformat(number_d2)
putexcel A11 = "College Grad"
putexcel B11 = matrix(m60e4), nformat(number_d2)
putexcel A12 = "White -Less than High School"
putexcel B12 = matrix(m60we1), nformat(number_d2)
putexcel A13 = "White -High School"
putexcel B13 = matrix(m60we2), nformat(number_d2)
putexcel A14 = "White- Some College"
putexcel B14 = matrix(m60we3), nformat(number_d2)
putexcel A15 = "Whiite- College Grad"
putexcel B15 = matrix(m60we4), nformat(number_d2)
putexcel A16 = "Black - Less than High School"
putexcel B16 = matrix(m60be1), nformat(number_d2)
putexcel A17 = "Black - High School"
putexcel B17 = matrix(m60be2), nformat(number_d2)
putexcel A18 = "Black - Some College"
putexcel B18 = matrix(m60be3), nformat(number_d2)
putexcel A19 = "Black - College Grad"
putexcel B19 = matrix(m60be4), nformat(number_d2)
putexcel A20 = "Hispanic - Less than High School"
putexcel B20 = matrix(m60he1), nformat(number_d2)
putexcel A21 = "Hispanic - High School"
putexcel B21 = matrix(m60he2), nformat(number_d2)
putexcel A22 = "Hispanic - Some College"
putexcel B22 = matrix(m60he3), nformat(number_d2)
putexcel A23 = "Hispanic - College Grad"
putexcel B23 = matrix(m60he4), nformat(number_d2)
putexcel A24 = "Marital first birth"
putexcel B24 = matrix(m60nmb0), nformat(number_d2)
putexcel A25 = "Non-marital first birth"
putexcel B25 = matrix(m60nmb1), nformat(number_d2)

local Ycolumns B C D E
local Pcolumns H I J K
local Qcolumns M N O

* Calculate sum and proportions for all years 
forvalues r=4/25 {
        putexcel F`r' = formula (+B`r' + C`r' + D`r'+E`r'), nformat(number_d2) // sum of years
	forvalues c=1/4 {
		local col : word `c' of `Pcolumns'
		local ycol : word `c' of `Ycolumns'
		putexcel `col'`r' = formula(+`ycol'`r'/F`r'), nformat(number_d2)
	}
}

* Calculate proportions for years living with minor children
forvalues r=4/25 {
	forvalues c=1/3 {
		local col : word `c' of `Qcolumns'
		local d=`c'+ 1
		local ycol : word `d' of `Ycolumns'
		putexcel `col'`r' = formula(=+`ycol'`r'/(+C`r'+D`r'+E`r')), nformat(number_d2)
	}
}
