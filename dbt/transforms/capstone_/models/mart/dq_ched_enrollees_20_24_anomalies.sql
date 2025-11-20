{{ config(materialized="view", schema="mart_grp3") }}

with cln as (
  select * from {{ ref('clean_ched_enrollees_20_24') }}
),

violations as (
  select
    region,
    total_2020_2021,
    total_2021_2022,
    total_2022_2023,
    total_2023_2024,

    multiIf(
      region is null, 'null_region',

      total_2020_2021 < 0 or 
      total_2021_2022 < 0 or
      total_2022_2023 < 0 or
      total_2023_2024 < 0,
      'negative_enrollees',

      greatest(
        total_2020_2021,
        total_2021_2022,
        total_2022_2023,
        total_2023_2024
      ) > 5e6, 
      'extreme_enrollee_value',

      'ok'
    ) as dq_issue
  from cln
)

select *
from violations
where dq_issue != 'ok'
