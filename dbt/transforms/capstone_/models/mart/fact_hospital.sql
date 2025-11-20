{{ config(
    materialized = "table",
    schema = "mart_grp3"
) }}

WITH

region_lookup AS (
    SELECT
        region_id,
        replaceAll(
            replaceAll(
                replaceAll(upper(trimBoth(region_name)), ' ', ''),
            '-', ''),
        'BARRM','BARMM'
        ) AS cleaned_region
    FROM {{ source('mart_grp3','dim_region') }}
),

-- continue your next CTE...

 psa AS (
    SELECT
        {{ clean_region }} AS region,
        year_2020 AS population_2020,
        year_2024 AS population_2024,
        growth_rate_2020_2024
    FROM clean_grp3.clean_psa_population_growth_rate
    WHERE upper(region) != 'PHILIPPINES'
),

-- ============================================================
-- HOSPITAL COUNTS
-- ============================================================
hosp AS (
    SELECT
        {{ clean_region }} AS region,
        toInt64OrZero(total_hospitals) AS hospital_count
    FROM clean_grp3.clean_doh_hospital_counts
),

-- ============================================================
-- MERGE PSA + HOSP
-- ============================================================
base AS (
    SELECT
        COALESCE(psa.region, hosp.region) AS region,
        psa.population_2020,
        psa.population_2024,
        psa.growth_rate_2020_2024,
        hosp.hospital_count
    FROM psa
    FULL OUTER JOIN hosp ON psa.region = hosp.region
),

-- ============================================================
-- CLEAN REGION FORMAT FOR DIM REGION JOIN
-- ============================================================
fixed AS (
    SELECT
        CASE
            WHEN region = 'IVA' THEN 'IV-A'
            WHEN region = 'IVB' THEN 'IV-B'
            ELSE region
        END AS region_key,
        toInt64(population_2020) AS population_2020,
        toInt64(population_2024) AS population_2024,
        toInt64(hospital_count) AS hospital_count,
        toFloat64(growth_rate_2020_2024) AS growth_rate_2024
    FROM base
),

-- ============================================================
-- REGION FACTS
-- ============================================================
region_facts AS (
    SELECT
        r.region_id,
        r.region_name,

        round(f.growth_rate_2024, 2) AS population_growth_rate,

        round(
            (f.hospital_count / nullIf(f.population_2024, 0)) * 100000,
            2
        ) AS hospital_density,

        r.created_at
    FROM mart_grp3.dim_region r
    LEFT JOIN fixed f
        ON r.region_name = f.region_key
    WHERE r.region_id != 0
),

-- ============================================================
-- NATIONWIDE ROW
-- ============================================================
agg AS (
    SELECT
        sum(population_2020) AS population_2020,
        sum(population_2024) AS population_2024,
        sum(hospital_count) AS hospital_count,
        avg(growth_rate_2024) AS growth_rate_2024
    FROM fixed
),

nationwide AS (
    SELECT
        0 AS region_id,
        'NATIONWIDE' AS region_name,
        round(a.growth_rate_2024, 2) AS population_growth_rate,
        round((a.hospital_count / nullIf(a.population_2024, 0)) * 100000, 2)
            AS hospital_density,
        now() AS created_at
    FROM agg a
),

-- ============================================================
-- NORMALIZATION LIMITS (REGION ONLY)
-- ============================================================
norm AS (
    SELECT
        min(population_growth_rate) AS min_pg,
        max(population_growth_rate) AS max_pg,
        min(hospital_density) AS min_hd,
        max(hospital_density) AS max_hd
    FROM region_facts
),

-- ============================================================
-- REGION SCORES
-- ============================================================
region_scored AS (
    SELECT
        rf.region_id,
        rf.region_name,
        rf.population_growth_rate,
        rf.hospital_density,

        round(
            (rf.population_growth_rate - n.min_pg)
            / nullIf(n.max_pg - n.min_pg, 0),
        2) AS population_score,

        round(
            (rf.hospital_density - n.min_hd)
            / nullIf(n.max_hd - n.min_hd, 0),
        2) AS hospital_density_score,

        rf.created_at
    FROM region_facts rf
    CROSS JOIN norm n
),

-- ============================================================
-- NATIONWIDE SCORES
-- ============================================================
nationwide_scored AS (
    SELECT
        nw.region_id,
        nw.region_name,
        nw.population_growth_rate,
        nw.hospital_density,

        round(
            (nw.population_growth_rate - n.min_pg)
            / nullIf(n.max_pg - n.min_pg, 0),
        2) AS population_score,

        round(
            (nw.hospital_density - n.min_hd)
            / nullIf(n.max_hd - n.min_hd, 0),
        2) AS hospital_density_score,

        nw.created_at
    FROM nationwide nw
    CROSS JOIN norm n
)

-- ============================================================
-- FINAL OUTPUT (region_name removed)
-- ============================================================
SELECT
    toInt32(region_id) AS region_id,
    round(population_growth_rate, 2) AS population_growth_rate,
    round(hospital_density, 2) AS hospital_density,
    round(population_score, 2) AS population_score,
    round(hospital_density_score, 2) AS hospital_density_score
FROM (
    SELECT * FROM nationwide_scored
    UNION ALL
    SELECT * FROM region_scored
)
ORDER BY
    CASE WHEN region_id = 0 THEN 0 ELSE 1 END,
    region_id ASC