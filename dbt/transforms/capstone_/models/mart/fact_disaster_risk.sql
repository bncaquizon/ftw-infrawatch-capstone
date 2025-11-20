{{ config(materialized='table', schema='mart_grp3', order_by='region_id') }}

SELECT
    CAST(dr.region_id AS INTEGER) AS region_id,
    SUM(earthquake_score) AS earthquake_score_region,
    SUM(flood_score) AS flood_score_region,
    SUM(storm_score) AS storm_score_region,
    SUM(landslide_score) AS landslide_score_region,
    (earthquake_score_region*0.25 +
     flood_score_region*0.25 +
     storm_score_region*0.25 +
     landslide_score_region*0.25) AS total_disaster_risk_score
FROM 
    (SELECT * FROM {{ ref('clean_pdc_disaster_index') }}) AS pd
    JOIN {{ source('mart_grp3', 'dim_region') }}AS dr
    USING (region_name)
GROUP BY region_id, region_name
