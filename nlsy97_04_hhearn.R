# Household data_hh Variables
data_hh   <- incdata

data_hh  <- data_hh  %>%
  select(PUBID_1997, year, birth_year, wages, mombiz, spwages, spbiz, hhinc)

## Create data_hh summary variables
data_hh  <- data_hh  %>%
  group_by(PUBID_1997, year) %>%  
  mutate(momearn = wages + mombiz,
         hhearn  = wages + mombiz + spwages + spbiz + hhinc)

## Tidy year vars
data_hh$year       <- as.numeric(data_hh$year)
data_hh$birth_year <- as.numeric(data_hh$birth_year)

## Birth year breadwinning 50%
## Careful - t0 is birth year plus 1 for data_hh because respondents report data_hh from the previous year
data_hh <- data_hh %>%
  group_by(PUBID_1997) %>%
  mutate(
    hhe5_m2 = case_when(
      ((momearn/hhearn) >  .5 & year == birth_year - 1)      ~ "Breadwinner",
      ((momearn/hhearn) <= .5 & year == birth_year - 1)      ~ "Not a breadwinner",
      TRUE                                                   ~  NA_character_),
    hhe5_m1 = case_when(
      ((momearn/hhearn) >  .5 & year == birth_year)          ~ "Breadwinner",
      ((momearn/hhearn) <= .5 & year == birth_year)          ~ "Not a breadwinner",
      TRUE                                                   ~  NA_character_),
    hhe5_t0 = case_when(
      ((momearn/hhearn) >  .5 & year == birth_year + 1)      ~ "Breadwinner",
      ((momearn/hhearn) <= .5 & year == birth_year + 1)      ~ "Not a breadwinner",
      TRUE                                                   ~  NA_character_),
    hhe5_t1 = case_when(
      ((momearn/hhearn) >  .5 & year == birth_year + 2)      ~ "Breadwinner",
      ((momearn/hhearn) <= .5 & year == birth_year + 2)      ~ "Not a breadwinner",
      TRUE                                                   ~  NA_character_),
    hhe5_t2 = case_when(
      ((momearn/hhearn) >  .5 & year == birth_year + 3)      ~ "Breadwinner",
      ((momearn/hhearn) <= .5 & year == birth_year + 3)      ~ "Not a breadwinner",
      TRUE                                                   ~  NA_character_),
    hhe5_t3 = case_when(
      ((momearn/hhearn) >  .5 & year == birth_year + 4)      ~ "Breadwinner",
      ((momearn/hhearn) <= .5 & year == birth_year + 4)      ~ "Not a breadwinner",
      TRUE                                                   ~  NA_character_),
    hhe5_t4 = case_when(
      ((momearn/hhearn) >  .5 & year == birth_year + 5)      ~ "Breadwinner",
      ((momearn/hhearn) <= .5 & year == birth_year + 5)      ~ "Not a breadwinner",
      TRUE                                                   ~  NA_character_),
    hhe5_t5 = case_when(
      ((momearn/hhearn) >  .5 & year == birth_year + 6)      ~ "Breadwinner",
      ((momearn/hhearn) <= .5 & year == birth_year + 6)      ~ "Not a breadwinner",
      TRUE                                                   ~  NA_character_),
    hhe5_t6 = case_when(
      ((momearn/hhearn) >  .5 & year == birth_year + 7)      ~ "Breadwinner",
      ((momearn/hhearn) <= .5 & year == birth_year + 7)      ~ "Not a breadwinner",
      TRUE                                                   ~  NA_character_),
    hhe5_t7 = case_when(
      ((momearn/hhearn) >  .5 & year == birth_year + 8)      ~ "Breadwinner",
      ((momearn/hhearn) <= .5 & year == birth_year + 8)      ~ "Not a breadwinner",
      TRUE                                                   ~  NA_character_),
    hhe5_t8 = case_when(
      ((momearn/hhearn) >  .5 & year == birth_year + 9)      ~ "Breadwinner",
      ((momearn/hhearn) <= .5 & year == birth_year + 9)      ~ "Not a breadwinner",
      TRUE                                                   ~  NA_character_),
    hhe5_t9 = case_when(
      ((momearn/hhearn) >  .5 & year == birth_year + 10)     ~ "Breadwinner",
      ((momearn/hhearn) <= .5 & year == birth_year + 10)     ~ "Not a breadwinner",
      TRUE                                                   ~  NA_character_),
    hhe5_t10 = case_when(
      ((momearn/hhearn) >  .5 & year == birth_year + 11)     ~ "Breadwinner",
      ((momearn/hhearn) <= .5 & year == birth_year + 11)     ~ "Not a breadwinner",
      TRUE                                                   ~  NA_character_))


## Birth year breadwinning 60%
## Careful - t0 is birth year plus 1 for data_hh because respondents report data_hh from the previous year
data_hh <- data_hh %>%
  group_by(PUBID_1997) %>%
  mutate(
    hhe6_m2 = case_when(
      ((momearn/hhearn) >  .6 & year == birth_year - 1)      ~ "Breadwinner",
      ((momearn/hhearn) <= .6 & year == birth_year - 1)      ~ "Not a breadwinner",
      TRUE                                                   ~  NA_character_),
    hhe6_m1 = case_when(
      ((momearn/hhearn) >  .6 & year == birth_year)          ~ "Breadwinner",
      ((momearn/hhearn) <= .6 & year == birth_year)          ~ "Not a breadwinner",
      TRUE                                                   ~  NA_character_),
    hhe6_t0 = case_when(
      ((momearn/hhearn) >  .6 & year == birth_year + 1)      ~ "Breadwinner",
      ((momearn/hhearn) <= .6 & year == birth_year + 1)      ~ "Not a breadwinner",
      TRUE                                                   ~  NA_character_),
    hhe6_t1 = case_when(
      ((momearn/hhearn) >  .6 & year == birth_year + 2)      ~ "Breadwinner",
      ((momearn/hhearn) <= .6 & year == birth_year + 2)      ~ "Not a breadwinner",
      TRUE                                                   ~  NA_character_),
    hhe6_t2 = case_when(
      ((momearn/hhearn) >  .6 & year == birth_year + 3)      ~ "Breadwinner",
      ((momearn/hhearn) <= .6 & year == birth_year + 3)      ~ "Not a breadwinner",
      TRUE                                                   ~  NA_character_),
    hhe6_t3 = case_when(
      ((momearn/hhearn) >  .6 & year == birth_year + 4)      ~ "Breadwinner",
      ((momearn/hhearn) <= .6 & year == birth_year + 4)      ~ "Not a breadwinner",
      TRUE                                                   ~  NA_character_),
    hhe6_t4 = case_when(
      ((momearn/hhearn) >  .6 & year == birth_year + 5)      ~ "Breadwinner",
      ((momearn/hhearn) <= .6 & year == birth_year + 5)      ~ "Not a breadwinner",
      TRUE                                                   ~  NA_character_),
    hhe6_t5 = case_when(
      ((momearn/hhearn) >  .6 & year == birth_year + 6)      ~ "Breadwinner",
      ((momearn/hhearn) <= .6 & year == birth_year + 6)      ~ "Not a breadwinner",
      TRUE                                                   ~  NA_character_),
    hhe6_t6 = case_when(
      ((momearn/hhearn) >  .6 & year == birth_year + 7)      ~ "Breadwinner",
      ((momearn/hhearn) <= .6 & year == birth_year + 7)      ~ "Not a breadwinner",
      TRUE                                                   ~  NA_character_),
    hhe6_t7 = case_when(
      ((momearn/hhearn) >  .6 & year == birth_year + 8)      ~ "Breadwinner",
      ((momearn/hhearn) <= .6 & year == birth_year + 8)      ~ "Not a breadwinner",
      TRUE                                                   ~  NA_character_),
    hhe6_t8 = case_when(
      ((momearn/hhearn) >  .6 & year == birth_year + 9)      ~ "Breadwinner",
      ((momearn/hhearn) <= .6 & year == birth_year + 9)      ~ "Not a breadwinner",
      TRUE                                                   ~  NA_character_),
    hhe6_t9 = case_when(
      ((momearn/hhearn) >  .6 & year == birth_year + 10)     ~ "Breadwinner",
      ((momearn/hhearn) <= .6 & year == birth_year + 10)     ~ "Not a breadwinner",
      TRUE                                                   ~  NA_character_),
    hhe6_t10 = case_when(
      ((momearn/hhearn) >  .6 & year == birth_year + 11)     ~ "Breadwinner",
      ((momearn/hhearn) <= .6 & year == birth_year + 11)     ~ "Not a breadwinner",
      TRUE                                                   ~  NA_character_))

## Tidy data
data_hh <- data_hh %>%
  select(PUBID_1997, year, birth_year, momearn, famearn, starts_with("hhe"))

data_hh$hhe5_m2  <- factor(data_hh$hhe5_m2)
data_hh$hhe5_m1  <- factor(data_hh$hhe5_m1)
data_hh$hhe5_t0  <- factor(data_hh$hhe5_t0)
data_hh$hhe5_t1  <- factor(data_hh$hhe5_t1)
data_hh$hhe5_t2  <- factor(data_hh$hhe5_t2)
data_hh$hhe5_t3  <- factor(data_hh$hhe5_t3)
data_hh$hhe5_t4  <- factor(data_hh$hhe5_t4)
data_hh$hhe5_t5  <- factor(data_hh$hhe5_t5)
data_hh$hhe5_t6  <- factor(data_hh$hhe5_t6)
data_hh$hhe5_t7  <- factor(data_hh$hhe5_t7)
data_hh$hhe5_t8  <- factor(data_hh$hhe5_t8)
data_hh$hhe5_t9  <- factor(data_hh$hhe5_t9)
data_hh$hhe5_t10 <- factor(data_hh$hhe5_t10)

data_hh$hhe6_m2  <- factor(data_hh$hhe6_m2)
data_hh$hhe6_m1  <- factor(data_hh$hhe6_m1)
data_hh$hhe6_t0  <- factor(data_hh$hhe6_t0)
data_hh$hhe6_t1  <- factor(data_hh$hhe6_t1)
data_hh$hhe6_t2  <- factor(data_hh$hhe6_t2)
data_hh$hhe6_t3  <- factor(data_hh$hhe6_t3)
data_hh$hhe6_t4  <- factor(data_hh$hhe6_t4)
data_hh$hhe6_t5  <- factor(data_hh$hhe6_t5)
data_hh$hhe6_t6  <- factor(data_hh$hhe6_t6)
data_hh$hhe6_t7  <- factor(data_hh$hhe6_t7)
data_hh$hhe6_t8  <- factor(data_hh$hhe6_t8)
data_hh$hhe6_t9  <- factor(data_hh$hhe6_t9)
data_hh$hhe6_t10 <- factor(data_hh$hhe6_t10)

# Create firstbirth variable
data_hh <- arrange(data_hh, PUBID_1997, year)

data_hh <- data_hh %>%
  group_by(PUBID_1997) %>%
  mutate(
    firstbirth = case_when(
      (year >= birth_year -1)   ~ 1,
      (year <  birth_year -1)   ~ 0))

# Create time variable
data_hh <- data_hh %>%
  group_by(PUBID_1997) %>%
  mutate(
    time = case_when(
      (year == birth_year - 1)      ~ -2L, # These are lagged by 1 year because earnings were asked about the previous year
      (year == birth_year - 0)      ~ -1L,
      (year == birth_year + 1)      ~  0L,
      (year == birth_year + 2)      ~  1L,
      (year == birth_year + 3)      ~  2L,
      (year == birth_year + 4)      ~  3L,
      (year == birth_year + 5)      ~  4L,
      (year == birth_year + 6)      ~  5L,
      (year == birth_year + 7)      ~  6L,
      (year == birth_year + 8)      ~  7L,
      (year == birth_year + 9)      ~  8L,
      (year == birth_year + 10)     ~  9L))

# Restructure the data
## 50% Breadwinning data
data_hh50 <- data_hh %>%
  select(PUBID_1997, year, firstbirth, birth_year, time, starts_with("hhe5")) %>%
  group_by(PUBID_1997) %>%
  gather(status, hhe50, -PUBID_1997, -year, -firstbirth, -birth_year, -time) %>%
  separate(status, c("type", "status"), "_")

data_hh50$hhe50[data_hh50$hhe50 == "Not a breadwinner"] = 0L  # Not a breadwinner
data_hh50$hhe50[data_hh50$hhe50 == "Breadwinner"]       = 1L  # Breadwinner

data_hh50$hhe50 <- as.numeric(data_hh50$hhe50)

data_hh50 <- data_hh50 %>%
  group_by(PUBID_1997, year) %>%
  summarise(firstbirth = first(firstbirth),
            birthyear = first(birth_year),
            time = first(time),
            hhe50 = mean(hhe50, na.rm=TRUE))
data_hh50$hhe50[is.nan(data_hh50$hhe50)] <- NA

data_hh50 <- data_hh50[order(data_hh50$PUBID_1997, data_hh50$year),]


## 60% Breadwinning data
data_hh60 <- data_hh %>%
  select(PUBID_1997, year, firstbirth, birth_year, time, starts_with("hhe6")) %>%
  group_by(PUBID_1997) %>%
  gather(status, hhe60, -PUBID_1997, -year, -firstbirth, -birth_year, -time) %>%
  separate(status, c("type", "status"), "_")

data_hh60$hhe60[data_hh60$hhe60 == "Not a breadwinner"] = 0L  # Not a breadwinner
data_hh60$hhe60[data_hh60$hhe60 == "Breadwinner"]       = 1L  # Breadwinner

data_hh60$hhe60 <- as.numeric(data_hh60$hhe60)

data_hh60 <- data_hh60 %>%
  group_by(PUBID_1997, year) %>%
  summarise(firstbirth = first(firstbirth),
            birthyear = first(birth_year),
            time = first(time),
            hhe60 = mean(hhe60, na.rm=TRUE))
data_hh60$hhe60[is.nan(data_hh60$hhe60)] <- NA

data_hh60 <- data_hh60[order(data_hh60$PUBID_1997, data_hh60$year),]


#Create datasets

require(foreign)
write.dta(data_hh50, "stata/NLSY97_hh50.dta")
write.dta(data_hh60, "stata/NLSY97_hh60.dta")