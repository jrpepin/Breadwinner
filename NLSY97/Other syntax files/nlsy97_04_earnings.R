## Create mom's total EARNINGS variable
##  wages, mombiz, spbiz, spinc, hhinc

earnings   <- mominc
earnings   <- left_join(earnings,   mombiz)
earnings   <- left_join(earnings,   spinc)
earnings   <- left_join(earnings,   spbiz)
earnings   <- left_join(earnings,   hhinc)

earnings <- earnings %>%
  select(PUBID_1997, year, birth_year, wages, mombiz, spwages, spbiz, hhinc)

#I'm going to need to handle the missing data for all of these variables before combining them.......
earnings[earnings == -4] = 0  # Valid missing

earnings <- earnings %>%
  filter(wages != -5)         # Non-interview

earnings[is.na(earnings)] = 0 # Make missing 0 so don't drop them just because variable didn't exist that year

earnings[earnings == -3] <- NA # Invalid missing 
earnings[earnings == -2] <- NA # Dont know 
earnings[earnings == -1] <- NA # Refused 

earnings <- earnings %>%
  group_by(PUBID_1997, year) %>%  
  mutate(momearn = wages + mombiz,
         famearn = wages + mombiz + spwages + spbiz,
         hhearn  = wages + mombiz + spwages + spbiz + hhinc)

# Create the birth year plus 1 variables
earnings$birth_year1   <- earnings$birth_year + 1
earnings$birth_year2   <- earnings$birth_year + 2
earnings$birth_year3   <- earnings$birth_year + 3
earnings$birth_year4   <- earnings$birth_year + 4
earnings$birth_year5   <- earnings$birth_year + 5
earnings$birth_year6   <- earnings$birth_year + 6
earnings$birth_year7   <- earnings$birth_year + 7
earnings$birth_year8   <- earnings$birth_year + 8
earnings$birth_year9   <- earnings$birth_year + 9
earnings$birth_year10  <- earnings$birth_year + 10
earnings$birth_year11  <- earnings$birth_year + 11

earnings$birth_minus1 <- earnings$birth_year - 1
earnings$birth_minus2 <- earnings$birth_year - 2
earnings$birth_minus3 <- earnings$birth_year - 3
earnings$birth_minus4 <- earnings$birth_year - 4

# give people the earnings they reported for each of the earnings plus 1 variables
## Careful - t0 is birth year plus 1 for earnings because respondents report earnings from the previous year
earnings <- earnings %>%
  group_by(PUBID_1997) %>% 
  mutate(momearn_t0  = case_when(birth_year1   == year ~ momearn),
         momearn_t1  = case_when(birth_year2   == year ~ momearn),
         momearn_t2  = case_when(birth_year3   == year ~ momearn),
         momearn_t3  = case_when(birth_year4   == year ~ momearn),
         momearn_t4  = case_when(birth_year5   == year ~ momearn),
         momearn_t5  = case_when(birth_year6   == year ~ momearn),
         momearn_t6  = case_when(birth_year7   == year ~ momearn),
         momearn_t7  = case_when(birth_year8   == year ~ momearn),
         momearn_t8  = case_when(birth_year9   == year ~ momearn),
         momearn_t9  = case_when(birth_year10  == year ~ momearn),
         momearn_t10 = case_when(birth_year11  == year ~ momearn),
         famearn_t0  = case_when(birth_year1   == year ~ famearn),
         famearn_t1  = case_when(birth_year2   == year ~ famearn),
         famearn_t2  = case_when(birth_year3   == year ~ famearn),
         famearn_t3  = case_when(birth_year4   == year ~ famearn),
         famearn_t4  = case_when(birth_year5   == year ~ famearn),
         famearn_t5  = case_when(birth_year6   == year ~ famearn),
         famearn_t6  = case_when(birth_year7   == year ~ famearn),
         famearn_t7  = case_when(birth_year8   == year ~ famearn),
         famearn_t8  = case_when(birth_year9   == year ~ famearn),
         famearn_t9  = case_when(birth_year10  == year ~ famearn),
         famearn_t10 = case_when(birth_year11  == year ~ famearn),
         hhearn_t0   = case_when(birth_year1   == year ~ hhearn),
         hhearn_t1   = case_when(birth_year2   == year ~ hhearn),
         hhearn_t2   = case_when(birth_year3   == year ~ hhearn),
         hhearn_t3   = case_when(birth_year4   == year ~ hhearn),
         hhearn_t4   = case_when(birth_year5   == year ~ hhearn),
         hhearn_t5   = case_when(birth_year6   == year ~ hhearn),
         hhearn_t6   = case_when(birth_year7   == year ~ hhearn),
         hhearn_t7   = case_when(birth_year8   == year ~ hhearn),
         hhearn_t8   = case_when(birth_year9   == year ~ hhearn),
         hhearn_t9   = case_when(birth_year10  == year ~ hhearn),
         hhearn_t10  = case_when(birth_year11  == year ~ hhearn))

# give people the earnings they reported for each of the earnings minus 1 variables
earnings <- earnings %>%
  group_by(PUBID_1997) %>% 
  mutate(momearn_m1 = case_when(birth_year   == year ~ momearn),
         momearn_m2 = case_when(birth_minus1 == year ~ momearn),
         momearn_m3 = case_when(birth_minus2 == year ~ momearn),
         momearn_m4 = case_when(birth_minus3 == year ~ momearn),
         momearn_m5 = case_when(birth_minus4 == year ~ momearn),
         famearn_m1 = case_when(birth_year   == year ~ famearn),
         famearn_m2 = case_when(birth_minus1 == year ~ famearn),
         famearn_m3 = case_when(birth_minus2 == year ~ famearn),
         famearn_m4 = case_when(birth_minus3 == year ~ famearn),
         famearn_m5 = case_when(birth_minus4 == year ~ famearn),
         hhearn_m1  = case_when(birth_year   == year ~ hhearn),
         hhearn_m2  = case_when(birth_minus1 == year ~ hhearn),
         hhearn_m3  = case_when(birth_minus2 == year ~ hhearn),
         hhearn_m4  = case_when(birth_minus3 == year ~ hhearn),
         hhearn_m5  = case_when(birth_minus4 == year ~ hhearn))

# aggregate the data so there is 1 row per person
earnings <- earnings %>%
  group_by(PUBID_1997) %>% 
  summarise_at(c("momearn_t0", "momearn_t1", "momearn_t2", "momearn_t3", "momearn_t4", "momearn_t5", 
                 "momearn_t6", "momearn_t7", "momearn_t8", "momearn_t9", "momearn_t10",
                 "momearn_m1", "momearn_m2", "momearn_m3", "momearn_m4", "momearn_m5",
                 "famearn_t0", "famearn_t1", "famearn_t2", "famearn_t3", "famearn_t4", "famearn_t5", 
                 "famearn_t6", "famearn_t7", "famearn_t8", "famearn_t9", "famearn_t10",
                 "famearn_m1", "famearn_m2", "famearn_m3", "famearn_m4", "famearn_m5",
                 "hhearn_t0",  "hhearn_t1",  "hhearn_t2",  "hhearn_t3",  "hhearn_t4",  "hhearn_t5", 
                 "hhearn_t6",  "hhearn_t7",  "hhearn_t8",  "hhearn_t9",  "hhearn_t10",
                 "hhearn_m1",  "hhearn_m2",  "hhearn_m3",  "hhearn_m4",  "hhearn_m5"), mean, na.rm = TRUE)

## replace the NaN with NA to address the missing
earnings$momearn_t0[is.nan(earnings$momearn_t0)] <- NA
earnings$momearn_t1[is.nan(earnings$momearn_t1)] <- NA
earnings$momearn_t2[is.nan(earnings$momearn_t2)] <- NA
earnings$momearn_t3[is.nan(earnings$momearn_t3)] <- NA
earnings$momearn_t4[is.nan(earnings$momearn_t4)] <- NA
earnings$momearn_t5[is.nan(earnings$momearn_t5)] <- NA
earnings$momearn_t6[is.nan(earnings$momearn_t6)] <- NA
earnings$momearn_t7[is.nan(earnings$momearn_t7)] <- NA
earnings$momearn_t8[is.nan(earnings$momearn_t8)] <- NA
earnings$momearn_t9[is.nan(earnings$momearn_t9)] <- NA
earnings$momearn_t10[is.nan(earnings$momearn_t10)] <- NA

earnings$famearn_t0[is.nan(earnings$famearn_t0)] <- NA
earnings$famearn_t1[is.nan(earnings$famearn_t1)] <- NA
earnings$famearn_t2[is.nan(earnings$famearn_t2)] <- NA
earnings$famearn_t3[is.nan(earnings$famearn_t3)] <- NA
earnings$famearn_t4[is.nan(earnings$famearn_t4)] <- NA
earnings$famearn_t5[is.nan(earnings$famearn_t5)] <- NA
earnings$famearn_t6[is.nan(earnings$famearn_t6)] <- NA
earnings$famearn_t7[is.nan(earnings$famearn_t7)] <- NA
earnings$famearn_t8[is.nan(earnings$famearn_t8)] <- NA
earnings$famearn_t9[is.nan(earnings$famearn_t9)] <- NA
earnings$famearn_t10[is.nan(earnings$famearn_t10)] <- NA

earnings$hhearn_t0[is.nan(earnings$hhearn_t0)] <- NA
earnings$hhearn_t1[is.nan(earnings$hhearn_t1)] <- NA
earnings$hhearn_t2[is.nan(earnings$hhearn_t2)] <- NA
earnings$hhearn_t3[is.nan(earnings$hhearn_t3)] <- NA
earnings$hhearn_t4[is.nan(earnings$hhearn_t4)] <- NA
earnings$hhearn_t5[is.nan(earnings$hhearn_t5)] <- NA
earnings$hhearn_t6[is.nan(earnings$hhearn_t6)] <- NA
earnings$hhearn_t7[is.nan(earnings$hhearn_t7)] <- NA
earnings$hhearn_t8[is.nan(earnings$hhearn_t8)] <- NA
earnings$hhearn_t9[is.nan(earnings$hhearn_t9)] <- NA
earnings$hhearn_t10[is.nan(earnings$hhearn_t10)] <- NA

earnings$momearn_m1[is.nan(earnings$momearn_m1)] <- NA
earnings$momearn_m2[is.nan(earnings$momearn_m2)] <- NA
earnings$momearn_m3[is.nan(earnings$momearn_m3)] <- NA
earnings$momearn_m4[is.nan(earnings$momearn_m4)] <- NA
earnings$momearn_m5[is.nan(earnings$momearn_m5)] <- NA

earnings$famearn_m1[is.nan(earnings$famearn_m1)] <- NA
earnings$famearn_m2[is.nan(earnings$famearn_m2)] <- NA
earnings$famearn_m3[is.nan(earnings$famearn_m3)] <- NA
earnings$famearn_m4[is.nan(earnings$famearn_m4)] <- NA
earnings$famearn_m5[is.nan(earnings$famearn_m5)] <- NA

earnings$hhearn_m1[is.nan(earnings$hhearn_m1)] <- NA
earnings$hhearn_m2[is.nan(earnings$hhearn_m2)] <- NA
earnings$hhearn_m3[is.nan(earnings$hhearn_m3)] <- NA
earnings$hhearn_m4[is.nan(earnings$hhearn_m4)] <- NA
earnings$hhearn_m5[is.nan(earnings$hhearn_m5)] <- NA

# Data 
earndat   <- left_join(new_data,   earnings)

earndat <- earndat %>%
  filter(!is.na(birth_year)) # limit to mothers

# earndat <- earndat %>%
 # filter(age_birth >= 18 & age_birth <==27) # limit to mothers 18 - 27 at first birth

which( colnames(earndat)=="dob" )
which( colnames(earndat)=="hhearn_m5" )

earndat <- earndat %>%
  select(1, 741:830) # This needs to be updated each time new variables are added/created.

## Replace type of NAs with NA
earndat[earndat == -1] = NA  # Refused 
earndat[earndat == -2] = NA  # Dont know 
earndat[earndat == -3] = NA  # Invalid missing 
earndat[earndat == -4] = NA  # Valid missing 
earndat[earndat == -5] = NA  # Non-interview

# FAMILY BREADWINNER 50%
earndat <- earndat %>%
  mutate(
    bwf5_t0 = case_when(
      (earndat$momearn_t0/earndat$famearn_t0) >  .5 ~ "Breadwinner",
      (earndat$momearn_t0/earndat$famearn_t0) <= .5 ~ "Not a breadwinner",
      TRUE                                          ~  NA_character_),
    bwf5_t1 = case_when(
      (earndat$momearn_t1/earndat$famearn_t1) >  .5 ~ "Breadwinner",
      (earndat$momearn_t1/earndat$famearn_t1) <= .5 ~ "Not a breadwinner",
      TRUE                                          ~  NA_character_),
    bwf5_t2 = case_when(
      (earndat$momearn_t2/earndat$famearn_t2) >  .5 ~ "Breadwinner",
      (earndat$momearn_t2/earndat$famearn_t2) <= .5 ~ "Not a breadwinner",
      TRUE                                          ~  NA_character_),
    bwf5_t3 = case_when(
      (earndat$momearn_t3/earndat$famearn_t3) >  .5 ~ "Breadwinner",
      (earndat$momearn_t3/earndat$famearn_t3) <= .5 ~ "Not a breadwinner",
      TRUE                                          ~  NA_character_),
    bwf5_t4 = case_when(
      (earndat$momearn_t4/earndat$famearn_t4) >  .5 ~ "Breadwinner",
      (earndat$momearn_t4/earndat$famearn_t4) <= .5 ~ "Not a breadwinner",
      TRUE                                          ~  NA_character_),
    bwf5_t5 = case_when(
      (earndat$momearn_t5/earndat$famearn_t5) >  .5 ~ "Breadwinner",
      (earndat$momearn_t5/earndat$famearn_t5) <= .5 ~ "Not a breadwinner",
      TRUE                                          ~  NA_character_),
    bwf5_t6 = case_when(
      (earndat$momearn_t6/earndat$famearn_t6) >  .5 ~ "Breadwinner",
      (earndat$momearn_t6/earndat$famearn_t6) <= .5 ~ "Not a breadwinner",
      TRUE                                          ~  NA_character_),
    bwf5_t7 = case_when(
      (earndat$momearn_t7/earndat$famearn_t7) >  .5 ~ "Breadwinner",
      (earndat$momearn_t7/earndat$famearn_t7) <= .5 ~ "Not a breadwinner",
      TRUE                                          ~  NA_character_),
    bwf5_t8 = case_when(
      (earndat$momearn_t8/earndat$famearn_t8) >  .5 ~ "Breadwinner",
      (earndat$momearn_t8/earndat$famearn_t8) <= .5 ~ "Not a breadwinner",
      TRUE                                          ~  NA_character_),
    bwf5_t9 = case_when(
      (earndat$momearn_t9/earndat$famearn_t9) >  .5 ~ "Breadwinner",
      (earndat$momearn_t9/earndat$famearn_t9) <= .5 ~ "Not a breadwinner",
      TRUE                                          ~  NA_character_),
    bwf5_t10 = case_when(
      (earndat$momearn_t10/earndat$famearn_t10) >  .5 ~ "Breadwinner",
      (earndat$momearn_t10/earndat$famearn_t10) <= .5 ~ "Not a breadwinner",
      TRUE                                            ~  NA_character_))

earndat$bwf5_t0 <- factor(earndat$bwf5_t0, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwf5_t1 <- factor(earndat$bwf5_t1, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwf5_t2 <- factor(earndat$bwf5_t2, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwf5_t3 <- factor(earndat$bwf5_t3, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwf5_t4 <- factor(earndat$bwf5_t4, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwf5_t5 <- factor(earndat$bwf5_t5, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwf5_t6 <- factor(earndat$bwf5_t6, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwf5_t7 <- factor(earndat$bwf5_t7, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwf5_t8 <- factor(earndat$bwf5_t8, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwf5_t9 <- factor(earndat$bwf5_t9, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwf5_t10 <- factor(earndat$bwf5_t10, levels = c("Breadwinner", "Not a breadwinner"))


earndat <- earndat %>%
  mutate(
    bwf5_m1 = case_when(
      (earndat$momearn_m1/earndat$famearn_m1) >  .5 ~ "Breadwinner",
      (earndat$momearn_m1/earndat$famearn_m1) <= .5 ~ "Not a breadwinner",
      TRUE                                          ~  NA_character_),
    bwf5_m2 = case_when(
      (earndat$momearn_m2/earndat$famearn_m2) >  .5 ~ "Breadwinner",
      (earndat$momearn_m2/earndat$famearn_m2) <= .5 ~ "Not a breadwinner",
      TRUE                                          ~  NA_character_),
    bwf5_m3 = case_when(
      (earndat$momearn_m3/earndat$famearn_m3) >  .5 ~ "Breadwinner",
      (earndat$momearn_m3/earndat$famearn_m3) <= .5 ~ "Not a breadwinner",
      TRUE                                          ~  NA_character_),
    bwf5_m4 = case_when(
      (earndat$momearn_m4/earndat$famearn_m4) >  .5 ~ "Breadwinner",
      (earndat$momearn_m4/earndat$famearn_m4) <= .5 ~ "Not a breadwinner",
      TRUE                                          ~  NA_character_),
    bwf5_m5 = case_when(
      (earndat$momearn_m5/earndat$famearn_m5) >  .5 ~ "Breadwinner",
      (earndat$momearn_m5/earndat$famearn_m5) <= .5 ~ "Not a breadwinner",
      TRUE                                          ~  NA_character_))

earndat$bwf5_m1 <- factor(earndat$bwf5_m1, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwf5_m2 <- factor(earndat$bwf5_m2, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwf5_m3 <- factor(earndat$bwf5_m3, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwf5_m4 <- factor(earndat$bwf5_m4, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwf5_m5 <- factor(earndat$bwf5_m5, levels = c("Breadwinner", "Not a breadwinner"))


# FAMILY BREADWINNER 60%
earndat <- earndat %>%
  mutate(
    bwf6_t0 = case_when(
      (earndat$momearn_t0/earndat$famearn_t0) >  .6 ~ "Breadwinner",
      (earndat$momearn_t0/earndat$famearn_t0) <= .6 ~ "Not a breadwinner",
      TRUE                                          ~  NA_character_),
    bwf6_t1 = case_when(
      (earndat$momearn_t1/earndat$famearn_t1) >  .6 ~ "Breadwinner",
      (earndat$momearn_t1/earndat$famearn_t1) <= .6 ~ "Not a breadwinner",
      TRUE                                          ~  NA_character_),
    bwf6_t2 = case_when(
      (earndat$momearn_t2/earndat$famearn_t2) >  .6 ~ "Breadwinner",
      (earndat$momearn_t2/earndat$famearn_t2) <= .6 ~ "Not a breadwinner",
      TRUE                                          ~  NA_character_),
    bwf6_t3 = case_when(
      (earndat$momearn_t3/earndat$famearn_t3) >  .6 ~ "Breadwinner",
      (earndat$momearn_t3/earndat$famearn_t3) <= .6 ~ "Not a breadwinner",
      TRUE                                          ~  NA_character_),
    bwf6_t4 = case_when(
      (earndat$momearn_t4/earndat$famearn_t4) >  .6 ~ "Breadwinner",
      (earndat$momearn_t4/earndat$famearn_t4) <= .6 ~ "Not a breadwinner",
      TRUE                                          ~  NA_character_),
    bwf6_t5 = case_when(
      (earndat$momearn_t5/earndat$famearn_t5) >  .6 ~ "Breadwinner",
      (earndat$momearn_t5/earndat$famearn_t5) <= .6 ~ "Not a breadwinner",
      TRUE                                          ~  NA_character_),
    bwf6_t6 = case_when(
      (earndat$momearn_t6/earndat$famearn_t6) >  .6 ~ "Breadwinner",
      (earndat$momearn_t6/earndat$famearn_t6) <= .6 ~ "Not a breadwinner",
      TRUE                                          ~  NA_character_),
    bwf6_t7 = case_when(
      (earndat$momearn_t7/earndat$famearn_t7) >  .6 ~ "Breadwinner",
      (earndat$momearn_t7/earndat$famearn_t7) <= .6 ~ "Not a breadwinner",
      TRUE                                          ~  NA_character_),
    bwf6_t8 = case_when(
      (earndat$momearn_t8/earndat$famearn_t8) >  .6 ~ "Breadwinner",
      (earndat$momearn_t8/earndat$famearn_t8) <= .6 ~ "Not a breadwinner",
      TRUE                                          ~  NA_character_),
    bwf6_t9 = case_when(
      (earndat$momearn_t9/earndat$famearn_t9) >  .6 ~ "Breadwinner",
      (earndat$momearn_t9/earndat$famearn_t9) <= .6 ~ "Not a breadwinner",
      TRUE                                          ~  NA_character_),
    bwf6_t10 = case_when(
      (earndat$momearn_t10/earndat$famearn_t10) >  .6 ~ "Breadwinner",
      (earndat$momearn_t10/earndat$famearn_t10) <= .6 ~ "Not a breadwinner",
      TRUE                                            ~  NA_character_))

earndat$bwf6_t0 <- factor(earndat$bwf6_t0, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwf6_t1 <- factor(earndat$bwf6_t1, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwf6_t2 <- factor(earndat$bwf6_t2, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwf6_t3 <- factor(earndat$bwf6_t3, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwf6_t4 <- factor(earndat$bwf6_t4, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwf6_t5 <- factor(earndat$bwf6_t5, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwf6_t6 <- factor(earndat$bwf6_t6, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwf6_t7 <- factor(earndat$bwf6_t7, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwf6_t8 <- factor(earndat$bwf6_t8, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwf6_t9 <- factor(earndat$bwf6_t9, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwf6_t10 <- factor(earndat$bwf6_t10, levels = c("Breadwinner", "Not a breadwinner"))


earndat <- earndat %>%
  mutate(
    bwf6_m1 = case_when(
      (earndat$momearn_m1/earndat$famearn_m1) >  .6 ~ "Breadwinner",
      (earndat$momearn_m1/earndat$famearn_m1) <= .6 ~ "Not a breadwinner",
      TRUE                                          ~  NA_character_),
    bwf6_m2 = case_when(
      (earndat$momearn_m2/earndat$famearn_m2) >  .6 ~ "Breadwinner",
      (earndat$momearn_m2/earndat$famearn_m2) <= .6 ~ "Not a breadwinner",
      TRUE                                          ~  NA_character_),
    bwf6_m3 = case_when(
      (earndat$momearn_m3/earndat$famearn_m3) >  .6 ~ "Breadwinner",
      (earndat$momearn_m3/earndat$famearn_m3) <= .6 ~ "Not a breadwinner",
      TRUE                                          ~  NA_character_),
    bwf6_m4 = case_when(
      (earndat$momearn_m4/earndat$famearn_m4) >  .6 ~ "Breadwinner",
      (earndat$momearn_m4/earndat$famearn_m4) <= .6 ~ "Not a breadwinner",
      TRUE                                          ~  NA_character_),
    bwf6_m5 = case_when(
      (earndat$momearn_m5/earndat$famearn_m5) >  .6 ~ "Breadwinner",
      (earndat$momearn_m5/earndat$famearn_m5) <= .6 ~ "Not a breadwinner",
      TRUE                                          ~  NA_character_))

earndat$bwf6_m1 <- factor(earndat$bwf6_m1, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwf6_m2 <- factor(earndat$bwf6_m2, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwf6_m3 <- factor(earndat$bwf6_m3, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwf6_m4 <- factor(earndat$bwf6_m4, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwf6_m5 <- factor(earndat$bwf6_m5, levels = c("Breadwinner", "Not a breadwinner"))

# HOUSEHOLD BREADWINNER 50%
earndat <- earndat %>%
  mutate(
    bwh5_t0 = case_when(
      (earndat$momearn_t0/earndat$hhearn_t0) >  .5 ~ "Breadwinner",
      (earndat$momearn_t0/earndat$hhearn_t0) <= .5 ~ "Not a breadwinner",
      TRUE                                         ~  NA_character_),
    bwh5_t1 = case_when(
      (earndat$momearn_t1/earndat$hhearn_t1) >  .5 ~ "Breadwinner",
      (earndat$momearn_t1/earndat$hhearn_t1) <= .5 ~ "Not a breadwinner",
      TRUE                                         ~  NA_character_),
    bwh5_t2 = case_when(
      (earndat$momearn_t2/earndat$hhearn_t2) >  .5 ~ "Breadwinner",
      (earndat$momearn_t2/earndat$hhearn_t2) <= .5 ~ "Not a breadwinner",
      TRUE                                         ~  NA_character_),
    bwh5_t3 = case_when(
      (earndat$momearn_t3/earndat$hhearn_t3) >  .5 ~ "Breadwinner",
      (earndat$momearn_t3/earndat$hhearn_t3) <= .5 ~ "Not a breadwinner",
      TRUE                                         ~  NA_character_),
    bwh5_t4 = case_when(
      (earndat$momearn_t4/earndat$hhearn_t4) >  .5 ~ "Breadwinner",
      (earndat$momearn_t4/earndat$hhearn_t4) <= .5 ~ "Not a breadwinner",
      TRUE                                         ~  NA_character_),
    bwh5_t5 = case_when(
      (earndat$momearn_t5/earndat$hhearn_t5) >  .5 ~ "Breadwinner",
      (earndat$momearn_t5/earndat$hhearn_t5) <= .5 ~ "Not a breadwinner",
      TRUE                                         ~  NA_character_),
    bwh5_t6 = case_when(
      (earndat$momearn_t6/earndat$hhearn_t6) >  .5 ~ "Breadwinner",
      (earndat$momearn_t6/earndat$hhearn_t6) <= .5 ~ "Not a breadwinner",
      TRUE                                         ~  NA_character_),
    bwh5_t7 = case_when(
      (earndat$momearn_t7/earndat$hhearn_t7) >  .5 ~ "Breadwinner",
      (earndat$momearn_t7/earndat$hhearn_t7) <= .5 ~ "Not a breadwinner",
      TRUE                                         ~  NA_character_),
    bwh5_t8 = case_when(
      (earndat$momearn_t8/earndat$hhearn_t8) >  .5 ~ "Breadwinner",
      (earndat$momearn_t8/earndat$hhearn_t8) <= .5 ~ "Not a breadwinner",
      TRUE                                         ~  NA_character_),
    bwh5_t9 = case_when(
      (earndat$momearn_t9/earndat$hhearn_t9) >  .5 ~ "Breadwinner",
      (earndat$momearn_t9/earndat$hhearn_t9) <= .5 ~ "Not a breadwinner",
      TRUE                                         ~  NA_character_),
    bwh5_t10 = case_when(
      (earndat$momearn_t10/earndat$hhearn_t10) >  .5 ~ "Breadwinner",
      (earndat$momearn_t10/earndat$hhearn_t10) <= .5 ~ "Not a breadwinner",
      TRUE                                           ~  NA_character_))

earndat$bwh5_t0 <- factor(earndat$bwh5_t0, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwh5_t1 <- factor(earndat$bwh5_t1, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwh5_t2 <- factor(earndat$bwh5_t2, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwh5_t3 <- factor(earndat$bwh5_t3, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwh5_t4 <- factor(earndat$bwh5_t4, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwh5_t5 <- factor(earndat$bwh5_t5, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwh5_t6 <- factor(earndat$bwh5_t6, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwh5_t7 <- factor(earndat$bwh5_t7, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwh5_t8 <- factor(earndat$bwh5_t8, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwh5_t9 <- factor(earndat$bwh5_t9, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwh5_t10 <- factor(earndat$bwh5_t10, levels = c("Breadwinner", "Not a breadwinner"))


earndat <- earndat %>%
  mutate(
    bwh5_m1 = case_when(
      (earndat$momearn_m1/earndat$hhearn_m1) >  .5 ~ "Breadwinner",
      (earndat$momearn_m1/earndat$hhearn_m1) <= .5 ~ "Not a breadwinner",
      TRUE                                         ~  NA_character_),
    bwh5_m2 = case_when(
      (earndat$momearn_m2/earndat$hhearn_m2) >  .5 ~ "Breadwinner",
      (earndat$momearn_m2/earndat$hhearn_m2) <= .5 ~ "Not a breadwinner",
      TRUE                                         ~  NA_character_),
    bwh5_m3 = case_when(
      (earndat$momearn_m3/earndat$hhearn_m3) >  .5 ~ "Breadwinner",
      (earndat$momearn_m3/earndat$hhearn_m3) <= .5 ~ "Not a breadwinner",
      TRUE                                         ~  NA_character_),
    bwh5_m4 = case_when(
      (earndat$momearn_m4/earndat$hhearn_m4) >  .5 ~ "Breadwinner",
      (earndat$momearn_m4/earndat$hhearn_m4) <= .5 ~ "Not a breadwinner",
      TRUE                                         ~  NA_character_),
    bwh5_m5 = case_when(
      (earndat$hhearn_m5/earndat$momearn_m5) >  .5 ~ "Breadwinner",
      (earndat$hhearn_m5/earndat$momearn_m5) <= .5 ~ "Not a breadwinner",
      TRUE                                         ~  NA_character_))

earndat$bwh5_m1 <- factor(earndat$bwh5_m1, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwh5_m2 <- factor(earndat$bwh5_m2, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwh5_m3 <- factor(earndat$bwh5_m3, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwh5_m4 <- factor(earndat$bwh5_m4, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwh5_m5 <- factor(earndat$bwh5_m5, levels = c("Breadwinner", "Not a breadwinner"))


# HOUSEHOLD BREADWINNER 60%
earndat <- earndat %>%
  mutate(
    bwh6_t0 = case_when(
      (earndat$momearn_t0/earndat$hhearn_t0) >  .6 ~ "Breadwinner",
      (earndat$momearn_t0/earndat$hhearn_t0) <= .6 ~ "Not a breadwinner",
      TRUE                                         ~  NA_character_),
    bwh6_t1 = case_when(
      (earndat$momearn_t1/earndat$hhearn_t1) >  .6 ~ "Breadwinner",
      (earndat$momearn_t1/earndat$hhearn_t1) <= .6 ~ "Not a breadwinner",
      TRUE                                         ~  NA_character_),
    bwh6_t2 = case_when(
      (earndat$momearn_t2/earndat$hhearn_t2) >  .6 ~ "Breadwinner",
      (earndat$momearn_t2/earndat$hhearn_t2) <= .6 ~ "Not a breadwinner",
      TRUE                                         ~  NA_character_),
    bwh6_t3 = case_when(
      (earndat$momearn_t3/earndat$hhearn_t3) >  .6 ~ "Breadwinner",
      (earndat$momearn_t3/earndat$hhearn_t3) <= .6 ~ "Not a breadwinner",
      TRUE                                         ~  NA_character_),
    bwh6_t4 = case_when(
      (earndat$momearn_t4/earndat$hhearn_t4) >  .6 ~ "Breadwinner",
      (earndat$momearn_t4/earndat$hhearn_t4) <= .6 ~ "Not a breadwinner",
      TRUE                                         ~  NA_character_),
    bwh6_t5 = case_when(
      (earndat$momearn_t5/earndat$hhearn_t5) >  .6 ~ "Breadwinner",
      (earndat$momearn_t5/earndat$hhearn_t5) <= .6 ~ "Not a breadwinner",
      TRUE                                         ~  NA_character_),
    bwh6_t6 = case_when(
      (earndat$momearn_t6/earndat$hhearn_t6) >  .6 ~ "Breadwinner",
      (earndat$momearn_t6/earndat$hhearn_t6) <= .6 ~ "Not a breadwinner",
      TRUE                                         ~  NA_character_),
    bwh6_t7 = case_when(
      (earndat$momearn_t7/earndat$hhearn_t7) >  .6 ~ "Breadwinner",
      (earndat$momearn_t7/earndat$hhearn_t7) <= .6 ~ "Not a breadwinner",
      TRUE                                         ~  NA_character_),
    bwh6_t8 = case_when(
      (earndat$momearn_t8/earndat$hhearn_t8) >  .6 ~ "Breadwinner",
      (earndat$momearn_t8/earndat$hhearn_t8) <= .6 ~ "Not a breadwinner",
      TRUE                                         ~  NA_character_),
    bwh6_t9 = case_when(
      (earndat$momearn_t9/earndat$hhearn_t9) >  .6 ~ "Breadwinner",
      (earndat$momearn_t9/earndat$hhearn_t9) <= .6 ~ "Not a breadwinner",
      TRUE                                         ~  NA_character_),
    bwh6_t10 = case_when(
      (earndat$momearn_t10/earndat$hhearn_t10) >  .6 ~ "Breadwinner",
      (earndat$momearn_t10/earndat$hhearn_t10) <= .6 ~ "Not a breadwinner",
      TRUE                                           ~  NA_character_)
  )
earndat$bwh6_t0  <- factor(earndat$bwh6_t0,  levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwh6_t1  <- factor(earndat$bwh6_t1,  levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwh6_t2  <- factor(earndat$bwh6_t2,  levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwh6_t3  <- factor(earndat$bwh6_t3,  levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwh6_t4  <- factor(earndat$bwh6_t4,  levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwh6_t5  <- factor(earndat$bwh6_t5,  levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwh6_t6  <- factor(earndat$bwh6_t6,  levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwh6_t7  <- factor(earndat$bwh6_t7,  levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwh6_t8  <- factor(earndat$bwh6_t8,  levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwh6_t9  <- factor(earndat$bwh6_t9,  levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwh6_t10 <- factor(earndat$bwh6_t10, levels = c("Breadwinner", "Not a breadwinner"))


earndat <- earndat %>%
  mutate(
    bwh6_m1 = case_when(
      (earndat$momearn_m1/earndat$hhearn_m1) >  .6 ~ "Breadwinner",
      (earndat$momearn_m1/earndat$hhearn_m1) <= .6 ~ "Not a breadwinner",
      TRUE                                         ~  NA_character_),
    bwh6_m2 = case_when(
      (earndat$momearn_m2/earndat$hhearn_m2) >  .6 ~ "Breadwinner",
      (earndat$momearn_m2/earndat$hhearn_m2) <= .6 ~ "Not a breadwinner",
      TRUE                                         ~  NA_character_),
    bwh6_m3 = case_when(
      (earndat$momearn_m3/earndat$hhearn_m3) >  .6 ~ "Breadwinner",
      (earndat$momearn_m3/earndat$hhearn_m3) <= .6 ~ "Not a breadwinner",
      TRUE                                         ~  NA_character_),
    bwh6_m4 = case_when(
      (earndat$momearn_m4/earndat$hhearn_m4) >  .6 ~ "Breadwinner",
      (earndat$momearn_m4/earndat$hhearn_m4) <= .6 ~ "Not a breadwinner",
      TRUE                                         ~  NA_character_),
    bwh6_m5 = case_when(
      (earndat$momearn_m5/earndat$hhearn_m5) >  .6 ~ "Breadwinner",
      (earndat$momearn_m5/earndat$hhearn_m5) <= .6 ~ "Not a breadwinner",
      TRUE                                         ~  NA_character_))

earndat$bwh6_m1 <- factor(earndat$bwh6_m1, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwh6_m2 <- factor(earndat$bwh6_m2, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwh6_m3 <- factor(earndat$bwh6_m3, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwh6_m4 <- factor(earndat$bwh6_m4, levels = c("Breadwinner", "Not a breadwinner"))
earndat$bwh6_m5 <- factor(earndat$bwh6_m5, levels = c("Breadwinner", "Not a breadwinner"))


table(earndat$bwf5_t0)
table(earndat$bwf5_t1)
table(earndat$bwf5_t2)
table(earndat$bwf5_t3)
table(earndat$bwf5_t4)
table(earndat$bwf5_t5)
table(earndat$bwf5_t6)
table(earndat$bwf5_t7)
table(earndat$bwf5_t8)
table(earndat$bwf5_t9)
table(earndat$bwf5_t10)

table(earndat$bwf5_m1)
table(earndat$bwf5_m2)
table(earndat$bwf5_m3)
table(earndat$bwf5_m4)
table(earndat$bwf5_m5)


table(earndat$bwf6_t0)
table(earndat$bwf6_t1)
table(earndat$bwf6_t2)
table(earndat$bwf6_t3)
table(earndat$bwf6_t4)
table(earndat$bwf6_t5)
table(earndat$bwf6_t6)
table(earndat$bwf6_t7)
table(earndat$bwf6_t8)
table(earndat$bwf6_t9)
table(earndat$bwf6_t10)


table(earndat$bwh5_t0)
table(earndat$bwh5_t1)
table(earndat$bwh5_t2)
table(earndat$bwh5_t3)
table(earndat$bwh5_t4)
table(earndat$bwh5_t5)
table(earndat$bwh5_t6)
table(earndat$bwh5_t7)
table(earndat$bwh5_t8)
table(earndat$bwh5_t9)
table(earndat$bwh5_t10)

table(earndat$bwh6_t0)
table(earndat$bwh6_t1)
table(earndat$bwh6_t2)
table(earndat$bwh6_t3)
table(earndat$bwh6_t4)
table(earndat$bwh6_t5)
table(earndat$bwh6_t6)
table(earndat$bwh6_t7)
table(earndat$bwh6_t8)
table(earndat$bwh6_t9)
table(earndat$bwh6_t10)
