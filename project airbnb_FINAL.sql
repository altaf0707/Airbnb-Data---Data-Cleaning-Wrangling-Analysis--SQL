CREATE DATABASE IF NOT EXISTS airbnb_1; -- creating the database

USE airbnb_1; -- using the database

-- creating the table
CREATE TABLE project_airbnb_3
(
index1 INT,
Unnamed INT,
id INT,
namess VARCHAR(300) ,
host_id INT,
host_name VARCHAR(300),
borough VARCHAR(300),
neighbourhood VARCHAR(300),
latitude FLOAT,
longitude FLOAT,
room_type VARCHAR(200),
price FLOAT,
minimum_nights FLOAT,
number_of_reviews FLOAT,
last_review VARCHAR(200),
reviews_per_month FLOAT,
calculated_host_listings_count FLOAT,
availability_365 FLOAT
);

-- going through the data
SELECT * FROM project_airbnb_3;
DESC project_airbnb_3;

/*
-- This is the optimize code for dropping the column :
-- ALTER TABLE project_1_csv DROP COLUMN `MyUnknownColumn`, DROP COLUMN `Unnamed: 0`;
*/

-- setting sql_safe_updates to 0 in order to change or update the changes in the dataframe.
SET SQL_SAFE_UPDATES = 0;

-- dropping unnecessary columns
ALTER TABLE project_airbnb_3
DROP COLUMN `index1`,
DROP COLUMN `Unnamed`;
ALTER TABLE project_airbnb_3
DROP COLUMN `host_name`,
DROP COLUMN `last_review`;



-- checking null values for reviews_per_month
SELECT COUNT(*) FROM project_airbnb_3 WHERE reviews_per_month IS NULL; 

SELECT number_of_reviews FROM project_airbnb_3 WHERE reviews_per_month IS NULL;
/* Inference:- we have have found that in a row where ever reviews_per_month is null, and 
where ever the number_of_reviews are having values as 0. t simply states a relationship between the two and
indicates that in that null values of reviews_per_month is nothing but zero for the corresponding values
in the number_of_reviews column where the values are 0. 
*/


-- updating nullvalues of reviews_per_month by putting condition to check if there are no reviews given.
UPDATE project_airbnb_3
SET reviews_per_month = 0.00
WHERE number_of_reviews = 0 AND reviews_per_month IS NULL;

-- dealing with rest of the null values of reviews_per_month

-- finding whether the number of rows of null values in reviews_per_month are even or odd
SELECT count(*) null_rows_for_reviews_per_month  FROM project_airbnb_3 WHERE reviews_per_month IS NULL; 
-- INF: the number of null values rows are even so will using the median code accoridngly

-- imputing the remaining null values of reviews_per_month with the median of it
WITH median_value_for_reviews_per_month1 AS (
  SELECT reviews_per_month AS MEDIAN
  FROM (
    SELECT
      reviews_per_month,
      ROW_NUMBER() OVER (ORDER BY reviews_per_month) AS row_numberr,
      COUNT(*) OVER () AS n
    FROM
      project_airbnb_3
    WHERE reviews_per_month IS NOT NULL -- Exclude rows where reviews_per_month is null
  ) AS subquery
  WHERE row_numberr IN ((((n + 1) DIV 2) + (n DIV 2)) DIV 2)
) -- median value is found using the above code

-- imputing the null values with the median found out for reviews_per_month
UPDATE project_airbnb_3 AS t
SET t.reviews_per_month = (
  SELECT MEDIAN
  FROM median_value_for_reviews_per_month1
)
WHERE t.reviews_per_month IS NULL; -- Only update rows where reviews_per_month is null


-- checking the names of boroughs
SELECT DISTINCT borough FROM project_airbb_3;

-- updating typos of boroughs with the correct ones 
UPDATE project_airbnb_3
SET borough = "Brooklyn" 
WHERE borough = "Brookly";

SELECT borough FROM project_airbnb_3
WHERE borough = "Brooklyn";

UPDATE project_airbnb_3
SET borough = "Manhattan" 
WHERE borough IN ("Manhatteen", "Mahattan","Manhattn");

UPDATE project_airbnb_3
SET borough = "Queens" 
WHERE borough IN ("Queen");

-- rechecking the borough names
SELECT DISTINCT borough FROM project_airbnb_3;


-- room_type and price columns are interrelated as the price varies with room_types 

-- finding the mininum and maximum price for every room_types 
SELECT room_type, MIN(price),AVG(price), MAX(price) FROM project_airbnb_3 GROUP BY 1;

/*
 we have found from the above code that the minimum price for all the room_type is 0 which cannot be true
so these are straight forwardly outliers and at the time maximum price for entire_home/apt and private_room, 
And maximum values for each room_types are also having vast difference from their avg values,
that also cannot be true and hence taken as outliers. And for the shared room type is coming many times more than the avg price and
hence can be concluded as outliers. So in the above circumstances, in order to properly impute the null values in the room_type columns
we will be using the 25% percentile of the price for corresponding room_type in order to avoid the overlapping of the price ranges 
for all the room_types.
 */

-- query for finding 25% percentile values of price columns for each room_type 
SELECT 
    room_type,
    price AS percentile_25
FROM (
    SELECT 
        room_type,
        price,
        ROW_NUMBER() OVER (PARTITION BY room_type ORDER BY price) AS row_num,
        COUNT(*) OVER (PARTITION BY room_type) AS total_rows
    FROM project_airbnb_3
) AS subquery
WHERE row_num = CEIL(0.25 * total_rows); -- ceil: The CEIL() function returns the nearest smallest integer that is greater than or equal to a number.
-- INF 25th percentile price value for room_types entire_home/apt, private_room and shared room is 119, 50 and 32 respectively.


-- checking the null values count for room_type
SELECT count(*) null_values_count FROM project_airbnb_3 WHERE room_type = 'None';

-- imputing the null values for room_type based on 25th percentile values of price for each room_type
UPDATE project_airbnb_3
SET room_type = 
    CASE
        WHEN room_type = "None" AND price >= 119.0 THEN 'Entire home/apt'
        WHEN room_type = "None" AND price >= 50.0 AND price < 119.0 THEN 'Private room'
        WHEN room_type = "None" AND (price < 50.0 ) THEN 'Shared room'
        ELSE room_type
    END;

-- checking the counts of each room_type
SELECT room_type, COUNT(room_type) FROM project_airbnb_3 GROUP BY 1;

-- verifying if there is any null values still left
SELECT room_type, COUNT(*) FROM project_airbnb_3
GROUP BY 1
HAVING room_type ='None';


/*
 PLEASE NOTE:  in float variable 'none' is taken as null by mysql and for all other data type where in python we are setting the null values to be 'None'
for them mysql treats the same null values as the string values as 'None', not other way around.
*/

--  borough and price column are interrelated 

 -- checking the nullprice_values count for each boroughs
SELECT borough , count(*) null_price_counts FROM project_airbnb_3 WHERE price IS NULL;
 
 
-- checking the number of rows if the number is even or odd in order to use the median formula accordingly
SELECT COUNT(*) FROM project_airbnb_3 WHERE borough = 'Manhattan'; -- getting odd no of rows


-- finding price median values for MANHATTAN to impute null values of price column for the same
WITH median_value_for_manhattan_null_price AS (
  SELECT price AS MEDIAN
  FROM (
    SELECT
      price,
      ROW_NUMBER() OVER (ORDER BY price) AS row_numberr,
      COUNT(*) OVER () AS n
    FROM
      project_airbnb_3
    WHERE borough = 'Manhattan' 
  ) AS subquery
  WHERE row_numberr IN ((n + 1) DIV 2) 
)

-- imputing the null values with median price values for manhattan
UPDATE project_airbnb_3 AS t
SET t.price = (
  SELECT MEDIAN
  FROM median_value_for_manhattan_null_price
)
WHERE t.price IS NULL AND t.borough = 'Manhattan';

-- checking the null values for manhattan
SELECT price FROM project_airbnb_3 WHERE borough = 'Manhattan' AND price IS NULL;


-- Brooklyn(90) and Bronx(65)

-- checking the number of rows if the number is even or odd in order to use the median formula accordingly
SELECT COUNT(price) FROM project_airbnb_3 WHERE borough = 'Brooklyn'; -- getting odd no of rows

-- finding price median values for BROOKLYN to impute null values of price column for the same
WITH median_value_for_brooklyn_null_price AS (
  SELECT price AS MEDIAN
  FROM (
    SELECT
      price,
      ROW_NUMBER() OVER (ORDER BY price) AS row_numberr,
      COUNT(*) OVER () AS n
    FROM
      project_airbnb_3
    WHERE borough = 'Brooklyn' 
  ) AS subquery
  WHERE row_numberr IN ((n + 1) DIV 2) 
)


-- imputing the null values with median price values for brooklyn
UPDATE project_airbnb_3 AS t
SET t.price = (
  SELECT MEDIAN
  FROM median_value_for_brooklyn_null_price
)
WHERE t.price IS NULL AND t.borough = 'Brooklyn';


-- checking the null values for BROOKLYN
SELECT price FROM project_airbnb_3 WHERE borough = 'Brooklyn' AND price IS NULL;

-- checking the number of rows if the number is even or odd in order to use the median formula accordingly
SELECT COUNT(price) FROM project_airbnb_3 WHERE borough = 'Bronx'; -- getting odd no of rows

-- finding price median values for BRONX to impute null values of price column for the same
WITH median_value_for_bronx_null_price AS (
  SELECT price AS MEDIAN
  FROM (
    SELECT
      price,
      ROW_NUMBER() OVER (ORDER BY price) AS row_numberr,
      COUNT(*) OVER () AS n
    FROM
      project_airbnb_3
    WHERE borough = 'Bronx' 
  ) AS subquery
  WHERE row_numberr IN ((n + 1) DIV 2) 
)


-- imputing the null values with median price values for Bronx
UPDATE project_airbnb_3 AS t
SET t.price = (
  SELECT MEDIAN
  FROM median_value_for_bronx_null_price
)
WHERE t.price IS NULL AND t.borough = 'Bronx';


-- checking the null values for BRONX
SELECT price FROM project_airbnb_3 WHERE borough = 'Bronx' AND price IS NULL;


-- checking the null values of price
SELECT COUNT(*)
FROM project_airbnb_3 WHERE price IS NULL;

-- Deleting rest of the price null values as the count is 6 which is small
DELETE FROM project_airbnb_3 
WHERE price IS NULL;

-- checking the price null values if there is still any left
SELECT COUNT(*)
FROM project_airbnb_3 WHERE price IS NULL;


-- null values for reviews_per_month, price, roomtype resolved uptil now 


-- dealing with calculated_host_listings_count null values, 
-- DELETING the null values of calculated_host_listings_count as there are only 16 null values 
SELECT DISTINCT calculated_host_listings_count from project_airbnb_3; -- checking null values count

-- removing the null valued rows of calculated_host_listings_count
DELETE FROM project_airbnb_3 
WHERE calculated_host_listings_count IS NULL;

/*
-- checking the null values for every column
SELECT COUNT(*) FROM project_airbnb_3
WHERE id IS NULL; -- 0
SELECT COUNT(*) FROM project_airbnb_3
WHERE namess = 'None'; -- 14
SELECT COUNT(*) FROM project_airbnb_3
WHERE host_id IS NULL; -- 0
SELECT COUNT(*) FROM project_airbnb_3
WHERE borough = 'None'; -- 60
SELECT COUNT(*) FROM project_airbnb_3
WHERE neighbourhood = 'None'; -- 0
SELECT COUNT(*) FROM project_airbnb_3
WHERE room_type = 'None'; -- 0
SELECT COUNT(*) FROM project_airbnb_3
WHERE price IS NULL; -- 0
SELECT COUNT(*) FROM project_airbnb_3
WHERE number_of_reviews IS NULL; -- 25
SELECT COUNT(*) FROM project_airbnb_3
WHERE reviews_per_month IS NULL; -- 0
SELECT COUNT(*) FROM project_airbnb_3
WHERE calculated_host_listings_count IS NULL; -- 0
SELECT COUNT(*) FROM project_airbnb_3
WHERE availability_365 IS NULL; -- 39
*/

DESC project_airbnb_3;
SELECT SUM(CASE
             WHEN id IS NULL THEN 1
             ELSE 0
           END) AS id_total_null_values,
       SUM(CASE
             WHEN namess = 'None' THEN 1
             ELSE 0
           END) AS name_total_null_values,
       SUM(CASE
             WHEN host_id IS NULL THEN 1
             ELSE 0
           END) AS host_id_total_null_values,
       SUM(CASE
             WHEN borough = 'None' THEN 1
             ELSE 0
           END) AS borough_total_null_values,
       SUM(CASE
             WHEN neighbourhood ='None' THEN 1
             ELSE 0
           END) AS neighbourhood_total_null_values,
       SUM(CASE
             WHEN room_type = 'None' THEN 1
             ELSE 0
           END) AS room_type_total_null_values,
       SUM(CASE
             WHEN price IS NULL THEN 1
             ELSE 0
           END) AS price_total_null_values,
       SUM(CASE
             WHEN minimum_nights IS NULL THEN 1
             ELSE 0
           END) AS minimum_nights_total_null_values,
       SUM(CASE
             WHEN number_of_reviews IS NULL THEN 1
             ELSE 0
           END) AS number_of_reviews_total_null_values,
		SUM(CASE
					 WHEN reviews_per_month IS NULL THEN 1
					 ELSE 0
				   END) AS reviews_per_month_total_null_values,
		SUM(CASE
					 WHEN calculated_host_listings_count IS NULL THEN 1
					 ELSE 0
				   END) AS calculated_host_listings_count_total_null_values,
		SUM(CASE
					 WHEN availability_365 IS NULL THEN 1
					 ELSE 0
				   END) AS availability_365_total_null_values
FROM   project_airbnb_3;




SELECT room_type, mode(minimum_nights) FROM project_airbnb_3  GROUP BY 1 ;

-- dealing minimum_nights null values with mode values of the same referring with each room_type
UPDATE project_airbnb_3 AS t1
INNER JOIN (
  SELECT room_type, 
         mode FROM (
           SELECT room_type, 
                  minimum_nights AS mode,
                  ROW_NUMBER() OVER (PARTITION BY room_type ORDER BY COUNT(*) DESC) AS rn 
           FROM project_airbnb_3
           WHERE minimum_nights IS NOT NULL
           GROUP BY room_type, minimum_nights
         ) AS temp
  WHERE rn = 1
) AS t2
ON t1.room_type = t2.room_type
SET t1.minimum_nights = t2.mode
WHERE t1.minimum_nights IS NULL;
-- TO BE BACK ON THIS

-- rechecking the null values of minimum_nights
SELECT COUNT(*) FROM project_airbnb_3
WHERE minimum_nights IS NULL;


-- dealing availability null values with mode values of the same referring with each room_type
UPDATE project_airbnb_3 AS t1
INNER JOIN (
  SELECT room_type, 
         mode FROM (
           SELECT room_type, 
                  availability_365 AS mode,
                  ROW_NUMBER() OVER (PARTITION BY room_type ORDER BY COUNT(*) DESC) AS rn -- availability_365 in order by
           FROM project_airbnb_3
           WHERE availability_365 IS NOT NULL
           GROUP BY room_type, availability_365
         ) AS temp
  WHERE rn = 1
) AS t2
ON t1.room_type = t2.room_type
SET t1.availability_365 = t2.mode
WHERE t1.availability_365 IS NULL;

-- rechecking the null values of availability
SELECT COUNT(*) FROM project_airbnb_3
WHERE availability_365 IS NULL;


-- Imputing null values of namess column with Others as we don't have info regarding them so will imputing them as others category
UPDATE project_airbnb_3
SET namess = 'Others'
WHERE namess ='None';


-- imputing the null values of number_of_reviews with mode values for each room_type
UPDATE project_airbnb_3
SET number_of_reviews = 
    CASE 
        WHEN room_type = 'Entire home/apt' THEN (
            SELECT IFNULL(number_of_reviews, 0) 
            FROM (
                SELECT number_of_reviews 
                FROM project_airbnb_3
                WHERE room_type = 'Entire home/apt' AND number_of_reviews IS NOT NULL 
                GROUP BY number_of_reviews 
                ORDER BY COUNT(*) DESC 
                LIMIT 1
            ) AS mode_subquery
        )
        WHEN room_type = 'Shared room' THEN (
            SELECT IFNULL(number_of_reviews, 0) 
            FROM (
                SELECT number_of_reviews 
                FROM project_airbnb_3
                WHERE room_type = 'Shared room' AND number_of_reviews IS NOT NULL 
                GROUP BY number_of_reviews 
                ORDER BY COUNT(*) DESC 
                LIMIT 1
            ) AS mode_subquery
        )
        WHEN room_type = 'Private room' THEN (
            SELECT IFNULL(number_of_reviews, 0) 
            FROM (
                SELECT number_of_reviews 
                FROM project_airbnb_3
                WHERE room_type = 'Private room' AND number_of_reviews IS NOT NULL 
                GROUP BY number_of_reviews 
                ORDER BY COUNT(*) DESC 
                LIMIT 1
            ) AS mode_subquery
        )
        ELSE number_of_reviews
    END
WHERE number_of_reviews IS NULL
;

-- rechecking the null values for number_of_reviews
SELECT COUNT(*) FROM project_airbnb_3
WHERE number_of_reviews IS NULL; -- 0

  
  

-- imputing the null borough values on the basis of neighbourhood as the neighbourhood null values are 0 and hence referring neighbourhood columns for imputation of boroughs.
UPDATE project_airbnb_3 AS p
LEFT JOIN (
    SELECT neighbourhood,
           MAX(CASE WHEN borough = 'Manhattan' THEN 'Manhattan' END) AS borough_manhattan,
           MAX(CASE WHEN borough = 'Bronx' THEN 'Bronx' END) AS borough_bronx,
           MAX(CASE WHEN borough = 'Brooklyn' THEN 'Brooklyn' END) AS borough_brooklyn,
           MAX(CASE WHEN borough = 'Queens' THEN 'Queens' END) AS borough_queens,
           MAX(CASE WHEN borough = 'Staten Island' THEN 'Staten Island' END) AS borough_staten_island
    FROM project_airbnb_3
    GROUP BY neighbourhood
) AS borough_data ON p.neighbourhood = borough_data.neighbourhood
SET p.borough =
    CASE 
        WHEN p.borough = 'None' THEN
            COALESCE(
                borough_data.borough_manhattan,
                borough_data.borough_bronx,
                borough_data.borough_brooklyn,
                borough_data.borough_queens,
                borough_data.borough_staten_island
            )
        ELSE p.borough
    END;   


-- dropping lattitude and longitude columns as they are irrelevant for the anaysis    
ALTER TABLE project_airbnb_3
DROP COLUMN latitude;
ALTER TABLE project_airbnb_3
DROP COLUMN longitude;


-- Dealing with outliers 
-- Calculate Q1, Q3, and IQR for "Entire home/apt" in Brooklyn

-- Calculate the number of rows for "Entire home/apt" in Brooklyn
DROP PROCEDURE IF EXISTS HandleOutliers;
-- Calculate the row numbers for Q1, Q3, and IQR
DELIMITER //
CREATE PROCEDURE HandleOutliers(IN borough_name VARCHAR(255), IN room_type_name VARCHAR(255))
BEGIN
    -- Calculate Q1, Q3, and IQR for the specified borough and room type
    SELECT COUNT(*) INTO @total_rows -- @ is used to make dynamic variable, we are storing values in dynamic variable
    FROM project_airbnb_3 
    WHERE borough = borough_name AND room_type = room_type_name;

    SET @Q1_row := CEIL(0.25 * @total_rows);
    SET @Q3_row := CEIL(0.75 * @total_rows);

    SELECT price INTO @Q1
    FROM (
        SELECT price, @rownum := @rownum + 1 AS row_numberr
        FROM project_airbnb_3,
        (SELECT @rownum := 0) r
        WHERE borough = borough_name AND room_type = room_type_name
        ORDER BY price
    ) AS ranked
    WHERE row_numberr = @Q1_row;

    SELECT price INTO @Q3
    FROM (
        SELECT price, @rownum := @rownum + 1 AS row_numberr
        FROM project_airbnb_3,
        (SELECT @rownum := 0) r
        WHERE borough = borough_name AND room_type = room_type_name
        ORDER BY price DESC
    ) AS ranked
    WHERE row_numberr = @Q3_row;

    SET @IQR := @Q3 - @Q1;

    -- Update the price column to cap outliers with upper and lower whisker values for the specified borough and room type
    UPDATE project_airbnb_3
    SET price = 
        CASE
            WHEN price > @Q3 + 1.5 * @IQR THEN @Q3 + 1.5 * @IQR
            WHEN price < @Q1 - 1.5 * @IQR THEN @Q1 - 1.5 * @IQR
            ELSE price
        END
    WHERE borough = borough_name AND room_type = room_type_name;
    
    
END //
DELIMITER ;






-- calling out the function
CALL HandleOutliers42('Brooklyn', 'Entire home/apt');

CALL HandleOutliers42('Brooklyn', 'Private room');

CALL HandleOutliers42('Brooklyn', 'Shared room');

CALL HandleOutliers42('Manhattan', 'Entire home/apt');

CALL HandleOutliers42('Manhattan', 'Private room');

CALL HandleOutliers42('Manhattan', 'Shared room');

CALL HandleOutliers('Bronx', 'Entire home/apt');

CALL HandleOutliers('Bronx', 'Private room');

CALL HandleOutliers('Bronx', 'Shared room');

CALL HandleOutliers('Staten Island', 'Entire home/apt');

CALL HandleOutliers('Staten Island', 'Private room');

CALL HandleOutliers('Staten Island', 'Shared room');

CALL HandleOutliers('Queens', 'Entire home/apt');

CALL HandleOutliers('Queens', 'Private room');

CALL HandleOutliers('Queens', 'Shared room');

/*
------------------------------------------------------------------------------
*/

/* Which boroughs and neighborhoods have the greatest residential housing stock 
used for home-rental accommodation?
*/
SELECT borough, neighbourhood, COUNT(*) AS stock_counts
FROM project_airbnb_3
GROUP BY 1, 2 
ORDER BY stock_counts DESC ;

--  
SELECT borough, count(*) FROM project_airbnb_3 GROUP BY 1;
/*
How do prices vary among the boroughs? Which borough is the most expensive?
*/
SELECT borough, SUM(price) AS stock_Prices
FROM project_airbnb_3
GROUP BY 1
ORDER BY stock_Prices DESC;

/*
Which room type is the most common? 
Which room type will appeal to a traveler whose accommodation is paid for by their company?
*/
SELECT room_type, COUNT(*) as Room_Type_counts
FROM project_airbnb_3
GROUP BY 1
ORDER BY Room_Type_counts DESC;
-- answer for 2nd part

/*
Which borough/neighborhood generates the highest revenue?
*/
SELECT borough, neighbourhood, SUM(price) AS Revenue, AVG(price) AS Revenue_per_unit
FROM project_airbnb_3
GROUP BY 1,2
ORDER BY Revenue DESC;

SELECT borough, SUM(price) AS Revenue, AVG(price) AS Revenue_per_unit
FROM project_airbnb_3
GROUP BY 1
ORDER BY Revenue DESC;

SELECT neighbourhood, SUM(price) AS Revenue, AVG(price) AS Revenue_per_unit
FROM project_airbnb_3
GROUP BY 1
ORDER BY Revenue DESC;


/*
How does availability differ among the boroughs?
*/
SELECT borough, COUNT(availability_365) AS availability
FROM project_airbnb_3
GROUP BY 1
ORDER BY availability DESC;

/*
Which boroughs should the company explore 
for expansion into the residential accommodation market in New York City? Why?
*/
SELECT borough, SUM(price) AS Revenue
FROM project_airbnb_3
GROUP BY 1
ORDER BY Revenue DESC;

SELECT borough, COUNT(*) AS most_frequent_borough
FROM project_airbnb_3
GROUP BY 1
ORDER BY most_frequent_borough DESC;


/*
Which hosts have more than one property up for rent? 
What is the maximum number of properties owned by one host?
*/
SELECT host_id,  COUNT(*) AS property_counts
FROM project_airbnb_3
GROUP BY 1
HAVING COUNT(*) > 1
ORDER BY property_counts DESC;









