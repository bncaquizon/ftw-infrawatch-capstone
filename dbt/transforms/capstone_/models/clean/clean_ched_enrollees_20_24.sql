{{ config(
    materialized="table",
    schema="clean_grp3"
) }}

-- ============================================================
-- CLEAN CHED ENROLLEES 2020–2024 (FINAL — PER REGION TOTALS)
-- ============================================================

WITH base AS (
    SELECT
        trim(region) AS region_raw,
        trim(hei_type) AS hei_type,
        trim(program_level) AS program_level,

        -- clean numeric columns
        toInt64OrZero(replaceAll(replaceAll(_2020_20201, ',', ''), '-', '0')) AS yr_2020_2021,
        toInt64OrZero(replaceAll(replaceAll(_2021_2022, ',', ''), '-', '0')) AS yr_2021_2022,
        toInt64OrZero(replaceAll(replaceAll(_2022_2023, ',', ''), '-', '0')) AS yr_2022_2023,
        toInt64OrZero(replaceAll(replaceAll(_2023_2024, ',', ''), '-', '0')) AS yr_2023_2024
    FROM {{ source('raw_grp3', 'raw___ched_enrollees_20_24') }}
),

-- ------------------------------------------------------------
-- Extract region name text (remove the number prefix)
-- Example: "01 - Ilocos Region" → "Ilocos Region"
-- ------------------------------------------------------------
parsed AS (
    SELECT
        region_raw,
        trim(splitByChar('-', region_raw)[2]) AS region_name,
        yr_2020_2021,
        yr_2021_2022,
        yr_2022_2023,
        yr_2023_2024
    FROM base
),

-- ------------------------------------------------------------
-- Standardize region names into your 18 region codes
-- ------------------------------------------------------------
standardized AS (
    SELECT
        CASE
            WHEN ilike(region_name, '%capital%') THEN 'NCR'
            WHEN ilike(region_name, '%cordillera%') THEN 'CAR'
            WHEN ilike(region_name, '%ilocos%') THEN 'I'
            WHEN ilike(region_name, '%cagayan%') THEN 'II'
            WHEN ilike(region_name, '%central luzon%') THEN 'III'
            WHEN ilike(region_name, '%calabarzon%') THEN 'IV-A'
            WHEN ilike(region_name, '%mimaropa%') THEN 'IV-B'
            WHEN ilike(region_name, '%bicol%') THEN 'V'
            WHEN ilike(region_name, '%western visayas%') THEN 'VI'
            WHEN ilike(region_name, '%negros%') THEN 'NIR'
            WHEN ilike(region_name, '%central visayas%') THEN 'VII'
            WHEN ilike(region_name, '%eastern visayas%') THEN 'VIII'
            WHEN ilike(region_name, '%zamboanga%') THEN 'IX'
            WHEN ilike(region_name, '%northern mindanao%') THEN 'X'
            WHEN ilike(region_name, '%davao%') THEN 'XI'
            WHEN ilike(region_name, '%soccsksargen%') THEN 'XII'
            WHEN ilike(region_name, '%caraga%') THEN 'XIII'
            WHEN ilike(region_name, '%bangsamoro%') OR ilike(region_name, '%barmm%') THEN 'BARMM'
            WHEN ilike(region_name, '%nationwide%') THEN 'NATIONWIDE'
            ELSE region_name
        END AS region,

        yr_2020_2021,
        yr_2021_2022,
        yr_2022_2023,
        yr_2023_2024
    FROM parsed
),

-- ------------------------------------------------------------
-- Final aggregation: per region totals
-- ------------------------------------------------------------
totals AS (
    SELECT
        region,
        SUM(yr_2020_2021) AS total_2020_2021,
        SUM(yr_2021_2022) AS total_2021_2022,
        SUM(yr_2022_2023) AS total_2022_2023,
        SUM(yr_2023_2024) AS total_2023_2024
    FROM standardized
    GROUP BY region
)

SELECT *
FROM totals
ORDER BY region