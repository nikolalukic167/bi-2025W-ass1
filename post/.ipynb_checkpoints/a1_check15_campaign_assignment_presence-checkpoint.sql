SET search_path TO dwh_006, stg_006;

-- Check [facts have campaign references when campaigns are active in city-day]
WITH any_campaign AS (
  SELECT COUNT(*) AS c FROM stg_006.tb_environmental_campaign
),
reading_with_c AS (
  SELECT COUNT(*) AS c FROM ft_reading_daily WHERE campaign_key IS NOT NULL
),
service_with_c AS (
  SELECT COUNT(*) AS c FROM ft_service_event WHERE campaign_key IS NOT NULL
)
SELECT any_campaign.c AS campaigns_defined,
       reading_with_c.c AS reading_rows_with_campaign,
       service_with_c.c AS service_rows_with_campaign,
       CASE WHEN any_campaign.c = 0 THEN 'OK' -- no campaigns → no expectation
            WHEN reading_with_c.c + service_with_c.c > 0 THEN 'OK'
            ELSE 'fail' END AS status_check,
       CURRENT_TIMESTAMP(0)::timestamp AS run_time
FROM any_campaign, reading_with_c, service_with_c;
