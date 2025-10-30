SET search_path TO dwh_006, stg_006;

-- Check [dim_sensor_type count matches tb_sensortype]
WITH dwh_ct AS (SELECT COUNT(*) AS c FROM dim_sensor_type),
     stg_ct AS (SELECT COUNT(*) AS c FROM tb_sensortype)
SELECT dwh_ct.c AS dwh_count, stg_ct.c AS stg_count,
       CASE WHEN dwh_ct.c = stg_ct.c THEN 'OK' ELSE 'fail' END AS status_check,
       CURRENT_TIMESTAMP(0)::timestamp AS run_time
FROM dwh_ct, stg_ct;
