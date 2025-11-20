{{ config(
    materialized = "view",
    schema = "mart_grp3"
) }}

with rawDs as (
  select *
  from {{ source('raw_grp3', 'raw___ched_enrollees_20_24') }}
),

cln as (
  select *
  from {{ ref('clean_ched_enrollees_20_24') }}
),

counts as (
  select
    (select count() from rawDs) as row_count_raw,
    (select count() from cln)   as row_count_clean
),

nulls as (
  select
    round(100 * countIf(region is null) / nullif(count(),0), 2) as null_pct_region,
    round(100 * countIf(total_2020_2021 is null) / nullif(count(),0), 2) as null_pct_2020_2021,
    round(100 * countIf(total_2021_2022 is null) / nullif(count(),0), 2) as null_pct_2021_2022,
    round(100 * countIf(total_2022_2023 is null) / nullif(count(),0), 2) as null_pct_2022_2023,
    round(100 * countIf(total_2023_2024 is null) / nullif(count(),0), 2) as null_pct_2023_2024
  from cln
),

dupes as (
  select countIf(cnt > 1) as duplicate_regions
  from (select region, count() as cnt from cln group by region)
),

value_ranges as (
  select
    countIf(total_2020_2021 < 0 or total_2021_2022 < 0 or total_2022_2023 < 0 or total_2023_2024 < 0)
      as negative_values,
    countIf(greatest(total_2020_2021,total_2021_2022,total_2022_2023,total_2023_2024) > 5e6)
      as extreme_values
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
