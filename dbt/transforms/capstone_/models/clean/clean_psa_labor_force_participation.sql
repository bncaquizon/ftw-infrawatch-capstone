{{ config(
    materialized = "table",
    schema = "clean_grp3",
    engine = "MergeTree()",
    order_by = "region",
    tags=["clean", "psa"]
) }}

-- Clean Layer: PSA Labor Force Participation
-- Purpose: Standardize labor force and employment rate data for trend analysis (2024–2025)

select
  upper(trim(region)) as region,
  cast(labor_force_parti_rate_2024 as Float64) as labor_force_parti_rate_2024,
  cast(labor_force_parti_rate_jan_2025 as Float64) as labor_force_parti_rate_jan_2025,
  cast(labor_force_parti_rate_april_2025 as Float64) as labor_force_parti_rate_april_2025,
  cast(labor_force_parti_rate_july_2025 as Float64) as labor_force_parti_rate_july_2025,
  cast(employment_rate_jul_2024 as Float64) as employment_rate_jul_2024,
  cast(employment_rate_jan_2025 as Float64) as employment_rate_jan_2025,
  cast(employment_rate_april_2025 as Float64) as employment_rate_april_2025,
  cast(employment_rate_jul_2025 as Float64) as employment_rate_jul_2025
from {{ source('raw_grp3', 'raw___psa_labor_force_participation') }}