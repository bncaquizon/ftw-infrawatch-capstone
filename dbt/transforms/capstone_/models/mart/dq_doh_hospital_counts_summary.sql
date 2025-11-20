{{ config(enabled=false) }}


with rawDs as (
  select *
  from {{ source('raw_grp3', 'raw___doh_hospital') }}
),

cln as (
  select *
  from {{ ref('clean_doh_hospital_counts') }}
),

counts as (
  select
    (select count() from rawDs) as row_count_raw,
    (select count() from cln)   as row_count_clean
),

nulls as (
  select
    round(100 * countIf(region is null) / nullif(count(),0), 2) as null_pct_region,
    round(100 * countIf(total_hospitals is null) / nullif(count(),0), 2) as null_pct_total
  from cln
),

dupes as (
  select countIf(cnt > 1) as duplicate_regions
  from (select region, count() as cnt from cln group by region)
),

value_ranges as (
  select
    countIf(total_hospitals < 0) as negative_values,
    countIf(total_hospitals > 2000) as extreme_values
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
