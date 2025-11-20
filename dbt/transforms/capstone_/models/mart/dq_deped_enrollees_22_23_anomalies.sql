{{ config(materialized="view", schema="mart_grp3") }}

with cln as (
  select * from {{ ref('clean_deped_enrollees_22_23') }}
),

violations as (
  select
    region,
    enrollees_22_23,

    multiIf(
      region is null, 'null_region',
      enrollees_22_23 < 0, 'negative_enrollees',
      enrollees_22_23 > 5e6, 'extreme_enrollee_value',
      'ok'
    ) as dq_issue
  from cln
)

select *
from violations
where dq_issue != 'ok'