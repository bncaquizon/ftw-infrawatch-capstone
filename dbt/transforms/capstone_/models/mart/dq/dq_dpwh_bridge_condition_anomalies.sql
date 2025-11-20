{{ config(
    materialized = "view",
    schema = "mart_grp3"
) }}

-- Row-level Data Quality Violations for DPWH Bridge Condition
-- Detects missing regions, zero totals, and mismatched percent totals.

with cln as (
  select * 
  from {{ ref('clean_dpwh_bridge_condition') }}
),

violations as (
  select
    region,
    total_good,
    percent_good,
    total_fair,
    percent_fair,
    total_poor,
    percent_poor,
    total_bad,
    percent_bad,
    further_assessment,
    percent_further_assessment,
    grand_total,
    percent_grand_total,

    -- Data Quality Issue Classification
    multiIf(
      region is null, 'null_region',
      grand_total is null, 'null_grand_total',
      grand_total = 0, 'zero_grand_total',
      (percent_good + percent_fair + percent_poor + percent_bad + percent_further_assessment) <> percent_grand_total,
        'percent_total_mismatch',
      total_good < 0 or total_fair < 0 or total_poor < 0 or total_bad < 0, 'negative_bridge_counts',
      percent_good < 0 or percent_fair < 0 or percent_poor < 0 or percent_bad < 0, 'negative_percent',
      percent_grand_total > 100, 'over_100_percent',
      'ok'
    ) as dq_issue

  from cln
)

select *
from violations
where dq_issue != 'ok'
