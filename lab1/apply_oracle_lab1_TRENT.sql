-- ----------------------------------------------------------------------
-- Instructions:
-- ----------------------------------------------------------------------
-- Below you will want to call the four scripts
-- Run instructor provided setup scripts.
-- @@/home/student/Data/cit225/oracle/lib1/utility/cleanup_oracle.sql
-- @@/home/student/Data/cit225/oracle/lib1/create/create_oracle_store2.sql
-- @@/home/student/Data/cit225/oracle/lib1/preseed/preseed_oracle_store.sql
-- @@/home/student/Data/cit225/oracle/lib1/seed/seeding.sql
-- The 4 scripts contain spooling commands
-- NOTICE the spooling command in this script. 
-- It start after you run the 4 files. 
-- When you run this file you first connect to the Oracle database with this syntax:
--
--   sqlplus student/student
--
-- Then, you call this script with the following syntax:
--
--   sql> @apply_oracle_lab1.sql
--
-- ----------------------------------------------------------------------

-- Call the setup scripts.
@@/home/student/Data/cit225/oracle/lib1/utility/cleanup_oracle.sql
@@/home/student/Data/cit225/oracle/lib1/create/create_oracle_store2.sql
@@/home/student/Data/cit225/oracle/lib1/preseed/preseed_oracle_store.sql
@@/home/student/Data/cit225/oracle/lib1/seed/seeding.sql

commit;

-- Start a log file
SPOOL apply_oracle_lab1.txt


-- Query the table names as defined in STEP 5
-- PUT YOUR SQL BELOW HERE FOR STEP 5.
SELECT   table_name
  FROM   user_tables
 WHERE   table_name NOT IN ('EMP','DEPT')
   AND   NOT  table_name LIKE 'DEMO%'
   AND   NOT  table_name LIKE 'APEX%'
 ORDER   BY table_name;

-- Close the log file
SPOOL OFF
