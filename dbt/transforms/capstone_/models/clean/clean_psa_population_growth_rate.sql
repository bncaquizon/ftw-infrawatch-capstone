{{ config(
    materialized = "table",
    schema = "clean_grp3",
    engine = "MergeTree()",
    order_by = "region",
    tags=["clean","psa"]
) }}

-- Clean Layer: PSA Population Growth Rate
-- Purpose: Standardize population counts and computed growth rate values.

select
  upper(trim(region)) as region,
  cast(year_2010 as Int64) as year_2010,
  cast(year_2015 as Int64) as year_2015,
  cast(year_2020 as Int64) as year_2020,
  cast(year_2024 as Int64) as year_2024,
  cast(growth_rate_2010_2015 as Float64) as growth_rate_2010_2015,
  cast(growth_rate_2015_2020 as Float64) as growth_rate_2015_2020,
  cast(growth_rate_2015_2024 as Float64) as growth_rate_2015_2024,
  cast(growth_rate_2020_2024 as Float64) as growth_rate_2020_2024
from {{ source('raw_grp3', 'raw___psa_population_growth_rate') }}