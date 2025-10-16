SET search_path TO dwh_006, stg_006;

-- Check [dim_timeday spans staging min..max]
WITH stg_bounds AS (
  SELECT
    LEAST(
      (SELECT MIN(readat)     FROM stg_006.tb_readingevent),
      (SELECT MIN(servicedat) FROM stg_006.tb_serviceevent),
      (SELECT MIN(observedat) FROM stg_006.tb_weather),
      (SELECT MIN(start_date) FROM stg_006.tb_environmental_campaign)
    ) AS min_date,
    GREATEST(
      (SELECT MAX(readat)     FROM stg_006.tb_readingevent),
      (SELECT MAX(servicedat) FROM stg_006.tb_serviceevent),
      (SELECT MAX(observedat) FROM stg_006.tb_weather),
      (SELECT MAX(COALESCE(end_date, DATE '9999-12-31')) FROM stg_006.tb_environmental_campaign)
    ) AS max_date
),
dim_bounds AS (SELECT MIN(date_actual) AS dim_min, MAX(date_actual) AS dim_max FROM dim_timeday)
SELECT sb.min_date AS stg_min, db.dim_min, sb.max_date AS stg_max, db.dim_max,
       CASE WHEN db.dim_min <= sb.min_date AND db.dim_max >= sb.max_date THEN 'OK' ELSE 'fail' END AS status_check,
       CURRENT_TIMESTAMP(0)::timestamp AS run_time
FROM stg_bounds sb CROSS JOIN dim_bounds db;
