-- TASK 1: Analyze annual sales by channels and regions.

WITH tmp AS( 
SELECT 
DISTINCT ON (cou.country_region, tim.calendar_year, cha.channel_desc)
cou.country_region, tim.calendar_year, cha.channel_desc
, round(sum(amount_sold) OVER (PARTITION BY cou.country_region_id, tim.calendar_year_id, sal.channel_id),0) AS AMOUNT_SOLD
, sum(amount_sold) OVER (PARTITION BY cou.country_region_id, tim.calendar_year_id, sal.channel_id)
/sum(amount_sold) OVER (PARTITION BY cou.country_region_id, tim.calendar_year_id)*100	 AS "% BY CHANNELS"
FROM sh.sales sal
JOIN sh.channels cha 
ON cha.channel_id = sal.channel_id 
JOIN sh.customers cus
ON cus.cust_id = sal.cust_id 
JOIN sh.countries cou 
ON cou.country_id = cus.country_id 
JOIN sh.times tim
ON tim.time_id = sal.time_id 
WHERE cou.country_region IN ('Americas', 'Asia', 'Europe')
AND 
tim.calendar_year IN (1998, 1999, 2000, 2001)
ORDER BY country_region ASC, calendar_year ASC, channel_desc ASC)
SELECT tmp2.country_region, tmp2.calendar_year, tmp2.channel_desc, tmp2.AMOUNT_SOLD AS "AMOUNT_SOLD"
, round(tmp2."% BY CHANNELS",2) AS "% BY CHANNELS"
, round(tmp1."% BY CHANNELS",2) AS "% PREVIOUS PERIOD"
, round(tmp2."% BY CHANNELS",2) - round(tmp1."% BY CHANNELS",2) AS "% DIFF"
FROM tmp tmp1, tmp tmp2
WHERE tmp1.country_region = tmp2.country_region AND tmp1.channel_desc = tmp2.channel_desc
AND tmp1.calendar_year = tmp2.calendar_year-1
;


-- TASK 2: Build the query to generate a sales report for the 49th, 50th and 51st weeks of 1999. Add column CUM_SUM for accumulated amounts within
--weeks. For each day, display the average sales for the previous, current and next days (centered moving average, CENTERED_3_DAY_AVG column).
--For Monday, calculate average weekend sales + Monday + Tuesday. For Friday, calculate the average sales for Thursday + Friday + weekends.
WITH tmp AS( 
SELECT 
DISTINCT ON (tim.calendar_week_number, tim.time_id, tim.day_name)
tim.calendar_week_number, tim.time_id, tim.day_name
, sum(sal.amount_sold) OVER (PARTITION BY tim.calendar_week_number, tim.time_id, tim.day_name) AS sales
FROM sh.sales sal
JOIN sh.channels cha 
ON cha.channel_id = sal.channel_id 
JOIN sh.customers cus
ON cus.cust_id = sal.cust_id 
JOIN sh.countries cou 
ON cou.country_id = cus.country_id 
JOIN sh.times tim
ON tim.time_id = sal.time_id 
WHERE tim.calendar_year IN (1999)
AND tim.calendar_week_number IN (48,49,50,51)
ORDER BY tim.calendar_week_number, tim.time_id, tim.day_name)
SELECT 
calendar_week_number, time_id, day_name, sales
, sum(sales) OVER (PARTITION BY calendar_week_number ORDER BY time_id ) as CUM_SUM
, CASE 
		WHEN 
			day_name = 'Monday' 
			THEN avg(sales) OVER (ORDER BY calendar_week_number,time_id, day_name ROWS BETWEEN 2 PRECEDING AND 1 FOLLOWING)
		WHEN day_name = 'Friday'
			THEN avg(sales) OVER (ORDER BY calendar_week_number,time_id, day_name ROWS BETWEEN 1 PRECEDING AND 2 FOLLOWING)
		ELSE
			avg(sales) OVER (ORDER BY calendar_week_number,time_id, day_name ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING)
	END	AS CENTERED_3_DAY_AVG
FROM tmp
WHERE calendar_week_number IN (49,50,51)
ORDER BY calendar_week_number, time_id, day_name
;

-- TASK 3: Prepare 3 examples of using window functions with a frame clause (RANGE, ROWS, and GROUPS modes)
-- Explain why you used a particular type of frame in each example. It can be one query or 3 separate queries.
  WITH Day_Sales AS (
  SELECT
   	sal.time_id, SUM(sal.amount_sold) AS amount_sold 
  FROM sh.sales sal
  WHERE time_id BETWEEN '1998-11-01' AND '1998-11-30'
  GROUP BY sal.time_id
  ORDER BY sal.time_id
  )
  SELECT 
  time_id
  ,	sum(amount_sold) OVER (PARTITION BY time_id)
  ,	round(sum(amount_sold) OVER (ORDER BY EXTRACT(DAY FROM time_id)  GROUPS BETWEEN 2 PRECEDING AND 2 FOLLOWING),0) AS GROUPS_5_day
  , array_agg(time_id) OVER (ORDER BY EXTRACT(DAY FROM time_id) GROUPS BETWEEN 2 PRECEDING AND 2 FOLLOWING) AS array_agg_GROUPS
  , round(avg(amount_sold) OVER (ORDER BY EXTRACT(DAY FROM time_id) ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING),0) AS ROWS_AVG_3DAY
  , array_agg(time_id) OVER (ORDER BY EXTRACT(DAY FROM time_id) ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS array_agg_ROWS
  , sum(amount_sold) OVER (ORDER BY  EXTRACT(DAY FROM time_id) RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RANGE_Cum_Total
  , array_agg(time_id) OVER (ORDER BY EXTRACT(DAY FROM time_id) RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS array_agg_RANGE
FROM Day_Sales
ORDER BY time_id
  ;
 -- I used ROWS because it need to calculate Average for the day. ROWS create fixed frame day befor and after
 -- GROUPS because for calculate 5 day amount of 5 day sales. GROUPS allow takes all values by row name from ORDER 
 -- it helps if we have any values by row name - i think it works like GROUP BY 
 -- RANGE - chose range for cumulative total
 -- range can takes 2 groups befor and 2 groups after curren group if it allows 
  
  

