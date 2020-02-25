
~~~~
<<dd_do: quietly>>

** This file uses data from the NLSY to estimate risks of becoming a breadwinner
** at each duration of motherhood using data from the NLSY 1997

* data produced by nlsy97_hh50_pred.do
use "stata/bw50_analysis.dta", clear

keep if hhe50_minus1_ == 0

tab time hhe50, matcell(bw50uw) // just to check n's 

<</dd_do>>
~~~~

An initial table describing transition rates at all durations using data: 

~~~~
<<dd_do>>

tab time hhe50 [fweight=wt1997], matcell(bw50wnc) nofreq row

tab time everbw [fweight=wt1997], matcell(pbw) nofreq row

drop if everbw == 1 

tab time hhe50 [fweight=wt1997], matcell(bw50wc) nofreq row

<</dd_do>>
~~~~

~~~~
<<dd_do: quietly>>
// Now, calculating the proportions not (not!) transitioning into breadwining by hand.

forvalues d=1/10 {
   gen nbbwnc50_rate`d'=bw50wnc[`d',1]/(bw50wnc[`d',1]+bw50wnc[`d',2])
}

// note d=1 is the proportion breadwinning in birth year and d=2 is rate of transition 
// between year turns 1 and year first child turns age 2. d=180 is the transition 
// rate between year first child turned 9 and year she turns 10.

// estimate censored on prior breadwinning
forvalues d=1/10 {
   gen nbbwc50_rate`d'=bw50wc[`d',1]/(bw50wc[`d',1]+bw50wc[`d',2])
}

// calculating a cumulative risk of breadwinning by age 18 by multiplying rates
* of entry at each duration of breadwinning

* initializing cumulative measures
gen notbwnc50 = 1
gen notbwc50 = 1

* the proportion who do not become breadwinners is the proportion not breadwinning at birth times
* the proportion who do not become breadwinners in the first year times....who do not become breadwinners
* in year 17.
forvalues d=1/10 {
  replace notbwnc50=notbwnc50*nbbwnc50_rate`d'
  replace notbwc50=notbwc50*nbbwc50_rate`d'
}

* make into nice percents
local notbwnc50 = 100*notbwnc50
local notbwc50 = 100*notbwc50

gen per_bw50_atbirth=100*(1-bw50wnc[1,1]/(bw50wnc[1,1]+bw50wnc[1,2]))

local per_bw50_atbirth=per_bw50_atbirth

* Take the inverse of the proportion not breadwinning to get the proportion breadwinning.
* Multiply by 100 to get a percent.
local bwnc50_bydur10=100*(1-notbwnc50)
local bwc50_bydur10=100*(1-notbwc50)

<</dd_do>>
~~~~

Results
--------------------------------------------------------------------------------

In the NLSY 1997, we observe <<dd_di: %4.1f `per_bw50_atbirth'>>% breadwining, 
or earning more than 50% of the household income in the year of their first birth. 

The percentage never breadwinning by the time their first child reaches age 10 
is <<dd_di: %4.1f `notbwnc50'>>.

The percentage breadwinning by the time their first child reaches age 10 is <<dd_di: %4.1f `bwnc50_bydur10'>>%.

This is an overestimate because many women probably previously breadwon 
at earlier duration and this upwardly biases the estimate of risk of transitioning into breadwinning 
at later durations. We can address this by limiting the estimate of transitions 
to later waves among women not observed breadwinning in earlier waves. Doing so does 
not alter the estimate of the percent breadwinning at birth, but the estimate of percentage
never breadwinning by the time their first child reaches age 18 is <<dd_di: %4.1f `notbwc50'>>.

Extrapolating to SIPP
-------------------------------------------------------------------------------

Looking at the relationship of the censored and not censored estimates of transitions
into breadwinning to discover a pattern that might be extrapolated beyond age 10

We can think of the uncensored rate R as a function of the first time rate r, 
the rate among repeater breadwinners (rr), and the proportion who have previously breadwon (ppbw).

R = ppbw*rr + (1-ppbw)*r.
What we want is the pattern of relationship between r and rr as if varies by duration. Ideally
we'd get a constant deflation rate that we could apply across all durations.

~~~~
<<dd_do: quietly>>
// first calculate the proprtion previously breadwinning at each duration

forvalues d=1/10{
   gen ppbw`d'=pbw[`d',2]/(pbw[`d',1]+pbw[`d',2])
}

<</dd_do>>
~~~~

What we are looking for is the relationship between nbbwc50_rate and rr by duration. Is it a consistent relationship or do they become more different over time?

~~~~
<<dd_do>>
// next solve for the rate of transition for previous breadwinners 

forvalues d=1/10{
	gen rr`d'=1-((1-nbbwnc50_rate`d') - (ppbw`d')*(1-nbbwc50_rate`d'))/(1-ppbw`d')
	sum nbbwnc50_rate`d' nbbwc50_rate`d' rr`d'
}

<</dd_do>>
~~~~

In the first two durations all the rates are the same, by definition. (One can't have previously breadwon at birth). 
At duration 3 the rate of becoming a breadwinner for those who previously breadwon (1-rr) is larger than the rate for those
who have not previously breadwon (1-nbbwc50_rate). I might see some increase in the difference over time. 

How much of a discount factor should we apply to account for repeat breadwinning? Should the discount vary by duration?


