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
  
## Breadwinning

### Personal Income of R by year

# YINC-1400 - R RECEIVE INCOME FROM JOB IN PAST YEAR?
# YINC-1700 - TOTAL INCOME FROM WAGES AND SALARY IN PAST YEAR
mominc <- new_data %>%
  select(PUBID_1997, starts_with("YINC-1700"), starts_with("YINC-1400"), starts_with("YINC-1500")) %>%
  gather(var, val, -PUBID_1997) %>%
  separate(var, c("type", "year"), "_")

mominc <- mominc %>%
  mutate(rinc  = case_when(type == "YINC-1700" ~ val),
         incd  = case_when(type == "YINC-1400" ~ val),
         incd2 = case_when(type == "YINC-1500" ~ val)) %>%
  group_by(PUBID_1997, year) %>% 
  summarise(rinc = first(rinc), incd = nth(incd, 2), incd2 = last(incd2))

# Give people an income if they reported it, and 0 if they reported they had no income. Other is missing
mominc <- mominc %>%
  group_by(PUBID_1997, year) %>%
  mutate(rinc = case_when( incd   == "1"    ~ rinc,
                           incd   == "0"    ~ 0L,
                           incd   == "-5"   ~ -5L,
                           incd   == "-4"   ~ -4L,
                           incd   == "-3"   ~ -3L,
                           incd   == "-2"   ~ -2L,
                           incd   == "-1"   ~ -1L,
                           incd2  == "0"    ~ 0L,
                           TRUE             ~ NA_integer_
                      ))
# Order the dataset to match new_data and then add birth_year variable
mominc <- arrange(mominc, year, PUBID_1997)
mominc$birth_year   <- new_data$birth_year

# Create the birth year plus 1 variables
mominc$birth_year1   <- mominc$birth_year + 1
mominc$birth_year2   <- mominc$birth_year + 2
mominc$birth_year3   <- mominc$birth_year + 3
mominc$birth_year4   <- mominc$birth_year + 4
mominc$birth_year5   <- mominc$birth_year + 5
mominc$birth_year6   <- mominc$birth_year + 6
mominc$birth_year7   <- mominc$birth_year + 7
mominc$birth_year8   <- mominc$birth_year + 8
mominc$birth_year9   <- mominc$birth_year + 9
mominc$birth_year10  <- mominc$birth_year + 10
mominc$birth_year11  <- mominc$birth_year + 11


mominc$birth_minus1 <- mominc$birth_year - 1
mominc$birth_minus2 <- mominc$birth_year - 2
mominc$birth_minus3 <- mominc$birth_year - 3
mominc$birth_minus4 <- mominc$birth_year - 4


# give people the income they reported for each of the income plus 1 variables
## Careful - t0 is birth year plus 1 for income because respondents report income from the previous year
mominc <- mominc %>%
  group_by(PUBID_1997) %>% 
  mutate(inc_t0  = case_when(birth_year1   == year ~ rinc),
         inc_t1  = case_when(birth_year2   == year ~ rinc),
         inc_t2  = case_when(birth_year3   == year ~ rinc),
         inc_t3  = case_when(birth_year4   == year ~ rinc),
         inc_t4  = case_when(birth_year5   == year ~ rinc),
         inc_t5  = case_when(birth_year6   == year ~ rinc),
         inc_t6  = case_when(birth_year7   == year ~ rinc),
         inc_t7  = case_when(birth_year8   == year ~ rinc),
         inc_t8  = case_when(birth_year9   == year ~ rinc),
         inc_t9  = case_when(birth_year10  == year ~ rinc),
         inc_t10 = case_when(birth_year11  == year ~ rinc))

# give people the income they reported for each of the income minus 1 variables
mominc <- mominc %>%
  group_by(PUBID_1997) %>% 
  mutate(inc_m1 = case_when(birth_year   == year ~ rinc),
         inc_m2 = case_when(birth_minus1 == year ~ rinc),
         inc_m3 = case_when(birth_minus2 == year ~ rinc),
         inc_m4 = case_when(birth_minus3 == year ~ rinc),
         inc_m5 = case_when(birth_minus4 == year ~ rinc))

# aggregate the data so there is 1 row per person
mominc <- mominc %>%
group_by(PUBID_1997) %>% 
  summarise_at(c("inc_t0", "inc_t1", "inc_t2", "inc_t3", "inc_t4", "inc_t5", 
                 "inc_t6", "inc_t7", "inc_t8", "inc_t9", "inc_t10",
                 "inc_m1", "inc_m2", "inc_m3", "inc_m4", "inc_m5"), mean, na.rm = TRUE)

## replace the NaN with NA to address the missing
mominc$inc_t0[is.nan(mominc$inc_t0)] <- NA
mominc$inc_t1[is.nan(mominc$inc_t1)] <- NA
mominc$inc_t2[is.nan(mominc$inc_t2)] <- NA
mominc$inc_t3[is.nan(mominc$inc_t3)] <- NA
mominc$inc_t4[is.nan(mominc$inc_t4)] <- NA
mominc$inc_t5[is.nan(mominc$inc_t5)] <- NA
mominc$inc_t6[is.nan(mominc$inc_t6)] <- NA
mominc$inc_t7[is.nan(mominc$inc_t7)] <- NA
mominc$inc_t8[is.nan(mominc$inc_t8)] <- NA
mominc$inc_t9[is.nan(mominc$inc_t9)] <- NA
mominc$inc_t10[is.nan(mominc$inc_t10)] <- NA

mominc$inc_m1[is.nan(mominc$inc_m1)] <- NA
mominc$inc_m2[is.nan(mominc$inc_m2)] <- NA
mominc$inc_m3[is.nan(mominc$inc_m3)] <- NA
mominc$inc_m4[is.nan(mominc$inc_m4)] <- NA
mominc$inc_m5[is.nan(mominc$inc_m5)] <- NA

### Add new variables to original dataset
new_data   <- left_join(new_data,   mominc, by = "PUBID_1997")
remove(mominc)

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
  select(1, 185:226)

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

# BREADWINNER
nlsy97 <- nlsy97 %>%
  mutate(
    bw_t0 = case_when(
      (nlsy97$inc_t0/nlsy97$hhinc_t0) > .5 ~ "Breadwinner",
      (nlsy97$inc_t0/nlsy97$hhinc_t0) < .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw_t1 = case_when(
      (nlsy97$inc_t1/nlsy97$hhinc_t1) > .5 ~ "Breadwinner",
      (nlsy97$inc_t1/nlsy97$hhinc_t1) < .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw_t2 = case_when(
      (nlsy97$inc_t2/nlsy97$hhinc_t2) > .5 ~ "Breadwinner",
      (nlsy97$inc_t2/nlsy97$hhinc_t2) < .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw_t3 = case_when(
      (nlsy97$inc_t3/nlsy97$hhinc_t3) > .5 ~ "Breadwinner",
      (nlsy97$inc_t3/nlsy97$hhinc_t3) < .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw_t4 = case_when(
      (nlsy97$inc_t4/nlsy97$hhinc_t4) > .5 ~ "Breadwinner",
      (nlsy97$inc_t4/nlsy97$hhinc_t4) < .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw_t5 = case_when(
      (nlsy97$inc_t5/nlsy97$hhinc_t5) > .5 ~ "Breadwinner",
      (nlsy97$inc_t5/nlsy97$hhinc_t5) < .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw_t6 = case_when(
      (nlsy97$inc_t6/nlsy97$hhinc_t6) > .5 ~ "Breadwinner",
      (nlsy97$inc_t6/nlsy97$hhinc_t6) < .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw_t7 = case_when(
      (nlsy97$inc_t7/nlsy97$hhinc_t7) > .5 ~ "Breadwinner",
      (nlsy97$inc_t7/nlsy97$hhinc_t7) < .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw_t8 = case_when(
      (nlsy97$inc_t8/nlsy97$hhinc_t8) > .5 ~ "Breadwinner",
      (nlsy97$inc_t8/nlsy97$hhinc_t8) < .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw_t9 = case_when(
      (nlsy97$inc_t9/nlsy97$hhinc_t9) > .5 ~ "Breadwinner",
      (nlsy97$inc_t9/nlsy97$hhinc_t9) < .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw_t10 = case_when(
      (nlsy97$inc_t10/nlsy97$hhinc_t10) > .5 ~ "Breadwinner",
      (nlsy97$inc_t10/nlsy97$hhinc_t10) < .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_)
  )
nlsy97$bw_t0 <- factor(nlsy97$bw_t0, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw_t1 <- factor(nlsy97$bw_t1, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw_t2 <- factor(nlsy97$bw_t2, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw_t3 <- factor(nlsy97$bw_t3, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw_t4 <- factor(nlsy97$bw_t4, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw_t5 <- factor(nlsy97$bw_t5, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw_t6 <- factor(nlsy97$bw_t6, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw_t7 <- factor(nlsy97$bw_t7, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw_t8 <- factor(nlsy97$bw_t8, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw_t9 <- factor(nlsy97$bw_t9, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw_t10 <- factor(nlsy97$bw_t10, levels = c("Breadwinner", "Not a breadwinner"))


nlsy97 <- nlsy97 %>%
  mutate(
    bw_m1 = case_when(
      (nlsy97$inc_m1/nlsy97$hhinc_m1) > .5 ~ "Breadwinner",
      (nlsy97$inc_m1/nlsy97$hhinc_m1) < .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw_m2 = case_when(
      (nlsy97$inc_m2/nlsy97$hhinc_m2) > .5 ~ "Breadwinner",
      (nlsy97$inc_m2/nlsy97$hhinc_m2) < .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw_m3 = case_when(
      (nlsy97$inc_m3/nlsy97$hhinc_m3) > .5 ~ "Breadwinner",
      (nlsy97$inc_m3/nlsy97$hhinc_m3) < .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw_m4 = case_when(
      (nlsy97$inc_m4/nlsy97$hhinc_m4) > .5 ~ "Breadwinner",
      (nlsy97$inc_m4/nlsy97$hhinc_m4) < .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw_m5 = case_when(
      (nlsy97$hhinc_m5/nlsy97$inc_m5) > .5 ~ "Breadwinner",
      (nlsy97$hhinc_m5/nlsy97$inc_m5) < .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
  )

nlsy97$bw_m1 <- factor(nlsy97$bw_m1, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw_m2 <- factor(nlsy97$bw_m2, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw_m3 <- factor(nlsy97$bw_m3, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw_m4 <- factor(nlsy97$bw_m4, levels = c("Breadwinner", "Not a breadwinner"))
nlsy97$bw_m5 <- factor(nlsy97$bw_m5, levels = c("Breadwinner", "Not a breadwinner"))

## Ever breadwinning
nlsy97 <- nlsy97 %>%
  mutate(everbw = case_when(
    bw_t0  == "Breadwinner" |
      bw_t1  == "Breadwinner" |  
      bw_t2  == "Breadwinner" |
      bw_t3  == "Breadwinner" |
      bw_t4  == "Breadwinner" |
      bw_t5  == "Breadwinner" |
      bw_t6  == "Breadwinner" |
      bw_t7  == "Breadwinner" |
      bw_t8  == "Breadwinner" |
      bw_t9  == "Breadwinner" |
      bw_t10 == "Breadwinner" ~ 1))

nlsy97$everbw[is.na(nlsy97$everbw)] <- 0

table(nlsy97$everbw)

# Descriptives
table(nlsy97$birth_year, nlsy97$mar_t0)
table(nlsy97$birth_year, nlsy97$age_birth)

table(nlsy97$birth_year, nlsy97$bw_t0)
table(nlsy97$birth_year, nlsy97$bw_t1)
table(nlsy97$birth_year, nlsy97$bw_t2)
table(nlsy97$birth_year, nlsy97$bw_t3)
table(nlsy97$birth_year, nlsy97$bw_t4)
table(nlsy97$birth_year, nlsy97$bw_t5)
table(nlsy97$birth_year, nlsy97$bw_t6)
table(nlsy97$birth_year, nlsy97$bw_m1)

table(nlsy97$bw_t0)
table(nlsy97$bw_t1)
table(nlsy97$bw_t2)
table(nlsy97$bw_t3)
table(nlsy97$bw_t4)
table(nlsy97$bw_t5)
table(nlsy97$bw_t6)
table(nlsy97$bw_t7)
table(nlsy97$bw_t8)
table(nlsy97$bw_t9)
table(nlsy97$bw_t10)


table(nlsy97$bw_t0, exclude = NULL)
table(nlsy97$bw_t1, exclude = NULL)
table(nlsy97$bw_t2, exclude = NULL)
table(nlsy97$bw_t3, exclude = NULL)
table(nlsy97$bw_t4, exclude = NULL)
table(nlsy97$bw_t5, exclude = NULL)

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
  scale_y_continuous(name = "Age at First Birth", breaks = c(18, 20, 22, 24, 26, 28)) +
  labs(color = "Marital Status at 1st Birth")

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