{{ config(
    materialized = "view",
    schema = "mart_grp3"
) }}

-- Row-level Data Quality Violations for PSA Labor Force Participation
-- Detects missing regions, invalid participation rates, and outlier employment rates.

with cln as (
  select * 
  from {{ ref('clean_psa_labor_force_participation') }}
),

violations as (
  select
    region,
    labor_force_parti_rate_2024,
    labor_force_parti_rate_jan_2025,
    labor_force_parti_rate_april_2025,
    labor_force_parti_rate_july_2025,
    employment_rate_jul_2024,
    employment_rate_jan_2025,
    employment_rate_april_2025,
    employment_rate_jul_2025,

    -- Data Quality Issue Classification
    multiIf(
      region is null, 'null_region',
      labor_force_parti_rate_2024 < 0 or labor_force_parti_rate_2024 > 100, 'invalid_lfp_2024',
      labor_force_parti_rate_jan_2025 < 0 or labor_force_parti_rate_jan_2025 > 100, 'invalid_lfp_jan_2025',
      labor_force_parti_rate_april_2025 < 0 or labor_force_parti_rate_april_2025 > 100, 'invalid_lfp_april_2025',
      labor_force_parti_rate_july_2025 < 0 or labor_force_parti_rate_july_2025 > 100, 'invalid_lfp_july_2025',
      employment_rate_jul_2024 < 0 or employment_rate_jul_2024 > 100, 'invalid_employ_jul_2024',
      employment_rate_jan_2025 < 0 or employment_rate_jan_2025 > 100, 'invalid_employ_jan_2025',
      employment_rate_april_2025 < 0 or employment_rate_april_2025 > 100, 'invalid_employ_april_2025',
      employment_rate_jul_2025 < 0 or employment_rate_jul_2025 > 100, 'invalid_employ_jul_2025',
      'ok'
    ) as dq_issue

  from cln
)

select *
from violations
where dq_issue != 'ok'
