{{ config(
    materialized = "view",
    schema = "mart_grp3"
) }}

-- Row-level Data Quality Violations for PSA GRDP Per Capita
-- Detects nulls, invalid numeric values, and extreme outliers

with cln as (
  select * 
  from {{ ref('clean_psa_grdp_per_capita') }}
),

violations as (
  select
    region,
    year_2022,
    year_2023,
    year_2024,
    growth_rate_2022_2023,
    growth_rate_2023_2024,

    -- Data Quality Issue Classification
    multiIf(
      region is null, 'null_region',
      year_2022 < 0 or year_2023 < 0 or year_2024 < 0, 'negative_grdp_value',
      growth_rate_2022_2023 < -100 or growth_rate_2022_2023 > 1000, 'outlier_growth_2022_2023',
      growth_rate_2023_2024 < -100 or growth_rate_2023_2024 > 1000, 'outlier_growth_2023_2024',
      'ok'
    ) as dq_issue

  from cln
)

select *
from violations
where dq_issue != 'ok'
