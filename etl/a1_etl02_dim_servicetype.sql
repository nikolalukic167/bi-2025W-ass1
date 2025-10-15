-- Make A1 dwh_xxx, stg_xxx schemas the default for this session
SET search_path TO dwh_xxx, stg_xxx;

-- =======================================
-- Load [table name]
-- =======================================

-- Step 1: Truncate target table
TRUNCATE TABLE dim_servicetype RESTART IDENTITY CASCADE;

INSERT INTO dim_servicetype (tb_servicetype_id, typename)
SELECT DISTINCT st.id, st.typename
FROM tb_servicetype st
ORDER BY st.id;




