* creates measures of transitions into breadwinning status

use "$SIPP14keep/bwstatus.dta", clear

* start by making the file wide

gen wave=year-2012

local change_variables "year monthsobserved nmos_bw50 nmos_bw60 tpearn thearn spouse partner wpfinwgt minorchildren minorbiochildren tceb oldest_age start_spartner last_spartner dursinceb1_atint youngest_age anytype2 hh_noearnings bw50 bw60 gain_partner lost_partner partial_year erace eeduc"

* these should be constants: per_bw50_atbirth notbw50_atbirth pper_bw60_atbirth notbw50_atbirth

local i_vars "SSUID PNUM"
local j_vars "wave"

reshape wide `change_variables', i(`i_vars') j(`j_vars')

* create an indicator for whether individual is observed breadwinning for the first time (1) or
* has been observed breadwinning in the past (2)

gen trans_bw501=bw501
gen trans_bw601=bw601
    forvalues w=2/4 {
       gen trans_bw50`w'=bw50`w'
       gen trans_bw60`w'=bw60`w'
       forvalues obs=1/`w' {
          replace trans_bw50`w'=2 if trans_bw50`obs'==1
          replace trans_bw60`w'=2 if trans_bw60`obs'==1
       }
    }


reshape long `change_variables' trans_bw50 trans_bw60, i(`i_vars') j(`j_vars')

sum wpfinwgt

gen weighted=wpfinwgt/`r(mean)'

save "$SIPP14keep/bw_transitions.dta", replace

     
