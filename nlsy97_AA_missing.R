# Address missing data
earnings <- earnings %>%
  group_by(PUBID_1997) %>% 
  mutate(momearn_t0  = case_when(birth_year1   == year ~ momearn),
         momearn_t1  = case_when(birth_year2   == year ~ momearn),
         momearn_t2  = case_when(birth_year3   == year ~ momearn),
         momearn_t3  = case_when(birth_year4   == year ~ momearn),
         momearn_t4  = case_when(birth_year5   == year ~ momearn),
         momearn_t5  = case_when(birth_year6   == year ~ momearn))


## Type of NAs
table(miss_data$wages_t0)
table(miss_data$wages_t1)
table(miss_data$wages_t2)
table(miss_data$wages_t3)
table(miss_data$wages_t4)
table(miss_data$wages_t5)

sum(is.na(miss_data$wages_t0))
sum(is.na(miss_data$wages_t1))
sum(is.na(miss_data$wages_t2))
sum(is.na(miss_data$wages_t3))
sum(is.na(miss_data$wages_t4))
sum(is.na(miss_data$wages_t5))

table(miss_data$totinc_t0)
table(miss_data$totinc_t1)
table(miss_data$totinc_t2)
table(miss_data$totinc_t3)
table(miss_data$totinc_t4)
table(miss_data$totinc_t5)

sum(is.na(miss_data$totinc_t0))
sum(is.na(miss_data$totinc_t1))
sum(is.na(miss_data$totinc_t2))
sum(is.na(miss_data$totinc_t3))
sum(is.na(miss_data$totinc_t4))
sum(is.na(miss_data$totinc_t5))

### Missing data
table(miss_data$bw_t0, exclude=NULL)
table(miss_data$bw_t1, exclude=NULL)
table(miss_data$bw_t2, exclude=NULL)
table(miss_data$bw_t3, exclude=NULL)
table(miss_data$bw_t4, exclude=NULL)
table(miss_data$bw_t5, exclude=NULL)

sum(is.na(miss_data$wages_t0))
sum(is.na(miss_data$wages_t1))
sum(is.na(miss_data$wages_t2))
sum(is.na(miss_data$wages_t3))
sum(is.na(miss_data$wages_t4))
sum(is.na(miss_data$wages_t5))

sum(is.na(miss_data$totinc_t0))
sum(is.na(miss_data$totinc_t1))
sum(is.na(miss_data$totinc_t2))
sum(is.na(miss_data$totinc_t3))
sum(is.na(miss_data$totinc_t4))
sum(is.na(miss_data$totinc_t5))


# missing inc & totinc crosstabs
test <- miss_data
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

test$totincmiss0 <- 0
test$totincmiss1 <- 0
test$totincmiss2 <- 0
test$totincmiss3 <- 0
test$totincmiss4 <- 0
test$totincmiss5 <- 0
test$totincmiss6 <- 0
test$totincmiss7 <- 0
test$totincmiss8 <- 0
test$totincmiss9 <- 0
test$totincmiss10 <- 0

test$totincmiss0[is.na(test$totinc_t0)] <- 1
test$totincmiss1[is.na(test$totinc_t1)] <- 1
test$totincmiss2[is.na(test$totinc_t2)] <- 1
test$totincmiss3[is.na(test$totinc_t3)] <- 1
test$totincmiss4[is.na(test$totinc_t4)] <- 1
test$totincmiss5[is.na(test$totinc_t5)] <- 1
test$totincmiss6[is.na(test$totinc_t6)] <- 1
test$totincmiss7[is.na(test$totinc_t7)] <- 1
test$totincmiss8[is.na(test$totinc_t8)] <- 1
test$totincmiss9[is.na(test$totinc_t9)] <- 1
test$totincmiss10[is.na(test$totinc_t10)] <- 1

table(test$incmiss0, test$totincmiss0)
table(test$incmiss1, test$totincmiss1)
table(test$incmiss2, test$totincmiss2)
table(test$incmiss3, test$totincmiss3)
table(test$incmiss4, test$totincmiss4)
table(test$incmiss5, test$totincmiss5)


## Replace type of NAs with NA
miss_data[miss_data == -1] = NA  # Refused 
miss_data[miss_data == -2] = NA  # Dont know 
miss_data[miss_data == -3] = NA  # Invalid missing 
miss_data[miss_data == -4] = NA  # Valid missing 
miss_data[miss_data == -5] = NA  # Non-interview 



