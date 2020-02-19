Breadwinner Estimates (SIPP 2014 reweighted to look like NLSY age distribution)
================================================================================
~~~~
<<dd_do: quietly>>
* This file estimates lifetables using SIPP data weighted to look like NLSY

use "$SIPP14keep/bw_transitions_NLSYwgt.dta", clear

tab durmom trans_bw50, matcell(bw50uw)

tab durmom trans_bw60, matcell(bw60uw) // just to check n's 
<</dd_do>>
~~~~
First, a description of the age distribution of the SIPP weighted to be the same
as the NLSY 97

tab tage durmom [aweight=adjwgt], nofreq col

<</dd_do>>
~~~~

A table describing weighted transition rates at all durations: 

~~~~
<<dd_do>>
tab durmom trans_bw50 [aweight=adjwgt] if trans_bw50 !=2 , matcell(bw50w) nofreq row
tab durmom trans_bw60 [aweight=adjwgt] if trans_bw60 !=2 , matcell(bw60w) nofreq row

<</dd_do>>
~~~~

~~~~
<<dd_do: quietly>>
// Now, calculating the proportions not (not!) transitioning into breadwining by hand.

forvalues d=1/9 {
   gen nbbw50_rate`d'=bw50w[`d',1]/(bw50w[`d',1]+bw50w[`d',2])
}

// note d=1 is the rate of transition between birth year and year first child
// turns age 1. d=9 is the transition rate between year first child turned 8 and
// year she turns 9.
forvalues d=1/9 {
   gen nbbw60_rate`d'=bw60w[`d',1]/(bw60w[`d',1]+bw60w[`d',2])
}

// calculating a cumulative risk of breadwinning by age 9 by multiplying rates
* of entry at each duration of breadwinning

* initializing cumulative measure at birth
gen notbw50 = notbw50_atbirth
gen notbw60 = notbw60_atbirth

* the proportion who do not become breadwinners is the proportion not breadwinning at birth times
* the proportion who do not become breadwinners in the first year times....who do not become breadwinners
* in year 17.
forvalues d=1/9 {
  replace notbw50=notbw50*nbbw50_rate`d'
  replace notbw60=notbw60*nbbw60_rate`d'
}

* make into nice percents
local notbw50 = 100*notbw50
local notbw60 = 100*notbw60

local per_bw50_atbirth=per_bw50_atbirth
local per_bw60_atbirth=per_bw60_atbirth

* Take the inverse of the proportion not breadwinning to get the proportion breadwinning.
* Multiply by 100 to get a percent.
local bw50_bydur9=100*(1-notbw50)
local bw60_bydur9=100*(1-notbw60)

<</dd_do>>
~~~~

Results
--------------------------------------------------------------------------------

We observe <<dd_di: %4.1f `per_bw50_atbirth'>>% breadwining, or earning more than 50% of the household income in the year of their first birth. 
This estimate is lower (<<dd_di: %4.1f `per_bw60_atbirth'>> percent) using a 60% threshold.

The percentage never breadwinning by the time their first child reaches age 9 is <<dd_di: %4.1f `notbw50'>>, or <<dd_di: %4.1f `notbw60'>> using the 60% threshold.

The percentage breadwinning by the time their first child reaches age 9 is <<dd_di: %4.1f `bw50_bydur9'>>% or <<dd_di: %4.1f `bw60_bydur9'>>% using the 60% threshold.


