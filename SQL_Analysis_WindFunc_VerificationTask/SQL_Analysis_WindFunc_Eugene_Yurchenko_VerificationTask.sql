-- TASK 1: Build the query to generate a report about regions 
-- with the maximum number of products sold (quantity_sold) for each channel for the entire period.

WITH RANK_channel AS (
SELECT sal.channel_id , cha.channel_desc, cou.country_region 
, sum(sal.quantity_sold) AS sales 
, RANK() OVER (PARTITION BY cha.channel_desc ORDER BY sum(sal.quantity_sold) DESC ) rnk
FROM sh.sales sal
JOIN sh.customers cus
ON cus.cust_id = sal.cust_id 
JOIN sh.countries cou 
ON cou.country_id  = cus.country_id 
JOIN sh.channels cha 
ON cha.channel_id = sal.channel_id
GROUP BY sal.channel_id, cha.channel_desc, cou.country_region,sal.quantity_sold
ORDER BY cou.country_region)
SELECT channel_desc, country_region, sales
, TO_CHAR(round((sales/total_chanel)*100,2), 'fm00D00%') AS "SALES %"
FROM RANK_channel r
LEFT JOIN (SELECT channel_id, sum(quantity_sold) AS total_chanel FROM sh.sales GROUP BY channel_id) AS total
ON total.channel_id=r.channel_id
WHERE r.rnk = 1
ORDER BY sales DESC;

-- TASK 2: Define subcategories of products (prod_subcategory) for which sales for 1998-2001 have always been higher (sum(amount_sold))
-- compared TO the previous year. The final dataset must include only one column (prod_subcategory).

WITH tmp AS (
SELECT pro.prod_subcategory_id, pro.prod_subcategory, tim.calendar_year
, sum(sal.amount_sold) AS sales 
, LAG(sum(sal.amount_sold),1) OVER (PARTITION BY pro.prod_subcategory_id ORDER BY calendar_year	) AS prev_year
,CASE WHEN (sum(sal.amount_sold) -  COALESCE (LAG(sum(sal.amount_sold),1) OVER (PARTITION BY pro.prod_subcategory_id ORDER BY calendar_year	),0)) > 0 THEN 1
ELSE 0 END  AS cou_year
,count(tim.calendar_year) OVER (PARTITION BY pro.prod_subcategory_id RANGE CURRENT ROW	) AS count_sales_year
FROM sh.sales sal
JOIN sh.times tim 
ON tim.time_id = sal.time_id 
JOIN sh.products pro 
ON pro.prod_id = sal.prod_id
GROUP BY pro.prod_subcategory_id, pro.prod_subcategory, tim.calendar_year
ORDER BY pro.prod_subcategory_id, tim.calendar_year
)
SELECT 
prod_subcategory
FROM tmp
GROUP BY prod_subcategory_id, prod_subcategory, cou_year, count_sales_year
HAVING sum(cou_year)=count_sales_year
;
