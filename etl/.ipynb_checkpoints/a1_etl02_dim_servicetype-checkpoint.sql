SET search_path TO dwh_006, stg_006;

TRUNCATE TABLE dim_servicetype RESTART IDENTITY CASCADE;

INSERT INTO dim_servicetype (
  service_type_id_nk, service_group, category, service_type_name, required_min_level, procedure_short
)
SELECT
  st.id, st.servicegroup, st.category, st.typename, st.minlevel, st.details
FROM stg_006.tb_servicetype st
ORDER BY st.id;
