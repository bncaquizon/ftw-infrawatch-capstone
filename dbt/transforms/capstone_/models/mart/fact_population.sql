{{ config(
    materialized = "table",
    schema = "mart_grp3",
    engine = "MergeTree()",
    order_by = "region_id",
    tags = ["mart", "population"]
) }}

WITH growth AS (
    SELECT 
        upper(trim(region)) AS region,
        [year_2010, year_2015, year_2020, year_2024] AS populations,
        [growth_rate_2010_2015, growth_rate_2015_2020, growth_rate_2020_2024, growth_rate_2015_2024] AS population_growth
    FROM {{ ref('clean_psa_population_growth_rate') }}
),

density AS (
    SELECT
        upper(trim(region)) AS region,
        [population_density_2010, population_density_2015, population_density_2020, population_density_2024] AS population_density,
        land_area,
        density_growth_rate_2010_2024
    FROM {{ ref('clean_psa_population_density') }}
),

combined AS (
    SELECT
        g.region,
        cast(g.populations[4] AS UInt32) AS population_2024,
        round(cast(((g.population_growth[1] + g.population_growth[2] + g.population_growth[3] + g.population_growth[4]) / 4.0) AS Float32), 2) AS avg_population_growth_rate_2010_2024,
        round(cast(d.land_area AS Float32), 2) AS land_area,
        round(cast(((d.population_density[1] + d.population_density[2] + d.population_density[3] + d.population_density[4]) / 4.0) AS Float32), 2) AS avg_population_density_2010_2024,
        round(cast(d.density_growth_rate_2010_2024 AS Float32), 2) AS density_growth_rate_2010_2024
    FROM growth g
    LEFT JOIN density d ON g.region = d.region
),

-- Step 1: compute normalized scores in subquery
normalized AS (
    SELECT
        r.region_id,
        c.population_2024,
        c.avg_population_growth_rate_2010_2024,
        c.land_area,
        c.avg_population_density_2010_2024,
        c.density_growth_rate_2010_2024,

        -- Normalized scores (rounded to 2 decimals)
        ROUND(
            (c.population_2024 - MIN(c.population_2024) OVER ()) /
            NULLIF(MAX(c.population_2024) OVER () - MIN(c.population_2024) OVER (), 0),
            2
        ) AS population_score,

        ROUND(
            (c.avg_population_growth_rate_2010_2024 - MIN(c.avg_population_growth_rate_2010_2024) OVER ()) /
            NULLIF(MAX(c.avg_population_growth_rate_2010_2024) OVER () - MIN(c.avg_population_growth_rate_2010_2024) OVER (), 0),
            2
        ) AS growth_rate_score,

        ROUND(
            (CAST(MAX(c.land_area) OVER () - c.land_area AS Float32)) /
            NULLIF(MAX(c.land_area) OVER () - MIN(c.land_area) OVER (), 0),
            2
        ) AS land_area_score,

        ROUND(
            (c.avg_population_density_2010_2024 - MIN(c.avg_population_density_2010_2024) OVER ()) /
            NULLIF(MAX(c.avg_population_density_2010_2024) OVER () - MIN(c.avg_population_density_2010_2024) OVER (), 0),
            2
        ) AS density_score,

        ROUND(
            (c.density_growth_rate_2010_2024 - MIN(c.density_growth_rate_2010_2024) OVER ()) /
            NULLIF(MAX(c.density_growth_rate_2010_2024) OVER () - MIN(c.density_growth_rate_2010_2024) OVER (), 0),
            2
        ) AS density_growth_score

    FROM {{ ref('dim_region') }} r
    LEFT JOIN combined c ON r.region_name = c.region
    WHERE r.region_id <> 0
)

-- Step 2: compute weighted score and dense rank in outer query
SELECT
    *,
    ROUND(
        (population_score * 0.30 +
         growth_rate_score * 0.25 +
         land_area_score * 0.20 +
         density_score * 0.15 +
         density_growth_score * 0.10) * 100, 1
    ) AS population_indicator_score,

    DENSE_RANK() OVER (
        ORDER BY
            (population_score * 0.30 +
             growth_rate_score * 0.25 +
             land_area_score * 0.20 +
             density_score * 0.15 +
             density_growth_score * 0.10) DESC
    ) AS population_indicator_rank

FROM normalized
ORDER BY population_indicator_rank