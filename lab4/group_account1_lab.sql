-- ------------------------------------------------------------------
--  Program Name:   group_account1.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  30-Jan-2018
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ------------------------------------------------------------------
-- This seeds data in the video store model.
-- ------------------------------------------------------------------
-- ------------------------------------------------------------------
--  This seeds rows in a dependency chain, including the following
--  tables:
--
--    1. MEMBER
--    2. CONTACT
--    3. ADDRESS
--    4. STREET_ADDRESS
--    5. TELEPHONE
--
--  It creates primary keys with the .NEXTVAL pseudo columns and
--  foreign keys with the .CURRVAL pseudo columns.
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
--  Open log file.
-- ------------------------------------------------------------------
SPOOL group_account1_lab.txt

-- ------------------------------------------------------------------
--  Insert record set #1, with one entry in the member table and
--  two entries in contact table.
-- ------------------------------------------------------------------
INSERT INTO member_lab
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
( member_s1.nextval                               -- member_id
, NULL                                            -- member_type
,'B293-71445'                                     -- account_number
,'1111-2222-3333-4444'                            -- credit_card_number
,(SELECT   common_lookup_id
  FROM     common_lookup_lab
  WHERE    common_lookup_context = 'MEMBER_LAB'
  AND      common_lookup_type = 'DISCOVER_CARD')  -- credit_card_type
,(SELECT   system_user_id
  FROM     system_user_lab
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
, SYSDATE                                         -- creation_date
,(SELECT   system_user_id
  FROM     system_user_lab
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
, SYSDATE                                         -- last_update_date
);

-- ------------------------------------------------------------------
--  Insert first contact in a group account user.
-- ------------------------------------------------------------------
INSERT INTO contact_lab
( contact_id
, member_id
, contact_type
, first_name
, last_name
, created_by
, creation_date
, last_updated_by
, last_update_date )
VALUES
( contact_s1.nextval                              -- contact_id
, member_s1.currval                               -- member_id
,(SELECT   common_lookup_id
  FROM     common_lookup_lab
  WHERE    common_lookup_context = 'CONTACT_LAB'
  AND      common_lookup_type = 'CUSTOMER')       -- contact_type
,'Randi'                                          -- first_name
,'Winn'                                           -- last_name
,(SELECT   system_user_id
  FROM     system_user_lab
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
, SYSDATE                                         -- creation_date
,(SELECT   system_user_id
  FROM     system_user_lab
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
, SYSDATE                                         -- last_update_date
);

INSERT INTO address_lab
( address_id
, contact_id
, address_type
, city
, state_province
, postal_code
, created_by
, creation_date
, last_updated_by
, last_update_date )
VALUES
( address_s1.nextval                              -- address_id
, contact_s1.currval                              -- contact_id
,(SELECT   common_lookup_id
  FROM     common_lookup_lab
  WHERE    common_lookup_type = 'HOME')           -- address_type
,'San Jose'                                       -- city
,'CA'                                             -- state_province
,'95192'                                          -- postal_code
,(SELECT   system_user_id
  FROM     system_user_lab
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
, SYSDATE                                         -- creation_date
,(SELECT   system_user_id
  FROM     system_user_lab
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
, SYSDATE                                         -- last_update_date
);

INSERT INTO street_address_lab
( street_address_id
, address_id
, street_address
, created_by
, creation_date
, last_updated_by
, last_update_date )
 VALUES
( street_address_s1.nextval                       -- street_address_id
, address_s1.currval                              -- address_id
,'10 El Camino Real'                              -- street_address
,(SELECT   system_user_id
  FROM     system_user_lab
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
, SYSDATE                                         -- creation_date
,(SELECT   system_user_id
  FROM     system_user_lab
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
, SYSDATE                                         -- last_update_date
);

INSERT INTO telephone_lab
( telephone_id
, contact_id
, address_id
, telephone_type
, country_code
, area_code
, telephone_number
, created_by
, creation_date
, last_updated_by
, last_update_date )
 VALUES
( telephone_s1.nextval                            -- telephone_id
, address_s1.currval                              -- address_id
, contact_s1.currval                              -- contact_id
,(SELECT   common_lookup_id
  FROM     common_lookup_lab
  WHERE    common_lookup_context = 'MULTIPLE'
  AND      common_lookup_type = 'HOME')           -- telephone_type
,'001'                                            -- country_code
,'408'                                            -- area_code
,'111-1111'                                       -- telephone_number
,(SELECT   system_user_id
  FROM     system_user_lab
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
, SYSDATE                                         -- creation_date
,(SELECT   system_user_id
  FROM     system_user_lab
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
, SYSDATE                                         -- last_update_date
);

-- ------------------------------------------------------------------
--  Insert second contact in a group account user.
-- ------------------------------------------------------------------
INSERT INTO contact_lab
( contact_id
, member_id
, contact_type
, first_name
, last_name
, created_by
, creation_date
, last_updated_by
, last_update_date )
VALUES
( contact_s1.nextval                              -- contact_id
, member_s1.currval                               -- member_id
,(SELECT   common_lookup_id
  FROM     common_lookup_lab
  WHERE    common_lookup_context = 'CONTACT_LAB'
  AND      common_lookup_type = 'CUSTOMER')       -- contact_type
,'Brian'                                          -- first_name
,'Winn'                                           -- last_name
,(SELECT   system_user_id
  FROM     system_user_lab
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
, SYSDATE                                         -- creation_date
,(SELECT   system_user_id
  FROM     system_user_lab
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
, SYSDATE                                         -- last_update_date
);


INSERT INTO address_lab
( address_id
, contact_id
, address_type
, city
, state_province
, postal_code
, created_by
, creation_date
, last_updated_by
, last_update_date )
VALUES
( address_s1.nextval                              -- address_id
, contact_s1.currval                              -- contact_id
,(SELECT   common_lookup_id
  FROM     common_lookup_lab
  WHERE    common_lookup_type = 'HOME')           -- address_type
,'San Jose'                                       -- city
,'CA'                                             -- state_province
,'95192'                                          -- postal_code
,(SELECT   system_user_id
  FROM     system_user_lab
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
, SYSDATE                                         -- creation_date
,(SELECT   system_user_id
  FROM     system_user_lab
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
, SYSDATE                                         -- last_update_date
);

INSERT INTO street_address_lab
( street_address_id
, address_id
, street_address
, created_by
, creation_date
, last_updated_by
, last_update_date )
 VALUES
( street_address_s1.nextval                       -- street_address_id
, address_s1.currval                              -- address_id
,'10 El Camino Real'                              -- street_address
,(SELECT   system_user_id
  FROM     system_user_lab
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
, SYSDATE                                         -- creation_date
,(SELECT   system_user_id
  FROM     system_user_lab
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
, SYSDATE                                         -- last_update_date
);

INSERT INTO telephone_lab
( telephone_id
, contact_id
, address_id
, telephone_type
, country_code
, area_code
, telephone_number
, created_by
, creation_date
, last_updated_by
, last_update_date )
 VALUES
( telephone_s1.nextval                            -- telephone_id
, address_s1.currval                              -- address_id
, contact_s1.currval                              -- contact_id
,(SELECT   common_lookup_id
  FROM     common_lookup_lab
  WHERE    common_lookup_context = 'MULTIPLE'
  AND      common_lookup_type = 'HOME')           -- telephone_type
,'001'                                            -- country_code
,'408'                                            -- area_code
,'111-1111'                                       -- telephone_number
,(SELECT   system_user_id
  FROM     system_user_lab
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
, SYSDATE                                         -- creation_date
,(SELECT   system_user_id
  FROM     system_user_lab
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
, SYSDATE                                         -- last_update_date
);

COL account_number  FORMAT A10  HEADING "Account|Number"
COL full_name       FORMAT A16  HEADING "Name|(Last, First MI)"
COL city            FORMAT A12  HEADING "City"
COL state_province  FORMAT A10  HEADING "State"
COL telephone       FORMAT A18  HEADING "Telephone"
SELECT   m.account_number
,        c.last_name || ', ' || c.first_name
||       CASE
           WHEN c.middle_name IS NOT NULL THEN ' ' || c.middle_name
         END AS full_name
,        a.city
,        a.state_province
,        t.country_code || '-(' || t.area_code || ') ' || t.telephone_number AS telephone
FROM     member m INNER JOIN contact c ON m.member_id = c.member_id INNER JOIN
         address a ON c.contact_id = a.contact_id INNER JOIN
         street_address sa ON a.address_id = sa.address_id INNER JOIN
         telephone t ON c.contact_id = t.contact_id AND a.address_id = t.address_id
WHERE    c.last_name = 'Winn';

-- ------------------------------------------------------------------
--  Close log file.
-- ------------------------------------------------------------------
SPOOL OFF

