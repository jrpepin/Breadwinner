
~~~~
<<dd_do: quietly>>

** This file uses data from the NLSY to estimate risks of becoming a breadwinner
** at each duration of motherhood using data from the NLSY 1997

* data produced by nlsy97_bw_estimates_hh50.do
use "bw50_analysis.dta", clear

// to measure transitions into breadwinning, we need to limit the sample to 
// those who were not breadwinning the previous year. At time==0, 
// no one was a breadwinning mother in the previous year (and hhe50_minus1_ is 
// missing. 
keep if hhe50_minus1_ == 0 | time==0

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
The (new) purpose of the NLSY analysis is to desccribe levels of breadwinning 
by 10 years after first birth using data from the NLSY. 

To start, we produce an initial table describing transition rates at all durations 
using NLSY data. The first table shows by year since first birth the risk of becoming 
a breadwinning mother among women who were not breadwinning mothers in the previous 
year. The second table shows the percentage of mothers ever previously breadwinning by 
number of years since becoming a breadwinner. At year 0 it is impossible to have been a 
breadwinning mother previously. At duration 1 it is impossible to experience a repeat
transition into breadwinning. After that, the proportion who have previously breadwon 
grows (a lot). This suggests that the SIPP could over-estimate lifetime breadwinning to 
be sure one needs to compare this Table 1 to Table 3 to see if the rate of transition
into breadwinning is higher for those who previously breadwon. 

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

We can see that the proportion becoming a breadwinning mother is smaller in the third table
than in the first. This suggests that repeat breadwinning does lead to an overestimate of 
lifetime breadwinning unless one censors on previous breadwinning. 

In any event, Table 3 is presents the information we need to calculate the percentage of women 
(n)ever breadwinning 10 years after becoming a mother. 

~~~~
<<dd_do>>
// Now, calculating the proportions not (not!) transitioning into breadwining by hand.

// estimate censored on prior breadwinning using Table 3 estimates saved in bw50wc
forvalues d=1/9 {
   gen nbbwc50_rate`d'=bw50wc[`d',1]/(bw50wc[`d',1]+bw50wc[`d',2])
}

// calculating a cumulative risk of breadwinning by age 18 by multiplying rates
* of entry at each duration of breadwinning

* initializing cumulative measures
gen notbwc50 = 1

* the proportion who do not become breadwinners is the proportion not breadwinning at birth times
* the proportion who do not become breadwinners in the first year times....who do not become breadwinners
* in year 9.
forvalues d=1/9 {
  replace notbwc50=notbwc50*nbbwc50_rate`d'
}

* make into nice percents
local notbwc50 = 100*notbwc50

gen per_bw50_atbirth=100*(1-bw50wc[1,1]/(bw50wc[1,1]+bw50wc[1,2]))

local per_bw50_atbirth=per_bw50_atbirth

* Take the inverse of the proportion not breadwinning to get the proportion breadwinning.
* Multiply by 100 to get a percent.
local bwc50_bydur9=100*(1-notbwc50)

<</dd_do>>
~~~~

NLSY Results
--------------------------------------------------------------------------------

In the NLSY 1997, we observe <<dd_di: %4.1f `per_bw50_atbirth'>>% breadwining, 
or earning more than 50% of the household income in the year of their first birth. 

The percentage never breadwinning by the time their first child reaches age 10 
is <<dd_di: %4.1f `notbwc50'>>.

The percentage breadwinning by the time their first child reaches age 9 is <<dd_di: %4.1f `bwc50_bydur9'>>%.

