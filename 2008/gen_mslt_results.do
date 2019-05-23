Estimates of number of years spent as a non or secondary earner, primary earner, sole earner, and in a zero-earnnings household for total, by race-ethnicty, and by educational attainment.
~~~~
<<dd_do: quietly>>

use "$SIPP08keep/transrates50.dta", clear

quietly lxpct_2, i(5) d(0)

<</dd_do>>
~~~~

                     not primary earner   primary earner  sole-earner  zero-earning hh
Total     <<dd_display: %8.1f e_x[1,3]>> <<dd_display: %8.1f e_x[1,4]>> <<dd_display: %8.1f e_x[1,5]>> <<dd_display: %8.1f e_x[1,6]>>

~~~~
<<dd_do: quietly>>

use "$SIPP08keep/transrates50w.dta", clear

quietly lxpct_2, i(5) d(0)

<</dd_do>>
~~~~
non-Hispanic white  <<dd_display: %8.1f e_x[1,3]>> <<dd_display: %8.1f e_x[1,4]>> <<dd_display: %8.1f e_x[1,5]>> <<dd_display: %8.1f e_x[1,6]>>
~~~~
<<dd_do: quietly>>

use "$SIPP08keep/transrates50b.dta", clear

quietly lxpct_2, i(5) d(0)

<</dd_do>>
~~~~
black              <<dd_display: %8.1f e_x[1,3]>> <<dd_display: %8.1f e_x[1,4]>> <<dd_display: %8.1f e_x[1,5]>> <<dd_display: %8.1f e_x[1,6]>>
~~~~
<<dd_do: quietly>>

use "$SIPP08keep/transrates50h.dta", clear

quietly lxpct_2, i(5) d(0)

<</dd_do>>
~~~~
non-black Hispanic  <<dd_display: %8.1f e_x[1,3]>> <<dd_display: %8.1f e_x[1,4]>> <<dd_display: %8.1f e_x[1,5]>> <<dd_display: %8.1f e_x[1,6]>>
~~~~
<<dd_do: quietly>>

use "$SIPP08keep/transrates50e1.dta", clear

quietly lxpct_2, i(5) d(0)

<</dd_do>>
~~~~


                       not primary earner   primary earner  sole-earner  zero-earning hh
Less than High School  <<dd_display: %8.1f e_x[1,3]>> <<dd_display: %8.1f e_x[1,4]>> <<dd_display: %8.1f e_x[1,5]>> <<dd_display: %8.1f e_x[1,6]>>
~~~~
<<dd_do: quietly>>

use "$SIPP08keep/transrates50e2.dta", clear

quietly lxpct_2, i(5) d(0)

<</dd_do>>
~~~~
High School grad    <<dd_display: %8.1f e_x[1,3]>> <<dd_display: %8.1f e_x[1,4]>> <<dd_display: %8.1f e_x[1,5]>> <<dd_display: %8.1f e_x[1,6]>>
~~~~
<<dd_do: quietly>>
use "$SIPP08keep/transrates50e3.dta", clear

quietly lxpct_2, i(5) d(0)

<</dd_do>>
~~~~
Some College        <<dd_display: %8.1f e_x[1,3]>> <<dd_display: %8.1f e_x[1,4]>> <<dd_display: %8.1f e_x[1,5]>> <<dd_display: %8.1f e_x[1,6]>>
~~~~
<<dd_do: quietly>>

use "$SIPP08keep/transrates50e4.dta", clear

quietly lxpct_2, i(5) d(0)

<</dd_do>>
~~~~
College Grad        <<dd_display: %8.1f e_x[1,3]>> <<dd_display: %8.1f e_x[1,4]>> <<dd_display: %8.1f e_x[1,5]>> <<dd_display: %8.1f e_x[1,6]>>
                      

