{{ config(
    materialized="table",
    schema="clean_grp3"
) }}

WITH base AS (
    SELECT
        trim(regions) AS region_name,
        toInt64OrZero(replaceAll(enrollees_21_22, ',', '')) AS enrollees_21_22
    FROM {{ source('raw_grp3', 'raw___deped_enrollees_21_22') }}
),

-- ------------------------------------------------------------
-- Standardize region names
-- ------------------------------------------------------------
standardized AS (
    SELECT
        CASE
            ------------------------------------------------------------------
            -- TREAT TOTAL, NULL, BLANK, NATIONWIDE AS "NATIONWIDE"
            ------------------------------------------------------------------
            WHEN region_name IS NULL THEN 'NATIONWIDE'
            WHEN trim(region_name) = '' THEN 'NATIONWIDE'
            WHEN ilike(region_name, '%total%') THEN 'NATIONWIDE'
            WHEN ilike(region_name, '%nationwide%') THEN 'NATIONWIDE'
            WHEN ilike(region_name, '%overall%') THEN 'NATIONWIDE'
            WHEN ilike(region_name, '%philippines%') THEN 'NATIONWIDE'
            WHEN ilike(region_name, '%all%regions%') THEN 'NATIONWIDE'

            ------------------------------------------------------------------
            -- REGION NAME MATCHES
            ------------------------------------------------------------------
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
            WHEN ilike(region_name, '%bangsamoro%')
              OR ilike(region_name, '%barmm%')
              OR ilike(region_name, '%baarm%')
                THEN 'BARMM'

            ------------------------------------------------------------------
            -- DIRECT FIXES
            ------------------------------------------------------------------
            WHEN upper(region_name) = 'IVA' THEN 'IV-A'
            WHEN upper(region_name) = 'IV-A' THEN 'IV-A'
            WHEN upper(region_name) = 'IVB' THEN 'IV-B'
            WHEN upper(region_name) = 'IV-B' THEN 'IV-B'
            WHEN upper(region_name) = 'BAARM' THEN 'BARMM'
            WHEN upper(region_name) = 'BARMM' THEN 'BARMM'

            ELSE region_name
        END AS region,
        enrollees_21_22
    FROM base
),

-- ------------------------------------------------------------
-- Final totals
-- ------------------------------------------------------------
totals AS (
    SELECT
        region,
        SUM(enrollees_21_22) AS total_2021_2022
    FROM standardized
    GROUP BY region
)

SELECT *
FROM totals
ORDER BY 
    region = 'NATIONWIDE' DESC,   -- ⭐ Always put nationwide first
    region ASC
