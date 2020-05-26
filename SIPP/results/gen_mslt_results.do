*-------------------------------------------------------------------------------
* BREADWINNER PROJECT
* gen_mslt_results.do
* Kelly Raley and Joanna Pepin
*-------------------------------------------------------------------------------
di "$S_DATE"

********************************************************************************
* DESCRIPTION
********************************************************************************
* This script runs the lifetable analysis for each group at each cutoff

* The data file used in this script was produced by create_mstransitions14.do

********************************************************************************
* Run the lifetable analysis using lxpct_2
********************************************************************************

local cutoffs "50 60"
local groups "t w b h e1 e2 e3 e4"

foreach c of local cutoffs {
    foreach g of local groups {
       use "$SIPP14keep/transrates`c'`g'.dta", clear

       lxpct_2, i(3) d(0)
	   
	   // take the first row and column 2 to the end  
	   matrix first=e_x[1,2...]

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
putexcel B2:E2 = "Years", merge border("bottom")
putexcel G2:I2 = "Proportion", merge border("bottom")
putexcel K2:L2 = "Proportion of years living with children", merge border("bottom")
putexcel B3 = ("Not Coresiding with Children") C3 = ("Not Breadwinning") D3 = ("Breadinning") E3 = ("Total")
putexcel G3 = ("Not Coresiding with Children") H3 = ("Not Breadwinning") I3 = ("Breadinning")
putexcel K3 = ("Not Breadwinning") L2 = ("Breadinning")
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

local Ycolumns B C D
local Pcolumns G H I
local Qcolumns K L

* Calculate sum and proportions for all years 
forvalues r=4/11 {
        putexcel E`r' = formula (+B`r' + C`r' + D`r'), nformat(number_d2) // sum of years
	forvalues c=1/3 {
		local col : word `c' of `Pcolumns'
		local ycol : word `c' of `Ycolumns'
		putexcel `col'`r' = formula(+`ycol'`r'/E`r'), nformat(number_d2)
	}
}

* Calculate proportions for years living with minor children
forvalues r=4/11 {
	forvalues c=1/2 {
		local col : word `c' of `Qcolumns'
		local d=`c'+ 1
		local ycol : word `d' of `Ycolumns'
		putexcel `col'`r' = formula(=+`ycol'`r'/(+C`r'+D`r')), nformat(number_d2)
	}
}

* 60 % threshold

* 50 % threshold

putexcel set "$output/Descriptives60.xlsx", sheet(mslt) modify
putexcel A1:L1 = "Multi-State Lifetable estimates of number of years and proportion of years spent breadwinning", merge border("bottom")
putexcel B2:E2 = "Years", merge border("bottom")
putexcel G2:I2 = "Proportion", merge border("bottom")
putexcel K2:L2 = "Proportion of years living with children", merge border("bottom")
putexcel B3 = ("Not Coresiding with Children") C3 = ("Not Breadwinning") D3 = ("Breadinning") E3 = ("Total")
putexcel G3 = ("Not Coresiding with Children") H3 = ("Not Breadwinning") I3 = ("Breadinning")
putexcel K3 = ("Not Breadwinning") L2 = ("Breadinning")
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

local Ycolumns B C D
local Pcolumns G H I
local Qcolumns K L

* Calculate sum and proportions for all years 
forvalues r=4/11 {
        putexcel E`r' = formula (+B`r' + C`r' + D`r'), nformat(number_d2) // sum of years
	forvalues c=1/3 {
		local col : word `c' of `Pcolumns'
		local ycol : word `c' of `Ycolumns'
		putexcel `col'`r' = formula(+`ycol'`r'/E`r'), nformat(number_d2)
	}
}

* Calculate proportions for years living with minor children
forvalues r=4/11 {
	forvalues c=1/2 {
		local col : word `c' of `Qcolumns'
		local d=`c'+ 1
		local ycol : word `d' of `Ycolumns'
		putexcel `col'`r' = formula(=+`ycol'`r'/(+C`r'+D`r')), nformat(number_d2)
	}
}

* Note that each column is the number of years spent in each state from
* birth to the year the first child reaches age 18. The assumptions of 
* lifetables don't apply perfectly to our problem. Usually we can assume the first
* state is the same for everyone. That is not the case here as we are split between
* breadwinning and not breadwinning. So, the first observation is the transition into
* breadwinning motherhood or not breadwinning motherhood. The lifetable assumes that
* (on average) half the year is spent in the origin state (not mom) and half in the destination
* state. In addition, some mothers spend time apart from their children. 

* I'm not sure why some of the rows don't add up to 18. This happens for educ=1 and educ==4

* To get estimates of the proportion of years spent breadwinning, I think we should take 
* the percent breadwinning of the time spent breadwinning or not_breadwinning. That is, we should
* ignore the first column of numbers.

/* Current results (weighted)

			Proportion      Years		
							
    		50% 	60% 	50% 	60%				
							
Total		32.7	25.5	5.9 	4.6
White		32.7	24.4	5.9 	4.4
Black		45.9	41.2	8.3 	7.4
Hispanic	27.4	22.2	4.9 	4.0
LTHS		22.2	19.4	4.0 	3.5
HS  	 	28.8	23.7	5.2 	4.3
SCOL		37.0	31.9	6.7 	5.7
Colg		33.6	23.5	6.1 	4.2
