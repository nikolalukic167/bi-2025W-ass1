SET search_path TO dwh_006, stg_006;

TRUNCATE TABLE dim_parameter RESTART IDENTITY CASCADE;

INSERT INTO dim_parameter (
  parameter_id_nk, parameter_code, parameter_name, unit, family
)
SELECT
  p.id AS parameter_id_nk,
  REGEXP_REPLACE(UPPER(p.paramname), '[^A-Z0-9]+', '_', 'g') AS parameter_code,
  p.paramname AS parameter_name,
  p.unit,
  p.category  AS family
FROM stg_006.tb_param p
ORDER BY p.id;
