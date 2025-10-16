SET search_path TO dwh_006, stg_006;

UPDATE stg_006.tb_campaign_city cc
SET city_id = c.id
FROM stg_006.tb_city c
JOIN stg_006.tb_country co ON c.countryid = co.id
WHERE
  cc.city_id IS NULL
  AND LOWER(cc.city_name) = LOWER(c.cityname)
  AND LOWER(cc.country_name) = LOWER(co.countryname);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM stg_006.tb_campaign_city WHERE city_id IS NULL) THEN
    IF NOT EXISTS (
      SELECT 1 FROM pg_constraint
      WHERE conname = 'uq_campaign_city' AND conrelid = 'stg_006.tb_campaign_city'::regclass
    ) THEN
      ALTER TABLE stg_006.tb_campaign_city
        ADD CONSTRAINT uq_campaign_city UNIQUE (campaign_id, city_id);
    END IF;

    IF NOT EXISTS (
      SELECT 1 FROM pg_constraint
      WHERE conname = 'fk_campaign_city_city' AND conrelid = 'stg_006.tb_campaign_city'::regclass
    ) THEN
      ALTER TABLE stg_006.tb_campaign_city
        ADD CONSTRAINT fk_campaign_city_city
        FOREIGN KEY (city_id)
        REFERENCES stg_006.tb_city (id)
        ON UPDATE CASCADE ON DELETE RESTRICT;
    END IF;
  END IF;
END $$;
