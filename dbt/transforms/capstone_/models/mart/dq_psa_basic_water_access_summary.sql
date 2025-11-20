
{{ config(
    materialized = "view",
    schema = "mart_grp3"
) }}

with rawDs as (
  select *
  from {{ source('raw_grp3', 'raw___psa_basic_water_access') }}
),

cln as (
  select *
  from {{ ref('clean_psa_basic_water_access') }}
),

counts as (
  select
    (select count() from rawDs) as row_count_raw,
    (select count() from cln)   as row_count_clean
),

nulls as (
  select
    round(100 * countIf(region is null) / nullif(count(),0), 2) as null_pct_region,
    round(100 * countIf(safely_managed_waters is null) / nullif(count(),0), 2) as null_pct_safely,
    round(100 * countIf(basic_drinking_water is null) / nullif(count(),0), 2) as null_pct_basic
  from cln
),

dupes as (
  select countIf(cnt > 1) as duplicate_regions
  from (select region, count() as cnt from cln group by region)
),

value_ranges as (
  select
    countIf(safely_managed_waters < 0 or basic_drinking_water < 0) as negative_values,
    countIf(safely_managed_waters > 100 or basic_drinking_water > 100) as invalid_percentages
  from cln
),

joined as (
  select
    row_count_raw,
    row_count_clean,
    row_count_raw - row_count_clean as dropped_rows,
    nulls.*,
    dupes.duplicate_regions,
    value_ranges.*
  from counts
  cross join nulls
  cross join dupes
  cross join value_ranges
)

select * from joined