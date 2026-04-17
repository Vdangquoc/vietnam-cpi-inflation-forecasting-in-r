

## 1.Context & motivation
## This project studies Vietnam’s annual CPI inflation. 
# Inflation is important because it affects purchasing power, financial planning, and the general economic environment.

#### 2. Dataset description
#### The dataset used in this project is Vietnam’s annual consumer price inflation from FRED. 
###  The data are measured as percent change. Only historical observations from 1995 to 2024 were used.

#### 3. Modelling choices
##### In this project, I used ARIMA and ETS to forecast inflation. These are common time-series forecasting models 
#### I compared them to see which model gives better forecasting accuracy.

#### 4. Results 
####Based on the test-set results, ETS performed better than ARIMA.
####ETS had lower RMSE and MAE values, so it was selected as the final model.

##### 5. Business
#### The forecast suggests that inflation may remain relatively stable in the next five years.
#### This can be useful for financial planning and understanding the future price environment.

##### 6.limitations
#### One limitation of this project is that the data are annual, so the number of observations is limited. 
### Also, ARIMA and ETS only use past values, so they may not fully capture policy changes or unexpected economic shocks.





rm(list = ls())

##### 1. LOACD libraries####
library(quantmod)
library(readr)
library(forecast)
library(Metrics)
library(tseries)
library(ggplot2)

####### 2. IMPORT DATA FROM FRED#######

getSymbols("VNMPCPIPCPPPT",src="FRED")
cpi_data<- data.frame(DATE = index(VNMPCPIPCPPPT),
				CPI= as.numeric(VNMPCPIPCPPPT[,1]))
cpi_data<- subset(cpi_data,
			DATE >= as.Date("1995-01-01")&
			DATE <= as.Date("2024-01-01"))

#### CLEAN DATA ####
cpi_data <- na.omit(cpi_data)

## CHECK DUPLICATES##
print("Number of duplicated dates:")
print(sum(duplicated(cpi_data$DATE)))

## CHECK STRUCTURE ##
print("Structure of cleaned data:")
str(cpi_data)
print("Summary of cleaned data")
summary(cpi_data)
head(cpi_data)
tail(cpi_data)

# 5. CONVERT TO TIME SERIES
############################
cpi_ts <- ts(cpi_data$CPI, start = 1995, frequency = 1)

print("Length of time series:")
print(length(cpi_ts))

print("Start and end of time series:")
print(start(cpi_ts))
print(end(cpi_ts))

# 6. PLOT THE SERIES
############################
plot(cpi_ts,
     main = "Vietnam Consumer Price Inflation",
     ylab = "Percent Change",
     xlab = "Year",
     type = "o")

grid()
abline(h = mean(cpi_ts), col = "blue", lty = 2)

# 7. EXPLORATORY DATA ANALYSIS
############################
print("Mean CPI inflation:")
print(mean(cpi_ts))

print("Standard deviation of CPI inflation:")
print(sd(cpi_ts))

print("Minimum CPI inflation:")
print(min(cpi_ts))

print("Maximum CPI inflation:")
print(max(cpi_ts))

# KPSS test on original series
print("KPSS test on original series:")
print(kpss.test(cpi_ts))

# First difference
diff_cpi <- diff(cpi_ts)

plot(diff_cpi,
     main = "Differenced Vietnam CPI Inflation",
     ylab = "Differenced Inflation",
     xlab = "Year",
     type = "o")

grid()

# 7. EXPLORATORY DATA ANALYSIS
############################
print("Mean CPI inflation:")
print(mean(cpi_ts))

print("Standard deviation of CPI inflation:")
print(sd(cpi_ts))

print("Minimum CPI inflation:")
print(min(cpi_ts))

print("Maximum CPI inflation:")
print(max(cpi_ts))


# KPSS test on original series
print("KPSS test on original series:")
print(kpss.test(cpi_ts))

# First difference
diff_cpi <- diff(cpi_ts)

plot(diff_cpi,
     main = "Differenced Vietnam CPI Inflation",
     ylab = "Differenced Inflation",
     xlab = "Year",
     type = "o")

grid()

print("KPSS test on differenced series:")
print(kpss.test(diff_cpi))

# ACF and PACF
acf(cpi_ts, main = "ACF of Vietnam CPI Inflation")
pacf(cpi_ts, main = "PACF of Vietnam CPI Inflation")

acf(diff_cpi, main = "ACF of Differenced CPI")
pacf(diff_cpi, main = "PACF of Differenced CPI")


####### 8. TRAIN-TEST SPLIT ######

n <- length(cpi_ts)
tr_end <- round(0.8 * n)

train <- cpi_ts[1:tr_end]
test  <- cpi_ts[-(1:tr_end)]

print("Training observations:")
print(length(train))

print("Test observations:")
print(length(test))

print("Training data:")
print(train)

print("Test data:")
print(test)

###### 9. ARIMA MODEL #####
arima_model <- auto.arima(train)
print("ARIMA model summary:")
summary(arima_model)

arima_fc <- forecast(arima_model, h = length(test))

plot(train,
     xlim = c(start(train)[1], end(test)[1]),
     ylim = range(c(train, test, arima_fc$mean)),
     main = "ARIMA Forecast vs Actual",
     ylab = "Percent Change",
     xlab = "Year",
     type = "o")

lines(test, col = "red", type = "o")
lines(arima_fc$mean, col = "blue", type = "o")

legend("topright",
       legend = c("Train", "Actual Test", "Forecast"),
       col = c("black", "red", "blue"),
       lty = 1,
       pch = 1)

######## 10. ETS MODEL#######
ets_model <- ets(train)
print("ETS model summary:")
summary(ets_model)

ets_fc <- forecast(ets_model, h = length(test))

plot(train,
     xlim = c(start(train)[1], end(test)[1]),
     ylim = range(c(train, test, ets_fc$mean)),
     main = "ETS Forecast vs Actual",
     ylab = "Percent Change",
     xlab = "Year",
     type = "o")

lines(test, col = "red", type = "o")
lines(ets_fc$mean, col = "blue", type = "o")

legend("topright",
       legend = c("Train", "Actual Test", "Forecast"),
       col = c("black", "red", "blue"),
       lty = 1,
       pch = 1)

######### 11. EVALUATION METRICS ########

actual <- as.numeric(test)

arima_pred <- as.numeric(arima_fc$mean)
ets_pred   <- as.numeric(ets_fc$mean)

rmse_arima <- rmse(actual, arima_pred)
mae_arima  <- mae(actual, arima_pred)
mape_arima <- mape(actual, arima_pred)

rmse_ets <- rmse(actual, ets_pred)
mae_ets  <- mae(actual, ets_pred)
mape_ets <- mape(actual, ets_pred)

results <- data.frame(
  Model = c("ARIMA", "ETS"),
  RMSE  = c(rmse_arima, rmse_ets),
  MAE   = c(mae_arima, mae_ets),
  MAPE  = c(mape_arima, mape_ets)
)

print("Model comparison:")
print(results)

print("Best model based on RMSE:")
print(results[which.min(results$RMSE), "Model"])

######## 12. FIT BEST MODEL ON FULL DATA #######

if (rmse_arima < rmse_ets) {
  best_model <- auto.arima(cpi_ts)
  best_name <- "ARIMA"
} else {
  best_model <- ets(cpi_ts)
  best_name <- "ETS"
}

print(paste("Best model is:", best_name))

###### 13. FORECAST FUTURE VALUES######
future_fc <- forecast(best_model, h = 5)

plot(future_fc,
     main = paste("5-Year Forecast using", best_name),
     ylab = "Percent Change",
     xlab = "Year")

####### 14. OPTIONAL ACCURACY OUTPUT##########
print("ARIMA accuracy:")
print(forecast::accuracy(arima_fc, test))
print("ETS accuracy:")
print(forecast::accuracy(ets_fc, test))