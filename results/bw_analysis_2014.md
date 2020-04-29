Breadwinner Estimates (SIPP 2014)
================================================================================
~~~~
<<dd_do: quietly>>
* Called by breadwinner14.do, this file descibes the data and measures for the breadwinner paper.
* It won't work properly unless the earlier data files are created during the same stata session.
<</dd_do>>
~~~~

Data
--------------------------------------------------------------------------------
This analysis uses data from the [2014 Survey of Income and Program Participation](https://www.census.gov/programs-surveys/sipp/data/datasets.html).
We use all 4 waves of the survey data, which spans January 2013 to December 2016.
The total sample consists of <<dd_di: %10.0fc "$allindividuals" >> individuals.

~~~~
<<dd_do: quietly>>
* The $allindividuals macro was created in the extract_earnings script.
<</dd_do>>
~~~~

The description of the variables can be found in the [SIPP 2014 Wave 4 Metadata report](https://www2.census.gov/programs-surveys/sipp/data/datasets/2014/w4/2014SIPP_W4_Metadata_AllSections.pdf).
We use the following variables for this analysis.

|Variable		| Description 													|
|:--------------|:--------------------------------------------------------------|
|_TECHNICAL_	| 																|
|swave  		| Wave number of interview |
|einttype  		| Type of interview |
|monthcode  	| Value of reference month |
|wpfinwgt  		| Final person weight |
|ssuid  		| Sample unit identifier.  |
|pnum 			| Person number |
|epnpar1  		| Person number of parent 1 |
|epnpar2  		| Person number of parent 2 |
|epnspouse 		| Person number of spouse |
|rfamrefwt2  	| Person number of the family reference person (with Type 2 persons) |
|et2_lno*		| Person number of the first Type 2 person |
|eresidenceid 	| This field stores a unique six-digit identifier for residence addresses |
|shhadid  		| Household address ID. Differentiates households spawned from an original sample household |
|_HOUSEHOLD_	| 																|
|erelrp  		| Household relationship (old values) |
|epar1typ  		| Type of relationship to parent 1 |
|epar2typ   	| Type of relationship to parent 2 |
|rhnumper  		| Number of persons in household this month |
|rhnumperwt2 	| Number of persons in household this month (with Type 2 persons) |
|rhnumu18  		| Number of persons in household under 18 years this month |
|rhnumu18wt2  	| Number of persons in household under 18 years this month (with Type 2 persons) |
|rhnum65over  	| Number of persons in household 65 years and over this month |
|rhnum65ovrt2 	| Number of persons in household 65 years and over this month (with Type 2 persons) |
|et2_mth*		| Did ... live with the first Type 2 person during month *? |
|rrel*  		| Monthly household relationship to person |
|rrel_pnum* 	| Person number for monthly relationship |
|aroutingsrop	| Status Flag: Number of times the other parent takes child 0-5 on outings. |
|_FINANCIAL_	| 																|
|tftotinc 		| Sum of the reported monthly earning and income received by all individuals in a family |
|thtotinc  		| Sum of all earnings and income received by a household |
|tpearn			| Sum of earnings and profits/losses from all jobs |
|apearn			| Status Flag: tpearn |
|tjb?_msum		| Monthly earnings from job * |
|ajb?_msum		| Status Flag: tjb?_msum |
|_DEMOGRAPHIC_	| 																|
|ems  			| Is ... currently married, widowed, divorced, separated, or never married? |
|tceb			| Children ever born/fathered |
|tcbyr_* 		| Birth year of child |
|eorigin  		| Is ... Spanish, Hispanic, or Latino? |
|erace  		| What race(s) does ... consider herself/himself to be? |
|esex  			| Sex of this person |
|et2_sex*		| What is the * Type 2 person's sex? |
|tage   		| Age as of last birthday |
|tt2_age		| What is the * Type 2 person's age? |
|eeduc  		| What is the highest level of school ... completed or the highest degree received.... |
|rged 			| Did respondent complete high school by diploma or GED? |
|renroll  		| Recode for monthly enrollment status |
|eedgrade  		| Grade level of spell of enrollment |
|eedgrep  		| Repeated a grade |
|rfoodr  		| Recode for the raw food security score that is a count of affirmative responses |
|rfoods  		| Recode variable for food security status |
|rhpov 			| Household poverty threshold in this month, excluding Type 2 individuals |
|rhpovt2 		| Household poverty threshold in this month, including Type 2 individuals |
|thincpov  		| Household income-to-poverty ratio in this month, excluding Type 2 individuals |
|thincpovt2  	| Household income-to-poverty ratio in this month, including Type 2 individuals |
|tst_intv  		| State of residence for the interview address |

Sample
--------------------------------------------------------------------------------
We restricted the sample to <<dd_di: %6.0fc "$minus_oldmoms">> women who first became mothers less than 19 years prior 
to each interview.  
We use the birth history measures (year of each birth) to identify the sample eligble to be included in our analysis.

## Sample Construction
~~~~
<<dd_do: quietly>>
* The following macros were created in the extract_earnings script:
	** $allindividuals $women_n $mothers_n $minus_newmoms $minus_oldmoms
* The $mothers_cores_minor macro was created in the annualize script
<</dd_do>>
~~~~

|__Restiction__  						| __Cases left__ |
|:--------------------------------------|:-------------------------------------- |
|Raw sample								| <<dd_di: %10.0fc "$allindividuals" >> |
|Women									| <<dd_di: %10.0fc "$women_n" >> |
|Mothers								| <<dd_di: %10.0fc "$mothers_n" >> |
|No earnings data during reference year	| <<dd_di: %10.0fc "$minus_afterref" >> |
|Motherhood < 19 yrs from interview year| <<dd_di: %10.0fc "$minus_oldmoms" >> |
* JP -- still need to update this with all of the sample restrictions.

Measures
--------------------------------------------------------------------------------
We created a measure of household earnings by aggregating the earnings across all type 1 individuals in the household in each month and 
then aggregating earnings across all months in each year to get an annual measure of household earnings. 

To create indicators of breadwinning we compare each mothers' annual earnings to the annual household earnings 
measures. We consider mothers who earn more than 50% (or 60%) of the household earnings breadwinners.

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

// Prior to substracting 1 we checked the distribution on durmom and found that 
// we had only a small number of women breadwinning at durmom = 0. 
// This is because some of the women whose first
// children are still infants have durmom=1 because those births happened in
// the previous calendar year (SIPP does not give us month of birth on the 
// public-use data file). The estimate of breadwinning at durmom=0 is less
// than half the estimate at durmom=1. We are concerned about using it because
// a) it is based on a small sample size and this will get much worse when we 
// do an analysis by maternal education and b) it's a lot lower than the estimate
// that we get with the NLSY. It's easy to believe that the timing of the interview
// relative to the timing of the birth is not random. 

// Thus, after subtracting 1 from durmom we drop cases where durmom < 0

// below we use the percentage breadwinning at durmom=0 (in the 
// year prior to the interview, when first child was born) to estimate 
// breadwinning at child's birth. 
// We use this same year also to estimate transitions into breadwinning between
// birth and child age 1. 

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

An initial table describing transition rates at all durations using data: 

~~~~
<<dd_do>>

tab durmom trans_bw50 [aweight=wpfinwgt] if trans_bw50 !=2 , matcell(bw50w) nofreq row
tab durmom trans_bw60 [aweight=wpfinwgt] if trans_bw60 !=2 , matcell(bw60w) nofreq row

<</dd_do>>
~~~~

And some quick tables by education. The first is the percent breadwinning at birth by education.
Following there are tables of transitions into breadwinning by duration where durmom=0 
has the transition rate between birth year and age 1. 

~~~~
<<dd_do>>

tab educ bw50 [aweight=wpfinwgt] , nofreq row

sort educ 
by educ: tab durmom trans_bw50 [aweight=wpfinwgt] if trans_bw50 !=2, nofreq row

<</dd_do>>
~~~~

~~~~
<<dd_do: quietly>>
// Now, calculating the proportions not (not!) transitioning into breadwining by hand.

forvalues d=1/18 {
   gen nbbw50_rate`d'=bw50w[`d',1]/(bw50w[`d',1]+bw50w[`d',2])
}

// note d=1 is the rate of transition between birth year and year first child
// turns age 1. d=18 is the transition rate between year first child turned 17 and
// year she turns 18.
forvalues d=1/18 {
   gen nbbw60_rate`d'=bw60w[`d',1]/(bw60w[`d',1]+bw60w[`d',2])
}

// calculating a cumulative risk of breadwinning by age 18 by multiplying rates
* of entry at each duration of breadwinning

* initializing cumulative measure at birth
gen notbw50 = notbw50_atbirth
gen notbw60 = notbw60_atbirth

* the proportion who do not become breadwinners is the proportion not breadwinning at birth times
* the proportion who do not become breadwinners in the first year times....who do not become breadwinners
* in year 17.
forvalues d=1/17 {
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
local bw50_bydur18=100*(1-notbw50)
local bw60_bydur18=100*(1-notbw60)

<</dd_do>>
~~~~

Results
--------------------------------------------------------------------------------

We observe <<dd_di: %4.1f `per_bw50_atbirth'>>% breadwining, or earning more than 50% of the household income in the year of their first birth. 
This estimate is lower (<<dd_di: %4.1f `per_bw60_atbirth'>> percent) using a 60% threshold.

The percentage never breadwinning by the time their first child reaches age 18 is <<dd_di: %4.1f `notbw50'>>, or <<dd_di: %4.1f `notbw60'>> using the 60% threshold.

The percentage breadwinning by the time their first child reaches age 18 is <<dd_di: %4.1f `bw50_bydur18'>>% or <<dd_di: %4.1f `bw60_bydur18'>>% using the 60% threshold.

This is likely an overestimate because many women probably previously breadwon 
prior to our initial observation and, as we explain in the paper, including 
those who breadwon at earlier duration upwardly biases the estimate of risk of 
transitioning into breadwinning at later durations. We can address this by 
limiting te estimate of transitions to later waves among women not observed 
breadwinning in earlier waves.

~~~~
<<dd_do: quietly>>

drop if wave < 3

// need to adjust durmom (see above for full explanation)

drop if durmom < 1 // the estimate at durmom=0 above is unbiased

<</dd_do>>
~~~~

Alternate rates based on data on waves (2), 3, and 4,, among those not previously
observed breadwinning.

~~~~
<<dd_do>>

tab durmom trans_bw50, matcell(bw50uw) // checking n's

tab durmom trans_bw50 [aweight=wpfinwgt] if trans_bw50 !=2 , matcell(bw50w) nofreq row
tab durmom trans_bw60 [aweight=wpfinwgt] if trans_bw60 !=2 , matcell(bw60w) nofreq row

<</dd_do>>
~~~~

We see that on average the transition rates are a slight bit lower when we restrict to 
transitions from wave 2-3 and 3-4. Does it shrink further if we restrict to just
transitions from wave 3-4?

~~~~
<<dd_do>>

drop if wave < 4

tab durmom trans_bw50, matcell(bw50uw) // checking n's

tab durmom trans_bw50 [aweight=wpfinwgt] if trans_bw50 !=2 , matcell(bw50w) nofreq row
tab durmom trans_bw60 [aweight=wpfinwgt] if trans_bw60 !=2 , matcell(bw60w) nofreq row


<</dd_do>>
~~~~
