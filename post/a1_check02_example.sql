-- Make A1 dwh_xxx, stg_xxx schemas default for this session
SET search_path TO dwh_xxx, stg_xxx;

-- =======================================
-- Check [dim_servicetype.typename matches staging]
-- =======================================
WITH joined AS 
(
  SELECT d.tb_servicetype_id
	, d.typename AS dwh_typename
	, s.typename AS stg_typename
  FROM dim_servicetype d
  FULL OUTER JOIN tb_servicetype s ON d.tb_servicetype_id = s.id
)
, mismatch AS 
(
  SELECT COUNT(*) AS cnt
  FROM joined
  WHERE 1=1
	AND (dwh_typename IS NULL
		OR stg_typename IS NULL
		OR dwh_typename <> stg_typename)
)
SELECT cnt AS name_mismatches_or_missing
  , CASE WHEN cnt = 0 THEN 'OK' ELSE 'fail' END AS status_check
  , CURRENT_TIMESTAMP(0)::timestamp AS run_time
FROM mismatch


