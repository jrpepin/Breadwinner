Estimates of number of years spent as a non or secondary earner, primary earner, sole earner, and in a zero-earnnings household for total, by race-ethnicty, and by educational attainment.

~~~~

First using the 50% cutoff    
<<dd_do: quietly>>

use "$SIPP08keep/transrates50.dta", clear

lxpct_2, i(3) d(0)

<</dd_do>>
~~~~

                     not primary earner   primary earner  sole-earner  
Total     <<dd_display: %8.1f e_x[1,2]>> <<dd_display: %8.1f e_x[1,3]>> <<dd_display: %8.1f e_x[1,4]>> 
~~~~
<<dd_do: quietly>>

use "$SIPP08keep/transrates50w.dta", clear

quietly lxpct_2, i(3) d(0)

<</dd_do>>
~~~~
non-Hispanic_white  <<dd_display: %8.1f e_x[1,2]>> <<dd_display: %8.1f e_x[1,3]>> <<dd_display: %8.1f e_x[1,4]>> 
~~~~
<<dd_do: quietly>>

use "$SIPP08keep/transrates50b.dta", clear

quietly lxpct_2, i(3) d(0)

<</dd_do>>
~~~~
black              <<dd_display: %8.1f e_x[1,2]>> <<dd_display: %8.1f e_x[1,3]>> <<dd_display: %8.1f e_x[1,4]>> 
~~~~
<<dd_do: quietly>>

use "$SIPP08keep/transrates50h.dta", clear

quietly lxpct_2, i(3) d(0)

<</dd_do>>
~~~~
non-black_Hispanic  <<dd_display: %8.1f e_x[1,2]>> <<dd_display: %8.1f e_x[1,3]>> <<dd_display: %8.1f e_x[1,4]>> 
~~~~
<<dd_do: quietly>>

use "$SIPP08keep/transrates50e1.dta", clear

quietly lxpct_2, i(3) d(0)

<</dd_do>>
~~~~


                       not primary earner   primary earner  sole-earner  
Less_than_High_School  <<dd_display: %8.1f e_x[1,2]>> <<dd_display: %8.1f e_x[1,3]>> <<dd_display: %8.1f e_x[1,4]>> 
~~~~
<<dd_do: quietly>>

use "$SIPP08keep/transrates50e2.dta", clear

quietly lxpct_2, i(3) d(0)

<</dd_do>>
~~~~
High_School_grad    <<dd_display: %8.1f e_x[1,2]>> <<dd_display: %8.1f e_x[1,3]>> <<dd_display: %8.1f e_x[1,4]>> 
~~~~
<<dd_do: quietly>>
use "$SIPP08keep/transrates50e3.dta", clear

quietly lxpct_2, i(3) d(0)

<</dd_do>>
~~~~
Some College        <<dd_display: %8.1f e_x[1,2]>> <<dd_display: %8.1f e_x[1,3]>> <<dd_display: %8.1f e_x[1,4]>> 
~~~~
<<dd_do: quietly>>

use "$SIPP08keep/transrates50e4.dta", clear

quietly lxpct_2, i(3) d(0)

<</dd_do>>
~~~~
College_Grad        <<dd_display: %8.1f e_x[1,2]>> <<dd_display: %8.1f e_x[1,3]>> <<dd_display: %8.1f e_x[1,4]>> 

Next using the 60% cutoff    

<<dd_do: quietly>>

use "$SIPP08keep/transrates60.dta", clear

quietly lxpct_2, i(3) d(0)

<</dd_do>>
~~~~

                     not primary earner   primary earner  sole-earner  
Total     <<dd_display: %8.1f e_x[1,2]>> <<dd_display: %8.1f e_x[1,3]>> <<dd_display: %8.1f e_x[1,4]>> 

~~~~
<<dd_do: quietly>>

use "$SIPP08keep/transrates60w.dta", clear

quietly lxpct_2, i(3) d(0)

<</dd_do>>
~~~~
non-Hispanic_white  <<dd_display: %8.1f e_x[1,2]>> <<dd_display: %8.1f e_x[1,3]>> <<dd_display: %8.1f e_x[1,4]>> 
~~~~
<<dd_do: quietly>>

use "$SIPP08keep/transrates60b.dta", clear

quietly lxpct_2, i(3) d(0)

<</dd_do>>
~~~~
black              <<dd_display: %8.1f e_x[1,2]>> <<dd_display: %8.1f e_x[1,3]>> <<dd_display: %8.1f e_x[1,4]>> 
~~~~
<<dd_do: quietly>>

use "$SIPP08keep/transrates60h.dta", clear

quietly lxpct_2, i(3) d(0)

<</dd_do>>
~~~~
non-black_Hispanic  <<dd_display: %8.1f e_x[1,2]>> <<dd_display: %8.1f e_x[1,3]>> <<dd_display: %8.1f e_x[1,4]>> 
~~~~
<<dd_do: quietly>>

use "$SIPP08keep/transrates60e1.dta", clear

quietly lxpct_2, i(3) d(0)

<</dd_do>>
~~~~


                       not primary earner   primary earner  sole-earner  
Less_than_High_School  <<dd_display: %8.1f e_x[1,2]>> <<dd_display: %8.1f e_x[1,3]>> <<dd_display: %8.1f e_x[1,4]>> 
~~~~
<<dd_do: quietly>>

use "$SIPP08keep/transrates60e2.dta", clear

quietly lxpct_2, i(3) d(0)

<</dd_do>>
~~~~
High_School_Grad    <<dd_display: %8.1f e_x[1,2]>> <<dd_display: %8.1f e_x[1,3]>> <<dd_display: %8.1f e_x[1,4]>> 
~~~~
<<dd_do: quietly>>
use "$SIPP08keep/transrates60e3.dta", clear

quietly lxpct_2, i(3) d(0)

<</dd_do>>
~~~~
Some_College        <<dd_display: %8.1f e_x[1,2]>> <<dd_display: %8.1f e_x[1,3]>> <<dd_display: %8.1f e_x[1,4]>> 
~~~~
<<dd_do: quietly>>

use "$SIPP08keep/transrates60e4.dta", clear

quietly lxpct_2, i(3) d(0)

<</dd_do>>
~~~~
College_Grad        <<dd_display: %8.1f e_x[1,2]>> <<dd_display: %8.1f e_x[1,3]>> <<dd_display: %8.1f e_x[1,4]>> 

