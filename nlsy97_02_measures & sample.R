

# Use this script after the Investigator R script
# marked out the "Handle missing values" code in the Investigator script to analyze type of missing data

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

marstat[marstat == "-5" | marstat == "-4" | marstat == "-3"| marstat == "-2"| marstat == "-1"] = NA  # Missing

marstat <- marstat %>% 
  gather(var, marst, -PUBID_1997) %>%
  separate(var, c("type", "var", "year"), "_")

marstat <- subset(marstat, select = -c(type, var))
marstat$birth_year   <- new_data$birth_year

marstat <- marstat %>%
  mutate(
    marst = case_when(
      marst   == "Married, spouse present"       |  marst == "Married, spouse absent"       ~ "Married",
      marst   == "Divorced, cohabiting"          |  marst == "Never married, cohabiting" |
      marst   == "Separated, cohabiting"         |  marst == "Widowed, cohabiting"          ~ "Cohab",
      marst   == "Never married, not cohabiting"                                            ~ "Never married",
      marst   == "Divorced, not cohabiting"      |  marst == "Separated, not cohabiting" |
      marst   == "Widowed, not cohabiting"                                                  ~ "Div/Sep/Wid",
      TRUE                                                                                  ~  NA_character_
    ))

marstat$marst <- factor(marstat$marst, levels = c("Married", "Cohab", "Never married", "Div/Sep/Wid"))

marstat <- marstat %>%
  group_by(PUBID_1997) %>% 
  mutate(
    mar_t0 = case_when(year  == birth_year + 0 ~ marst),
    mar_t1 = case_when(year  == birth_year + 1 ~ marst),
    mar_t2 = case_when(year  == birth_year + 2 ~ marst),
    mar_t3 = case_when(year  == birth_year + 3 ~ marst),
    mar_t4 = case_when(year  == birth_year + 4 ~ marst),
    mar_t5 = case_when(year  == birth_year + 5 ~ marst),
    mar_t6 = case_when(year  == birth_year + 6 ~ marst),
    mar_t7 = case_when(year  == birth_year + 7 ~ marst),
    mar_t8 = case_when(year  == birth_year + 8 ~ marst),
    mar_t9 = case_when(year  == birth_year + 9 ~ marst))

marstat <- marstat %>% group_by(PUBID_1997) %>% summarise_all(funs(first(na.omit(.)))) # 1 row per person

marstat <- subset(marstat, select = -c(year, marst, birth_year)) # drop extra variables

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
  mutate(spwages = case_when(spincd   == "1"    ~ spwages,
                             spincd   == "0"    ~ 0L,
                             spincd   == "-5"   ~ -5L,
                             spincd   == "-4"   ~ -4L,
                             spincd   == "-3"   ~ -3L,
                             spincd   == "-2"   ~ -2L,
                             spincd   == "-1"   ~ -1L,
                             TRUE               ~ NA_integer_
  ))

### Let's give people the estimated income if they reported it. Use the mean of the range selected, as done for the Gross Income variables.
### https://www.nlsinfo.org/content/cohorts/nlsy97/other-documentation/codebook-supplement/appendix-5-income-and-assets-variab-3
spinc <- spinc %>%
  group_by(PUBID_1997, year) %>%
  mutate(spwages = case_when(!is.na(spwages) & (spwages< -5L | spwages >=0L)  ~ spwages,
                             spwages_est == 1L ~ 2500L,
                             spwages_est == 2L ~ 7500L,
                             spwages_est == 3L ~ 17500L,
                             spwages_est == 4L ~ 37500L,
                             spwages_est == 5L ~ 75000L,
                             spwages_est == 6L ~ 175000L,
                             spwages_est == 7L ~ 250001L,
                           (spwages >= -5L & spwages <= -1) & spwages_est<= -1L ~ spwages,
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

### R's Total Household Income by year
# https://www.nlsinfo.org/content/cohorts/nlsy97/topical-guide/income/income

totinc <- new_data %>%
  select(PUBID_1997, starts_with("CV_INCOME_GROSS_YR"), starts_with("CV_INCOME_FAMILY")) %>%
  gather(var, totinc, -PUBID_1997) %>%
  separate(var, c("type", "year"), -4)

# Create dataset with all income variables
##  wages, mombiz, chsup, dvdend, gftinc, govpro1, govpro2, govpro3, inhinc, intrst, othinc, rntinc, wcomp, hhinc, totinc
incdata   <- mominc
incdata   <- left_join(incdata,   mombiz)
incdata   <- left_join(incdata,   chsup)
incdata   <- left_join(incdata,   dvdend)
incdata   <- left_join(incdata,   gftinc)
incdata   <- left_join(incdata,   govpro1)
incdata   <- left_join(incdata,   govpro2)
incdata   <- left_join(incdata,   govpro3)
incdata   <- left_join(incdata,   inhinc)
incdata   <- left_join(incdata,   intrst)
incdata   <- left_join(incdata,   othinc)
incdata   <- left_join(incdata,   rntinc)
incdata   <- left_join(incdata,   wcomp)
incdata   <- left_join(incdata,   hhinc)
incdata   <- left_join(incdata,   totinc)
incdata   <- left_join(incdata,   spwages)
incdata   <- left_join(incdata,   spbiz)
incdata   <- left_join(incdata,   spinc)
incdata   <- left_join(incdata,   wcomp_sp)

incdata <- incdata %>%
  select(PUBID_1997, year, birth_year, wages, mombiz, chsup, dvdend, gftinc, govpro1, govpro2, govpro3, inhinc, intrst, othinc, rntinc, wcomp, 
         hhinc, totinc, spwages, spbiz, spwages, wcomp_sp)

## Create the birth year plus 1 variables
incdata$birth_year1   <- incdata$birth_year + 1
incdata$birth_year2   <- incdata$birth_year + 2
incdata$birth_year3   <- incdata$birth_year + 3
incdata$birth_year4   <- incdata$birth_year + 4
incdata$birth_year5   <- incdata$birth_year + 5
incdata$birth_year6   <- incdata$birth_year + 6
incdata$birth_year7   <- incdata$birth_year + 7
incdata$birth_year8   <- incdata$birth_year + 8
incdata$birth_year9   <- incdata$birth_year + 9
incdata$birth_year10  <- incdata$birth_year + 10
incdata$birth_year11  <- incdata$birth_year + 11

incdata$birth_minus1 <- incdata$birth_year - 1
incdata$birth_minus2 <- incdata$birth_year - 2
incdata$birth_minus3 <- incdata$birth_year - 3
incdata$birth_minus4 <- incdata$birth_year - 4

### Clean up console
is.logical(length(unique(incdata$PUBID_1997)) == length(unique(new_data$PUBID_1997))) # Check to make sure N in incdata = N in new_data

remove(chsup, dvdend, gftinc, govpro1, govpro2, govpro3, inhinc, 
       intrst, mominc, mombiz, othinc, rntinc, wcomp, totinc, 
       hhinc, spbiz, spinc, wcomp_sp)

##############################################################################
# Create the sample
## Data is in long format, multiple rows per person.
incdata <- merge(incdata, new_data[, c("PUBID_1997", "age_birth")], by="PUBID_1997") # Add age at first birth to data

incdata <- incdata %>%
  filter(birth_year != 0) # limit to mothers

incdata <- incdata %>%
  filter(age_birth >= 18 & age_birth <=30) # limit to mothers 18 - 30 at first birth

## MISSING DATA
### Create copy of dataset to evaluate missing income data
miss_data <- incdata

### Handle the missing data for all of these variables before combining them.......
incdata[incdata == -4] = 0  # Valid missing

incdata <- incdata %>%
  filter(wages != -5)         # Non-interview

incdata[is.na(incdata)] = 0 # Make missing 0 so don't drop them just because variable didn't exist that year

incdata[incdata == -3] <- NA # Invalid missing 
incdata[incdata == -2] <- NA # Dont know 
incdata[incdata == -1] <- NA # Refused 

incdata <- arrange(incdata, PUBID_1997, year)

print("End of nlsy97_02_measures & sample") # Marks end of R Script