-- TASK 1: The 5 largest customers are required for each channel.
SELECT ch.channel_desc, format('%s %s',cust.cust_last_name, cust.cust_first_name) AS FullName
-- Sum by channel and customers:
, sum(a.amount_sold) AS amount_sold
-- % calculated by channel:
, format('.%s %%', split_part(cast(ROUND((sum(a.amount_sold)/total.total_chanel)*100,5)as text),'.',2)) AS "sales_percentage, %"
FROM
	(SELECT sa.channel_id, sa.cust_id, sum(sa.amount_sold) AS amount_sold
-- Sum calculated by channel and customers:
	, RANK() OVER (PARTITION BY sa.channel_id ORDER BY sum(amount_sold) DESC ) rnk
	FROM sh.sales sa
JOIN sh.channels ch
ON sa.channel_id = ch.channel_id
JOIN sh.customers cust
ON cust.cust_id = sa.cust_id 
GROUP BY sa.channel_id, sa.cust_id) AS a
-- Total sum by channel
LEFT JOIN (SELECT channel_id, sum(amount_sold) AS total_chanel FROM sh.sales GROUP BY channel_id) AS total
ON total.channel_id=a.channel_id
JOIN sh.channels ch
ON a.channel_id = ch.channel_id
JOIN sh.customers cust
ON cust.cust_id = a.cust_id 
--LIMIT 5 customer by chnnel:
WHERE rnk <=5 
GROUP BY  a.cust_id, a.channel_id, ch.channel_id, cust.cust_id, total.total_chanel
ORDER BY sum(amount_sold) DESC 
;

-- TASK 2: Compose query to retrieve data for report with sales totals for all products in Photo category in Asia (use data for 2000 year). 
-- Calculate report total (YEAR_SUM).
-- TASK 2.1:
WITH Year_sales AS (
SELECT ti.calendar_quarter_desc , pro.prod_name 
, sum(sa.amount_sold) 
OVER (PARTITION BY pro.prod_id, ti.calendar_quarter_desc) 
AS total_amount 
,sum(sa.amount_sold) OVER (PARTITION BY pro.prod_id) AS YEAR_sum
FROM sh.sales sa
JOIN sh.products pro
ON pro.prod_id = sa.prod_id
JOIN sh.times ti 
ON ti.time_id = sa.time_id 
WHERE calendar_year = 2000 
AND pro.prod_category_id IN (SELECT p.prod_category_id  FROM sh.products p WHERE lower(p.prod_category)=lower('Photo'))
AND sa.cust_id IN (SELECT c.cust_id  FROM sh.customers c JOIN sh.countries c2 ON c.country_id = c2.country_id WHERE lower(c2.country_subregion) = lower('Asia'))
ORDER BY ti.calendar_quarter_desc, total_amount DESC)
SELECT prod_name,
       COALESCE (max(total_amount) filter (where calendar_quarter_desc = '2000-01'), 0) as "Q1",
       COALESCE (max(total_amount) filter (where calendar_quarter_desc = '2000-02'), 0) as "Q2",
       COALESCE (max(total_amount) filter (where calendar_quarter_desc = '2000-03'), 0) as "Q3",
       COALESCE (max(total_amount) filter (where calendar_quarter_desc = '2000-04') , 0)as "Q4",
       max(YEAR_sum) AS YEAR_sum
       FROM Year_sales
GROUP BY prod_name;

-- TASK 2.2:
CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT prod_name, COALESCE ("1Q2000",0) AS "1Q2000", COALESCE ("2Q2000",0) AS "2Q2000", COALESCE ("3Q2000",0) AS "3Q2000", COALESCE ("4Q2000",0) AS "4Q2000"
, sum(COALESCE ("1Q2000",0)+COALESCE ("2Q2000",0)+COALESCE ("3Q2000",0)+COALESCE ("4Q2000",0)) AS "Grand Total" FROM crosstab(
$$SELECT prod_name, calendar_quarter_number
, sum(sa.amount_sold) AS YEAR_sum  FROM sh.sales sa
JOIN sh.products pro
ON pro.prod_id = sa.prod_id
JOIN sh.times ti 
ON ti.time_id = sa.time_id 
WHERE calendar_year = 2000 
AND pro.prod_category_id IN (SELECT p.prod_category_id  FROM products p WHERE lower(p.prod_category)=lower('Photo'))
AND sa.cust_id IN (SELECT c.cust_id  FROM customers c JOIN countries c2 ON c.country_id = c2.country_id WHERE lower(c2.country_subregion) = lower('Asia'))
GROUP BY pro.prod_id, ti.calendar_quarter_number
ORDER BY prod_name, calendar_quarter_number$$)
AS YEAR_SUM (prod_name varchar(60) , "1Q2000" numeric, "2Q2000" numeric, "3Q2000" numeric, "4Q2000" numeric)
GROUP BY year_sum.prod_name, year_sum."1Q2000", year_sum."2Q2000", year_sum."3Q2000", year_sum."4Q2000"
ORDER BY year_sum.prod_name
;


--TASK 3:Build the query to generate a report about customers who were included into TOP 300 (based on the amount of sales) in 1998, 1999 and 2001.
--This report should separate clients by sales channels, and, at the same time, channels should be calculated independently
--(i.e. only purchases made on selected channel are relevant).
--TASK 3.1: TOP 300 By sales in 1998, 1999 and 2001. By Channel and Customer
SELECT DISTINCT ON (sum(sa.amount_sold) OVER(PARTITION BY sa.cust_id, sa.channel_id), sa.channel_id, sa.cust_id)ch.channel_desc, cust.cust_id, format('%s %s',cust.cust_last_name, cust.cust_first_name) AS FullName 
, sum(sa.amount_sold) OVER(PARTITION BY sa.cust_id, sa.channel_id) AS total_amount
FROM sh.sales sa
JOIN sh.times ti 
ON ti.time_id = sa.time_id 
JOIN sh.customers cust
ON cust.cust_id = sa.cust_id 
JOIN sh.channels ch
ON ch.channel_id  = sa.channel_id
WHERE ti.calendar_year  IN('1998', '1999', '2001') 
--GROUP BY  ch.channel_id, cust.cust_id , sa.amount_sold
ORDER BY total_amount DESC, sa.channel_id, sa.cust_id
LIMIT 300;

--TASK 3.2: TOP 300 customers who has sales in each year in 1998, 1999 and 2001. By Channel and Customer
-- Calculate sales for 1998 year
WITH sales1998 AS (
SELECT DISTINCT ON (sum(sa.amount_sold) OVER(PARTITION BY ti.calendar_year, sa.cust_id, sa.channel_id), sa.channel_id, sa.cust_id)ch.channel_desc, cust.cust_id, ti.calendar_year, format('%s %s',cust.cust_last_name, cust.cust_first_name) AS FullName 
, sum(sa.amount_sold) OVER(PARTITION BY ti.calendar_year,sa.cust_id, sa.channel_id) AS total_amount
FROM sh.sales sa
JOIN sh.times ti 
ON ti.time_id = sa.time_id 
JOIN sh.customers cust
ON cust.cust_id = sa.cust_id 
JOIN sh.channels ch
ON ch.channel_id  = sa.channel_id
WHERE ti.calendar_year  IN('1998') 
ORDER BY total_amount DESC, sa.channel_id, sa.cust_id
--LIMIT 300
),
-- Calculate sales for 1999 year
sales1999 AS (
SELECT DISTINCT ON (sum(sa.amount_sold) OVER(PARTITION BY ti.calendar_year, sa.cust_id, sa.channel_id), sa.channel_id, sa.cust_id)ch.channel_desc, cust.cust_id, ti.calendar_year, format('%s %s',cust.cust_last_name, cust.cust_first_name) AS FullName 
, sum(sa.amount_sold) OVER(PARTITION BY ti.calendar_year,sa.cust_id, sa.channel_id) AS total_amount
FROM sh.sales sa
JOIN sh.times ti 
ON ti.time_id = sa.time_id 
JOIN sh.customers cust
ON cust.cust_id = sa.cust_id 
JOIN sh.channels ch
ON ch.channel_id  = sa.channel_id
WHERE ti.calendar_year  IN('1999') 
ORDER BY total_amount DESC, sa.channel_id, sa.cust_id
--LIMIT 300
),
-- Calculate sales for 2001 year
sales2001 AS (
SELECT DISTINCT ON (sum(sa.amount_sold) OVER(PARTITION BY ti.calendar_year, sa.cust_id, sa.channel_id), sa.channel_id, sa.cust_id)ch.channel_desc, cust.cust_id, ti.calendar_year, format('%s %s',cust.cust_last_name, cust.cust_first_name) AS FullName 
, sum(sa.amount_sold) OVER(PARTITION BY ti.calendar_year,sa.cust_id, sa.channel_id) AS total_amount
FROM sh.sales sa
JOIN sh.times ti 
ON ti.time_id = sa.time_id 
JOIN sh.customers cust
ON cust.cust_id = sa.cust_id 
JOIN sh.channels ch
ON ch.channel_id  = sa.channel_id
WHERE ti.calendar_year  IN('2001') 
ORDER BY total_amount DESC, sa.channel_id, sa.cust_id
--LIMIT 300
)
-- Select TOP 300 customers who has sales in in 1998, 1999 and 2001 year by id=channel_id+cust_id
SELECT sales2001.channel_desc, sales2001.cust_id, sales2001.FullName
, (sales2001.total_amount+sales1999.total_amount+sales1998.total_amount) AS total_amount
FROM sales2001, sales1999, sales1998 
WHERE
(sales2001.channel_desc = sales1999.channel_desc AND sales1999.channel_desc = sales1998.channel_desc)
AND
(sales2001.cust_id = sales1999.cust_id AND sales1999.cust_id = sales1998.cust_id)
ORDER BY total_amount DESC
LIMIT 300
;


-- TASK 4: Build the query to generate the report about sales in America and Europe:
-- Conditions:
-- TIMES.CALENDAR_MONTH_DESC: 2000-01, 2000-02, 2000-03
--  COUNTRIES.COUNTRY_REGION: Europe, Americas.
WITH COUNTRY_REGION AS (
SELECT ti.calendar_month_desc , pro.prod_category_desc, c2.country_region, sum(sa.amount_sold) AS total_amount
FROM sh.sales sa
JOIN sh.products pro
ON pro.prod_id = sa.prod_id
JOIN sh.times ti 
ON ti.time_id = sa.time_id 
JOIN sh.customers c
ON c.cust_id = sa.cust_id 
JOIN sh.countries c2 
ON c.country_id = c2.country_id
WHERE ti.calendar_month_desc IN('2000-01', '2000-02', '2000-03') 
AND c2.country_region IN ('Europe', 'Americas')
GROUP BY pro.prod_id, ti.calendar_month_desc, c2.country_region
ORDER BY ti.calendar_month_desc, total_amount DESC)
SELECT calendar_month_desc, prod_category_desc,
       sum(total_amount) filter (where country_region = 'Americas') as "Americas SALES",
       sum(total_amount) filter (where country_region = 'Europe') as "Europe SALES"
FROM COUNTRY_REGION
GROUP BY calendar_month_desc, prod_category_desc
ORDER BY calendar_month_desc, prod_category_desc;
