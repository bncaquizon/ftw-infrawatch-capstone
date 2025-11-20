{{ config(
    materialized = "view",
    schema = "mart_grp3"
) }}

-- Row-level Data Quality Violations for PSA Population Growth Rate
-- Detects missing regions, invalid population counts, and outlier growth rates.

with cln as (
  select * 
  from {{ ref('clean_psa_population_growth_rate') }}
),

violations as (
  select
    region,
    year_2010,
    year_2015,
    year_2020,
    year_2024,
    growth_rate_2010_2015,
    growth_rate_2015_2020,
    growth_rate_2015_2024,
    growth_rate_2020_2024,

    -- Data Quality Issue Classification
    multiIf(
      region is null, 'null_region',
      year_2010 < 0 or year_2015 < 0 or year_2020 < 0 or year_2024 < 0, 'negative_population',
      growth_rate_2010_2015 < -100 or growth_rate_2010_2015 > 1000, 'outlier_growth_2010_2015',
      growth_rate_2015_2020 < -100 or growth_rate_2015_2020 > 1000, 'outlier_growth_2015_2020',
      growth_rate_2015_2024 < -100 or growth_rate_2015_2024 > 1000, 'outlier_growth_2015_2024',
      growth_rate_2020_2024 < -100 or growth_rate_2020_2024 > 1000, 'outlier_growth_2020_2024',
      'ok'
    ) as dq_issue

  from cln
)

select *
from violations
where dq_issue != 'ok'
