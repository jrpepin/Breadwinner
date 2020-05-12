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

In the NLSY 1997, we observe <<dd_di: "$per_bw50_atbirth""%">> breadwining, 
or earning more than 50% of the household income in the year mothers give birth for the fist time. 

The percent breadwinning (50% threhold) by motherhood duration & education (not censored)
~~~~
<<dd_do: quietly>>

forvalues e=1/4{
	local tbw`e'_0: di %4.1fc = 100*peratbirth50_`e'[1,1]
	local fbw`e'_0: di %4.1fc = 100*peratbirth50_`e'[1,1]
}

forvalues t=1/7 {
	forvalues e=1/4 {
		local tbw`e'_`t': di %4.1fc = 100*transbw50`e'_`t'[1,1]
		local fbw`e'_`t': di %4.1fc = 100*firstbw50`e'_`t'[1,1]
	}
}


<</dd_do>>
~~~~

Not censored: percent breadwinning (50% threhold) by motherhood duration & education

| Time	| <  high school            | High school           | Some college               | College degree|
|:------|:--------------------------|:----------------------|:---------------------------|:-----------------------|
|	0	| <<dd_di: "`tbw1_0'""%" >>	| <<dd_di: "`tbw2_0'""%" >> | <<dd_di: "`tbw3_0'""%" >> | <<dd_di: "`tbw4_0'""%" >>
|	1	| <<dd_di: "`tbw1_1'""%" >> | <<dd_di: "`tbw2_1'""%" >> | <<dd_di: "`tbw3_1'""%" >> | <<dd_di: "`tbw4_1'""%" >>
|	2	| <<dd_di: "`tbw1_2'""%" >>	| <<dd_di: "`tbw2_2'""%" >> | <<dd_di: "`tbw3_2'""%" >> | <<dd_di: "`tbw4_2'""%" >>
|	3	| <<dd_di: "`tbw1_3'""%" >>	| <<dd_di: "`tbw2_3'""%" >> | <<dd_di: "`tbw3_3'""%" >> | <<dd_di: "`tbw4_3'""%" >>
|	4	| <<dd_di: "`tbw1_4'""%" >>	| <<dd_di: "`tbw2_4'""%" >> | <<dd_di: "`tbw3_4'""%" >> | <<dd_di: "`tbw4_4'""%" >>
|	5	| <<dd_di: "`tbw1_5'""%" >> | <<dd_di: "`tbw2_5'""%" >> | <<dd_di: "`tbw3_5'""%" >> | <<dd_di: "`tbw4_5'""%" >>
|	6	| <<dd_di: "`tbw1_6'""%" >> | <<dd_di: "`tbw2_6'""%" >> | <<dd_di: "`tbw3_6'""%" >> | <<dd_di: "`tbw4_6'""%" >>
|	7	| <<dd_di: "`tbw1_7'""%" >> | <<dd_di: "`tbw2_7'""%" >> | <<dd_di: "`tbw3_7'""%" >> | <<dd_di: "`tbw4_7'""%" >>

Censored: percent breadwinning (50% threhold) by motherhood duration & education

| Time	| <  high school            | High school           | Some college               | College degree|
|:------|:--------------------------|:----------------------|:---------------------------|:-----------------------|
|	0	| <<dd_di: "`fbw1_0'""%" >>	| <<dd_di: "`fbw2_0'""%" >> | <<dd_di: "`fbw3_0'""%" >> | <<dd_di: "`fbw4_0'""%" >>
|	1	| <<dd_di: "`fbw1_1'""%" >> | <<dd_di: "`fbw2_1'""%" >> | <<dd_di: "`fbw3_1'""%" >> | <<dd_di: "`fbw4_1'""%" >>
|	2	| <<dd_di: "`fbw1_2'""%" >>	| <<dd_di: "`fbw2_2'""%" >> | <<dd_di: "`fbw3_2'""%" >> | <<dd_di: "`fbw4_2'""%" >>
|	3	| <<dd_di: "`fbw1_3'""%" >>	| <<dd_di: "`fbw2_3'""%" >> | <<dd_di: "`fbw3_3'""%" >> | <<dd_di: "`fbw4_3'""%" >>
|	4	| <<dd_di: "`fbw1_4'""%" >>	| <<dd_di: "`fbw2_4'""%" >> | <<dd_di: "`fbw3_4'""%" >> | <<dd_di: "`fbw4_4'""%" >>
|	5	| <<dd_di: "`fbw1_5'""%" >> | <<dd_di: "`fbw2_5'""%" >> | <<dd_di: "`fbw3_5'""%" >> | <<dd_di: "`fbw4_5'""%" >>
|	6	| <<dd_di: "`fbw1_6'""%" >> | <<dd_di: "`fbw2_6'""%" >> | <<dd_di: "`fbw3_6'""%" >> | <<dd_di: "`fbw4_6'""%" >>
|	7	| <<dd_di: "`fbw1_7'""%" >> | <<dd_di: "`fbw2_7'""%" >> | <<dd_di: "`fbw3_7'""%" >> | <<dd_di: "`fbw4_7'""%" >>

The percentage that have never been a breadwinning mother when their first child is age 8 
is <<dd_di: "$notbw50dur8""%">>.

The percentage breadwinning (50% threshold) by the time their first child is age 8 is __<<dd_di: "$bwc50_bydur8""%">>__.

The percentage breadwinning by the time their first child is age **7** by education at first birth:

|__Mothers' Education at First Birth__	| __% breadwinning at 50% threshold__	 |
|:--------------------------------------|:-------------------------------------- |
|Less than high school			|  <<dd_di: "$bwc50_bydur7_lesshs""%" >> |
|High school				|  <<dd_di: "$bwc50_bydur7_hs""%" >> 	 |
|Some college				|  <<dd_di: "$bwc50_bydur7_somecol""%">> |
|College degree				|  <<dd_di: "$bwc50_bydur7_univ""%" >> 	 |


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
