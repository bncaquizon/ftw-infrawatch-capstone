{{ config(
    materialized = "view",
    schema = "mart_grp3"
) }}

-- Data Quality Summary for PSA Population Growth Rate
-- Tracks row counts, null %, duplicates, and numeric validity checks.

with rawDs as (
  select * from {{ source('raw_grp3', 'raw___psa_population_growth_rate') }}
),

cln as (
  select * from {{ ref('clean_psa_population_growth_rate') }}
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
    round(100.0 * countIf(year_2010 is null) / nullif(count(),0), 2) as null_pct_year_2010,
    round(100.0 * countIf(year_2015 is null) / nullif(count(),0), 2) as null_pct_year_2015,
    round(100.0 * countIf(year_2020 is null) / nullif(count(),0), 2) as null_pct_year_2020,
    round(100.0 * countIf(year_2024 is null) / nullif(count(),0), 2) as null_pct_year_2024
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
    countIf(year_2010 < 0 or year_2015 < 0 or year_2020 < 0 or year_2024 < 0) as negative_population,
    countIf(growth_rate_2010_2015 < -100 or growth_rate_2010_2015 > 1000) as outlier_growth_2010_2015,
    countIf(growth_rate_2015_2020 < -100 or growth_rate_2015_2020 > 1000) as outlier_growth_2015_2020,
    countIf(growth_rate_2015_2024 < -100 or growth_rate_2015_2024 > 1000) as outlier_growth_2015_2024,
    countIf(growth_rate_2020_2024 < -100 or growth_rate_2020_2024 > 1000) as outlier_growth_2020_2024
  from cln
),

-- Combine all metrics
joined as (
  select
    counts.row_count_raw,
    counts.row_count_clean,
    (counts.row_count_raw - counts.row_count_clean) as dropped_rows,
    nulls.*,
    dupes.duplicate_regions,
    value_ranges.negative_population,
    value_ranges.outlier_growth_2010_2015,
    value_ranges.outlier_growth_2015_2020,
    value_ranges.outlier_growth_2015_2024,
    value_ranges.outlier_growth_2020_2024
  from counts
  cross join nulls
  cross join dupes
  cross join value_ranges
)

select * from joined
