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
We restricted the sample to <<dd_di: %6.0fc "$obvsprev_n" >> women who first became mothers less than 19 years prior 
to each interview (and who had earnings data in the current and previous waves).  
We use the birth history measures (year of each birth) to identify the sample eligble to be included in our analysis.

## Sample Construction

|__Restiction__  						| __Cases left__ |
|:--------------------------------------|:--------------------------------------------|
|Raw sample					| <<dd_di: %10.0fc "$allindividuals" >>  |
|Women						| <<dd_di: %10.0fc "$women_n" >>         |
|Mothers					| <<dd_di: %10.0fc "$mothers_n" >>       |
|Became mother after reference year	     | <<dd_di: %10.0fc "$minus_afterref" >>  |
|Motherhood < 19 yrs from interview year     | <<dd_di: %10.0fc "$minus_oldmoms" >>   |
|Observations with data in the current waves | <<dd_di: %10.0fc "$obvsnow_n" >>       |
|Observations with data in the previous waves | <<dd_di: %10.0fc "$obvsprev_n" >>     |

Measures
--------------------------------------------------------------------------------
We created a measure of household earnings by aggregating the earnings across all type 1 individuals in the household in each month and 
then aggregating earnings across all months in each year to get an annual measure of household earnings. 

To create indicators of breadwinning we compare each mothers' annual earnings to the annual household earnings 
measures. We consider mothers who earn more than 50% (or 60%) of the household earnings breadwinners.

Results
--------------------------------------------------------------------------------

We observe <<dd_di: %4.1f $per_bw50_atbirth>>% breadwining, or earning more than 
50% of the household income in the year of their first birth. This estimate is 
lower (<<dd_di: %4.1f $per_bw60_atbirth>> percent) using a 60% threshold.

Ignoring the possibility of breadwinning prior to first observation, we find that 
the percentage never breadwinning by the time their first child reaches age 18 is 
<<dd_di: %4.1f "$notbw50bydur18""%">>, or <<dd_di: %4.1f "$notbw60bydur18""%">> 
using the 60% threshold. Or, put differently, the percentage breadwinning by the 
time their first child reaches age 18 is <<dd_di: %4.1f "$bw50bydur18""%">> or 
<<dd_di: %4.1f "$bw60bydur18""%">>% using the 60% threshold.

This is likely an overestimate because many women probably previously breadwon 
prior to our initial observation and, as we explain in the paper, including 
those who breadwon at earlier duration upwardly biases the estimate of risk of 
transitioning into breadwinning at later durations. We adjust the transition rates 
at durations greater than 5 to account for this over estimate. We estimated the 
discount rate by taking the average ratio of the rate of transition into breadwinning 
in the NLSY to the rate in the SIPP for durations 5-7. The discount rate was estimated
to be <<dd_di: %6.3g "$discount50" >> at the 50% threshold and <<dd_di: %6.3g "$discount60" >> at the 60% threshold. 

Refer to the excel tables to find the estimates of breadwinning after discounting for repeat breadwinning.


We also investigated the impact of repeat breadwinning by limiting te estimate of 
transitions to later waves among women not observed breadwinning in earlier waves. 
That investigation is in older versions of this file (i.e. prior to May 25, 2020). 
