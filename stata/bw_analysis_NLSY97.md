Breadwinner Estimates (NLSY 1997)
================================================================================
~~~~
<<dd_do: quietly>>

* Called by breadwinnerNLSY97.do, this file descibes the data and measures for the 
* breadwinner paper. We use data from the NLSY97 to estimate risks of becoming 
* a breadwinner at each duration of motherhood using data from the NLSY 1997.

* This file won't work properly unless the earlier data files are created during 
* the same stata session.

<</dd_do>>
~~~~

The purpose of this analysis of the NLSY97 data is to describe mothers' odds of 
having ever been a breadwinning mother by 9 years after first birth. 

Sample
--------------------------------------------------------------------------------
This analysis uses data from the [National Longitudinal Survey of Youth, 1997 cohort](https://www.nlsinfo.org/content/cohorts/nlsy97).
We use all available rounds of the survey data, which spans 1997-98 to 2017-18.

The total sample consists of <<dd_di: %10.0fc "$all_n" >> individuals.

We restricted the sample to <<dd_di: %6.0fc "$momunder30_n">> women who first became 
mothers when they were at least 18 years old and younger than 30 years old.  

Sample Construction
--------------------------------------------------------------------------------
  
~~~~
<<dd_do: quietly>>
* The following macros were created in the 01_nlsy97_sample & demo .do file:
	** $all_n $women_n $mom_n $mom18plus_n $momunder30_n
<</dd_do>>
~~~~
  
|__Restiction__  						| __Cases remaining__ 					 |
|:--------------------------------------|:-------------------------------------- |
|Raw sample								|  <<dd_di: %10.0fc "$all_n" >> 		 |
|Women									|  <<dd_di: %10.0fc "$women_n" >>  		 |
|Mothers								|  <<dd_di: %10.0fc "$mom_n" >> 		 |
|Total # moms 18+ at first birth		|  <<dd_di: %10.0fc "$mom18plus_n" >> 	 |
|Total # moms <30 at first birth		|  <<dd_di: %10.0fc "$momunder30_n" >> 	 |

  
NLSY Results
--------------------------------------------------------------------------------

~~~~
<<dd_do: quietly>>

 	 do "04_nlsy97_bw_estimates_hh50.do"

<</dd_do>>
~~~~

In the NLSY 1997, we observe <<dd_di: "$per_bw50_atbirth""%">> breadwining, 
or earning more than 50% of the household income in the year mothers give birth for the fist time. 

The percent breadwinning (50% threhold) in the first year, by education
~~~~
<<dd_do>>

tab educ hhe50 if time	==0 [fweight=wt1997], matcell(bw50w) nofreq row

<</dd_do>>
~~~~

The percent breadwinning (50% threhold) by motherhood duration & education (not censored)
~~~~
<<dd_do>>

sort educ 
preserve
drop if educ==.
by educ: tab time hhe50 [fweight=wt1997], nofreq row
restore

<</dd_do>>
~~~~

Censored: percent breadwinning (50% threhold) by motherhood duration & education

| Time	| <  high school            | High school           | Some college               | College degree|
|:------|:--------------------------|:----------------------|:---------------------------|:-----------------------|
|	1	| <<dd_di: "$lesshs1""%" >>	| <<dd_di: "$hs1""%" >> | <<dd_di: "$somecol1""%" >> | <<dd_di: "$univ1""%" >>
|	2	| <<dd_di: "$lesshs2""%" >> | <<dd_di: "$hs2""%" >> | <<dd_di: "$somecol2""%" >> | <<dd_di: "$univ2""%" >>
|	3	| <<dd_di: "$lesshs3""%" >>	| <<dd_di: "$hs3""%" >> | <<dd_di: "$somecol3""%" >> | <<dd_di: "$univ3""%" >>
|	4	| <<dd_di: "$lesshs4""%" >>	| <<dd_di: "$hs4""%" >>	| <<dd_di: "$somecol4""%" >> | <<dd_di: "$univ4""%" >>
|	5	| <<dd_di: "$lesshs5""%" >>	| <<dd_di: "$hs5""%" >>	| <<dd_di: "$somecol5""%" >> | <<dd_di: "$univ5""%" >>
|	6	| <<dd_di: "$lesshs6""%" >> | <<dd_di: "$hs6""%" >> | <<dd_di: "$somecol6""%" >> | <<dd_di: "$univ6""%" >>
|	7	| <<dd_di: "$lesshs7""%" >> | <<dd_di: "$hs7""%" >> | <<dd_di: "$somecol7""%" >> | <<dd_di: "$univ7""%" >>
|	8	| <<dd_di: "$lesshs8""%" >> | <<dd_di: "$hs8""%" >> | <<dd_di: "$somecol8""%" >> | <<dd_di: "$univ8""%" >>

The percentage that have never been a breadwinning mother when their first child is age 8 
is <<dd_di: "$notbwc50""%">>.

The percentage breadwinning (50% threshold) by the time their first child is age 8 is __<<dd_di: "$bwc50_bydur8""%">>__.

The percentage breadwinning by the time their first child is age **7** by education at first birth:

|__Mothers' Education at First Birth__	| __% breadwinning at 50% threshold__	 |
|:--------------------------------------|:-------------------------------------- |
|Less than high school					|  <<dd_di: "$bwc50_bydur7_lesshs""%" >> |
|High school							|  <<dd_di: "$bwc50_bydur7_hs""%" >> 	 |
|Some college							|  <<dd_di: "$bwc50_bydur7_somecol""%">> |
|College degree							|  <<dd_di: "$bwc50_bydur7_univ""%" >> 	 |


Using a conservative 60% threshold of family income to determine primary earning status, 
__<<dd_di: "$bwc60_bydur8""%">>__ of American mothers can expect to be the  
primary earners in their household at some point during their first 8 years of motherhood.


The percentage breadwinning by the time their first child reaches age **7** by education at first birth:

|__Mothers' Education at First Birth__	| __% breadwinning at 60% threshold__	 |
|:--------------------------------------|:-------------------------------------- |	
|Less than high school					|  <<dd_di: "$bwc60_bydur7_lesshs""%" >> |
|High school							|  <<dd_di: "$bwc60_bydur7_hs""%" >> 	 |
|Some college							|  <<dd_di: "$bwc60_bydur7_somecol""%">> |
|College degree							|  <<dd_di: "$bwc60_bydur7_univ""%" >> 	 |
