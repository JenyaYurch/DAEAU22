	-- 1. Top-3 most selling movie categories of all time and total dvd rental income for each category. 
	-- Only consider dvd rental customers from the USA.
	
SELECT 
	c.category_id  AS category
	,c.name AS categoryname 
	, SUM(p.amount) AS total 			-- calculate total ammount per group
FROM payment p 
	JOIN rental r 			ON p.rental_id = r.rental_id 
	JOIN customer c2 		ON r.customer_id = c2.customer_id 
	JOIN inventory i 		ON i.inventory_id = r.inventory_id 
	JOIN film f				ON f.film_id = i.film_id 
	JOIN film_category fc	ON fc.film_id  = f.film_id 
	JOIN category c 		ON c.category_id = fc.category_id 
	JOIN address a 			ON c2.address_id = a.address_id 
	JOIN city				ON city.city_id = a.city_id 
	JOIN country c3			ON c3.country_id = city.country_id 
WHERE c3.country = 'United States'
GROUP BY c.category_id
ORDER BY total DESC 
FETCH FIRST 3 ROWS WITH TIES
;
	
-- 2. For each client, display a list of horrors that he had ever rented (in one column, separated by commas),
-- and the amount of money that he paid for it
	
SELECT 
	c2.first_name ||' '|| c2.last_name AS FIO			-- Customers FName AND LName
	,STRING_AGG(f.title,',')							-- IN one ROW ALL titles
	,SUM(p.amount) as total
FROM customer c2 
	JOIN address a 			ON c2.customer_id = a.address_id 
	JOIN city				ON city.city_id = a.address_id 
	JOIN country c3			ON c3.country_id = city.country_id 
	JOIN payment p			ON p.customer_id = c2.customer_id 
	JOIN rental r			ON p.rental_id = r.rental_id 
	JOIN inventory i		ON i.inventory_id = r.inventory_id 
	JOIN film f 			ON f.film_id = i.film_id 
	JOIN film_category fc	ON fc.film_id  = f.film_id 
	JOIN category c 		ON c.category_id = fc.category_id 
WHERE upper(c.name) LIKE 'HORROR'
GROUP BY FIO
ORDER BY fio,total desc
	