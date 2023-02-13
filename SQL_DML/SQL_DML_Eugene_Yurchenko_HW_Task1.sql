-- TASK 1
-- 1.1 Choose your top-3 favorite movies and add them to 'film' table. Fill rental rates with 4.99, 9.99 and 19.99
-- and rental durations with 1, 2 and 3 weeks respectively.
    
INSERT INTO public.film
    (title, description, release_year, language_id, rental_duration, rental_rate, length, replacement_cost, rating, last_update)
SELECT title, description, release_year, lang.language_id, rental_duration, rental_rate, length, replacement_cost, rating, new_films.last_update
FROM
    (SELECT 'Episode IV – A New Hope' AS title, 'Amid a galactic civil war Rebel Alliance spies have stolen plans to the Galactic Empire''s Death Star' AS description, 1977 AS release_year, 'English' AS language, 1 AS rental_duration, 4.99 AS rental_rate, 121 AS length, 14.99 AS replacement_cost, 'PG'::public."mpaa_rating" AS rating, now() AS last_update
    UNION ALL
    SELECT 'Episode V – The Empire Strikes Back', 'Three years after the destruction of the Death Star,[c] the Imperial fleet, led by Darth Vader, dispatches Probe Droids across the galaxy to find Princess Leia''s Rebel Alliance', 1980, 'English', 2, 9.99, 124, 14.99, 'PG'::public."mpaa_rating", now()
    UNION ALL
    SELECT 'Episode VI – Return of the Jedi', 'A year after Han Solo''s capture,[b] C-3PO and R2-D2 are sent to crime lord Jabba the Hutt''s palace on Tatooine', 1983, 'English', 3, 19.99, 132, 14.99, 'PG'::public."mpaa_rating", now()) AS new_films
INNER JOIN language lang 
ON new_films.LANGUAGE = lang."name"
WHERE new_films.title NOT IN (SELECT title FROM public.film)
RETURNING film_id, title
; 

-- 1.2 Add actors who play leading roles in your favorite movies to 'actor' and 'film_actor' tables 
--(6 or more actors in total)
INSERT INTO public.actor
	(first_name, last_name, last_update)
SELECT first_name, last_name, last_update
FROM
	(SELECT 'Mark' AS first_name, 'Hamill' AS last_name, now() AS last_update
	UNION ALL
    SELECT 'Harrison', 'Ford', now()
	UNION ALL
    SELECT'William', 'Katt', now()
	UNION ALL
    SELECT'Robby', 'Benson', now()
	UNION ALL
    SELECT 'Carrie', 'Fisher', now()
	UNION ALL
    SELECT 'Jodie', 'Foster', now())AS new_actor
WHERE (new_actor.first_name, new_actor.last_name) NOT IN (SELECT first_name, last_name FROM public.actor)
RETURNING actor_id, first_name, last_name, last_update
	;
   
INSERT INTO public.film_actor
	(actor_id, film_id, last_update)
SELECT act.actor_id, fil.film_id, new_film_actor.last_update
FROM
	(SELECT 'Mark'||'Hamill' AS fl_name, 'Episode IV – A New Hope' AS title, now()  AS last_update
	UNION ALL
    SELECT 'Harrison'||'Ford', 'Episode IV – A New Hope', now()
    UNION ALL
    SELECT 'William'||'Katt', 'Episode V – The Empire Strikes Back', now()
    UNION ALL
    SELECT 'Robby'||'Benson', 'Episode V – The Empire Strikes Back', now()
    UNION ALL
    SELECT 'Carrie'||'Fisher', 'Episode VI – Return of the Jedi', now()
    UNION ALL
    SELECT 'Jodie'||'Foster', 'Episode VI – Return of the Jedi', now()) new_film_actor
    INNER JOIN public.film AS fil
    ON new_film_actor.title = fil."title"
    INNER JOIN public.actor AS act
    ON new_film_actor.fl_name=act.first_name || act.last_name 
 	WHERE new_film_actor.fl_name || new_film_actor.title  
 	NOT IN (SELECT actor.first_name ||actor.last_name ||film.title  FROM public.film 
 	INNER JOIN public.film_actor 
 	ON film.film_id = film_actor.film_id
 	INNER JOIN public.actor 
 	ON film_actor.actor_id = actor.actor_id)
 	RETURNING actor_id, film_id, last_update
    ;

-- 1.3 Add your favorite movies to any store's inventory
INSERT INTO public.inventory
	(film_id, store_id, last_update)
SELECT fil.film_id, addr.address_id , new_inventory.last_update
FROM
	(SELECT 'Episode IV – A New Hope' AS title, '47 MySakila Drive' AS address, now() AS last_update
	UNION ALL
    SELECT 'Episode V – The Empire Strikes Back', '47 MySakila Drive', now()
    UNION ALL
    SELECT 'Episode VI – Return of the Jedi', '47 MySakila Drive', now()) AS new_inventory
	INNER JOIN public.film AS fil
    ON new_inventory.title = fil."title"
    INNER JOIN address addr 
    ON new_inventory.address = addr."address"
    RETURNING *
	;

-- 1.4 Alter any existing customer in the database who has at least 43 rental and 43 payment records. Change his/her personal data to yours (first name,
-- last name, address, etc.). Do not perform any updates on 'address' table, as it can impact multiple records with the same address. Change
-- customer's create_date value to current_date.

WITH AnyCustomer AS(
SELECT 
	c.customer_id
FROM payment p 
JOIN rental r 
	ON p.rental_id = r.rental_id 
JOIN inventory i 
	ON r.inventory_id = i.inventory_id 
JOIN store s 
	ON i.store_id = s.store_id 
JOIN customer c 
	ON p.customer_id = c.customer_id 
GROUP BY c.customer_id
HAVING 	count(r.rental_id) = count(p.payment_id)
		AND count(r.rental_id)>42
		AND count(p.payment_id)>42	
ORDER BY random()
LIMIT 1)
UPDATE public.customer
SET store_id=1, first_name='EUGENE', last_name='YURCHENKO', email='jenyayurch@gmail.com', address_id=370, activebool=true, create_date=current_date::text::date, last_update=now(), active=1
WHERE	customer_id IN (SELECT customer_id FROM AnyCustomer) 
		and 'jenyayurch@gmail.com' NOT IN (SELECT email FROM public.customer );

SELECT *  FROM customer c 
WHERE email='jenyayurch@gmail.com';

-- 1.5 Remove any records related to you (as a customer) from all tables except 'Customer' and 'Inventory'

WITH MyID AS (SELECT customer_id  FROM customer c 
				WHERE email='jenyayurch@gmail.com')
DELETE FROM public.payment
WHERE customer_id IN (SELECT customer_id FROM MyID);

WITH MyID AS (SELECT customer_id  FROM customer c 
				WHERE email='jenyayurch@gmail.com')
DELETE FROM public.rental
WHERE customer_id IN (SELECT customer_id FROM MyID);


-- 1.6 Rent you favorite movies from the store they are in and pay for them (add corresponding records to the database to represent this activity)
WITH Free_dvd AS (
SELECT i.inventory_id, f.title  FROM inventory i
INNER JOIN film f 
ON i.film_id = f.film_id 
GROUP BY i.inventory_id, f.title
HAVING mod(count(i.inventory_id),2)<>0
) 								-- select only DVD to which returned to the store 
INSERT INTO public.rental
	(rental_date, inventory_id, customer_id,  staff_id, last_update)
SELECT rental_date, inventory_id, customer_id,  staff.staff_id , new_rental.last_update
FROM 
	(SELECT date ('2017-01-14 15:15:15.291 +0100') AS rental_date, (SELECT inventory_id FROM Free_dvd WHERE title = 'Episode IV – A New Hope' LIMIT 1) AS inventory_id, (SELECT customer_id  FROM customer c WHERE email='jenyayurch@gmail.com') AS customer_id,NULL, 'Hanna.Carry@sakilastaff.com' AS email, now() AS last_update 
	UNION ALL
    SELECT date ('2017-01-14 15:25:15.291 +0100'), (SELECT inventory_id FROM Free_dvd WHERE title = 'Episode V – The Empire Strikes Back' LIMIT 1), (SELECT customer_id  FROM customer c WHERE email='jenyayurch@gmail.com'),NULL, 'Hanna.Carry@sakilastaff.com', now()
    UNION ALL
    SELECT date ('2017-01-14 15:35:15.291 +0100'), (SELECT inventory_id FROM Free_dvd WHERE title = 'Episode VI – Return of the Jedi' LIMIT 1), (SELECT customer_id  FROM customer c WHERE email='jenyayurch@gmail.com'),NULL, 'Hanna.Carry@sakilastaff.com', now()) AS new_rental
   INNER JOIN staff  
   ON new_rental.EMAIL = staff.EMAIL 
   WHERE new_rental.inventory_id>0                               -- INSERT DATA IF DVD is in the store
   RETURNING *
    ;

   WITH rentID AS (
   SELECT p.payment_id, r.rental_id,f.title, r.rental_date FROM rental r
   INNER JOIN inventory i 
   ON i.inventory_id =r.inventory_id 
   INNER JOIN film f 
   ON f.film_id = i.film_id 
   LEFT JOIN public.payment p
   ON p.rental_id = r.rental_id
   WHERE r.customer_id = (SELECT customer_id  FROM customer c WHERE email='jenyayurch@gmail.com')
   AND f.title IN ('Episode IV – A New Hope','Episode V – The Empire Strikes Back','Episode VI – Return of the Jedi'))
   INSERT INTO public.payment 
	(customer_id, staff_id, rental_id, amount, payment_date)
	SELECT	new_payment.customer_id, staff.staff_id, rental_id, amount, payment_date
FROM
	(SELECT (SELECT customer_id  FROM customer c WHERE email='jenyayurch@gmail.com') AS customer_id, 'Hanna.Carry@sakilastaff.com' AS email, (SELECT rental_id FROM rentID WHERE title='Episode IV – A New Hope') AS rental_id , 4.99 AS amount , date('2017-01-14 15:15:15.291 +0100') AS payment_date
	UNION ALL
    SELECT (SELECT customer_id  FROM customer c WHERE email='jenyayurch@gmail.com'), 'Hanna.Carry@sakilastaff.com' AS email, (SELECT rental_id FROM rentID WHERE title='Episode V – The Empire Strikes Back'), 9.99,date('2017-01-14 15:25:15.291 +0100')
	UNION ALL
    SELECT (SELECT customer_id  FROM customer c WHERE email='jenyayurch@gmail.com'), 'Hanna.Carry@sakilastaff.com' AS email, (SELECT rental_id FROM rentID WHERE title='Episode VI – Return of the Jedi'), 15.99,date('2017-01-14 15:35:15.291 +0100')) AS new_payment
INNER JOIN staff  
   ON new_payment.EMAIL = staff.EMAIL 
   WHERE  EXISTS (SELECT payment_id FROM rentID WHERE DATE(rental_date)= DATE(payment_date)) -- INSERT DATA IF we have a rental record and don't have payment record on the same day  
   RETURNING *
	;
