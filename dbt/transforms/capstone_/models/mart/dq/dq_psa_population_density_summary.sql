{{ config(
    materialized = "view",
    schema = "mart_grp3"
) }}

-- Data Quality Summary for PSA Population Density
-- Tracks: row counts, null %, duplicates, and value range checks

with rawDs as (
  select * from {{ source('raw_grp3', 'raw___psa_population_density') }}
),

cln as (
  select * from {{ ref('clean_psa_population_density') }}
),

-- Row Count Comparison
counts as (
  select
    (select count() from rawDs)  as row_count_raw,
    (select count() from cln)    as row_count_clean
),

-- Null Percentage Check
nulls as (
  select
    round(100.0 * countIf(region is null) / nullif(count(),0), 2) as null_pct_region,
    round(100.0 * countIf(land_area is null) / nullif(count(),0), 2) as null_pct_land_area,
    round(100.0 * countIf(population_2024 is null) / nullif(count(),0), 2) as null_pct_population_2024,
    round(100.0 * countIf(population_density_2024 is null) / nullif(count(),0), 2) as null_pct_density_2024
  from cln
),

-- Duplicate Regions
dupes as (
  select
    countIf(cnt > 1) as duplicate_regions
  from (
    select region, count() as cnt
    from cln
    group by region
  )
),

-- Value Range Checks
value_ranges as (
  select
    countIf(land_area <= 0) as invalid_land_area,
    countIf(population_2024 < 0) as invalid_population,
    countIf(population_density_2024 < 0) as invalid_density,
    countIf(density_growth_rate_2010_2024 < -100 or density_growth_rate_2010_2024 > 1000) as outlier_density_growth,
    countIf(urban_pop_growth_2010_2020 < -100 or urban_pop_growth_2010_2020 > 1000) as outlier_urban_growth
  from cln
),

-- Join all metrics
joined as (
  select
    counts.row_count_raw,
    counts.row_count_clean,
    (counts.row_count_raw - counts.row_count_clean) as dropped_rows,
    nulls.*,
    dupes.duplicate_regions,
    value_ranges.invalid_land_area,
    value_ranges.invalid_population,
    value_ranges.invalid_density,
    value_ranges.outlier_density_growth,
    value_ranges.outlier_urban_growth
  from counts
  cross join nulls
  cross join dupes
  cross join value_ranges
)

select * from joined
