
~~~~
<<dd_do: quietly>>
* Called by breadwinner14.do, this file descibes the data and measures for the breadwinner paper.
* It won't work properly unless the earlier data files are created during the same stata session.
<</dd_do>>
~~~~

This analysis uses data from the 2014 Survey of Income and Program Participation. These data collected information on a sample of <dd_di: %10.0fc "$allindividuals" >> individuals. We use the birth history measures (year of each birth) to identify the sample eligble to be included in our analysis, restricting the sample to <<dd_di: %10.0fc "$mothers0to25">> women who first became mothers within the 25 years prior to each interview. After futher restricting the data files to mothers coresiding with minor (age < 18) children, we have a sample of <<dd_di: %6.0fc "$mothers_cores_minor">>.

We created a measure of household earnings by aggregating the earnings across all type 1 individuals in the household in each month and then aggregating earnings across all months in each year to get an annual measure of household earnings. To create indicators of breadwinning we compare each mothers' annual earnings to the annual household earnings measures. We consider mothers who earn more than 50% (or 60%) of the household earnings breadwinners.

~~~~
<<dd_do: quietly>>
use "$SIPP14keep/bw_transitions.dta", clear

tab dursinceb1_atint trans_bw50, matcell(bw50uw)

tab dursinceb1_atint trans_bw50 [aweight=wpfinwgt] if trans_bw50 !=2 , matcell(bw50w) nofreq row

* ugh, stata won't put percent in the matrix. Ok, here's calculating the proportions not
* (not!) transitioning into breadwining by hand.

forvalues d=1/17 {
   gen nbbw50_rate`d'=bw50w[`d',1]/(bw50w[`d',1]+bw50w[`d',2])
}

tab dursinceb1_atint trans_bw60, matcell(bw60uw)

tab dursinceb1_atint trans_bw60 [aweight=wpfinwgt] if trans_bw60 !=2 , matcell(bw60w) nofreq row

forvalues d=1/17 {
   gen nbbw60_rate`d'=bw60w[`d',1]/(bw60w[`d',1]+bw60w[`d',2])
}

sum notbw50_atbirth

gen notbw50 = notbw50_atbirth
gen notbw60 = notbw60_atbirth

* the proportion who do not become breadwinners is the proportion not breadwinning at birth times
* the proportion who do not become breadwinners in the first year times....who do not become breadwinners
* in year 17.
forvalues d=1/17 {
  replace notbw50=notbw50*nbbw50_rate`d'
  replace notbw60=notbw60*nbbw60_rate`d'
}

tab notbw50
tab notbw60

local notbw50 = 100*notbw50
local notbw60 = 100*notbw60

local per_bw50_atbirth=per_bw50_atbirth
local per_bw60_atbirth=per_bw60_atbirth

* Take the inferse of the proportion not breadwinning to get the proportion breadwinning.
* Multiply by 100 to get a percent.
local bw50_bydur18=100*(1-notbw50)
local bw60_bydur18=100*(1-notbw60)

<</dd_do>>
~~~~

We observe <<dd_di: %4.1f `per_bw50_atbirth'>>% breadwining, or earning more than 50% of the household income in the year of their first birth. This figure is lower (<<dd_di: %4.1f `per_bw60_atbirth'>> percent) using a 60% threshold.

The percentage never breadwinning by the time their first child reaches age 18 is <<dd_di: %4.1f `notbw50'>>, or <<dd_di: %4.1f `notbw60'>> using the 60% threshold.

The percentage breadwinning by the time their first child reaches age 18 is <<dd_di: %4.1f `bw50_bydur18'>>% or <<dd_di: %4.1f `bw60_bydur18'>>% using the 60% threshold.

