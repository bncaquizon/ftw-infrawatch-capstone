{{ config(
    materialized = "table",
    schema = "clean_grp3",
    engine = "MergeTree()",
    order_by = "region",
    tags=["clean", "psa"]
) }}

-- Clean Layer: LTO Motor Vehicles
-- Purpose: Standardize motor vehicle registration data for trend analysis (2022–2024)

select
    upper(trim(region)) as region,
    cast(motor_vehi_reg_2022 as Int64) as motor_vehi_reg_2022,
    cast(motor_vehi_reg_2023 as Int64) as motor_vehi_reg_2023,
    cast(motor_vehi_reg_2024 as Int64) as motor_vehi_reg_2024,
    cast(percent_inc_dec_2022_2023 as Float64) as percent_inc_dec_2022_2023,
    cast(percent_inc_dec_2023_2024 as Float64) as percent_inc_dec_2023_2024
from {{ source('raw_grp3', 'raw___lto_motor_vehicles') }}