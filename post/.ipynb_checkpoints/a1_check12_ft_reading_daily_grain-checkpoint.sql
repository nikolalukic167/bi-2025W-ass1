SET search_path TO dwh_006, stg_006;

-- Check [ft_reading_daily grain uniqueness: {time_day_key, device_key, parameter_key, reading_mode_key}]
WITH dupes AS (
  SELECT time_day_key, device_key, parameter_key, reading_mode_key, COUNT(*) AS c
  FROM ft_reading_daily
  GROUP BY 1,2,3,4
  HAVING COUNT(*) > 1
)
SELECT COUNT(*) AS duplicate_groups,
       CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'fail' END AS status_check,
       CURRENT_TIMESTAMP(0)::timestamp AS run_time
FROM dupes;
