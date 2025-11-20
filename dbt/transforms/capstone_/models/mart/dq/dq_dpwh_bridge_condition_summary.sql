{{ config(
    materialized = "view",
    schema = "mart_grp3"
) }}

-- Data Quality Summary for DPWH Bridge Condition
-- Tracks row counts, null %, duplicates, and outlier or invalid percent checks.

with rawDs as (
  select * from {{ source('raw_grp3', 'raw___dpwh_bridge_condition') }}
),

cln as (
  select * from {{ ref('clean_dpwh_bridge_condition') }}
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
    round(100.0 * countIf(grand_total is null) / nullif(count(),0), 2) as null_pct_grand_total
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

-- Value Validity Checks
value_checks as (
  select
    countIf(grand_total = 0) as zero_grand_total,
    countIf(total_good < 0 or total_fair < 0 or total_poor < 0 or total_bad < 0) as negative_bridge_counts,
    countIf(percent_good < 0 or percent_fair < 0 or percent_poor < 0 or percent_bad < 0) as negative_percent,
    countIf(percent_grand_total > 100) as over_100_percent,
    countIf(
      (percent_good + percent_fair + percent_poor + percent_bad + percent_further_assessment) <> percent_grand_total
    ) as percent_total_mismatch
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
    value_checks.zero_grand_total,
    value_checks.negative_bridge_counts,
    value_checks.negative_percent,
    value_checks.over_100_percent,
    value_checks.percent_total_mismatch
  from counts
  cross join nulls
  cross join dupes
  cross join value_checks
)

select * from joined