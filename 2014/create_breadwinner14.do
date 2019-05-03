* This file creates measures of breadwinning for a sample of mothers with coresident minor children
* 
* by Kerry Waldrep

* Read in data extract
use "$SIPPextracts/breadwinning_extract_SIPP14.dta", clear

*******************************************************************************
* Create earnings variables 
*******************************************************************************

* need to create household and personal annual earnings before dropping any individuals or months

egen year_pearn=total(TPEARN), by(SSUID PNUM)
egen THEARN=total(TPEARN), by(SSUID MONTHCODE)
egen year_hearn=total(TPEARN), by(SSUID)

label variable THEARN "monthly household earnings"
label variable year_pearn "Personal annual earnings 2013"
label variable year_hearn "Household annual earnings 2013"

********************************************************************************
* Sample selection
********************************************************************************
//Limit respondents to their December month code
//none missing; every observation has a coded month
keep if MONTHCODE == 12

//Limit to women
//ESEX: Sex of this person: 1. Male; 2. Female
//none missing
keep if ESEX == 2

//Find respondents who are mothers
//codebook explains that TCEB is asked to all respondents age 15 or older
keep if TAGE >= 15
tab TCEB, m
//120 observations are still missing for TCEB; 7,871 have 0 children ever born.  Might any of them still be mothers?

tab EPAR_SCRNR, m
//Shows whether respondent is a parent (biological, adoptive, or step); 1. Yes; 2. No
drop if EPAR_SCRNR == 2
tab TCEB, m
//348 with 0 children ever born; 3 with missing data

//Confirm that children are under 18 and in the house
tab ERP, m
//Identifies if adult is a reference parent to any household children under 18 years old; 1. Yes; 2. No
tab TYEAR_FB, m
//Identifies year of first birth, ensures first child is 18 or younger
keep if TYEAR_FB >= 1996
//Now we have first births in 1996 or later, but must confirm that the children live in the house
drop if ERP == 2
tab ERP TYEAR_FB, m
//still have 3 missing observations and 101 who record (1) that yes, they have a child under 18 in the house but no recorded year of that child's birth
//are those perhaps adoptive parents?  step parents?  Could they be grandparents?
//Looking in the data at EPAR1TYP for those whose TYEAR_FB == ., all but 4 have missing EPAR1TYP.  There are 4 who record 1 (indicating a biological parent relationship)
//For EPAR2TYP for those whose TYEAR_FB == ., all but 2 are missing; the 2 with data record 1 (a biological parent relationship).

********************************************************************************
* analytical variable creation
********************************************************************************

gen motherhoodyear = .
forvalues year=0/18{
	replace motherhoodyear = `year' if TYEAR_FB == 2014-`year'
}
recode motherhoodyear (0/1=1)
tab motherhoodyear, m

tab RHNUMU18
//This shows the number of persons in the household under 18 years this month.  So these could be adopted or stepchildren?
//some people with RHNUMU18 = 0 (so no persons under 18 living in the household) have one or two children.  So their children are gone;
//other people who have not given birth to children are living with children in their households.

//Look for rates of personal income and household income.
sum TPTOTINC
//TPTOTINC and THTOTINC data available for all respondents
count if THTOTINC <= 0
count if THTOTINC < 0
//164 respondents had a household income of 0
//18 people with a negative household income, ranging from -27 to -30,767

//Create a variable for household contribution
gen contrib = year_pearn/year_hearn
sum contrib
count if contrib > 1
count if contrib < 0
//Where contrib < 0, is the mother contributing positively or negatively?
//Where contrib > 1, is the mother contributing more than the household total?
//recalculate a contribution with mothers' positive contributions included
//separate calculations for mother's contribution of 0 in a household income of 0
gen contrib2 = contrib if contrib <= 1 & contrib >= 0
gen negpinc=1 if year_pearn < 0
gen neghinc=1 if year_hearn < 0
count if year_pearn == 0
//XXXX respondents contributed $0 of personal income
count if year_pearn == 0 & year_hearn == 0
replace contrib2=0 if year_pearn==0 & year_hearn==0
//XXX respondents contributed $0 to a household income of $0
count if year_pearn < 0
//XX respondents reported a negative personal income
replace contrib2 = 0 if year_pearn <= 0
count if year_pearn > 0 & year_hearn < 0
//X respondents contributed positive personal income but had a negative household income
replace contrib2 = 1 if year_pearn > 0 & year_hearn < 0
count if year_pearn > year_hearn
//XX respondents contributed more personal income than their total household income
replace contrib2 = 1 if year_pearn > year_hearn
count if contrib != contrib2

//create variables for breadwinning
gen breadwin50 = 1 if contrib2 >= .5
replace breadwin50 = 0 if contrib2 < .5

gen breadwin60 = 1 if contrib2 >= .6
replace breadwin60 = 0 if contrib2 < .6

//create educational status
gen educstatus = .
//Educational Status levels of: 1 = less than high school degree; 2 = high school degree but less than a 4-year college degree; 
//3 = 4-year college degree; 5 = advanced degree
replace educstatus = 1 if EEDUC <= 38
replace educstatus = 2 if EEDUC == 39 | EEDUC == 40 | EEDUC == 41 | EEDUC == 42
replace educstatus = 3 if EEDUC == 43
replace educstatus = 4 if EEDUC >= 44

label define educ 1 "< high school" 2 "High School and Some College" 3 "College Grad" 4 "Post Bach"
label values educstatus educ

//create marital status
gen married = 1 if EMS == 1 | EMS == 2 
replace married = 2 if EMS == 3 | EMS == 4 | EMS == 5 | EMS == 6 | EMS == .

label define married 1 "married" 2 "not married"
label values married married

save "$SIPP14keep/breadwinner14.dta", $replace

tab neghinc, m
tab negpinc, m

drop if neghinc==1 

keep if motherhoodyear > 0 & motherhoodyear < 18

gen ratio=year_pearn/year_hearn
if year_pearn==0 & year_hearn==0 then ratio==0

gen catratio=int(ratio*10) if ratio >= 0 & ratio <= 1
replace catratio=-1 if ratio < 0
replace catratio=20 if ratio > 1

sum breadwin50 year_pearn year_hearn TPEARN THEARN ratio contrib2

tab catratio breadwin50

*tab motherhoodyear breadwin50 
*tab motherhoodyear breadwin50 if married==0
*tab motherhoodyear breadwin50 if married==1


