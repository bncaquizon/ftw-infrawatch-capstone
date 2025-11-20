{{ config(materialized="table", schema="clean_grp3") }}

WITH source AS (
    SELECT 
        CAST(region AS VARCHAR(20)) AS region,
        CAST(province AS VARCHAR(20)) AS province,
        CAST(province_lgu as VARCHAR(20)) AS province_lgu,
        CAST(_2016 AS NUMERIC(10, 3)) AS _2016,
        CAST(_2017 AS NUMERIC(10, 3)) AS _2017,
        CAST(_2018 AS NUMERIC(10, 3)) AS _2018,
        CAST(_2019 AS NUMERIC(10, 3)) AS _2019,
        CAST(_2020 AS NUMERIC(10, 3)) AS _2020,
        CAST(_2021 AS NUMERIC(10, 3)) AS _2021,
        CAST(_2022 AS NUMERIC(10, 3)) AS _2022,
        CAST(_2023 AS NUMERIC(10, 3)) AS _2023,
        CAST(_2024 AS NUMERIC(10, 3)) AS _2024

    from {{ source('raw_grp3', 'raw___cmci_school') }}
)
,

cleaned as (
    select
        region,
        province,
        province_lgu,
        _2016,
        _2017,
        _2017,
        _2019,
        _2020,
        _2021,
        _2022,
        _2023,
        _2024,


    from source
    where region is not null
      and province is not null
      and province_lgu is not null
      
)

select * from cleaned
