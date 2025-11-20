{{ config(
    materialized = "view",
    schema = "mart_grp3"
) }}

with rawDs as (
  select *
  from {{ source('raw_grp3', 'raw___dpwh_projects') }}
),

cln as (
  select *
  from {{ ref('clean_dpwh_projects') }}
),

counts as (
  select
    (select count() from rawDs) as row_count_raw,
    (select count() from cln)   as row_count_clean
),

nulls as (
  select
    round(100 * countIf(region is null) / nullif(count(),0), 2) as null_pct_region,
    round(100 * countIf(project_count is null) / nullif(count(),0), 2) as null_pct_project_count,
    round(100 * countIf(total_contract_cost is null) / nullif(count(),0), 2) as null_pct_cost,
    round(100 * countIf(avg_pct_complete is null) / nullif(count(),0), 2) as null_pct_pct_complete
  from cln
),

dupes as (
  select countIf(cnt > 1) as duplicate_regions
  from (select region, count() as cnt from cln group by region)
),

value_ranges as (
  select
    countIf(project_count < 0) as negative_projects,
    countIf(total_contract_cost < 0) as negative_cost,
    countIf(avg_pct_complete < 0 or avg_pct_complete > 100) as invalid_pct_complete,
    countIf(total_contract_cost > 1e12) as extreme_cost
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