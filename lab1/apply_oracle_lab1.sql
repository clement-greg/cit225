-- ----------------------------------------------------------------------
-- Instructions:
-- ----------------------------------------------------------------------
-- Below you will want to call the 2 scripts
-- Run instructor provided setup scripts.
-- @@/home/student/Data/cit225/oracle/lib1/utility/cleanup_oracle.sql
-- @@/home/student/Data/cit225/oracle/lib1/create/create_oracle_store2.sql
-- The 2 scripts contain spooling commands
-- NOTICE the spooling command in this script. 
-- It starts after you run the 2 files. 
-- When you run this file you first connect to the Oracle database with this syntax:
--
-- sqlplus student/student
--
-- Then, you call this script with the following syntax:
--
-- sql> @apply_oracle_lab1.sql
--
-- ----------------------------------------------------------------------

-- Call the setup scripts.
-- Replace with the correct script names as the below are just place holders

@@/home/student/Data/cit225/oracle/lib1/utility/cleanup_oracle.sql
@@/home/student/Data/cit225/oracle/lib1/create/create_oracle_store2.sql

commit;

-- Start a log file
SPOOL apply_oracle_lab1_log.txt

-- Query the table names as defined in STEP 5
-- PUT YOUR SQL BELOW HERE FOR STEP 5

-- Close the log file
SPOOL OFF
