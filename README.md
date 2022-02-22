# SQL for Analyzing Australia & New Zealand Road Crash
This is a SQL project for my studies, which is analysis about Australia & New Zealand Road Crash. This folder contains the whole dataset used for this project including 6 csv files, an ERR diagram showing the operational layer, a table image describing the analytical layer (fact and dimensions), and the SQL script containing all the SQL statements that create the operational layer, the analytical layer, the ETL pipeline as well as the data marts. Below is just a brief summary of this project, including my main analytical goals and the steps that I took. A more detailed explanation of this project is available in the SQL script through comments between the SQL statements. 

## Operational Layer
The road_crash_schema contains road crash data in Australia and New Zealand. The schema has 6 tables which can be seen in the EER diagram below. The source of the dataset is available on [Kaggle](https://www.kaggle.com/mgray39/australia-new-zealand-road-crash-dataset). However, to speed up the queries for this project,  I cut out some data as professor László suggested. Therefore, if you want to reproduce this project with my SQL statements, please use the adjusted dataset I provided in the dataset folder.
<p align="center">
  <img src="https://github.com/xibei-chen/sql_analysis_australia_and_new_zealand_road_crash/blob/main/Term1/eer_diagram.png" />
</p>

## Analytics Plan
The questions regarding road crash I planned to answer during analytics are as below.
1. Is it that the higher the speed limit, the more road crash with severity?
2. How does lighting affect the number of vehicles involved?
3. Is it more likely for pedestrians to be involved in a road crash when it rains?
4. Where are animals more likly to be involved in a road crash?
5. Do days of week and hours play a role in terms of fatality?

From all the variables in all the tables, I picked some variables I think would be helpful to answer my aboved-mentioned analytical questions. The structure of the data store is shown as below.
* Fact(crash): severity, number_of_vehicles, involve_pedestrians, involve_animals
* Dimension1(road condition): lighting, weather, speed_limit
* Dimension2(location): country, state, local_government_area
* Dimension3(date time): day_of_week, hour

With this data store, I then created views and procedures as datamarts. One data mart for each question. Therefore, there are in total 5 data marts created for analysis.

## Analytical layer and ETL pipeline
The analytical layer was created with a stored procedure, which inner joined all the relevant tables. To increase the query speed, I only selected the data in year 2018 and 2019. Then in return, a new table road_crash was created to work as the analytical layer, aka a denormalized snapshot of the operational tables for road_crash subject as shown below. In addition, an event was also created to call the procedure every minute in the next 1 hour. The purpose is to document the timestamp each time updating table road_crash (it is mainly for practice purpose in this project). Furthermore, a trigger was created to insert a new line into previously created road_crash table the moment an insert is executed into table crash. Both the event and the trigger were tested to make sure they work properly. 
<p align="center">
  <img src="https://github.com/xibei-chen/sql_analysis_australia_and_new_zealand_road_crash/blob/main/Term1/data%20_store_fact_dimensions.png" />
</p>

## Data Marts
* Data mart no.1 was created with the help of VIEW. CASE statement was used to transform speed_limit into speed_limit_category.
* Data mart no.2 was also created with the help of VIEW. Aggregation with AVG funtion was used to compare the average number of vehicles involved in road crash under different lighting conditions.
* Data mart no.3 was created with the help of stored PROCEDURE. CTE and IF statement was used to convert number of pedestrians into a boolean value of if involving pedestrians. In addition, SUM and COUNT statements were used together to calculate the percentage.
* Data mart no.4 was created after a PROCEDURE using IN parameters to identify which country has more chance of road crash involving animals. Then again SUM and COUNT statements were again used together to calculate percentage.
* Data mart no.5 was created after a PROCEDURE using CURSOR and LOOP and another procedure to do some simple calculations with COUNT and return me two tabs of result.

## Analytical Conclusions
1. To my surprise, it is not that the higher the speed limit, the more road crash with severity. The highest number of road crash is under medium speed limit category (60-90 km/h). It might be the result of people being less vigilant while driving in medium speed. Maybe if goverment puts some warning signs next to medium speed limit, it will help reduce the occurance of road crash under medium speed limit category.
2. The average number of vehicles involved in road crash is the highest when it is in darkness but with lights, higher than when it is daylight.
3. Except fine weater, the chance is the highest when it rains compared to other weather conditions. So pedestrian should be most vigilant on the road when it is raining than other adverse weathers.
4. More road crash involving animals happen in Australia than in New Zealand. It might be the result of Australia being the habitat of kangaroos, possums and emus etc. And it would be wise to be extra careful and vigilant, and watch out for animals when driving in Australia, particularly in South Australia. An interesting article about Australia's road kill animals on [BBC Earth](https://www.bbcearth.com/news/australias-road-kill-map).
5. In this dataset, days of the week and hours don't play too much of a role in terms of fatality in road crash.
