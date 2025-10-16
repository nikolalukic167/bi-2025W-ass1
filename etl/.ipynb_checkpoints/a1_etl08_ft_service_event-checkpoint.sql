SET search_path TO dwh_006, stg_006;

TRUNCATE TABLE ft_service_event RESTART IDENTITY CASCADE;

WITH svc AS (
  SELECT
      se.id               AS service_event_id
    , se.servicedat::date AS d
    , se.servicetypeid
    , se.employeeid
    , se.sensordevid
    , se.servicecost
    , se.durationminutes
    , se.servicequality
  FROM stg_006.tb_serviceevent se
),
svc_keys AS (
  SELECT
      s.*
    , dt.time_day_key
    , dd.device_key
    , dst.service_type_key
    , dtr.technician_role_key
    , (SELECT c.campaign_id
       FROM stg_006.tb_campaign_city cc
       JOIN stg_006.tb_environmental_campaign c ON c.campaign_id = cc.campaign_id
       JOIN stg_006.tb_sensordevice sdx ON sdx.id = s.sensordevid
       WHERE cc.city_id = sdx.cityid
         AND c.start_date <= s.d
         AND (c.end_date IS NULL OR c.end_date >= s.d)
       ORDER BY
         CASE cc.impact_level WHEN 'High' THEN 3 WHEN 'Medium' THEN 2 WHEN 'Low' THEN 1 ELSE 0 END DESC,
         cc.effectiveness_score DESC NULLS LAST,
         c.campaign_id ASC
       LIMIT 1) AS campaign_id
  FROM svc s
  JOIN dwh_006.dim_timeday       dt  ON dt.date_actual = s.d
  JOIN dwh_006.dim_device        dd  ON dd.device_id_nk = s.sensordevid
  JOIN dwh_006.dim_servicetype  dst ON dst.service_type_id_nk = s.servicetypeid
  JOIN dwh_006.dim_technician_role dtr
    ON dtr.technician_id_nk = s.employeeid
   AND dtr.valid_from <= s.d
   AND COALESCE(dtr.valid_to, DATE '9999-12-31') >= s.d
),
underq AS (
  SELECT
      sk.service_event_id
    , CASE WHEN dtr.role_level < dst.required_min_level THEN 1 ELSE 0 END AS underqualified_flag
  FROM svc_keys sk
  JOIN dwh_006.dim_technician_role dtr ON dtr.technician_role_key = sk.technician_role_key
  JOIN dwh_006.dim_servicetype    dst ON dst.service_type_key     = sk.service_type_key
)
INSERT INTO ft_service_event (
  time_day_key, device_key, service_type_key, technician_role_key, campaign_key,
  service_event_code, service_cost_eur, service_duration_min, service_quality_score, underqualified_flag
)
SELECT
    sk.time_day_key
  , sk.device_key
  , sk.service_type_key
  , sk.technician_role_key
  , dc_dim.campaign_key
  , sk.service_event_id::text AS service_event_code
  , sk.servicecost::numeric(12,2) AS service_cost_eur
  , sk.durationminutes
  , sk.servicequality::numeric(5,2) AS service_quality_score
  , uq.underqualified_flag
FROM svc_keys sk
LEFT JOIN underq uq ON uq.service_event_id = sk.service_event_id
LEFT JOIN dwh_006.dim_campaign dc_dim ON dc_dim.campaign_id_nk = sk.campaign_id;
