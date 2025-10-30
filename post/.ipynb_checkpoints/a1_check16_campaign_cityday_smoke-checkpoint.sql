SET search_path TO dwh_006, stg_006;

-- Check [active campaign city-days have at least some fact activity (smoke test)]
WITH active_city_days AS (
  SELECT DISTINCT cc.city_id, d.date_actual AS d
  FROM stg_006.tb_campaign_city cc
  JOIN stg_006.tb_environmental_campaign c ON c.campaign_id = cc.campaign_id
  JOIN dwh_006.dim_timeday d ON d.date_actual BETWEEN c.start_date AND COALESCE(c.end_date, DATE '9999-12-31')
),
reading_city_days AS (
  SELECT DISTINCT ci.id AS city_id, dtd.date_actual AS d
  FROM ft_reading_daily frd
  JOIN dwh_006.dim_device dd   ON dd.device_key = frd.device_key
  JOIN stg_006.tb_city ci      ON ci.cityname = dd.city_name
  JOIN stg_006.tb_country co   ON co.countryname = dd.country_name AND co.id = ci.countryid
  JOIN dwh_006.dim_timeday dtd ON dtd.time_day_key = frd.time_day_key
),
missing AS (
  SELECT acd.city_id, acd.d
  FROM active_city_days acd
  LEFT JOIN reading_city_days rcd ON rcd.city_id = acd.city_id AND rcd.d = acd.d
  WHERE rcd.city_id IS NULL
)
SELECT COUNT(*) AS active_citydays_without_readings,
       CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'fail' END AS status_check,
       CURRENT_TIMESTAMP(0)::timestamp AS run_time
FROM missing;
