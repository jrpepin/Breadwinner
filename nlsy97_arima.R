# https://stackoverflow.com/questions/43622486/time-series-forecasting-in-r-univariate-time-series
# https://rpubs.com/riazakhan94/arima_with_example
# https://www.datascience.com/blog/introduction-to-forecasting-with-arima-in-r-learn-data-science-tutorials
arima <- earndat

count <- arima %>%
  select(PUBID_1997, starts_with("bwf5")) %>%
  gather(var, val, -PUBID_1997) %>%
  separate(var, c("level", "time"))

count$val  <- as.factor(count$val)
count$time <- as.factor(count$time)

count <- count %>% 
  group_by(time) %>%
  summarise(pct.bw = mean(val == "Breadwinner", na.rm=TRUE))

count <- count %>%
  mutate(time  = case_when(time   == "t0" ~ 0L,
                           time   == "t1" ~ 1L, 
                           time   == "t2" ~ 2L,
                           time   == "t3" ~ 3L,
                           time   == "t4" ~ 4L,
                           time   == "t5" ~ 5L,
                           time   == "t6" ~ 6L,
                           time   == "t7" ~ 7L,
                           time   == "t8" ~ 8L,
                           time   == "t9" ~ 9L,
                           time   == "t10" ~ 10L,
                           time   == "m1" ~ -1L,
                           time   == "m2" ~ -2L,
                           time   == "m3" ~ -3L,
                           time   == "m4" ~ -4L,
                           time   == "m5" ~ -5L))

#count$time <- as.Date(paste(count$time, 1, 1, sep = "-"))

library(ggplot2)
library(forecast)
library(tseries)

## trouble installing forecast and tseries: https://stackoverflow.com/questions/55872936/dependency-quadprog-is-not-available-for-installing-package-bfast

# Examine the time series
## I'm going to need to restructure the data to match this format. 
setwd("C:/Users/Joanna/Downloads/Bike-Sharing-Dataset")
daily_data = read.csv('day.csv', header=TRUE, stringsAsFactors=FALSE)

daily_data$Date = as.Date(daily_data$dteday)

ggplot(daily_data, aes(Date, cnt)) + geom_line() + scale_x_date('month')  + ylab("Daily Bike Checkouts") +
  xlab("")

ggplot(count, aes(time, pct.bw)) + geom_line() +  ylab("% Breadwinner") +  xlab("Time since first birth")

count_ts = ts(count)
arima_fit = auto.arima(count_ts[,1])

# Forecast for the next 10 time units
arima_forecast = forecast(arima_fit, h = 3)
# Plot forecasts
plot(arima_forecast)