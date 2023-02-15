-- Build the query to generate sales report for 1999 and 2000 in the context of quarters and product categories. 
-- In the report you should analyze the sales of products from the categories 'Electronics', 'Hardware' and 'Software/Other', through the channels 'Partners' and 'Internet':


SELECT 
	t.calendar_year
	,t.calendar_quarter_desc
	,p.prod_category
	,to_char(SUM(s.amount_sold), '999,999,999.99') AS "sales$"
	,CASE 	
		WHEN (rank() over w1) = 1 THEN 'N/A' ::VARCHAR 
		ELSE to_char(((SUM(s.amount_sold) / first_value(SUM(s.amount_sold)) over w1) - 1) * 100, '999999.99') || '%' 
	 END AS diff_percent
	, to_char(SUM(SUM(s.amount_sold)) over w2, '999,999,999.99') AS "cum_sum$"
FROM sh.sales s 
	INNER JOIN sh.times t ON s.time_id = t.time_id 
	INNER JOIN sh.products p ON s.prod_id = p.prod_id 
	INNER JOIN sh.channels c ON s.channel_id = c.channel_id 
WHERE t.calendar_year BETWEEN 1999 AND 2000 
AND upper(p.prod_category) IN ('ELECTRONICS', 'HARDWARE', 'SOFTWARE/OTHER') 
AND upper(c.channel_desc) IN ('PARTNERS', 'INTERNET') 
GROUP BY t.calendar_year, t.calendar_quarter_desc, p.prod_category 
WINDOW 	 w1 AS(PARTITION BY t.calendar_year, p.prod_category ORDER BY t.calendar_quarter_desc)
		,w2 AS(PARTITION BY t.calendar_year ORDER BY t.calendar_quarter_desc groups BETWEEN unbounded preceding AND CURRENT ROW) 
ORDER BY t.calendar_year, t.calendar_quarter_desc, SUM(s.amount_sold) DESC;
