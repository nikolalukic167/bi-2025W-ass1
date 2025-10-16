SET search_path TO dwh_006, stg_006;

TRUNCATE TABLE dim_device RESTART IDENTITY CASCADE;

INSERT INTO dim_device (
  device_id_nk, device_code, country_name, city_name, location_type,
  altitude_m, installation_date, manufacturer_name, sensor_type_name, technology
)
SELECT
    sd.id            AS device_id_nk
  , sd.locationname  AS device_code
  , co.countryname   AS country_name
  , ci.cityname      AS city_name
  , sd.locationtype  AS location_type
  , sd.altitude      AS altitude_m
  , sd.installedat   AS installation_date
  , st.manufacturer  AS manufacturer_name
  , st.typename      AS sensor_type_name
  , st.technology    AS technology
FROM stg_006.tb_sensordevice sd
JOIN stg_006.tb_city       ci ON ci.id = sd.cityid
JOIN stg_006.tb_country    co ON co.id = ci.countryid
JOIN stg_006.tb_sensortype st ON st.id = sd.sensortypeid
ORDER BY sd.id;
