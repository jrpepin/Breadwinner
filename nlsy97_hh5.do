cd "C:\Users\Joanna\Dropbox\Repositories\NLSY97_Breadwinning"
clear
set more off
local logdate = string( d(`c(current_date)'), "%dCY.N.D" )

// Replace NA with nothing in CSV file.
// Delete first column prodced by R output
// Replace m1 - t9 with numbers

log using nlsy97_hh5_`logdate'.log, t replace

************************************************************************************************************
/// Import the data

// Data: Mothers who had first birth between ages 18-27. 
// Breadwinning 50% threshold. Mom's earnings/Household earnings

/*
import 	delimited C:\Users\Joanna\Dropbox\Repositories\NLSY97_Breadwinning\NLSY97_hh5.csv
save 	"C:\Users\Joanna\Dropbox\Repositories\NLSY97_Breadwinning\nlsy97_hh5.dta", replace
*/
use 	"C:\Users\Joanna\Dropbox\Repositories\NLSY97_Breadwinning\nlsy97_hh5.dta", clear

// pubid_1997  == caseid
// Time: year of first birth == 3
// Status: Not a breadwinner == 0, Breadwinner == 1

label define timelbl 	1 "Minus 2" 2 "Minus 1" 3 "Year of 1st Birth" 4 "Plus 1" 5 "Plus 2" 6 "Plus 3" ///
						7 "Plus 4"	8 "Plus 5"	9 "Plus 6"	10 "Plus 7" 11 "Plus 8" 12 "Plus 9" 13 "Plus 10"
label values time timelbl
						
label define statuslbl  0 "Not a breadwinner" 1 "Breadwinner"
label values status statuslbl

************************************************************************************************************
/// Preview the structure of the data

list if pubid_1997 < 10 & status !=.

tab time status
tab status

************************************************************************************************************
/// create variables for breadwinning status at m1 and m2

egen m_2 	= max(status) if time == 1,  by(pubid_1997) 
egen m_1 	= max(status) if time == 2,  by(pubid_1997) 
egen t_0 	= max(status) if time == 3,  by(pubid_1997) 
egen t_1 	= max(status) if time == 4,  by(pubid_1997) 
egen t_2 	= max(status) if time == 5,  by(pubid_1997) 
egen t_3 	= max(status) if time == 6,  by(pubid_1997) 
egen t_4 	= max(status) if time == 7,  by(pubid_1997) 
egen t_5 	= max(status) if time == 8,  by(pubid_1997) 
egen t_6 	= max(status) if time == 9,  by(pubid_1997) 
egen t_7 	= max(status) if time == 10, by(pubid_1997) 
egen t_8 	= max(status) if time == 11, by(pubid_1997) 
egen t_9 	= max(status) if time == 12, by(pubid_1997) 
egen t_10 	= max(status) if time == 13, by(pubid_1997) 

egen m2  	= max(m_2), 	by(pubid_1997)
egen m1  	= max(m_1), 	by(pubid_1997) 
egen t0  	= max(t_0), 	by(pubid_1997) 
egen t1  	= max(t_1), 	by(pubid_1997) 
egen t2  	= max(t_2), 	by(pubid_1997) 
egen t3  	= max(t_3), 	by(pubid_1997) 
egen t4  	= max(t_4), 	by(pubid_1997) 
egen t5 	= max(t_5), 	by(pubid_1997) 
egen t6  	= max(t_6), 	by(pubid_1997) 
egen t7  	= max(t_7), 	by(pubid_1997) 
egen t8  	= max(t_8), 	by(pubid_1997) 
egen t9  	= max(t_9), 	by(pubid_1997) 
egen t10 	= max(t_10), 	by(pubid_1997) 

drop m_2 m_1 t_0 t_1 t_2 t_3 t_4 t_5 t_6 t_7 t_8 t_9 t_10

/// If you select on time > 2 and time <=9 what do the distributions on m1 and m2 look like?

cap drop flag
gen flag =.
replace flag = 1 if time > 2 & time <=9

tab m1 if flag ==1
tab m2 if flag ==1

preserve
collapse (max) 	m2 m1 t0 t1 t2 t3 t4 t5 ///
				t6 t7 t8 t9 t10, by(pubid_1997 time)
				
tab time if m2!=.
tab time if m2!=. & m1!=.
tab time if m2!=. & m1!=. & t0 !=.
tab time if m2!=. & m1!=. & t0 !=. & t1 !=.
tab time if m2!=. & m1!=. & t0 !=. & t1 !=. & t2 !=.

tab time if m1!=.
tab time if m1!=. & t0 !=.
tab time if m1!=. & t0 !=. & t1 !=.
tab time if m1!=. & t0 !=. & t1 !=. & t2 !=.

tab time if t0 !=.
tab time if t0 !=. & t1 !=.
tab time if t0 !=. & t1 !=. & t2 !=.
restore

// Limit to rows with out missing breadwinning status
keep if status !=.

// breadwinning at time 0 dependent on breadwinning at t1 and t2
logit t0 ib3.time m1 		// Just t-minus 1
logit t0 ib3.time m1 m2 	// t-minus 1 & t-minus 2

margins time
marginsplot

log close
