# Bike Sharing Demand
Time Series Prediction on Bike Sharing Data Set using R programming

## Objective
The project is based on the Bike Sharing Demand data set from Kaggle. Link to data set is mentioned below. The aim of this project is to predict the number of bikes rented in next hour using the following features:

    1. datetime - hourly date + timestamp
    2. season - 1 = spring, 2 = summer, 3 = fall, 4 = winter
    3. holiday - whether the day is considered a holiday
    4. workingday - whether the day is neither a weekend nor holiday
    5. weather -
          1: Clear, Few clouds, Partly cloudy, Partly cloudy
          2: Mist + Cloudy, Mist + Broken clouds, Mist + Few clouds, Mist
          3: Light Snow, Light Rain + Thunderstorm + Scattered clouds, Light Rain + Scattered clouds
          4: Heavy Rain + Ice Pallets + Thunderstorm + Mist, Snow + Fog
    6. temp - temperature in Celsius
    7. atemp - "feels like" temperature in Celsius
    8. humidity - relative humidity
    9. windspeed - wind speed
    10. casual - number of non-registered user rentals initiated
    11. registered - number of registered user rentals initiated
    12. count - number of total rentals
    
Through this project, I aim to conduct EDA, visualize data to find trends, build benchmark model, build best model and tune it get better result. Accuracy is measured in terms of RMSE and R2 error.

Link: https://www.kaggle.com/c/bike-sharing-demand/data

## Result
Through EDA and Data Visualization(graphs are included in the repo), following inferences were made:
    1. Count of users and temp are correlated. It is true as people would prefer to stat at home/use other transportation methods at hotter and colder temperature.
    2. Similarly, most users rent bike around 8 A.M. and 7 P.M. during working days & evening hours in non working days.
    3. Users are seen renting more in Fall season followed by Spring season. The least count is during Spring Season. This is true as we already know the relation of temperature and count.
    4. Count, Casual and Registered user count are highly correlated. Similarly, temp and atemp are highly correlated. Hence these features need to be removed for better accuracy.

### Model result:
    1. Linear Model:
          RMSE: 109.6229         R2: 0.6144
    2. Random Forest:
          RMSE: 69.8340       R2: 0.8435
    3. Random Forest tuned using Grid Search:
          RMSE: 35.9374             R2: 0.9586
