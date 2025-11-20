{{ config(
    materialized = "table", 
    schema = "mart_grp3",
    engine = "MergeTree()",
    order_by = "region_id"
) }}

WITH hosp AS (
    SELECT
        region_id,
        toFloat64(coalesce(population_score, 0)) AS population_score,
        toFloat64(coalesce(hospital_density_score, 0)) AS hospital_density_score
    FROM {{ source('mart_grp3', 'fact_hospital') }}
),
water AS (
    SELECT
        region_id,
        toFloat64(coalesce(normalized_score, 0)) AS water_access_score
    FROM {{ source('mart_grp3', 'fact_water_access') }}
),
school AS (
    SELECT
        region_id,
        toFloat64(coalesce(normalized_score, 0)) AS school_score
    FROM {{ source('mart_grp3', 'fact_schools') }}
),
combined AS (
    SELECT
        r.region_id AS region_id,
        coalesce(h.population_score, 0) AS population_score,
        coalesce(h.hospital_density_score, 0) AS hospital_density_score,
        coalesce(w.water_access_score, 0) AS water_access_score,
        coalesce(s.school_score, 0) AS school_score
    FROM {{ ref('dim_region') }} r
    LEFT JOIN hosp h ON r.region_id = h.region_id
    LEFT JOIN water w ON r.region_id = w.region_id
    LEFT JOIN school s ON r.region_id = s.region_id
    WHERE r.region_id <> 0
),
scored AS (
    SELECT
        region_id,
        population_score,
        hospital_density_score,
        water_access_score,
        school_score,
        ROUND(
            population_score * 0.10 +
            hospital_density_score * 0.30 +
            water_access_score * 0.30 +
            school_score * 0.30
        , 2) * 100 AS social_service_score
    FROM combined
)

SELECT
    region_id,
    population_score,
    hospital_density_score,
    water_access_score,
    school_score,
    social_service_score,
    DENSE_RANK() OVER (ORDER BY social_service_score DESC) AS social_service_rank
FROM scored
ORDER BY social_service_rank