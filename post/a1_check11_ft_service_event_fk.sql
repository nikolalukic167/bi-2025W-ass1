SET search_path TO dwh_006, stg_006;

-- Check [ft_service_event FKs exist]
WITH probs AS (
  SELECT
    SUM(CASE WHEN f.time_day_key        NOT IN (SELECT time_day_key        FROM dim_timeday)         THEN 1 ELSE 0 END) AS miss_time,
    SUM(CASE WHEN f.device_key          NOT IN (SELECT device_key          FROM dim_device)          THEN 1 ELSE 0 END) AS miss_device,
    SUM(CASE WHEN f.service_type_key    NOT IN (SELECT service_type_key    FROM dim_service_type)    THEN 1 ELSE 0 END) AS miss_service_type,
    SUM(CASE WHEN f.technician_role_key NOT IN (SELECT technician_role_key FROM dim_technician_role) THEN 1 ELSE 0 END) AS miss_technician_role,
    SUM(CASE WHEN f.campaign_key IS NOT NULL
              AND f.campaign_key NOT IN (SELECT campaign_key FROM dim_campaign)
             THEN 1 ELSE 0 END) AS miss_campaign
  FROM ft_service_event f
)
SELECT miss_time, miss_device, miss_service_type, miss_technician_role, miss_campaign,
       CASE WHEN miss_time=0 AND miss_device=0 AND miss_service_type=0 AND miss_technician_role=0 AND miss_campaign=0
            THEN 'OK' ELSE 'fail' END AS status_check,
       CURRENT_TIMESTAMP(0)::timestamp AS run_time
FROM probs;
