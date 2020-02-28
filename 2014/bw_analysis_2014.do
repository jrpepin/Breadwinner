
use "$SIPP14keep/bw_transitions.dta", clear

// must first drop wave 1 because we only know status, not transitions into breadwinning

drop if wave==1 // shouldn't actually drop anyone because bw_transitions drops wave 1

// need to adjust durmom. Currently the transition variables describe transition
// into breadwinning between the previous year and this one. For example:
// 
//  durmom   trans_bw
//    4         0             
//    5         0          <- this case transitions to breadwinning between year
//    6         1              5 and year 6
//
// Lifetables usually would describe the risk of transition between this year and the next.
// For example
//  durmom   trans_bw
//    4         0             
//    5         1          <- this case transitions to breadwinning between year
//    6         2              5 and year 6
//
// to make the file as expected subtract 1 from durmom

replace durmom=durmom-1

// drop the observation at birth because it is covered by the status at birth
// above. the record durmom = 0 is the risk of transitioning between year 0 and 1

drop if durmom < 0

tab durmom trans_bw50, matcell(bw50uw)

*tab durmom trans_bw60, matcell(bw60uw) // just to check n's 

tab durmom bw50 [aweight=wpfinwgt], row

tab durmom trans_bw50 [aweight=wpfinwgt] if trans_bw50 !=2 , matcell(bw50w) nofreq row
*tab durmom trans_bw60 [aweight=wpfinwgt] if trans_bw60 !=2 , matcell(bw60w) nofreq row

sort durmom

by durmom: tab bw50L bw50, row
