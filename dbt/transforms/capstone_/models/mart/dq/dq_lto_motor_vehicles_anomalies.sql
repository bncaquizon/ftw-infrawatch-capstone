{{ config(
    materialized = "view",
    schema = "mart_grp3"
) }}

-- Row-level Data Quality Violations for LTO Motor Vehicle Registrations
-- Detects missing regions, negative registrations, and extreme percent changes.

with cln as (
  select * 
  from {{ ref('clean_lto_motor_vehicles') }}
),

violations as (
  select
    region,
    motor_vehi_reg_2022,
    motor_vehi_reg_2023,
    motor_vehi_reg_2024,
    percent_inc_dec_2022_2023,
    percent_inc_dec_2023_2024,

    -- Data Quality Issue Classification
    multiIf(
      region is null, 'null_region',
      motor_vehi_reg_2022 < 0 or motor_vehi_reg_2023 < 0 or motor_vehi_reg_2024 < 0, 'negative_registration',
      percent_inc_dec_2022_2023 < -100 or percent_inc_dec_2022_2023 > 500, 'outlier_growth_2022_2023',
      percent_inc_dec_2023_2024 < -100 or percent_inc_dec_2023_2024 > 500, 'outlier_growth_2023_2024',
      'ok'
    ) as dq_issue

  from cln
)

select *
from violations
where dq_issue != 'ok'