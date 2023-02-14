CREATE OR REPLACE FUNCTION public.dvd_customer_metrics(p_client_id integer, left_boundary timestamp without time zone, right_boundary timestamp without time zone)
 RETURNS TABLE(metric_name text, metric_value text)
 LANGUAGE sql
AS $function$
WITH tmp AS(
SELECT 
	format('%s %s, %s', INITCAP(first_name), INITCAP(last_name), lower(email)) AS names
	, count(r.customer_id) AS films_rented 
	, string_agg(f.title ::text, ', ') AS titles
	, count (p.customer_id) AS payments 
	, SUM(p.amount) AS amount
FROM customer c 
	JOIN rental r ON c.customer_id = r.customer_id 
	JOIN inventory i ON r.inventory_id = i.inventory_id 
	JOIN film f ON i.film_id = f.film_id 
	JOIN payment p ON r.rental_id = p.rental_id 
WHERE c.customer_id = $1
AND r.rental_date BETWEEN date_trunc('day', $2) AND  (date_trunc('day', $3) + interval '1 day' - interval '1 second') 
GROUP BY c.customer_id)
	SELECT 'customers info' AS metric_name, (SELECT names) AS metric_value FROM tmp
	UNION ALL 
	SELECT 'num. of films rented', (SELECT CAST(films_rented AS TEXT)) FROM tmp
	UNION ALL 
	SELECT 'rented films titles', (SELECT titles) FROM tmp
	UNION ALL 
	SELECT 'num. of payments', (SELECT CAST(payments AS TEXT)) FROM tmp
	UNION ALL 
	SELECT 'payments amount', (SELECT CAST(amount AS TEXT)) FROM tmp
$function$
;

SELECT * FROM dvd_customer_metrics(252, '2017-01-14','2017-01-14')
