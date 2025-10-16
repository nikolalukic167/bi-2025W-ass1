SET search_path TO dwh_006, stg_006;

-- Check [dim_campaign count matches tb_environmental_campaign]
WITH dwh_ct AS (SELECT COUNT(*) AS c FROM dim_campaign),
     stg_ct AS (SELECT COUNT(*) AS c FROM tb_environmental_campaign)
SELECT dwh_ct.c AS dwh_count, stg_ct.c AS stg_count,
       CASE WHEN dwh_ct.c = stg_ct.c THEN 'OK' ELSE 'fail' END AS status_check,
       CURRENT_TIMESTAMP(0)::timestamp AS run_time
FROM dwh_ct, stg_ct;
