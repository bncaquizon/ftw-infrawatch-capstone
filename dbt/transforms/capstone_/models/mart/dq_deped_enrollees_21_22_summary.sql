{{ config(
    materialized = "view",
    schema = "mart_grp3"
) }}

with rawDs as (
  select *
  from {{ source('raw_grp3', 'raw___deped_enrollees_21_22') }}
),

cln as (
  select *
  from {{ ref('clean_deped_enrollees_21_22') }}
),

counts as (
  select
    (select count() from rawDs) as row_count_raw,
    (select count() from cln)   as row_count_clean
),

nulls as (
  select
    round(100 * countIf(region is null) / nullif(count(),0), 2) as null_pct_region,
    round(100 * countIf(enrollees_21_22 is null) / nullif(count(),0), 2) as null_pct_enrollees
  from cln
),

dupes as (
  select
    countIf(cnt > 1) as duplicate_regions
  from (
    select region, count() as cnt
    from cln
    group by region
  )
),

value_ranges as (
  select
    countIf(enrollees_21_22 < 0) as negative_enrollees,
    countIf(enrollees_21_22 > 5e6) as extreme_enrollees
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
