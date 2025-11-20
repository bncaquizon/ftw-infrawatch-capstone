{{ config(materialized="view", schema="mart_grp3") }}

with cln as (
  select * from {{ ref('clean_psa_school_counts') }}
),

violations as (
  select
    school_year,
    region,
    total_schools,

    multiIf(
      region is null, 'null_region',
      total_schools < 0, 'negative_school_count',
      total_schools > 100000, 'extreme_school_value',
      'ok'
    ) as dq_issue
  from cln
)

select *
from violations
where dq_issue != 'ok'