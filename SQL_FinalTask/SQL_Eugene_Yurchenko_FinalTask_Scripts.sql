--Because in Krakow a lot of museums. We have a museum database. 
--The global idea was to create a list of museums and events for museums. So We can know which museums 
--hold events. Start and end dates and current price
--As an additional option, we have in payment history. And we can calculate the previous price and the total amount.
--First of all, we need to add new museums with addresses. 
--After that, we can add an exhibit and create events where this exhibit will take part. If it events will take a part in another museum we can ease copy all exhibits.
--We can add customers and a list of customer visits. Because we may have a monthly or annual pass we don't add the price for the visit table.
--But we can create a special price for our special event in our price list table. in the Price-list table, we stored current monthly or annual pass and other passes. To add a pass we need to add a new Event name and current price. Or easy update the old price for our  monthly or annual pass


CREATE DATABASE Museums_Krakow;

CREATE SCHEMA IF NOT EXISTS Museum;

-- Museums country museum.country;
CREATE TABLE IF NOT EXISTS museum.country (
	country_id serial4 NOT NULL,
	country text NOT NULL,
	last_update timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT country_pkey PRIMARY KEY (country_id)
);

-- Museums city museum.city;
CREATE TABLE IF NOT EXISTS museum.city (
	city_id serial4 NOT NULL,
	city text NOT NULL,
	country_id int2 NOT NULL,
	last_update timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT city_pkey PRIMARY KEY (city_id),
	CONSTRAINT city_country_id_fkey FOREIGN KEY (country_id) REFERENCES museum.country(country_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Museums address museum.address;
CREATE TABLE IF NOT EXISTS museum.address (
	address_id serial4 NOT NULL,
	address text NOT NULL,
	city_id int2 NOT NULL,
	postal_code text NULL,
	phone text NOT NULL,
	CONSTRAINT address_pkey PRIMARY KEY (address_id),
	last_update timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT address_city_id_fkey FOREIGN KEY (city_id) REFERENCES museum.city(city_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- List of Museums museum.listofmuseum;
CREATE TABLE IF NOT EXISTS museum.listofmuseum (
	museum_id serial4 NOT NULL,
	museum_title TEXT NOT NULL,
	--manager_staff_id int2 NOT NULL,
	address_id int2 NOT NULL,
	last_update timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT museum_pkey PRIMARY KEY (museum_id),
	CONSTRAINT listofmuseum_address_id_fkey FOREIGN KEY (address_id) REFERENCES museum.address(address_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Museums staff museum.staff;
CREATE TABLE IF NOT EXISTS museum.staff (
	staff_id serial4 NOT NULL,
	first_name text NOT NULL,
	last_name text NOT NULL,
	full_name TEXT GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED NOT NULL,
	address_id int2 NOT NULL,
	email text NULL,
	museum_id int2 NOT NULL,
	active bool NOT NULL DEFAULT true, -- DEFAULT ALL staff IS active
	last_update timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT staff_pkey PRIMARY KEY (staff_id),
	CONSTRAINT staff_address_id_fkey FOREIGN KEY (address_id) REFERENCES museum.address(address_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT staff_museum_id_fkey FOREIGN KEY (museum_id) REFERENCES museum.listofmuseum(museum_id)
);

-- Museums customer museum.customer;
CREATE TABLE IF NOT EXISTS museum.customer (
	customer_id serial4 NOT NULL,
	--museum_id int2 NOT NULL,
	first_name text NOT NULL,
	last_name text NOT NULL,
	full_name TEXT GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED NOT NULL,
	email text NULL,
	address_id int2 NOT NULL,
	activebool bool NOT NULL DEFAULT true,
	create_date date NOT NULL DEFAULT 'now'::text::date,
	last_update timestamptz NULL DEFAULT now(),
	CONSTRAINT customer_pkey PRIMARY KEY (customer_id),
	CONSTRAINT customer_address_id_fkey FOREIGN KEY (address_id) REFERENCES museum.address(address_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

--Museums exhibits museum.exhibit
CREATE TABLE IF NOT EXISTS museum.exhibit (
	exhibit_id serial4 NOT NULL,
	title text NOT NULL,
	description text NULL,
	last_update timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT exhibit_pkey PRIMARY KEY (exhibit_id)
);

--Museums exhibits category museum.category
CREATE TABLE IF NOT EXISTS museum.category (
	category_id serial4 NOT NULL,
	"name" text NOT NULL,
	last_update timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT category_pkey PRIMARY KEY (category_id)
);

--Museums exhibits epoch/age museum.epoch
CREATE TABLE IF NOT EXISTS museum.epoch (
	epoch_id serial4 NOT NULL,
	epoch_name text NOT NULL,
	last_update timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT epoch_pkey PRIMARY KEY (epoch_id)
);

--Museums exhibits event museum.event
CREATE TABLE IF NOT EXISTS museum.event (
	event_id serial4 NOT NULL,
	title  text NOT NULL,
	start_date date NOT NULL,
	end_date date NOT NULL,
	--exhibit_id int2 NOT NULL,
	museum_id int2 NOT NULL,
	event_Reg_check bool NOT NULL DEFAULT true, -- checks IF EVENT OR exhibition IS regular OR temporarily
	last_update timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT event_pkey PRIMARY KEY (event_id),
	--CONSTRAINT event_exhibit_id_fkey FOREIGN KEY (exhibit_id) REFERENCES museum.exhibit(exhibit_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT event_museum_id_fkey FOREIGN KEY (museum_id) REFERENCES museum.listofmuseum(museum_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

--many-to-many exhibit_event
CREATE TABLE IF NOT EXISTS museum.exhibit_event (
	exhibit_id int2 NOT NULL,
	event_id int2 NOT NULL,
	last_update timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT exhibit_event_pkey PRIMARY KEY (exhibit_id, event_id),
	CONSTRAINT exhibit_event_exhibit_id_fkey FOREIGN KEY (exhibit_id) REFERENCES museum.exhibit(exhibit_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT exhibit_event_event_id_fkey FOREIGN KEY (event_id) REFERENCES museum.event(event_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

--many-to-many exhibit_category_exhibit
CREATE TABLE IF NOT EXISTS museum.exhibit_category (
	exhibit_id int2 NOT NULL,
	category_id int2 NOT NULL,
	last_update timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT exhibit_category_pkey PRIMARY KEY (exhibit_id, category_id),
	CONSTRAINT exhibit_category_exhibit_id_fkey FOREIGN KEY (exhibit_id) REFERENCES museum.exhibit(exhibit_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT exhibit_category_category_id_fkey FOREIGN KEY (category_id) REFERENCES museum.category(category_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

--many-to-many exhibit_epoch_exhibit
CREATE TABLE IF NOT EXISTS museum.exhibit_epoch (
	epoch_id int2 NOT NULL,
	exhibit_id int2 NOT NULL,
	last_update timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT exhibit_epoch_pkey PRIMARY KEY (epoch_id, exhibit_id),
	CONSTRAINT exhibit_epoch_exhibit_id_fkey FOREIGN KEY (exhibit_id) REFERENCES museum.exhibit(exhibit_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT exhibit_epoch_epoch_id_fkey FOREIGN KEY (epoch_id) REFERENCES museum.epoch(epoch_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Visiting exhibitions by customers
CREATE TABLE IF NOT EXISTS museum.visit (
	visit_id serial4 NOT NULL,
	visit_date date NOT NULL,
	event_id int4 NOT NULL,
	customer_id int2 NOT NULL,
	last_update timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT visit_pkey PRIMARY KEY (visit_id),
	CONSTRAINT visit_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES museum.customer(customer_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT visit_museum_id_fkey FOREIGN KEY (event_id) REFERENCES museum.event(event_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Price-list events museum.price
CREATE TABLE IF NOT EXISTS museum.price(
	price_id serial4 NOT NULL,
	--event_id serial4 NOT NULL,
	price_name text NOT NULL, 
	price_current int4 NOT NULL,
	last_update timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT price_pkey PRIMARY KEY (price_id)
	--CONSTRAINT event_price_id_fkey FOREIGN KEY (event_id) REFERENCES museum.event(event_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Payment history by customer adn event with amount
CREATE TABLE IF NOT EXISTS museum.payment(
	payment_id serial4 NOT NULL,
	customer_id int2 NOT NULL,
	price_id int2 NOT NULL,
	--event_id int4 NOT NULL,
	quantity int NOT NULL,
	amount numeric(5, 0) NOT NULL,
	payment_date timestamptz NOT NULL,
	CONSTRAINT payment_pkey PRIMARY KEY (payment_id),
	CONSTRAINT payment_price_id_fkey FOREIGN KEY (price_id) REFERENCES museum.price(price_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CHECKS AND ALERTS
ALTER TABLE museum.address DROP CONSTRAINT IF EXISTS PN_Check;
ALTER TABLE museum.address ADD CONSTRAINT PN_Check CHECK (phone not like '%[^0-9]%');
ALTER TABLE museum.staff DROP CONSTRAINT IF EXISTS Email_Check;
ALTER TABLE museum.staff ADD CONSTRAINT Email_Check CHECK (email ~* '^[A-Za-z0-9._+%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$');
ALTER TABLE museum.customer DROP CONSTRAINT IF EXISTS Email_Check;
ALTER TABLE museum.customer ADD CONSTRAINT Email_Check CHECK (email ~* '^[A-Za-z0-9._+%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$');

--INSERT DATA

--Country
INSERT INTO museum.country
(country)
SELECT country
FROM 
	(Select 'Poland' AS country
	UNION ALL
    SELECT 'Czech Republic'
    	UNION ALL
    SELECT 'Slovakia'
    	UNION ALL
    SELECT 'Ukraine'
    	UNION ALL
    SELECT 'Lithuania'
       	UNION ALL
    SELECT 'Belarus'
    	UNION ALL
    SELECT 'Russia'
        UNION ALL
    SELECT 'Germany'
    ) AS new_city
WHERE (new_city.country) NOT IN (SELECT country FROM museum.country)
RETURNING *;

--City
INSERT INTO museum.city
(city, country_id)
SELECT city, country_id
FROM 
	(Select 'Krakow' AS city, (SELECT country_id FROM country WHERE upper(country) = upper('Poland')) AS country_id
	UNION ALL
    SELECT 'Warsaw', (SELECT country_id FROM museum.country WHERE upper(country) = upper('Poland'))
    	UNION ALL
    SELECT 'Gdansk', (SELECT country_id FROM museum.country WHERE upper(country) = upper('Poland'))
    	UNION ALL
    SELECT 'Poznan', (SELECT country_id FROM museum.country WHERE upper(country) = upper('Poland'))
    	UNION ALL
    SELECT 'Wroclaw', (SELECT country_id FROM museum.country WHERE upper(country) = upper('Poland'))
    UNION ALL
    SELECT 'Minsk', (SELECT country_id FROM museum.country WHERE upper(country) = upper('Belarus'))
    UNION ALL
    SELECT 'Berlin', (SELECT country_id FROM museum.country WHERE upper(country) = upper('Germany'))
    UNION ALL
    SELECT 'Bratislava', (SELECT country_id FROM museum.country WHERE upper(country) = upper('Slovakia'))
      ) AS new_city
WHERE (new_city.city) NOT IN (SELECT city FROM museum.city)
RETURNING *;

--Address
INSERT INTO museum.address
(address, city_id, postal_code, phone)
SELECT address, city_id, postal_code, phone
FROM 
	(SELECT 'Rynek Glowny 35'AS address, (SELECT city_id FROM museum.city WHERE upper(city) = upper('Krakow')) AS city_id,'31-011' AS postal_code, '+48 12 619 23 35' AS phone
	UNION ALL
    SELECT 'Rynek Glowny 1', (SELECT city_id FROM museum.city WHERE upper(city) = upper('Krakow')),'31-011' , '+48 12 426 43 34'
    UNION ALL
    SELECT 'ul. Basztowa', (SELECT city_id FROM museum.city WHERE upper(city) = upper('Krakow')),'30-547' , '+48 12 421 02 01'
    UNION ALL
    SELECT 'Ksiecia Jozefa 337', (SELECT city_id FROM museum.city WHERE upper(city) = upper('Krakow')),'30-243' , '+48 12 422 51 47'
    UNION ALL
    SELECT 'os. Szkolne 37', (SELECT city_id FROM museum.city WHERE upper(city) = upper('Krakow')),'31-978' , '+48 12 446 78 22'
    UNION ALL
    SELECT 'ul. Jana Svermu 43', (SELECT city_id FROM museum.city WHERE upper(city) = upper('Bratislava')),'7 974 04' , '+482 12 446 78 33'
    UNION ALL
    SELECT 'Mohrenstrasse 37', (SELECT city_id FROM museum.city WHERE upper(city) = upper('Berlin')),'10117' , '+49 30 30 18 58 00'
    UNION ALL
    SELECT 'Glebki 44', (SELECT city_id FROM museum.city WHERE upper(city) = upper('Minsk')),'20012' , '+375 29 390 51 97'
     UNION ALL
    SELECT 'plac Wszystkich Swietych 12', (SELECT city_id FROM museum.city WHERE upper(city) = upper('Krakow')),'30-348' , '+48 12 436 42 31'
    UNION ALL
    SELECT 'LOBZOWSKA STREET 8', (SELECT city_id FROM museum.city WHERE upper(city) = upper('Krakow')),'31-140' , '+33 1 70 98 61 18'
	) AS NEW_address
WHERE (NEW_address.address) NOT IN (SELECT address FROM museum.address)
RETURNING *;

--List of Museums
INSERT INTO museum.listofmuseum
(museum_title, address_id)
SELECT museum_title, address_id
FROM 
	(SELECT 'Krzysztofory Palace' AS museum_title, (SELECT address_id FROM museum.address WHERE upper(address) = upper('Rynek Glowny 35')) AS address_id
	UNION ALL
    SELECT 'Town Hall Tower', (SELECT address_id FROM museum.address WHERE upper(address) = upper('Rynek Glowny 1'))
    UNION ALL
    SELECT 'Barbican', (SELECT address_id FROM museum.address WHERE upper(address) = upper('ul. Basztowa'))
    UNION ALL
    SELECT 'Thesaurus Cracoviensis', (SELECT address_id FROM museum.address WHERE upper(address) = upper('Ksiecia Jozefa 337'))
    UNION ALL
    SELECT 'Nowa Huta Underground', (SELECT address_id FROM museum.address WHERE upper(address) = upper('os. Szkolne 37'))
	) AS NEW_museum
WHERE (NEW_museum.museum_title) NOT IN (SELECT museum_title FROM museum.listofmuseum)
RETURNING *;

-- Musem staff
INSERT INTO museum.staff
(first_name, last_name, address_id, email, museum_id)
SELECT first_name, last_name, address_id, email, museum_id
FROM
	(SELECT 'Daniel' AS first_name, 'Olbrychski' AS last_name,(SELECT address_id FROM museum.address WHERE upper(address) = upper('Rynek Glowny 35')) AS address_id, 'Olbrychski@gmail.com' AS email, (SELECT museum_id FROM museum.listofmuseum WHERE upper(museum_title) = upper('Krzysztofory Palace')) AS museum_id
	UNION ALL
	SELECT 'Janusz', 'Gajos', (SELECT address_id FROM museum.address WHERE upper(address) = upper('Rynek Glowny 35')), 'Gajos@gmail.com',(SELECT museum_id FROM museum.listofmuseum WHERE upper(museum_title) = upper('Krzysztofory Palace'))
	UNION ALL
	SELECT 'Piotr', 'Adamczyk', (SELECT address_id FROM museum.address WHERE upper(address) = upper('ul. Basztowa')), 'Adamczyk@gmail.com', (SELECT museum_id FROM museum.listofmuseum WHERE upper(museum_title) = upper('Barbican'))
	UNION ALL
	SELECT'Izabella', 'Miko', (SELECT address_id FROM museum.address WHERE upper(address) = upper('ul. Basztowa')), 'Miko@gmail.com', (SELECT museum_id FROM museum.listofmuseum WHERE upper(museum_title) = upper('Barbican'))
	UNION ALL
	SELECT 'Krystyna', 'Janda', (SELECT address_id FROM museum.address WHERE upper(address) = upper('os. Szkolne 37')),'Janda@gmail.com', (SELECT museum_id FROM museum.listofmuseum WHERE upper(museum_title) = upper('Nowa Huta Underground'))
	) AS new_staff 
WHERE (new_staff.email) NOT IN (SELECT email FROM museum.staff)
RETURNING *;

-- Musem customer
INSERT INTO museum.customer
(first_name, last_name, email, address_id)
SELECT first_name, last_name, email, address_id
FROM 
		(SELECT 'Reksio' AS first_name, 'Oisker' AS last_name, 'Oisker@gmail.com' AS email, (SELECT address_id FROM museum.address WHERE upper(address) = upper('ul. Jana Svermu 43')) AS address_id
		UNION ALL
		SELECT 'Bolek', 'Kelob', 'Kelob@gmail.com', (SELECT address_id FROM museum.address WHERE upper(address) = upper('Mohrenstrasse 37'))
		UNION ALL
		SELECT 'Lolek', 'Kolek', 'Kolek@gmail.com', (SELECT address_id FROM museum.address WHERE upper(address) = upper('Glebki 44'))
		UNION ALL
		SELECT 'Maya ', 'Ayam', 'Ayam@gmail.com', (SELECT address_id FROM museum.address WHERE upper(address) = upper('plac Wszystkich Swietych 12'))
		UNION ALL
		SELECT 'Binio  ', 'Bill', 'Bill@gmail.com', (SELECT address_id FROM museum.address WHERE upper(address) = upper('LOBZOWSKA STREET 8'))
		) AS new_customer
	WHERE (new_customer.email) NOT IN (SELECT email FROM museum.customer)
RETURNING *;

-- Musem exhibits
INSERT INTO museum.exhibit
(title)
SELECT title
FROM 
	(SELECT 'ARTBUSKE' AS title
	UNION ALL
	SELECT 'BERAKNA'
	UNION ALL
	SELECT 'PADRAG'
	UNION ALL
	SELECT 'STILREN'
	UNION ALL
	SELECT 'KARAFF'
	UNION ALL
	SELECT 'GRADVIS'
	UNION ALL
	SELECT 'FORENLIG'
	UNION ALL
	SELECT 'VILJESTARK'
	UNION ALL
	SELECT 'SOCKERART'
	UNION ALL
	SELECT 'RAFFELBJORK'
	) AS new_title
	WHERE (new_title.title) NOT IN (SELECT title FROM museum.exhibit)
RETURNING *;

--Museum events
INSERT INTO museum."event"
(title, start_date, end_date, museum_id)
SELECT title, start_date, end_date, museum_id
FROM 
	(SELECT 'Regular museum exhibition' AS title, TO_DATE('2022-12-01', 'YYYY-MM-DD')  AS start_date, TO_DATE('2023-12-31', 'YYYY-MM-DD') AS end_date, (SELECT museum_id FROM museum.listofmuseum WHERE upper(museum_title) = upper('Krzysztofory Palace')) AS museum_id
	UNION ALL
	SELECT 'A Netherlandish master of detail',TO_DATE('2023-01-01', 'YYYY-MM-DD'), TO_DATE('2023-02-01', 'YYYY-MM-DD'), (SELECT museum_id FROM museum.listofmuseum WHERE upper(museum_title) = upper('Krzysztofory Palace'))
	UNION ALL
	SELECT 'Christmas Cribs Exhibition',TO_DATE('2022-11-01', 'YYYY-MM-DD'), TO_DATE('2023-02-01', 'YYYY-MM-DD'), (SELECT museum_id FROM museum.listofmuseum WHERE upper(museum_title) = upper('Krzysztofory Palace'))
	UNION ALL
	SELECT 'Politics in Art',TO_DATE('2023-03-01', 'YYYY-MM-DD'), TO_DATE('2023-06-01', 'YYYY-MM-DD'), (SELECT museum_id FROM museum.listofmuseum WHERE upper(museum_title) = upper('Barbican'))
	UNION ALL
	SELECT 'Dialogue with the Space',TO_DATE('2023-04-01', 'YYYY-MM-DD'), TO_DATE('2023-10-01', 'YYYY-MM-DD'), (SELECT museum_id FROM museum.listofmuseum WHERE upper(museum_title) = upper('Barbican'))
	UNION ALL
	SELECT 'Contemporary Models of Realism',TO_DATE('2023-05-01', 'YYYY-MM-DD'), TO_DATE('2023-06-01', 'YYYY-MM-DD'), (SELECT museum_id FROM museum.listofmuseum WHERE upper(museum_title) = upper('Thesaurus Cracoviensis'))
	UNION ALL
	SELECT 'Maks Levin, War Correspondent',TO_DATE('2023-12-01', 'YYYY-MM-DD'), TO_DATE('2024-02-01', 'YYYY-MM-DD'), (SELECT museum_id FROM museum.listofmuseum WHERE upper(museum_title) = upper('Thesaurus Cracoviensis'))
	) AS new_event
		WHERE (new_event.title) NOT IN (SELECT title FROM museum."event") AND end_date > start_date
RETURNING *; 

INSERT INTO museum.exhibit_event
(exhibit_id, event_id)
SELECT exhibit_id, event_id
FROM 
	(SELECT (SELECT exhibit_id FROM museum.exhibit WHERE upper(title) = upper('ARTBUSKE')) AS exhibit_id, (SELECT event_id FROM museum."event" WHERE upper(title) = upper('Regular museum exhibition')) AS event_id
	UNION ALL
	SELECT (SELECT exhibit_id FROM museum.exhibit WHERE upper(title) = upper('BERAKNA')), (SELECT event_id FROM museum."event" WHERE upper(title) = upper('Regular museum exhibition'))
	UNION ALL
	SELECT (SELECT exhibit_id FROM museum.exhibit WHERE upper(title) = upper('PADRAG')), (SELECT event_id FROM museum."event" WHERE upper(title) = upper('Maks Levin, War Correspondent'))
	UNION ALL
	SELECT (SELECT exhibit_id FROM museum.exhibit WHERE upper(title) = upper('STILREN')), (SELECT event_id FROM museum."event" WHERE upper(title) = upper('Maks Levin, War Correspondent'))
	UNION ALL
	SELECT (SELECT exhibit_id FROM museum.exhibit WHERE upper(title) = upper('KARAFF')), (SELECT event_id FROM museum."event" WHERE upper(title) = upper('Contemporary Models of Realism'))
	UNION ALL
	SELECT (SELECT exhibit_id FROM museum.exhibit WHERE upper(title) = upper('GRADVIS')), (SELECT event_id FROM museum."event" WHERE upper(title) = upper('Contemporary Models of Realism'))
	UNION ALL
	SELECT (SELECT exhibit_id FROM museum.exhibit WHERE upper(title) = upper('FORENLIG')), (SELECT event_id FROM museum."event" WHERE upper(title) = upper('Dialogue with the Space'))
	UNION ALL
	SELECT (SELECT exhibit_id FROM museum.exhibit WHERE upper(title) = upper('VILJESTARK')), (SELECT event_id FROM museum."event" WHERE upper(title) = upper('Dialogue with the Space'))
	UNION ALL
	SELECT (SELECT exhibit_id FROM museum.exhibit WHERE upper(title) = upper('SOCKERART')), (SELECT event_id FROM museum."event" WHERE upper(title) = upper('Politics in Art'))
	UNION ALL
	SELECT (SELECT exhibit_id FROM museum.exhibit WHERE upper(title) = upper('RAFFELBJORK')), (SELECT event_id FROM museum."event" WHERE upper(title) = upper('Politics in Art'))
	) AS new_exhibit_event
	WHERE (new_exhibit_event.exhibit_id) NOT IN (SELECT exhibit_id FROM museum.exhibit_event) AND (new_exhibit_event.event_id) NOT IN (SELECT event_id FROM museum.exhibit_event)
RETURNING *; 

-- exhibit epoch
INSERT INTO museum.epoch
(epoch_name)
SELECT epoch_name
	FROM
		(SELECT 'Bronze Age' AS epoch_name
		UNION ALL
		SELECT 'Iron Age'
		UNION ALL
		SELECT 'Middle Ages'
		UNION ALL
		SELECT 'Early modern period'
		UNION ALL
		SELECT 'Long nineteenth century'
		)AS new_epoch
		WHERE  (new_epoch.epoch_name) NOT IN (SELECT epoch_name FROM museum.epoch)
RETURNING *; 


-- exhibit epoch
INSERT INTO museum.category
("name")
SELECT "name"
	FROM
		(SELECT 'Technological' AS "name"
		UNION ALL
		SELECT 'Wars and financial crisis'
		UNION ALL
		SELECT 'Modern History'
		UNION ALL
		SELECT 'Ancient History'
		UNION ALL
		SELECT 'Classical Antiquity'
		)AS new_category
		WHERE  (new_category.name) NOT IN (SELECT name FROM museum.category)
RETURNING *; 


--many to many exhibit_category
INSERT INTO museum.exhibit_category
(exhibit_id, category_id)
SELECT exhibit_id, category_id
FROM 
	(SELECT (SELECT exhibit_id FROM museum.exhibit WHERE upper(title) = upper('ARTBUSKE')) AS exhibit_id, (SELECT category_id FROM museum.category WHERE upper("name") = upper('Technological')) AS category_id
	UNION ALL 
	SELECT (SELECT exhibit_id FROM museum.exhibit WHERE upper(title) = upper('BERAKNA')) AS exhibit_id, (SELECT category_id FROM museum.category WHERE upper("name") = upper('Technological'))
	UNION ALL 
	SELECT (SELECT exhibit_id FROM museum.exhibit WHERE upper(title) = upper('PADRAG')) AS exhibit_id, (SELECT category_id FROM museum.category WHERE upper("name") = upper('Wars and financial crisis'))
	UNION ALL 
	SELECT (SELECT exhibit_id FROM museum.exhibit WHERE upper(title) = upper('STILREN')) AS exhibit_id, (SELECT category_id FROM museum.category WHERE upper("name") = upper('Wars and financial crisis'))
	UNION ALL 
	SELECT (SELECT exhibit_id FROM museum.exhibit WHERE upper(title) = upper('KARAFF')) AS exhibit_id, (SELECT category_id FROM museum.category WHERE upper("name") = upper('Modern History'))
	UNION ALL 
	SELECT (SELECT exhibit_id FROM museum.exhibit WHERE upper(title) = upper('GRADVIS')) AS exhibit_id, (SELECT category_id FROM museum.category WHERE upper("name") = upper('Modern History'))
	UNION ALL 
	SELECT (SELECT exhibit_id FROM museum.exhibit WHERE upper(title) = upper('FORENLIG')) AS exhibit_id, (SELECT category_id FROM museum.category WHERE upper("name") = upper('Ancient History'))
	UNION ALL 
	SELECT (SELECT exhibit_id FROM museum.exhibit WHERE upper(title) = upper('VILJESTARK')) AS exhibit_id, (SELECT category_id FROM museum.category WHERE upper("name") = upper('Ancient History'))
	UNION ALL 
	SELECT (SELECT exhibit_id FROM museum.exhibit WHERE upper(title) = upper('SOCKERART')) AS exhibit_id, (SELECT category_id FROM museum.category WHERE upper("name") = upper('Classical Antiquity'))
	UNION ALL 
	SELECT (SELECT exhibit_id FROM museum.exhibit WHERE upper(title) = upper('RAFFELBJORK')) AS exhibit_id, (SELECT category_id FROM museum.category WHERE upper("name") = upper('Classical Antiquity'))
	) AS new_exhibit_category
	WHERE (new_exhibit_category.exhibit_id) NOT IN (SELECT exhibit_id FROM museum.exhibit_category) AND (new_exhibit_category.category_id) NOT IN (SELECT category_id FROM museum.exhibit_category)
RETURNING *; 


--many to many exhibit_epoch
INSERT INTO museum.exhibit_epoch
(epoch_id, exhibit_id)
SELECT epoch_id, exhibit_id
FROM 
	(SELECT (SELECT exhibit_id FROM museum.exhibit WHERE upper(title) = upper('ARTBUSKE')) AS exhibit_id, (SELECT epoch_id FROM museum.epoch WHERE upper(epoch_name) = upper('Bronze Age')) AS epoch_id
	UNION ALL 
	SELECT (SELECT exhibit_id FROM museum.exhibit WHERE upper(title) = upper('BERAKNA')), (SELECT epoch_id FROM museum.epoch WHERE upper(epoch_name) = upper('Bronze Age'))
	UNION ALL 
	SELECT (SELECT exhibit_id FROM museum.exhibit WHERE upper(title) = upper('PADRAG')), (SELECT epoch_id FROM museum.epoch WHERE upper(epoch_name) = upper('Iron Age'))
	UNION ALL 
	SELECT (SELECT exhibit_id FROM museum.exhibit WHERE upper(title) = upper('STILREN')), (SELECT epoch_id FROM museum.epoch WHERE upper(epoch_name) = upper('Iron Age'))
	UNION ALL 
	SELECT (SELECT exhibit_id FROM museum.exhibit WHERE upper(title) = upper('KARAFF')), (SELECT epoch_id FROM museum.epoch WHERE upper(epoch_name) = upper('Middle Ages'))
	UNION ALL 
	SELECT (SELECT exhibit_id FROM museum.exhibit WHERE upper(title) = upper('GRADVIS')), (SELECT epoch_id FROM museum.epoch WHERE upper(epoch_name) = upper('Middle Ages'))
	UNION ALL 
	SELECT (SELECT exhibit_id FROM museum.exhibit WHERE upper(title) = upper('FORENLIG')), (SELECT epoch_id FROM museum.epoch WHERE upper(epoch_name) = upper('Early modern period'))
	UNION ALL 
	SELECT (SELECT exhibit_id FROM museum.exhibit WHERE upper(title) = upper('VILJESTARK')), (SELECT epoch_id FROM museum.epoch WHERE upper(epoch_name) = upper('Early modern period'))
	UNION ALL 
	SELECT (SELECT exhibit_id FROM museum.exhibit WHERE upper(title) = upper('SOCKERART')), (SELECT epoch_id FROM museum.epoch WHERE upper(epoch_name) = upper('Long nineteenth century'))
	UNION ALL 
	SELECT (SELECT exhibit_id FROM museum.exhibit WHERE upper(title) = upper('RAFFELBJORK')), (SELECT epoch_id FROM museum.epoch WHERE upper(epoch_name) = upper('Long nineteenth century'))
	) AS new_exhibit_epoch
	WHERE (new_exhibit_epoch.exhibit_id) NOT IN (SELECT exhibit_id FROM museum.exhibit_epoch) AND (new_exhibit_epoch.epoch_id) NOT IN (SELECT epoch_id FROM museum.exhibit_epoch)
RETURNING *; 

--Customers visits
INSERT INTO museum.visit
(visit_date, event_id, customer_id)
SELECT visit_date, event_id, customer_id
FROM
	(SELECT TO_DATE('2022-01-13', 'YYYY-MM-DD') AS visit_date, (SELECT event_id FROM museum."event" WHERE upper(title) = upper('Regular museum exhibition')) AS event_id, (SELECT customer_id FROM museum.customer WHERE upper(email) = upper('Oisker@gmail.com')) AS customer_id
	UNION ALL 
	SELECT TO_DATE('2022-01-15', 'YYYY-MM-DD') AS visit_date, (SELECT event_id FROM museum."event" WHERE upper(title) = upper('Maks Levin, War Correspondent')) AS event_id, (SELECT customer_id FROM museum.customer WHERE upper(email) = upper('Oisker@gmail.com'))
	UNION ALL 
	SELECT TO_DATE('2022-01-13', 'YYYY-MM-DD') AS visit_date, (SELECT event_id FROM museum."event" WHERE upper(title) = upper('Regular museum exhibition')) AS event_id, (SELECT customer_id FROM museum.customer WHERE upper(email) = upper('Kelob@gmail.com'))
	UNION ALL 
	SELECT TO_DATE('2022-01-13', 'YYYY-MM-DD') AS visit_date, (SELECT event_id FROM museum."event" WHERE upper(title) = upper('A Netherlandish master of detail')) AS event_id, (SELECT customer_id FROM museum.customer WHERE upper(email) = upper('Kolek@gmail.com'))
	UNION ALL 
	SELECT TO_DATE('2022-01-13', 'YYYY-MM-DD') AS visit_date, (SELECT event_id FROM museum."event" WHERE upper(title) = upper('Regular museum exhibition')) AS event_id, (SELECT customer_id FROM museum.customer WHERE upper(email) = upper('Ayam@gmail.com'))
	UNION ALL 
	SELECT TO_DATE('2022-01-15', 'YYYY-MM-DD') AS visit_date, (SELECT event_id FROM museum."event" WHERE upper(title) = upper('Christmas Cribs Exhibition')) AS event_id, (SELECT customer_id FROM museum.customer WHERE upper(email) = upper('Ayam@gmail.com'))
	UNION ALL 
	SELECT TO_DATE('2022-01-15', 'YYYY-MM-DD') AS visit_date, (SELECT event_id FROM museum."event" WHERE upper(title) = upper('Regular museum exhibition')) AS event_id, (SELECT customer_id FROM museum.customer WHERE upper(email) = upper('Bill@gmail.com'))
	UNION ALL
	SELECT TO_DATE('2022-01-15', 'YYYY-MM-DD') AS visit_date, (SELECT event_id FROM museum."event" WHERE upper(title) = upper('Dialogue with the Space')) AS event_id, (SELECT customer_id FROM museum.customer WHERE upper(email) = upper('Bill@gmail.com'))
	UNION ALL
	SELECT TO_DATE('2022-01-15', 'YYYY-MM-DD') AS visit_date, (SELECT event_id FROM museum."event" WHERE upper(title) = upper('Contemporary Models of Realism')) AS event_id, (SELECT customer_id FROM museum.customer WHERE upper(email) = upper('Bill@gmail.com'))
	UNION ALL
	SELECT TO_DATE('2022-01-15', 'YYYY-MM-DD') AS visit_date, (SELECT event_id FROM museum."event" WHERE upper(title) = upper('Maks Levin, War Correspondent')) AS event_id, (SELECT customer_id FROM museum.customer WHERE upper(email) = upper('Bill@gmail.com'))
	) AS new_visit
	WHERE (new_visit.event_id) NOT IN (SELECT event_id FROM museum.visit) AND (new_visit.customer_id) NOT IN (SELECT customer_id FROM museum.visit) AND (new_visit.visit_date) NOT IN (SELECT visit_date FROM museum.visit) 
RETURNING *; 

-- Price-list
INSERT INTO museum.price
( price_name, price_current)
SELECT price_name, price_current
FROM
	(SELECT 'monthly pass' AS price_name, 120 AS price_current
	UNION ALL
	SELECT  'annual pass', 1000
	UNION ALL
	SELECT  'single pass', 15
	UNION ALL
	SELECT  'children`s pass', 10
	UNION ALL
	SELECT  'Group pass', 65
	) AS new_price
	WHERE new_price.price_name NOT IN (SELECT price_name FROM museum.price)
RETURNING *;

INSERT INTO museum.payment
(customer_id, price_id, quantity, amount, payment_date)
SELECT customer_id, price_id, quantity, amount, payment_date
FROM 
	(
	SELECT (SELECT customer_id FROM museum.customer WHERE upper(email) = upper('Oisker@gmail.com')) AS customer_id, (SELECT price_id FROM museum.price WHERE upper(price_name) = upper('single pass')) AS price_ID, 2 AS quantity, 30 AS amount ,TO_DATE('2022-01-01', 'YYYY-MM-DD') AS payment_date
	UNION ALL
	SELECT (SELECT customer_id FROM museum.customer WHERE upper(email) = upper('Oisker@gmail.com')) AS customer_id, (SELECT price_id FROM museum.price WHERE upper(price_name) = upper('single pass')) AS price_ID, 2 AS quantity, 30 AS amount ,TO_DATE('2022-01-01', 'YYYY-MM-DD')
	UNION ALL
	SELECT (SELECT customer_id FROM museum.customer WHERE upper(email) = upper('Kelob@gmail.com')) AS customer_id, (SELECT price_id FROM museum.price WHERE upper(price_name) = upper('children`s pass')) AS price_ID, 1 AS quantity, 10 AS amount ,TO_DATE('2022-01-01', 'YYYY-MM-DD')
	UNION ALL
	SELECT (SELECT customer_id FROM museum.customer WHERE upper(email) = upper('Kolek@gmail.com')) AS customer_id, (SELECT price_id FROM museum.price WHERE upper(price_name) = upper('monthly pass')) AS price_ID, 1 AS quantity, 120 AS amount ,TO_DATE('2022-01-01', 'YYYY-MM-DD')
	UNION ALL
	SELECT (SELECT customer_id FROM museum.customer WHERE upper(email) = upper('Ayam@gmail.com')) AS customer_id, (SELECT price_id FROM museum.price WHERE upper(price_name) = upper('monthly pass')) AS price_ID, 1 AS quantity, 120 AS amount ,TO_DATE('2022-01-01', 'YYYY-MM-DD')
	UNION ALL
	SELECT (SELECT customer_id FROM museum.customer WHERE upper(email) = upper('Bill@gmail.com')) AS customer_id, (SELECT price_id FROM museum.price WHERE upper(price_name) = upper('annual pass')) AS price_ID, 1 AS quantity, 1000 AS amount ,TO_DATE('2022-01-01', 'YYYY-MM-DD')
	) AS new_payment
	WHERE new_payment.payment_date NOT IN (SELECT payment_date FROM museum.payment) AND new_payment.customer_id NOT IN (SELECT customer_id FROM museum.payment)
RETURNING *;

--DROP SCHEMA Museum CASCADE;

--• Function that UPDATEs data in one of your tables (input arguments: table's primary key value, column name and column value to UPDATE to).

--INSERT NEW price in orice-list
CREATE OR REPLACE FUNCTION Insert_into_price (new_price_name varchar(50),price_current int DEFAULT 15) RETURNS int
AS $$ 
BEGIN
	    IF $1 IN (SELECT price_name FROM museum.price) THEN
	   RAISE NOTICE 'Price %  was added before', $1;
ELSIF price_current >0 THEN 
INSERT INTO museum.price (price_name, price_current) 
values(new_price_name, price_current);
END IF;
RETURN (SELECT price_ID FROM museum.price WHERE price_name ilike $1 ) AS price_ID;
END; $$ LANGUAGE plpgSQL;

SELECT * FROM Insert_into_price('Scool pass',1960);

-- Function that adds new transaction to your transaction table. Come up with input arguments and output format yourself. 
--Make sure all transaction attributes can be set with the function (via their natural keys).
CREATE OR REPLACE FUNCTION Insert_into_payment (customer_email text, price_name text, quantity int, amount NUMERIC , payment_date date DEFAULT now()) RETURNS int
AS $$ 
BEGIN
	    IF $1 NOT IN (SELECT customer.email FROM museum.customer) THEN
	   RAISE NOTICE 'Customer with email: %  was not found', $1;
ELSIF quantity >0 THEN 
INSERT INTO museum.payment (customer_id, price_id, quantity, amount, payment_date) 
VALUES((SELECT customer_id from museum.customer  WHERE upper(customer.email)=upper($1)), (SELECT price_id FROM museum.price WHERE upper(price.price_name) = upper($2)), quantity, amount, payment_date);
END IF;
RETURN (SELECT payment_ID FROM museum.payment WHERE payment.payment_date = $5 AND customer_id IN (SELECT customer_id FROM museum.customer WHERE upper(customer.email)=upper($1))) AS payment_ID;
END; $$ LANGUAGE plpgSQL;

SELECT * FROM Insert_into_payment ('Bill@gmail.com', 'group pass', 1, 65 )

--Function that adds new transaction to your transaction table. Come up with input arguments and output format yourself. Make sure all transaction
--attributes can be set with the function (via their natural keys).
CREATE OR REPLACE VIEW museum.FullData AS 
SELECT 
ev.title, ev.start_date, ev.end_date, ev.event_reg_check
, ex.title AS event_name
, ep.epoch_name
, cat."name" 
, vis.visit_date 
, lm.museum_title
, adr2.address AS Museum_address
, cou2.country AS Museum_country
, cit2.city AS Museum_city
, cus.full_name, cus.email, cus.activebool, cus.create_date
, adr.address, cou.country, cit.city, adr.postal_code, adr.phone
, pay.quantity, pay.amount, pay.payment_date
, pr.price_name, pr.price_current
FROM EVENT ev
INNER JOIN visit vis ON ev.event_id=vis.event_id
INNER JOIN listofmuseum lm ON ev.museum_id=lm.museum_id
INNER JOIN customer cus ON vis.customer_id = cus.customer_id 
INNER JOIN address adr ON cus.address_id = adr.address_id
LEFT JOIN city cit ON cit.city_id = adr.city_id
LEFT JOIN country cou ON cit.country_id = cou.country_id
INNER JOIN address adr2 ON lm.address_id = adr2.address_id
LEFT JOIN city cit2 ON cit2.city_id = adr2.city_id
LEFT JOIN country cou2 ON cit2.country_id = cou2.country_id
INNER JOIN exhibit_event exev ON exev.event_id = ev.event_id 
INNER JOIN exhibit ex ON ex.exhibit_id = exev.exhibit_id
INNER JOIN exhibit_epoch exep ON ex.exhibit_id =exep.exhibit_id
INNER JOIN epoch ep ON ep.epoch_id = exep.epoch_id 
INNER JOIN exhibit_category excat ON ex.exhibit_id =excat.exhibit_id
INNER JOIN category cat ON cat.category_id = excat.category_id 
INNER JOIN payment pay ON pay.customer_id = cus.customer_id 
INNER JOIN price pr ON pr.price_id = pay.price_id 
;

--Create manager's read-only role. Make sure he can only SELECT from tables in your database. Make sure he can LOGIN as well.
--Make sure you follow database security best practices when creating role(s)

--DROP ROLE IF EXISTS museum_manager;
CREATE ROLE museum_manager;
GRANT CONNECT ON DATABASE postgres TO museum_manager;
GRANT USAGE ON SCHEMA museum TO museum_manager;
GRANT SELECT ON ALL TABLES IN SCHEMA museum TO museum_manager; -- PERMISSION FOR SELECT DATA FROM ALL TABLES

CREATE ROLE DB_Museum_Manager WITH LOGIN PASSWORD 'a2b3c4d5'; -- CREATE ROLE WITH FUNCTION LOGIN TO DATABASE
GRANT museum_manager TO DB_Museum_Manager;	


