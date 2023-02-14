--PART 1: CREATE SCHEMA AND TABLES 

CREATE DATABASE kindergarten;

CREATE SCHEMA IF NOT EXISTS kinder;

--groups
CREATE TABLE IF NOT EXISTS kinder.groups(
	group_id INT GENERATED ALWAYS AS IDENTITY
	,group_name VARCHAR (50)
	,PRIMARY KEY(group_id)
	);

--children
CREATE TABLE IF NOT EXISTS kinder.children (
	children_id INT GENERATED ALWAYS AS IDENTITY
	,group_id INT
	,children_Fname VARCHAR ( 50 )  NOT NULL
	,children_Lname VARCHAR ( 50 )  NOT NULL
	,children_DOB DATE  NOT NULL CHECK (extract( year FROM children_DOB) >= extract( year from current_timestamp )-6) -- ONLY children ubder 7 years
	,PRIMARY KEY(children_id)
	,CONSTRAINT FK_groups FOREIGN KEY(group_id) REFERENCES kinder.groups(group_id)
	);

--menu
CREATE TABLE IF NOT EXISTS kinder.menu (
	dish_id INT GENERATED ALWAYS AS IDENTITY
	,dish_name VARCHAR ( 50 ) NOT NULL
	,details VARCHAR ( 50 )
	,PRIMARY KEY(dish_id)
	,CONSTRAINT UC_menu UNIQUE (dish_name,details)
	);

--meal_plan
CREATE TABLE IF NOT EXISTS kinder.meal_plan (
	meal_plan_id INT GENERATED ALWAYS AS IDENTITY
	,children_id INT
	,meal_plane_date DATE  NOT NULL 
	,meal_plan_details VARCHAR ( 50 )
	,PRIMARY KEY(meal_plan_id)
	,CONSTRAINT FK_children FOREIGN KEY(children_id) REFERENCES kinder.children(children_id)
	);

--meal_plan_menu
CREATE TABLE IF NOT EXISTS kinder.meal_plan_menu (
	meal_plan_id INT
	, dish_id INT
	, quantity INT 
	, meal_plan_menu_date DATE
	,CONSTRAINT FK_menu FOREIGN KEY(dish_id)  REFERENCES kinder.menu (dish_id)
	,CONSTRAINT FK_meal_plan FOREIGN KEY(meal_plan_id) REFERENCES kinder.meal_plan(meal_plan_id)
	,CONSTRAINT Check_Qty CHECK (quantity<3) -- ONLY two the same dish IN one hands
	);

--employees
CREATE TABLE IF NOT EXISTS kinder.employees (
	employees_id INT GENERATED ALWAYS AS IDENTITY
	,employees_Fname VARCHAR ( 50 )  NOT NULL
	,employees_Lname VARCHAR ( 50 )  NOT NULL
	,PRIMARY KEY(employees_id)
	);

--employees_groups
CREATE TABLE IF NOT EXISTS kinder.employees_groups (
	employees_id INT
	,group_id INT
	,CONSTRAINT FK_groups FOREIGN KEY(group_id) REFERENCES kinder.groups(group_id)
	,CONSTRAINT FK_employees FOREIGN KEY(employees_id) REFERENCES kinder.employees(employees_id)
	);

--rooms
CREATE TABLE IF NOT EXISTS kinder.rooms (
	room_id INT GENERATED ALWAYS AS IDENTITY
	,room_name VARCHAR ( 50 )  NOT NULL
	,PRIMARY KEY(room_id)
	);

--schedule
CREATE TABLE IF NOT EXISTS kinder.schedule (
	schedule_id INT GENERATED ALWAYS AS IDENTITY
	,group_id INT
	,room_id INT
	,start_time VARCHAR ( 10 ) NOT NULL
	,end_time VARCHAR ( 10 ) NOT NULL
	,PRIMARY KEY(schedule_id)
	,CONSTRAINT FK_groups FOREIGN KEY(group_id) REFERENCES kinder.groups(group_id)
	,CONSTRAINT FK_rooms FOREIGN KEY(room_id) REFERENCES kinder.rooms(room_id)
	);

--schedule_confirmed
CREATE TABLE IF NOT EXISTS kinder.schedule_confirmed (
	sconfirmed_id INT GENERATED ALWAYS AS IDENTITY
	,schedule_id INT
	,employees_id INT
	,Start_WTme TIMESTAMP CHECK ((Start_WTme AT TIME ZONE 'UTC')::time >= '08:00:00'::time)
	,End_WTme TIMESTAMP  CHECK ((Start_WTme AT TIME ZONE 'UTC')::time <= '19:00:00'::time)
	,PRIMARY KEY(sconfirmed_id)
	,FOREIGN KEY(schedule_id) REFERENCES kinder.schedule(schedule_id)
	,FOREIGN KEY(employees_id) REFERENCES kinder.employees(employees_id)
	,CONSTRAINT start_before_end CHECK (Start_WTme < End_WTme )
	);

--employees_role
CREATE TABLE IF NOT EXISTS kinder.employees_role (
	role_id INT GENERATED ALWAYS AS IDENTITY
	,role_name VARCHAR ( 50 )  NOT NULL
	,role_CheckFullDay BOOLEAN DEFAULT 'TRUE'  NOT NULL
	,PRIMARY KEY(role_id)
	);

--employees_role_employees
CREATE TABLE IF NOT EXISTS kinder.employees_role_employees (
	role_id INT
	,employees_id INT
	,CONSTRAINT FK_role FOREIGN KEY(role_id)  REFERENCES kinder.employees_role (role_id)
	,CONSTRAINT FK_employees FOREIGN KEY(employees_id) REFERENCES kinder.employees(employees_id)
	);
	
--ResponsibleAdultStatus
CREATE TABLE IF NOT EXISTS kinder.ResponsibleAdultStatus (
	RespAdultStatus_id INT GENERATED ALWAYS AS IDENTITY
	,RAS_detail VARCHAR ( 50 ) NOT NULL
	,PRIMARY KEY(RespAdultStatus_id)
	);

--ResponsibleAdult
CREATE TABLE IF NOT EXISTS kinder.ResponsibleAdult (
	RespAdult_id INT GENERATED ALWAYS AS IDENTITY
	,RespAdult_Fname VARCHAR ( 50 )  NOT NULL
	,RespAdult_Lname VARCHAR ( 50 )  NOT NULL
	,phonenumber_details VARCHAR ( 11 )
	,PRIMARY KEY(RespAdult_id)
	,CONSTRAINT PN_Check CHECK (phonenumber_details not like '%[^0-9]%')
	);

--ResponsibleAdult_Children
CREATE TABLE IF NOT EXISTS kinder.ResponsibleAdult_Children (
	RespAdult_id INT
	, children_id INT
	, RespAdultStatus_id INT 
	,CONSTRAINT FK_RespAdult FOREIGN KEY(RespAdult_id)  REFERENCES kinder.ResponsibleAdult (RespAdult_id)
	,CONSTRAINT FK_children FOREIGN KEY(children_id) REFERENCES kinder.children(children_id)
	,CONSTRAINT FK_RespAdultStatus FOREIGN KEY(RespAdultStatus_id) REFERENCES kinder.ResponsibleAdultStatus(RespAdultStatus_id)
	);

--City
CREATE TABLE IF NOT EXISTS kinder.city (
	city_id INT GENERATED ALWAYS AS IDENTITY
	,city_name VARCHAR ( 50 ) UNIQUE  NOT NULL
	,PRIMARY KEY(city_id)
	);

--District
CREATE TABLE IF NOT EXISTS kinder.district (
	district_id INT GENERATED ALWAYS AS IDENTITY
	,city_id INT
	,district_name VARCHAR ( 50 )  NOT NULL
	,PRIMARY KEY(district_id)
	,CONSTRAINT FK_city FOREIGN KEY(city_id)  REFERENCES kinder.city(city_id)
	);

--Street
CREATE TABLE IF NOT EXISTS kinder.street (
	street_id INT GENERATED ALWAYS AS IDENTITY
	,street_name VARCHAR ( 50 )  NOT NULL
	,PRIMARY KEY(street_id)
	);
	
--Street_District
CREATE TABLE IF NOT EXISTS kinder.Street_District (
	district_id INT
	,street_id INT
	,CONSTRAINT FK_district FOREIGN KEY(district_id)  REFERENCES kinder.district(district_id)
	,CONSTRAINT FK_street FOREIGN KEY(street_id)  REFERENCES kinder.street(street_id)
	,PRIMARY KEY(district_id,street_id)
	);

--Building
CREATE TABLE IF NOT EXISTS kinder.Building (
	Building_id INT GENERATED ALWAYS AS IDENTITY
	,district_id INT
	,street_id INT
	,Building_Number INT  NOT NULL
	,CheckStreetToApplay BOOLEAN DEFAULT 'TRUE'
	,PRIMARY KEY(Building_id)
	,FOREIGN KEY(district_id,street_id) REFERENCES kinder.Street_District(district_id,street_id)
	);
	
--RespAdultAdress
CREATE TABLE IF NOT EXISTS kinder.RespAdultAdress (
	RespAdultAdress_id INT GENERATED ALWAYS AS IDENTITY
	,RespAdult_id INT
	,Building_id INT
	,Appartment_number INT  NOT NULL
	,RespAdultAdress_Description VARCHAR ( 50 )  NOT NULL
	,PRIMARY KEY(RespAdultAdress_id)
	,CONSTRAINT FK_RespAdult FOREIGN KEY(RespAdult_id)  REFERENCES kinder.ResponsibleAdult(RespAdult_id)
	,CONSTRAINT FK_Building FOREIGN KEY(Building_id)  REFERENCES kinder.Building(Building_id) 
	);	
	
--PART 2: INSERT DATA INTO TABLES

--Menu
INSERT INTO kinder.menu
(dish_name, details)
SELECT dish_name, details
FROM 
	(Select 'Zupa' AS dish_name, 'Spice' AS details
	UNION ALL
    SELECT 'Steak', 'Rare'
    UNION ALL
    SELECT 'Water', 'Cold'
    UNION ALL
    SELECT 'Water', 'Sparkling'
    UNION ALL
    SELECT 'Water', 'Still'
	) AS new_menu
WHERE (new_menu.dish_name,new_menu.details) NOT IN (SELECT dish_name,details FROM kinder.menu)
RETURNING *;

--Rooms
INSERT INTO kinder.rooms
(room_name)
SELECT room_name
FROM 
	(Select 'Bedroom' AS room_name
	UNION ALL
    SELECT 'Gym'
    UNION ALL
    SELECT 'Class #1'
	UNION ALL
    SELECT 'Class #2'
	UNION ALL
    SELECT 'Class #3'
    UNION ALL
    SELECT 'Music room' 
	) AS new_rooms
WHERE (new_rooms.room_name) NOT IN (SELECT room_name FROM kinder.rooms)
RETURNING *;

--City
INSERT INTO kinder.city
(city_name)
SELECT city_name
FROM 
	(Select 'Krakow' AS city_name
	UNION ALL
    SELECT 'Warsaw'
    ) AS new_city
WHERE (new_city.city_name) NOT IN (SELECT city_name FROM kinder.city)
RETURNING *;

--Street
INSERT INTO kinder.street
(street_name)
SELECT street_name
FROM 
	(Select 'Sw. Anny Street' AS street_name
	UNION ALL
    SELECT 'Szewska Street'
    UNION ALL
    SELECT 'Karmelicka Street'
    ) AS new_street
WHERE (new_street.street_name) NOT IN (SELECT street_name FROM kinder.street)
RETURNING *;

--ResponsibleAdultStatus
INSERT INTO kinder.responsibleadultstatus
(RAS_detail)
SELECT RAS_detail
FROM 
	(Select 'Parents' AS RAS_detail
	UNION ALL
    SELECT 'Relatives'
    UNION ALL
    SELECT 'Curator'
    ) AS new_responsibleadultstatus
WHERE (new_responsibleadultstatus.RAS_detail) NOT IN (SELECT RAS_detail FROM kinder.responsibleadultstatus)
RETURNING *;

--Employees_role
INSERT INTO kinder.employees_role
(role_name, role_CheckFullDay)
SELECT role_name, role_CheckFullDay
FROM 
	(Select 'Director' AS role_name, TRUE AS role_checkfullday
	UNION ALL
    SELECT 'Educator', TRUE
    UNION ALL
    SELECT 'Guard', TRUE
    UNION ALL
    SELECT 'Doctor', TRUE
    UNION ALL
    SELECT 'Music Teacher', FALSE
    UNION ALL
    SELECT 'Dance Teacher', FALSE
    ) AS new_employees_role
WHERE (new_employees_role.role_name) NOT IN (SELECT role_name FROM kinder.employees_role)
RETURNING *;


--Groups
INSERT INTO kinder."groups"
(group_name)
SELECT group_name
FROM 
	(Select 'Raspberry' AS group_name
	UNION ALL
    SELECT 'Strawberry'
    UNION ALL
    SELECT 'Blackberry'
    ) AS new_groups
WHERE (new_groups.group_name) NOT IN (SELECT group_name FROM kinder."groups")
RETURNING *;

--Children
INSERT INTO kinder.children
(group_id, children_fname, children_lname, children_dob)
SELECT group_id, children_fname, children_lname, children_dob
FROM
	(SELECT 'Raspberry' AS group_name, 'Pikachu' AS children_fname, 'Shinx' AS children_lname, TO_DATE('17/12/2018', 'DD/MM/YYYY') AS children_dob
	UNION ALL
    SELECT 'Raspberry', 'Voltorb', 'Blitzle', TO_DATE('14/07/2019', 'DD/MM/YYYY') 
    UNION ALL
    SELECT 'Strawberry', 'Jolteon', 'Luxray', TO_DATE('21/03/2017', 'DD/MM/YYYY')
    UNION ALL
    SELECT 'Blackberry', 'Mareep', 'Shinx', TO_DATE('11/08/2016', 'DD/MM/YYYY')
    UNION ALL
    SELECT 'Strawberry', 'Flaaffy', 'Yamper', TO_DATE('30/05/2017', 'DD/MM/YYYY') 
    UNION ALL
    SELECT 'Blackberry', 'Plusle', 'Yamper', TO_DATE('31/12/2016', 'DD/MM/YYYY')
	) AS new_children
INNER JOIN kinder."groups" gr
ON new_children.group_name=gr.group_name 
WHERE extract( year FROM children_DOB) >= extract( year from current_timestamp )-6
AND 
(new_children.children_fname,new_children.children_lname) NOT IN (SELECT children_fname, children_lname FROM kinder.children)
RETURNING *
	;

--Meal_plan
INSERT INTO kinder.meal_plan
(children_id, meal_plane_date, meal_plan_details)
SELECT ch.children_id, meal_plane_date, meal_plan_details
FROM
	(SELECT 'Pikachu'||'Shinx' AS children_fn, TO_DATE('05/12/2022', 'DD/MM/YYYY') AS meal_plane_date, 'only vegans' AS meal_plan_details
	UNION ALL 
	SELECT 'Voltorb'||'Blitzle', TO_DATE('06/12/2022', 'DD/MM/YYYY'), 'w/o milk'
	UNION ALL 
	SELECT 'Jolteon'||'Luxray',TO_DATE('05/12/2022', 'DD/MM/YYYY'), null
	UNION ALL 
	SELECT 'Mareep'||'Shinx',TO_DATE('06/12/2022', 'DD/MM/YYYY'), 'help with spoon'
	UNION ALL 
	SELECT 'Flaaffy'||'Yamper',TO_DATE('05/12/2022', 'DD/MM/YYYY'), null
	UNION ALL 
	SELECT 'Plusle'||'Yamper',TO_DATE('06/12/2022', 'DD/MM/YYYY'), null
) AS new_meal_plan
INNER JOIN	kinder.children ch
ON ch.children_fname||ch.children_lname=new_meal_plan.children_fn
WHERE (new_meal_plan.children_fn, new_meal_plan.meal_plan_details) NOT IN (SELECT ch.children_fname||ch.children_lname, meal_plan_details FROM kinder.meal_plan)
RETURNING *
;

--Meal_plan_Menu
INSERT INTO kinder.meal_plan_menu
(meal_plan_id, dish_id, quantity, meal_plan_menu_date)
SELECT meal_plan_id, dish_id, quantity, meal_plan_menu_date
FROM
	(SELECT (SELECT children.children_id FROM children WHERE children.children_fname||children.children_lname = 'Pikachu'||'Shinx') AS children_id, (SELECT dish_id FROM menu where upper(dish_name)=upper('Zupa')AND upper(details)=upper('Spice')) AS dish_id, 1 AS quantity, TO_DATE('05/12/2022', 'DD/MM/YYYY') AS meal_plan_menu_date
	UNION ALL  
	SELECT (SELECT children.children_id FROM children WHERE children.children_fname||children.children_lname = 'Pikachu'||'Shinx'), (SELECT dish_id FROM menu where upper(dish_name)=upper('Steak')AND upper(details)=upper('Rare')), 1, TO_DATE('05/12/2022', 'DD/MM/YYYY')
	UNION ALL 
	SELECT (SELECT children.children_id FROM children WHERE children.children_fname||children.children_lname = 'Pikachu'||'Shinx'), (SELECT dish_id FROM menu where upper(dish_name)=upper('Water')AND upper(details)=upper('Sparkling')), 1, TO_DATE('05/12/2022', 'DD/MM/YYYY')
	UNION ALL 
	SELECT (SELECT children.children_id FROM children WHERE children.children_fname||children.children_lname = 'Pikachu'||'Shinx'), (SELECT dish_id FROM menu where upper(dish_name)=upper('Zupa')AND upper(details)=upper('Spice')), 1, TO_DATE('06/12/2022', 'DD/MM/YYYY')
	UNION ALL 
	SELECT (SELECT children.children_id FROM children WHERE children.children_fname||children.children_lname = 'Pikachu'||'Shinx'), (SELECT dish_id FROM menu where upper(dish_name)=upper('Steak')AND upper(details)=upper('Rare')), 1, TO_DATE('06/12/2022', 'DD/MM/YYYY')
	UNION ALL 
	SELECT (SELECT children.children_id FROM children WHERE children.children_fname||children.children_lname = 'Pikachu'||'Shinx'), (SELECT dish_id FROM menu where upper(dish_name)=upper('Water')AND upper(details)=upper('still')), 1, TO_DATE('06/12/2022', 'DD/MM/YYYY')
	UNION ALL 
	SELECT (SELECT children.children_id FROM children WHERE children.children_fname||children.children_lname = 'Jolteon'||'Luxray'), (SELECT dish_id FROM menu where upper(dish_name)=upper('Zupa')AND upper(details)=upper('Spice')), 1, TO_DATE('05/12/2022', 'DD/MM/YYYY')
	UNION ALL 
	SELECT (SELECT children.children_id FROM children WHERE children.children_fname||children.children_lname = 'Jolteon'||'Luxray'), (SELECT dish_id FROM menu where upper(dish_name)=upper('Steak')AND upper(details)=upper('Rare')), 1, TO_DATE('05/12/2022', 'DD/MM/YYYY')
	UNION ALL 
	SELECT (SELECT children.children_id FROM children WHERE children.children_fname||children.children_lname = 'Jolteon'||'Luxray'), (SELECT dish_id FROM menu where upper(dish_name)=upper('Water')AND upper(details)=upper('cold')), 1, TO_DATE('05/12/2022', 'DD/MM/YYYY')
	UNION ALL 
	SELECT (SELECT children.children_id FROM children WHERE children.children_fname||children.children_lname = 'Jolteon'||'Luxray'), (SELECT dish_id FROM menu where upper(dish_name)=upper('Zupa') AND upper(details)=upper('Spice')), 1, TO_DATE('06/12/2022', 'DD/MM/YYYY')
	UNION ALL 
	SELECT (SELECT children.children_id FROM children WHERE children.children_fname||children.children_lname = 'Jolteon'||'Luxray'), (SELECT dish_id FROM menu where upper(dish_name)=upper('Steak') AND upper(details)=upper('Rare')), 1, TO_DATE('06/12/2022', 'DD/MM/YYYY')
	UNION ALL 
	SELECT (SELECT children.children_id FROM children WHERE children.children_fname||children.children_lname = 'Jolteon'||'Luxray'), (SELECT dish_id FROM menu where upper(dish_name)=upper('Water') AND upper(details)=upper('cold') ), 1, TO_DATE('06/12/2022', 'DD/MM/YYYY')
	) AS new_meal_plan_menu
	INNER JOIN kinder.meal_plan mp 
ON mp.children_id = new_meal_plan_menu.children_id --AND mp.meal_plane_date =new_meal_plan_menu.meal_plan_menu_date
WHERE (new_meal_plan_menu.dish_id, new_meal_plan_menu.meal_plan_menu_date) NOT IN (SELECT dish_id, meal_plan_menu_date FROM kinder.meal_plan_menu)
RETURNING *
;

--ResponsibleAdult
INSERT INTO kinder.responsibleadult
(respadult_fname, respadult_lname, phonenumber_details)
SELECT respadult_fname, respadult_lname, phonenumber_details
FROM
	(SELECT 'Luxio' AS respadult_fname, 'Shinx' AS respadult_lname, '48500123120'AS phonenumber_details
	UNION ALL 
	SELECT 'Zeraora',  'Shinx', '48500123130'
	UNION ALL 
	SELECT 'Pachirisu',  'Blitzle', '48500123140'
	UNION ALL 
	SELECT 'Luxio',  'Luxray', '48500123140'
	UNION ALL 
	SELECT 'Zeraora',  'Yamper', '48500123140'
	) AS new_responsibleadult
	WHERE (new_responsibleadult.respadult_fname, new_responsibleadult.respadult_Lname) NOT IN (SELECT respadult_fname, respadult_lname FROM kinder.responsibleadult)
	RETURNING *
	;

--Responsibleadult_Children
INSERT INTO kinder.responsibleadult_children 
(respadult_id, children_id, respadultstatus_id)
SELECT respadult_id, children_id,  respadultstatus_id
FROM
	(SELECT (SELECT respadult_id FROM responsibleadult WHERE respadult_fname||respadult_lname = 'Luxio'||'Shinx') AS respadult_id, (SELECT children.children_id FROM children WHERE children.children_fname||children.children_lname = 'Pikachu'||'Shinx') AS children_id, (SELECT respadultstatus_id FROM kinder.responsibleadultstatus  WHERE upper(ras_detail)=upper('parents')) AS respadultstatus_id
	UNION ALL  
	SELECT  (SELECT respadult_id FROM responsibleadult WHERE respadult_fname||respadult_lname = 'Zeraora'||'Shinx'), (SELECT children.children_id FROM children WHERE children.children_fname||children.children_lname = 'Pikachu'||'Shinx'), (SELECT respadultstatus_id FROM kinder.responsibleadultstatus  WHERE upper(ras_detail)=upper('parents'))
	UNION ALL  
	SELECT  (SELECT respadult_id FROM responsibleadult WHERE respadult_fname||respadult_lname = 'Luxio'||'Luxray'), (SELECT children.children_id FROM children WHERE children.children_fname||children.children_lname = 'Voltorb'||'Blitzle'), (SELECT respadultstatus_id FROM kinder.responsibleadultstatus  WHERE upper(ras_detail)=upper('Curator'))
	UNION ALL  
	SELECT  (SELECT respadult_id FROM responsibleadult WHERE respadult_fname||respadult_lname = 'Luxio'||'Shinx'), (SELECT children.children_id FROM children WHERE children.children_fname||children.children_lname = 'Mareep'||'Shinx'), (SELECT respadultstatus_id FROM kinder.responsibleadultstatus  WHERE upper(ras_detail)=upper('parents'))
	UNION ALL 
	SELECT  (SELECT respadult_id FROM responsibleadult WHERE respadult_fname||respadult_lname = 'Zeraora'||'Shinx'), (SELECT children.children_id FROM children WHERE children.children_fname||children.children_lname = 'Mareep'||'Shinx'), (SELECT respadultstatus_id FROM kinder.responsibleadultstatus  WHERE upper(ras_detail)=upper('parents'))
	) AS new_responsibleadult_children
	WHERE (new_responsibleadult_children.respadult_id,new_responsibleadult_children.children_id) NOT IN (SELECT respadult_id, children_id FROM kinder.responsibleadult_children )
RETURNING *
;

--District
INSERT INTO kinder.district 
(city_id, district_name)
SELECT city_id, district_name
FROM
	(SELECT (SELECT city_id FROM city WHERE upper(city_name) = upper('Krakow')) AS city_id, 'Debniki' AS district_name
	UNION ALL 
	SELECT  (SELECT city_id FROM city WHERE upper(city_name) = upper('Krakow')), 'Czyzyny'
	UNION ALL 
	SELECT  (SELECT city_id FROM city WHERE upper(city_name) = upper('Krakow')), 'Stare Miasto'
	) AS new_district
WHERE (new_district.city_id, new_district.district_name) NOT IN (SELECT city_id, district_name FROM kinder.district)
RETURNING *
;

--Street_District
INSERT INTO kinder.street_district 
(district_id, street_id)
SELECT district_id, street_id
FROM 
	(SELECT (SELECT district_id FROM district WHERE upper(district_name) = upper('Debniki')) AS district_id, (SELECT street_id FROM street WHERE upper(street_name)= upper('Sw. Anny Street')) AS street_id
	UNION ALL 
	SELECT (SELECT district_id FROM district WHERE upper(district_name) = upper('Czyzyny')) AS district_id, (SELECT street_id FROM street WHERE upper(street_name)= upper('Szewska Street'))
	UNION ALL 
	SELECT (SELECT district_id FROM district WHERE upper(district_name) = upper('Stare Miasto')) AS district_id, (SELECT street_id FROM street WHERE upper(street_name)= upper('Karmelicka Street'))
	) AS new_street_district
WHERE (new_street_district.district_id, new_street_district.street_id) NOT IN (SELECT district_id, street_id FROM kinder.street_district )
RETURNING *
;

--Building
INSERT INTO kinder.building
(district_id, street_id, building_number, checkstreettoapplay)
SELECT district_id, street_id, building_number, checkstreettoapplay
FROM 
	(SELECT (SELECT district_id FROM district WHERE upper(district_name) = upper('Debniki')) AS district_id, (SELECT street_id FROM street WHERE upper(street_name)= upper('Sw. Anny Street')) AS street_id, 45 AS building_number, TRUE  AS checkstreettoapplay
	UNION ALL
	SELECT (SELECT district_id FROM district WHERE upper(district_name) = upper('Czyzyny')), (SELECT street_id FROM street WHERE upper(street_name)= upper('Szewska Street')), 12, FALSE 
	UNION ALL
	SELECT (SELECT district_id FROM district WHERE upper(district_name) = upper('Stare Miasto')), (SELECT street_id FROM street WHERE upper(street_name)= upper('Karmelicka Street')), 68, FALSE 
	) AS new_building
WHERE (new_building.district_id, new_building.street_id, new_building.building_number) NOT IN (SELECT district_id, street_id, building_number FROM  kinder.building)
RETURNING *
;


--RespAdultAddress
WITH AllowStreet AS (SELECT b.building_id, d.district_name, s.street_name  FROM building b INNER JOIN district d ON d.district_id=b.district_id INNER JOIN street s ON s.street_id=b.street_id WHERE checkstreettoapplay=TRUE )
INSERT INTO kinder.respadultadress
(respadult_id, building_id, appartment_number, respadultadress_description)
SELECT respadult_id, building_id, appartment_number, respadultadress_description
FROM 
	(SELECT (SELECT respadult_id FROM responsibleadult WHERE respadult_fname||respadult_lname = 'Luxio'||'Shinx') AS respadult_id, (SELECT building_id FROM AllowStreet WHERE upper(district_name) = upper('Debniki') AND upper(street_name) = upper('Sw. Anny Street') )AS building_id, 65::INT AS appartment_number, 'ok' AS respadultadress_description
	UNION ALL 
	SELECT (SELECT respadult_id FROM responsibleadult WHERE respadult_fname||respadult_lname = 'Zeraora'||'Shinx'), (SELECT building_id FROM AllowStreet WHERE upper(district_name) = upper('Debniki') AND upper(street_name) = upper('Sw. Anny Street')), 65::INT, 'ok' 
	UNION  ALL 
	SELECT (SELECT respadult_id FROM responsibleadult WHERE respadult_fname||respadult_lname = 'Luxio'||'Luxray'), (SELECT building_id FROM AllowStreet WHERE upper(district_name) = upper('Debniki') AND upper(street_name) = upper('Sw. Anny Street')), 45::INT, 'ok'
	) AS new_respadultadress
WHERE (new_respadultadress.respadult_id, new_respadultadress.building_id, new_respadultadress.appartment_number) NOT IN (SELECT respadult_id, building_id, appartment_number FROM kinder.respadultadress)
RETURNING *
;


--Employees
INSERT INTO kinder.employees
( employees_fname, employees_lname)
SELECT employees_fname, employees_lname 
FROM 
	(SELECT 'Reksio' AS employees_fname, 'Oisker' AS employees_lname
	UNION ALL 
	SELECT 'Bolek', 'Kelob'
	UNION ALL 
	SELECT 'Lolek', 'Kolek'
	UNION ALL 
	SELECT 'Maya ', 'Ayam'
	UNION ALL 
	SELECT 'Willy  ', 'Ylliw'
	UNION ALL 
	SELECT 'Binio  ', 'Bill'
	UNION ALL 
	SELECT 'Miss  ', 'Cassandra'
	UNION ALL 
	SELECT 'Doctor  ', 'Skarpetka'
	UNION ALL 
	SELECT 'Musico  ', 'Daceco'
	) AS new_employees
WHERE (employees_fname, employees_lname) NOT IN (SELECT employees_fname, employees_lname FROM kinder.employees)
RETURNING *
;


--Employees_Role_Employees
INSERT INTO	kinder.employees_role_employees
(role_id, employees_id)
SELECT role_id, employees_id
FROM 
	(SELECT (SELECT role_id FROM employees_role WHERE upper(role_name)=upper('Director') ) AS role_id, (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Reksio') AND trim(upper(employees_lname)) = upper('Oisker')) AS employees_id
	UNION ALL 
	SELECT (SELECT role_id FROM employees_role WHERE upper(role_name)=upper('Educator') ), (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Bolek') AND trim(upper(employees_lname)) = upper('Kelob'))
	UNION ALL 
	SELECT (SELECT role_id FROM employees_role WHERE upper(role_name)=upper('Educator') ), (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Lolek') AND trim(upper(employees_lname)) = upper('Kolek'))
	UNION ALL 
	SELECT (SELECT role_id FROM employees_role WHERE upper(role_name)=upper('Educator') ), (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Maya') AND trim(upper(employees_lname)) = upper('Ayam'))
	UNION ALL 
	SELECT (SELECT role_id FROM employees_role WHERE upper(role_name)=upper('Music Teacher') ), (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Musico') AND trim(upper(employees_lname)) = upper('Daceco'))
	UNION ALL 
	SELECT (SELECT role_id FROM employees_role WHERE upper(role_name)=upper('Dance Teacher') ), (SELECT employees_id FROM employees WHERE upper(trim(employees_fname)) = upper('Miss') AND trim(upper(employees_lname)) = upper('Cassandra'))
	) AS new_employees_role_employees
	WHERE (new_employees_role_employees.role_id, new_employees_role_employees.employees_id) NOT IN (SELECT role_id, employees_id FROM kinder.employees_role_employees)
RETURNING *
;

--Employees_Groups
INSERT INTO kinder.employees_groups
(employees_id, group_id)
SELECT employees_id, group_id
FROM
	(SELECT (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Bolek') AND trim(upper(employees_lname)) = upper('Kelob')) AS employees_id, (SELECT group_id FROM kinder."groups" WHERE upper(group_name)=upper('Raspberry') )AS group_id 
	UNION ALL 
	SELECT (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Lolek') AND trim(upper(employees_lname)) = upper('Kolek')), (SELECT group_id FROM kinder."groups" WHERE upper(group_name)=upper('Strawberry') )
	UNION ALL 
	SELECT (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Maya') AND trim(upper(employees_lname)) = upper('Ayam')), (SELECT group_id FROM kinder."groups" WHERE upper(group_name)=upper('Blackberry') )
	) AS new_employees_groups
	WHERE (new_employees_groups.employees_id, new_employees_groups.group_id) NOT IN (SELECT employees_id, group_id FROM kinder.employees_groups)
	RETURNING *
;

--Schedule
INSERT INTO kinder.schedule
(group_id, room_id, start_time, end_time)
SELECT group_id, room_id, 	start_time, end_time
FROM 
	(SELECT (SELECT group_id FROM kinder."groups" WHERE upper(group_name)=upper('Raspberry') ) AS group_id, (SELECT room_id FROM rooms WHERE upper(room_name)=upper('Class #1')) AS room_id,'08:00:00' AS start_time, '10:00:00' AS end_time
	UNION ALL 
	SELECT (SELECT group_id FROM kinder."groups" WHERE upper(group_name)=upper('Strawberry') ), (SELECT room_id FROM rooms WHERE upper(room_name)=upper('Class #2')), '08:00:00', '10:00:00'
	UNION ALL 
	SELECT (SELECT group_id FROM kinder."groups" WHERE upper(group_name)=upper('Blackberry') ), (SELECT room_id FROM rooms WHERE upper(room_name)=upper('Class #3')), '08:00:00', '10:00:00'
	UNION ALL 
	SELECT (SELECT group_id FROM kinder."groups" WHERE upper(group_name)=upper('Raspberry') ), (SELECT room_id FROM rooms WHERE upper(room_name)=upper('Music room')), '10:00:00', '12:00:00'
	UNION ALL 
	SELECT (SELECT group_id FROM kinder."groups" WHERE upper(group_name)=upper('Strawberry') ), (SELECT room_id FROM rooms WHERE upper(room_name)=upper('Gym')), '10:00:00', '12:00:00'
	) AS new_schedule
	WHERE (group_id, room_id, start_time) NOT IN (SELECT group_id, room_id, start_time FROM kinder.schedule)
RETURNING *
;

--Schedule_Confirmed
INSERT INTO kinder.schedule_confirmed
(schedule_id, employees_id, Start_WTme, End_WTme)
SELECT schedule_id, employees_id, Start_WTme, End_WTme
FROM
	(SELECT	(SELECT schedule_id FROM schedule WHERE group_id = (SELECT group_id FROM kinder."groups" WHERE upper(group_name)=upper('Raspberry')) AND room_id = (SELECT room_id FROM rooms WHERE upper(room_name)=upper('Class #1'))) AS schedule_id, (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Bolek') AND trim(upper(employees_lname)) = upper('Kelob')) AS employees_id, timestamp '2022-12-05 08:00:00' AS Start_WTme, timestamp '2022-12-05 10:00:00' AS ENd_WTme    
	UNION ALL 
	SELECT	(SELECT schedule_id FROM schedule WHERE group_id = (SELECT group_id FROM kinder."groups" WHERE upper(group_name)=upper('Strawberry')) AND room_id = (SELECT room_id FROM rooms WHERE upper(room_name)=upper('Class #2'))), (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Lolek') AND trim(upper(employees_lname)) = upper('Kolek')), timestamp '2022-12-05 08:00:00', timestamp '2022-12-05 10:00:00'
	) AS new_Schedule_Confirmed
	WHERE (new_Schedule_Confirmed.schedule_id, new_Schedule_Confirmed.employees_id) NOT IN (SELECT schedule_id, employees_id FROM kinder.schedule_confirmed)
RETURNING *
;


--PART 3: Alter all tables and add 'record_ts' field

ALTER TABLE IF EXISTS kinder.building ADD IF NOT EXISTS record_ts Date NOT NULL DEFAULT now();
ALTER TABLE IF EXISTS kinder.children ADD IF NOT EXISTS record_ts Date NOT NULL DEFAULT now();
ALTER TABLE IF EXISTS kinder.city ADD IF NOT EXISTS record_ts Date NOT NULL DEFAULT now();
ALTER TABLE IF EXISTS kinder.district ADD IF NOT EXISTS record_ts Date NOT NULL DEFAULT now();
ALTER TABLE IF EXISTS kinder.employees ADD IF NOT EXISTS record_ts Date NOT NULL DEFAULT now();
ALTER TABLE IF EXISTS kinder.employees_groups ADD IF NOT EXISTS record_ts Date NOT NULL DEFAULT now();
ALTER TABLE IF EXISTS kinder.employees_role ADD IF NOT EXISTS record_ts Date NOT NULL DEFAULT now();
ALTER TABLE IF EXISTS kinder.employees_role_employees ADD IF NOT EXISTS record_ts Date NOT NULL DEFAULT now();
ALTER TABLE IF EXISTS kinder."groups" ADD IF NOT EXISTS record_ts Date NOT NULL DEFAULT now();
ALTER TABLE IF EXISTS kinder.meal_plan ADD IF NOT EXISTS record_ts Date NOT NULL DEFAULT now();
ALTER TABLE IF EXISTS kinder.meal_plan_menu ADD IF NOT EXISTS record_ts Date NOT NULL DEFAULT now();
ALTER TABLE IF EXISTS kinder.menu ADD IF NOT EXISTS record_ts Date NOT NULL DEFAULT now();
ALTER TABLE IF EXISTS kinder.respadultadress ADD IF NOT EXISTS record_ts Date NOT NULL DEFAULT now();
ALTER TABLE IF EXISTS kinder.responsibleadult ADD IF NOT EXISTS record_ts Date NOT NULL DEFAULT now();
ALTER TABLE IF EXISTS kinder.responsibleadult_children ADD IF NOT EXISTS record_ts Date NOT NULL DEFAULT now();
ALTER TABLE IF EXISTS kinder.responsibleadultstatus ADD IF NOT EXISTS record_ts Date NOT NULL DEFAULT now();
ALTER TABLE IF EXISTS kinder.rooms ADD IF NOT EXISTS record_ts Date NOT NULL DEFAULT now();
ALTER TABLE IF EXISTS kinder.schedule ADD IF NOT EXISTS record_ts Date NOT NULL DEFAULT now();
ALTER TABLE IF EXISTS kinder.schedule_confirmed ADD IF NOT EXISTS record_ts Date NOT NULL DEFAULT now();
ALTER TABLE IF EXISTS kinder.street ADD IF NOT EXISTS record_ts Date NOT NULL DEFAULT now();
ALTER TABLE IF EXISTS kinder.street_district ADD IF NOT EXISTS record_ts Date NOT NULL DEFAULT now();


