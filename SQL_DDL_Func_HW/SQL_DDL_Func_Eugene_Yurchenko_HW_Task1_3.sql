
-- Create a function that will return a list of films by part of the title in stock (for example, films with the word 'love' in the title).
CREATE FUNCTION get_film(varchar) RETURNS TABLE 
(
	film_title text
	, film_row_numer bigint
	, film_language character(20)
	, film_customer_name text
	, film_rental_date timestamp
) 
AS $$
BEGIN
DROP SEQUENCE IF EXISTS row_n;
CREATE SEQUENCE row_n START 1;
    RETURN QUERY SELECT
	 DISTINCT ON (f.title)f.title  AS film
	, nextval('row_n') AS Row_num
	, l.name AS LANGUAGE
	, format('%s %s', c.first_name, c.last_name) AS Customer_name  
	, r.rental_date::timestamp AS Rental_dates
FROM public.film f
JOIN public.language l USING (language_id)
JOIN public.inventory i USING (film_id)
JOIN public.rental r USING (inventory_id)
JOIN public.customer c USING (customer_id)
WHERE f.title ilike $1 
GROUP BY f.film_id, l.language_id, c.customer_id, r.rental_id  
ORDER BY f.title, r.rental_date DESC;
    IF NOT FOUND THEN
        RAISE NOTICE 'A movie with Title %  was not found', $1;
    END IF;
    RETURN;
 END;
$$
LANGUAGE plpgsql;

SELECT * FROM get_film ('%LORD%');




--Create a function that will return the most popular film for each country (where country is an input paramenter)
CREATE OR REPLACE FUNCTION get_Country (p_country TEXT[] ) 
RETURNS TABLE (
	film_Country varchar
	, film_Title varchar
	, film_Rating varchar
	, film_language varchar
	, film_Length int
	, film_Release_year int
)
AS $$
WITH tmp as(
SELECT DISTINCT ON (cou.country_id)cou.country_id AS country_id
,cou.country
, count(r.rental_id) AS cntrent
FROM public.film f
JOIN public.language l USING (language_id)
JOIN public.inventory i USING (film_id)
JOIN public.rental r USING (inventory_id)
JOIN public.customer c USING (customer_id)
JOIN public.address a USING (address_id)
JOIN public.city c2 USING (city_id)
JOIN public.country cou USING (country_id)
GROUP BY cou.country_id, f.film_id 
ORDER BY cou.country_id,cntrent DESC 
)
SELECT  
    cou.country AS Country
	,f.title AS film
	,f.rating AS Rating
	, l.name AS LANGUAGE
	, f.length AS Length 
	, f.release_year AS Release_year
FROM public.film f
JOIN public.language l USING (language_id)
JOIN public.inventory i USING (film_id)
JOIN public.rental r USING (inventory_id)
JOIN public.customer c USING (customer_id)
JOIN public.address a USING (address_id)
JOIN public.city c2 USING (city_id)
JOIN public.country cou USING (country_id)
JOIN tmp ON cou.country_id = tmp.country_id
WHERE cou.country = any($1)
GROUP BY cou.country_id, f.film_id,tmp.cntrent, l.language_id 
HAVING count(r.rental_id)=tmp.cntrent
ORDER BY cou.country,  count(r.rental_id) DESC
$$ language sql;

SELECT * FROM get_Country (ARRAY['India','Afghanistan','Canada']::text[]);

--Create function that inserts new movie with the given name in �film� table. 
--�release_year�, �language� are optional arguments and default to current year and
--Russian respectively. The function must return film_id of the inserted movie. 
CREATE OR REPLACE FUNCTION Insert_into_films (new_title varchar(50),release_year INTEGER DEFAULT extract(year FROM now()) ,language varchar(50) DEFAULT 'English') RETURNS int
AS $$ 
BEGIN
	    IF $3 NOT IN (SELECT name FROM public.LANGUAGE) THEN
	   RAISE NOTICE 'Language %  was not found', $3;
    --END IF;
ELSIF new_title NOT IN (SELECT title FROM public.film) THEN 
INSERT INTO public.film (title, release_year, language_id) 
values(new_title, release_year,(SELECT language_id FROM LANGUAGE WHERE name=$3));
END IF;
RETURN (SELECT film_ID FROM public.film WHERE title ilike $1 ) AS film_ID;
END; $$ LANGUAGE plpgSQL;

SELECT * FROM Insert_into_films('YOUNG LANGUAGE RETURN VII',1960,'French');