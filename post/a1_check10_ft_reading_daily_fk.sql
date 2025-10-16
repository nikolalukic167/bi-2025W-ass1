SET search_path TO dwh_006, stg_006;

-- Check [ft_reading_daily FKs exist]
WITH probs AS (
  SELECT
    SUM(CASE WHEN frd.time_day_key     NOT IN (SELECT time_day_key     FROM dim_timeday)      THEN 1 ELSE 0 END) AS miss_time,
    SUM(CASE WHEN frd.device_key       NOT IN (SELECT device_key       FROM dim_device)       THEN 1 ELSE 0 END) AS miss_device,
    SUM(CASE WHEN frd.parameter_key    NOT IN (SELECT parameter_key    FROM dim_parameter)    THEN 1 ELSE 0 END) AS miss_param,
    SUM(CASE WHEN frd.sensor_type_key  NOT IN (SELECT sensor_type_key  FROM dim_sensor_type)  THEN 1 ELSE 0 END) AS miss_sensor,
    SUM(CASE WHEN frd.reading_mode_key NOT IN (SELECT reading_mode_key FROM dim_reading_mode) THEN 1 ELSE 0 END) AS miss_mode,
    SUM(CASE WHEN frd.campaign_key IS NOT NULL
              AND frd.campaign_key NOT IN (SELECT campaign_key FROM dim_campaign)
             THEN 1 ELSE 0 END) AS miss_campaign
  FROM ft_reading_daily frd
)
SELECT miss_time, miss_device, miss_param, miss_sensor, miss_mode, miss_campaign,
       CASE WHEN miss_time=0 AND miss_device=0 AND miss_param=0 AND miss_sensor=0 AND miss_mode=0 AND miss_campaign=0
            THEN 'OK' ELSE 'fail' END AS status_check,
       CURRENT_TIMESTAMP(0)::timestamp AS run_time
FROM probs;
