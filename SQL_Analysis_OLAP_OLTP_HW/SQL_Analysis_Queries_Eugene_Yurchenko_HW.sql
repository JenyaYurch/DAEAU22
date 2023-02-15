-- Find the top 10 most sales and top 10 most unsales products

WITH First10 AS (
SELECT prod_name, sum(amount_sold) AS total_amount
FROM sh.sales sal
JOIN sh.products pro
ON sal.prod_id = pro.prod_id 
GROUP BY prod_name
ORDER BY total_amount DESC 
LIMIT 10
),
Last10 AS (
SELECT prod_name, sum(amount_sold) AS total_amount
FROM sh.sales sal
JOIN sh.products pro
ON sal.prod_id = pro.prod_id 
GROUP BY prod_name
ORDER BY total_amount ASC 
LIMIT 10
)
SELECT	'--FIRST 10 PRODUCTS BY SALES--', NULL
UNION ALL
SELECT *
FROM First10
UNION ALL
SELECT	'--LAST 10 PRODUCTS BY SALES--', NULL
UNION ALL
SELECT *
FROM Last10
;

-- Calculate dynamic sales by channels and year/month
WITH Year_sales AS (
SELECT ti.calendar_year, ch.channel_desc, sum(sa.amount_sold) AS total_amount
FROM sh.sales sa
JOIN sh.channels ch
ON ch.channel_id = sa.channel_id 
JOIN sh.times ti 
ON ti.time_id = sa.time_id 
GROUP BY ch.channel_id, ti.calendar_year
ORDER BY ti.calendar_year, total_amount DESC)
SELECT channel_desc,
       max(total_amount) filter (where calendar_year = 1998) as "1998",
       max(total_amount) filter (where calendar_year = 1999) as "1999",
       max(total_amount) filter (where calendar_year = 2000) as "2000",
       max(total_amount) filter (where calendar_year = 2001) as "2001",
       max(total_amount) filter (where calendar_year = 2001) as "2002"
FROM Year_sales
GROUP BY channel_desc;

-- How much do we spend and how much do we earn money by promotions?
SELECT pr.promo_name, pr.promo_cost AS promo_cost, sum(sa.amount_sold) AS promo_amount, (sum(sa.amount_sold)-pr.promo_cost) AS profits
FROM sh.sales sa
RIGHT JOIN sh.promotions pr
ON pr.promo_id = sa.promo_id AND pr.promo_id NOT IN ('999')
GROUP BY pr.promo_id
ORDER BY profits;

