--1. Create database that monitors workload, capabilities and activities of our city's health institutions.

--Part One Create database and tables

CREATE DATABASE health_institutions;

CREATE SCHEMA IF NOT EXISTS health;

--Health care consumer
CREATE TABLE IF NOT EXISTS health.client (
	client_id INT GENERATED ALWAYS AS IDENTITY
	,client_Fname VARCHAR ( 50 )  NOT NULL
	,client_Lname VARCHAR ( 50 )  NOT NULL
	,client_DOB DATE  NOT NULL 
	,PRIMARY KEY(client_id)
	);

--Health institutions Status
CREATE TABLE IF NOT EXISTS health.institutionStatus (
	institutionStatus_id INT GENERATED ALWAYS AS IDENTITY
	,institutionStatus_Name VARCHAR ( 50 ) NOT NULL
	,PRIMARY KEY(institutionStatus_id)
	);

--Health institutions Services
CREATE TABLE IF NOT EXISTS health.institutionService (
	institutionService_id INT GENERATED ALWAYS AS IDENTITY
	,institutionService_Name VARCHAR ( 50 ) NOT NULL
	,PRIMARY KEY(institutionService_id)
	);

--Health institutions
CREATE TABLE IF NOT EXISTS health.institution (
	institution_id INT GENERATED ALWAYS AS IDENTITY
	,institution_Name VARCHAR ( 50 )  NOT NULL
	,phonenumber_details VARCHAR ( 11 )
	,capacity INT NOT NULL DEFAULT 10
	,PRIMARY KEY(institution_id)
	,CONSTRAINT PN_Check CHECK (phonenumber_details not like '%[^0-9]%')
	);

/*--Institution_Client
CREATE TABLE IF NOT EXISTS health.institution_client (
	institution_id INT
	, client_id INT
	,CONSTRAINT FK_institution FOREIGN KEY(institution_id)  REFERENCES health.institution (institution_id)
	,CONSTRAINT FK_client FOREIGN KEY(client_id) REFERENCES health.client(client_id)
	);*/

--Institution_Status
CREATE TABLE IF NOT EXISTS health.institution_Status (
	institution_id INT
	, institutionStatus_id INT 
	,CONSTRAINT FK_institution FOREIGN KEY(institution_id)  REFERENCES health.institution (institution_id)
	,CONSTRAINT FK_institutionStatus FOREIGN KEY(institutionStatus_id) REFERENCES health.institutionStatus(institutionStatus_id)
	);

--Institution_Service
CREATE TABLE IF NOT EXISTS health.institution_Service (
	institution_id INT
	, institutionService_id INT 
	,CONSTRAINT FK_institution FOREIGN KEY(institution_id)  REFERENCES health.institution (institution_id)
	,CONSTRAINT FK_institutionService FOREIGN KEY(institutionService_id) REFERENCES health.institutionService(institutionService_id)
	);

--City
CREATE TABLE IF NOT EXISTS health.city (
	city_id INT GENERATED ALWAYS AS IDENTITY
	,city_name VARCHAR ( 50 ) UNIQUE  NOT NULL
	,PRIMARY KEY(city_id)
	);

--District
CREATE TABLE IF NOT EXISTS health.district (
	district_id INT GENERATED ALWAYS AS IDENTITY
	,city_id INT
	,district_name VARCHAR ( 50 )  NOT NULL
	,PRIMARY KEY(district_id)
	,CONSTRAINT FK_city FOREIGN KEY(city_id)  REFERENCES health.city(city_id)
	);

--Street
CREATE TABLE IF NOT EXISTS health.street (
	street_id INT GENERATED ALWAYS AS IDENTITY
	,street_name VARCHAR ( 50 )  NOT NULL
	,PRIMARY KEY(street_id)
	);
	
--Street_District
CREATE TABLE IF NOT EXISTS health.Street_District (
	district_id INT
	,street_id INT
	,CONSTRAINT FK_district FOREIGN KEY(district_id)  REFERENCES health.district(district_id)
	,CONSTRAINT FK_street FOREIGN KEY(street_id)  REFERENCES health.street(street_id)
	,PRIMARY KEY(district_id,street_id)
	);

--Building
CREATE TABLE IF NOT EXISTS health.Building (
	Building_id INT GENERATED ALWAYS AS IDENTITY
	,district_id INT
	,street_id INT
	,Building_Number INT  NOT NULL
	,PRIMARY KEY(Building_id)
	,FOREIGN KEY(district_id,street_id) REFERENCES health.Street_District(district_id,street_id)
	);
	
--institutionsAdress
CREATE TABLE IF NOT EXISTS health.institutionAdress (
	institutionAdress_id INT GENERATED ALWAYS AS IDENTITY
	,institution_id INT
	,Building_id INT
	,institutionAdress_Description VARCHAR ( 50 )  NOT NULL
	,PRIMARY KEY(institutionAdress_id)
	,CONSTRAINT FK_institution FOREIGN KEY(institution_id)  REFERENCES health.institution(institution_id)
	,CONSTRAINT FK_Building FOREIGN KEY(Building_id)  REFERENCES health.Building(Building_id) 
	);	
	
--employees
CREATE TABLE IF NOT EXISTS health.employees (
	employees_id INT GENERATED ALWAYS AS IDENTITY
	,employees_Fname VARCHAR ( 50 )  NOT NULL
	,employees_Lname VARCHAR ( 50 )  NOT NULL
	,PRIMARY KEY(employees_id)
	);
	
--employees_role
CREATE TABLE IF NOT EXISTS health.employees_role (
	role_id INT GENERATED ALWAYS AS IDENTITY
	,role_name VARCHAR ( 50 )  NOT NULL
	,PRIMARY KEY(role_id)
	);

--Employees_Employees_Role
CREATE TABLE IF NOT EXISTS health.Employees_ERole (
	employees_id INT
	, role_id INT 
	,CONSTRAINT FK_employees FOREIGN KEY(employees_id) REFERENCES health.employees(employees_id)
	,CONSTRAINT FK_Role FOREIGN KEY(role_id)  REFERENCES health.employees_role(role_id)
	);

--Institution_employees
CREATE TABLE IF NOT EXISTS health.institution_Employees (
	institution_id INT
	, employees_id INT 
	,CONSTRAINT FK_institution FOREIGN KEY(institution_id)  REFERENCES health.institution (institution_id)
	,CONSTRAINT FK_employees FOREIGN KEY(employees_id) REFERENCES health.employees(employees_id)
	);

--schedule
CREATE TABLE IF NOT EXISTS health.schedule (
	schedule_id INT GENERATED ALWAYS AS IDENTITY
	,institution_id INT
	,client_id INT
	,start_time VARCHAR ( 20 ) NOT NULL DEFAULT now()
	,end_time VARCHAR ( 20 ) NOT NULL 
	,institutionservice_id int
	,PRIMARY KEY(schedule_id)
	,CONSTRAINT FK_SCH_institution FOREIGN KEY(institution_id) REFERENCES health.institution (institution_id)
	,CONSTRAINT FK_SCH_client FOREIGN KEY(client_id) REFERENCES health.client(client_id)
	);

--schedule_confirmed
CREATE TABLE IF NOT EXISTS health.schedule_confirmed (
	sconfirmed_id INT GENERATED ALWAYS AS IDENTITY
	,schedule_id INT
	,employees_id INT
	,Start_WTme TIMESTAMP CHECK ((Start_WTme AT TIME ZONE 'UTC')::time >= '08:00:00'::time) DEFAULT now()
	,End_WTme TIMESTAMP  CHECK ((Start_WTme AT TIME ZONE 'UTC')::time <= '19:00:00'::time)
	,PRIMARY KEY(sconfirmed_id)
	,FOREIGN KEY(schedule_id) REFERENCES health.schedule(schedule_id)
	,FOREIGN KEY(employees_id) REFERENCES health.employees(employees_id)
	,CONSTRAINT start_before_end CHECK (Start_WTme < End_WTme )
	);

-- Part two - insert data

--City
INSERT INTO health.city
(city_name)
SELECT city_name
FROM 
	(Select 'Krakow' AS city_name
	UNION ALL
    SELECT 'Warsaw'
    	UNION ALL
    SELECT 'Gdansk'
    	UNION ALL
    SELECT 'Poznan'
    	UNION ALL
    SELECT 'Wroclaw'
    ) AS new_city
WHERE (new_city.city_name) NOT IN (SELECT city_name FROM health.city)
RETURNING *;

--Street
INSERT INTO health.street
(street_name)
SELECT street_name
FROM 
	(Select 'Sw. Anny Street' AS street_name
	UNION ALL
    SELECT 'Szewska Street'
    UNION ALL
    SELECT 'Karmelicka Street'
    UNION ALL
    SELECT 'Pijarska Street'
    UNION ALL
    SELECT 'Szpitalna Street'
    ) AS new_street
WHERE (new_street.street_name) NOT IN (SELECT street_name FROM health.street)
RETURNING *;

--District
INSERT INTO health.district 
(city_id, district_name)
SELECT city_id, district_name
FROM
	(SELECT (SELECT city_id FROM city WHERE upper(city_name) = upper('Krakow')) AS city_id, 'Debniki' AS district_name
	UNION ALL 
	SELECT  (SELECT city_id FROM city WHERE upper(city_name) = upper('Krakow')), 'Czyzyny'
	UNION ALL 
	SELECT  (SELECT city_id FROM city WHERE upper(city_name) = upper('Krakow')), 'Stare Miasto'
	UNION ALL 
	SELECT  (SELECT city_id FROM city WHERE upper(city_name) = upper('Krakow')), 'Grzegorzki'
	UNION ALL 
	SELECT  (SELECT city_id FROM city WHERE upper(city_name) = upper('Krakow')), 'Krowodrza'
	) AS new_district
WHERE (new_district.city_id, new_district.district_name) NOT IN (SELECT city_id, district_name FROM health.district)
RETURNING *
;

--Street_District
INSERT INTO health.street_district 
(district_id, street_id)
SELECT district_id, street_id
FROM 
	(SELECT (SELECT district_id FROM district WHERE upper(district_name) = upper('Debniki')) AS district_id, (SELECT street_id FROM street WHERE upper(street_name)= upper('Sw. Anny Street')) AS street_id
	UNION ALL 
	SELECT (SELECT district_id FROM district WHERE upper(district_name) = upper('Krowodrza')) AS district_id, (SELECT street_id FROM street WHERE upper(street_name)= upper('Szewska Street'))
	UNION ALL 
	SELECT (SELECT district_id FROM district WHERE upper(district_name) = upper('Stare Miasto')) AS district_id, (SELECT street_id FROM street WHERE upper(street_name)= upper('Karmelicka Street'))
	UNION ALL 
	SELECT (SELECT district_id FROM district WHERE upper(district_name) = upper('Grzegorzki')) AS district_id, (SELECT street_id FROM street WHERE upper(street_name)= upper('Pijarska Street'))
	UNION ALL 
	SELECT (SELECT district_id FROM district WHERE upper(district_name) = upper('Czyzyny')) AS district_id, (SELECT street_id FROM street WHERE upper(street_name)= upper('Szpitalna Street'))
	) AS new_street_district
WHERE (new_street_district.district_id, new_street_district.street_id) NOT IN (SELECT district_id, street_id FROM health.street_district )
RETURNING *
;

--Building
INSERT INTO health.building
(district_id, street_id, building_number)
SELECT district_id, street_id, building_number
FROM 
	(SELECT (SELECT district_id FROM district WHERE upper(district_name) = upper('Debniki')) AS district_id, (SELECT street_id FROM street WHERE upper(street_name)= upper('Sw. Anny Street')) AS street_id, 45 AS building_number
	UNION ALL
	SELECT (SELECT district_id FROM district WHERE upper(district_name) = upper('Krowodrza')), (SELECT street_id FROM street WHERE upper(street_name)= upper('Szewska Street')), 12
	UNION ALL
	SELECT (SELECT district_id FROM district WHERE upper(district_name) = upper('Stare Miasto')), (SELECT street_id FROM street WHERE upper(street_name)= upper('Karmelicka Street')), 68
	UNION ALL
	SELECT (SELECT district_id FROM district WHERE upper(district_name) = upper('Grzegorzki')), (SELECT street_id FROM street WHERE upper(street_name)= upper('Pijarska Street')), 115
	UNION ALL
	SELECT (SELECT district_id FROM district WHERE upper(district_name) = upper('Czyzyny')), (SELECT street_id FROM street WHERE upper(street_name)= upper('Szpitalna Street')), 88
	) AS new_building
WHERE (new_building.district_id, new_building.street_id, new_building.building_number) NOT IN (SELECT district_id, street_id, building_number FROM  health.building)
RETURNING *
;

--Institution_Status
INSERT INTO health.institutionstatus
(institutionstatus_name)
SELECT institutionstatus_name
FROM 
	(Select 'Privite' AS institutionstatus_name
	UNION ALL
    SELECT 'Goverment'
    UNION ALL
    SELECT 'Childrens'
UNION ALL
    SELECT 'Laboratory'
UNION ALL
    SELECT 'Rehabilitation'
    ) AS new_institutionstatus
WHERE (new_institutionstatus.institutionstatus_name) NOT IN (SELECT institutionstatus_name FROM health.institutionstatus)
RETURNING *;

--Institution_Service
INSERT INTO health.institutionservice
(institutionservice_name)
SELECT institutionservice_name
FROM 
	(Select 'Diagnostics' AS institutionservice_name
	UNION ALL
    SELECT 'Short-term hospitalization'
    UNION ALL
    SELECT 'Emergency room services'
UNION ALL
    SELECT 'Laboratory services'
UNION ALL
    SELECT 'Blood services'
    ) AS new_institutionservice
WHERE (new_institutionservice.institutionservice_name) NOT IN (SELECT institutionservice_name FROM health.institutionservice)
RETURNING *;

--Institution
INSERT INTO health.institution
(institution_name, phonenumber_details, capacity)
SELECT institution_name, phonenumber_details, capacity
FROM 
	(Select 'Specialist Hospital. Jozef Dietl' AS institution_name, '48126143000' AS phonenumber_details, 500 AS capacity
	UNION ALL
    SELECT 'John Paul II Hospital', '48126142000', 200
    UNION ALL
    SELECT 'Szpital na Klinach', '48126144000', 50
    UNION ALL
    SELECT 'Military Clinical Hospital SPZOZ', '48126145000', 100
    UNION ALL
    SELECT 'Eco-Lab Healthcare', '48126145000', 10
    ) AS new_institution
WHERE (new_institution.institution_name) NOT IN (SELECT institution_name FROM health.institution)
RETURNING *;

--Institution_institution_Status
INSERT INTO health.institution_status 
(institution_id, institutionstatus_id)
SELECT institution_id, institutionstatus_id
FROM 
	(SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('Specialist Hospital. Jozef Dietl')) AS institution_id, (SELECT institutionstatus_id FROM institutionstatus WHERE upper(institutionstatus_name)= upper('Goverment')) AS institutionstatus_id
	UNION ALL 
	SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('John Paul II Hospital')), (SELECT institutionstatus_id FROM institutionstatus WHERE upper(institutionstatus_name)= upper('Goverment'))
	UNION ALL 
	SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('Szpital na Klinach')), (SELECT institutionstatus_id FROM institutionstatus WHERE upper(institutionstatus_name)= upper('Privite'))
	UNION ALL 
	SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('Military Clinical Hospital SPZOZ')), (SELECT institutionstatus_id FROM institutionstatus WHERE upper(institutionstatus_name)= upper('Rehabilitation'))
	UNION ALL 
	SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('Eco-Lab Healthcare')), (SELECT institutionstatus_id FROM institutionstatus WHERE upper(institutionstatus_name)= upper('Laboratory'))
	) AS new_institution_status 
WHERE (new_institution_status.institution_id, new_institution_status.institutionstatus_id) NOT IN (SELECT institution_id, institutionstatus_id FROM health.institution_status )
RETURNING *
;

--Institution_institution_Service
INSERT INTO health.institution_service 
(institution_id, institutionservice_id)
SELECT institution_id, institutionservice_id
FROM 
	(SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('Specialist Hospital. Jozef Dietl')) AS institution_id, (SELECT institutionservice_id FROM institutionservice WHERE upper(institutionservice_name)= upper('Diagnostics')) AS institutionservice_id
	UNION ALL 
	SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('John Paul II Hospital')), (SELECT institutionservice_id FROM institutionservice WHERE upper(institutionservice_name)= upper('Short-term hospitalization'))
	UNION ALL 
	SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('John Paul II Hospital')), (SELECT institutionservice_id FROM institutionservice WHERE upper(institutionservice_name)= upper('Emergency room services'))
	UNION ALL 
	SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('John Paul II Hospital')), (SELECT institutionservice_id FROM institutionservice WHERE upper(institutionservice_name)= upper('Blood services'))
	UNION ALL 
	SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('John Paul II Hospital')), (SELECT institutionservice_id FROM institutionservice WHERE upper(institutionservice_name)= upper('Laboratory services'))
	) AS new_institution_service 
WHERE (new_institution_service.institution_id, new_institution_service.institutionservice_id) NOT IN (SELECT institution_id, institutionservice_id FROM health.institution_service )
RETURNING *
;

--Clients
INSERT INTO health.Client
(Client_fname, Client_lname, Client_dob)
SELECT client_fname, client_lname, client_dob
FROM 
	(Select 'Daniel' AS client_fname, 'Olbrychski' AS client_lname, TO_DATE('01/03/1986', 'DD/MM/YYYY') AS client_dob
	UNION ALL
    SELECT 'Janusz', 'Gajos', TO_DATE('14/07/1976', 'DD/MM/YYYY') 
    UNION ALL
    SELECT 'Piotr', 'Adamczyk', TO_DATE('24/03/1986', 'DD/MM/YYYY') 
	UNION ALL
    SELECT 'Izabella', 'Miko', TO_DATE('28/11/1978', 'DD/MM/YYYY')
	UNION ALL
    SELECT 'Krystyna', 'Janda', TO_DATE('11/11/1996', 'DD/MM/YYYY')
    ) AS new_Client
WHERE (new_client.client_fname, new_client.client_Lname) NOT IN (SELECT client_fname, client_lname FROM health.client)
RETURNING *;


--Schedule
INSERT INTO health.schedule
(institution_id, client_id, start_time, end_time, institutionservice_id)
SELECT institution_id, client_id, start_time, end_time, institutionservice_id
FROM 
	(SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('Specialist Hospital. Jozef Dietl')) AS institution_id, (SELECT client_id FROM health.client WHERE upper(client_fname||client_lname)=upper('Daniel')||upper('Olbrychski') ) AS client_id, '01-01-2022 08:00'AS start_Time, '01-01-2022 09:00'AS end_time, (SELECT institutionservice_id FROM institutionservice WHERE upper(institutionservice_name)= upper('Emergency room services')) AS institutionservice_id
	UNION ALL 
	SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('Specialist Hospital. Jozef Dietl')), (SELECT client_id FROM health.client WHERE upper(client_fname||client_lname)=upper('Janusz')||upper('Gajos') ), '01-01-2022 09:00', '01-01-2022 10:00', (SELECT institutionservice_id FROM institutionservice WHERE upper(institutionservice_name)= upper('Diagnostics'))
	UNION ALL 
	SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('Specialist Hospital. Jozef Dietl')), (SELECT client_id FROM health.client WHERE upper(client_fname||client_lname)=upper('Piotr')||upper('Adamczyk') ), '01-01-2022 10:00', '01-01-2022 11:00', (SELECT institutionservice_id FROM institutionservice WHERE upper(institutionservice_name)= upper('Diagnostics'))
	UNION ALL 
	SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('Specialist Hospital. Jozef Dietl')), (SELECT client_id FROM health.client WHERE upper(client_fname||client_lname)=upper('Izabella')||upper('Miko') ), '01-01-2022 11:00', '01-01-2022 12:00', (SELECT institutionservice_id FROM institutionservice WHERE upper(institutionservice_name)= upper('Diagnostics'))
	UNION ALL 
	SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('Specialist Hospital. Jozef Dietl')), (SELECT client_id FROM health.client WHERE upper(client_fname||client_lname)=upper('Krystyna')||upper('Janda') ), '01-01-2022 12:00', '01-01-2022 13:00', (SELECT institutionservice_id FROM institutionservice WHERE upper(institutionservice_name)= upper('Diagnostics'))
	UNION ALL 
	SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('Specialist Hospital. Jozef Dietl')), (SELECT client_id FROM health.client WHERE upper(client_fname||client_lname)=upper('Janusz')||upper('Gajos') ), '01-02-2022 09:00', '01-02-2022 10:00', (SELECT institutionservice_id FROM institutionservice WHERE upper(institutionservice_name)= upper('Diagnostics'))
	UNION ALL 
	SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('Specialist Hospital. Jozef Dietl')), (SELECT client_id FROM health.client WHERE upper(client_fname||client_lname)=upper('Piotr')||upper('Adamczyk') ), '01-03-2022 10:00', '01-03-2022 11:00', (SELECT institutionservice_id FROM institutionservice WHERE upper(institutionservice_name)= upper('Short-term hospitalization'))
	UNION ALL 
	SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('Specialist Hospital. Jozef Dietl')), (SELECT client_id FROM health.client WHERE upper(client_fname||client_lname)=upper('Izabella')||upper('Miko') ), '01-04-2022 11:00', '01-04-2022 12:00', (SELECT institutionservice_id FROM institutionservice WHERE upper(institutionservice_name)= upper('Blood services'))
	UNION ALL 
	SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('Specialist Hospital. Jozef Dietl')), (SELECT client_id FROM health.client WHERE upper(client_fname||client_lname)=upper('Krystyna')||upper('Janda') ), '01-05-2022 12:00', '01-05-2022 13:00', (SELECT institutionservice_id FROM institutionservice WHERE upper(institutionservice_name)= upper('Emergency room services'))
	UNION ALL 
	SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('John Paul II Hospital')), (SELECT client_id FROM health.client WHERE upper(client_fname||client_lname)=upper('Janusz')||upper('Gajos') ), '02-02-2022 09:00', '02-02-2022 10:00', (SELECT institutionservice_id FROM institutionservice WHERE upper(institutionservice_name)= upper('Blood services'))
	UNION ALL 
	SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('Szpital na Klinach')), (SELECT client_id FROM health.client WHERE upper(client_fname||client_lname)=upper('Piotr')||upper('Adamczyk') ), '03-03-2022 10:00', '03-03-2022 11:00', (SELECT institutionservice_id FROM institutionservice WHERE upper(institutionservice_name)= upper('Laboratory services'))
	UNION ALL 
	SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('Military Clinical Hospital SPZOZ')), (SELECT client_id FROM health.client WHERE upper(client_fname||client_lname)=upper('Izabella')||upper('Miko') ), '04-04-2022 11:00', '04-04-2022 12:00', (SELECT institutionservice_id FROM institutionservice WHERE upper(institutionservice_name)= upper('Laboratory services'))
	UNION ALL 
	SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('Eco-Lab Healthcare')), (SELECT client_id FROM health.client WHERE upper(client_fname||client_lname)=upper('Krystyna')||upper('Janda') ), '05-05-2022 12:00', '05-05-2022 13:00', (SELECT institutionservice_id FROM institutionservice WHERE upper(institutionservice_name)= upper('Laboratory services'))
	) AS new_schedule
WHERE (new_schedule.institution_id,new_schedule.client_id, new_schedule.start_time) NOT IN (SELECT institution_id, client_id, start_time FROM health.schedule)
RETURNING *;

--Employees
INSERT INTO health.employees
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
WHERE (employees_fname, employees_lname) NOT IN (SELECT employees_fname, employees_lname FROM health.employees)
RETURNING *
;

--Employees_role
INSERT INTO health.employees_role
(role_name)
SELECT role_name
FROM 
	(Select 'Therapist' AS role_name
	UNION ALL
    SELECT ' Physical Therapist'
    UNION ALL
    SELECT 'Nurse Practitioner'
    UNION ALL
    SELECT 'Surgical Technologist'
    UNION ALL
    SELECT 'Psychiatr'
    UNION ALL
    SELECT ' Massage Therapist'
    ) AS new_employees_role
WHERE (new_employees_role.role_name) NOT IN (SELECT role_name FROM health.employees_role)
RETURNING *;

--Employees_Role_Employees
INSERT INTO	health.employees_erole
(role_id, employees_id)
SELECT role_id, employees_id
FROM 
	(SELECT (SELECT role_id FROM employees_role WHERE upper(role_name)=upper('Therapist') ) AS role_id, (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Reksio') AND trim(upper(employees_lname)) = upper('Oisker')) AS employees_id
	UNION ALL 
	SELECT (SELECT role_id FROM employees_role WHERE upper(role_name)=upper(' Physical Therapist') ), (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Bolek') AND trim(upper(employees_lname)) = upper('Kelob'))
	UNION ALL 
	SELECT (SELECT role_id FROM employees_role WHERE upper(role_name)=upper('Nurse Practitioner') ), (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Lolek') AND trim(upper(employees_lname)) = upper('Kolek'))
	UNION ALL 
	SELECT (SELECT role_id FROM employees_role WHERE upper(role_name)=upper('Surgical Technologist') ), (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Maya') AND trim(upper(employees_lname)) = upper('Ayam'))
	UNION ALL 
	SELECT (SELECT role_id FROM employees_role WHERE upper(role_name)=upper('Psychiatr') ), (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Musico') AND trim(upper(employees_lname)) = upper('Daceco'))
	UNION ALL 
	SELECT (SELECT role_id FROM employees_role WHERE upper(role_name)=upper(' Massage Therapist') ), (SELECT employees_id FROM employees WHERE upper(trim(employees_fname)) = upper('Miss') AND trim(upper(employees_lname)) = upper('Cassandra'))
	) AS new_employees_role_employees
	WHERE (new_employees_role_employees.role_id, new_employees_role_employees.employees_id) NOT IN (SELECT role_id, employees_id FROM health.employees_erole)
RETURNING *
;

--InstitutionAdress
WITH DistStreet AS (SELECT b.building_id, d.district_name, s.street_name  FROM building b INNER JOIN district d ON d.district_id=b.district_id INNER JOIN street s ON s.street_id=b.street_id)
INSERT INTO	health.institutionadress
(institution_id, building_id, institutionadress_description)
SELECT institution_id, building_id, institutionadress_description
FROM
	(SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('Specialist Hospital. Jozef Dietl')) AS institution_id, (SELECT building_id FROM DistStreet  WHERE upper(district_name) = upper('Debniki') AND upper(street_name) = upper('Sw. Anny Street') )AS building_id, '5 star' AS institutionadress_description
	UNION ALL 
	SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('John Paul II Hospital')), (SELECT building_id FROM DistStreet  WHERE upper(district_name) = upper('Krowodrza') AND upper(street_name) = upper('Szewska Street') ), '4 star'
	UNION ALL 
	SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('Szpital na Klinach')), (SELECT building_id FROM DistStreet  WHERE upper(district_name) = upper('Stare Miasto') AND upper(street_name) = upper('Karmelicka Street') ), '3 star'
	UNION ALL 
	SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('Military Clinical Hospital SPZOZ')), (SELECT building_id FROM DistStreet  WHERE upper(district_name) = upper('Grzegorzki') AND upper(street_name) = upper('Pijarska Street') ), '2 star'
	UNION ALL 
	SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('Eco-Lab Healthcare')), (SELECT building_id FROM DistStreet  WHERE upper(district_name) = upper('Czyzyny') AND upper(street_name) = upper('Szpitalna Street') ), '1 star'
	) AS new_institutionadress
	WHERE (new_institutionadress.institution_id, new_institutionadress.building_id) NOT IN (SELECT institution_id, building_id FROM health.institutionadress)
RETURNING *
;

--institution_employees
INSERT INTO health.institution_employees 
(institution_id, employees_id)
SELECT institution_id, employees_id
FROM 
	(SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('Specialist Hospital. Jozef Dietl')) AS institution_id, (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Reksio') AND trim(upper(employees_lname)) = upper('Oisker')) AS employees_id
	UNION ALL 
	SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('Specialist Hospital. Jozef Dietl')), (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Bolek') AND trim(upper(employees_lname)) = upper('Kelob'))
	UNION ALL
	SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('John Paul II Hospital')), (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Lolek') AND trim(upper(employees_lname)) = upper('Kolek'))
	UNION ALL
	SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('John Paul II Hospital')), (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Maya') AND trim(upper(employees_lname)) = upper('Ayam'))
	UNION ALL 
	SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('Szpital na Klinach')), (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Willy') AND trim(upper(employees_lname)) = upper('Ylliw'))
	UNION ALL 
	SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('Szpital na Klinach')), (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Binio') AND trim(upper(employees_lname)) = upper('Bill'))
	UNION ALL 
	SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('Military Clinical Hospital SPZOZ')), (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Miss') AND trim(upper(employees_lname)) = upper('Cassandra'))
	UNION ALL 
	SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('Military Clinical Hospital SPZOZ')), (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Doctor') AND trim(upper(employees_lname)) = upper('Skarpetka'))
	UNION ALL 
	SELECT (SELECT institution_id FROM institution WHERE upper(institution_name) = upper('Eco-Lab Healthcare')), (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Musico') AND trim(upper(employees_lname)) = upper('Daceco'))
	) AS new_institution_employees
WHERE (new_institution_employees.institution_id, new_institution_employees.employees_id) NOT IN (SELECT institution_id, employees_id FROM health.institution_employees )
RETURNING *
;

--Schedule_Confirmed
WITH scheduleID AS (SELECT s.schedule_id, i.institution_name, c.client_fname||c.client_lname AS fn_name, s.start_time  FROM schedule s JOIN institution i ON i.institution_id = s.institution_id JOIN client c ON c.client_id = s.client_id)
INSERT INTO health.schedule_confirmed
(schedule_id, employees_id, start_wtme, end_wtme)
SELECT schedule_id, employees_id, start_wtme, end_wtme
FROM
	(SELECT	(SELECT schedule_id FROM scheduleID WHERE institution_name = 'Specialist Hospital. Jozef Dietl' AND fn_name='DanielOlbrychski' AND  start_time like '01-01-2022 08:00') AS schedule_id, (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Reksio') AND trim(upper(employees_lname)) = upper('Oisker')) AS employees_id, timestamp '2022-01-01 08:00:00' AS Start_WTme, timestamp '2022-01-01 09:00:00' AS ENd_WTme 
	UNION ALL
	SELECT	(SELECT schedule_id FROM scheduleID WHERE institution_name = 'Specialist Hospital. Jozef Dietl' AND fn_name='JanuszGajos' AND  start_time like '01-01-2022 09:00'), (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Reksio') AND trim(upper(employees_lname)) = upper('Oisker')), timestamp '2022-01-01 09:00:00', timestamp '2022-01-01 10:00:00'
	UNION ALL
	SELECT	(SELECT schedule_id FROM scheduleID WHERE institution_name = 'Specialist Hospital. Jozef Dietl' AND fn_name='PiotrAdamczyk' AND  start_time like '01-01-2022 10:00'), (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Reksio') AND trim(upper(employees_lname)) = upper('Oisker')), timestamp '2022-01-01 10:00:00', timestamp '2022-01-01 11:00:00'
	UNION ALL
	SELECT	(SELECT schedule_id FROM scheduleID WHERE institution_name = 'Specialist Hospital. Jozef Dietl' AND fn_name='IzabellaMiko' AND  start_time like '01-01-2022 11:00'), (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Reksio') AND trim(upper(employees_lname)) = upper('Oisker')), timestamp '2022-01-01 11:00:00', timestamp '2022-01-01 12:00:00'
	UNION ALL
	SELECT	(SELECT schedule_id FROM scheduleID WHERE institution_name = 'Specialist Hospital. Jozef Dietl' AND fn_name='KrystynaJanda' AND  start_time like '01-01-2022 12:00'), (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Reksio') AND trim(upper(employees_lname)) = upper('Oisker')), timestamp '2022-01-01 12:00:00', timestamp '2022-01-01 13:00:00'
	UNION ALL
	SELECT	(SELECT schedule_id FROM scheduleID WHERE institution_name = 'Specialist Hospital. Jozef Dietl' AND fn_name='JanuszGajos' AND  start_time like '01-02-2022 09:00'), (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Reksio') AND trim(upper(employees_lname)) = upper('Oisker')), timestamp '2022-02-01 09:00:00', timestamp '2022-02-01 10:00:00'
	UNION ALL
	SELECT	(SELECT schedule_id FROM scheduleID WHERE institution_name = 'Specialist Hospital. Jozef Dietl' AND fn_name='PiotrAdamczyk' AND  start_time like '01-03-2022 10:00'), (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Bolek') AND trim(upper(employees_lname)) = upper('Kelob')), timestamp '2022-03-01 10:00:00', timestamp '2022-03-01 11:00:00'
	UNION ALL
	SELECT	(SELECT schedule_id FROM scheduleID WHERE institution_name = 'Specialist Hospital. Jozef Dietl' AND fn_name='IzabellaMiko' AND  start_time like '01-04-2022 11:00'), (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Bolek') AND trim(upper(employees_lname)) = upper('Kelob')), timestamp '2022-04-01 11:00:00', timestamp '2022-04-01 12:00:00'
	UNION ALL
	SELECT	(SELECT schedule_id FROM scheduleID WHERE institution_name = 'Specialist Hospital. Jozef Dietl' AND fn_name='KrystynaJanda' AND  start_time like '01-05-2022 12:00'), (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Bolek') AND trim(upper(employees_lname)) = upper('Kelob')), timestamp '2022-05-01 12:00:00', timestamp '2022-05-01 13:00:00'
	UNION ALL
	SELECT	(SELECT schedule_id FROM scheduleID WHERE institution_name = 'John Paul II Hospital' AND fn_name='JanuszGajos' AND  start_time like '02-02-2022 09:00'), (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Lolek') AND trim(upper(employees_lname)) = upper('Kolek')), timestamp '2022-02-02 09:00:00', timestamp '2022-02-02 10:00:00'
	UNION ALL
	SELECT	(SELECT schedule_id FROM scheduleID WHERE institution_name = 'Szpital na Klinach' AND fn_name='PiotrAdamczyk' AND  start_time like '03-03-2022 10:00'), (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Binio  ') AND trim(upper(employees_lname)) = upper('Bill')), timestamp '2022-03-03 10:00:00', timestamp '2022-03-03 11:00:00'
	UNION ALL
	SELECT	(SELECT schedule_id FROM scheduleID WHERE institution_name = 'Military Clinical Hospital SPZOZ' AND fn_name='IzabellaMiko' AND  start_time like '04-04-2022 11:00'), (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Doctor  ') AND trim(upper(employees_lname)) = upper('Skarpetka')), timestamp '2022-04-04 11:00:00', timestamp '2022-04-04 12:00:00'
	UNION ALL
	SELECT	(SELECT schedule_id FROM scheduleID WHERE institution_name = 'Eco-Lab Healthcare' AND fn_name='KrystynaJanda' AND  start_time like '05-05-2022 12:00'), (SELECT employees_id FROM employees WHERE trim(upper(employees_fname)) = upper('Musico  ') AND trim(upper(employees_lname)) = upper('Daceco')), timestamp '2022-05-05 12:00:00', timestamp '2022-05-05 13:00:00'
	) AS new_Schedule_Confirmed
	WHERE (new_Schedule_Confirmed.schedule_id, new_Schedule_Confirmed.employees_id) NOT IN (SELECT schedule_id, employees_id FROM health.schedule_confirmed)
RETURNING *
; 
