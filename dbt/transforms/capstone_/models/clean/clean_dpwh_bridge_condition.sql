{{ config(
    materialized = "table",
    schema = "clean_grp3",
    engine = "MergeTree()",
    order_by = "region",
    tags=["clean","dpwh"]
) }}

-- Clean layer: DPWH Bridge Condition
-- Purpose: Standardize numeric types and region names

select
    trim(region) as region,
    round(cast(total_good as Float64), 1) as total_good,
    round(cast(percent_good as Float64), 1) as percent_good,
    round(cast(total_fair as Float64), 1) as total_fair,
    round(cast(percent_fair as Float64), 1) as percent_fair,
    round(cast(total_poor as Float64), 1) as total_poor,
    round(cast(percent_poor as Float64), 1) as percent_poor,
    round(cast(total_bad as Float64), 1) as total_bad,
    round(cast(percent_bad as Float64), 1) as percent_bad,
    round(cast(further_assessment as Float64), 1) as further_assessment,
    round(cast(percent_further_assessment as Float64), 1) as percent_further_assessment,
    round(cast(grand_total as Float64), 1) as grand_total,
    round(cast(percent_grand_total as Float64), 1) as percent_grand_total
from {{ source('raw_grp3', 'raw___dpwh_bridge_condition') }}