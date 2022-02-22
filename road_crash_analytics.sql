-- -----------------------------------------------------------------------------------------------
-- Data Engineering 1 - Term Project 1
-- -----------------------------------------------------------------------------------------------
-- Purpose: Term Project 1 for Data Engineering 1: SQL and Different Shapes of Data in MSBA at CEU
-- Author: Xibei Chen
-- Updated on: 24.10.2021



-- -----------------------------------------------------------------------------------------------
-- CREATING THE OPERATIONAL LAYER
-- -----------------------------------------------------------------------------------------------

-- Create schema road_crash
DROP SCHEMA IF EXISTS road_crash_schema;

CREATE SCHEMA  road_crash_schema;

USE road_crash_schema;

-- Create table crash
DROP TABLE IF EXISTS crash;

CREATE TABLE crash(
crash_id VARCHAR(50) NOT NULL,
lat_long VARCHAR(50) REFERENCES location(lat_long),
date_time_id VARCHAR(50) NOT NULL REFERENCES date_time(date_time_id),
description_id INTEGER NOT NULL REFERENCES description(description_id),
vehicles_id VARCHAR(50) CHARACTER SET UTF8MB4 COLLATE UTF8MB4_bin REFERENCES vehicles(vehicles_id),
casualties_id VARCHAR(50) REFERENCES vasualties(casualties_id),
PRIMARY KEY(crash_id)
);

-- Load data into table crash (please be patient, it would take a few seconds)
LOAD DATA INFILE '/tmp/crash.csv'
INTO TABLE crash
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(crash_id,
@lat_long,
date_time_id,
description_id,
@vehicles_id,
@casualties_id)
SET
lat_long = NULLIF(@lat_long,''),
vehicles_id = NULLIF(@vehicles_id,''),
casualties_id = NULLIF(@casualties_id,'');

-- Create table description
DROP TABLE IF EXISTS description;

CREATE TABLE description(
description_id INTEGER NOT NULL,
severity VARCHAR(50) NOT NULL,
speed_limit VARCHAR(50),
midblock VARCHAR(10) NOT NULL,
intersection VARCHAR(10) NOT NULL,
road_position_horizontal VARCHAR(50),
road_position_vertical VARCHAR(50),
road_sealed VARCHAR(10),
road_wet VARCHAR(10),
weather VARCHAR(50),
crash_type VARCHAR(50),
lighting VARCHAR(50),
traffic_controls VARCHAR(50),
drugs_alcohol VARCHAR(10),
dca_code VARCHAR(50),
comment TEXT,
PRIMARY KEY(description_id)
);

-- Load data into table description (please be patient, it would take a few seconds)
LOAD DATA INFILE '/tmp/description.csv'
INTO TABLE description
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(description_id,
severity,
@speed_limit,
midblock,
intersection,
@road_position_horizontal,
@road_position_vertical,
@road_sealed,
@road_wet,
@weather,
@crash_type,
@lighting,
@traffic_controls,
@drugs_alcohol,
@dca_code,
@comment)
SET
speed_limit = NULLIF(@speed_limit,''),
road_position_horizontal = NULLIF(@road_position_horizontal,''),
road_position_vertical = NULLIF(@road_position_vertical,''),
road_sealed = NULLIF(@road_sealed,''),
road_wet = NULLIF(@road_wet,''),
weather = NULLIF(@weather,''),
crash_type = NULLIF(@crash_type,''),
lighting = NULLIF(@lighting,''),
traffic_controls = NULLIF(@traffic_controls,''),
drugs_alcohol = NULLIF(@drugs_alcohol,''),
comment = NULLIF(@comment,'');

-- Create table casualties
DROP TABLE IF EXISTS casualties;

CREATE TABLE casualties(
casualties_id VARCHAR(50) NOT NULL,
casualties INTEGER NOT NULL,
fatalities INTEGER NOT NULL,
serious_injuries INTEGER NOT NULL,
minor_injuries INTEGER NOT NULL,
PRIMARY KEY(casualties_id)
);

-- Load data into table casualties
LOAD DATA INFILE '/tmp/casualties.csv'
INTO TABLE casualties
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- Create table date_time
DROP TABLE IF EXISTS date_time;

CREATE TABLE date_time(
date_time_id VARCHAR(50) NOT NULL,
year VARCHAR(50) NOT NULL,
month VARCHAR(50),
day_of_week VARCHAR(50),
day_of_month VARCHAR(50),
hour VARCHAR(50),
approximate VARCHAR(10) NOT NULL,
PRIMARY KEY(date_time_id)
);

-- Load data into table date_time
LOAD DATA INFILE '/tmp/datetime.csv'
INTO TABLE date_time
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(date_time_id,
year,
@month,
@day_of_week,
@day_of_month,
@hour,
approximate)
SET
month = NULLIF(@month,''),
day_of_week = NULLIF(@day_of_week,''),
day_of_month = NULLIF(@day_of_month,''),
hour = NULLIF(@hour ,'');

-- Create table location
DROP TABLE IF EXISTS location;

CREATE TABLE location(
lat_long VARCHAR(50) NOT NULL,
latitude VARCHAR(50) NOT NULL,
longitude VARCHAR(50) NOT NULL,
country CHAR(2) NOT NULL,
state VARCHAR(5) NOT NULL,
local_government_area VARCHAR(100),
PRIMARY KEY(lat_long)
);

-- Load data into table location (please be patient, it would take a few seconds)
LOAD DATA INFILE '/tmp/location.csv'
INTO TABLE location
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(lat_long,
latitude,
longitude,
country,
state,
@local_government_area)
SET
local_government_area = NULLIF(@local_government_area,'');

-- Create table vehicles
DROP TABLE IF EXISTS vehicles;

CREATE TABLE vehicles(
vehicles_id VARCHAR(50) CHARACTER SET UTF8MB4 COLLATE UTF8MB4_bin NOT NULL UNIQUE,
animals INTEGER NOT NULL,
car_sedan INTEGER NOT NULL,
car_utility INTEGER NOT NULL,
car_van INTEGER NOT NULL,
car_4x4 INTEGER NOT NULL,
car_station_wagon INTEGER NOT NULL,
motor_cycle INTEGER NOT NULL,
truck_small INTEGER NOT NULL,
truck_large INTEGER NOT NULL,
bus INTEGER NOT NULL,
taxi INTEGER NOT NULL,
bicycle INTEGER NOT NULL,
scooter INTEGER NOT NULL,
pedestrian INTEGER NOT NULL,
inanimate INTEGER NOT NULL,
train INTEGER NOT NULL,
tram INTEGER NOT NULL,
vehicle_other INTEGER NOT NULL,
PRIMARY KEY(vehicles_id)
);

-- Load data into table vehicles
LOAD DATA INFILE '/tmp/vehicles.csv'
INTO TABLE vehicles
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(vehicles_id,
animals,
car_sedan,
car_utility,
car_van,
car_4x4,
car_station_wagon,
motor_cycle,
truck_small,
truck_large,
bus,
taxi,
bicycle,
scooter,
pedestrian,
inanimate,
train,
tram,
vehicle_other);



-- -----------------------------------------------------------------------------------------------
-- ANALYTICS PLAN
-- -----------------------------------------------------------------------------------------------

-- From all the variables in every table, I picked some that I think would be helpful to answer my questions during analytics. 
-- The structure of the data store is shown as below.
-- Fact(crash): severity, number_of_vehicles, involve_pedestrians, involve_animals
-- Dimension1(road condition): lighting, weather, speed_limit
-- Dimension2(location): country, state, local_government_area
-- Dimension3(date time): day_of_week, hour

-- Questions that hopefully can be answered on this data set:
-- 1. Is it that the higher the speed limit, the more road crash with severity?
-- 2. How does lighting affect the number of vehicles involved?
-- 3. Is it more likely for pedestrians to be involved in a road crash when it rains?
-- 4. Where are animals more likly to be involved in a road crash?
-- 5. Do days of week and hours play a role in terms of fatality?



-- -----------------------------------------------------------------------------------------------
-- CREATING THE ANALYTICAL LAYER AND THE ETL PIPELINE
-- -----------------------------------------------------------------------------------------------

USE road_crash_schema;

-- Create my analytical data store, aka a denormalized snapshot of the operational tables for road_crash subject
-- To increase the query speed, I decided to only use the data in year 2018 and 2019
-- There is a simple transformation to sum up number_of_vehicles
-- I embed the creation in a stored procedure called create_road_crash_store
DROP PROCEDURE IF EXISTS create_road_crash_store;

DELIMITER //

CREATE PROCEDURE create_road_crash_store()
BEGIN

	DROP TABLE IF EXISTS road_crash;

	CREATE TABLE road_crash AS
	SELECT 
	   description.severity AS severity, 
	   (
       vehicles.car_sedan+
       vehicles.car_utility+
       vehicles.car_van+
       vehicles.car_4x4+
       vehicles.car_station_wagon+
       vehicles.motor_cycle+
       vehicles.truck_small+
       vehicles.truck_large+
       vehicles.bus+
       vehicles.taxi+
       vehicles.bicycle+
       vehicles.scooter) AS number_of_vehicles,
	   vehicles.pedestrian AS involved_pedestrians,
	   vehicles.animals AS involved_animals,
	   description.lighting AS lighting,   
	   description.weather AS weather,
	   description.speed_limit AS speed_limit,   
	   location.country AS country,
	   location.state AS state,
       location.local_government_area AS local_government_area,
       date_time.day_of_week AS day_of_week,
       date_time.hour AS hour
	FROM
		crash
	INNER JOIN
        description USING(description_id)
	INNER JOIN
		vehicles USING(vehicles_id)
	INNER JOIN
		location USING (lat_long)
	INNER JOIN
		date_time USING (date_time_id)
	WHERE year IN (2018,2019);

END //
DELIMITER ;

CALL create_road_crash_store();

-- Create an event to schedule ETL job which is calling create_road_crash_store every 1 minute in the next 1 hour. 
-- The purpose is to document the timestamp each time updating table road_crash..
DROP TABLE IF EXISTS messages;

CREATE TABLE messages (message varchar(255) NOT NULL);

SET GLOBAL event_scheduler = ON;

SHOW VARIABLES LIKE "event_scheduler";

TRUNCATE messages;

DROP EVENT IF EXISTS create_road_crash_store_event;

DELIMITER //
CREATE EVENT create_road_crash_store_event
ON SCHEDULE EVERY 1 MINUTE
STARTS CURRENT_TIMESTAMP
ENDS CURRENT_TIMESTAMP + INTERVAL 1 HOUR
DO
	BEGIN
		INSERT INTO messages SELECT CONCAT('event:',NOW());
    		CALL create_road_crash_store();
	END//
DELIMITER ;

-- TESTING: if the event scheduler works.
-- Checking if I can get a few rows of event timestamps in table messages.
SELECT * FROM messages;
-- There are a few rows of event timpstamps, so the event scheduler works.


-- Creating a trigger which is activated if an insert is executed into crash
-- Once triggered will insert a new line in previously created road_crash table.
TRUNCATE messages;

DROP TRIGGER IF EXISTS after_description_insert; 

DELIMITER //

CREATE TRIGGER after_description_insert
AFTER INSERT
ON description FOR EACH ROW
BEGIN
	
	-- Log the description_id of the newly inserted
    	INSERT INTO messages SELECT CONCAT('new description id: ', NEW.description_id);

	-- Archive the description and assosiated table entries to road_crash
  	INSERT INTO road_crash
	SELECT 
	    description.severity AS severity, 
	   (
       vehicles.car_sedan+
       vehicles.car_utility+
       vehicles.car_van+
       vehicles.car_4x4+
       vehicles.car_station_wagon+
       vehicles.motor_cycle+
       vehicles.truck_small+
       vehicles.truck_large+
       vehicles.bus+
       vehicles.taxi+
       vehicles.bicycle+
       vehicles.scooter) AS number_of_vehicles,
	   vehicles.pedestrian AS involved_pedestrians,
	   vehicles.animals AS involved_animals,
	   description.lighting AS lighting,   
	   description.weather AS weather,
	   description.speed_limit AS speed_limit,   
	   location.country AS country,
	   location.state AS state,
       location.local_government_area AS local_government_area,
       date_time.day_of_week AS day_of_week,
       date_time.hour AS hour
FROM
		crash
	INNER JOIN
        description USING(description_id)
	INNER JOIN
		vehicles USING(vehicles_id)
	INNER JOIN
		location USING (lat_long)
	INNER JOIN
		date_time USING (date_time_id)
	WHERE year IN (2018,2019)
    AND description_id = NEW.description_id;

END //

DELIMITER ;

-- TESTING: if the trigger works.
-- Checking the number of rows in the road_crash table before inserting a new row to the description table.
SELECT COUNT(*) FROM road_crash;
-- Before activating the trigger the table has 60582 rows.

-- Now will activate the trigger by inserting into description table:
INSERT INTO crash VALUES('','(-34.9029224036547, 138.60939035340667)','2018-1--4-13','1999999999','2c','0c');
INSERT INTO description VALUES('1999999999','property_damage','60','TRUE','FALSE','straight','level','TRUE','FALSE','fine','Other new type','daylight','none',NULL,NULL,NULL);

-- Checking messages table.
SELECT * FROM messages;
-- There is a new description id: 1999999999.

-- Checking the number of rows in the updated road_crash table.
SELECT COUNT(*) FROM road_crash;
-- After activating the trigger the table has 60583 rows, so the trigger works.


-- -----------------------------------------------------------------------------------------------
-- CREATING THE DATA MARTS
-- -----------------------------------------------------------------------------------------------

-- Question 1. Is it that the higher the speed limit, the more road crash with severity?
-- -----------------------------------------------------------------------------------------------
-- To answer this question, I created the following VIEW speed_limit_severity as data mart no.1.
-- Here I used CASE statement to transform speed_limit into speed_limit_category to help make further analysis easier.
DROP VIEW IF EXISTS speed_limit_severity;

CREATE VIEW speed_limit_severity AS
SELECT severity, speed_limit,
CASE 
WHEN speed_limit IN ('5','10','15','20','25','30','40','50','0 - 50 km/h')
THEN "low"
WHEN speed_limit IN('60','60 km/h','70','70 km/h','75','80','90','80 - 90 km/h')
THEN 'medium'
ELSE "high" 
END AS speed_limit_category
FROM road_crash;

-- With the help of this data mart, I wrote the following query to compare the number of road crash between different speed limit category.
SELECT speed_limit_category, COUNT(*) AS number_of_road_crash
FROM speed_limit_severity
WHERE severity IN ('fatality','serious_injury')
GROUP BY speed_limit_category
ORDER BY number_of_road_crash DESC;

-- Conclusion: 
-- To my surprise, it is not that the higher the speed limit, the more likely road crash occurs.
-- Instead, we got the highest number of road crash under medium speed limit category. 
-- It might be the result of people being less vigilant while driving in medium speed. 
-- Maybe if goverment puts some warning signs next to medium speed limit will help reduce the occurance of road crash under medium speed limit category.


--  Question 2. How does lighting affect the number of vehicles involved?
-- -----------------------------------------------------------------------------------------------
--  To answer this question, I created the following VIEW lighting_number_of_vehicles as data mart no.2.
DROP VIEW IF EXISTS lighting_number_of_vehicles;

CREATE VIEW lighting_number_of_vehicles AS
SELECT lighting, number_of_vehicles
FROM road_crash;

-- With the help of this data mart, I am able to compare the average number of vehicles involved in road crash under different lighting conditions.
SELECT lighting, AVG(number_of_vehicles) AS avg_number_of_vehicles
FROM lighting_number_of_vehicles
GROUP BY lighting
ORDER BY avg_number_of_vehicles DESC;

-- Conclusion: 
-- We can see that the average number of vehicles involved in road crash is the highest when it is in darkness but with lights, higher than daylight in the second place.
-- Furthermore, dawn/dusk lighting and darkness without lights are not doing too bad in this analysis, as they are below daylight.
-- The reason might be that there are fewer vehicles on the road around dawn/dusk time or in total darkness.


-- Question 3. Is it more likely for pedestrians to be involved in a road crash when it rains?
-- -----------------------------------------------------------------------------------------------
-- To answer this question, first I created the following weather_pedestrians prodedure.
-- In this procedure, I used CTE convert_pedestrians with IF statement to
-- Convert variable number of pesdestrians to a boolean variable if_with_pedestrians with value 0 or 1 to make further percentage calculation easier.
-- The result of calling the following procedure works as data mart no.3.
DROP PROCEDURE IF EXISTS weather_pedestrians;

DELIMITER //

CREATE PROCEDURE weather_pedestrians()
BEGIN
    -- Create the CTE convert_pedestrians
    WITH convert_pedestrians
    AS (
	SELECT weather, involved_pedestrians, IF (involved_pedestrians = 0, 0, 1) AS if_with_pedestrians
    FROM road_crash)
    -- Use the CTE convert_pedestrians
    SELECT weather, (SUM(if_with_pedestrians)/COUNT(involved_pedestrians))*100 AS percentage_of_total_road_crash_with_pedestrians
    FROM convert_pedestrians
    GROUP BY weather
    ORDER BY percentage_of_total_road_crash_with_pedestrians DESC;

END //

DELIMITER ;

CALL weather_pedestrians();

-- Conclusion: 
-- We can see that road crash with pedestrians happens the most often when the weather is fine, no surprise.
-- When it rains, the chance drops around 0.8% compared to fine weather. When there is mist, the chance dropped around 0.1% compared to when it rains.
-- The chance then decreases quite significantly around 0.8% when there is fog.
-- In our dataset, road crash involving pedestrians almost never happens when it snows or when there is smoke dust or high wind.
-- So pedestrians should be most vigilant on the road when it is rainy or misty compared to other adverse weather conditions.


-- Question 4. Where are animals more likly to be involved in a road crash?
-- -----------------------------------------------------------------------------------------------
-- Before going further, I first would like to know the distinct numbers of involved animals, so I created the following query.
SELECT DISTINCT involved_animals
FROM road_crash;

-- The result includes 0 and 1. So either no animal or only one animal would be involved in a road crash in our dataset.
-- Then I created the following procedure using IN parameters, to see which country has more chance of road crash involving animals.
-- Using simple calculation to get the percentage of road crash wish animals. 
DROP PROCEDURE IF EXISTS country_animals;

DELIMITER //
CREATE PROCEDURE country_animals(
	IN country_name_1 CHAR(2),
    IN country_name_2 CHAR(2)
)
BEGIN
	SELECT country, (SUM(involved_animals)/COUNT(*))*100 AS percentage_of_road_crash_with_animals
	FROM road_crash
    WHERE country in (country_name_1, country_name_2)
    GROUP BY country
	ORDER BY percentage_of_road_crash_with_animals DESC;
END //

DELIMITER ;

CALL country_animals('AU','NZ');

-- It turns out that it is about 0.55% more likely to have road crash involving animals in Australia than in NZ,
-- which is not a small number on this matter considering so many road crashes happen everyday and it is in general not common for road crash to involve animals.
-- I assume that it is the result of Australia being habitat to many wildlife such as Kangaroos, possums, emus, etc.
-- To go further, I would also like to know where in Australia specifically has the highest chance for animals to be involved in road crash.
-- So I created the following procedure. Calling this procedure would get me data mart no.4.
DROP PROCEDURE IF EXISTS australia_animals;

DELIMITER //
CREATE PROCEDURE australia_animals()
BEGIN
	SELECT state, local_government_area, (SUM(involved_animals)/COUNT(involved_animals))*100 AS percentage_of_road_crash_with_animals
	FROM road_crash
    WHERE country = 'AU'
    GROUP BY state, local_government_area
	ORDER BY percentage_of_road_crash_with_animals DESC;
END //

DELIMITER ;

CALL australia_animals();

-- The local area with the highest chance 40% of involving animals in road crash is DC of Orroroo/Carrieton.
-- Followed by DC of Peterborough with around 28.6% and the Flinders Ranges Council with around 27.3%.
-- And we can clearly see from the result that all the local areas with rounded chance of more than 1% are located in South Australia.
-- Besides, there is only one area from another state that has rounded chance of more than 0, which is Macedon Ranges in Victoria with 0.73%.
-- Therefore, it would be well-advised to be extra careful and vigilant and watch out for animals when driving in Australia, particularly in South Australia.
-- There is an interesting article about Australia's road kill animals I found online. Link: https://www.bbcearth.com/news/australias-road-kill-map


-- Question 5. Do days of week and hours play a role in terms of fatality?
-- -----------------------------------------------------------------------------------------------
-- To answer this qusestion, I first created the following procedure transforming table road_crash into a new table as data mart.
-- This procedure using CURSOR and LOOP would get me only data I care about in this analysis, namely severity, day_of_week, hour and number_of_road_crash.
DROP PROCEDURE IF EXISTS fetch_road_crash;

DELIMITER //
CREATE PROCEDURE fetch_road_crash()
BEGIN
    DECLARE severity VARCHAR(20);
	DECLARE day_of_week INT;
	DECLARE hour INT;
    DECLARE number_of_road_crash INT;
    DECLARE finished INTEGER DEFAULT 0;
    
	-- Declare Cursor
	DECLARE my_cursor CURSOR FOR SELECT road_crash.severity, road_crash.day_of_week, road_crash.hour, COUNT(*) AS number_of_road_crash FROM road_crash_schema.road_crash GROUP BY road_crash.severity, road_crash.day_of_week, road_crash.hour;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
    
	-- Open Cursor
	OPEN my_cursor;
	DROP TABLE IF EXISTS severity_day_time;
    CREATE TABLE severity_day_time (severity VARCHAR(20), day_of_week INT, hour INT, number_of_road_crash INT);

	myloop: LOOP
	-- Fetch Cursor
		FETCH my_cursor INTO severity, day_of_week, hour, number_of_road_crash;
		INSERT INTO severity_day_time SELECT severity, day_of_week, hour, number_of_road_crash GROUP BY severity, day_of_week, hour;
		IF finished = 1 THEN LEAVE myloop;
		END IF;
	END LOOP myloop;
	-- Close Cursor
	CLOSE my_cursor;
END//
DELIMITER ;

CALL fetch_road_crash();

-- Now after calling the above loop procedure, I get a table severity_day_time.
-- Next I created the following procedure, selecting data from table severity_day_time to get me data mart no.5
-- To help me get insights about which day of week and which hours are specifically more likely for fatality to occur on the road.
DROP PROCEDURE IF EXISTS day_time_fatality;

DELIMITER //

CREATE PROCEDURE day_time_fatality()
BEGIN
    SELECT day_of_week, COUNT(*) AS number_of_road_crash
    FROM severity_day_time
    WHERE severity = 'fatality'
    GROUP BY day_of_week
    ORDER BY number_of_road_crash DESC;
    
	SELECT hour, COUNT(*) AS number_of_road_crash
    FROM severity_day_time
    WHERE severity = 'fatality'
    GROUP BY hour
    ORDER BY number_of_road_crash DESC;
END //

DELIMITER ;

CALL day_time_fatality();

-- Conclusion: 
-- Here we get two tabs of results, the first tab shows us that Monday is the day of week which has the highest number of road crash with fatality.
-- Followed by Saturday as second place. However, there is no significant difference between each day of week.
-- The second tab shows us that 12pm is the hour when the highest number of road crash with fatality happen.
-- However, there is not much difference during daylight hours either.
-- Therefore, in our dataset, days of the week and hours don't play too much of a role in terms of fatality in road crash.
