Estimates of number of years spent as a non or secondary earner, primary earner, sole earner, and in a zero-earnnings household for total, by race-ethnicty, and by educational attainment.


## Breadwinning duration (50% cutoff)
--------------------------------------------------------------------------------

~~~~
<<dd_do: quietly>>

	use "$SIPP14keep/transrates50t.dta", clear
	lxpct_2, i(3) d(0)
	global all50 = round(e_x[1,4], .1)

<</dd_do>>
~~~~


|Demographic  							|Years of Breadwinning                |
|:--------------------------------------|:-----------------------------------:|
|All mothers						    | <<dd_di: "$all50" >>                |


### By race/ethnicity (50% cutoff)

~~~~
<<dd_do: quietly>>

	// White
	use "$SIPP14keep/transrates50w.dta", clear
	lxpct_2, i(3) d(0)
	global white50 = round(e_x[1,4], .1)

	// Black
	use "$SIPP14keep/transrates50b.dta", clear
	lxpct_2, i(3) d(0)
	global black50 = round(e_x[1,4], .1)

	//Hispanic
	use "$SIPP14keep/transrates50h.dta", clear
	lxpct_2, i(3) d(0)
	global hisp50 = round(e_x[1,4], .1)

<</dd_do>>
~~~~

|Demographic  							| Years of Breadwinning              |
|:--------------------------------------|:----------------------------------:|
White (non-hispanic)                    | <<dd_di: %2.1f "$white50" >>  	 |
Black (non-hispanic)                    | <<dd_di: %2.1f "$black50" >>  	 |
Hispanic                     	        | <<dd_di: %2.1f "$hisp50" >>  		 |


### By mothers' education at first birth (50% cutoff)

~~~~
<<dd_do: quietly>>

	// Less than HS
	use "$SIPP14keep/transrates50e1.dta", clear
	lxpct_2, i(3) d(0)
	global lesshs50 = round(e_x[1,4], .1)

	// High school
	use "$SIPP14keep/transrates50e2.dta", clear
	lxpct_2, i(3) d(0)
	global hs50 = round(e_x[1,4], .1)

	// Some college
	use "$SIPP14keep/transrates50e3.dta", clear
	lxpct_2, i(3) d(0)
	global somecol50 = round(e_x[1,4], .1)

	// College
	use "$SIPP14keep/transrates50e4.dta", clear
	lxpct_2, i(3) d(0)
	global univ50 = round(e_x[1,4], .1)

<</dd_do>>
~~~~

|Demographic  							| Years of Breadwinning              |
|:--------------------------------------|:----------------------------------:|
Less than high school                   | <<dd_di: %2.1f "$lesshs50" >>  	 |
High school diploma                     | <<dd_di: %2.1f "$hs50" >>  		 |
Some college                   	        | <<dd_di: %2.1f "$somecol50" >>  	 |
College degree                 	        | <<dd_di: %2.1f "$univ50" >>  	     |



## Breadwinning duration (60% cutoff)
--------------------------------------------------------------------------------

~~~~
<<dd_do: quietly>>

	use "$SIPP14keep/transrates60t.dta", clear
	lxpct_2, i(3) d(0)
	global all60 = round(e_x[1,4], .1)

<</dd_do>>
~~~~


|Demographic  							|Years of Breadwinning                |
|:--------------------------------------|:-----------------------------------:|
|All mothers						    | <<dd_di: "$all60" >>                |


### By race/ethnicity (60% cutoff)

~~~~
<<dd_do: quietly>>

	// White
	use "$SIPP14keep/transrates60w.dta", clear
	lxpct_2, i(3) d(0)
	global white60 = round(e_x[1,4], .1)

	// Black
	use "$SIPP14keep/transrates60b.dta", clear
	lxpct_2, i(3) d(0)
	global black60 = round(e_x[1,4], .1)

	//Hispanic
	use "$SIPP14keep/transrates60h.dta", clear
	lxpct_2, i(3) d(0)
	global hisp60 = round(e_x[1,4], .1)

<</dd_do>>
~~~~

|Demographic  							| Years of Breadwinning              |
|:--------------------------------------|:----------------------------------:|
White (non-hispanic)                    | <<dd_di: %2.1f "$white60" >>  	 |
Black (non-hispanic)                    | <<dd_di: %2.1f "$black60" >>  	 |
Hispanic                     	        | <<dd_di: %2.1f "$hisp60" >>  		 |


### By mothers' education at first birth (60% cutoff)

~~~~
<<dd_do: quietly>>

	// Less than HS
	use "$SIPP14keep/transrates60e1.dta", clear
	lxpct_2, i(3) d(0)
	global lesshs60 = round(e_x[1,4], .1)

	// High school
	use "$SIPP14keep/transrates60e2.dta", clear
	lxpct_2, i(3) d(0)
	global hs60 = round(e_x[1,4], .1)

	// Some college
	use "$SIPP14keep/transrates60e3.dta", clear
	lxpct_2, i(3) d(0)
	global somecol60 = round(e_x[1,4], .1)

	// College
	use "$SIPP14keep/transrates60e4.dta", clear
	lxpct_2, i(3) d(0)
	global univ60 = round(e_x[1,4], .1)

<</dd_do>>
~~~~

|Demographic  							| Years of Breadwinning              |
|:--------------------------------------|:----------------------------------:|
Less than high school                   | <<dd_di: %2.1f "$lesshs60" >>  	 |
High school diploma                     | <<dd_di: %2.1f "$hs60" >>  		 |
Some college                   	        | <<dd_di: %2.1f "$somecol60" >>  	 |
College degree                 	        | <<dd_di: %2.1f "$univ60" >>  	     |
