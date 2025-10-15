-- -------------------------------
-- 1) Assignment 1: create/reset stg_xxx schema per group
-- -------------------------------
DROP SCHEMA IF EXISTS stg_xxx CASCADE;
CREATE SCHEMA stg_xxx AUTHORIZATION grp_xxx;