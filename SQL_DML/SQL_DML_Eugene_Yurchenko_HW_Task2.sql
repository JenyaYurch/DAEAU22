-- TASK 2
-- 2.1 Create table ‘table_to_delete’ and fill it with the following query:

CREATE TABLE table_to_delete AS
SELECT 'veeeeeeery_long_string' || x AS col
FROM generate_series(1,(10^7)::int) x; -- generate_series() creates 10^7 rows of sequential numbers from 1 to 10000000 (10^7);

-- 2.2 Lookup how much space this table consumes with the following query:

SELECT *, pg_size_pretty(total_bytes) AS total,
pg_size_pretty(index_bytes) AS INDEX,
pg_size_pretty(toast_bytes) AS toast,
pg_size_pretty(table_bytes) AS TABLE
FROM ( SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS table_bytes
FROM (SELECT c.oid,nspname AS table_schema,
relname AS TABLE_NAME,
c.reltuples AS row_estimate,
pg_total_relation_size(c.oid) AS total_bytes,
pg_indexes_size(c.oid) AS index_bytes,
pg_total_relation_size(reltoastrelid) AS toast_bytes
FROM pg_class c
LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE relkind = 'r'
) a
) a
WHERE table_name LIKE '%table_to_delete%';
-- Result:
-- oid  |table_schema|table_name     |row_estimate|total_bytes|index_bytes|toast_bytes|table_bytes|total |index  |toast     |table |
--------+------------+---------------+------------+-----------+-----------+-----------+-----------+------+-------+----------+------+
-- 32801|public      |table_to_delete|    10000000|  602365952|          0|       8192|  602357760|574 MB|0 bytes|8192 bytes|574 MB|


-- 2.3 Issue the following DELETE operation on ‘table_to_delete’:
DELETE FROM table_to_delete
WHERE REPLACE(col, 'veeeeeeery_long_string','')::int % 3 = 0; -- removes 1/3 of all ROWS

-- a. Note how much time it takes to perform this DELETE statement;
-- TIme DELETE 1/3 of all ROWS = 37.941s

-- b. Lookup how much space this table consumes after previous DELETE;
-- Before DELETE 575 MB / After DELETE 383 MB / Difference 192 MB or 33%

--c. Perform the following command to observe server output (VACUUM results)):
VACUUM FULL VERBOSE table_to_delete; 
-- Result:
-- vacuuming "public.table_to_delete"
--"table_to_delete": found 0 removable, 6666667 nonremovable row versions in 73530 pages 

-- d. Check space consumption of the table once again and make conclusions;
-- Result:
-- oid  |table_schema|table_name     |row_estimate|total_bytes|index_bytes|toast_bytes|table_bytes|total |index  |toast     |table |
--------+------------+---------------+------------+-----------+-----------+-----------+-----------+------+-------+----------+------+
-- 32783|public      |table_to_delete|   6666667.0|  401580032|          0|       8192|  401571840|383 MB|0 bytes|8192 bytes|383 MB|
-- WHEN we deleted 1/3 of all ROWS - we got 1/3 FREE space
-- Creation of the table takes 43.182s. It is near the same time to delet it - 37.941s


-- 2.4. Issue the following TRUNCATE operation:
TRUNCATE table_to_delete;

-- a. Note how much time it takes to perform this TRUNCATE statement. 
-- TRUNCATE statement time = 20ms

-- b. Compare with previous results and make conclusion.
-- Time DELETE 1/3 of all ROWS = 37.941s
-- TRUNCATE statement time = 20ms
-- it is faster ~200 times

-- c. Check space consumption of the table once again and make conclusions;
--oid  |table_schema|table_name     |row_estimate|total_bytes|index_bytes|toast_bytes|table_bytes|total     |index  |toast     |table  |
-------+------------+---------------+------------+-----------+-----------+-----------+-----------+----------+-------+----------+-------+
--32793|public      |table_to_delete|        -1.0|       8192|          0|       8192|          0|8192 bytes|0 bytes|8192 bytes|0 bytes|

-- table is empty. The Sise of the table 8192 bytes


--2.5. Hand over your investigation's results to your trainer. The results must include:

-- Creation of the table takes 43.182s
-- The total table has 1M rows and total sise = 574 MB
-- The time for deliting 1/3 of all ROWS = 37.941s
-- After DELETED 1/3 of all ROWS total sise = 383 MB 
-- TRUNCATE statement time = 20ms
-- The DELETE statement removes rows one at a time and records an entry in the transaction log
-- TRUNCATE TABLE removes the data and records only the page deallocations in the transaction log.
-- TRUNCATE more faster than DELETED
-- When we delet or update tables - tuples are not physically removed from their table
-- and we use VACUUM for clear/ set free data
-- This is a useful command for routine maintenance scripts
-- VACUUM FULL - slowly, because it can set free more space. And lock the table. FULL vacuum tqake copy of table befor complitle delete old copy.
-- this is operation requires extra disk space
-- after DELETE 1/3 rows I can see the rows are fewer now, but the table size has not changed
-- after  VACUUM FULL i can see that we get 192 MB free space 


