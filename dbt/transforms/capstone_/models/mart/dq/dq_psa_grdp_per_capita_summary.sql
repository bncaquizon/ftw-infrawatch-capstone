{{ config(
    materialized = "view",
    schema = "mart_grp3"
) }}

-- Data Quality Summary for PSA GRDP Per Capita
-- Tracks: row counts, null %, duplicates, and value range checks

with rawDs as (
  select * from {{ source('raw_grp3', 'raw___psa_grdp_per_capita') }}
),

cln as (
  select * from {{ ref('clean_psa_grdp_per_capita') }}
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
    round(100.0 * countIf(year_2022 is null) / nullif(count(),0), 2) as null_pct_year_2022,
    round(100.0 * countIf(year_2023 is null) / nullif(count(),0), 2) as null_pct_year_2023,
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
    countIf(year_2022 < 0 or year_2023 < 0 or year_2024 < 0) as negative_grdp_value,
    countIf(growth_rate_2022_2023 < -100 or growth_rate_2022_2023 > 1000) as outlier_growth_2022_2023,
    countIf(growth_rate_2023_2024 < -100 or growth_rate_2023_2024 > 1000) as outlier_growth_2023_2024
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
    value_ranges.negative_grdp_value,
    value_ranges.outlier_growth_2022_2023,
    value_ranges.outlier_growth_2023_2024
  from counts
  cross join nulls
  cross join dupes
  cross join value_ranges
)

select * from joined
