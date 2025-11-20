{{ config(materialized="view", schema="mart_grp3") }}

with cln as (
  select * from {{ ref('clean_psa_basic_water_access') }}
),

violations as (
  select
    region,
    safely_managed_waters,
    basic_drinking_water,

    multiIf(
      region is null, 'null_region',

      safely_managed_waters < 0 or basic_drinking_water < 0,
      'negative_water_values',

      safely_managed_waters > 100 or basic_drinking_water > 100,
      'invalid_percentage',

      'ok'
    ) as dq_issue
  from cln
)

select *
from violations
where dq_issue != 'ok'