SET search_path TO dwh_006, stg_006;

TRUNCATE TABLE dim_timeday RESTART IDENTITY CASCADE;

WITH bounds AS (
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
series AS (
  SELECT generate_series(min_date, max_date, INTERVAL '1 day')::date AS d
  FROM bounds
)
INSERT INTO dim_timeday (
  time_day_key, date_actual, day_of_week, day_name, is_weekend,
  week_of_year, month, month_name, quarter, year
)
SELECT
  CAST(to_char(d, 'YYYYMMDD') AS INTEGER) AS time_day_key,
  d                                     AS date_actual,
  EXTRACT(ISODOW FROM d)::smallint       AS day_of_week,
  TO_CHAR(d, 'FMDay')                    AS day_name,
  (EXTRACT(ISODOW FROM d) IN (6,7))      AS is_weekend,
  EXTRACT(WEEK FROM d)::smallint         AS week_of_year,
  EXTRACT(MONTH FROM d)::smallint        AS month,
  TO_CHAR(d, 'FMMonth')                  AS month_name,
  EXTRACT(QUARTER FROM d)::smallint      AS quarter,
  EXTRACT(YEAR FROM d)::smallint         AS year
FROM series
ORDER BY d;
