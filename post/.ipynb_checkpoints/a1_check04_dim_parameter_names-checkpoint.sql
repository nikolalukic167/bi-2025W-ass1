SET search_path TO dwh_006, stg_006;

-- Check [dim_parameter.parameter_name matches tb_param.paramname]
WITH joined AS (
  SELECT d.parameter_id_nk, d.parameter_name, s.paramname
  FROM dwh_006.dim_parameter d
  FULL JOIN stg_006.tb_param s ON d.parameter_id_nk = s.id
),
mismatch AS (SELECT COUNT(*) AS cnt FROM joined WHERE parameter_name IS DISTINCT FROM paramname)
SELECT cnt AS name_mismatches_or_missing,
       CASE WHEN cnt = 0 THEN 'OK' ELSE 'fail' END AS status_check,
       CURRENT_TIMESTAMP(0)::timestamp AS run_time
FROM mismatch;
