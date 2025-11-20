{{ config(
    materialized = "view",
    schema = "mart_grp3"
) }}

-- Data Quality Summary for PSA Labor Force Participation
-- Tracks row counts, null %, duplicates, and value range checks for rates.

with rawDs as (
  select * from {{ source('raw_grp3', 'raw___psa_labor_force_participation') }}
),

cln as (
  select * from {{ ref('clean_psa_labor_force_participation') }}
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
    round(100.0 * countIf(labor_force_parti_rate_2024 is null) / nullif(count(),0), 2) as null_pct_lfp_2024,
    round(100.0 * countIf(labor_force_parti_rate_jan_2025 is null) / nullif(count(),0), 2) as null_pct_lfp_jan_2025,
    round(100.0 * countIf(labor_force_parti_rate_april_2025 is null) / nullif(count(),0), 2) as null_pct_lfp_april_2025,
    round(100.0 * countIf(labor_force_parti_rate_july_2025 is null) / nullif(count(),0), 2) as null_pct_lfp_july_2025,
    round(100.0 * countIf(employment_rate_jul_2024 is null) / nullif(count(),0), 2) as null_pct_employ_jul_2024,
    round(100.0 * countIf(employment_rate_jan_2025 is null) / nullif(count(),0), 2) as null_pct_employ_jan_2025,
    round(100.0 * countIf(employment_rate_april_2025 is null) / nullif(count(),0), 2) as null_pct_employ_april_2025,
    round(100.0 * countIf(employment_rate_jul_2025 is null) / nullif(count(),0), 2) as null_pct_employ_jul_2025
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
    countIf(labor_force_parti_rate_2024 < 0 or labor_force_parti_rate_2024 > 100) as invalid_lfp_2024,
    countIf(labor_force_parti_rate_jan_2025 < 0 or labor_force_parti_rate_jan_2025 > 100) as invalid_lfp_jan_2025,
    countIf(labor_force_parti_rate_april_2025 < 0 or labor_force_parti_rate_april_2025 > 100) as invalid_lfp_april_2025,
    countIf(labor_force_parti_rate_july_2025 < 0 or labor_force_parti_rate_july_2025 > 100) as invalid_lfp_july_2025,
    countIf(employment_rate_jul_2024 < 0 or employment_rate_jul_2024 > 100) as invalid_employ_jul_2024,
    countIf(employment_rate_jan_2025 < 0 or employment_rate_jan_2025 > 100) as invalid_employ_jan_2025,
    countIf(employment_rate_april_2025 < 0 or employment_rate_april_2025 > 100) as invalid_employ_april_2025,
    countIf(employment_rate_jul_2025 < 0 or employment_rate_jul_2025 > 100) as invalid_employ_jul_2025
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
    value_ranges.invalid_lfp_2024,
    value_ranges.invalid_lfp_jan_2025,
    value_ranges.invalid_lfp_april_2025,
    value_ranges.invalid_lfp_july_2025,
    value_ranges.invalid_employ_jul_2024,
    value_ranges.invalid_employ_jan_2025,
    value_ranges.invalid_employ_april_2025,
    value_ranges.invalid_employ_jul_2025
  from counts
  cross join nulls
  cross join dupes
  cross join value_ranges
)

select * from joined