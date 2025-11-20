{{ config(
    materialized = "view",
    schema = "mart_grp3"
) }}

-- Data Quality Summary for LTO Motor Vehicle Registrations
-- Tracks row counts, null %, duplicates, and outlier registration/growth values.

with rawDs as (
  select * from {{ source('raw_grp3', 'raw___lto_motor_vehicles') }}
),

cln as (
  select * from {{ ref('clean_lto_motor_vehicles') }}
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
    round(100.0 * countIf(motor_vehi_reg_2022 is null) / nullif(count(),0), 2) as null_pct_2022,
    round(100.0 * countIf(motor_vehi_reg_2023 is null) / nullif(count(),0), 2) as null_pct_2023,
    round(100.0 * countIf(motor_vehi_reg_2024 is null) / nullif(count(),0), 2) as null_pct_2024
  from cln
),

-- Duplicate Region Check
dupes as (
  select
    countIf(cnt > 1) as duplicate_regions
  from (
    select region, count() as cnt
    from cln
    group by region
  )
),

-- Value Range and Outlier Checks
value_ranges as (
  select
    countIf(motor_vehi_reg_2022 < 0 or motor_vehi_reg_2023 < 0 or motor_vehi_reg_2024 < 0) as negative_registration,
    countIf(percent_inc_dec_2022_2023 < -100 or percent_inc_dec_2022_2023 > 500) as outlier_growth_2022_2023,
    countIf(percent_inc_dec_2023_2024 < -100 or percent_inc_dec_2023_2024 > 500) as outlier_growth_2023_2024
  from cln
),

-- Combine All Metrics
joined as (
  select
    counts.row_count_raw,
    counts.row_count_clean,
    (counts.row_count_raw - counts.row_count_clean) as dropped_rows,
    nulls.*,
    dupes.duplicate_regions,
    value_ranges.negative_registration,
    value_ranges.outlier_growth_2022_2023,
    value_ranges.outlier_growth_2023_2024
  from counts
  cross join nulls
  cross join dupes
  cross join value_ranges
)

select * from joined