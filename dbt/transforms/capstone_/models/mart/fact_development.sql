{{ config(
    materialized = "table",
    schema = "mart_grp3",
    engine = "MergeTree()",
    order_by = "region_id",
    tags = ["mart", "development"]
) }}

WITH rgdp AS (
    SELECT 
        upper(trim(region)) AS region,
        [year_2022, year_2023, year_2024] AS gross,
        [growth_rate_2022_2023, growth_rate_2023_2024] AS gross_growth
    FROM {{ ref('clean_psa_grdp_per_capita') }}
),

density AS (
    SELECT
        upper(trim(region)) AS region,
        urban_pop_growth_2010_2020
    FROM {{ ref('clean_psa_population_density') }}
),

labor AS (
    SELECT
        upper(trim(region)) AS region,
        [labor_force_parti_rate_2024, labor_force_parti_rate_jan_2025, labor_force_parti_rate_april_2025, labor_force_parti_rate_july_2025] AS labor_force,
        employment_rate_jul_2025
    FROM {{ ref('clean_psa_labor_force_participation') }}
),

economic_dyna AS (
    SELECT
        upper(trim(region)) AS region,

        -- ARRAY OF AGGREGATED VALUES
        [
            avg(_2016),
            avg(_2017),
            avg(_2019),
            avg(_2020),
            avg(_2021),
            avg(_2022),
            avg(_2023),
            avg(_2024)
        ] AS values_2016_2024,

        -- AVERAGE OF THE AGGREGATED YEARLY VALUES
        ROUND((
            avg(_2016) +
            avg(_2017) +
            avg(_2019) +
            avg(_2020) +
            avg(_2021) +
            avg(_2022) +
            avg(_2023) +
            avg(_2024)
        ) / 8.0, 3) AS avg_2016_2024

    FROM {{ source('clean_grp3', 'clean_cmci_economicdyna') }}
    GROUP BY region
),

combined AS (
    SELECT
        g.region AS region,
        ROUND((g.gross[1] + g.gross[2] + g.gross[3]) / 3.0, 2) AS avg_rgdp_pc_2022_2024,
        ROUND((g.gross_growth[1] + g.gross_growth[2]) / 2.0, 2) AS avg_rgdp_pc_gr_2022_2024,
        ROUND(d.urban_pop_growth_2010_2020, 2) AS urban_pop_growth_2010_2020,
        ROUND((l.labor_force[1] + l.labor_force[2] + l.labor_force[3] + l.labor_force[4]) / 4.0, 2) AS avg_labor_force_participation_2024_2025,
        ROUND(l.employment_rate_jul_2025, 2) AS employment_rate_2025,
        ROUND(e.avg_2016_2024, 2) AS economic_dynamism_2016_2024
    FROM rgdp g
    LEFT JOIN density d ON g.region = d.region
    LEFT JOIN labor l ON d.region = l.region
    LEFT JOIN economic_dyna e ON l.region = e.region
),

-- Step 1: compute normalized scores
normalized AS (
    SELECT
        r.region_id,
        c.avg_rgdp_pc_2022_2024,
        c.avg_rgdp_pc_gr_2022_2024,
        c.urban_pop_growth_2010_2020,
        c.economic_dynamism_2016_2024,
        c.employment_rate_2025,
        c.avg_labor_force_participation_2024_2025,

        ROUND((c.avg_rgdp_pc_2022_2024 - MIN(c.avg_rgdp_pc_2022_2024) OVER ()) /
              NULLIF(MAX(c.avg_rgdp_pc_2022_2024) OVER () - MIN(c.avg_rgdp_pc_2022_2024) OVER (), 0), 2) AS rgdp_score,

        ROUND((c.avg_rgdp_pc_gr_2022_2024 - MIN(c.avg_rgdp_pc_gr_2022_2024) OVER ()) /
              NULLIF(MAX(c.avg_rgdp_pc_gr_2022_2024) OVER () - MIN(c.avg_rgdp_pc_gr_2022_2024) OVER (), 0), 2) AS rgdp_growth_score,

        ROUND((MAX(c.urban_pop_growth_2010_2020) OVER () - c.urban_pop_growth_2010_2020) /
              NULLIF(MAX(c.urban_pop_growth_2010_2020) OVER () - MIN(c.urban_pop_growth_2010_2020) OVER (), 0), 2) AS urban_pop_growth_score,

        ROUND((c.economic_dynamism_2016_2024 - MIN(c.economic_dynamism_2016_2024) OVER ()) /
              NULLIF(MAX(c.economic_dynamism_2016_2024) OVER () - MIN(c.economic_dynamism_2016_2024) OVER (), 0), 2) AS economic_dynamism_score,

        ROUND((c.employment_rate_2025 - MIN(c.employment_rate_2025) OVER ()) /
              NULLIF(MAX(c.employment_rate_2025) OVER () - MIN(c.employment_rate_2025) OVER (), 0), 2) AS employment_score

    FROM {{ ref('dim_region') }} r
    LEFT JOIN combined c ON r.region_name = c.region
    WHERE r.region_id <> 0
)

-- Step 2: compute weighted development indicator and rank
SELECT
    *,
    ROUND(
        (rgdp_score * 0.35 +
         rgdp_growth_score * 0.25 +
         urban_pop_growth_score * 0.20 +
         economic_dynamism_score * 0.10 +
         employment_score * 0.10) * 100, 1
    ) AS development_indicator_score,

    DENSE_RANK() OVER (
        ORDER BY
            (rgdp_score * 0.35 +
             rgdp_growth_score * 0.25 +
             urban_pop_growth_score * 0.20 +
             economic_dynamism_score * 0.10 +
             employment_score * 0.10) DESC
    ) AS development_indicator_rank

FROM normalized
ORDER BY development_indicator_rank
