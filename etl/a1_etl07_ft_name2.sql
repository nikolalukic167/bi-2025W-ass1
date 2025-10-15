-- Make A1 dwh_xxx, stg_xxx schemas the default for this session
SET search_path TO dwh_xxx, stg_xxx;

-- =======================================
-- Load ft_name2 (seed, FK-safe)
-- =======================================

-- 1) Truncate target
TRUNCATE TABLE ft_name2 RESTART IDENTITY CASCADE;

-- 2) Insert a small, valid seed set
WITH seeds AS (
  SELECT
      dtd.id                       AS day_id
    , dp.sk_parameter              AS sk_parameter
    , tr.sk_technician_role        AS sk_technician_role
    , ROW_NUMBER() OVER ()         AS rn
  FROM (SELECT id FROM dim_timeday ORDER BY id LIMIT 3)              dtd
  CROSS JOIN (SELECT sk_parameter FROM dim_parameter ORDER BY 1 LIMIT 2) dp
  CROSS JOIN (SELECT sk_technician_role
              FROM dim_technician_role_scd2
              WHERE is_current = TRUE
              ORDER BY 1 LIMIT 2) tr
)
INSERT INTO ft_name2 (id, day_id, sk_parameter, sk_technician_role)
SELECT rn, day_id, sk_parameter, sk_technician_role
FROM seeds
ORDER BY rn
LIMIT 5;

-- 3) Refresh stats (optional but recommended)
ANALYZE ft_name2;



