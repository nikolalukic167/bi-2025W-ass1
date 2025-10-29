SET search_path TO dwh_006, stg_006;

WITH dwh_st AS 
(
  SELECT '006' AS group_num
       , COUNT(service_type_key) AS dwh_count
  FROM dim_service_type
),
stg_st AS 
(
  SELECT '006' AS group_num
       , COUNT(id) AS stg_count
  FROM tb_servicetype
)
SELECT
    d.dwh_count
  , s.stg_count
  , CASE WHEN d.dwh_count = s.stg_count THEN 'OK' ELSE 'fail' END AS status_check
  , CURRENT_TIMESTAMP(0)::timestamp AS run_time
FROM dwh_st d
JOIN stg_st s USING (group_num);
