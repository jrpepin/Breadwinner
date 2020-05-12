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
