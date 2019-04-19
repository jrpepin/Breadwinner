# Change the working directory to the repository
setwd("C:/Users/Joanna/Dropbox/Repositories/NLSY97_Breadwinning")

# Use this script after the Investigator R script
# mark out the "Handle missing values" code in the Investigator script to analyze type of missing data

library(tidyverse)
library(lubridate)


## Fix caseID in categories dataset
categories$PUBID_1997 <- new_data$PUBID_1997

# Map special values to NA in every NUMERIC column: Refusal(-1), Don't Know(-2), Invalid Skip (-3),VALID SKIP(-4), NON-INTERVIEW(-5)
# library(naniar)
# na_special <- c(-1,-2,-3,-4,-5)
# new_data <- new_data %>%
  #replace_with_na_if(.predicate = is.integer,
   #                  condition = ~.x %in% (na_special))

## Limit to women
summary(categories$KEY_SEX_1997)

colnames(categories)[colnames(categories) == 'KEY_SEX_1997'] <- 'sex'
categories <- filter(categories, sex == "Female")

colnames(new_data)[colnames(new_data) == 'KEY_SEX_1997'] <- 'sex'
new_data <- filter(new_data, sex == "2")

## Create age variable
new_data$dob <- mdy(paste(new_data$KEY_BDATE_M_1997, "1", new_data$KEY_BDATE_Y_1997, sep='-'))

## Indentify moms

### birth month
mom_month <- new_data %>%
  select(PUBID_1997, starts_with("CV_CHILD_BIRTH_DATE.01~M"))

mom_month[mom_month >= -5 & mom_month <= -1] = NA  # Missing

mom_month <- mom_month %>% 
  gather(var, birth_month, -PUBID_1997)
mom_month <- aggregate(birth_month ~ PUBID_1997, data = mom_month, first)

### birth year
mom_year <- new_data %>%
  select(PUBID_1997, starts_with("CV_CHILD_BIRTH_DATE.01~Y"))

mom_year[mom_year >= -5 & mom_year <= -1] = NA  # Missing

mom_year <- mom_year %>% 
  gather(var, birth_year, -PUBID_1997)
mom_year <- aggregate(birth_year ~ PUBID_1997, data = mom_year, first)


### Add new variables to original dataset
new_data   <- left_join(new_data,   mom_month)
new_data   <- left_join(new_data,   mom_year)

remove(mom_month)
remove(mom_year)

### combine child dob variables
new_data$birth <- mdy(paste(new_data$birth_month, "1", new_data$birth_year, sep='-'))
 # new_data <- subset(new_data, select = -c(birth_month, birth_year))

### Create age at first birth variable
new_data$age_birth <-round((time_length(difftime(new_data$birth, new_data$dob), "years")), digits = 0)

# Marital status variables
marstat <- categories %>%
  select(PUBID_1997, starts_with("CV_MARSTAT_"))

marstat[marstat >= -5 & marstat <= -1] = NA  # Missing

marstat <- marstat %>% 
  gather(var, marst, -PUBID_1997)

marstat <- marstat %>%
  separate(var, c("type", "var", "year"), "_")

marstat <- subset(marstat, select = -c(type, var))
marstat$birth_year   <- new_data$birth_year

# Create the birth year plus 1 variables
marstat$birth_year1 <- marstat$birth_year + 1
marstat$birth_year2 <- marstat$birth_year + 2
marstat$birth_year3 <- marstat$birth_year + 3
marstat$birth_year4 <- marstat$birth_year + 4

# This loses moms who became mothers before 1997// could assume mstatus in 1997 was mstatus at time of birth
marstat <- marstat %>%
  group_by(PUBID_1997) %>% 
  mutate(mar_t0 = case_when(birth_year  == year ~ marst),
         mar_t1 = case_when(birth_year1 == year ~ marst),
         mar_t2 = case_when(birth_year2 == year ~ marst),
         mar_t3 = case_when(birth_year3 == year ~ marst),
         mar_t4 = case_when(birth_year4 == year ~ marst))

marstat <- marstat %>% group_by(PUBID_1997) %>% summarise_all(funs(max(., na.rm = TRUE)))
marstat <- subset(marstat, select = -c(year, marst, birth_year4, birth_year3, birth_year2, birth_year1, birth_year)) # drop extra variables

marstat <- marstat %>%
  mutate(
    mar_t0 = case_when(
      mar_t0   == "Married, spouse present"       |  mar_t0 == "Married, spouse absent"       ~ "Married",
      mar_t0   == "Divorced, cohabiting"          |  mar_t0 == "Never married, cohabiting" |
      mar_t0   == "Separated, cohabiting"         |  mar_t0 == "Widowed, cohabiting"          ~ "Cohab",
      mar_t0   == "Never married, not cohabiting"                                             ~ "Never married",
      mar_t0   == "Divorced, not cohabiting"      |  mar_t0 == "Separated, not cohabiting" |
      mar_t0   == "Widowed, not cohabiting"                                                   ~ "Div/Sep/Wid",
      TRUE                                                                                    ~  NA_character_
    ))
marstat$mar_t0 <- factor(marstat$mar_t0, levels = c("Married", "Cohab", "Never married", "Div/Sep/Wid"))

marstat <- marstat %>%
  mutate(
      mar_t1 = case_when(
      mar_t1   == "Married, spouse present"       |  mar_t1 == "Married, spouse absent"       ~ "Married",
      mar_t1   == "Divorced, cohabiting"          |  mar_t1 == "Never married, cohabiting" |
      mar_t1   == "Separated, cohabiting"         |  mar_t1 == "Widowed, cohabiting"          ~ "Cohab",
      mar_t1   == "Never married, not cohabiting"                                             ~ "Never married",
      mar_t1   == "Divorced, not cohabiting"      |  mar_t1 == "Separated, not cohabiting" |
      mar_t1   == "Widowed, not cohabiting"                                                   ~ "Div/Sep/Wid",
      TRUE                                                                                    ~  NA_character_
    ))
marstat$mar_t1 <- factor(marstat$mar_t1, levels = c("Married", "Cohab", "Never married", "Div/Sep/Wid"))

marstat <- marstat %>%
  mutate(
      mar_t2 = case_when(
      mar_t2   == "Married, spouse present"       |  mar_t2 == "Married, spouse absent"       ~ "Married",
      mar_t2   == "Divorced, cohabiting"          |  mar_t2 == "Never married, cohabiting" |
      mar_t2   == "Separated, cohabiting"         |  mar_t2 == "Widowed, cohabiting"          ~ "Cohab",
      mar_t2   == "Never married, not cohabiting"                                             ~ "Never married",
      mar_t2   == "Divorced, not cohabiting"      |  mar_t2 == "Separated, not cohabiting" |
      mar_t2   == "Widowed, not cohabiting"                                                   ~ "Div/Sep/Wid",
      TRUE                                                                                    ~  NA_character_
    ))
marstat$mar_t2 <- factor(marstat$mar_t2, levels = c("Married", "Cohab", "Never married", "Div/Sep/Wid"))


marstat <- marstat %>%
  mutate(
      mar_t3 = case_when(
      mar_t3   == "Married, spouse present"       |  mar_t3 == "Married, spouse absent"       ~ "Married",
      mar_t3   == "Divorced, cohabiting"          |  mar_t3 == "Never married, cohabiting" |
      mar_t3   == "Separated, cohabiting"         |  mar_t3 == "Widowed, cohabiting"          ~ "Cohab",
      mar_t3   == "Never married, not cohabiting"                                             ~ "Never married",
      mar_t3   == "Divorced, not cohabiting"      |  mar_t3 == "Separated, not cohabiting" |
      mar_t3   == "Widowed, not cohabiting"                                                   ~ "Div/Sep/Wid",
      TRUE                                                                                    ~  NA_character_
    ))
marstat$mar_t3 <- factor(marstat$mar_t3, levels = c("Married", "Cohab", "Never married", "Div/Sep/Wid"))

marstat <- marstat %>%
  mutate(
      mar_t4 = case_when(
      mar_t4   == "Married, spouse present"       |  mar_t4 == "Married, spouse absent"       ~ "Married",
      mar_t4   == "Divorced, cohabiting"          |  mar_t4 == "Never married, cohabiting" |
      mar_t4   == "Separated, cohabiting"         |  mar_t4 == "Widowed, cohabiting"          ~ "Cohab",
      mar_t4   == "Never married, not cohabiting"                                             ~ "Never married",
      mar_t4   == "Divorced, not cohabiting"      |  mar_t4 == "Separated, not cohabiting" |
      mar_t4   == "Widowed, not cohabiting"                                                   ~ "Div/Sep/Wid",
      TRUE                                                                                    ~  NA_character_
    ))
marstat$mar_t4 <- factor(marstat$mar_t4, levels = c("Married", "Cohab", "Never married", "Div/Sep/Wid"))


### Add new variables to original dataset
new_data   <- left_join(new_data,   marstat)

remove(marstat)
  
# R's Income

## Personal Income of R by year

# YINC-1400 - R RECEIVE INCOME FROM JOB IN PAST YEAR? (incd)
# YINC-1500 - INCOME IN WAGES, SALARY, TIPS FROM REGULAR OR ODD JOBS (incd2)
# YINC-1700 - TOTAL INCOME FROM WAGES AND SALARY IN PAST YEAR (wages)
# YINC-1800 - ESTIMATED INCOME FROM WAGES AND SALARY IN PAST YEAR (wages_est)

mominc <- new_data %>%
  select(PUBID_1997, starts_with("YINC-1700"), starts_with("YINC-1400"), starts_with("YINC-1500"), starts_with("YINC-1800")) %>%
  gather(var, val, -PUBID_1997) %>%
  separate(var, c("type", "year"), "_")

mominc <- mominc %>%
  mutate(wages     = case_when(type == "YINC-1700" ~ val),
         incd      = case_when(type == "YINC-1400" ~ val),
         incd2     = case_when(type == "YINC-1500" ~ val),
         wages_est = case_when(type == "YINC-1800" ~ val)) %>%
  group_by(PUBID_1997, year) %>% 
  summarise(wages = first(wages), incd = nth(incd, 2), incd2 = last(incd2), wages_est = last(wages_est))

###  Give people an income if they reported it, and 0 if they reported they had no income. Other is missing
### This code chunk has extra codes in it unless the missing codes were added. Doesn't mess up results to just leave it.
mominc <- mominc %>%
  group_by(PUBID_1997, year) %>%
  mutate(wages = case_when(incd   == "1"    ~ wages,
                           incd   == "0"    ~ 0L,
                           incd   == "-5"   ~ -5L,
                           incd   == "-4"   ~ -4L,
                           incd   == "-3"   ~ -3L,
                           incd   == "-2"   ~ -2L,
                           incd   == "-1"   ~ -1L,
                           incd2  == "0"    ~ 0L,
                           TRUE             ~ NA_integer_
                      ))

### Let's give people the estimated income if they reported it. Use the mean of the range selected, as done for the Gross Income variables.
### https://www.nlsinfo.org/content/cohorts/nlsy97/other-documentation/codebook-supplement/appendix-5-income-and-assets-variab-3
mominc <- mominc %>%
  group_by(PUBID_1997, year) %>%
  mutate(wages = case_when(!is.na(wages) & (wages< -5L | wages >=0L)  ~ wages,
                           wages_est == 1L ~ 2500L,
                           wages_est == 2L ~ 7500L,
                           wages_est == 3L ~ 17500L,
                           wages_est == 4L ~ 37500L,
                           wages_est == 5L ~ 75000L,
                           wages_est == 6L ~ 175000L,
                           wages_est == 7L ~ 250001L,
                           (wages >= -5L & wages <= -1) & wages_est<= -1L ~ wages,
                           TRUE            ~ NA_integer_))

### Order the dataset to match new_data and then add birth_year variable
mominc <- arrange(mominc, year, PUBID_1997)
mominc$birth_year   <- new_data$birth_year

## Spouse/Partner Income by year

### YINC-2400 - SP/P RECEIVE INCOME FROM JOB IN PAST YEAR? (incd)
### YINC-2600 - TOTAL INCOME FROM WAGES AND SALARY IN PAST YEAR (wages)
### YINC-2700 - ESTIMATED INCOME FROM WAGES AND SALARY IN PAST YEAR (wages_est)

spinc <- new_data %>%
  select(PUBID_1997, starts_with("YINC-2400"), starts_with("YINC-2600"), starts_with("YINC-2700")) %>%
  gather(var, val, -PUBID_1997) %>%
  separate(var, c("type", "year"), "_")

spinc <- spinc %>%
  mutate(spwages     = case_when(type == "YINC-2600" ~ val),
         spwages_est = case_when(type == "YINC-2700" ~ val),
         spincd      = case_when(type == "YINC-2400" ~ val)) %>%
  group_by(PUBID_1997, year) %>% 
  summarise(spincd = first(spincd), spwages = nth(spwages, 2), spwages_est = last(spwages_est))


### Give people an income if they reported it, and 0 if they reported they had no income. Other is missing
### This code chunk has extra codes in it unless the missing codes were added. Doesn't mess up results to just leave it.
spinc <- spinc %>%
  group_by(PUBID_1997, year) %>%
  mutate(wages = case_when(incd   == "1"    ~ wages,
                           incd   == "0"    ~ 0L,
                           incd   == "-5"   ~ -5L,
                           incd   == "-4"   ~ -4L,
                           incd   == "-3"   ~ -3L,
                           incd   == "-2"   ~ -2L,
                           incd   == "-1"   ~ -1L,
                           TRUE             ~ NA_integer_
  ))

### Let's give people the estimated income if they reported it. Use the mean of the range selected, as done for the Gross Income variables.
### https://www.nlsinfo.org/content/cohorts/nlsy97/other-documentation/codebook-supplement/appendix-5-income-and-assets-variab-3
spinc <- spinc %>%
  group_by(PUBID_1997, year) %>%
  mutate(wages = case_when(!is.na(wages) & (wages< -5L | wages >=0L)  ~ wages,
                           wages_est == 1L ~ 2500L,
                           wages_est == 2L ~ 7500L,
                           wages_est == 3L ~ 17500L,
                           wages_est == 4L ~ 37500L,
                           wages_est == 5L ~ 75000L,
                           wages_est == 6L ~ 175000L,
                           wages_est == 7L ~ 250001L,
                           (wages >= -5L & wages <= -1) & wages_est<= -1L ~ wages,
                           TRUE            ~ NA_integer_))

## Mom's business earnings
### YINC-2000 - ANY INCOME FROM OWN BUSINESS OR FARM IN PAST YEAR (mombizd)
### YINC-2100 - TOTAL INCOME FROM BUSINESS OR FARM IN PAST YEAR (mombiz)
### YINC-2200 - ESTIMATED INCOME FROM BUSINESS OR FARM IN PAST YEAR (mombiz_est)

mombiz <- new_data %>%
  select(PUBID_1997, starts_with("YINC-2000"), starts_with("YINC-2100"), starts_with("YINC-2200")) %>%
  gather(var, val, -PUBID_1997) %>%
  separate(var, c("type", "year"), "_")

mombiz <- mombiz %>%
  mutate(mombiz     = case_when(type == "YINC-2100" ~ val),
         mombiz_est = case_when(type == "YINC-2200" ~ val),
         mombizd    = case_when(type == "YINC-2000" ~ val)) %>%
  group_by(PUBID_1997, year) %>%
  summarise(mombizd = first(mombizd), mombiz = nth(mombiz, 2), mombiz_est = last(mombiz_est))

mombiz <- mombiz %>%
  group_by(PUBID_1997, year) %>%
  mutate(mombiz = case_when(mombizd    == "1"  ~ mombiz,
                            mombizd    == "0"  ~ 0L,
                            mombiz_est == "1"  ~ -2L,
                            mombiz_est == "2"  ~ 2500L,
                            mombiz_est == "3"  ~ 7500L,
                            mombiz_est == "4"  ~ 17500L,
                            mombiz_est == "5"  ~ 37500L,
                            mombiz_est == "6"  ~ 75000L,
                            mombiz_est == "7"  ~ 175000L,
                            mombiz_est == "8"  ~ 250001L,
                            (mombiz >= -5L & mombiz <= -1) & mombiz_est<= -1L ~ mombiz,
                            TRUE               ~ NA_integer_))

## Spouse/Partner's business earnings
### YINC-2900 - SP/P RECEIVE ANY INCOME FROM OWN BUSINESS OR FARM IN PAST YEAR (spbizd)
### YINC-3000 - SP/P TOTAL INCOME FROM BUSINESS OR FARM IN PAST YEAR (spbiz)
### YINC-3100 - SP/P ESTIMATED INCOME FROM BUSINESS OR FARM IN PAST YEAR (spbiz_est)

spbiz <- new_data %>%
  select(PUBID_1997, starts_with("YINC-2900"), starts_with("YINC-3000"), starts_with("YINC-3100")) %>%
  gather(var, val, -PUBID_1997) %>%
  separate(var, c("type", "year"), "_")

spbiz <- spbiz %>%
  mutate(spbiz     = case_when(type == "YINC-3000" ~ val),
         spbiz_est = case_when(type == "YINC-3100" ~ val),
         spbizd    = case_when(type == "YINC-2900" ~ val)) %>%
  group_by(PUBID_1997, year) %>%
  summarise(spbizd = first(spbizd), spbiz = nth(spbiz, 2), spbiz_est = last(spbiz_est))

spbiz <- spbiz %>%
  group_by(PUBID_1997, year) %>%
  mutate(spbiz = case_when( spbizd    == "1"  ~ spbiz,
                            spbizd    == "0"  ~ 0L,
                            spbiz_est == "1"  ~ -2L,
                            spbiz_est == "2"  ~ 2500L,
                            spbiz_est == "3"  ~ 7500L,
                            spbiz_est == "4"  ~ 17500L,
                            spbiz_est == "5"  ~ 37500L,
                            spbiz_est == "6"  ~ 75000L,
                            spbiz_est == "7"  ~ 175000L,
                            spbiz_est == "8"  ~ 250001L,
                            (spbiz >= -5L & spbiz <= -1) & spbiz_est<= -1L ~ spbiz,
                            TRUE               ~ NA_integer_))

## Other family members' income who are living with R
### YINC-11600 - TOTAL COMBINED INCOME OTHER ADULT HOUSEHOLD FAMILY MEMBERS IN PAST YEAR (hhinc)
### YINC-11700 - ESTIMATED TOTAL INCOME WAGES/BUS/FARM PAST YEAR (OTHER HH MEMBERS) (hhinc_est)

hhinc <- new_data %>%
  select(PUBID_1997, starts_with("YINC-11600"), starts_with("YINC-11700")) %>%
  gather(var, val, -PUBID_1997) %>%
  separate(var, c("type", "year"), "_")

hhinc <- hhinc %>%
  mutate(hhinc     = case_when(type == "YINC-11600A" | type == "YINC-11600B" ~ val),
         hhinc_est = case_when(type == "YINC-11700"  ~ val)) %>%
  group_by(PUBID_1997, year) %>%
  summarise(hhinc = first(hhinc), hhinc_est = last(hhinc_est))

hhinc <- hhinc %>%
  group_by(PUBID_1997, year) %>%
  mutate(hhinc = case_when( hhinc     >= "0"  ~ hhinc,
                            hhinc_est == "1"  ~ 2500L,
                            hhinc_est == "2"  ~ 7500L,
                            hhinc_est == "3"  ~ 17500L,
                            hhinc_est == "4"  ~ 37500L,
                            hhinc_est == "5"  ~ 75000L,
                            hhinc_est == "6"  ~ 175000L,
                            hhinc_est == "7"  ~ 250001L,
                            (hhinc >= -5L & hhinc <= -1) & hhinc_est<= -1L ~ hhinc,
                            TRUE               ~ NA_integer_))

## Worker's Compensation 
### YINC-2250 - DID R HAVE ANY INCOME FROM WORKER'S COMPENSATION IN PAST YEAR? (wcompd)
### YINC-2260 - TOTAL INCOME FROM WORKER'S COMPENSATION IN PAST YEAR (wcomp)
### YINC-2270 - ESTIMATED INCOME FROM WORKER'S COMPENSATION IN PAST YEAR (wcomp_est)

wcomp <- new_data %>%
  select(PUBID_1997, starts_with("YINC-2250"), starts_with("YINC-2260"), starts_with("YINC-2270")) %>%
  gather(var, val, -PUBID_1997) %>%
  separate(var, c("type", "year"), "_")

wcomp <- wcomp %>%
  mutate(wcompd     = case_when(type == "YINC-2250" ~ val),
         wcomp      = case_when(type == "YINC-2260" ~ val),
         wcomp_est  = case_when(type == "YINC-2270" ~ val)) %>%
  group_by(PUBID_1997, year) %>%
  summarise(wcompd = first(wcompd), wcomp = nth(wcomp, 2), wcomp_est = last(wcomp_est))

wcomp <- wcomp %>%
  group_by(PUBID_1997, year) %>%
  mutate(wcomp = case_when (wcompd    == "1"  ~ wcomp,
                            wcompd    == "0"  ~ 0L,
                            wcomp_est == "1"  ~ 500L,
                            wcomp_est == "2"  ~ 1750L,
                            wcomp_est == "3"  ~ 3750L,
                            wcomp_est == "4"  ~ 7500L,
                            wcomp_est == "5"  ~ 17500L,
                            wcomp_est == "6"  ~ 37500L,
                            wcomp_est == "7"  ~ 50001L,
                            (wcomp >= -5L & wcomp <= -1L) & (wcomp_est<= 0L | is.na(wcomp_est))~ wcomp,
                            TRUE               ~ NA_integer_))

## Spouse/Partner's Worker's Compensation 
### YINC-3150 - DID SP/P HAVE ANY INCOME FROM WORKER'S COMPENSATION IN PAST YEAR? (wcomp_spd)
### YINC-3160 - TOTAL SP/P INCOME FROM WORKER'S COMPENSATION IN PAST YEAR (wcomp_sp)
### YINC-3170 - ESTIMATED SP/P INCOME FROM WORKER'S COMPENSATION IN PAST YEAR (wcomp_sp_est)

wcomp_sp <- new_data %>%
  select(PUBID_1997, starts_with("YINC-3150"), starts_with("YINC-3160"), starts_with("YINC-3170")) %>%
  gather(var, val, -PUBID_1997) %>%
  separate(var, c("type", "year"), "_")

wcomp_sp <- wcomp_sp %>%
  mutate(wcomp_spd     = case_when(type == "YINC-3150" ~ val),
         wcomp_sp      = case_when(type == "YINC-3160" ~ val),
         wcomp_sp_est  = case_when(type == "YINC-3170" ~ val)) %>%
  group_by(PUBID_1997, year) %>%
  summarise(wcomp_spd = first(wcomp_spd), wcomp_sp = nth(wcomp_sp, 2), wcomp_sp_est = last(wcomp_sp_est))

wcomp_sp <- wcomp_sp %>%
  group_by(PUBID_1997, year) %>%
  mutate(wcomp_sp = case_when (wcomp_spd    == "1"  ~ wcomp_sp,
                               wcomp_spd    == "0"  ~ 0L,
                               wcomp_sp_est == "1"  ~ 500L,
                               wcomp_sp_est == "2"  ~ 1750L, #This is wrong in the appendix. Says 1250
                               wcomp_sp_est == "3"  ~ 3750L,
                               wcomp_sp_est == "4"  ~ 7500L,
                               wcomp_sp_est == "5"  ~ 17500L,
                               wcomp_sp_est == "6"  ~ 37500L,
                               wcomp_sp_est == "7"  ~ 50001L,
                               (wcomp_sp >= -5L & wcomp_sp <= -1L) & (wcomp_sp_est<= 0L | is.na(wcomp_sp_est))~ wcomp_sp,
                               TRUE               ~ NA_integer_))

## Child Support
### YINC-4000 - R/SPOUSE SUPPOSED TO RECEIVE CHILD SUPPORT? (chsupd)
### YINC-4100 - TOTAL AMOUNT OF CHILD SUPPORT ACTUALLY RECEIVED (chsup)
### YINC-4200 - ESTIMATED AMOUNT OF CHILD SUPPORT ACTUALLY RECEIVED (chsup_est)

chsup <- new_data %>%
  select(PUBID_1997, starts_with("YINC-4000"), starts_with("YINC-4100"), starts_with("YINC-4200")) %>%
  gather(var, val, -PUBID_1997) %>%
  separate(var, c("type", "year"), "_")

chsup <- chsup %>%
  mutate(chsupd     = case_when(type == "YINC-4000" ~ val),
         chsup      = case_when(type == "YINC-4100" ~ val),
         chsup_est  = case_when(type == "YINC-4200" ~ val)) %>%
  group_by(PUBID_1997, year) %>%
  summarise(chsupd = first(chsupd), chsup = nth(chsup, 2), chsup_est = last(chsup_est))

chsup <- chsup %>%
  group_by(PUBID_1997, year) %>%
  mutate(chsup = case_when (chsupd    == "1"  ~ chsup,
                            chsupd    == "0"  ~ 0L,
                            chsup_est == "1"  ~ 500L,
                            chsup_est == "2"  ~ 1750L,
                            chsup_est == "3"  ~ 3750L,
                            chsup_est == "4"  ~ 7500L,
                            chsup_est == "5"  ~ 17500L,
                            chsup_est == "6"  ~ 37500L,
                            chsup_est == "7"  ~ 50001L,
                            (chsup >= -5L & chsup <= -1L) & (chsup_est<= 0L | is.na(chsup_est))~ chsup,
                            TRUE               ~ NA_integer_))

## Interest payments
### YINC-4300 - ANY INCOME INTEREST FROM BANK SOURCES AND ACCOUNTS? (intrstd)
### YINC-4400 - TOTAL INCOME INTEREST FROM BANK ACCOUNTS (intrst)
### YINC-4500 - EST INCOME INTEREST FROM BANK ACCOUNTS (intrst_est)

intrst <- new_data %>%
  select(PUBID_1997, starts_with("YINC-4300"), starts_with("YINC-4400"), starts_with("YINC-4500")) %>%
  gather(var, val, -PUBID_1997) %>%
  separate(var, c("type", "year"), "_")

intrst <- intrst %>%
  mutate(intrstd     = case_when(type == "YINC-4300" ~ val),
         intrst      = case_when(type == "YINC-4400" ~ val),
         intrst_est  = case_when(type == "YINC-4500" ~ val)) %>%
  group_by(PUBID_1997, year) %>%
  summarise(intrstd = first(intrstd), intrst = nth(intrst, 2), intrst_est = last(intrst_est))

intrst <- intrst %>%
  group_by(PUBID_1997, year) %>%
  mutate(intrst = case_when (intrstd   == "1"  ~ intrst,
                             intrstd    == "0"  ~ 0L,
                             intrst_est == "1"  ~ 250L,
                             intrst_est == "2"  ~ 750L,
                             intrst_est == "3"  ~ 1750L,
                             intrst_est == "4"  ~ 3750L,
                             intrst_est == "5"  ~ 6250L,
                             intrst_est == "6"  ~ 8750L,
                             intrst_est == "7"  ~ 10001L,
                             (intrst >= -5L & intrst <= -1L) & (intrst_est<= 0L | is.na(intrst_est))~ intrst,
                             TRUE               ~ NA_integer_))

## Stocks & mutual funds
### YINC-4600 - ANY INCOME FROM DIVIDENDS FROM STOCKS OR MUTUAL FUNDS? (dvdendd)
### YINC-4700 - TOTAL INCOME FROM DIVIDENDS FROM STOCKS OR MUTUAL FUNDS (dvdend)
### YINC-4800 - ESTIMATED INCOME FROM DIVIDENDS FROM STOCKS OR MUTUAL FUNDS (dvdend_est)

dvdend <- new_data %>%
  select(PUBID_1997, starts_with("YINC-4600"), starts_with("YINC-4700"), starts_with("YINC-4800")) %>%
  gather(var, val, -PUBID_1997) %>%
  separate(var, c("type", "year"), "_")

dvdend <- dvdend %>%
  mutate(dvdendd     = case_when(type == "YINC-4600" ~ val),
         dvdend      = case_when(type == "YINC-4700" ~ val),
         dvdend_est  = case_when(type == "YINC-4800" ~ val)) %>%
  group_by(PUBID_1997, year) %>%
  summarise(dvdendd = first(dvdendd), dvdend = nth(dvdend, 2), dvdend_est = last(dvdend_est))

dvdend <- dvdend %>%
  group_by(PUBID_1997, year) %>%
  mutate(dvdend = case_when(dvdendd    == "1"  ~ dvdend,
                            dvdendd    == "0"  ~ 0L,
                            dvdend_est == "1"  ~ 250L,
                            dvdend_est == "2"  ~ 750L,
                            dvdend_est == "3"  ~ 1750L,
                            dvdend_est == "4"  ~ 3750L,
                            dvdend_est == "5"  ~ 6250L,
                            dvdend_est == "6"  ~ 8750L,
                            dvdend_est == "7"  ~ 10001L,
                            (dvdend >= -5L & dvdend <= -1L) & (dvdend_est<= 0L | is.na(dvdend_est))~ dvdend,
                            TRUE               ~ NA_integer_))

## Rental Income
### YINC-4900 - ANY INCOME FROM RENTAL PROPERTY? (rntincd)
### YINC-5000 - TOTAL INCOME FROM RENTAL PROPERTY (rntinc)
### YINC-5100 - ESTIMATED INCOME FROM RENTAL PROPERTY (rntinc_est)

rntinc <- new_data %>%
  select(PUBID_1997, starts_with("YINC-4900"), starts_with("YINC-5000"), starts_with("YINC-5100")) %>%
  gather(var, val, -PUBID_1997) %>%
  separate(var, c("type", "year"), "_")

rntinc <- rntinc %>%
  mutate(rntincd     = case_when(type == "YINC-4900" ~ val),
         rntinc      = case_when(type == "YINC-5000" ~ val),
         rntinc_est  = case_when(type == "YINC-5100" ~ val)) %>%
  group_by(PUBID_1997, year) %>%
  summarise(rntincd = first(rntincd), rntinc = nth(rntinc, 2), rntinc_est = last(rntinc_est))

rntinc <- rntinc %>%
  group_by(PUBID_1997, year) %>%
  mutate(rntinc = case_when(rntincd    == "1"  ~ rntinc,
                            rntincd    == "0"  ~ 0L,
                            rntinc_est == "1"  ~ 500L,
                            rntinc_est == "2"  ~ 1750L,
                            rntinc_est == "3"  ~ 3750L,
                            rntinc_est == "4"  ~ 7500L,
                            rntinc_est == "5"  ~ 17500L,
                            rntinc_est == "6"  ~ 37500L,
                            rntinc_est == "7"  ~ 50001L,
                            (rntinc >= -5L & rntinc <= -1L) & (rntinc_est<= 0L | is.na(rntinc_est))~ rntinc,
                            TRUE               ~ NA_integer_))

## Estates, trusts
### YINC-5200 - ANY INCOME OR PROPERTY FROM ESTATES, TRUSTS, INHERITANCE? (inhincd)
### YINC-5300 - TOTAL MARKET VALUE OF ESTATES, TRUSTS, INHERITANCE (inhinc)
### YINC-5400 - EST MARKET VALUE OF ESTATES, TRUSTS, INHERITANCE (inhinc_est)

inhinc <- new_data %>%
  select(PUBID_1997, starts_with("YINC-5200"), starts_with("YINC-5300"), starts_with("YINC-5400")) %>%
  gather(var, val, -PUBID_1997) %>%
  separate(var, c("type", "year"), "_")

inhinc <- inhinc %>%
  mutate(inhincd     = case_when(type == "YINC-5200" ~ val),
         inhinc      = case_when(type == "YINC-5300" ~ val),
         inhinc_est  = case_when(type == "YINC-5400" ~ val)) %>%
  group_by(PUBID_1997, year) %>%
  summarise(inhincd = first(inhincd), inhinc = nth(inhinc, 2), inhinc_est = last(inhinc_est))

inhinc <- inhinc %>%
  group_by(PUBID_1997, year) %>%
  mutate(inhinc = case_when (inhincd    == "1"  ~ inhinc,
                             inhincd    == "0"  ~ 0L,
                             inhinc_est == "1"  ~ 2500L,
                             inhinc_est == "2"  ~ 7500L,
                             inhinc_est == "3"  ~ 17500L,
                             inhinc_est == "4"  ~ 37500L,
                             inhinc_est == "5"  ~ 75000L,
                             inhinc_est == "6"  ~ 175000L,
                             inhinc_est == "7"  ~ 250001L,
                             (inhinc >= -5L & inhinc <= -1L) & (inhinc_est<= 0L | is.na(inhinc_est))~ inhinc,
                             TRUE               ~ NA_integer_))

## Gift income
### YINC-5700 - PARENTS GIVE R ANY MONEY, NOT ALLOWANCE? (gtfincd)
### YINC-5800 - TOTAL AMOUNT OF INCOME PARENTS GAVE R (gftinc)
### YINC-5900 - ESTIMATED AMOUNT OF INCOME PARENTS GAVE R (gftinc_est)

gftinc <- new_data %>%
  select(PUBID_1997, starts_with("YINC-5700"), starts_with("YINC-5800"), starts_with("YINC-5900")) %>%
  gather(var, val, -PUBID_1997) %>%
  separate(var, c("type", "year"), "_")

gftinc <- gftinc %>%
  mutate(gftincd     = case_when(type == "YINC-5700" ~ val),
         gftinc      = case_when(type == "YINC-5800" ~ val),
         gftinc_est  = case_when(type == "YINC-5900" ~ val)) %>%
  group_by(PUBID_1997, year) %>%
  summarise(gftincd = first(gftincd), gftinc = nth(gftinc, 2), gftinc_est = last(gftinc_est))

gftinc <- gftinc %>%
  group_by(PUBID_1997, year) %>%
  mutate(gftinc = case_when(gftincd    == "1"  ~ gftinc,
                            gftincd    == "0"  ~ 0L,
                            gftinc_est == "1"  ~ 250L,
                            gftinc_est == "2"  ~ 750L,
                            gftinc_est == "3"  ~ 1750L,
                            gftinc_est == "4"  ~ 3750L,
                            gftinc_est == "5"  ~ 6250L,
                            gftinc_est == "6"  ~ 8750L,
                            gftinc_est == "7"  ~ 10001L,
                            (gftinc >= -5L & gftinc <= -1L) & (gftinc_est<= 0L | is.na(gftinc_est))~ gftincd, #replace with dum var for this var
                            TRUE               ~ NA_integer_))

## Other income
### YINC-7600 - INCOME FROM OTHER SOURCES SUCH AS SOCIAL SECURITY, PENSION, INSURANCE? (othincd)
### YINC-7700 - TOTAL INCOME FROM OTHER SOURCES PAST YEAR (othinc)
### YINC-7800 - ESTIMATED INCOME FROM OTHER SOURCES PAST YEAR (othinc_est)

othinc <- new_data %>%
  select(PUBID_1997, starts_with("YINC-7600"), starts_with("YINC-7700"), starts_with("YINC-7800")) %>%
  gather(var, val, -PUBID_1997) %>%
  separate(var, c("type", "year"), "_")

othinc <- othinc %>%
  mutate(othincd     = case_when(type == "YINC-7600" ~ val),
         othinc      = case_when(type == "YINC-7700" ~ val),
         othinc_est  = case_when(type == "YINC-7800" ~ val)) %>%
  group_by(PUBID_1997, year) %>%
  summarise(othincd = first(othincd), othinc = nth(othinc, 2), othinc_est = last(othinc_est))

othinc <- othinc %>%
  group_by(PUBID_1997, year) %>%
  mutate(othinc = case_when(othincd    == "1"  ~ othinc,
                            othincd    == "0"  ~ 0L,
                            othinc_est == "1"  ~ 500L,
                            othinc_est == "2"  ~ 1750L,
                            othinc_est == "3"  ~ 3750L,
                            othinc_est == "4"  ~ 7500L,
                            othinc_est == "5"  ~ 17500L,
                            othinc_est == "6"  ~ 37500L,
                            othinc_est == "7"  ~ 50001L,
                            (othinc >= -5L & othinc <= -1L) & (othinc_est<= 0L | is.na(othinc_est))~ othinc,
                            TRUE               ~ NA_integer_))

## Cash Assistance
### YINC-6000A - ANY CASH ASSISTANCE FROM GOVERNMENT PROGRAMS SUCH AS SSI TANF, ETC.?
### YINC-6100A - 	AMOUNT OF CASH ASSISTANCE FROM GOVERNMENT PROGRAMS

govpro1 <- new_data %>%
  select(PUBID_1997, starts_with("YINC-6000A"), starts_with("YINC-6100A")) %>%
  gather(var, val, -PUBID_1997) %>%
  separate(var, c("type", "year"), "_")

govpro1 <- govpro1 %>%
  mutate(govpro1d     = case_when(type == "YINC-6000A" ~ val),
         govpro1      = case_when(type == "YINC-6100A" ~ val)) %>%
  group_by(PUBID_1997, year) %>%
  summarise(govpro1d = first(govpro1d), govpro1 = nth(govpro1, 2))

govpro1 <- govpro1 %>%
  group_by(PUBID_1997, year) %>%
  mutate(govpro1 = case_when(govpro1d   == "0"  ~ 0L,
                             govpro1     == "1"  ~ 250L,
                             govpro1     == "2"  ~ 750L,
                             govpro1     == "3"  ~ 1750L,
                             govpro1     == "4"  ~ 3750L,
                             govpro1     == "5"  ~ 6250L,
                             govpro1     == "6"  ~ 8750L,
                             govpro1     == "7"  ~ 10001L,
                             (govpro1 >= -5L & govpro1 <= -1L) ~ govpro1,
                             (govpro1d >= -5L & govpro1d <= -1L) ~ govpro1d,
                             TRUE                ~ NA_integer_))

## Cash Assistance from WIC, SNA, or Food Stamps
### YINC-6200A - CASH ASSISTANCE FROM WIC, SNAP, OR FOOD STAMPS?
### YINC-6300A - AMOUNT OF CASH ASSISTANCE FROM WIC, SNAP, OR FOOD STAMPS

govpro2 <- new_data %>%
  select(PUBID_1997, starts_with("YINC-6200A"), starts_with("YINC-6300A")) %>%
  gather(var, val, -PUBID_1997) %>%
  separate(var, c("type", "year"), "_")

govpro2 <- govpro2 %>%
  mutate(govpro2d     = case_when(type == "YINC-6200A" ~ val),
         govpro2      = case_when(type == "YINC-6300A" ~ val)) %>%
  group_by(PUBID_1997, year) %>%
  summarise(govpro2d = first(govpro2d), govpro2 = nth(govpro2, 2))

govpro2 <- govpro2 %>%
  group_by(PUBID_1997, year) %>%
  mutate(govpro2 = case_when(govpro2d   == "0"  ~ 0L,
                             govpro2     == "1"  ~ 250L,
                             govpro2     == "2"  ~ 750L,
                             govpro2     == "3"  ~ 1750L,
                             govpro2     == "4"  ~ 3750L,
                             govpro2     == "5"  ~ 6250L,
                             govpro2     == "6"  ~ 8750L,
                             govpro2     == "7"  ~ 10001L,
                             (govpro2 >= -5L & govpro2 <= -1L) ~ govpro2,
                             (govpro2d >= -5L & govpro2d <= -1L) ~ govpro2d,
                             TRUE                ~ NA_integer_))

## Any other benefits from government programs
### YINC-6400A - ANY OTHER BENEFITS FROM GOVERNMENT PROGRAMS?
### YINC-6500A - CASH VALUE OF OTHER BENEFITS FROM GOVERNMENT PROGRAMS

govpro3 <- new_data %>%
  select(PUBID_1997, starts_with("YINC-6400A"), starts_with("YINC-6500A")) %>%
  gather(var, val, -PUBID_1997) %>%
  separate(var, c("type", "year"), "_")

govpro3 <- govpro3 %>%
  mutate(govpro3d     = case_when(type == "YINC-6400A" ~ val),
         govpro3      = case_when(type == "YINC-6500A" ~ val)) %>%
  group_by(PUBID_1997, year) %>%
  summarise(govpro3d = first(govpro3d), govpro3 = nth(govpro3, 2))

govpro3 <- govpro3 %>%
  group_by(PUBID_1997, year) %>%
  mutate(govpro3 = case_when(govpro3d    == "0"  ~ 0L,
                             govpro3     == "1"  ~ 250L,
                             govpro3     == "2"  ~ 750L,
                             govpro3     == "3"  ~ 1750L,
                             govpro3     == "4"  ~ 3750L,
                             govpro3     == "5"  ~ 6250L,
                             govpro3     == "6"  ~ 8750L,
                             govpro3     == "7"  ~ 10001L,
                             (govpro3 >= -5L & govpro3 <= -1L)  ~ govpro3,
                             (govpro3d >= -5L & govpro3d <= -1L) ~ govpro3d,
                             TRUE                ~ NA_integer_))

## Create mom's total income variable
##  wages, mombiz, chsup, dvdend, gftinc, govpro1, govpro2, govpro3, inhinc, intrst, othinc, rntinc, wcomp
### mombiz <- arrange(mombiz, year, PUBID_1997)
### mominc$mombiz   <- mombiz$mombiz


inc_data   <- mominc
inc_data   <- left_join(inc_data,   mombiz)
inc_data   <- left_join(inc_data,   chsup)
inc_data   <- left_join(inc_data,   dvdend)
inc_data   <- left_join(inc_data,   gftinc)
inc_data   <- left_join(inc_data,   govpro1)
inc_data   <- left_join(inc_data,   govpro2)
inc_data   <- left_join(inc_data,   govpro3)
inc_data   <- left_join(inc_data,   inhinc)
inc_data   <- left_join(inc_data,   intrst)
inc_data   <- left_join(inc_data,   othinc)
inc_data   <- left_join(inc_data,   rntinc)
inc_data   <- left_join(inc_data,   wcomp)

inc_data <- inc_data %>%
  select(PUBID_1997, year, birth_year, wages, mombiz, chsup, dvdend, gftinc, govpro1, govpro2, govpro3, inhinc, intrst, othinc, rntinc, wcomp)

#I'm going to need to handle the missing data for all of these variables before combining them.......
inc_data[inc_data == -4] = 0  # Valid missing

inc_data <- inc_data %>%
  filter(wages != -5)         # Non-interview

inc_data[is.na(inc_data)] = 0 # Make missing 0 so don't drop them just because variable didn't exist that year

inc_data[inc_data == -3] <- NA # Invalid missing 
inc_data[inc_data == -2] <- NA # Dont know 
inc_data[inc_data == -1] <- NA # Refused 

inc_data <- inc_data %>%
  group_by(PUBID_1997, year) %>%  
  mutate(momtot = wages + mombiz + chsup + dvdend + gftinc + govpro1 + govpro2 + govpro3 + inhinc + intrst + othinc + rntinc + wcomp)

# Create the birth year plus 1 variables
inc_data$birth_year1   <- inc_data$birth_year + 1
inc_data$birth_year2   <- inc_data$birth_year + 2
inc_data$birth_year3   <- inc_data$birth_year + 3
inc_data$birth_year4   <- inc_data$birth_year + 4
inc_data$birth_year5   <- inc_data$birth_year + 5
inc_data$birth_year6   <- inc_data$birth_year + 6
inc_data$birth_year7   <- inc_data$birth_year + 7
inc_data$birth_year8   <- inc_data$birth_year + 8
inc_data$birth_year9   <- inc_data$birth_year + 9
inc_data$birth_year10  <- inc_data$birth_year + 10
inc_data$birth_year11  <- inc_data$birth_year + 11

inc_data$birth_minus1 <- inc_data$birth_year - 1
inc_data$birth_minus2 <- inc_data$birth_year - 2
inc_data$birth_minus3 <- inc_data$birth_year - 3
inc_data$birth_minus4 <- inc_data$birth_year - 4


# give people the income they reported for each of the income plus 1 variables
## Careful - t0 is birth year plus 1 for income because respondents report income from the previous year
inc_data <- inc_data %>%
  group_by(PUBID_1997) %>% 
  mutate(inc_t0  = case_when(birth_year1   == year ~ momtot),
         inc_t1  = case_when(birth_year2   == year ~ momtot),
         inc_t2  = case_when(birth_year3   == year ~ momtot),
         inc_t3  = case_when(birth_year4   == year ~ momtot),
         inc_t4  = case_when(birth_year5   == year ~ momtot),
         inc_t5  = case_when(birth_year6   == year ~ momtot),
         inc_t6  = case_when(birth_year7   == year ~ momtot),
         inc_t7  = case_when(birth_year8   == year ~ momtot),
         inc_t8  = case_when(birth_year9   == year ~ momtot),
         inc_t9  = case_when(birth_year10  == year ~ momtot),
         inc_t10 = case_when(birth_year11  == year ~ momtot))

# give people the income they reported for each of the income minus 1 variables
inc_data <- inc_data %>%
  group_by(PUBID_1997) %>% 
  mutate(inc_m1 = case_when(birth_year   == year ~ momtot),
         inc_m2 = case_when(birth_minus1 == year ~ momtot),
         inc_m3 = case_when(birth_minus2 == year ~ momtot),
         inc_m4 = case_when(birth_minus3 == year ~ momtot),
         inc_m5 = case_when(birth_minus4 == year ~ momtot))

# aggregate the data so there is 1 row per person
inc_data <- inc_data %>%
group_by(PUBID_1997) %>% 
  summarise_at(c("inc_t0", "inc_t1", "inc_t2", "inc_t3", "inc_t4", "inc_t5", 
                 "inc_t6", "inc_t7", "inc_t8", "inc_t9", "inc_t10",
                 "inc_m1", "inc_m2", "inc_m3", "inc_m4", "inc_m5"), mean, na.rm = TRUE)

## replace the NaN with NA to address the missing
inc_data$inc_t0[is.nan(inc_data$inc_t0)] <- NA
inc_data$inc_t1[is.nan(inc_data$inc_t1)] <- NA
inc_data$inc_t2[is.nan(inc_data$inc_t2)] <- NA
inc_data$inc_t3[is.nan(inc_data$inc_t3)] <- NA
inc_data$inc_t4[is.nan(inc_data$inc_t4)] <- NA
inc_data$inc_t5[is.nan(inc_data$inc_t5)] <- NA
inc_data$inc_t6[is.nan(inc_data$inc_t6)] <- NA
inc_data$inc_t7[is.nan(inc_data$inc_t7)] <- NA
inc_data$inc_t8[is.nan(inc_data$inc_t8)] <- NA
inc_data$inc_t9[is.nan(inc_data$inc_t9)] <- NA
inc_data$inc_t10[is.nan(inc_data$inc_t10)] <- NA

inc_data$inc_m1[is.nan(inc_data$inc_m1)] <- NA
inc_data$inc_m2[is.nan(inc_data$inc_m2)] <- NA
inc_data$inc_m3[is.nan(inc_data$inc_m3)] <- NA
inc_data$inc_m4[is.nan(inc_data$inc_m4)] <- NA
inc_data$inc_m5[is.nan(inc_data$inc_m5)] <- NA

### Add new variables to original dataset
new_data  <- left_join(new_data,   inc_data, by = "PUBID_1997")
remove(chsup)
remove(dvdend)
remove(gftinc)
remove(govpro1)
remove(govpro2)
remove(govpro3)
remove(inhinc)
remove(intrst)
remove(mominc)
remove(othinc)
remove(rntinc)
remove(wcomp)


### R's Total Household Income by year
# https://www.nlsinfo.org/content/cohorts/nlsy97/topical-guide/income/income

totinc <- new_data %>%
  select(PUBID_1997, starts_with("CV_INCOME_GROSS_YR"), starts_with("CV_INCOME_FAMILY")) %>%
  gather(var, hhinc, -PUBID_1997) %>%
  separate(var, c("type", "year"), -4)

# Create the birth year plus 1 variables
totinc$birth_year  <- new_data$birth_year

totinc$birth_year1 <- totinc$birth_year + 1
totinc$birth_year2 <- totinc$birth_year + 2
totinc$birth_year3 <- totinc$birth_year + 3
totinc$birth_year4 <- totinc$birth_year + 4
totinc$birth_year5 <- totinc$birth_year + 5
totinc$birth_year6 <- totinc$birth_year + 6
totinc$birth_year7 <- totinc$birth_year + 7
totinc$birth_year8 <- totinc$birth_year + 8
totinc$birth_year9 <- totinc$birth_year + 9
totinc$birth_year10 <- totinc$birth_year + 10
totinc$birth_year11 <- totinc$birth_year + 11

totinc$birth_minus1 <- totinc$birth_year - 1
totinc$birth_minus2 <- totinc$birth_year - 2
totinc$birth_minus3 <- totinc$birth_year - 3
totinc$birth_minus4 <- totinc$birth_year - 4

# give people the total household income reported for each of the total income plus 1 variables
totinc <- totinc %>%
  group_by(PUBID_1997) %>% 
  mutate(hhinc_t0  = case_when(birth_year1  == year ~ hhinc),
         hhinc_t1  = case_when(birth_year2  == year ~ hhinc),
         hhinc_t2  = case_when(birth_year3  == year ~ hhinc),
         hhinc_t3  = case_when(birth_year4  == year ~ hhinc),
         hhinc_t4  = case_when(birth_year5  == year ~ hhinc),
         hhinc_t5  = case_when(birth_year6  == year ~ hhinc),
         hhinc_t6  = case_when(birth_year7  == year ~ hhinc),
         hhinc_t7  = case_when(birth_year8  == year ~ hhinc),
         hhinc_t8  = case_when(birth_year9  == year ~ hhinc),
         hhinc_t9  = case_when(birth_year10 == year ~ hhinc),
         hhinc_t10 = case_when(birth_year11 == year ~ hhinc))

totinc <- totinc %>%
  group_by(PUBID_1997) %>% 
  mutate(hhinc_m1 = case_when(birth_year   == year ~ hhinc),
         hhinc_m2 = case_when(birth_minus1 == year ~ hhinc),
         hhinc_m3 = case_when(birth_minus2 == year ~ hhinc),
         hhinc_m4 = case_when(birth_minus3 == year ~ hhinc),
         hhinc_m5 = case_when(birth_minus4 == year ~ hhinc))

# aggregate the data so there is 1 row per person
totinc <- totinc %>%
  group_by(PUBID_1997) %>% 
  summarise_at(c("hhinc_t0", "hhinc_t1", "hhinc_t2", "hhinc_t3", "hhinc_t4", "hhinc_t5",
                 "hhinc_t6", "hhinc_t7", "hhinc_t8", "hhinc_t9", "hhinc_t10",
                 "hhinc_m1", "hhinc_m2", "hhinc_m3", "hhinc_m4", "hhinc_m5"), mean, na.rm = TRUE)

# replace the NaN with NA to address the missing
totinc$hhinc_t0[is.nan(totinc$hhinc_t0)] <- NA
totinc$hhinc_t1[is.nan(totinc$hhinc_t1)] <- NA
totinc$hhinc_t2[is.nan(totinc$hhinc_t2)] <- NA
totinc$hhinc_t3[is.nan(totinc$hhinc_t3)] <- NA
totinc$hhinc_t4[is.nan(totinc$hhinc_t4)] <- NA
totinc$hhinc_t5[is.nan(totinc$hhinc_t5)] <- NA
totinc$hhinc_t6[is.nan(totinc$hhinc_t6)] <- NA
totinc$hhinc_t7[is.nan(totinc$hhinc_t7)] <- NA
totinc$hhinc_t8[is.nan(totinc$hhinc_t8)] <- NA
totinc$hhinc_t9[is.nan(totinc$hhinc_t9)] <- NA
totinc$hhinc_t10[is.nan(totinc$hhinc_t10)] <- NA

totinc$hhinc_m1[is.nan(totinc$hhinc_m1)] <- NA
totinc$hhinc_m2[is.nan(totinc$hhinc_m2)] <- NA
totinc$hhinc_m3[is.nan(totinc$hhinc_m3)] <- NA
totinc$hhinc_m4[is.nan(totinc$hhinc_m4)] <- NA
totinc$hhinc_m5[is.nan(totinc$hhinc_m5)] <- NA

### Add new variables to original dataset
new_data   <- left_join(new_data,   totinc)

remove(totinc)

# Data 
nlsy97 <- new_data %>%
  filter(!is.na(birth_year)) # limit to mothers

nlsy97 <- nlsy97 %>%
  filter(age_birth >= 18 & age_birth <=27) # limit to mothers 18 - 27 at first birth

which( colnames(nlsy97)=="dob" )
which( colnames(nlsy97)=="hhinc_m5" )

nlsy97 <- nlsy97 %>%
  select(1, 735:776) # This needs to be updated each time new variables are added/created.

# sample <- nlsy97 %>%
  # select(PUBID_1997, birth_year, age_birth, mar_t1:bw_m4)
# sample <- sample[1:20,]
# write.csv(sample, file = "NLSY97_sample.csv")

# Address missing data

## Type of NAs
table(nlsy97$inc_t0)
table(nlsy97$inc_t1)
table(nlsy97$inc_t2)
table(nlsy97$inc_t3)
table(nlsy97$inc_t4)
table(nlsy97$inc_t5)

sum(is.na(nlsy97$inc_t0))
sum(is.na(nlsy97$inc_t1))
sum(is.na(nlsy97$inc_t2))
sum(is.na(nlsy97$inc_t3))
sum(is.na(nlsy97$inc_t4))
sum(is.na(nlsy97$inc_t5))

table(nlsy97$hhinc_t0)
table(nlsy97$hhinc_t1)
table(nlsy97$hhinc_t2)
table(nlsy97$hhinc_t3)
table(nlsy97$hhinc_t4)
table(nlsy97$hhinc_t5)

sum(is.na(nlsy97$hhinc_t0))
sum(is.na(nlsy97$hhinc_t1))
sum(is.na(nlsy97$hhinc_t2))
sum(is.na(nlsy97$hhinc_t3))
sum(is.na(nlsy97$hhinc_t4))
sum(is.na(nlsy97$hhinc_t5))

## Replace type of NAs with NA
   nlsy97[nlsy97 == -1] = NA  # Refused 
   nlsy97[nlsy97 == -2] = NA  # Dont know 
   nlsy97[nlsy97 == -3] = NA  # Invalid missing 
   nlsy97[nlsy97 == -4] = NA  # Valid missing 
   nlsy97[nlsy97 == -5] = NA  # Non-interview 

## Check to see if there are 0s for personal income
nlsy97 %>%
  ggplot(aes(inc_t1)) +
  geom_histogram()

# BREADWINNER 50%
nlsy97 <- nlsy97 %>%
  mutate(
    bw5_t0 = case_when(
      (nlsy97$inc_t0/nlsy97$hhinc_t0) > .5 ~ "Breadwinner",
      (nlsy97$inc_t0/nlsy97$hhinc_t0) < .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw5_t1 = case_when(
      (nlsy97$inc_t1/nlsy97$hhinc_t1) > .5 ~ "Breadwinner",
      (nlsy97$inc_t1/nlsy97$hhinc_t1) < .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw5_t2 = case_when(
      (nlsy97$inc_t2/nlsy97$hhinc_t2) > .5 ~ "Breadwinner",
      (nlsy97$inc_t2/nlsy97$hhinc_t2) < .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw5_t3 = case_when(
      (nlsy97$inc_t3/nlsy97$hhinc_t3) > .5 ~ "Breadwinner",
      (nlsy97$inc_t3/nlsy97$hhinc_t3) < .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw5_t4 = case_when(
      (nlsy97$inc_t4/nlsy97$hhinc_t4) > .5 ~ "Breadwinner",
      (nlsy97$inc_t4/nlsy97$hhinc_t4) < .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw5_t5 = case_when(
      (nlsy97$inc_t5/nlsy97$hhinc_t5) > .5 ~ "Breadwinner",
      (nlsy97$inc_t5/nlsy97$hhinc_t5) < .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw5_t6 = case_when(
      (nlsy97$inc_t6/nlsy97$hhinc_t6) > .5 ~ "Breadwinner",
      (nlsy97$inc_t6/nlsy97$hhinc_t6) < .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw5_t7 = case_when(
      (nlsy97$inc_t7/nlsy97$hhinc_t7) > .5 ~ "Breadwinner",
      (nlsy97$inc_t7/nlsy97$hhinc_t7) < .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw5_t8 = case_when(
      (nlsy97$inc_t8/nlsy97$hhinc_t8) > .5 ~ "Breadwinner",
      (nlsy97$inc_t8/nlsy97$hhinc_t8) < .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw5_t9 = case_when(
      (nlsy97$inc_t9/nlsy97$hhinc_t9) > .5 ~ "Breadwinner",
      (nlsy97$inc_t9/nlsy97$hhinc_t9) < .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw5_t10 = case_when(
      (nlsy97$inc_t10/nlsy97$hhinc_t10) > .5 ~ "Breadwinner",
      (nlsy97$inc_t10/nlsy97$hhinc_t10) < .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_)
  )
nlsy97$bw5_t0 <- factor(nlsy97$bw5_t0, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw5_t1 <- factor(nlsy97$bw5_t1, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw5_t2 <- factor(nlsy97$bw5_t2, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw5_t3 <- factor(nlsy97$bw5_t3, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw5_t4 <- factor(nlsy97$bw5_t4, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw5_t5 <- factor(nlsy97$bw5_t5, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw5_t6 <- factor(nlsy97$bw5_t6, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw5_t7 <- factor(nlsy97$bw5_t7, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw5_t8 <- factor(nlsy97$bw5_t8, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw5_t9 <- factor(nlsy97$bw5_t9, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw5_t10 <- factor(nlsy97$bw5_t10, levels = c("Breadwinner", "Not a breadwinner"))


nlsy97 <- nlsy97 %>%
  mutate(
    bw5_m1 = case_when(
      (nlsy97$inc_m1/nlsy97$hhinc_m1) > .5 ~ "Breadwinner",
      (nlsy97$inc_m1/nlsy97$hhinc_m1) < .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw5_m2 = case_when(
      (nlsy97$inc_m2/nlsy97$hhinc_m2) > .5 ~ "Breadwinner",
      (nlsy97$inc_m2/nlsy97$hhinc_m2) < .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw5_m3 = case_when(
      (nlsy97$inc_m3/nlsy97$hhinc_m3) > .5 ~ "Breadwinner",
      (nlsy97$inc_m3/nlsy97$hhinc_m3) < .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw5_m4 = case_when(
      (nlsy97$inc_m4/nlsy97$hhinc_m4) > .5 ~ "Breadwinner",
      (nlsy97$inc_m4/nlsy97$hhinc_m4) < .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw5_m5 = case_when(
      (nlsy97$hhinc_m5/nlsy97$inc_m5) > .5 ~ "Breadwinner",
      (nlsy97$hhinc_m5/nlsy97$inc_m5) < .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
  )

nlsy97$bw5_m1 <- factor(nlsy97$bw5_m1, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw5_m2 <- factor(nlsy97$bw5_m2, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw5_m3 <- factor(nlsy97$bw5_m3, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw5_m4 <- factor(nlsy97$bw5_m4, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw5_m5 <- factor(nlsy97$bw5_m5, levels = c("Breadwinner", "Not a breadwinner"))

# BREADWINNER 60%
nlsy97 <- nlsy97 %>%
  mutate(
    bw6_t0 = case_when(
      (nlsy97$inc_t0/nlsy97$hhinc_t0) > .6 ~ "Breadwinner",
      (nlsy97$inc_t0/nlsy97$hhinc_t0) < .6 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw6_t1 = case_when(
      (nlsy97$inc_t1/nlsy97$hhinc_t1) > .6 ~ "Breadwinner",
      (nlsy97$inc_t1/nlsy97$hhinc_t1) < .6 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw6_t2 = case_when(
      (nlsy97$inc_t2/nlsy97$hhinc_t2) > .6 ~ "Breadwinner",
      (nlsy97$inc_t2/nlsy97$hhinc_t2) < .6 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw6_t3 = case_when(
      (nlsy97$inc_t3/nlsy97$hhinc_t3) > .6 ~ "Breadwinner",
      (nlsy97$inc_t3/nlsy97$hhinc_t3) < .6 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw6_t4 = case_when(
      (nlsy97$inc_t4/nlsy97$hhinc_t4) > .6 ~ "Breadwinner",
      (nlsy97$inc_t4/nlsy97$hhinc_t4) < .6 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw6_t5 = case_when(
      (nlsy97$inc_t5/nlsy97$hhinc_t5) > .6 ~ "Breadwinner",
      (nlsy97$inc_t5/nlsy97$hhinc_t5) < .6 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw6_t6 = case_when(
      (nlsy97$inc_t6/nlsy97$hhinc_t6) > .6 ~ "Breadwinner",
      (nlsy97$inc_t6/nlsy97$hhinc_t6) < .6 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw6_t7 = case_when(
      (nlsy97$inc_t7/nlsy97$hhinc_t7) > .6 ~ "Breadwinner",
      (nlsy97$inc_t7/nlsy97$hhinc_t7) < .6 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw6_t8 = case_when(
      (nlsy97$inc_t8/nlsy97$hhinc_t8) > .6 ~ "Breadwinner",
      (nlsy97$inc_t8/nlsy97$hhinc_t8) < .6 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw6_t9 = case_when(
      (nlsy97$inc_t9/nlsy97$hhinc_t9) > .6 ~ "Breadwinner",
      (nlsy97$inc_t9/nlsy97$hhinc_t9) < .6 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw6_t10 = case_when(
      (nlsy97$inc_t10/nlsy97$hhinc_t10) > .6 ~ "Breadwinner",
      (nlsy97$inc_t10/nlsy97$hhinc_t10) < .6 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_)
  )
nlsy97$bw6_t0 <- factor(nlsy97$bw6_t0, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw6_t1 <- factor(nlsy97$bw6_t1, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw6_t2 <- factor(nlsy97$bw6_t2, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw6_t3 <- factor(nlsy97$bw6_t3, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw6_t4 <- factor(nlsy97$bw6_t4, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw6_t5 <- factor(nlsy97$bw6_t5, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw6_t6 <- factor(nlsy97$bw6_t6, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw6_t7 <- factor(nlsy97$bw6_t7, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw6_t8 <- factor(nlsy97$bw6_t8, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw6_t9 <- factor(nlsy97$bw6_t9, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw6_t10 <- factor(nlsy97$bw6_t10, levels = c("Breadwinner", "Not a breadwinner"))


nlsy97 <- nlsy97 %>%
  mutate(
    bw6_m1 = case_when(
      (nlsy97$inc_m1/nlsy97$hhinc_m1) > .6 ~ "Breadwinner",
      (nlsy97$inc_m1/nlsy97$hhinc_m1) < .6 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw6_m2 = case_when(
      (nlsy97$inc_m2/nlsy97$hhinc_m2) > .6 ~ "Breadwinner",
      (nlsy97$inc_m2/nlsy97$hhinc_m2) < .6 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw6_m3 = case_when(
      (nlsy97$inc_m3/nlsy97$hhinc_m3) > .6 ~ "Breadwinner",
      (nlsy97$inc_m3/nlsy97$hhinc_m3) < .6 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw6_m4 = case_when(
      (nlsy97$inc_m4/nlsy97$hhinc_m4) > .6 ~ "Breadwinner",
      (nlsy97$inc_m4/nlsy97$hhinc_m4) < .6 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw6_m5 = case_when(
      (nlsy97$hhinc_m5/nlsy97$inc_m5) > .6 ~ "Breadwinner",
      (nlsy97$hhinc_m5/nlsy97$inc_m5) < .6 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
  )

nlsy97$bw6_m1 <- factor(nlsy97$bw6_m1, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw6_m2 <- factor(nlsy97$bw6_m2, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw6_m3 <- factor(nlsy97$bw6_m3, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw6_m4 <- factor(nlsy97$bw6_m4, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw6_m5 <- factor(nlsy97$bw6_m5, levels = c("Breadwinner", "Not a breadwinner"))


## Ever breadwinning 50%
nlsy97 <- nlsy97 %>%
  mutate(everbw = case_when(
      bw5_t0  == "Breadwinner" |
      bw5_t1  == "Breadwinner" |  
      bw5_t2  == "Breadwinner" |
      bw5_t3  == "Breadwinner" |
      bw5_t4  == "Breadwinner" |
      bw5_t5  == "Breadwinner" |
      bw5_t6  == "Breadwinner" |
      bw5_t7  == "Breadwinner" |
      bw5_t8  == "Breadwinner" |
      bw5_t9  == "Breadwinner" |
      bw5_t10 == "Breadwinner" ~ 1))

nlsy97$everbw[is.na(nlsy97$everbw)] <- 0

table(nlsy97$everbw)

# Descriptives
table(nlsy97$birth_year, nlsy97$mar_t0, exclude = NULL)
table(nlsy97$birth_year, nlsy97$age_birth)

table(nlsy97$birth_year, nlsy97$bw_t0)
table(nlsy97$birth_year, nlsy97$bw_t1)
table(nlsy97$birth_year, nlsy97$bw_t2)
table(nlsy97$birth_year, nlsy97$bw_t3)
table(nlsy97$birth_year, nlsy97$bw_t4)
table(nlsy97$birth_year, nlsy97$bw_t5)
table(nlsy97$birth_year, nlsy97$bw_t6)
table(nlsy97$birth_year, nlsy97$bw_m1)

table(nlsy97$bw5_t0)
table(nlsy97$bw5_t1)
table(nlsy97$bw5_t2)
table(nlsy97$bw5_t3)
table(nlsy97$bw5_t4)
table(nlsy97$bw5_t5)
table(nlsy97$bw5_t6)
table(nlsy97$bw5_t7)
table(nlsy97$bw5_t8)
table(nlsy97$bw5_t9)
table(nlsy97$bw5_t10)

table(nlsy97$bw6_t0)
table(nlsy97$bw6_t1)
table(nlsy97$bw6_t2)
table(nlsy97$bw6_t3)
table(nlsy97$bw6_t4)
table(nlsy97$bw6_t5)
table(nlsy97$bw6_t6)
table(nlsy97$bw6_t7)
table(nlsy97$bw6_t8)
table(nlsy97$bw6_t9)
table(nlsy97$bw6_t10)


table(nlsy97$bw5_t0, exclude = NULL)
table(nlsy97$bw5_t1, exclude = NULL)
table(nlsy97$bw5_t2, exclude = NULL)
table(nlsy97$bw5_t3, exclude = NULL)
table(nlsy97$bw5_t4, exclude = NULL)
table(nlsy97$bw5_t5, exclude = NULL)

## How many cases do we have 3 years of breadwinning in a row?
nlsy97 <- nlsy97 %>%
mutate(t0 = case_when(  (bw_t0 == "Breadwinner" | bw_t0 == "Not a breadwinner") &
                        (bw_t1 == "Breadwinner" | bw_t1 == "Not a breadwinner") &
                        (bw_t2 == "Breadwinner" | bw_t2 == "Not a breadwinner") ~ 1),
       t1 = case_when(  (bw_t1 == "Breadwinner" | bw_t1 == "Not a breadwinner") &
                        (bw_t2 == "Breadwinner" | bw_t2 == "Not a breadwinner") &
                        (bw_t3 == "Breadwinner" | bw_t3 == "Not a breadwinner") ~ 1),
       t2 = case_when(  (bw_t2 == "Breadwinner" | bw_t2 == "Not a breadwinner") &
                        (bw_t3 == "Breadwinner" | bw_t3 == "Not a breadwinner") &
                        (bw_t4 == "Breadwinner" | bw_t4 == "Not a breadwinner") ~ 1))

nlsy97$t0[is.na(nlsy97$t0)] <- 0
nlsy97$t1[is.na(nlsy97$t1)] <- 0
nlsy97$t2[is.na(nlsy97$t2)] <- 0

summary(nlsy97$t0)
summary(nlsy97$t1)
summary(nlsy97$t2)

nlsy97 <- nlsy97 %>%
mutate(bw3a = case_when(  bw_t0 == "Breadwinner" & bw_t1 == "Breadwinner" &
                          bw_t2 == "Breadwinner" ~ 1),
       bw3b = case_when(  bw_t1 == "Breadwinner" & bw_t2 == "Breadwinner" &
                          bw_t3 == "Breadwinner" ~ 1),  
       bw3c = case_when(  bw_t2 == "Breadwinner" & bw_t3 == "Breadwinner" &
                          bw_t4 == "Breadwinner" ~ 1))

nlsy97$bw3a[is.na(nlsy97$bw3a)] <- 0
nlsy97$bw3b[is.na(nlsy97$bw3b)] <- 0
nlsy97$bw3c[is.na(nlsy97$bw3c)] <- 0

summary(nlsy97$bw3a)
summary(nlsy97$bw3b)
summary(nlsy97$bw3c)

#Birth year by age_birth & marst
nlsy97 %>%
  filter(!is.na(mar_t0)) %>%
  ggplot(aes(birth_year, age_birth, color = mar_t0)) +
  geom_point(position = "jitter") +
  theme_minimal() +
  theme(legend.position = c(0.85, 0.2),
        plot.margin=unit(c(1,1,1.5,1.5),"cm")) +
  scale_y_continuous(name = "Age at 1st birth", breaks = c(18, 20, 22, 24, 26, 28)) +
  scale_x_continuous(name = "Year of 1st birth", breaks = c(1996, 2000, 2004, 2008, 2012)) +
  labs(title = "Mothers' marital status at the time of 1st birth", 
       subtitle = "Mothers aged 18 - 27 at 1st birth",
       color = "Marital status",
       caption = "Source: National Longitudinal Survey of Youth | 1997 \n Analysis by: Joanna R. Pepin")

#Age_birth by inc_t1 & marst
nlsy97 %>%
  filter(!is.na(mar_t0)) %>%
  ggplot(aes(age_birth, log10(inc_t0), color = mar_t0)) +
  geom_point(position = "jitter") +
  theme_minimal()

#Age_birth by hhinc_t1 & marst
nlsy97 %>%
  filter(!is.na(mar_t0)) %>%
  ggplot(aes(age_birth, hhinc_t0, color = mar_t0)) +
  geom_point(position = "jitter") +
  theme_minimal()

#Birth year by age_birth & breadwinner
nlsy97 %>%
  filter(!is.na(bw_t0)) %>%
  filter(mar_t0 != "Div/Sep/Wid" & !is.na(mar_t0)) %>%
  ggplot(aes(age_birth, hhinc_t0, color = bw_t0)) +
  facet_wrap(~ mar_t0) +
  geom_point(position = "jitter") +
  theme_minimal()

## Early births

early <- nlsy97 %>%
  filter(birth_year <= 2006)

table(early$bw_t0)
table(early$bw_t1)
table(early$bw_t2)
table(early$bw_t3)
table(early$bw_t4)
table(early$bw_t5)
table(early$bw_t6)
table(early$bw_t7)
table(early$bw_t8)
table(early$bw_t9)
table(early$bw_t10)

early %>%
  filter(!is.na(bw_t5)) %>%
  filter(mar_t0 != "Div/Sep/Wid" & !is.na(mar_t0)) %>%
  ggplot(aes(birth_year, age_birth,  color = bw_t5)) +
  facet_wrap(~ mar_t0) +
  scale_y_continuous(name = "Age at First Birth", breaks = c(18, 20, 22, 24, 26, 28)) +
  scale_x_continuous(name = "Birth year") +
  geom_point(position = "jitter") +
  labs(title = "Breadwinner Status 5 years after 1st birth", 
       subtitle = "By marital status at the time of 1st birth",
       color = "Breadwinner Status T + 5") +
  theme_minimal()

### Missing data
table(nlsy97$bw_t0, exclude=NULL)
table(nlsy97$bw_t1, exclude=NULL)
table(nlsy97$bw_t2, exclude=NULL)
table(nlsy97$bw_t3, exclude=NULL)
table(nlsy97$bw_t4, exclude=NULL)
table(nlsy97$bw_t5, exclude=NULL)

sum(is.na(nlsy97$inc_t0))
sum(is.na(nlsy97$inc_t1))
sum(is.na(nlsy97$inc_t2))
sum(is.na(nlsy97$inc_t3))
sum(is.na(nlsy97$inc_t4))
sum(is.na(nlsy97$inc_t5))

sum(is.na(nlsy97$hhinc_t0))
sum(is.na(nlsy97$hhinc_t1))
sum(is.na(nlsy97$hhinc_t2))
sum(is.na(nlsy97$hhinc_t3))
sum(is.na(nlsy97$hhinc_t4))
sum(is.na(nlsy97$hhinc_t5))


# missing inc & hhinc crosstabs
test <- nlsy97
test$incmiss0 <- 0
test$incmiss1 <- 0
test$incmiss2 <- 0
test$incmiss3 <- 0
test$incmiss4 <- 0
test$incmiss5 <- 0
test$incmiss6 <- 0
test$incmiss7 <- 0
test$incmiss8 <- 0
test$incmiss9 <- 0
test$incmiss10 <- 0

test$incmiss0[is.na(test$inc_t0)] <- 1
test$incmiss1[is.na(test$inc_t1)] <- 1
test$incmiss2[is.na(test$inc_t2)] <- 1
test$incmiss3[is.na(test$inc_t3)] <- 1
test$incmiss4[is.na(test$inc_t4)] <- 1
test$incmiss5[is.na(test$inc_t5)] <- 1
test$incmiss6[is.na(test$inc_t6)] <- 1
test$incmiss7[is.na(test$inc_t7)] <- 1
test$incmiss8[is.na(test$inc_t8)] <- 1
test$incmiss9[is.na(test$inc_t9)] <- 1
test$incmiss10[is.na(test$inc_t10)] <- 1

test$hhincmiss0 <- 0
test$hhincmiss1 <- 0
test$hhincmiss2 <- 0
test$hhincmiss3 <- 0
test$hhincmiss4 <- 0
test$hhincmiss5 <- 0
test$hhincmiss6 <- 0
test$hhincmiss7 <- 0
test$hhincmiss8 <- 0
test$hhincmiss9 <- 0
test$hhincmiss10 <- 0

test$hhincmiss0[is.na(test$hhinc_t0)] <- 1
test$hhincmiss1[is.na(test$hhinc_t1)] <- 1
test$hhincmiss2[is.na(test$hhinc_t2)] <- 1
test$hhincmiss3[is.na(test$hhinc_t3)] <- 1
test$hhincmiss4[is.na(test$hhinc_t4)] <- 1
test$hhincmiss5[is.na(test$hhinc_t5)] <- 1
test$hhincmiss6[is.na(test$hhinc_t6)] <- 1
test$hhincmiss7[is.na(test$hhinc_t7)] <- 1
test$hhincmiss8[is.na(test$hhinc_t8)] <- 1
test$hhincmiss9[is.na(test$hhinc_t9)] <- 1
test$hhincmiss10[is.na(test$hhinc_t10)] <- 1

table(test$incmiss0, test$hhincmiss0)
table(test$incmiss1, test$hhincmiss1)
table(test$incmiss2, test$hhincmiss2)
table(test$incmiss3, test$hhincmiss3)
table(test$incmiss4, test$hhincmiss4)
table(test$incmiss5, test$hhincmiss5)