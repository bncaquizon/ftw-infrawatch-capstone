{{ config(
    materialized = "view",
    schema = "mart_grp3"
) }}

with cln as (
    select *
    from {{ ref('clean_psa_school_counts') }}
),

counts as (
    select
        0 as row_count_raw,
        (select count() from cln) as row_count_clean
),

nulls as (
    select
        round(100 * countIf(region is null) / nullif(count(), 0), 2) as null_pct_region,
        round(100 * countIf(school_year is null) / nullif(count(), 0), 2) as null_pct_school_year,
        round(100 * countIf(total_schools is null) / nullif(count(), 0), 2) as null_pct_total_schools
    from cln
),

dupes as (
    select countIf(cnt > 1) as duplicate_region_year
    from (
        select region, school_year, count() as cnt
        from cln
        group by region, school_year
    )
),

value_ranges as (
    select
        countIf(total_schools < 0) as negative_values,
        countIf(total_schools > 100000) as extreme_values
    from cln
),

joined as (
    select
        counts.row_count_raw,
        counts.row_count_clean,
        nulls.null_pct_region,
        nulls.null_pct_school_year,
        nulls.null_pct_total_schools,
        dupes.duplicate_region_year,
        value_ranges.negative_values,
        value_ranges.extreme_values
    from counts
    cross join nulls
    cross join dupes
    cross join value_ranges
)

select *
from joined