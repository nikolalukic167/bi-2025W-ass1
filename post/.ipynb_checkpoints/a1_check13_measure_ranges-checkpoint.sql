SET search_path TO dwh_006, stg_006;

-- Check [measures are within expected domains]
WITH r AS (
  SELECT
    SUM((cnt_readings < 0)::int)                 AS bad_cnt,
    SUM((sum_data_volume_bytes < 0)::int)        AS bad_bytes,
    SUM((avg_data_quality < 0 OR avg_data_quality > 5)::int) AS bad_quality,
    SUM((cnt_exceed_yellow  < 0)::int)           AS bad_y,
    SUM((cnt_exceed_orange  < 0)::int)           AS bad_o,
    SUM((cnt_exceed_red     < 0)::int)           AS bad_r,
    SUM((cnt_exceed_crimson < 0)::int)           AS bad_c
  FROM ft_reading_daily
),
s AS (
  SELECT
    SUM((service_cost_eur < 0)::int)                       AS bad_cost,
    SUM((service_duration_min < 0)::int)                   AS bad_dur,
    SUM((service_quality_score < 0 OR service_quality_score > 5)::int) AS bad_q,
    SUM((underqualified_flag NOT IN (0,1))::int)           AS bad_flag
  FROM ft_service_event
)
SELECT r.bad_cnt, r.bad_bytes, r.bad_quality, r.bad_y, r.bad_o, r.bad_r, r.bad_c,
       s.bad_cost, s.bad_dur, s.bad_q, s.bad_flag,
       CASE WHEN r.bad_cnt=0 AND r.bad_bytes=0 AND r.bad_quality=0
                 AND r.bad_y=0 AND r.bad_o=0 AND r.bad_r=0 AND r.bad_c=0
                 AND s.bad_cost=0 AND s.bad_dur=0 AND s.bad_q=0 AND s.bad_flag=0
            THEN 'OK' ELSE 'fail' END AS status_check,
       CURRENT_TIMESTAMP(0)::timestamp AS run_time
FROM r, s;
