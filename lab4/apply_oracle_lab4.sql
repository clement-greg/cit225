-- ------------------------------------------------------------------
-- LAB 4 BROTHER TRENT PETERSON
--  This seeds data in the video store model.
--   - Inserts the data in the rental_lab table for 5 records and
--     then inserts 9 dependent records in a non-sequential 
--     order.
--   - A non-sequential order requires that you use subqueries
--     to discover the foreign key values for the inserts.
-- ------------------------------------------------------------------
-- Run the prior lab script.
@/home/student/Data/cit225/oracle/lab3/apply_oracle_lab3.sql
@/home/student/Data/cit225/oracle/lib1/seed/seeding.sql
 
-- insert calls to other SQL script files here, in the order that they appear in the seeding.sql script ...
@@group_account1_lab.sql
@@group_account2_lab.sql
@@group_account3_lab.sql
@@item_inserts_lab.sql
@@create_insert_contacts_lab.sql
@@individual_accounts_lab.sql
@@update_members_lab.sql
@@rental_inserts_lab.sql
@@create_view_lab.sql
--
-- ISSUE A COMMIT TO BE SURE ALL DATA SO FAR HAS BEEN COMMITED TO THE DB
commit;
-- ISSUE A SPOOL OFF JUST TO BE SURE IT IS NOT STILL SPOOLING
spool off
--
-- 
-- START YOUR SPOOL FILE HERE FOR LAB 4 
SPOOL apply_oracle_seeding_lab_log.txt

-- ------------------------------------------------------------------
--   Query to verify seven rows of chained inserts to the five
--   dependent tables.
-- ------------------------------------------------------------------
--    1. MEMBER_LAB
--    2. CONTACT_LAB
--    3. ADDRESS_LAB
--    4. STREET_ADDRESS_LAB
--    5. TELEPHONE_LAB
-- ------------------------------------------------------------------

COL member_id       FORMAT 9999 HEADING "Acct|ID #"
COL account_number  FORMAT A10  HEADING "Account|Number"
COL full_name       FORMAT A16  HEADING "Name|(Last, First MI)"
COL city            FORMAT A12  HEADING "City"
COL state_province  FORMAT A10  HEADING "State"
COL telephone       FORMAT A18  HEADING "Telephone"
SELECT   m.member_id
,        m.account_number
,        c.last_name || ', ' || c.first_name
||       CASE
           WHEN c.middle_name IS NOT NULL THEN ' ' || SUBSTR(c.middle_name,1,1)
         END AS full_name
,        a.city
,        a.state_province
,        t.country_code || '-(' || t.area_code || ') ' || t.telephone_number AS telephone
FROM     member_lab m INNER JOIN contact_lab c ON m.member_id = c.member_id INNER JOIN
         address_lab a ON c.contact_id = a.contact_id INNER JOIN
         street_address_lab sa ON a.address_id = sa.address_id INNER JOIN
         telephone_lab t ON c.contact_id = t.contact_id AND a.address_id = t.address_id
WHERE    last_name IN ('Sweeney','Vizquel','Winn');

-- ------------------------------------------------------------------
--  Display the 21 inserts into the item table.
-- ------------------------------------------------------------------
SET PAGESIZE 99
COL item_id                FORMAT 9999  HEADING "Item|ID #"
COL common_lookup_meaning  FORMAT A20  HEADING "Item Description"
COL item_title             FORMAT A30  HEADING "Item Title"
COL item_release_date      FORMAT A11  HEADING "Item|Release|Date"
SELECT   i.item_id
,        cl.common_lookup_meaning
,        i.item_title
,        i.item_release_date
FROM     item_lab i INNER JOIN common_lookup_lab cl ON i.item_type = cl.common_lookup_id;

-- ------------------------------------------------------------------
--   Query to verify five individual rows of chained inserts through
--   a procedure into the five dependent tables.
-- ------------------------------------------------------------------
COL account_number  FORMAT A10  HEADING "Account|Number"
COL full_name       FORMAT A20  HEADING "Name|(Last, First MI)"
COL city            FORMAT A12  HEADING "City"
COL state_province  FORMAT A10  HEADING "State"
COL telephone       FORMAT A18  HEADING "Telephone"
SELECT   m.account_number
,        c.last_name || ', ' || c.first_name
||       CASE
           WHEN c.middle_name IS NOT NULL THEN ' ' || SUBSTR(c.middle_name,1,1)
         END AS full_name
,        a.city
,        a.state_province
,        t.country_code || '-(' || t.area_code || ') ' || t.telephone_number AS telephone
FROM     member_lab m INNER JOIN contact_lab c ON m.member_id = c.member_id INNER JOIN
         address_lab a ON c.contact_id = a.contact_id INNER JOIN
         street_address_lab sa ON a.address_id = sa.address_id INNER JOIN
         telephone_lab t ON c.contact_id = t.contact_id AND a.address_id = t.address_id
WHERE    m.member_type = (SELECT common_lookup_id
                          FROM   common_lookup_lab
                          WHERE  common_lookup_context = 'MEMBER_LAB'
                          AND    common_lookup_type = 'INDIVIDUAL');

-- ------------------------------------------------------------------
--   Query to verify nine rental agreements, some with one and some
--   with more than one rental item.
-- ------------------------------------------------------------------
COL member_id       FORMAT 9999 HEADING "Member|ID #"
COL account_number  FORMAT A10  HEADING "Account|Number"
COL full_name       FORMAT A20  HEADING "Name|(Last, First MI)"
COL rental_id       FORMAT 9999 HEADING "Rent|ID #"
COL rental_item_id  FORMAT 9999 HEADING "Rent|Item|ID #"
COL item_title      FORMAT A26  HEADING "Item Title"
SELECT   m.member_id
,        m.account_number
,        c.last_name || ', ' || c.first_name
||       CASE
           WHEN c.middle_name IS NOT NULL THEN ' ' || SUBSTR(c.middle_name,1,1)
         END AS full_name
,        r.rental_id
,        ri.rental_item_id
,        i.item_title
FROM     member_lab m INNER JOIN contact_lab c ON m.member_id = c.member_id INNER JOIN
         rental_lab r ON c.contact_id = r.customer_id INNER JOIN
         rental_item_lab ri ON r.rental_id = ri.rental_id INNER JOIN
         item_lab i ON ri.item_id = i.item_id
ORDER BY r.rental_id;

SPOOL OFF
