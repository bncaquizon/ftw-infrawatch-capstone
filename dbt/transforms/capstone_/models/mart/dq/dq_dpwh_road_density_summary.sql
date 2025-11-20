{{ config(
    materialized = "view",
    schema = "mart_grp3"
) }}

-- Data Quality Summary for DPWH Road Density
-- Tracks row counts (raw vs clean), null %, duplicates, negative densities, and extreme jumps.

with rawDs as (
  select * from {{ source('raw_grp3', 'raw___dpwh_road_density') }}
),

cln as (
  select * from {{ ref('clean_dpwh_road_density') }}
),

-- Row Count Comparison
counts as (
  select
    (select count() from rawDs) as row_count_raw,
    (select count() from cln) as row_count_clean
),

-- Null Percentage Check
nulls as (
  select
    round(100.0 * countIf(region is null)/nullif(count(),0),2) as null_pct_region
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

-- Negative Values & Extreme Year-to-Year Jumps
value_checks as (
  select
    countIf(
      year_2012 < 0 or year_2013 < 0 or year_2014 < 0 or year_2015 < 0 or
      year_2016 < 0 or year_2017 < 0 or year_2018 < 0 or year_2019 < 0 or
      year_2020 < 0 or year_2021 < 0 or year_2022 < 0 or year_2023 < 0 or
      year_2024 < 0
    ) as negative_density,
    countIf(
      greatest(
        abs(year_2012 - year_2013),
        abs(year_2013 - year_2014),
        abs(year_2014 - year_2015),
        abs(year_2015 - year_2016),
        abs(year_2016 - year_2017),
        abs(year_2017 - year_2018),
        abs(year_2018 - year_2019),
        abs(year_2019 - year_2020),
        abs(year_2020 - year_2021),
        abs(year_2021 - year_2022),
        abs(year_2022 - year_2023),
        abs(year_2023 - year_2024)
      ) > 500
    ) as outlier_jump
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
    value_checks.negative_density,
    value_checks.outlier_jump
  from counts
  cross join nulls
  cross join dupes
  cross join value_checks
)

select * from joined