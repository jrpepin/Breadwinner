earnings   <- inc_data


earnings <- earnings %>%
  select(PUBID_1997, year, birth_year, wages, mombiz, spwages, spbiz, hhinc)

## Create earnings summary variables
earnings <- earnings %>%
  group_by(PUBID_1997, year) %>%  
  mutate(momearn = wages + mombiz,
         famearn = wages + mombiz + spwages + spbiz,
         hhearn  = wages + mombiz + spwages + spbiz + hhinc)


## Tidy year vars
earnings$year <- as.numeric(earnings$year)
earnings$birth_year <- as.numeric(earnings$birth_year)

## Birth year breadwinning
## Careful - t0 is birth year plus 1 for earnings because respondents report earnings from the previous year
earnings <- earnings %>%
  group_by(PUBID_1997) %>%
  mutate(
    bwf5_m2 = case_when(
      ((momearn/famearn) >  .5 & year == birth_year - 1)      ~ "Breadwinner",
      ((momearn/famearn) <= .5 & year == birth_year - 1)      ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    bwf5_m1 = case_when(
      ((momearn/famearn) >  .5 & year == birth_year)          ~ "Breadwinner",
      ((momearn/famearn) <= .5 & year == birth_year)          ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    bwf5_t0 = case_when(
      ((momearn/famearn) >  .5 & year == birth_year + 1)      ~ "Breadwinner",
      ((momearn/famearn) <= .5 & year == birth_year + 1)      ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    bwf5_t1 = case_when(
      ((momearn/famearn) >  .5 & year == birth_year + 2)      ~ "Breadwinner",
      ((momearn/famearn) <= .5 & year == birth_year + 2)      ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    bwf5_t2 = case_when(
      ((momearn/famearn) >  .5 & year == birth_year + 3)      ~ "Breadwinner",
      ((momearn/famearn) <= .5 & year == birth_year + 3)      ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    bwf5_t3 = case_when(
      ((momearn/famearn) >  .5 & year == birth_year + 4)      ~ "Breadwinner",
      ((momearn/famearn) <= .5 & year == birth_year + 4)      ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    bwf5_t4 = case_when(
      ((momearn/famearn) >  .5 & year == birth_year + 5)      ~ "Breadwinner",
      ((momearn/famearn) <= .5 & year == birth_year + 5)      ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    bwf5_t5 = case_when(
      ((momearn/famearn) >  .5 & year == birth_year + 6)      ~ "Breadwinner",
      ((momearn/famearn) <= .5 & year == birth_year + 6)      ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    bwf5_t6 = case_when(
      ((momearn/famearn) >  .5 & year == birth_year + 7)      ~ "Breadwinner",
      ((momearn/famearn) <= .5 & year == birth_year + 7)      ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    bwf5_t7 = case_when(
      ((momearn/famearn) >  .5 & year == birth_year + 8)      ~ "Breadwinner",
      ((momearn/famearn) <= .5 & year == birth_year + 8)      ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    bwf5_t8 = case_when(
      ((momearn/famearn) >  .5 & year == birth_year + 9)      ~ "Breadwinner",
      ((momearn/famearn) <= .5 & year == birth_year + 9)      ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    bwf5_t9 = case_when(
      ((momearn/famearn) >  .5 & year == birth_year + 10)     ~ "Breadwinner",
      ((momearn/famearn) <= .5 & year == birth_year + 10)     ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_),
    bwf5_t10 = case_when(
      ((momearn/famearn) >  .5 & year == birth_year + 11)     ~ "Breadwinner",
      ((momearn/famearn) <= .5 & year == birth_year + 11)     ~ "Not a breadwinner",
      TRUE                                                    ~  NA_character_))

earnings <- earnings %>%
  select(PUBID_1997, year, birth_year, momearn, famearn, starts_with("bwf5"))

earnings$bwf5_m2  <- factor(earnings$bwf5_m2)
earnings$bwf5_m1  <- factor(earnings$bwf5_m1)
earnings$bwf5_t0  <- factor(earnings$bwf5_t0)
earnings$bwf5_t1  <- factor(earnings$bwf5_t1)
earnings$bwf5_t2  <- factor(earnings$bwf5_t2)
earnings$bwf5_t3  <- factor(earnings$bwf5_t3)
earnings$bwf5_t4  <- factor(earnings$bwf5_t4)
earnings$bwf5_t5  <- factor(earnings$bwf5_t5)
earnings$bwf5_t6  <- factor(earnings$bwf5_t6)
earnings$bwf5_t7  <- factor(earnings$bwf5_t7)
earnings$bwf5_t8  <- factor(earnings$bwf5_t8)
earnings$bwf5_t9  <- factor(earnings$bwf5_t9)
earnings$bwf5_t10 <- factor(earnings$bwf5_t10)

## restructure data
test <- earnings %>%
  select(PUBID_1997, year, starts_with("bwf5")) %>%
  group_by(PUBID_1997) %>%
  gather(time, status, -PUBID_1997, -year) %>%
  separate(time, c("type", "time"), "_") %>%
  filter(!is.na(status))


## Sample of data
earnings <- earnings %>%
  select(PUBID_1997, year, starts_with("bwf5")) %>%
  group_by(PUBID_1997) %>%
  gather(time, status, -PUBID_1997, -year) %>%
  separate(time, c("type", "time"), "_")

earnings$status[earnings$status == "Not a breadwinner"] = 0  # Not a breadwinner
earnings$status[earnings$status == "Breadwinner"]       = 1  # Breadwinner

earnings <- earnings[order(earnings$PUBID_1997, earnings$year),]
# sample <- earnings[1:100,]
write.csv(earnings, file = "NLSY97.csv")


## Logit
mylogit1 <- glm(bwf5_t0 ~ bwf5_m1, data = earndat, family = "binomial")
mylogit2 <- glm(bwf5_t0 ~ bwf5_m2, data = earndat, family = "binomial")

test$status  <- factor(test$status)

test$time <- factor(test$time, levels = c("t0", "m2", "m1", "t1", "t2", "t3", "t4", 
                                             "t5", "t6", "t7", "t8", "t9", "t10", ordered = TRUE))
mylogitA <- glm(status ~ time, data = test, family=binomial(link='logit'))

test$time <- factor(test$time, levels = c("m2", "m1", "t0", "t1", "t2", "t3", "t4", 
                                          "t5", "t6", "t7", "t8", "t9", "t10", ordered = TRUE))
mylogitB <- glm(status ~ time, data = test, family=binomial(link='logit'))

library(ggeffects)
pbw   <- ggeffect(mylogitA, "time")

ggpredict(se=TRUE)

ggplot(pbw, aes(x, predicted)) +
  geom_line() +
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high), alpha = .1)