SET search_path TO dwh_006, stg_006;

TRUNCATE TABLE ft_reading_daily RESTART IDENTITY CASCADE;

WITH base AS (
  SELECT
      re.sensordevid
    , re.paramid
    , re.readingmodeid
    , re.readat::date                              AS d
    , COUNT(*)                                     AS cnt_readings
    , SUM(COALESCE(re.datavolumekb,0)) * 1024::bigint AS sum_data_volume_bytes
    , AVG(re.dataquality)::numeric(5,2)            AS avg_data_quality
    , AVG(re.recordedvalue)::numeric(18,6)         AS avg_value
  FROM stg_006.tb_readingevent re
  GROUP BY re.sensordevid, re.paramid, re.readingmodeid, re.readat::date
),
alert_rank AS (
  SELECT id,
         CASE UPPER(alertname)
           WHEN 'YELLOW'  THEN 1
           WHEN 'ORANGE'  THEN 2
           WHEN 'RED'     THEN 3
           WHEN 'CRIMSON' THEN 4
           ELSE 0
         END AS lvl
  FROM stg_006.tb_alert
),
event_level AS (
  SELECT re.id AS readingevent_id, MAX(ar.lvl) AS max_lvl
  FROM stg_006.tb_readingevent re
  JOIN stg_006.tb_paramalert pa ON pa.paramid = re.paramid
  JOIN alert_rank ar            ON ar.id = pa.alertid
  WHERE re.recordedvalue >= pa.threshold
  GROUP BY re.id
),
daily_exceed AS (
  SELECT
      re.sensordevid
    , re.paramid
    , re.readingmodeid
    , re.readat::date AS d
    , SUM(CASE WHEN el.max_lvl = 1 THEN 1 ELSE 0 END) AS cnt_yellow
    , SUM(CASE WHEN el.max_lvl = 2 THEN 1 ELSE 0 END) AS cnt_orange
    , SUM(CASE WHEN el.max_lvl = 3 THEN 1 ELSE 0 END) AS cnt_red
    , SUM(CASE WHEN el.max_lvl = 4 THEN 1 ELSE 0 END) AS cnt_crimson
  FROM stg_006.tb_readingevent re
  LEFT JOIN event_level el ON el.readingevent_id = re.id
  GROUP BY re.sensordevid, re.paramid, re.readingmodeid, re.readat::date
),
device_city AS (
  SELECT sd.id AS sensordevid, ci.id AS city_id
  FROM stg_006.tb_sensordevice sd
  JOIN stg_006.tb_city ci ON ci.id = sd.cityid
),
impact_rank AS (
  SELECT 'Low'::text AS impact_level, 1 AS rnk UNION ALL
  SELECT 'Medium', 2 UNION ALL
  SELECT 'High', 3
),
active_campaign AS (
  SELECT
      b.sensordevid
    , b.paramid
    , b.readingmodeid
    , b.d
    , (SELECT c.campaign_id
       FROM stg_006.tb_campaign_city cc
       JOIN stg_006.tb_environmental_campaign c ON c.campaign_id = cc.campaign_id
       JOIN impact_rank ir ON ir.impact_level = cc.impact_level
       WHERE cc.city_id = dc.city_id
         AND c.start_date <= b.d
         AND (c.end_date IS NULL OR c.end_date >= b.d)
       ORDER BY ir.rnk DESC, cc.effectiveness_score DESC NULLS LAST, c.campaign_id ASC
       LIMIT 1) AS campaign_id
  FROM base b
  JOIN device_city dc ON dc.sensordevid = b.sensordevid
),
keys AS (
  SELECT
      b.*
    , de.device_key
    , dp.parameter_key
    , ds.sensor_type_key
    , drm.reading_mode_key
    , dt.time_day_key
    , ac.campaign_id
  FROM base b
  JOIN dwh_006.dim_device        de  ON de.device_id_nk        = b.sensordevid
  JOIN dwh_006.dim_parameter     dp  ON dp.parameter_id_nk     = b.paramid
  JOIN stg_006.tb_sensordevice   sd  ON sd.id                  = b.sensordevid
  JOIN dwh_006.dim_sensor_type   ds  ON ds.sensor_type_id_nk   = sd.sensortypeid
  JOIN dwh_006.dim_reading_mode  drm ON drm.reading_mode_id_nk = b.readingmodeid
  JOIN dwh_006.dim_timeday       dt  ON dt.date_actual         = b.d
  LEFT JOIN active_campaign      ac  ON ac.sensordevid = b.sensordevid
                                     AND ac.paramid     = b.paramid
                                     AND ac.readingmodeid = b.readingmodeid
                                     AND ac.d          = b.d
)
INSERT INTO ft_reading_daily (
  time_day_key, device_key, parameter_key, sensor_type_key, reading_mode_key, campaign_key,
  cnt_readings, sum_data_volume_bytes, avg_data_quality, avg_value,
  cnt_exceed_yellow, cnt_exceed_orange, cnt_exceed_red, cnt_exceed_crimson
)
SELECT
    k.time_day_key
  , k.device_key
  , k.parameter_key
  , k.sensor_type_key
  , k.reading_mode_key
  , dc_dim.campaign_key
  , k.cnt_readings
  , k.sum_data_volume_bytes
  , k.avg_data_quality
  , k.avg_value
  , COALESCE(dx.cnt_yellow,  0)
  , COALESCE(dx.cnt_orange,  0)
  , COALESCE(dx.cnt_red,     0)
  , COALESCE(dx.cnt_crimson, 0)
FROM keys k
LEFT JOIN daily_exceed dx
  ON dx.sensordevid   = k.sensordevid
 AND dx.paramid       = k.paramid
 AND dx.readingmodeid = k.readingmodeid
 AND dx.d             = (SELECT date_actual FROM dwh_006.dim_timeday WHERE time_day_key = k.time_day_key)
LEFT JOIN dwh_006.dim_campaign dc_dim
  ON dc_dim.campaign_id_nk = k.campaign_id;
