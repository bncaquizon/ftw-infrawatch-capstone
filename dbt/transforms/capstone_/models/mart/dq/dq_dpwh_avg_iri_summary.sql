{{ config(
    materialized = "view",
    schema = "mart_grp3"
) }}

-- Data Quality Summary for DPWH Average IRI
-- Tracks row counts, null %, duplicates, and outlier checks for IRI values.

with rawDs as (
  select * from {{ source('raw_grp3', 'raw___dpwh_avg_iri') }}
),

cln as (
  select * from {{ ref('clean_dpwh_avg_iri') }}
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
    round(100.0 * countIf(avg_iri is null) / nullif(count(),0), 2) as null_pct_avg_iri
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
    countIf(avg_iri < 0) as negative_iri,
    countIf(avg_iri > 20) as outlier_high_iri
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
    value_ranges.negative_iri,
    value_ranges.outlier_high_iri
  from counts
  cross join nulls
  cross join dupes
  cross join value_ranges
)

select * from joined