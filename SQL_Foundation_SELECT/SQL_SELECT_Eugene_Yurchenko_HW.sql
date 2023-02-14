--1. All comedy movies released between 2000 and 2004, alphabetical category
SELECT
	f.title
FROM public.film_category fc 
JOIN public.film f
ON f.film_id = fc.film_id 
JOIN public.category c
ON fc.category_id = c.category_id 
WHERE upper(c.name) LIKE 'COMEDY' 				-- select ID films where category = comedy
AND release_year BETWEEN 2000 AND 2004
ORDER BY f.title ;

--2. Revenue of every rental store for year 2017 (columns: address and address2 – as one column, revenue)
SELECT 
	concat(a.address, a.address2) AS adress 	-- unite colmn address AND address2
	, SUM(p.amount) AS revenue					-- Revenue of rental store
FROM public.payment p 
JOIN public.customer c 
ON p.customer_id =c.customer_id 				-- customer TABLE use FOR CONNECT payment AND store
JOIN public.store s
ON s.store_id = c.store_id
JOIN public.address a 
ON s.address_id = a.address_id 
WHERE EXTRACT (year  FROM  p.payment_date) =2017 -- EXTRACT YEAR FROM payment_date
GROUP BY s.store_id, a.address, a.address2  
 ;
--3. Top-3 actors by number of movies they took part in (columns: first_name, last_name, number_of_movies, sorted by
--   number_of_movies in descending order)
SELECT
	a.first_name 
	, a.last_name
	, COUNT (f.film_id) AS  number_of_movies 	-- Calculated filmes FOR EACH actor
FROM public.film f
JOIN public.film_actor fa
ON f.film_id = fa.film_id 						-- film_actor TABLE use FOR CONNECT actor AND film
JOIN public.actor a 
ON a.actor_id = fa.actor_id 
GROUP BY fa.actor_id,a.first_name, a.last_name
ORDER BY COUNT(f.film_id) DESC 
FETCH FIRST 3 ROWS WITH TIES					-- TOP 3 actors
;

--4. Number of comedy, horror and action movies per year (columns: release_year, number_of_action_movies,
--   number_of_horror_movies, number_of_comedy_movies), sorted by release year in descending order 
SELECT
		f.release_year 
		, COUNT(f.film_id) FILTER (WHERE c.name ='Action')	 AS 	number_of_action_movies
		, COUNT(f.film_id) FILTER (WHERE c.name ='Horror')	 AS 	number_of_horror_movies
		, COUNT(f.film_id) FILTER (WHERE c.name ='Comedy')	 AS 	number_of_comedy_movies
FROM public.film f
JOIN public.film_category fc 
ON f.film_id =fc.film_id 
JOIN public.category c
ON fc.category_id = c.category_id  
GROUP BY f.release_year
ORDER BY f.release_year DESC;


--5. Which staff members made the highest revenue for each store and deserve a bonus for 2017 year?
SELECT 
	DISTINCT ON (s.store_id) s.store_id					-- SELECT one single value FROM each group
	, concat(a.address, a.address2) AS adress			-- Store address
	, s.first_name ||' '|| s.last_name AS staff_name 	-- unite colmn first AND last name
	, SUM(p.amount) AS revenue							-- Revenue of rental store
FROM public.payment p 
JOIN public.staff s 
ON p.staff_id = s.staff_id 
JOIN public.store s2  
ON s2.store_id = s.store_id
JOIN public.address a  
ON s2.address_id = a.address_id 
WHERE EXTRACT (YEAR  FROM  p.payment_date) =2017		 
GROUP BY s.store_id , s.staff_id, s2.address_id,a.address, a.address2
ORDER BY s.store_id, SUM(p.amount) DESC					-- Sort BY store AND max TO min sum of amount
;

--6. Which 5 movies were rented more than others and what's expected audience age for those movies?
SELECT 
	f.title 
	--,COUNT (r.rental_id)
	,CASE 	WHEN f.rating ='G' THEN '0-99'			-- expected audience age
			WHEN f.rating ='PG' THEN '14-99'		-- expected audience age
			WHEN f.rating ='PG-13' THEN '14-99'		-- expected audience age
			WHEN f.rating ='NC-17' THEN '18-99'		-- expected audience age
			WHEN f.rating ='R' THEN '18-99'			-- expected audience age
	END AS audienceAge
	FROM public.film f
JOIN public.inventory i 
ON f.film_id = i.film_id 
JOIN public.rental r 
ON i.inventory_id = r.inventory_id 
GROUP BY f.film_id,f.rating
HAVING COUNT (r.rental_id)>=						-- compare funded in next step number of films with all films								
(SELECT DISTINCT (fc.filmcount) AS filmcount FROM (		
SELECT 												-- count rental films FOR ALL films
	COUNT (r.rental_id) AS filmcount
	FROM public.film f
JOIN public.inventory i 
ON f.film_id = i.film_id 
JOIN public.rental r 
ON i.inventory_id = r.inventory_id 
GROUP BY f.film_id
ORDER BY COUNT(r.rental_id) DESC ) fc												
ORDER BY fc.filmcount DESC 							-- Sort number films FROM max TO min
LIMIT 1 OFFSET 4									-- find number films FOR 5th film.
)
ORDER BY COUNT (r.rental_id) DESC
FETCH FIRST 5 ROWS WITH TIES
;

--7.1 Which actors/actresses didn't act for a longer period of time than others?
WITH tmp AS (																	-- TABLE WITH actors AND films which actors played
	SELECT
		a.actor_id
		,a.first_name
		, a.last_name
		, f.release_year 
	FROM public.actor a 
	JOIN film_actor fa 
	ON a.actor_id = fa.actor_id 
	JOIN film f 
	ON fa.film_id = f.film_id 
	ORDER BY a.actor_id, f.release_year DESC)
SELECT
		t.first_name||' '|| t.last_name AS ActorFullName						-- Name AND LAST name IN one string
		, date_part('year', CURRENT_DATE)-max(t.release_year) AS didntactperiod
FROM tmp t
GROUP BY t.actor_id, t.first_name, t.last_name
HAVING date_part('year', CURRENT_DATE)-max(t.release_year) IN 
				(SELECT 
						date_part('year', CURRENT_DATE)-max(t.release_year) AS didntactperiod -- count number of years TO CURRENT DAY for EACH actor
				FROM tmp t
				GROUP BY t.actor_id, t.first_name, t.last_name
				ORDER BY date_part('year', CURRENT_DATE)-max(t.release_year) DESC
				LIMIT 1																		  -- select actor with max number years from LAST film
				)
ORDER BY date_part('year', CURRENT_DATE)-max(t.release_year) DESC
;

--7.2 Which actors/actresses didn't act for a longer period of time than others?
WITH tmp AS (																	-- TABLE WITH actors AND films which actors played
	SELECT
		a.actor_id
		, a.first_name
		, a.last_name
		,f.release_year
		, (	SELECT max(DISTINCT f1.release_year ) AS release_year 				-- ADD COLUMN WITH previous YEAR
			FROM public.actor a1 
			JOIN film_actor fa1 
			ON a1.actor_id = fa1.actor_id 
			JOIN film f1 
			ON fa1.film_id = f1.film_id  
			WHERE f1.release_year<f.release_year AND a1.actor_id=a.actor_id 
			)AS prev_release_year
	FROM public.actor a 
	JOIN film_actor fa 
	ON a.actor_id = fa.actor_id 
	JOIN film f 
	ON fa.film_id = f.film_id 
	GROUP BY a.actor_id,f.release_year, a.first_name, a.last_name
	ORDER BY a.actor_id, f.release_year DESC)
SELECT
	t.first_name
	,t.last_name
	,(release_year-prev_release_year-1) AS didntact									  -- calculate didnt act period
FROM tmp t
GROUP BY t.first_name, t.last_name,t.release_year,t.prev_release_year
HAVING max(release_year-prev_release_year-1) = (release_year-prev_release_year-1) -- SELECT ONLY max value FOR EACH actor
ORDER BY (release_year-prev_release_year-1) DESC 
FETCH FIRST 1 ROWS WITH TIES													  -- SELECT TOP 1




