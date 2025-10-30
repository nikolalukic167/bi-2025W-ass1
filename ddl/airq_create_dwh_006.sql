CREATE SCHEMA IF NOT EXISTS dwh_006;
SET search_path TO dwh_006;

CREATE TABLE IF NOT EXISTS dim_timeday (
    time_day_key          INTEGER     PRIMARY KEY,
    date_actual           DATE        NOT NULL UNIQUE,
    day_of_week           SMALLINT    NOT NULL,
    day_name              TEXT        NOT NULL,
    is_weekend            BOOLEAN     NOT NULL,
    week_of_year          SMALLINT    NOT NULL,
    month                 SMALLINT    NOT NULL,
    month_name            TEXT        NOT NULL,
    quarter               SMALLINT    NOT NULL,
    year                  SMALLINT    NOT NULL,
    etl_load_timestamp    TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS dim_device (
    device_key            BIGINT      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    device_id_nk          INTEGER     NOT NULL UNIQUE,
    device_code           TEXT        NOT NULL,
    country_name          TEXT        NOT NULL,
    city_name             TEXT        NOT NULL,
    location_type         TEXT        NOT NULL,
    altitude_m            INTEGER     NOT NULL,
    installation_date     DATE        NOT NULL,
    manufacturer_name     TEXT,
    sensor_type_name      TEXT,
    technology            TEXT,
    etl_load_timestamp    TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS dim_sensor_type (
    sensor_type_key       BIGINT      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sensor_type_id_nk     INTEGER     NOT NULL UNIQUE,
    manufacturer_name     TEXT        NOT NULL,
    technology            TEXT        NOT NULL,
    sensor_type_name      TEXT        NOT NULL,
    introduced_date       DATE,
    retired_date          DATE,
    etl_load_timestamp    TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS dim_parameter (
    parameter_key         BIGINT      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    parameter_id_nk       INTEGER     NOT NULL UNIQUE,
    parameter_code        TEXT        NOT NULL,
    parameter_name        TEXT        NOT NULL,
    unit                  TEXT        NOT NULL,
    family                TEXT        NOT NULL,
    etl_load_timestamp    TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS dim_reading_mode (
    reading_mode_key      BIGINT      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    reading_mode_id_nk    INTEGER     NOT NULL UNIQUE,
    mode_name             TEXT        NOT NULL,
    valid_from            DATE        NOT NULL,
    valid_to              DATE,
    details               TEXT,
    etl_load_timestamp    TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS dim_servicetype (
    service_type_key      BIGINT      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    service_type_id_nk    INTEGER     NOT NULL UNIQUE,
    service_group         TEXT        NOT NULL,
    category              TEXT        NOT NULL,
    service_type_name     TEXT        NOT NULL,
    required_min_level    SMALLINT    NOT NULL,
    procedure_short       TEXT,
    etl_load_timestamp    TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,

    sk_servicetype        BIGINT      GENERATED ALWAYS AS (service_type_key) STORED,
    tb_servicetype_id     INTEGER     GENERATED ALWAYS AS (service_type_id_nk) STORED,
    typename              TEXT        GENERATED ALWAYS AS (service_type_name) STORED
);

CREATE TABLE IF NOT EXISTS dim_technician_role (
    technician_role_key   BIGINT      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    technician_id_nk      INTEGER     NOT NULL,
    role_category         TEXT        NOT NULL,
    role_level            SMALLINT    NOT NULL,
    valid_from            DATE        NOT NULL,
    valid_to              DATE,
    is_current            BOOLEAN     NOT NULL,
    etl_load_timestamp    TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS ix_dtr_nk_range
    ON dim_technician_role (technician_id_nk, valid_from, COALESCE(valid_to, '9999-12-31'));

CREATE TABLE IF NOT EXISTS dim_campaign (
    campaign_key          BIGINT      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    campaign_id_nk        INTEGER     NOT NULL UNIQUE,
    campaign_name         TEXT        NOT NULL,
    campaign_type         TEXT        NOT NULL,
    start_date            DATE        NOT NULL,
    end_date              DATE,
    responsible_agency    TEXT,
    budget_million_eur    NUMERIC(10,2),
    etl_load_timestamp    TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- FACTS
CREATE TABLE IF NOT EXISTS ft_reading_daily (
    reading_daily_key         BIGINT  GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    time_day_key              INTEGER NOT NULL REFERENCES dwh_006.dim_timeday(time_day_key),
    device_key                BIGINT  NOT NULL REFERENCES dwh_006.dim_device(device_key),
    parameter_key             BIGINT  NOT NULL REFERENCES dwh_006.dim_parameter(parameter_key),
    sensor_type_key           BIGINT  NOT NULL REFERENCES dwh_006.dim_sensor_type(sensor_type_key),
    reading_mode_key          BIGINT  NOT NULL REFERENCES dwh_006.dim_reading_mode(reading_mode_key),
    campaign_key              BIGINT           REFERENCES dwh_006.dim_campaign(campaign_key),

    cnt_readings              BIGINT  NOT NULL CHECK (cnt_readings >= 0),
    sum_data_volume_bytes     BIGINT  NOT NULL CHECK (sum_data_volume_bytes >= 0),
    avg_data_quality          NUMERIC(5,2) NOT NULL CHECK (avg_data_quality BETWEEN 0 AND 5),
    avg_value                 NUMERIC(18,6) NOT NULL,
    cnt_exceed_yellow         INTEGER NOT NULL CHECK (cnt_exceed_yellow   >= 0),
    cnt_exceed_orange         INTEGER NOT NULL CHECK (cnt_exceed_orange   >= 0),
    cnt_exceed_red            INTEGER NOT NULL CHECK (cnt_exceed_red      >= 0),
    cnt_exceed_crimson        INTEGER NOT NULL CHECK (cnt_exceed_crimson  >= 0),

    etl_load_timestamp        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS ix_ft_reading_daily_fk
    ON ft_reading_daily (time_day_key, device_key, parameter_key, sensor_type_key, reading_mode_key, campaign_key);

CREATE TABLE IF NOT EXISTS ft_service_event (
    service_event_key         BIGINT  GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    time_day_key              INTEGER NOT NULL REFERENCES dwh_006.dim_timeday(time_day_key),
    device_key                BIGINT  NOT NULL REFERENCES dwh_006.dim_device(device_key),
    service_type_key          BIGINT  NOT NULL REFERENCES dwh_006.dim_servicetype(service_type_key),
    technician_role_key       BIGINT  NOT NULL REFERENCES dwh_006.dim_technician_role(technician_role_key),
    campaign_key              BIGINT           REFERENCES dwh_006.dim_campaign(campaign_key),

    service_event_code        TEXT,

    service_cost_eur          NUMERIC(12,2) NOT NULL CHECK (service_cost_eur >= 0),
    service_duration_min      INTEGER       NOT NULL CHECK (service_duration_min >= 0),
    service_quality_score     NUMERIC(5,2)  NOT NULL CHECK (service_quality_score BETWEEN 0 AND 5),
    underqualified_flag       SMALLINT      NOT NULL CHECK (underqualified_flag IN (0,1)),

    etl_load_timestamp        TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS ix_ft_service_event_fk
    ON ft_service_event (time_day_key, device_key, service_type_key, technician_role_key, campaign_key);