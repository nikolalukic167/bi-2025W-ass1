SET search_path TO dwh_006, stg_006;

TRUNCATE TABLE dim_technician_role RESTART IDENTITY CASCADE;

WITH role_history AS (
  SELECT
      e.id                                  AS technician_id_nk       
    , r.category                            AS role_category
    , r.rolelevel                           AS role_level
    , e.validfrom                           AS valid_from
    , COALESCE(e.validto, DATE '9999-12-31') AS valid_to
    , (e.validto IS NULL)                   AS is_current
  FROM stg_006.tb_employee e
  JOIN stg_006.tb_role r ON r.id = e.roleid
)
INSERT INTO dim_technician_role (
  technician_id_nk, role_category, role_level, valid_from, valid_to, is_current
)
SELECT technician_id_nk, role_category, role_level, valid_from, valid_to, is_current
FROM role_history
ORDER BY technician_id_nk, valid_from;
