

-- Call library files.
@/home/student/Data/cit225/oracle/lab6/apply_oracle_lab6.sql

-- Open log file.
SPOOL apply_lab7_oracle.txt

-- Set the page size.
SET ECHO ON
SET PAGESIZE 999

-- ----------------------------------------------------------------------
--  Step #1 : Insert rows into COMMON_LOOKUP to support the PRICE table
-- ----------------------------------------------------------------------
SELECT  'Step #1' AS "Step Number" FROM dual;

INSERT INTO COMMON_LOOKUP VALUES
( common_lookup_s1.nextval
, 'YES'
, 'Yes'
, 1, SYSDATE, 1, SYSDATE
, 'PRICE'
, 'ACTIVE_FLAG'
, 'Y');

INSERT INTO COMMON_LOOKUP VALUES
( common_lookup_s1.nextval
, 'NO'
, 'No'
, 1, SYSDATE, 1, SYSDATE
, 'PRICE'
, 'ACTIVE_FLAG'
, 'N');

-- ----------------------------------------------------------------------
--  Verification #1: Verify the common_lookup contents. 
-- ----------------------------------------------------------------------
COLUMN common_lookup_table  FORMAT A20 HEADING "COMMON_LOOKUP_TABLE"
COLUMN common_lookup_column FORMAT A20 HEADING "COMMON_LOOKUP_COLUMN"
COLUMN common_lookup_type   FORMAT A20 HEADING "COMMON_LOOKUP_TYPE"
SELECT   common_lookup_table
,        common_lookup_column
,        common_lookup_type
FROM     common_lookup
WHERE    common_lookup_table = 'PRICE'
AND      common_lookup_column = 'ACTIVE_FLAG'
ORDER BY 1, 2, 3 DESC;

-- ----------------------------------------------------------------------
--  Step #2 : Insert new rows to support PRICE and RENTAL_ITEM table.
-- ----------------------------------------------------------------------
INSERT INTO COMMON_LOOKUP VALUES
( common_lookup_s1.nextval
, '1-DAY RENTAL'
, '1 Day Rental'
, 1, SYSDATE, 1, SYSDATE
, 'PRICE'
, 'PRICE_TYPE'
, '1');

INSERT INTO COMMON_LOOKUP VALUES
( common_lookup_s1.nextval
, '3-DAY RENTAL'
, '3 Day Rental'
, 1, SYSDATE, 1, SYSDATE
, 'PRICE'
, 'PRICE_TYPE'
, '3');

INSERT INTO COMMON_LOOKUP VALUES
( common_lookup_s1.nextval
, '5-DAY RENTAL'
, '5 Day Rental'
, 1, SYSDATE, 1, SYSDATE
, 'PRICE'
, 'PRICE_TYPE'
, '5');

INSERT INTO COMMON_LOOKUP VALUES
( common_lookup_s1.nextval
, '1-DAY RENTAL'
, '1 Day Rental'
, 1, SYSDATE, 1, SYSDATE
, 'RENTAL_ITEM'
, 'RENTAL_ITEM_TYPE'
, '1');

INSERT INTO COMMON_LOOKUP VALUES
( common_lookup_s1.nextval
, '3-DAY RENTAL'
, '3 Day Rental'
, 1, SYSDATE, 1, SYSDATE
, 'RENTAL_ITEM'
, 'RENTAL_ITEM_TYPE'
, '3');

INSERT INTO COMMON_LOOKUP VALUES
( common_lookup_s1.nextval
, '5-DAY RENTAL'
, '5 Day Rental'
, 1, SYSDATE, 1, SYSDATE
, 'RENTAL_ITEM'
, 'RENTAL_ITEM_TYPE'
, '5');

-- ----------------------------------------------------------------------
--  Verification #2: Verify the common_lookup contents. 
-- ----------------------------------------------------------------------
COLUMN common_lookup_table  FORMAT A20 HEADING "COMMON_LOOKUP_TABLE"
COLUMN common_lookup_column FORMAT A20 HEADING "COMMON_LOOKUP_COLUMN"
COLUMN common_lookup_type   FORMAT A20 HEADING "COMMON_LOOKUP_TYPE"
SELECT   common_lookup_table
,        common_lookup_column
,        common_lookup_type
FROM     common_lookup
WHERE    common_lookup_table IN ('PRICE','RENTAL_ITEM')
AND      common_lookup_column IN ('PRICE_TYPE','RENTAL_ITEM_TYPE')
ORDER BY 1, 3;

--Trent
-- ----------------------------------------------------------------------
--  Step #3a : Now obsolete based on instructions in blog
-- ----------------------------------------------------------------------

-- WE ARE NO LONGER DOING THE BELOW (REMOVED BY TRENT)
-- Using the /* to the next */  Comments out everything else between
-- ADD the rental_item_price column is now done in Lab 6
/*

ALTER TABLE rental_item
   ADD (rental_item_price  NUMBER);
*/

-- ----------------------------------------------------------------------
--  Step #3a NEW: Update the RENTAL_ITEM_TYPE value through a correlated subquery.
-- ----------------------------------------------------------------------

-- Update the RENTAL_ITEM_TYPE value through a correlated subquery.
UPDATE   rental_item ri
SET      rental_item_type =
           (SELECT   cl.common_lookup_id
            FROM     common_lookup cl
            WHERE    cl.common_lookup_code =
              (SELECT  r.return_date - r.check_out_date
               FROM    rental r
               WHERE   r.rental_id = ri.rental_id)
        AND cl.common_lookup_table = 'RENTAL_ITEM'
        AND cl.common_lookup_column = 'RENTAL_ITEM_TYPE');

-- ----------------------------------------------------------------------
--  Verification #3a: Verify the common_lookup structure. 
-- ----------------------------------------------------------------------

-- Query the RENTAL_ITEM table.
COLUMN table_name   FORMAT A14
COLUMN column_id    FORMAT 9999
COLUMN column_name  FORMAT A22
COLUMN data_type    FORMAT A12
SELECT   table_name
,        column_id
,        column_name
,        CASE
           WHEN nullable = 'N' THEN 'NOT NULL'
           ELSE ''
         END AS nullable
,        CASE
           WHEN data_type IN ('CHAR','VARCHAR2','NUMBER') THEN
             data_type||'('||data_length||')'
           ELSE
             data_type
         END AS data_type
FROM     user_tab_columns
WHERE    table_name = 'RENTAL_ITEM'
ORDER BY 2;   

-- Verify the count of rental items.
SELECT   row_count
,        col_count
FROM    (SELECT   COUNT(*) AS ROW_COUNT
         FROM     rental_item) rc CROSS JOIN
        (SELECT   COUNT(rental_item_type) AS col_count
         FROM     rental_item
         WHERE    rental_item_type IS NOT NULL) cc;

-- ----------------------------------------------------------------------
--  Step #3b: create the fk_rental_item_7
-- ----------------------------------------------------------------------

ALTER TABLE rental_item ADD CONSTRAINT fk_rental_item_7 FOREIGN KEY(rental_item_type)
  REFERENCES common_lookup(common_lookup_id);

-- ----------------------------------------------------------------------
--  Verification #3b: Verify the fk_rental_item_7 FOREIGN KEY. 
-- ----------------------------------------------------------------------

COLUMN table_name      FORMAT A12 HEADING "TABLE NAME"
COLUMN constraint_name FORMAT A18 HEADING "CONSTRAINT NAME"
COLUMN constraint_type FORMAT A12 HEADING "CONSTRAINT|TYPE"
COLUMN column_name     FORMAT A18 HEADING "COLUMN NAME"
SELECT   uc.table_name
,        uc.constraint_name
,        CASE
           WHEN uc.constraint_type = 'R' THEN
            'FOREIGN KEY'
         END AS constraint_type
,        ucc.column_name
FROM     user_constraints uc INNER JOIN user_cons_columns ucc
ON       uc.constraint_name = ucc.constraint_name
WHERE    uc.table_name = 'RENTAL_ITEM'
AND      ucc.column_name = 'RENTAL_ITEM_TYPE';

-- ----------------------------------------------------------------------
--  Step #3c: set NOT NULL on rental_item_type.
-- ----------------------------------------------------------------------

-- Alter the table to add a not null constraint.
ALTER TABLE rental_item MODIFY (rental_item_type NUMBER NOT NULL);

-- ----------------------------------------------------------------------
--  Verification #3c: Verify the NOT NULL on rental_item_type. 
-- ----------------------------------------------------------------------

-- Query the rental item to check for NOT NULL ON RENTAL_ITEM_TYPE.
COLUMN CONSTRAINT FORMAT A10
SELECT   TABLE_NAME
,        column_name
,        CASE
           WHEN NULLABLE = 'N' THEN 'NOT NULL'
           ELSE 'NULLABLE'
         END AS CONSTRAINT
FROM     user_tab_columns
WHERE    TABLE_NAME = 'RENTAL_ITEM'
AND      column_name = 'RENTAL_ITEM_TYPE';

-- ----------------------------------------------------------------------
--  Step #4 : Select List
-- ----------------------------------------------------------------------
COLUMN item_id     FORMAT 9999 HEADING "ITEM|ID"
COLUMN active_flag FORMAT A6   HEADING "ACTIVE|FLAG"
COLUMN price_type  FORMAT 9999 HEADING "PRICE|TYPE"
COLUMN price_desc  FORMAT A12  HEADING "PRICE DESC"
COLUMN start_date  FORMAT A10  HEADING "START|DATE"
COLUMN end_date    FORMAT A10  HEADING "END|DATE"
COLUMN amount      FORMAT 9999 HEADING "AMOUNT"
SELECT   i.item_id
,        af.active_flag
,        cl.common_lookup_id AS price_type
,        cl.common_lookup_type AS price_desc
,        CASE
           WHEN (TRUNC(SYSDATE) - i.release_date) <= 30 OR
                (TRUNC(SYSDATE) - i.release_date) >  30 AND af.active_flag = 'N' THEN
             i.release_date
           ELSE
             i.release_date + 31
         END AS start_date
,        CASE
           WHEN (TRUNC(SYSDATE) - i.release_date) > 30 AND af.active_flag = 'N' THEN
             i.release_date + 30
         END AS end_date
,        CASE
           WHEN (TRUNC(SYSDATE) - i.release_date) <= 30 THEN
             CASE
               WHEN dr.rental_days = 1 THEN 3
               WHEN dr.rental_days = 3 THEN 10
               WHEN dr.rental_days = 5 THEN 15
             END
           WHEN (TRUNC(SYSDATE) - i.release_date) > 30 AND af.active_flag = 'N' THEN
             CASE
               WHEN dr.rental_days = 1 THEN 3
               WHEN dr.rental_days = 3 THEN 10
               WHEN dr.rental_days = 5 THEN 15
             END
           ELSE
             CASE
               WHEN dr.rental_days = 1 THEN 1
               WHEN dr.rental_days = 3 THEN 3
               WHEN dr.rental_days = 5 THEN 5
             END
         END AS amount
FROM     item i CROSS JOIN
        (SELECT 'Y' AS active_flag FROM dual
         UNION ALL
         SELECT 'N' AS active_flag FROM dual) af CROSS JOIN
        (SELECT '1' AS rental_days FROM dual
         UNION ALL
         SELECT '3' AS rental_days FROM dual
         UNION ALL
         SELECT '5' AS rental_days FROM dual) dr INNER JOIN
         common_lookup cl ON dr.rental_days = SUBSTR(cl.common_lookup_type,1,1)
WHERE cl.common_lookup_table = 'PRICE'
AND cl.common_lookup_column = 'PRICE_TYPE'
AND NOT     (af.active_flag = 'N' AND (TRUNC(SYSDATE) - 30) < i.release_date)
ORDER BY 1, 2, 3;

spool off
