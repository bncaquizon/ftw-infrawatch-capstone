{{ config(materialized='table') }}

with motor_vehicles as (
    select 
        region_id,
        motor_vehi_reg_2024
    from {{ source('mart_grp3', 'dim_region') }} 
    left join {{ source('clean_grp3', 'clean_lto_motor_vehicles') }} 
        on clean_lto_motor_vehicles.region = dim_region.region_name
),
avg_iri as (
    select 
        region_id,
        avg_iri
    from {{ source('mart_grp3', 'dim_region') }} 
    left join {{ source('clean_grp3', 'clean_dpwh_avg_iri') }} 
        on clean_dpwh_avg_iri.region = dim_region.region_name
),
road_density as (
    select 
        region_id,
        year_2024 as road_density
    from {{ source('mart_grp3', 'dim_region') }} 
    left join {{ source('clean_grp3', 'clean_dpwh_road_density') }} 
        on clean_dpwh_road_density.region = dim_region.region_name
),
bridge_condition as (
    select 
        region_id,
        round(
            case 
                when grand_total = 0 then null
                else (total_poor + total_bad) / grand_total
            end, 2
        ) as percent_bad_total
    from {{ source('mart_grp3', 'dim_region') }} 
    left join {{ source('clean_grp3', 'clean_dpwh_bridge_condition') }} 
        on clean_dpwh_bridge_condition.region = dim_region.region_name
),
base as (
    select
        dim_region.region_id as region_id,
        coalesce(motor_vehicles.motor_vehi_reg_2024, 0) as motor_vehi_reg_2024,
        coalesce(avg_iri.avg_iri, 0) as avg_iri,
        coalesce(road_density.road_density, 0) as road_density,
        bridge_condition.percent_bad_total as percent_bad_total
    from {{ source('mart_grp3', 'dim_region') }} dim_region
    left join motor_vehicles
        on dim_region.region_id = motor_vehicles.region_id
    left join avg_iri
        on dim_region.region_id = avg_iri.region_id
    left join road_density
        on dim_region.region_id = road_density.region_id
    left join bridge_condition
        on dim_region.region_id = bridge_condition.region_id
    where dim_region.region_id != '0'
),
min_max as (
    select
        min(motor_vehi_reg_2024) as min_motor_vehi_reg,
        max(motor_vehi_reg_2024) as max_motor_vehi_reg,
        min(avg_iri) as min_avg_iri,
        max(avg_iri) as max_avg_iri,
        min(road_density) as min_road_density,
        max(road_density) as max_road_density
    from base
)

select
    b.region_id,
    b.motor_vehi_reg_2024,
    b.avg_iri,
    b.road_density,
    b.percent_bad_total,
    round(
        (b.motor_vehi_reg_2024 - m.min_motor_vehi_reg) 
        / if(m.max_motor_vehi_reg - m.min_motor_vehi_reg = 0, NULL, m.max_motor_vehi_reg - m.min_motor_vehi_reg) * 100, 
        2
    ) as motor_vehi_reg_2024_score,
    round(
        (b.avg_iri - m.min_avg_iri) 
        / if(m.max_avg_iri - m.min_avg_iri = 0, NULL, m.max_avg_iri - m.min_avg_iri) * 100, 
        2
    ) as avg_iri_score,
    round(
        (m.max_road_density - b.road_density) 
        / if(m.max_road_density - m.min_road_density = 0, NULL, m.max_road_density - m.min_road_density) * 100, 
        2
    ) as road_density_score,
    round(
        ( (b.motor_vehi_reg_2024 - m.min_motor_vehi_reg) 
            / if(m.max_motor_vehi_reg - m.min_motor_vehi_reg = 0, NULL, m.max_motor_vehi_reg - m.min_motor_vehi_reg) * 100 * 0.4
          + (b.avg_iri - m.min_avg_iri) 
            / if(m.max_avg_iri - m.min_avg_iri = 0, NULL, m.max_avg_iri - m.min_avg_iri) * 100 * 0.35
          + (m.max_road_density - b.road_density) 
            / if(m.max_road_density - m.min_road_density = 0, NULL, m.max_road_density - m.min_road_density) * 0.25
        ), 2
    ) as transport_indicator_score,
    rank() over (order by 
        round(
            ( (b.motor_vehi_reg_2024 - m.min_motor_vehi_reg) 
                / if(m.max_motor_vehi_reg - m.min_motor_vehi_reg = 0, NULL, m.max_motor_vehi_reg - m.min_motor_vehi_reg) * 100 * 0.4
              + (b.avg_iri - m.min_avg_iri) 
                / if(m.max_avg_iri - m.min_avg_iri = 0, NULL, m.max_avg_iri - m.min_avg_iri) * 100 * 0.35
              + (m.max_road_density - b.road_density) 
                / if(m.max_road_density - m.min_road_density = 0, NULL, m.max_road_density - m.min_road_density) * 0.25
            ), 2
        ) desc
    ) as transport_indicator_rank
from base b
cross join min_max m
order by b.region_id