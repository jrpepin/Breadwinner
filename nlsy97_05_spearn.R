# Spouse/Partner Earnings Variables
data_sp   <- incdata

data_sp <- data_sp %>%
  select(PUBID_1997, year, birth_year, wages, mombiz, spwages, spbiz)

## Create earnings summary variables
data_sp <- data_sp %>%
  group_by(PUBID_1997, year) %>%  
  mutate(momearn = wages + mombiz,
         spearn = wages + mombiz + spwages + spbiz)

## Tidy year vars
data_sp$year       <- as.numeric(data_sp$year)
data_sp$birth_year <- as.numeric(data_sp$birth_year)

## Birth year breadwinning 50%
## Careful - t0 is birth year plus 1 for earnings because respondents report earnings from the previous year
data_sp <- data_sp %>%
  group_by(PUBID_1997) %>%
  mutate(
    spe5_m2 = case_when(
      ((momearn/spearn) >  .5 & year == birth_year - 1)      ~ "Breadwinner",
      ((momearn/spearn) <= .5 & year == birth_year - 1)      ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    spe5_m1 = case_when(
      ((momearn/spearn) >  .5 & year == birth_year)          ~ "Breadwinner",
      ((momearn/spearn) <= .5 & year == birth_year)          ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    spe5_t0 = case_when(
      ((momearn/spearn) >  .5 & year == birth_year + 1)      ~ "Breadwinner",
      ((momearn/spearn) <= .5 & year == birth_year + 1)      ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    spe5_t1 = case_when(
      ((momearn/spearn) >  .5 & year == birth_year + 2)      ~ "Breadwinner",
      ((momearn/spearn) <= .5 & year == birth_year + 2)      ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    spe5_t2 = case_when(
      ((momearn/spearn) >  .5 & year == birth_year + 3)      ~ "Breadwinner",
      ((momearn/spearn) <= .5 & year == birth_year + 3)      ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    spe5_t3 = case_when(
      ((momearn/spearn) >  .5 & year == birth_year + 4)      ~ "Breadwinner",
      ((momearn/spearn) <= .5 & year == birth_year + 4)      ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    spe5_t4 = case_when(
      ((momearn/spearn) >  .5 & year == birth_year + 5)      ~ "Breadwinner",
      ((momearn/spearn) <= .5 & year == birth_year + 5)      ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    spe5_t5 = case_when(
      ((momearn/spearn) >  .5 & year == birth_year + 6)      ~ "Breadwinner",
      ((momearn/spearn) <= .5 & year == birth_year + 6)      ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    spe5_t6 = case_when(
      ((momearn/spearn) >  .5 & year == birth_year + 7)      ~ "Breadwinner",
      ((momearn/spearn) <= .5 & year == birth_year + 7)      ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    spe5_t7 = case_when(
      ((momearn/spearn) >  .5 & year == birth_year + 8)      ~ "Breadwinner",
      ((momearn/spearn) <= .5 & year == birth_year + 8)      ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    spe5_t8 = case_when(
      ((momearn/spearn) >  .5 & year == birth_year + 9)      ~ "Breadwinner",
      ((momearn/spearn) <= .5 & year == birth_year + 9)      ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    spe5_t9 = case_when(
      ((momearn/spearn) >  .5 & year == birth_year + 10)     ~ "Breadwinner",
      ((momearn/spearn) <= .5 & year == birth_year + 10)     ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    spe5_t10 = case_when(
      ((momearn/spearn) >  .5 & year == birth_year + 11)     ~ "Breadwinner",
      ((momearn/spearn) <= .5 & year == birth_year + 11)     ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_))


## Birth year breadwinning 60%
## Careful - t0 is birth year plus 1 for earnings because respondents report earnings from the previous year
data_sp <- data_sp %>%
  group_by(PUBID_1997) %>%
  mutate(
    spe6_m2 = case_when(
      ((momearn/spearn) >  .6 & year == birth_year - 1)      ~ "Breadwinner",
      ((momearn/spearn) <= .6 & year == birth_year - 1)      ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    spe6_m1 = case_when(
      ((momearn/spearn) >  .6 & year == birth_year)          ~ "Breadwinner",
      ((momearn/spearn) <= .6 & year == birth_year)          ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    spe6_t0 = case_when(
      ((momearn/spearn) >  .6 & year == birth_year + 1)      ~ "Breadwinner",
      ((momearn/spearn) <= .6 & year == birth_year + 1)      ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    spe6_t1 = case_when(
      ((momearn/spearn) >  .6 & year == birth_year + 2)      ~ "Breadwinner",
      ((momearn/spearn) <= .6 & year == birth_year + 2)      ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    spe6_t2 = case_when(
      ((momearn/spearn) >  .6 & year == birth_year + 3)      ~ "Breadwinner",
      ((momearn/spearn) <= .6 & year == birth_year + 3)      ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    spe6_t3 = case_when(
      ((momearn/spearn) >  .6 & year == birth_year + 4)      ~ "Breadwinner",
      ((momearn/spearn) <= .6 & year == birth_year + 4)      ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    spe6_t4 = case_when(
      ((momearn/spearn) >  .6 & year == birth_year + 5)      ~ "Breadwinner",
      ((momearn/spearn) <= .6 & year == birth_year + 5)      ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    spe6_t5 = case_when(
      ((momearn/spearn) >  .6 & year == birth_year + 6)      ~ "Breadwinner",
      ((momearn/spearn) <= .6 & year == birth_year + 6)      ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    spe6_t6 = case_when(
      ((momearn/spearn) >  .6 & year == birth_year + 7)      ~ "Breadwinner",
      ((momearn/spearn) <= .6 & year == birth_year + 7)      ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    spe6_t7 = case_when(
      ((momearn/spearn) >  .6 & year == birth_year + 8)      ~ "Breadwinner",
      ((momearn/spearn) <= .6 & year == birth_year + 8)      ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    spe6_t8 = case_when(
      ((momearn/spearn) >  .6 & year == birth_year + 9)      ~ "Breadwinner",
      ((momearn/spearn) <= .6 & year == birth_year + 9)      ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    spe6_t9 = case_when(
      ((momearn/spearn) >  .6 & year == birth_year + 10)     ~ "Breadwinner",
      ((momearn/spearn) <= .6 & year == birth_year + 10)     ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    spe6_t10 = case_when(
      ((momearn/spearn) >  .6 & year == birth_year + 11)     ~ "Breadwinner",
      ((momearn/spearn) <= .6 & year == birth_year + 11)     ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_))

## Tidy data
data_sp <- data_sp %>%
  select(PUBID_1997, year, birth_year, momearn, famearn, starts_with("hhe"))

data_sp$spe5_m2  <- factor(data_sp$spe5_m2)
data_sp$spe5_m1  <- factor(data_sp$spe5_m1)
data_sp$spe5_t0  <- factor(data_sp$spe5_t0)
data_sp$spe5_t1  <- factor(data_sp$spe5_t1)
data_sp$spe5_t2  <- factor(data_sp$spe5_t2)
data_sp$spe5_t3  <- factor(data_sp$spe5_t3)
data_sp$spe5_t4  <- factor(data_sp$spe5_t4)
data_sp$spe5_t5  <- factor(data_sp$spe5_t5)
data_sp$spe5_t6  <- factor(data_sp$spe5_t6)
data_sp$spe5_t7  <- factor(data_sp$spe5_t7)
data_sp$spe5_t8  <- factor(data_sp$spe5_t8)
data_sp$spe5_t9  <- factor(data_sp$spe5_t9)
data_sp$spe5_t10 <- factor(data_sp$spe5_t10)

data_sp$spe6_m2  <- factor(data_sp$spe6_m2)
data_sp$spe6_m1  <- factor(data_sp$spe6_m1)
data_sp$spe6_t0  <- factor(data_sp$spe6_t0)
data_sp$spe6_t1  <- factor(data_sp$spe6_t1)
data_sp$spe6_t2  <- factor(data_sp$spe6_t2)
data_sp$spe6_t3  <- factor(data_sp$spe6_t3)
data_sp$spe6_t4  <- factor(data_sp$spe6_t4)
data_sp$spe6_t5  <- factor(data_sp$spe6_t5)
data_sp$spe6_t6  <- factor(data_sp$spe6_t6)
data_sp$spe6_t7  <- factor(data_sp$spe6_t7)
data_sp$spe6_t8  <- factor(data_sp$spe6_t8)
data_sp$spe6_t9  <- factor(data_sp$spe6_t9)
data_sp$spe6_t10 <- factor(data_sp$spe6_t10)

# Restructure the data

## 50% Breadwinning data
data_sp5 <- data_sp %>%
  select(PUBID_1997, year, starts_with("spe5")) %>%
  group_by(PUBID_1997) %>%
  gather(time, status, -PUBID_1997, -year) %>%
  separate(time, c("type", "time"), "_")

data_sp5$status[data_sp5$status == "Not a breadwinner"] = 0  # Not a breadwinner
data_sp5$status[data_sp5$status == "Breadwinner"]       = 1  # Breadwinner

data_sp5 <- data_sp5[order(data_sp5$PUBID_1997, data_sp5$year),]


## 60% Breadwinning data
data_sp6 <- data_sp %>%
  select(PUBID_1997, year, starts_with("spe6")) %>%
  group_by(PUBID_1997) %>%
  gather(time, status, -PUBID_1997, -year) %>%
  separate(time, c("type", "time"), "_")

data_sp6$status[data_sp6$status == "Not a breadwinner"] = 0  # Not a breadwinner
data_sp6$status[data_sp6$status == "Breadwinner"]       = 1  # Breadwinner

data_sp6 <- data_sp6[order(data_sp6$PUBID_1997, data_sp6$year),]

#Create datasets
write.csv(data_sp5, file = "NLSY97_sp5.csv")
write.csv(data_sp6, file = "NLSY97_sp6.csv")