# Household Income Variables
data_inc <- incdata

## Create mom's total income variable
data_inc <- data_inc %>%
  group_by(PUBID_1997, year) %>%
  mutate(momtot = wages + mombiz + chsup + dvdend + gftinc + govpro1 + govpro2 + govpro3 + inhinc + intrst + othinc + rntinc + wcomp)

# give people the income they reported for each of the income plus 1 variables
## Careful - t0 is birth year plus 1 for income because respondents report income from the previous year
data_inc <- data_inc %>%
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
data_inc <- data_inc %>%
  group_by(PUBID_1997) %>% 
  mutate(inc_m1 = case_when(birth_year   == year ~ momtot),
         inc_m2 = case_when(birth_minus1 == year ~ momtot),
         inc_m3 = case_when(birth_minus2 == year ~ momtot),
         inc_m4 = case_when(birth_minus3 == year ~ momtot),
         inc_m5 = case_when(birth_minus4 == year ~ momtot))

# give people the total household income reported for each of the total income plus 1 variables
data_inc <- data_inc %>%
  group_by(PUBID_1997) %>% 
  mutate(totinc_t0  = case_when(birth_year1  == year ~ totinc),
         totinc_t1  = case_when(birth_year2  == year ~ totinc),
         totinc_t2  = case_when(birth_year3  == year ~ totinc),
         totinc_t3  = case_when(birth_year4  == year ~ totinc),
         totinc_t4  = case_when(birth_year5  == year ~ totinc),
         totinc_t5  = case_when(birth_year6  == year ~ totinc),
         totinc_t6  = case_when(birth_year7  == year ~ totinc),
         totinc_t7  = case_when(birth_year8  == year ~ totinc),
         totinc_t8  = case_when(birth_year9  == year ~ totinc),
         totinc_t9  = case_when(birth_year10 == year ~ totinc),
         totinc_t10 = case_when(birth_year11 == year ~ totinc))

data_inc <- data_inc %>%
  group_by(PUBID_1997) %>% 
  mutate(totinc_m1 = case_when(birth_year   == year ~ totinc),
         totinc_m2 = case_when(birth_minus1 == year ~ totinc),
         totinc_m3 = case_when(birth_minus2 == year ~ totinc),
         totinc_m4 = case_when(birth_minus3 == year ~ totinc),
         totinc_m5 = case_when(birth_minus4 == year ~ totinc))


# aggregate the data so there is 1 row per person
data_inc <- data_inc %>%
  group_by(PUBID_1997) %>% 
  summarise_at(c( "inc_t0", "inc_t1", "inc_t2", "inc_t3", "inc_t4", "inc_t5", 
                  "inc_t6", "inc_t7", "inc_t8", "inc_t9", "inc_t10",
                  "inc_m1", "inc_m2", "inc_m3", "inc_m4", "inc_m5",
                  "totinc_t0", "totinc_t1", "totinc_t2", "totinc_t3", "totinc_t4", "totinc_t5",
                  "totinc_t6", "totinc_t7", "totinc_t8", "totinc_t9", "totinc_t10", 
                  "totinc_m1", "totinc_m2", "totinc_m3", "totinc_m4", "totinc_m5"), mean, na.rm = TRUE)

## replace the NaN with NA to address the missing
data_inc$inc_t0[is.nan(data_inc$inc_t0)]   <- NA
data_inc$inc_t1[is.nan(data_inc$inc_t1)]   <- NA
data_inc$inc_t2[is.nan(data_inc$inc_t2)]   <- NA
data_inc$inc_t3[is.nan(data_inc$inc_t3)]   <- NA
data_inc$inc_t4[is.nan(data_inc$inc_t4)]   <- NA
data_inc$inc_t5[is.nan(data_inc$inc_t5)]   <- NA
data_inc$inc_t6[is.nan(data_inc$inc_t6)]   <- NA
data_inc$inc_t7[is.nan(data_inc$inc_t7)]   <- NA
data_inc$inc_t8[is.nan(data_inc$inc_t8)]   <- NA
data_inc$inc_t9[is.nan(data_inc$inc_t9)]   <- NA
data_inc$inc_t10[is.nan(data_inc$inc_t10)] <- NA

data_inc$inc_m1[is.nan(data_inc$inc_m1)] <- NA
data_inc$inc_m2[is.nan(data_inc$inc_m2)] <- NA
data_inc$inc_m3[is.nan(data_inc$inc_m3)] <- NA
data_inc$inc_m4[is.nan(data_inc$inc_m4)] <- NA
data_inc$inc_m5[is.nan(data_inc$inc_m5)] <- NA

# replace the NaN with NA to address the missing
data_inc$totinc_t0[is.nan(data_inc$totinc_t0)]   <- NA
data_inc$totinc_t1[is.nan(data_inc$totinc_t1)]   <- NA
data_inc$totinc_t2[is.nan(data_inc$totinc_t2)]   <- NA
data_inc$totinc_t3[is.nan(data_inc$totinc_t3)]   <- NA
data_inc$totinc_t4[is.nan(data_inc$totinc_t4)]   <- NA
data_inc$totinc_t5[is.nan(data_inc$totinc_t5)]   <- NA
data_inc$totinc_t6[is.nan(data_inc$totinc_t6)]   <- NA
data_inc$totinc_t7[is.nan(data_inc$totinc_t7)]   <- NA
data_inc$totinc_t8[is.nan(data_inc$totinc_t8)]   <- NA
data_inc$totinc_t9[is.nan(data_inc$totinc_t9)]   <- NA
data_inc$totinc_t10[is.nan(data_inc$totinc_t10)] <- NA

data_inc$totinc_m1[is.nan(data_inc$totinc_m1)] <- NA
data_inc$totinc_m2[is.nan(data_inc$totinc_m2)] <- NA
data_inc$totinc_m3[is.nan(data_inc$totinc_m3)] <- NA
data_inc$totinc_m4[is.nan(data_inc$totinc_m4)] <- NA
data_inc$totinc_m5[is.nan(data_inc$totinc_m5)] <- NA


# BREADWINNER 50%
data_inc <- data_inc %>%
  mutate(
    bw5_t0 = case_when(
      (inc_t0/totinc_t0) >  .5 ~ "Breadwinner",
      (inc_t0/totinc_t0) <= .5 ~ "Not a breadwinner",
      TRUE                     ~  NA_character_),
    bw5_t1 = case_when(
      (inc_t1/totinc_t1) >  .5 ~ "Breadwinner",
      (inc_t1/totinc_t1) <= .5 ~ "Not a breadwinner",
      TRUE                     ~  NA_character_),
    bw5_t2 = case_when(
      (inc_t2/totinc_t2) >  .5 ~ "Breadwinner",
      (inc_t2/totinc_t2) <= .5 ~ "Not a breadwinner",
      TRUE                     ~  NA_character_),
    bw5_t3 = case_when(
      (inc_t3/totinc_t3) >  .5 ~ "Breadwinner",
      (inc_t3/totinc_t3) <= .5 ~ "Not a breadwinner",
      TRUE                     ~  NA_character_),
    bw5_t4 = case_when(
      (inc_t4/totinc_t4) >  .5 ~ "Breadwinner",
      (inc_t4/totinc_t4) <= .5 ~ "Not a breadwinner",
      TRUE                     ~  NA_character_),
    bw5_t5 = case_when(
      (inc_t5/totinc_t5) >  .5 ~ "Breadwinner",
      (inc_t5/totinc_t5) <= .5 ~ "Not a breadwinner",
      TRUE                     ~  NA_character_),
    bw5_t6 = case_when(
      (inc_t6/totinc_t6) >  .5 ~ "Breadwinner",
      (inc_t6/totinc_t6) <= .5 ~ "Not a breadwinner",
      TRUE                                   ~  NA_character_),
    bw5_t7 = case_when(
      (inc_t7/totinc_t7) >  .5 ~ "Breadwinner",
      (inc_t7/totinc_t7) <= .5 ~ "Not a breadwinner",
      TRUE                     ~  NA_character_),
    bw5_t8 = case_when(
      (inc_t8/totinc_t8) >  .5 ~ "Breadwinner",
      (inc_t8/totinc_t8) <= .5 ~ "Not a breadwinner",
      TRUE                     ~  NA_character_),
    bw5_t9 = case_when(
      (inc_t9/totinc_t9) >  .5 ~ "Breadwinner",
      (inc_t9/totinc_t9) <= .5 ~ "Not a breadwinner",
      TRUE                     ~  NA_character_),
    bw5_t10 = case_when(
      (inc_t10/totinc_t10) >  .5 ~ "Breadwinner",
      (inc_t10/totinc_t10) <= .5 ~ "Not a breadwinner",
      TRUE                       ~  NA_character_))

data_inc$bw5_t0 <- factor(data_inc$bw5_t0, levels = c("Breadwinner", "Not a breadwinner"))
data_inc$bw5_t1 <- factor(data_inc$bw5_t1, levels = c("Breadwinner", "Not a breadwinner"))
data_inc$bw5_t2 <- factor(data_inc$bw5_t2, levels = c("Breadwinner", "Not a breadwinner"))
data_inc$bw5_t3 <- factor(data_inc$bw5_t3, levels = c("Breadwinner", "Not a breadwinner"))
data_inc$bw5_t4 <- factor(data_inc$bw5_t4, levels = c("Breadwinner", "Not a breadwinner"))
data_inc$bw5_t5 <- factor(data_inc$bw5_t5, levels = c("Breadwinner", "Not a breadwinner"))
data_inc$bw5_t6 <- factor(data_inc$bw5_t6, levels = c("Breadwinner", "Not a breadwinner"))
data_inc$bw5_t7 <- factor(data_inc$bw5_t7, levels = c("Breadwinner", "Not a breadwinner"))
data_inc$bw5_t8 <- factor(data_inc$bw5_t8, levels = c("Breadwinner", "Not a breadwinner"))
data_inc$bw5_t9 <- factor(data_inc$bw5_t9, levels = c("Breadwinner", "Not a breadwinner"))
data_inc$bw5_t10 <- factor(data_inc$bw5_t10, levels = c("Breadwinner", "Not a breadwinner"))


data_inc <- data_inc %>%
  mutate(
    bw5_m1 = case_when(
      (inc_m1/totinc_m1) >  .5 ~ "Breadwinner",
      (inc_m1/totinc_m1) <= .5 ~ "Not a breadwinner",
      TRUE                     ~  NA_character_),
    bw5_m2 = case_when(
      (inc_m2/totinc_m2) >  .5 ~ "Breadwinner",
      (inc_m2/totinc_m2) <= .5 ~ "Not a breadwinner",
      TRUE                     ~  NA_character_),
    bw5_m3 = case_when(
      (inc_m3/totinc_m3) >  .5 ~ "Breadwinner",
      (inc_m3/totinc_m3) <= .5 ~ "Not a breadwinner",
      TRUE                     ~  NA_character_),
    bw5_m4 = case_when(
      (inc_m4/totinc_m4) >  .5 ~ "Breadwinner",
      (inc_m4/totinc_m4) <= .5 ~ "Not a breadwinner",
      TRUE                     ~  NA_character_),
    bw5_m5 = case_when(
      (totinc_m5/inc_m5) >  .5 ~ "Breadwinner",
      (totinc_m5/inc_m5) <= .5 ~ "Not a breadwinner",
      TRUE                     ~  NA_character_))

data_inc$bw5_m1 <- factor(data_inc$bw5_m1, levels = c("Breadwinner", "Not a breadwinner"))
data_inc$bw5_m2 <- factor(data_inc$bw5_m2, levels = c("Breadwinner", "Not a breadwinner"))
data_inc$bw5_m3 <- factor(data_inc$bw5_m3, levels = c("Breadwinner", "Not a breadwinner"))
data_inc$bw5_m4 <- factor(data_inc$bw5_m4, levels = c("Breadwinner", "Not a breadwinner"))
data_inc$bw5_m5 <- factor(data_inc$bw5_m5, levels = c("Breadwinner", "Not a breadwinner"))

# BREADWINNER 60%
data_inc <- data_inc %>%
  mutate(
    bw6_t0 = case_when(
      (inc_t0/totinc_t0) >  .6 ~ "Breadwinner",
      (inc_t0/totinc_t0) <= .6 ~ "Not a breadwinner",
      TRUE                     ~  NA_character_),
    bw6_t1 = case_when(
      (inc_t1/totinc_t1) >  .6 ~ "Breadwinner",
      (inc_t1/totinc_t1) <= .6 ~ "Not a breadwinner",
      TRUE                     ~  NA_character_),
    bw6_t2 = case_when(
      (inc_t2/totinc_t2) >  .6 ~ "Breadwinner",
      (inc_t2/totinc_t2) <= .6 ~ "Not a breadwinner",
      TRUE                     ~  NA_character_),
    bw6_t3 = case_when(
      (inc_t3/totinc_t3) >  .6 ~ "Breadwinner",
      (inc_t3/totinc_t3) <= .6 ~ "Not a breadwinner",
      TRUE                     ~  NA_character_),
    bw6_t4 = case_when(
      (inc_t4/totinc_t4) >  .6 ~ "Breadwinner",
      (inc_t4/totinc_t4) <= .6 ~ "Not a breadwinner",
      TRUE                     ~  NA_character_),
    bw6_t5 = case_when(
      (inc_t5/totinc_t5) >  .6 ~ "Breadwinner",
      (inc_t5/totinc_t5) <= .6 ~ "Not a breadwinner",
      TRUE                     ~  NA_character_),
    bw6_t6 = case_when(
      (inc_t6/totinc_t6) >  .6 ~ "Breadwinner",
      (inc_t6/totinc_t6) <= .6 ~ "Not a breadwinner",
      TRUE                     ~  NA_character_),
    bw6_t7 = case_when(
      (inc_t7/totinc_t7) >  .6 ~ "Breadwinner",
      (inc_t7/totinc_t7) <= .6 ~ "Not a breadwinner",
      TRUE                     ~  NA_character_),
    bw6_t8 = case_when(
      (inc_t8/totinc_t8) >  .6 ~ "Breadwinner",
      (inc_t8/totinc_t8) <= .6 ~ "Not a breadwinner",
      TRUE                     ~  NA_character_),
    bw6_t9 = case_when(
      (inc_t9/totinc_t9) >  .6 ~ "Breadwinner",
      (inc_t9/totinc_t9) <= .6 ~ "Not a breadwinner",
      TRUE                     ~  NA_character_),
    bw6_t10 = case_when(
      (inc_t10/totinc_t10) >  .6 ~ "Breadwinner",
      (inc_t10/totinc_t10) <= .6 ~ "Not a breadwinner",
      TRUE                       ~  NA_character_))

data_inc$bw6_t0 <- factor(data_inc$bw6_t0, levels = c("Breadwinner", "Not a breadwinner"))
data_inc$bw6_t1 <- factor(data_inc$bw6_t1, levels = c("Breadwinner", "Not a breadwinner"))
data_inc$bw6_t2 <- factor(data_inc$bw6_t2, levels = c("Breadwinner", "Not a breadwinner"))
data_inc$bw6_t3 <- factor(data_inc$bw6_t3, levels = c("Breadwinner", "Not a breadwinner"))
data_inc$bw6_t4 <- factor(data_inc$bw6_t4, levels = c("Breadwinner", "Not a breadwinner"))
data_inc$bw6_t5 <- factor(data_inc$bw6_t5, levels = c("Breadwinner", "Not a breadwinner"))
data_inc$bw6_t6 <- factor(data_inc$bw6_t6, levels = c("Breadwinner", "Not a breadwinner"))
data_inc$bw6_t7 <- factor(data_inc$bw6_t7, levels = c("Breadwinner", "Not a breadwinner"))
data_inc$bw6_t8 <- factor(data_inc$bw6_t8, levels = c("Breadwinner", "Not a breadwinner"))
data_inc$bw6_t9 <- factor(data_inc$bw6_t9, levels = c("Breadwinner", "Not a breadwinner"))
data_inc$bw6_t10 <- factor(data_inc$bw6_t10, levels = c("Breadwinner", "Not a breadwinner"))


data_inc <- data_inc %>%
  mutate(
    bw6_m1 = case_when(
      (inc_m1/totinc_m1) >  .6 ~ "Breadwinner",
      (inc_m1/totinc_m1) <= .6 ~ "Not a breadwinner",
      TRUE                     ~  NA_character_),
    bw6_m2 = case_when(
      (inc_m2/totinc_m2) >  .6 ~ "Breadwinner",
      (inc_m2/totinc_m2) <= .6 ~ "Not a breadwinner",
      TRUE                     ~  NA_character_),
    bw6_m3 = case_when(
      (inc_m3/totinc_m3) >  .6 ~ "Breadwinner",
      (inc_m3/totinc_m3) <= .6 ~ "Not a breadwinner",
      TRUE                     ~  NA_character_),
    bw6_m4 = case_when(
      (inc_m4/totinc_m4) >  .6 ~ "Breadwinner",
      (inc_m4/totinc_m4) <= .6 ~ "Not a breadwinner",
      TRUE                     ~  NA_character_),
    bw6_m5 = case_when(
      (totinc_m5/inc_m5) >  .6 ~ "Breadwinner",
      (totinc_m5/inc_m5) <= .6 ~ "Not a breadwinner",
      TRUE                     ~  NA_character_))

data_inc$bw6_m1 <- factor(data_inc$bw6_m1, levels = c("Breadwinner", "Not a breadwinner"))
data_inc$bw6_m2 <- factor(data_inc$bw6_m2, levels = c("Breadwinner", "Not a breadwinner"))
data_inc$bw6_m3 <- factor(data_inc$bw6_m3, levels = c("Breadwinner", "Not a breadwinner"))
data_inc$bw6_m4 <- factor(data_inc$bw6_m4, levels = c("Breadwinner", "Not a breadwinner"))
data_inc$bw6_m5 <- factor(data_inc$bw6_m5, levels = c("Breadwinner", "Not a breadwinner"))

# SAVE DATASET
data_inc <- data_inc %>%
  select(PUBID_1997, starts_with("bw5_"), starts_with("bw6_"))

########################################################################################
## Ever breadwinning 50%
data_inc <- data_inc %>%
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

data_inc$everbw[is.na(data_inc$everbw)] <- 0

table(data_inc$everbw)
################################################################
# Add variables to dataset
nlsy97 <- data_inc # Create a newly named dataset

nlsy97$birth_year <- new_data$birth_year[match(nlsy97$PUBID_1997, new_data$PUBID_1997)] # Add birth year
nlsy97$mar_t0     <- new_data$mar_t0[match(nlsy97$PUBID_1997, new_data$PUBID_1997)]     # Add marst at t0
nlsy97$age_birth  <- new_data$age_birth[match(nlsy97$PUBID_1997, new_data$PUBID_1997)]  # Add age at first birth

###############################################################
# Descriptives
table(nlsy97$birth_year, nlsy97$mar_t0, exclude = NULL)
table(nlsy97$birth_year, nlsy97$age_birth)

table(nlsy97$birth_year, nlsy97$bw5_t0)
table(nlsy97$birth_year, nlsy97$bw5_t1)
table(nlsy97$birth_year, nlsy97$bw5_t2)
table(nlsy97$birth_year, nlsy97$bw5_t3)
table(nlsy97$birth_year, nlsy97$bw5_t4)
table(nlsy97$birth_year, nlsy97$bw5_t5)
table(nlsy97$birth_year, nlsy97$bw5_t6)
table(nlsy97$birth_year, nlsy97$bw5_m1)

table(nlsy97$age_birth, nlsy97$bw5_t0)
table(nlsy97$age_birth, nlsy97$bw5_t1)
table(nlsy97$age_birth, nlsy97$bw5_t2)
table(nlsy97$age_birth, nlsy97$bw5_t3)
table(nlsy97$age_birth, nlsy97$bw5_t4)
table(nlsy97$age_birth, nlsy97$bw5_t5)
table(nlsy97$age_birth, nlsy97$bw5_t6)
table(nlsy97$age_birth, nlsy97$bw5_m1)

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
  mutate(t0 = case_when(  (bw5_t0 == "Breadwinner" | bw5_t0 == "Not a breadwinner") &
                          (bw5_t1 == "Breadwinner" | bw5_t1 == "Not a breadwinner") &
                          (bw5_t2 == "Breadwinner" | bw5_t2 == "Not a breadwinner") ~ 1),
         t1 = case_when(  (bw5_t1 == "Breadwinner" | bw5_t1 == "Not a breadwinner") &
                          (bw5_t2 == "Breadwinner" | bw5_t2 == "Not a breadwinner") &
                          (bw5_t3 == "Breadwinner" | bw5_t3 == "Not a breadwinner") ~ 1),
         t2 = case_when(  (bw5_t2 == "Breadwinner" | bw5_t2 == "Not a breadwinner") &
                          (bw5_t3 == "Breadwinner" | bw5_t3 == "Not a breadwinner") &
                          (bw5_t4 == "Breadwinner" | bw5_t4 == "Not a breadwinner") ~ 1))

nlsy97$t0[is.na(nlsy97$t0)] <- 0
nlsy97$t1[is.na(nlsy97$t1)] <- 0
nlsy97$t2[is.na(nlsy97$t2)] <- 0

summary(nlsy97$t0)
summary(nlsy97$t1)
summary(nlsy97$t2)

nlsy97 <- nlsy97 %>%
  mutate(bw3a = case_when(  bw5_t0 == "Breadwinner" & bw5_t1 == "Breadwinner" &
                            bw5_t2 == "Breadwinner" ~ 1),
         bw3b = case_when(  bw5_t1 == "Breadwinner" & bw5_t2 == "Breadwinner" &
                            bw5_t3 == "Breadwinner" ~ 1),  
         bw3c = case_when(  bw5_t2 == "Breadwinner" & bw5_t3 == "Breadwinner" &
                            bw5_t4 == "Breadwinner" ~ 1))

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
       subtitle = "Mothers aged 18 - 30 at 1st birth",
       color = "Marital status",
       caption = "Source: National Longitudinal Survey of Youth | 1997 \n Analysis by: Joanna R. Pepin")

###################################################################
# These graphs no longer work.......... :/
#Age_birth by inc_t1 & marst
nlsy97 %>%
  filter(!is.na(mar_t0)) %>%
  ggplot(aes(age_birth, log10(inc_t0), color = mar_t0)) +
  geom_point(position = "jitter") +
  theme_minimal()

#Age_birth by totinc_t1 & marst
nlsy97 %>%
  filter(!is.na(mar_t0)) %>%
  ggplot(aes(age_birth, totinc_t0, color = mar_t0)) +
  geom_point(position = "jitter") +
  theme_minimal()

#Birth year by age_birth & breadwinner
nlsy97 %>%
  filter(!is.na(bw5_t0)) %>%
  filter(mar_t0 != "Div/Sep/Wid" & !is.na(mar_t0)) %>%
  ggplot(aes(age_birth, totinc_t0, color = bw5_t0)) +
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

