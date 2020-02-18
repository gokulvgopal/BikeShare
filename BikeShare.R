setwd("D:/UH/Udemy - R progamming/My Solution/Linear Regression Project")
# The problem statement is to predict the number of bikes rented in every
# hour using the bike sharing data set
# The data set contains 12 varibles and 10886 rows
# The objective is to use random forest and tune it predict the 
# time series data set

# Loading libraries
library(ggplot2)
library(dplyr)
library(caTools)
library(randomForest)
library(gbm)
library(caret)
library(corrplot)

# Loading the data set
df <- read.csv('bikeshare.csv')

# EDA
# Checking the structure and sample values from the data set
print(head(df))
print(str(df))

# Plotting count vs temp
# we can see that maximum number of count of rented bikes occurs between
# 20 -30 degree celcius. This is true as this is the most comfortable
# weather condition for bike ride
pl <- ggplot(df, aes(y=count, x=temp))
pl2 <- pl + geom_point(aes(color=temp), alpha=0.4, size = 3)
print(pl2)

# Plotting count vs time grouped by temperature during that hour
# We can clearly see that count varies with working and non working days
# And it varies further within that day
df$datetime <- as.POSIXct(df$datetime) 
pl3 <- ggplot(df, aes(x=datetime, y=count)) + geom_point(aes(color=temp)) + scale_color_gradient(high='red', low='green')
print(pl3)

# Calculating correlation of count with temperature
print(cor(df$count, df$temp))
# [1] 0.3944536

# Plotting count vs season
# We can see that fall season have higher mean followed by summer.
# This is true as temperature will be low in fall and rainfall will be affecting the spring season
pl4 <- ggplot(df, aes(x=factor(season), y=count))+geom_boxplot(aes(color=factor(season)))
print(pl4)

# Feature Engineering - Adding hour column
df$hour <- df$datetime %>% as.POSIXct(format="%H:%M:%S") %>% format("%H")
df$day <- df$datetime %>% as.POSIXct(format="%Y-%m-%d") %>% format("%d")
df$weekday <- as.POSIXlt(df$datetime)$wday + 1

# Plotting hour vs count on a working day grouped by temperature
# We can clearly see that count is more during office hours 8 am and evening 5 P.M.
pl4 <- ggplot(filter(df,workingday==1), aes(x=hour, y=count)) + geom_point(aes(color=temp),position=position_jitter(w=1, h=0)) + scale_color_gradientn(colors=c('red','green','black'))
print(pl4)

# Plotting hour vs count on a non working day grouped by temperature
# As expected, count is distributed across all hours with more on evening
pl5 <- ggplot(filter(df,workingday==0), aes(x=hour, y=count)) + geom_point(aes(color=temp),position=position_jitter(w=1, h=0)) + scale_color_gradientn(colors=c('red','green','black'))
print(pl5)

# Finding correlation between features
num.cols <- sapply(df, is.numeric)
cor.data <- cor(df[,num.cols])
print(cor.data)
print(corrplot(cor.data, method = 'color'))

# Splitting data in train and test set
df2 <- as.data.frame(df[,-1])
set.seed(101)
sampl <- sample.split(df2$count, SplitRatio = 0.7)
df2.train <- subset(df2, sampl == TRUE)
df2.test <- subset(df2, sampl == FALSE)
# Sapmple model - count and temperature
t.model <- lm(count ~ temp, df2.train)
print(summary(t.model))

# Predicting with dummt linear model
temp.data = data.frame(temp=c(25))
print(paste("Prediction using dummy model, when temp=25, count will be: ",ceiling(predict(t.model, temp.data))))
# [1] "Prediction using dummy model, when temp=25, count will be:  238"

# Function for calculating R2 and RMSE
error.calculation <- function(predicted, actual){
  rmse <- mean((actual-predicted)^2)^0.5
  sse <- sum((predicted-actual)^2)
  sst <- sum((mean(actual)-actual)^2)
  r2 <- 1 - sse/sst
  print(paste("Root Mean Squared Error: ",rmse))
  print(paste("R2 Square error: ",r2))
}
df2$hour <- sapply(df2$hour, as.numeric)
df2$day <- sapply(df2$day, as.numeric)
df2$weekday <- sapply(df2$weekday, as.numeric)


# Feature Selection
# Using the correlation matrix following actions were taken:
# Highly correlated feature - casual and registered is removed
# Target feature - count - is excluded
# atemp is also exlcluded as they are highly correlated with temp
n <- c('season','holiday','workingday','weather','temp','humidity','windspeed','hour','day','weekday')
feature.names <- paste("count ~ ",paste(n, collapse = " + "), sep="")

# Modelling
# Linear Model
# This model is used as benchmark for prediction error.
print("****************************************************************")
print(" ********** Linear Regression *************")
lm.model <- lm(feature.names, df2.train)
print("Summary of Linear Regression Model")
print(summary(lm.model))
lm.predicted <- predict(lm.model, df2.test)
print(" *** Linear Regression Model Error **")
error.calculation(lm.predicted,df2.test$count)
# [1] "Root Mean Squared Error:  109.622926231706"
# [1] "R2 Square error:  0.614410595426845"



# Random Forest
# with default values
print("****************************************************************")
print(" ********** Random Forest *************")
rf.model <- randomForest(as.formula(feature.names), data = df2.train)
print(" Summary of Random Forest Model ")
print(summary(rf.model))
rf.predicted <- predict(rf.model,df2.test)
# printing the # of trees for random forest used for building model
print(rf.model$ntree)
# [1] 500
# Printing error vs # of trees
plot(rf.model)
# Printing the # of trees for the least error and the RMSE for that model
print(which.min(rf.model$mse))
# [1] 326
print(sqrt(rf.model$mse[which.min(rf.model$mse)]))
print(" *** Random Forest Model Error **")
error.calculation(rf.predicted,df2.test$count)
# [1] "Root Mean Squared Error:  69.8339817740945"
# [1] "R2 Square error:  0.843521050989121"





print("****************************************************************")
print(" ********** Random Forest with Grid Search *************")
# Setting Parameters for grid search
control <- trainControl(method="repeatedcv", number=10, repeats=3, search="grid")
tunegrid <- expand.grid(.mtry=c(2:13))
metric <- "RMSE"
rf_gridsearch <- train(count ~ ., data=df2.train, method="rf", metric=metric, tuneGrid=expand.grid(.mtry=sqrt(ncol(df2.train))), trControl=control)
print(rf_gridsearch)
# Plotting the tuned Random Forest
plot(rf_gridsearch)
rf.gs.predicted <- predict(rf_gridsearch,df2.test)
print(" *** Random Forest Model with Grid Search Error **")
error.calculation(rf.gs.predicted,df2.test$count)
# [1] "Root Mean Squared Error:  35.9374167331061"
# [1] "R2 Square error:  0.958560355446042"


# Through this excercise, we understood that linear regression model do not do well with time series data
# At the same time, random forest deals better with time series data and it handles categorical and outliers
# Future work includes testing out other models