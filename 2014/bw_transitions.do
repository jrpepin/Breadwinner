*-------------------------------------------------------------------------------
* BREADWINNER PROJECT
* bw_transitions.do
* Kelly Raley
*-------------------------------------------------------------------------------

di "$S_DATE"

* creates measures of transitions into breadwinning status

use "$SIPP14keep/bwstatus.dta", clear

// set up to make the file wide

tab first_wave wave 

table durmom wave, contents(mean bw50) format(%3.2g)

local change_variables "year monthsobserved nmos_bw50 nmos_bw60 tpearn thearn spouse partner wpfinwgt minorchildren minorbiochildren tceb oldest_age start_spartner last_spartner durmom youngest_age anytype2 hh_noearnings bw50 bw60 gain_partner lost_partner partial_year raceth educ"

* these should be constants: per_bw50_atbirth notbw50_atbirth pper_bw60_atbirth notbw50_atbirth first_wave

local i_vars "SSUID PNUM"
local j_vars "wave"

reshape wide `change_variables', i(`i_vars') j(`j_vars')

// create a lagged measure of breadwinning
gen bw50L1=. // in wave 1 we have no measure of breadwinning in previous wave
gen bw60L1=. 
    forvalues w=2/4 {
       local v=`w'-1
       gen bw50L`w'=bw50`v' 
       gen bw60L`w'=bw60`v' 
	   gen monthsobservedL`w'=monthsobserved`v'
	   gen minorbiochildrenL`w'=minorbiochildren`v'
    }

// create an indicator for whether individual is observed breadwinning for the first time (1) or
* has been observed breadwinning in the past (2)

gen nprevbw50=0
gen nprevbw60=0
forvalues w=2/4{
   local v=`w'-1
   replace nprevbw50=nprevbw50+1 if bw50`v'==1 
   replace nprevbw60=nprevbw60+1 if bw60`v'==1  
 
   gen trans_bw50`w'=0 if bw50`w'==0 & nprevbw50==0
   gen trans_bw60`w'=0 if bw60`w'==0 & nprevbw60==0
   replace trans_bw50`w'=1 if bw50`w'==1 & nprevbw50==0
   replace trans_bw60`w'=1 if bw60`w'==1 & nprevbw60==0

   // code those who previously transitioned into breadwinning

   replace trans_bw50`w'=2 if nprevbw50 > 0
   replace trans_bw60`w'=2 if nprevbw60 > 0
}

drop nprevbw50 nprevbw60
	
reshape long `change_variables' trans_bw50 trans_bw60 bw50L bw60L monthsobservedL minorbiochildrenL, i(`i_vars') j(`j_vars')

gen transeligible`w'=1 if !missing(monthsobserved) & !missing(monthsobservedL) // for troubleshooting, delete 

tab trans_bw50 transeligible, m

// keep only observations with data in the current waves
keep if !missing(monthsobserved)

// and the previous wave, the only cases where we know about a *transition*
keep if !missing(monthsobservedL)

tab trans_bw50 transeligible, m

save "$SIPP14keep/bw_transitions.dta", replace

     
