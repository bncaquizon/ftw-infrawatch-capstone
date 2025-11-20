{{ config(
    materialized = "table",
    schema = "clean_grp3",
    engine = "MergeTree()",
    order_by = "region",
    tags=["clean","psa"]
) }}

-- Clean Layer: PSA Population Density
-- Purpose: Standardize population, area, and density values.

select
    upper(trim(region)) AS region,
    cast(replaceAll(population_2010, ',', '') AS Int64) AS population_2010,
    cast(replaceAll(population_2015, ',', '') AS Int64) AS population_2015,
    cast(replaceAll(population_2020, ',', '') AS Int64) AS population_2020,
    cast(replaceAll(population_2024, ',', '') AS Int64) AS population_2024,
    cast(replaceAll(land_area, ',', '') AS Float64) AS land_area,
    cast(replaceAll(population_density_2010, ',', '') AS Float64) AS population_density_2010,
    cast(replaceAll(population_density_2015, ',', '') AS Float64) AS population_density_2015,
    cast(replaceAll(population_density_2020, ',', '') AS Float64) AS population_density_2020,
    cast(replaceAll(population_density_2024, ',', '') AS Float64) AS population_density_2024,
    cast(density_growth_rate_2010_2024 AS Float64) AS density_growth_rate_2010_2024,
    cast(urban_pop_growth_2010_2020 AS Float64) AS urban_pop_growth_2010_2020,
    cast(urban_pop_growth_2010_2024 AS Float64) AS urban_pop_growth_2010_2024
from {{ source('raw_grp3', 'raw___psa_population_density') }}
where region is not null