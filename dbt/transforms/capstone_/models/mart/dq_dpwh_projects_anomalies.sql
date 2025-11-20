{{ config(materialized="view", schema="mart_grp3") }}

with cln as (
  select * from {{ ref('clean_dpwh_projects') }}
),

violations as (
  select
    region,
    project_count,
    total_contract_cost,
    avg_pct_complete,

    multiIf(
      region is null, 'null_region',

      project_count < 0, 'negative_project_count',
      total_contract_cost < 0, 'negative_cost',
      avg_pct_complete < 0 or avg_pct_complete > 100, 'invalid_pct_complete',

      total_contract_cost > 1e12, 'extreme_contract_cost',

      'ok'
    ) as dq_issue
  from cln
)

select *
from violations
where dq_issue != 'ok'