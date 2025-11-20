{{ config(
    materialized = "table",
    schema = "mart_grp3",
    engine = "MergeTree()",
    order_by = "region_id",
    tags = ["mart", "major_indicator"]
) }}

-- Step 0: Load raw scores from source tables
WITH pop AS (
    SELECT 
        region_id AS region_id,
        population_indicator_score AS population_score
    FROM {{ source('mart_grp3', 'fact_population') }}
),

dev AS (
    SELECT 
        region_id AS region_id,
        development_indicator_score AS development_score
    FROM {{ source('mart_grp3', 'fact_development') }}
),

dis AS (
    SELECT 
        region_id AS region_id,
        total_disaster_risk_score AS disaster_risk_score
    FROM {{ source('mart_grp3', 'fact_disaster_risk') }}
),

trans AS (
    SELECT 
        region_id AS region_id,
        transport_indicator_score AS transport_score
    FROM {{ source('mart_grp3', 'fact_transport') }}
),

social AS (
    SELECT 
        region_id AS region_id,
        social_service_score AS social_service_score
    FROM {{ source('mart_grp3', 'fact_social_services') }}
), 

-- Step 1: Combine all scores per region
combined AS (
    SELECT
        r.region_id AS region_id,
        coalesce(p.population_score, 0) AS population_score,
        coalesce(d.development_score, 0) AS development_score,
        coalesce(dis.disaster_risk_score, 0) AS disaster_risk_score,
        coalesce(t.transport_score, 0) AS transport_score,
        coalesce(s.social_service_score, 0) AS social_services_score
    FROM {{ ref('dim_region') }} r
    LEFT JOIN pop p ON r.region_id = p.region_id
    LEFT JOIN dev d ON r.region_id = d.region_id
    LEFT JOIN dis ON r.region_id = dis.region_id
    LEFT JOIN trans t ON r.region_id = t.region_id
    LEFT JOIN social s ON r.region_id = s.region_id
    WHERE r.region_id <> 0
)

-- Step 2: Compute weighted final score and dense rank
SELECT
    region_id,
    population_score,
    development_score,
    disaster_risk_score,
    transport_score,
    social_services_score,
    ROUND(
        (population_score * 0.25 +
         development_score * 0.20 +
         disaster_risk_score * 0.25 +
         transport_score * 0.20 +
         social_services_score * 0.10), 2
    ) AS final_score,
    DENSE_RANK() OVER (
        ORDER BY
            (population_score * 0.25 +
             development_score * 0.20 +
             disaster_risk_score * 0.25 +
             transport_score * 0.20 + 
             social_services_score * 0.10) DESC
    ) AS indicator_rank
FROM combined
ORDER BY indicator_rank