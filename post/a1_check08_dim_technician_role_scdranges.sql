SET search_path TO dwh_006, stg_006;

-- Check [SCD2 overlaps + one current row per technician]
WITH spans AS (
  SELECT technician_id_nk, technician_role_key,
         valid_from, COALESCE(valid_to, DATE '9999-12-31') AS valid_to,
         is_current
  FROM dim_technician_role
),
overlaps AS (
  SELECT COUNT(*) AS cnt
  FROM spans a
  JOIN spans b
    ON a.technician_id_nk = b.technician_id_nk
   AND a.technician_role_key < b.technician_role_key
   AND a.valid_from <= b.valid_to
   AND b.valid_from <= a.valid_to
),
curr AS (
  SELECT COUNT(*) AS bad
  FROM (
    SELECT technician_id_nk, COUNT(*) AS c
    FROM dim_technician_role
    WHERE is_current = TRUE
    GROUP BY 1
    HAVING COUNT(*) <> 1
  ) x
)
SELECT o.cnt AS overlap_pairs,
       c.bad AS technicians_with_bad_current_rows,
       CASE WHEN o.cnt = 0 AND c.bad = 0 THEN 'OK' ELSE 'fail' END AS status_check,
       CURRENT_TIMESTAMP(0)::timestamp AS run_time
FROM overlaps o, curr c;
