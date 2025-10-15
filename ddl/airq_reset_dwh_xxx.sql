-- -------------------------------
-- 1) Assignment 1: create/reset dwh_xxx schema per group
-- -------------------------------
DROP SCHEMA IF EXISTS dwh_xxx CASCADE;
CREATE SCHEMA dwh_xxx AUTHORIZATION grp_xxx;