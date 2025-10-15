-- Make A1 dwh_xxx, stg_xxx schemas the default for this session
SET search_path TO dwh_xxx, stg_xxx;

-- =======================================
-- Load [dim_technician_role_scd2]
-- =======================================

-- Step 1: Truncate target table
TRUNCATE TABLE dim_technician_role_scd2 RESTART IDENTITY CASCADE;

-- Step 2: materialize role history rows as SCD2 versions
WITH role_history AS 
(
  SELECT e.badgenumber
    , r.rolelevel
    , r.category AS category
    , r.rolename
    , e.validfrom AS effective_from
    , COALESCE(e.validto, DATE '9999-12-31') AS effective_to
    , (e.validto IS NULL) AS is_current
  FROM tb_employee e
  INNER JOIN tb_role r ON r.id = e.roleid
)
INSERT INTO dim_technician_role_scd2 (badgenumber, rolelevel, category, rolename, effective_from, effective_to, is_current)
SELECT badgenumber, rolelevel, category, rolename, effective_from, effective_to, is_current
FROM role_history
ORDER BY badgenumber, effective_from;





