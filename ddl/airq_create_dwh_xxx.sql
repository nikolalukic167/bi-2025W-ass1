-- Make A1 dwh_xxx schema the default for this session
SET search_path TO dwh_xxx;

-- -------------------------------
-- 2) DROP TABLE before attempting to create DWH schema tables
-- -------------------------------
DROP TABLE IF EXISTS dim_timeday;
DROP TABLE IF EXISTS dim_servicetype;
DROP TABLE IF EXISTS dim_parameter;
DROP TABLE IF EXISTS dim_technician_role_scd2;
--- and so on ...
DROP TABLE IF EXISTS ft_name1;
DROP TABLE IF EXISTS ft_name2;

-- -------------------------------
-- 3) CREATE TABLE statements for facts and dimensions
-- Please make sure the order in which individual statements are executed respects the FOREIGN KEY constraints
-- -------------------------------
CREATE TABLE dim_timeday (
    id INT NOT NULL PRIMARY KEY
    -- , ...
	, etl_load_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dim_servicetype (
  sk_servicetype BIGSERIAL PRIMARY KEY       -- SK
  , tb_servicetype_id INT NOT NULL           -- ID from OLTP
  , typename VARCHAR(200) NOT NULL
  , etl_load_timestamp TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP
  , CONSTRAINT uq_dim_servicetype_bk UNIQUE (tb_servicetype_id)
);

CREATE TABLE dim_parameter (
  sk_parameter BIGSERIAL PRIMARY KEY   -- SK
  , tb_param_id INT NOT NULL           -- ID from OLTP
  , paramname VARCHAR(200) NOT NULL    -- e.g., 'PM2', 'Mercury'
  , category VARCHAR(200) NOT NULL     -- e.g. Particulate matter, Heavy Metal
  , unit VARCHAR(50) NOT NULL          -- e.g., 'count/m3'
  , etl_load_timestamp TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP
  , CONSTRAINT uq_dim_parameter_bk UNIQUE (tb_param_id)
);

CREATE TABLE dim_technician_role_scd2 (
  sk_technician_role BIGSERIAL PRIMARY KEY
  , badgenumber VARCHAR(255) NOT NULL   -- business key
  , rolelevel INT NOT NULL
  , category VARCHAR(255) NOT NULL
  , rolename               VARCHAR(255) NOT NULL
  , effective_from         DATE NOT NULL
  , effective_to           DATE NOT NULL  -- '9999-12-31' for current
  , is_current             BOOLEAN NOT NULL
  , etl_load_timestamp     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(0)
  , CONSTRAINT ux_techrole_bk_timerange UNIQUE (badgenumber, effective_from, effective_to)
);

-- .......

-- FACT 1: linked to TimeDay + Parameter + ServiceType
CREATE TABLE ft_name1 (
    id INT NOT NULL PRIMARY KEY                  -- keep a simple surrogate PK for the fact
    , day_id INT NOT NULL                        -- -> dim_timeday.id
    , sk_parameter BIGINT NOT NULL               -- -> dim_parameter.sk_parameter
    , sk_servicetype BIGINT NOT NULL             -- -> dim_servicetype.sk_servicetype
    -- (optional) add your measures here, e.g.: measure_value NUMERIC(18,2) NOT NULL,
    , etl_load_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    , CONSTRAINT fk_name1_timeday FOREIGN KEY (day_id) REFERENCES dim_timeday(id)
    , CONSTRAINT fk_name1_parameter FOREIGN KEY (sk_parameter) REFERENCES dim_parameter(sk_parameter)
    , CONSTRAINT fk_name1_servicetype FOREIGN KEY (sk_servicetype) REFERENCES dim_servicetype(sk_servicetype)
);

-- helpful indexes for join performance (optional but recommended)
CREATE INDEX ix_ft_name1_day           ON ft_name1(day_id);
CREATE INDEX ix_ft_name1_parameter     ON ft_name1(sk_parameter);
CREATE INDEX ix_ft_name1_servicetype   ON ft_name1(sk_servicetype);

-- FACT 2: linked to TimeDay + Parameter + Technician Role (SCD2)
CREATE TABLE ft_name2 (
    id INT NOT NULL PRIMARY KEY                  -- keep a simple surrogate PK for the fact
    , day_id INT NOT NULL                        -- -> dim_timeday.id
    , sk_parameter BIGINT NOT NULL               -- -> dim_parameter.sk_parameter
    , sk_technician_role BIGINT NOT NULL         -- -> dim_technician_role_scd2.sk_technician_role
    -- (optional) add your measures here
    , etl_load_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    , CONSTRAINT fk_name2_day FOREIGN KEY (day_id) REFERENCES dim_timeday(id)
    , CONSTRAINT fk_name2_parameter FOREIGN KEY (sk_parameter) REFERENCES dim_parameter(sk_parameter)
    , CONSTRAINT fk_name2_techrole FOREIGN KEY (sk_technician_role) REFERENCES dim_technician_role_scd2(sk_technician_role)
);

-- helpful indexes for join performance (optional but recommended)
CREATE INDEX ix_ft_name2_day           ON ft_name2(day_id);
CREATE INDEX ix_ft_name2_parameter     ON ft_name2(sk_parameter);
CREATE INDEX ix_ft_name2_techrole      ON ft_name2(sk_technician_role);


