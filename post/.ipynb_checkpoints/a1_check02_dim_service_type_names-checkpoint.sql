-- Make A1 dwh_006, stg_006 schemas default for this session
SET search_path TO dwh_006, stg_006;

-- =======================================
-- Check [dim_service_type.service_type_name matches staging tb_servicetype.typename]
-- =======================================
WITH joined AS 
(
  SELECT d.service_type_id_nk
       , d.service_type_name AS dwh_typename
       , s.typename          AS stg_typename
  FROM dwh_006.dim_service_type d
  FULL OUTER JOIN stg_006.tb_servicetype s
    ON d.service_type_id_nk = s.id
)
, mismatch AS 
(
  SELECT COUNT(*) AS cnt
  FROM joined
  WHERE dwh_typename IS NULL
     OR stg_typename IS NULL
     OR dwh_typename <> stg_typename
)
SELECT cnt AS name_mismatches_or_missing
     , CASE WHEN cnt = 0 THEN 'OK' ELSE 'fail' END AS status_check
     , CURRENT_TIMESTAMP(0)::timestamp AS run_time
FROM mismatch;
