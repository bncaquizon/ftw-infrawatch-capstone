{{ config(
    materialized = "table",
    schema = "clean_grp3",
    engine = "MergeTree()",
    order_by = "region",
    tags=["clean","psa"]
) }}

-- Clean Layer: PSA GRDP Per Capita
-- Purpose: Standardize GRDP per capita and growth rate values.

select
  upper(trim(region)) as region,
  cast(year_2022 as Float64) as year_2022,
  cast(year_2023 as Float64) as year_2023,
  cast(year_2024 as Float64) as year_2024,
  cast(growth_rate_2022_2023 as Float64) as growth_rate_2022_2023,
  cast(growth_rate_2023_2024 as Float64) as growth_rate_2023_2024
from {{ source('raw_grp3', 'raw___psa_grdp_per_capita') }}