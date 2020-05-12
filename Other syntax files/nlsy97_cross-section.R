## Create mom's total EARNINGS variable
##  wages, mombiz, spbiz, spinc, hhinc

earnings   <- mominc
earnings   <- left_join(earnings,   mombiz)
earnings   <- left_join(earnings,   spinc)
earnings   <- left_join(earnings,   spbiz)
earnings   <- left_join(earnings,   hhinc)

earnings <- earnings %>%
  select(PUBID_1997, year, birth_year, wages, mombiz, spwages, spbiz, hhinc)

## Missing
earnings[earnings == -4] = 0  # Valid missing

earnings <- earnings %>%
  filter(wages != -5)         # Non-interview

earnings[is.na(earnings)] = 0 # Make missing 0 so don't drop them just because variable didn't exist that year

earnings[earnings == -3] <- NA # Invalid missing 
earnings[earnings == -2] <- NA # Dont know 
earnings[earnings == -1] <- NA # Refused 

## Create earnings summary variables
earnings <- earnings %>%
  group_by(PUBID_1997, year) %>%  
  mutate(momearn = wages + mombiz,
         famearn = wages + mombiz + spwages + spbiz,
         hhearn  = wages + mombiz + spwages + spbiz + hhinc)

## Keep if moms
earnings <- earnings %>%
  filter(birth_year != 0)         # Ever gave birth

## Keep if kid under 6 in household
kidu6 <- new_data %>%
  select(PUBID_1997, starts_with("CV_HH_UNDER_6_")) %>%
  gather(var, kidu6, -PUBID_1997) %>%
  separate(var, c("d1", "d2", "d3", "under", "year"), "_") %>%
  select(PUBID_1997, year, kidu6)

earnings      <- left_join(earnings,   kidu6)
earnings$dob <- new_data$dob[match(earnings$PUBID_1997, new_data$PUBID_1997)]

## 2004
nlsy04 <- earnings %>%
  filter(year == 2004 & birth_year <=2004 & kidu6 >=1)         # First year of hhinc var & mom & kidu6 in hh

### Missing
nlsy04 <- filter(nlsy04, !is.na(momearn))
nlsy04 <- filter(nlsy04, !is.na(hhearn))

### Age check
nlsy04$age <- floor((as.Date("2004-1-1") - nlsy04$dob)/ 365.25)

## Household breadwinning
nlsy04 <- nlsy04 %>%
  mutate(
    bwh5 = case_when(
      (momearn/hhearn) >  .5 ~ "Breadwinner",
      (momearn/hhearn) <= .5 ~ "Not a breadwinner"),
    bwh6 = case_when(
      (momearn/hhearn) >  .6 ~ "Breadwinner",
      (momearn/hhearn) <= .6 ~ "Not a breadwinner")
    )

## 2005
nlsy05 <- earnings %>%
  filter(year == 2005 & birth_year <=2005 & kidu6 >=1)         # First year of hhinc var & mom & kidu6 in hh

### Missing
nlsy05 <- filter(nlsy05, !is.na(momearn))
nlsy05 <- filter(nlsy05, !is.na(hhearn))

### Age check
nlsy05$age <- floor((as.Date("2005-1-1") - nlsy05$dob)/ 365.25)

## Household breadwinning
nlsy05 <- nlsy05 %>%
  mutate(
    bwh5 = case_when(
      (momearn/hhearn) >  .5 ~ "Breadwinner",
      (momearn/hhearn) <= .5 ~ "Not a breadwinner"),
    bwh6 = case_when(
      (momearn/hhearn) >  .6 ~ "Breadwinner",
      (momearn/hhearn) <= .6 ~ "Not a breadwinner")
  )

## 2006
nlsy06 <- earnings %>%
  filter(year == 2006 & birth_year <=2006 & kidu6 >=1)         # First year of hhinc var & mom & kidu6 in hh

### Missing
nlsy06 <- filter(nlsy06, !is.na(momearn))
nlsy06 <- filter(nlsy06, !is.na(hhearn))

### Age check
nlsy06$age <- floor((as.Date("2006-1-1") - nlsy06$dob)/ 365.25)

## Household breadwinning
nlsy06 <- nlsy06 %>%
  mutate(
    bwh5 = case_when(
      (momearn/hhearn) >  .5 ~ "Breadwinner",
      (momearn/hhearn) <= .5 ~ "Not a breadwinner"),
    bwh6 = case_when(
      (momearn/hhearn) >  .6 ~ "Breadwinner",
      (momearn/hhearn) <= .6 ~ "Not a breadwinner")
  )

## 2007
nlsy07 <- earnings %>%
  filter(year == 2007 & birth_year <=2007 & kidu6 >=1)         # First year of hhinc var & mom & kidu6 in hh

### Missing
nlsy07 <- filter(nlsy07, !is.na(momearn))
nlsy07 <- filter(nlsy07, !is.na(hhearn))

### Age check
nlsy07$age <- floor((as.Date("2007-1-1") - nlsy07$dob)/ 365.25)

## Household breadwinning
nlsy07 <- nlsy07 %>%
  mutate(
    bwh5 = case_when(
      (momearn/hhearn) >  .5 ~ "Breadwinner",
      (momearn/hhearn) <= .5 ~ "Not a breadwinner"),
    bwh6 = case_when(
      (momearn/hhearn) >  .6 ~ "Breadwinner",
      (momearn/hhearn) <= .6 ~ "Not a breadwinner")
  )

## 2008
nlsy08 <- earnings %>%
  filter(year == 2008 & birth_year <=2008 & kidu6 >=1)         # First year of hhinc var & mom & kidu6 in hh

### Missing
nlsy08 <- filter(nlsy08, !is.na(momearn))
nlsy08 <- filter(nlsy08, !is.na(hhearn))

### Age check
nlsy08$age <- floor((as.Date("2008-1-1") - nlsy08$dob)/ 365.25)

## Household breadwinning
nlsy08 <- nlsy08 %>%
  mutate(
    bwh5 = case_when(
      (momearn/hhearn) >  .5 ~ "Breadwinner",
      (momearn/hhearn) <= .5 ~ "Not a breadwinner"),
    bwh6 = case_when(
      (momearn/hhearn) >  .6 ~ "Breadwinner",
      (momearn/hhearn) <= .6 ~ "Not a breadwinner")
  )

## 2009
nlsy09 <- earnings %>%
  filter(year == 2009 & birth_year <=2009 & kidu6 >=1)         # First year of hhinc var & mom & kidu6 in hh

### Missing
nlsy09 <- filter(nlsy09, !is.na(momearn))
nlsy09 <- filter(nlsy09, !is.na(hhearn))

### Age check
nlsy09$age <- floor((as.Date("2009-1-1") - nlsy09$dob)/ 365.25)

## Household breadwinning
nlsy09 <- nlsy09 %>%
  mutate(
    bwh5 = case_when(
      (momearn/hhearn) >  .5 ~ "Breadwinner",
      (momearn/hhearn) <= .5 ~ "Not a breadwinner"),
    bwh6 = case_when(
      (momearn/hhearn) >  .6 ~ "Breadwinner",
      (momearn/hhearn) <= .6 ~ "Not a breadwinner")
  )

## 2010
nlsy10 <- earnings %>%
  filter(year == 2010 & birth_year <=2010 & kidu6 >=1)         # First year of hhinc var & mom & kidu6 in hh

### Missing
nlsy10 <- filter(nlsy10, !is.na(momearn))
nlsy10 <- filter(nlsy10, !is.na(hhearn))

### Age check
nlsy10$age <- floor((as.Date("2010-1-1") - nlsy10$dob)/ 365.25)

## Household breadwinning
nlsy10 <- nlsy10 %>%
  mutate(
    bwh5 = case_when(
      (momearn/hhearn) >  .5 ~ "Breadwinner",
      (momearn/hhearn) <= .5 ~ "Not a breadwinner"),
    bwh6 = case_when(
      (momearn/hhearn) >  .6 ~ "Breadwinner",
      (momearn/hhearn) <= .6 ~ "Not a breadwinner")
  )

## 2011
nlsy11 <- earnings %>%
  filter(year == 2011 & birth_year <=2011 & kidu6 >=1)         # First year of hhinc var & mom & kidu6 in hh

### Missing
nlsy11 <- filter(nlsy11, !is.na(momearn))
nlsy11 <- filter(nlsy11, !is.na(hhearn))

### Age check
nlsy11$age <- floor((as.Date("2011-1-1") - nlsy11$dob)/ 365.25)

## Household breadwinning
nlsy11 <- nlsy11 %>%
  mutate(
    bwh5 = case_when(
      (momearn/hhearn) >  .5 ~ "Breadwinner",
      (momearn/hhearn) <= .5 ~ "Not a breadwinner"),
    bwh6 = case_when(
      (momearn/hhearn) >  .6 ~ "Breadwinner",
      (momearn/hhearn) <= .6 ~ "Not a breadwinner")
  )

## 2013
nlsy13 <- earnings %>%
  filter(year == 2013 & birth_year <=2013 & kidu6 >=1)         # First year of hhinc var & mom & kidu6 in hh

### Missing
nlsy13 <- filter(nlsy13, !is.na(momearn))
nlsy13 <- filter(nlsy13, !is.na(hhearn))

### Age check
nlsy13$age <- floor((as.Date("2013-1-1") - nlsy13$dob)/ 365.25)

## Household breadwinning
nlsy13 <- nlsy13 %>%
  mutate(
    bwh5 = case_when(
      (momearn/hhearn) >  .5 ~ "Breadwinner",
      (momearn/hhearn) <= .5 ~ "Not a breadwinner"),
    bwh6 = case_when(
      (momearn/hhearn) >  .6 ~ "Breadwinner",
      (momearn/hhearn) <= .6 ~ "Not a breadwinner")
  )

## 2015
nlsy15 <- earnings %>%
  filter(year == 2015 & birth_year <=2015 & kidu6 >=1)         # First year of hhinc var & mom & kidu6 in hh

### Missing
nlsy15 <- filter(nlsy15, !is.na(momearn))
nlsy15 <- filter(nlsy15, !is.na(hhearn))

### Age check
nlsy15$age <- floor((as.Date("2015-1-1") - nlsy15$dob)/ 365.25)

## Household breadwinning
nlsy15 <- nlsy15 %>%
  mutate(
    bwh5 = case_when(
      (momearn/hhearn) >  .5 ~ "Breadwinner",
      (momearn/hhearn) <= .5 ~ "Not a breadwinner"),
    bwh6 = case_when(
      (momearn/hhearn) >  .6 ~ "Breadwinner",
      (momearn/hhearn) <= .6 ~ "Not a breadwinner")
  )

table(nlsy04$bwh5)
table(nlsy05$bwh5)
table(nlsy06$bwh5)
table(nlsy07$bwh5)
table(nlsy08$bwh5)
table(nlsy09$bwh5)
table(nlsy10$bwh5)
table(nlsy11$bwh5)
table(nlsy13$bwh5)
table(nlsy15$bwh5)

table(nlsy04$bwh6)
table(nlsy05$bwh6)
table(nlsy06$bwh6)
table(nlsy07$bwh6)
table(nlsy08$bwh6)
table(nlsy09$bwh6)
table(nlsy10$bwh6)
table(nlsy11$bwh6)
table(nlsy13$bwh6)
table(nlsy15$bwh6)