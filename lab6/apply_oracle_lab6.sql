-- ------------------------------------------------------------------
-- Instructions: LAB 6
-- ------------------------------------------------------------------
-- The two scripts contain spooling commands, which is why there
-- isn't a spooling command in this script. When you run this file
-- you first connect to the Oracle database with this syntax:
--
--   sqlplus student/student@xe
--
-- Then, you call this script with the following syntax:
--
--   sql> @apply_oracle_lab6.sql
-- ------------------------------------------------------------------
-- This seeds data in the video store model. It requires that you run
-- the create_oracle_store.sql script.
-- ------------------------------------------------------------------

-- Call Previous Lab.
@/home/student/Data/cit225/oracle/lab5/apply_oracle_lab5.sql

-- THE BELOW WILL REMOVE THE LINE NUMBERS SO IT DOESN'T CAUSE ISSES IN THE FEEDBACK
-- SOMETIME THE FEEDBACK IN THE SPOOL FILE HAS LINE NUMBERS IN IT THAT MAKES
-- IT UNREADABLE AS TO HOW MANY ROWS WERE INSERTED, UPDATED, etc...
set sqlnumber off

-- Open log file and Start your Step 1 from Here.  Remember to COMMIT and spool off a the very end of the file.
SPOOL apply_lab6_oracle.txt

-- Set the page size.
SET ECHO ON
SET PAGESIZE 999

-- ----------------------------------------------------------------------
--  Step #1 : Add two columns to the RENTAL_ITEM table.
-- ----------------------------------------------------------------------
SELECT  'Step #1' AS "Step Number" FROM dual;

-- ----------------------------------------------------------------------
--  Objective #1: Add the RENTAL_ITEM_PRICE and RENTAL_ITEM_TYPE columns 
--                to the RENTAL_ITEM table. Both columns should use a
--                NUMBER data type in Oracle, and an int unsigned data
--                type.
-- ----------------------------------------------------------------------
ALTER TABLE rental_item
  ADD (rental_item_type   NUMBER)
  ADD (rental_item_price  NUMBER);

-- SHOULD WE ADD A FK CONSTRAINT???

-- ----------------------------------------------------------------------
--  Verification #1: Verify the table structure. 
-- ----------------------------------------------------------------------
SET NULL ''
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


-- ----------------------------------------------------------------------
--  Step #2 : Create the PRICE table.
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
--  Objective #1: Conditionally drop a PRICE table before creating a
--                PRICE table and PRICE_S1 sequence.
-- ----------------------------------------------------------------------

-- Conditionally drop PRICE table and sequence.
BEGIN
  FOR i IN (SELECT null
            FROM   user_tables
            WHERE  table_name = 'PRICE') LOOP
    EXECUTE IMMEDIATE 'DROP TABLE PRICE CASCADE CONSTRAINTS';
  END LOOP;
  FOR i IN (SELECT null
            FROM   user_sequences
            WHERE  sequence_name = 'PRICE_S1') LOOP
    EXECUTE IMMEDIATE 'DROP SEQUENCE PRICE_S1';
  END LOOP;
END;
/

-- Create PRICE table.
CREATE TABLE price
( price_id              NUMBER
, item_id               NUMBER        CONSTRAINT nn_price_1 NOT NULL
, price_type            NUMBER
, active_flag           VARCHAR2(20)  CONSTRAINT nn_price_2 NOT NULL
, start_date            DATE          CONSTRAINT nn_price_3 NOT NULL
, end_date              DATE
, amount                NUMBER        CONSTRAINT nn_price_4 NOT NULL
, created_by            NUMBER        CONSTRAINT nn_price_5 NOT NULL
, creation_date         DATE          CONSTRAINT nn_price_6 NOT NULL
, last_updated_by       NUMBER        CONSTRAINT nn_price_7 NOT NULL
, last_updated_date     DATE          CONSTRAINT nn_price_8 NOT NULL
, CONSTRAINT pk_price_1 PRIMARY KEY(price_id)
, CONSTRAINT fk_price_1 FOREIGN KEY(item_id)
  REFERENCES item(item_id)
, CONSTRAINT yn_price   CHECK(active_flag IN ('Y','N'))
, CONSTRAINT fk_price_2 FOREIGN KEY(price_type)
  REFERENCES common_lookup(common_lookup_id)
, CONSTRAINT fk_price_3 FOREIGN KEY(created_by)
  REFERENCES system_user(system_user_id)  
, CONSTRAINT fk_price_4 FOREIGN KEY(last_updated_by)
  REFERENCES system_user(system_user_id)  
); 

-- Create sequence. 
CREATE SEQUENCE price_s1 START WITH 1001;

-- ----------------------------------------------------------------------
--  Objective #2: Verify the table structure. 
-- ----------------------------------------------------------------------
SET NULL ''
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
WHERE    table_name = 'PRICE'
ORDER BY 2;   
-- ----------------------------------------------------------------------
--  Objective #3: Verify the table constraints. 
-- ----------------------------------------------------------------------
COLUMN constraint_name   FORMAT A16
COLUMN search_condition  FORMAT A30
SELECT   uc.constraint_name
,        uc.search_condition
FROM     user_constraints uc INNER JOIN user_cons_columns ucc
ON       uc.table_name = ucc.table_name
AND      uc.constraint_name = ucc.constraint_name
WHERE    uc.table_name = UPPER('price')
AND      ucc.column_name = UPPER('active_flag')
AND      uc.constraint_name = UPPER('yn_price')
AND      uc.constraint_type = 'C';

-- ----------------------------------------------------------------------
--  Step #3 : Insert new data into the model.
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
--  Objective #3: Rename ITEM_RELEASE_DATE column to RELEASE_DATE column,
--                insert three new DVD releases into the ITEM table,
--                insert three new rows in the MEMBER, CONTACT, ADDRESS,
--                STREET_ADDRESS, and TELEPHONE tables, and insert
--                three new RENTAL and RENTAL_ITEM table rows.
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
--  Step #3a: Rename ITEM_RELEASE_DATE Column.
-- ----------------------------------------------------------------------
ALTER TABLE item RENAME COLUMN item_release_date TO release_date;

-- ----------------------------------------------------------------------
--  Verification #3a: Verify the column name change. 
-- ----------------------------------------------------------------------
SET NULL ''
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
,        data_type
||      '('||data_length||')' AS data_type
FROM     user_tab_columns
WHERE    TABLE_NAME = 'ITEM'
ORDER BY 2;

-- ----------------------------------------------------------------------
--  Step #3b: Insert three rows in the ITEM table.
-- ----------------------------------------------------------------------
INSERT INTO item VALUES
( item_s1.NEXTVAL
, '786936161878'
, (SELECT common_lookup_id 
   FROM common_lookup 
   WHERE common_lookup_type = 'DVD_WIDE_SCREEN')
, 'Tron'
, '20th Anniversary Collectors Edition'
, 'PG'
, TRUNC(SYSDATE) - 15
, 1, SYSDATE, 1, SYSDATE);

INSERT INTO item VALUES
( item_s1.NEXTVAL
, '4101-10422'
, (SELECT common_lookup_id 
   FROM common_lookup 
   WHERE common_lookup_type = 'DVD_WIDE_SCREEN')
, 'Taken' , '', 'PG-13'
, TRUNC(SYSDATE) - 15
, 1, SYSDATE, 1, SYSDATE);

INSERT INTO item VALUES
( item_s1.NEXTVAL
, '5918-1040'
, (SELECT common_lookup_id 
   FROM common_lookup 
   WHERE common_lookup_type = 'DVD_WIDE_SCREEN')
, 'Finding Faith in Christ'
, 'LDS'
, 'G'
, TRUNC(SYSDATE) - 15
, 1, SYSDATE, 1, SYSDATE);

-- ----------------------------------------------------------------------
--  Verification #3b: Verify the column name change. 
-- ----------------------------------------------------------------------
COLUMN item_title FORMAT A14
COLUMN today FORMAT A10
COLUMN release_date FORMAT A10 HEADING "RELEASE|DATE"
SELECT   i.item_title
,        SYSDATE AS today
,        i.release_date
FROM     item i
WHERE   (SYSDATE - i.release_date) < 31;

-- ----------------------------------------------------------------------
--  Step #3c: Insert three new rows in the MEMBER, CONTACT, ADDRESS,
--            STREET_ADDRESS, and TELEPHONE tables.
-- ----------------------------------------------------------------------

-- Insert "Harry Potter" records.
INSERT INTO MEMBER
( member_id
 , member_type
 , account_number
 , credit_card_number
 , credit_card_type
 , created_by
 , creation_date
 , last_updated_by
 , last_update_date )
 VALUES
 ( member_s1.NEXTVAL
 ,(SELECT   common_lookup_id
   FROM     common_lookup
   WHERE    common_lookup_context = 'MEMBER'
   AND      common_lookup_type = 'GROUP')
 , 'US00011'
 , '6011 0000 0000 0078'
 , (SELECT common_lookup_id
    FROM   common_lookup
    WHERE  common_lookup_type = 'DISCOVER_CARD')
 , 1, SYSDATE, 1, SYSDATE);

INSERT INTO contact VALUES
( contact_s1.nextval
, member_s1.currval
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'CONTACT'
  AND      common_lookup_type = 'CUSTOMER')
,'Harry','','Potter'
, 1, SYSDATE, 1, SYSDATE);

INSERT INTO address VALUES
( address_s1.nextval
, contact_s1.currval
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_type = 'HOME')
,'Provo','Utah','84604'
, 1, SYSDATE, 1, SYSDATE);

INSERT INTO street_address VALUES
( street_address_s1.nextval
, address_s1.currval
,'900 E, 300 N'
, 1, SYSDATE, 1, SYSDATE);

INSERT INTO telephone VALUES
( telephone_s1.nextval
, address_s1.currval
, contact_s1.currval
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_type = 'HOME')
,'USA','801','333-3333'
, 1, SYSDATE, 1, SYSDATE);

-- Insert "Ginny Potter" records.
INSERT INTO contact VALUES
( contact_s1.nextval
, member_s1.currval
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'CONTACT'
  AND      common_lookup_type = 'CUSTOMER')
,'Ginny','','Potter'
, 1, SYSDATE, 1, SYSDATE);

INSERT INTO address VALUES
( address_s1.nextval
, contact_s1.currval
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_type = 'HOME')
,'Provo','Utah','84604'
, 1, SYSDATE, 1, SYSDATE);

INSERT INTO street_address VALUES
( street_address_s1.nextval
, address_s1.currval
,'900 E, 300 N'
, 1, SYSDATE, 1, SYSDATE);

INSERT INTO telephone VALUES
( telephone_s1.nextval
, address_s1.currval
, contact_s1.currval
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_type = 'HOME')
,'USA','801','333-3333'
, 1, SYSDATE, 1, SYSDATE);

-- Insert "Lily Luna Potter" records.
INSERT INTO contact VALUES
( contact_s1.nextval
, member_s1.currval
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'CONTACT'
  AND      common_lookup_type = 'CUSTOMER')
,'Lily','Luna','Potter'
, 1, SYSDATE, 1, SYSDATE);

INSERT INTO address VALUES
( address_s1.nextval
, contact_s1.currval
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_type = 'HOME')
,'Provo','Utah','84604'
, 1, SYSDATE, 1, SYSDATE);

INSERT INTO street_address VALUES
( street_address_s1.nextval
, address_s1.currval
,'900 E, 300 N'
, 1, SYSDATE, 1, SYSDATE);

INSERT INTO telephone VALUES
( telephone_s1.nextval
, address_s1.currval
, contact_s1.currval
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_type = 'HOME')
,'USA','801','333-3333'
, 1, SYSDATE, 1, SYSDATE);

-- ----------------------------------------------------------------------
--  Verification #3c: Verify the three new CONTACTS and their related
--                    information set. 
-- ----------------------------------------------------------------------
SET NULL ''
COLUMN full_name FORMAT A20
COLUMN city      FORMAT A10
COLUMN state     FORMAT A10
SELECT   c.last_name || ', ' || c.first_name AS full_name
,        a.city
,        a.state_province AS state
FROM     member m INNER JOIN contact c
ON       m.member_id = c.member_id INNER JOIN address a
ON       c.contact_id = a.contact_id INNER JOIN street_address sa
ON       a.address_id = sa.address_id INNER JOIN telephone t
ON       c.contact_id = t.contact_id
WHERE    c.last_name = 'Potter';

-- ----------------------------------------------------------------------
--  Step #3d: Insert three new RENTAL and RENTAL_ITEM table rows..
-- ----------------------------------------------------------------------

-- Insert first record set.
INSERT INTO rental VALUES
( rental_s1.nextval
,(SELECT   contact_id
  FROM     contact
  WHERE    last_name = 'Potter'
  AND      first_name = 'Harry')
, TRUNC(SYSDATE), TRUNC(SYSDATE) + 1
, 1, SYSDATE, 1, SYSDATE);

INSERT INTO rental_item
( rental_item_id
, rental_id
, item_id
, created_by
, creation_date
, last_updated_by
, last_update_date)
VALUES
( rental_item_s1.nextval
, rental_s1.currval
,(SELECT   d.item_id
  FROM     item d
  ,        common_lookup cl
  WHERE    d.item_title = 'Tron'
  AND      d.item_subtitle = '20th Anniversary Collectors Edition'
  AND      d.item_type = cl.common_lookup_id
  AND      cl.common_lookup_type = 'DVD_WIDE_SCREEN')
, 1, SYSDATE, 1, SYSDATE);

INSERT INTO rental_item
( rental_item_id
, rental_id
, item_id
, created_by
, creation_date
, last_updated_by
, last_update_date)
VALUES
( rental_item_s1.nextval
, rental_s1.currval
,(SELECT   d.item_id
  FROM     item d
  ,        common_lookup cl
  WHERE    d.item_title = 'Tron'
  AND      d.item_subtitle = '20th Anniversary Collectors Edition'
  AND      d.item_type = cl.common_lookup_id
  AND      cl.common_lookup_type = 'DVD_WIDE_SCREEN')
, 1, SYSDATE, 1, SYSDATE);

-- Insert third record set.
INSERT INTO rental VALUES
( rental_s1.nextval
,(SELECT   contact_id
  FROM     contact
  WHERE    last_name = 'Potter'
  AND      first_name = 'Ginny')
, TRUNC(SYSDATE), TRUNC(SYSDATE) + 3
, 1, SYSDATE, 1, SYSDATE);

INSERT INTO rental_item
( rental_item_id
, rental_id
, item_id
, created_by
, creation_date
, last_updated_by
, last_update_date)
VALUES
( rental_item_s1.nextval
, rental_s1.currval
, (SELECT   d.item_id
    FROM     item d
    ,        common_lookup cl
    WHERE    d.item_title = 'Taken'
    AND      d.item_type = cl.common_lookup_id
    AND      cl.common_lookup_type = 'DVD_WIDE_SCREEN')
, 1, SYSDATE, 1, SYSDATE);

INSERT INTO rental VALUES
( rental_s1.nextval
,(SELECT   contact_id
  FROM     contact
  WHERE    last_name = 'Potter'
  AND      first_name = 'Lily'
  AND      middle_name = 'Luna')
, TRUNC(SYSDATE), TRUNC(SYSDATE) + 5
, 1, SYSDATE, 1, SYSDATE);

INSERT INTO rental_item
( rental_item_id
, rental_id
, item_id
, created_by
, creation_date
, last_updated_by
, last_update_date)
VALUES
( rental_item_s1.nextval
, rental_s1.currval
,(SELECT   d.item_id
  FROM     item d
  ,        common_lookup cl
  WHERE    d.item_title = 'Finding Faith in Christ'
  AND      d.item_subtitle = 'LDS'
  AND      d.item_type = cl.common_lookup_id
  AND      cl.common_lookup_type = 'DVD_WIDE_SCREEN')
, 1, SYSDATE, 1, SYSDATE);

-- ----------------------------------------------------------------------
--  Verification #3d: Verify the three new CONTACTS and their related
--                    information set. 
-- ----------------------------------------------------------------------
COLUMN full_name   FORMAT A18
COLUMN rental_id   FORMAT 9999
COLUMN rental_days FORMAT A14
COLUMN rentals     FORMAT 9999
COLUMN items       FORMAT 9999
SELECT   c.last_name||', '||c.first_name||' '||c.middle_name AS full_name
,        r.rental_id
,       (r.return_date - r.check_out_date) || '-DAY RENTAL' AS rental_days
,        COUNT(DISTINCT r.rental_id) AS rentals
,        COUNT(ri.rental_item_id) AS items
FROM     rental r INNER JOIN rental_item ri
ON       r.rental_id = ri.rental_id INNER JOIN contact c
ON       r.customer_id = c.contact_id
WHERE   (SYSDATE - r.check_out_date) < 15
AND      c.last_name = 'Potter'
GROUP BY c.last_name||', '||c.first_name||' '||c.middle_name
,        r.rental_id
,       (r.return_date - r.check_out_date) || '-DAY RENTAL'
ORDER BY 2;

-- ----------------------------------------------------------------------
--  Objective #4: Modify the design of the COMMON_LOOKUP table, insert
--                new data into the model, and update old non-compliant
--                design data in the model.
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
--  Step #4a: Drop Indexes.
-- ----------------------------------------------------------------------
DROP INDEX common_lookup_n1;
DROP INDEX common_lookup_u2;

-- ----------------------------------------------------------------------
--  Verification #4a: Verify the unique indexes are dropped. 
-- ----------------------------------------------------------------------
COLUMN table_name FORMAT A14
COLUMN index_name FORMAT A20
SELECT   table_name
,        index_name
FROM     user_indexes
WHERE    table_name = 'COMMON_LOOKUP';

-- ----------------------------------------------------------------------
--  Step #4b: Add three new columns.
-- ----------------------------------------------------------------------
ALTER TABLE common_lookup
  ADD (common_lookup_table  VARCHAR2(30))
  ADD (common_lookup_column VARCHAR2(30))
  ADD (common_lookup_code   VARCHAR2(30));

-- ----------------------------------------------------------------------
--  Verification #4b: Verify the unique indexes are dropped. 
-- ----------------------------------------------------------------------
SET NULL ''
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
WHERE    table_name = 'COMMON_LOOKUP'
ORDER BY 2;

-- ----------------------------------------------------------------------
--  Step #4c: Migrate data subject to re-engineered COMMON_LOOKUP table.
-- ----------------------------------------------------------------------
/*
BELOW IS ONE WAY TO DO IT BUT NOT THE BEST WAY TO DO IT
HOWEVER IT MAY MAKE MORE SENSE TO STUDENTS

UPDATE   common_lookup
SET      common_lookup_table = 'SYSTEM_USER'
,        common_lookup_column = 'SYSTEM_user_TYPE'
WHERE    common_lookup_context = 'SYSTEM_USER';
  
UPDATE   common_lookup
SET      common_lookup_table = 'CONTACT'
,        common_lookup_column = 'CONTACT_TYPE'
WHERE    common_lookup_context = 'CONTACT'; 

UPDATE   common_lookup
SET      common_lookup_table = 'MEMBER'
,        common_lookup_column = 'MEMBER_type'
WHERE    common_lookup_context = 'MEMBER'; 

UPDATE   common_lookup
SET      common_lookup_table = 'ADDRESS'
,        common_lookup_column = 'ADDRESS_TYPE'
WHERE    common_lookup_context = 'MULTIPLE';

UPDATE   common_lookup
SET      common_lookup_table = 'ITEM'
,        common_lookup_column = 'ITEM_TYPE'
WHERE    common_lookup_context = 'ITEM';

etc....
*/

PROMPT THIS IS THE BETTER WAY TO DO IT

UPDATE   common_lookup
SET      common_lookup_table = common_lookup_context
,        common_lookup_column = common_lookup_context||'_TYPE'
WHERE    common_lookup_context in (select table_name from user_tables);

--

UPDATE   common_lookup
SET      common_lookup_table = 'ADDRESS'
,        common_lookup_column = 'ADDRESS_TYPE'
WHERE    common_lookup_context = 'MULTIPLE';


-- Insert new rows.
-- THIS IS A BETTER WAY TO DO IT THAN WHAT I SHOW AFTER THIS
INSERT INTO common_lookup 
( common_lookup_id
, common_lookup_context
, common_lookup_table
, common_lookup_column
, common_lookup_type
, common_lookup_meaning
, created_by
, creation_date
, last_updated_by
, last_update_date )
VALUES
(common_lookup_s1.nextval
,'XYX'
,'TELEPHONE'
,'TELEPHONE_TYPE'
,'HOME'
,'Home'
,1
,SYSDATE,
1,
SYSDATE
);

INSERT INTO common_lookup 
( common_lookup_id
, common_lookup_context
, common_lookup_table
, common_lookup_column
, common_lookup_type
, common_lookup_meaning
, created_by
, creation_date
, last_updated_by
, last_update_date )
VALUES
(common_lookup_s1.nextval
,'XYX'
,'TELEPHONE'
,'TELEPHONE_TYPE'
,'WORK'
,'Work'
,1
,SYSDATE,
1,
SYSDATE
);

/*  OLD WAY BUT NOT AS DESCRIPTIVE DONT RUN THIS ANYMORE (COMMENTED OUT)
INSERT INTO common_lookup VALUES
( common_lookup_s1.nextval,'x','HOME','Home', 1, SYSDATE, 1, SYSDATE,'TELEPHONE','TELEPHONE_TYPE','');

INSERT INTO common_lookup VALUES
( common_lookup_s1.nextval,'x','WORK','Work', 1, SYSDATE, 1, SYSDATE,'TELEPHONE','TELEPHONE_TYPE','');
*/
SQL> desc common_lookup
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 COMMON_LOOKUP_ID                          NOT NULL NUMBER
 COMMON_LOOKUP_TYPE                        NOT NULL VARCHAR2(30)
 COMMON_LOOKUP_MEANING                     NOT NULL VARCHAR2(30)
 CREATED_BY                                NOT NULL NUMBER
 CREATION_DATE                             NOT NULL DATE
 LAST_UPDATED_BY                           NOT NULL NUMBER
 LAST_UPDATE_DATE                          NOT NULL DATE
 COMMON_LOOKUP_TABLE                       NOT NULL VARCHAR2(30)
 COMMON_LOOKUP_COLUMN                      NOT NULL VARCHAR2(30)
 COMMON_LOOKUP_CODE                                 VARCHAR2(30)


-- Fix obsoleted FOREIGN KEY values.
UPDATE   telephone
SET      telephone_type = 
         (SELECT common_lookup_id
          FROM common_lookup
          WHERE common_lookup_table = 'TELEPHONE'
          AND common_lookup_type = 'HOME')
WHERE    telephone_type = 
         (SELECT common_lookup_id
          FROM common_lookup
          WHERE common_lookup_table = 'ADDRESS'
          AND common_lookup_type = 'HOME');

UPDATE   telephone
SET      telephone_type = 
         (SELECT common_lookup_id
          FROM common_lookup
          WHERE common_lookup_table = 'TELEPHONE'
          AND common_lookup_type = 'WORK')
WHERE    telephone_type = 
         (SELECT common_lookup_id
          FROM common_lookup
          WHERE common_lookup_table = 'ADDRESS'
          AND common_lookup_type = 'WORK');

-- ----------------------------------------------------------------------
--  Verification #4c: Migrate data subject to re-engineered 
--                    COMMON_LOOKUP table.
-- ----------------------------------------------------------------------
SET NULL ''
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
WHERE    table_name = 'COMMON_LOOKUP'
ORDER BY 2;   

COLUMN common_lookup_table  FORMAT A20
COLUMN common_lookup_column FORMAT A20
COLUMN common_lookup_type   FORMAT A20
SELECT   common_lookup_table
,        common_lookup_column
,        common_lookup_type
FROM     common_lookup
ORDER BY 1, 2, 3;

COLUMN common_lookup_table  FORMAT A14 HEADING "Common|Lookup Table"
COLUMN common_lookup_column FORMAT A14 HEADING "Common|Lookup Column"
COLUMN common_lookup_type   FORMAT A8  HEADING "Common|Lookup|Type"
COLUMN count_dependent      FORMAT 999 HEADING "Count of|Foreign|Keys"
COLUMN count_lookup         FORMAT 999 HEADING "Count of|Primary|Keys"
SELECT   cl.common_lookup_table
,        cl.common_lookup_column
,        cl.common_lookup_type
,        COUNT(a.address_id) AS count_dependent
,        COUNT(DISTINCT cl.common_lookup_table) AS count_lookup
FROM     address a RIGHT JOIN common_lookup cl
ON       a.address_type = cl.common_lookup_id
WHERE    cl.common_lookup_table = 'ADDRESS'
AND      cl.common_lookup_column = 'ADDRESS_TYPE'
AND      cl.common_lookup_type IN ('HOME','WORK')
GROUP BY cl.common_lookup_table
,        cl.common_lookup_column
,        cl.common_lookup_type
UNION
SELECT   cl.common_lookup_table
,        cl.common_lookup_column
,        cl.common_lookup_type
,        COUNT(t.telephone_id) AS count_dependent
,        COUNT(DISTINCT cl.common_lookup_table) AS count_lookup
FROM     telephone t RIGHT JOIN common_lookup cl
ON       t.telephone_type = cl.common_lookup_id
WHERE    cl.common_lookup_table = 'TELEPHONE'
AND      cl.common_lookup_column = 'TELEPHONE_TYPE'
AND      cl.common_lookup_type IN ('HOME','WORK')
GROUP BY cl.common_lookup_table
,        cl.common_lookup_column
,        cl.common_lookup_type;

-- ----------------------------------------------------------------------
--  Step #4e: Constrain the COMMON_LOOKUP table.
-- ----------------------------------------------------------------------

-- Drop the extraneous column and add NOT NULL constraints to the new
-- columns.
ALTER TABLE common_lookup DROP COLUMN common_lookup_context;
ALTER TABLE common_lookup MODIFY common_lookup_table  VARCHAR2(30) constraint nn_clookup_8 NOT NULL;
ALTER TABLE common_lookup MODIFY common_lookup_column VARCHAR2(30) constraint nn_clookup_9 NOT NULL;

--  Verify new table structure.
SET NULL ''
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
WHERE    table_name = 'COMMON_LOOKUP'
ORDER BY 2;   

-- Add unique constraint on the natural key of the COMMON_LOOKUP table.
CREATE UNIQUE INDEX common_lookup_u2
  ON common_lookup(common_lookup_table, common_lookup_column, common_lookup_type);

--  Verify the new natural key index.
COLUMN table_name FORMAT A14
COLUMN index_name FORMAT A20
SELECT   table_name
,        index_name
FROM     user_indexes
WHERE    table_name = 'COMMON_LOOKUP';

commit;

SPOOL OFF
