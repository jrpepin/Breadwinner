~~~~
<<dd_do: quietly>>

* This file descibes results from the SIPP and NLSY analysis for the breadwinning paper.

* Run SIPPagedist before running this script

<</dd_do>>
~~~~

Comparison of SIPP and NLSY
----------------------------
This analysis creates estimates of "lifetime" breadwinning by age 10 using SIPP
2014 to compare to the NLSY.

~~~~
<<dd_do: quietly>>
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

gen intweight=int(wpfinwgt*10000)

********************************************************************************
* Describe percent breadwinning in the first year
********************************************************************************
// The percent breadwinning (50% threhold) in the first year. (~25%)
	sum bw50 if durmom	==0 [aweight=wpfinwgt] // Breadwinning in the year of the birth

	gen per_bw50_atbirth	=100*`r(mean)'
	gen notbw50_atbirth		=1-`r(mean)'

// The percent breadwinning (60% threhold) in the first year. (~17%)
	sum bw60 if durmom	==0 [aweight=wpfinwgt] // Breadwinning in the year of the birth

	gen per_bw60_atbirth	=100*`r(mean)'
	gen notbw60_atbirth		=1-`r(mean)'

tab durmom trans_bw50, matcell(bw50uw)

tab durmom trans_bw60, matcell(bw60uw) // just to check n's 
<</dd_do>>
~~~~

First, just a description of the transition rates by duration since becoming a mother
using the SIPP 2014. Note that the file is set up a bit differently than the file for the 
NLSY analysis so that trans_bw50 at durmom==0 is the rate of transition into breadwinning from not
breadwinning in the birth year to breadwinning in the year the first child has her first birthday. 
In short, compare durmom=0 in the SIPP to time==1 in the NLSY. per_bw50_atbirth gives the
percent breadwinnng at birth.

~~~~
<<dd_do>>

sum per_bw50_atbirth
tab durmom trans_bw50 [aweight=wpfinwgt] if trans_bw50 !=2 , matcell(bw50w) nofreq row

sum per_bw60_atbirth
tab durmom trans_bw60 [aweight=wpfinwgt] if trans_bw60 !=2 , matcell(bw60w) nofreq row

<</dd_do>>
~~~~

~~~~
<<dd_do: quietly>>
// Now, calculating the proportions not (not!) transitioning into breadwining by hand.

forvalues d=1/10 {
   gen nbbw50_rate`d'=bw50w[`d',1]/(bw50w[`d',1]+bw50w[`d',2])
}

// note d=1 is the rate of transition between birth year and year first child
// turns age 1. d=10 is the transition rate between year first child turned 17 and
// year she turns 10.
forvalues d=1/10 {
   gen nbbw60_rate`d'=bw60w[`d',1]/(bw60w[`d',1]+bw60w[`d',2])
}

// calculating a cumulative risk of breadwinning by age 18 by multiplying rates
* of entry at each duration of breadwinning

* initializing cumulative measure at birth
gen notbw50 = notbw50_atbirth
gen notbw60 = notbw60_atbirth

* the proportion who do not become breadwinners is the proportion not breadwinning at birth times
* the proportion who do not become breadwinners in the first year times....who do not become breadwinners
* in year 10.
forvalues d=1/9 {
  replace notbw50=notbw50*nbbw50_rate`d'
  replace notbw60=notbw60*nbbw60_rate`d'
}

* make into nice percents
local notbw50 = 100*notbw50
local notbw60 = 100*notbw60

local p_bw50_atbirth=per_bw50_atbirth
local p_bw60_atbirth=per_bw60_atbirth

* Take the inverse of the proportion not breadwinning to get the proportion breadwinning.
* Multiply by 100 to get a percent.
local bw50_bydur10=100*(1-notbw50)
local bw60_bydur10=100*(1-notbw60)

<</dd_do>>
~~~~

Results
--------------------------------------------------------------------------------

We observe <<dd_di: %4.1f `p_bw50_atbirth'>>% breadwining as defined by earning more than 50% of the household income in the year of their first birth. 
This estimate is lower (<<dd_di: %4.1f `p_bw60_atbirth'>> percent) using a 60% threshold.

The percentage never breadwinning by the time their first child reaches age 10 is <<dd_di: %4.1f `notbw50'>>%, or <<dd_di: %4.1f `notbw60'>> using the 60% threshold.

The percentage breadwinning by the time their first child reaches age 10 is <<dd_di: %4.1f `bw50_bydur10'>>% or <<dd_di: %4.1f `bw60_bydur10'>>% using the 60% threshold.

Weighting to match NLSY population
--------------------------------------------------------------------------------


~~~~
<<dd_do: quietly>>

* This file estimates lifetables using SIPP data weighted to look like NLSY

use "$SIPP14keep/bw_transitions_NLSYwgt.dta", clear

********************************************************************************
* Describe percent breadwinning in the first year
********************************************************************************
// The percent breadwinning (50% threhold) in the first year. (~25%)
	sum bw50 if durmom	==0 [aweight=adjwgt] // Breadwinning in the year of the birth

	gen per_bw50_atbirth	=100*`r(mean)'
	gen notbw50_atbirth		=1-`r(mean)'

<</dd_do>>
~~~~

First, a description of the age distribution of the SIPP weighted to be the same
as the NLSY 97

~~~~
<<dd_do>>

sum per_bw50_atbirth
tab tage durmom [aweight=adjwgt], nofreq col

<</dd_do>>
~~~~

Below is a table describing weighted transition rates at all durations. 

~~~~
<<dd_do>>

tab durmom trans_bw50 [aweight=adjwgt] if trans_bw50 !=2 , matcell(bw50w) nofreq row

<</dd_do>>
~~~~

~~~~
<<dd_do:quietly>>
// Now, calculating the proportions not (not!) transitioning into breadwining by hand.

forvalues d=1/10 {
   gen nbbw50_rate`d'=bw50w[`d',1]/(bw50w[`d',1]+bw50w[`d',2])
}

// note d=1 is the rate of transition between birth year and year first child
// turns age 1. d=9 is the transition rate between year first child turned 8 and
// year she turns 9.


// calculating a cumulative risk of breadwinning by age 9 by multiplying rates
* of entry at each duration of breadwinning

* initializing cumulative measure at birth
gen notbw50 = notbw50_atbirth

* the proportion who do not become breadwinners is the proportion not breadwinning at birth times
* the proportion who do not become breadwinners in the first year times....who do not become breadwinners
* in year 9.
forvalues d=1/10 {
  replace notbw50=notbw50*nbbw50_rate`d'
}

* make into nice percents
local notbw50 = 100*notbw50

local per_bw50_atbirth=per_bw50_atbirth

* Take the inverse of the proportion not breadwinning to get the proportion breadwinning.
* Multiply by 100 to get a percent.
local bw50_bydur10=100*(1-notbw50)

<</dd_do>>
~~~~

Results
--------------------------------------------------------------------------------

Weigting the SIPP to have the same distribution on age at first birth by duration as the 
NLSY, we observe <<dd_di: %4.1f `per_bw50_atbirth'>>% breadwining, or earning more than 50% of the household income in the year of their first birth. 

The percentage never breadwinning by the time their first child reaches age 10 is <<dd_di: %4.1f `notbw50'>> by the 50% threshold.

The percentage breadwinning by the time their first child reaches age 10 is <<dd_di: %4.1f `bw50_bydur10'>>%.
