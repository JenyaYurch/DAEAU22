-- TASK 1: Figure out what security precautions are already used in your 'dvd_rental' database; -- send description

-- IN our database we have USERS/ROLES. By default we use postgres user/role - with all permissions. We can login with postgres user/role
-- when we connect to database we pass AUTHORIZATION with user postgres and password
-- by DEFAULT we didnt have restriction in tables for users and rows - Row-level SECURITY 

SELECT * FROM pg_roles WHERE rolname !~ '^pg_';

-- And we have other Roles:
SELECT 
      r.rolname, 
      ARRAY(SELECT b.rolname
            FROM pg_catalog.pg_auth_members m
            JOIN pg_catalog.pg_roles b ON (m.roleid = b.oid)
            WHERE m.member = r.oid) as memberof
FROM pg_catalog.pg_roles r
WHERE r.rolname NOT IN ('pg_signal_backend','rds_iam',
                        'rds_replication','rds_superuser',
                        'rdsadmin','rdsrepladmin')
ORDER BY 1;

-- pg_monitor contains(groups) three roles pg_read_all_settings,pg_read_all_stats,pg_stat_scan_tables
-- IF we have ROLE pg_monitor we have all permissions of included roles
-- we don't have Row-Level Security for our tables in 'dvd rental' database


-- TASK 2: Implement role-based authentication model for dvd_rental database:
-- 2.1 Create group roles: DB developer, backend tester (read-only), customer (read-only for film and actor)
-- Assign proper privileges to each role.

-- DB developer
CREATE ROLE dvd_database_developer; 
GRANT CONNECT ON DATABASE postgres TO dvd_database_developer; 	-- PERMISSION TO CONNECT WITH DATABASE
GRANT USAGE ON SCHEMA public TO dvd_database_developer; 		-- PERMISSION FOR USE/SELECT OBJECTS IN SCHEMA
GRANT UPDATE, TRIGGER, INSERT, SELECT, DELETE, REFERENCES, TRUNCATE ON ALL TABLES IN SCHEMA public TO dvd_database_developer; -- PERMISSION FOR WORK WITH ALL TABLES

-- backend tester (read-only)
CREATE ROLE dvd_backend_tester;
GRANT CONNECT ON DATABASE postgres TO dvd_backend_tester;
GRANT USAGE ON SCHEMA public TO dvd_backend_tester;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO dvd_backend_tester; -- PERMISSION FOR SELECT DATA FROM ALL TABLES

--customer (read-only for film and actor)
CREATE ROLE dvd_customer;
GRANT CONNECT ON DATABASE postgres TO dvd_customer;
GRANT USAGE ON SCHEMA public TO dvd_customer;
GRANT SELECT ON TABLE public.film, public.actor TO dvd_customer; -- PERMISSION FOR SELECT DATA FROM THE INDICATED TABLES
GRANT SELECT (customer_id, first_name, last_name, email) ON TABLE public.customer  TO dvd_customer; -- FOR identification customer_id

-- 2.2 Create personalized role for any customer already existing in the dvd_rental database. Role name must be client_{first_name}_{last_name}
-- (omit curly brackets). Customer's payment and rental history must not be empty.

CREATE ROLE client_eugene_yurchenko WITH LOGIN PASSWORD 'a2b3c4d5'; -- CREATE ROLE WITH FUNCTION LOGIN TO DATABASE
GRANT dvd_customer TO client_eugene_yurchenko;						-- GIVES ALL PERMISSIONS FROM ROLE dvd_customer

-- 2.3 Relogin with USER client_eugene_yurchenko and PASS a2b3c4d5 and checked SELECT for film and actor - it`s ok. 
-- And no permission for another tables. SET ON ROLE client_eugene_yurchenko and try work with data and tables
-- Try to INSERT, DELETE and DROP data and tables - no permission

-- CHECK ROLE client_eugene_yurchenko
BEGIN;
SET ROLE client_eugene_yurchenko;
SELECT current_user;
SELECT * FROM public.film; 	-- OK
SELECT * FROM public.actor;	-- OK
SELECT * FROM public.rental;-- permission denied for table rental
UPDATE public.film SET title  = 'TEST' WHERE film_id = 1007; -- permission denied for table film
DELETE FROM film WHERE film_id = 1007;-- permission denied for table film
ROLLBACK;

-- CHECK ROLE dvd_database_developer
BEGIN;
SET ROLE dvd_database_developer;
SELECT current_user;
SELECT * FROM public.film; 	-- OK
SELECT * FROM public.rental;-- OK
UPDATE public.film SET title  = 'TEST' WHERE film_id = 1007; -- OK
SELECT * FROM film WHERE film_id = 1007; -- title = 'TEST' FOR film WITH ID = 1007
DELETE FROM film WHERE film_id = 1007;-- OK
SELECT * FROM film WHERE film_id = 1007;-- OK EMPTY TABLE
ROLLBACK;

-- CHECK ROLE dvd_backend_tester
BEGIN;
SET ROLE dvd_backend_tester;
SELECT current_user;
SELECT * FROM public.film; 	-- OK
SELECT * FROM public.actor;	-- OK
SELECT * FROM public.rental;-- OK
UPDATE public.film SET title  = 'TEST' WHERE film_id = 1007; -- permission denied for table film
DELETE FROM film WHERE film_id = 1007;-- permission denied for table film
ROLLBACK;


-- TASK 3: Configure it for your database, so that the customer can only access his own data in "rental" and "payment" tables
-- (verify using the personalized role you previously created).

-- SET row-level security
ALTER TABLE public.rental ENABLE ROW LEVEL SECURITY;	
ALTER TABLE public.payment  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer  ENABLE ROW LEVEL SECURITY; -- FOR identification customer_id

-- SET PERMISSION FOR READ
GRANT SELECT ON TABLE public.rental, public.payment TO dvd_customer; 

-- SET read only 
CREATE POLICY dvd_database_developer_rental_read ON public.rental USING (current_user='dvd_database_developer'); --  allow SELECT ALL rows
CREATE POLICY dvd_database_developer_payment_read ON public.payment USING (current_user='dvd_database_developer');-- allow SELECT ALL rows
CREATE POLICY dvd_backend_tester_rental_read ON public.rental FOR SELECT USING(current_user='dvd_backend_tester');-- allow SELECT ALL rows
CREATE POLICY dvd_backend_tester_payment_read ON public.payment FOR SELECT USING(current_user='dvd_backend_tester');-- allow SELECT ALL rows
CREATE POLICY dvd_database_developer_customer_read ON public.customer USING (current_user='dvd_database_developer');-- allow SELECT ALL rows
CREATE POLICY dvd_backend_tester_customer_read ON public.customer FOR SELECT USING(current_user='dvd_backend_tester');-- allow SELECT ALL rows
CREATE POLICY dvd_client_any_customer_read ON public.customer FOR SELECT USING (format('%s %s', lower(first_name), lower(last_name))
											=(SELECT format('%s %s', split_part(current_user,'_',2), split_part(current_user,'_',3)))); -- allow SELECT only customer's rows for certain customer

 -- allow SELECT only customer rows from rental
CREATE POLICY dvd_cust_rental_read ON public.rental FOR SELECT
 USING (customer_id IN (SELECT customer_id 
							FROM customer 
							WHERE format('%s %s', lower(first_name), lower(last_name))
							=(SELECT format('%s %s', split_part(current_user,'_',2), split_part(current_user,'_',3)))));
-- allow SELECT only customer rows from payment						
CREATE POLICY dvd_cust_payment_read ON public.payment FOR SELECT
 USING (customer_id IN (	SELECT customer_id 
							FROM customer 
							WHERE format('%s %s', lower(first_name), lower(last_name))
							=(SELECT format('%s %s', split_part(current_user,'_',2), split_part(current_user,'_',3)))));

-- Check role and permissions
SET ROLE client_eugene_yurchenko;
SET ROLE client_mary_smith;
SET ROLE dvd_database_developer;
SET ROLE dvd_backend_tester;
SELECT current_user;
SELECT * FROM public.rental;
SELECT * FROM public.payment;
SELECT customer_id AS "#", format('%s %s', INITCAP(first_name), INITCAP(last_name)) AS Fname, email FROM public.customer;
SET ROLE postgres;


-- TASK 4: Prepare answers to the following questions.

-- 4.1 How can one restrict access to certain columns of a database table?
-- We can create a view with certain columns and give access to the view. And  take away the rights for the source table
-- Or we can use GRANT SELECT and specify columns (certain column1, certain columns, ...) ON table to ROLE 

-- 4.2  What is the difference between user identification and user authentication?
-- Authentication - It is when we use login and password to connect to DB. 
-- Server identity of the client by login and password and can identify with role and permissions it has.
-- identification - It is when we specify something. Such as we can identify customers by customer ID

-- 4.3 What are the recommended authentication protocols for PostgreSQL?
-- Documentation recommended use Peer Authentication or Trust Authentication for local connections. 
-- For remote connections recomended use  Password Authentication or Certificate Authentication

-- 4.4 What is proxy authentication in PostgreSQL and what is it for? 
-- Why does it make the previously discussed role-based access control easier to implement?

-- in PostgreSQL the role of proxy authentication perfomes pg_hba.conf file - controls how people can connect to the database
-- we can specifi exact user, database, connection method, and authentication method combinations that are allowed access to the server 

-- I think it makes role-based access control easier to implement, because we can combine some roles for connected user or set model of authentication
