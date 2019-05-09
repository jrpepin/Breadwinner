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
data_hh <- data_hh %>% group_by(PUBID_1997) %>% complete(year=full_seq(year,1))

data_hh$birth_year <- as.numeric(data_hh$birth_year)

data_hh  <- data_hh  %>%
  group_by(PUBID_1997) %>%  
  mutate(birth_year = max(birth_year, na.rm = TRUE))

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
      TRUE                                                   ~  NA_character_),
    hhe5_t11 = case_when(
      ((momearn/hhearn) >  .5 & year == birth_year + 12)     ~ "Breadwinner",
      ((momearn/hhearn) <= .5 & year == birth_year + 12)     ~ "Not a breadwinner",
      TRUE                                                   ~  NA_character_),
    hhe5_t12 = case_when(
      ((momearn/hhearn) >  .5 & year == birth_year + 13)     ~ "Breadwinner",
      ((momearn/hhearn) <= .5 & year == birth_year + 13)     ~ "Not a breadwinner",
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
      TRUE                                                   ~  NA_character_),
    hhe6_t11 = case_when(
      ((momearn/hhearn) >  .6 & year == birth_year + 12)     ~ "Breadwinner",
      ((momearn/hhearn) <= .6 & year == birth_year + 12)     ~ "Not a breadwinner",
      TRUE                                                   ~  NA_character_),
    hhe6_t12 = case_when(
      ((momearn/hhearn) >  .6 & year == birth_year + 13)     ~ "Breadwinner",
      ((momearn/hhearn) <= .6 & year == birth_year + 13)     ~ "Not a breadwinner",
      TRUE                                                   ~  NA_character_),
    )

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
data_hh$hhe5_t11 <- factor(data_hh$hhe5_t11)
data_hh$hhe5_t12 <- factor(data_hh$hhe5_t12)

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
data_hh$hhe6_t11 <- factor(data_hh$hhe6_t11)
data_hh$hhe6_t12 <- factor(data_hh$hhe6_t12)

# Create time variable
data_hh <- data_hh %>%
  group_by(PUBID_1997) %>%
  mutate(
    time = case_when(
      (year == birth_year + 0)      ~  0L,
      (year == birth_year + 1)      ~  1L,
      (year == birth_year + 2)      ~  2L,
      (year == birth_year + 3)      ~  3L,
      (year == birth_year + 4)      ~  4L,
      (year == birth_year + 5)      ~  5L,
      (year == birth_year + 6)      ~  6L,
      (year == birth_year + 7)      ~  7L,
      (year == birth_year + 8)      ~  8L,
      (year == birth_year + 9)      ~  9L,
      (year == birth_year + 10)     ~  10L,
      (year == birth_year + 11)     ~  11L,
      (year == birth_year + 12)     ~  12L,
      (year == birth_year + 13)     ~  13L,
      (year == birth_year + 14)     ~  14L,
      (year == birth_year + 15)     ~  15L,
      (year == birth_year + 16)     ~  16L,
      (year == birth_year + 17)     ~  17L))

# Create firstbirth variable
data_hh <- arrange(data_hh, PUBID_1997, year)

data_hh <- data_hh %>%
  group_by(PUBID_1997) %>%
  mutate(
    firstbirth = case_when(
      (year >= birth_year)   ~ 1,
      (year < birth_year)    ~ 0))

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

data_hh50 <- data_hh50

data_hh50 <- data_hh50 %>%
  group_by(PUBID_1997, status) %>%
  mutate(hhe50  = max(hhe50, na.rm = TRUE))

data_hh50$hhe50[data_hh50$hhe50 == -Inf] <- NA

data_hh50 <- data_hh50 %>%
  filter(   (status == "t0" & time == 0) |
            (status == "t1" & time == 1) |
            (status == "t2" & time == 2) | 
            (status == "t3" & time == 3) |
            (status == "t4" & time == 4) |
            (status == "t5" & time == 5) |
            (status == "t6" & time == 6) | 
            (status == "t7" & time == 7) |
            (status == "t8" & time == 8) |
            (status == "t9" & time == 9))

data_hh50 <- arrange(data_hh50, PUBID_1997, year)



# Restructure the data
## 60% Breadwinning data
data_hh60 <- data_hh %>%
  select(PUBID_1997, year, firstbirth, birth_year, time, starts_with("hhe6")) %>%
  group_by(PUBID_1997) %>%
  gather(status, hhe60, -PUBID_1997, -year, -firstbirth, -birth_year, -time) %>%
  separate(status, c("type", "status"), "_")

data_hh60$hhe60[data_hh60$hhe60 == "Not a breadwinner"] = 0L  # Not a breadwinner
data_hh60$hhe60[data_hh60$hhe60 == "Breadwinner"]       = 1L  # Breadwinner

data_hh60$hhe60 <- as.numeric(data_hh60$hhe60)

data_hh60 <- data_hh60

data_hh60 <- data_hh60 %>%
  group_by(PUBID_1997, status) %>%
  mutate(hhe60  = max(hhe60, na.rm = TRUE))

data_hh60$hhe60[data_hh60$hhe60 == -Inf] <- NA

data_hh60 <- data_hh60 %>%
  filter(       (status == "t0" & time == 0) |
                (status == "t1" & time == 1) |
                (status == "t2" & time == 2) | 
                (status == "t3" & time == 3) |
                (status == "t4" & time == 4) |
                (status == "t5" & time == 5) |
                (status == "t6" & time == 6) | 
                (status == "t7" & time == 7) |
                (status == "t8" & time == 8) |
                (status == "t9" & time == 9))

data_hh60 <- arrange(data_hh60, PUBID_1997, year)


#Create datasets
data_hh50 <- data_hh50 %>%
  ungroup() %>%
  select(PUBID_1997, year, firstbirth, hhe50, time)

data_hh60 <- data_hh60 %>%
  ungroup() %>%
  select(PUBID_1997, year, firstbirth, hhe60, time)

require(foreign)
write.dta(data_hh50, "stata/NLSY97_hh50.dta")
write.dta(data_hh60, "stata/NLSY97_hh60.dta")