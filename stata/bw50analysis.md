
~~~~
<<dd_do: quietly>>

** This file uses data from the NLSY to estimate risks of becoming a breadwinner
** at each duration of motherhood using data from the NLSY 1997

* data produced by nlsy97_hh50_pred.do
use "bw50_analysis.dta", clear

keep if hhe50_minus1_ == 0

tab time hhe50, matcell(bw50uw) // just to check n's 

gen countme1=1 if time==9
gen countme2=1 if time==9 & everbw==0
gen countme3=1 if time==1 & everbw==0 & hhe50==1
egen numdur9uc=count(countme1)
egen numdur9c=count(countme2)
egen numbw9c=count(countme3)
local numdur9uc=numdur9uc
local numdur9c=numdur9c
local numbw9c=numbw9c

drop countme1 countme2 countme3 numdur9uc numdur9c numbw9c

<</dd_do>>
~~~~

NLSY analysis
-----------------------------------------------------------------------
The purpose of the NLSY analysis is to identify the degree to which repeat breadwinning
leads to an over-estimate of lifetime breadwinning in the SIPP. 

To start, we produce an initial table describing transition rates at all durations 
using NLSY data. The first table shows by year since first birth the risk of becoming 
a breadwinning mother among women who were not breadwinning mothers in the previous 
year. The second table shows the percentage of mothers ever previously breadwinning by 
number of years since becoming a breadwinner. At year 0 it is impossible to have been a 
breadwinning mother previously. At duration 1 it is impossible to experience a repeat
transition into breadwinning. After that, the proportion who have previously breadwon 
grows (a lot).

The third table shows risk of becoming a breadwinning mother among women 
who had never previously been a breadwinning mother.

~~~~
<<dd_do>>

tab time hhe50 [fweight=wt1997], matcell(bw50wnc) nofreq row

tab time everbw [fweight=wt1997], matcell(pbw) nofreq row

drop if everbw == 1 

tab time hhe50 [fweight=wt1997], matcell(bw50wc) nofreq row

<</dd_do>>
~~~~

We can see that the proportion becoming a breadwinning mother is smaller in the second table
than in the first. This suggests that repeat breadwinning does lead to an overestimate of 
lifetime breadwinning unless one censors on previous breadwinning. 

The next question is, how should we use the information in the comparison above 
to adjust the SIPP estimates? One approach might be to just take the average ratio of the 
censored and censored transition rates and apply that discount to the SIPP. That's OK, 
but the pattern of results suggest that the difference in the censored and uncensored
estimates might grow over time. It might be that it just grows from duration 2 to 5 
and is basically stable after that. That last observation in the NLSY 97 could be because a
relately small number of women are observed 9 years after first childbirth (n=<<dd_di: %4.0f `numdur9uc'>>. The 
denominator gets substantially smaller (n=<<dd_di: %4.0f `numdur9c'>> when we censor on prior breadwinning. 
That is, the censored analysis, we see <<dd_di: %4.0f `numbw9c'>> mothers transition into breadwinning at duration 9.
Although that's a small number, it's not crazy small. Do we think the dramatic decline in the 
risk of becoming a first time breadwinner at duration 9 is real?

As an aside, you might be worred that the NLSY sample is selected for women who have children 
at younger ages and that this becomes more true as duration since becoming a 
mother increases. That is true, but it doesn't seem to distort the measurement of 
breadwinning much. I ran an estimate of the proportion lifetime breadwinning on 
SIPP data weighted to have the same ageatfirstbirth by duration distribution as 
the NLSY and it changed the SIPP estimate at the third decimal place. 
(See SIPP14agedist.do in the SIPP repository)

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

NLSY Results
--------------------------------------------------------------------------------

These results are out of date as the code above was written for an earlier version
of the analysis file. 

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
never breadwinning by the time their first child reaches age 10 is <<dd_di: %4.1f `notbwc50'>>.

Extrapolating to SIPP
-------------------------------------------------------------------------------

Looking at the relationship of the censored and not censored estimates of transitions
into breadwinning to discover a pattern that might be extrapolated beyond age 10

We can think of the uncensored rate R as a function of the first time rate r, 
the rate among repeater breadwinners (rr), and the proportion who have previously breadwon (ppbw).

R = ppbw*rr + (1-ppbw)*r.
What we want is the pattern of relationship between r and rr as if varies by duration. Ideally
we'd get a constant deflation rate that we could apply across all durations. The results 
above don't provide strong support for a constant deflation rate. A conservative 
approach would be to increase the deflation rate a small amount at each duration, but how much?

Note that the difference in the transition rates censored and uncensord is both a function of the
bias (i.e. dfference in transition rates for never breadwinners and previous breadwinners) 
and of the proportion of the estimate based on the population producing the bias (previous breadwinners).

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


