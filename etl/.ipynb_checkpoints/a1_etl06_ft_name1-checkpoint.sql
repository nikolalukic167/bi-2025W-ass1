SET search_path TO dwh_006, stg_006;

TRUNCATE TABLE dim_campaign RESTART IDENTITY CASCADE;

INSERT INTO dim_campaign (
  campaign_id_nk, campaign_name, campaign_type, start_date, end_date, responsible_agency, budget_million_eur
)
SELECT
    c.campaign_id
  , c.campaign_name
  , c.campaign_type
  , c.start_date
  , c.end_date
  , c.responsible_agency
  , c.budget_million_eur
FROM stg_006.tb_environmental_campaign c
ORDER BY c.campaign_id;

INSERT INTO dim_campaign (campaign_id_nk, campaign_name, campaign_type, start_date)
VALUES (-1, 'No Active Campaign', 'None', DATE '1900-01-01')
ON CONFLICT (campaign_id_nk) DO NOTHING;