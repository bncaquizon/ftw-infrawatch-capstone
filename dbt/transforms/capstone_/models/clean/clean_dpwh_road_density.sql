{{ config(
    materialized = "table",
    schema = "clean_grp3",
    engine = "MergeTree()",
    order_by = "region",
    tags=["clean","dpwh"]
) }}

-- Clean Layer: DPWH Road Density
-- Purpose: Standardize road density data for all years 2012–2024.

select
    upper(trim(region)) as region,
    round(cast(`2012` as Float64), 1) as year_2012,
    round(cast(`2013` as Float64), 1) as year_2013,
    round(cast(`2014` as Float64), 1) as year_2014,
    round(cast(`2015` as Float64), 1) as year_2015,
    round(cast(`2016` as Float64), 1) as year_2016,
    round(cast(`2017` as Float64), 1) as year_2017,
    round(cast(`2018` as Float64), 1) as year_2018,
    round(cast(`2019` as Float64), 1) as year_2019,
    round(cast(`2020` as Float64), 1) as year_2020,
    round(cast(`2021` as Float64), 1) as year_2021,
    round(cast(`2022` as Float64), 1) as year_2022,
    round(cast(`2023` as Float64), 1) as year_2023,
    round(cast(`2024` as Float64), 1) as year_2024
from {{ source('raw_grp3', 'raw___dpwh_road_density') }}
where region is not null
