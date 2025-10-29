CREATE SCHEMA IF NOT EXISTS stg_006;
SET search_path TO stg_006;

CREATE TABLE IF NOT EXISTS tb_environmental_campaign (
    campaign_id           INTEGER PRIMARY KEY,
    campaign_name         TEXT        NOT NULL,
    campaign_type         TEXT        NOT NULL CHECK (campaign_type IN ('Awareness','Regulation','Research')),
    start_date            DATE        NOT NULL,
    end_date              DATE,
    responsible_agency    TEXT,
    budget_million_eur    NUMERIC(10,2) CHECK (budget_million_eur >= 0),
    etl_load_timestamp    TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE tb_environmental_campaign IS
'Manually created Table_X (entity) listing environmental/policy/awareness campaigns.';


CREATE TABLE IF NOT EXISTS tb_campaign_city (
    campaign_id           INTEGER     NOT NULL,
    city_id               INTEGER     NULL,
    city_name             TEXT        NOT NULL,
    country_name          TEXT        NOT NULL,
    impact_level          TEXT        NOT NULL CHECK (impact_level IN ('Low','Medium','High')),
    effectiveness_score   NUMERIC(3,1) CHECK (effectiveness_score >= 0 AND effectiveness_score <= 5),
    monitoring_required   BOOLEAN     NOT NULL DEFAULT FALSE,
    etl_load_timestamp    TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_campaign_city_natural PRIMARY KEY (campaign_id, city_name, country_name),
    CONSTRAINT fk_campaign_city_campaign
        FOREIGN KEY (campaign_id)
        REFERENCES stg_006.tb_environmental_campaign (campaign_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS ix_campaign_city_names
    ON tb_campaign_city (LOWER(city_name), LOWER(country_name));

COMMENT ON TABLE tb_campaign_city IS
'Manually created Table_Y (bridge) linking campaigns to cities. city_id populated after name-based lookup.';
