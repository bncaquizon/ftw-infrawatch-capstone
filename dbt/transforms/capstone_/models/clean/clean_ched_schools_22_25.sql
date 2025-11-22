{{ config(
    materialized="table",
    schema="clean_grp3"
) }}

-- 1️⃣ RAW INPUT
WITH base AS (
    SELECT
        trim(region) AS region_raw,
        trim(school_year) AS school_year,
        toInt64OrZero(replaceAll(grand_total, ',', '')) AS value
    FROM {{ source('raw_grp3', 'raw___ched_schools_22_25') }}
    WHERE school_year = '2022-2023'              -- ⭐ FILTER HERE
      AND region_raw NOT IN ('', 'TOTAL', 'Philippines', 'Nationwide')
),

-- 2️⃣ CLEAN REGION FIELD
region_clean AS (
    SELECT
        *,
        trim(
            multiIf(
                like(region_raw, '%-%'),
                    splitByChar('-', region_raw)[-1],   
                region_raw
            )
        ) AS region_name_text
    FROM base
),

-- 3️⃣ STANDARDIZE REGION NAMES
standardized AS (
    SELECT
        school_year,

        CASE
            WHEN region_name_text IS NULL THEN 'NATIONWIDE'
            WHEN trim(region_name_text) = '' THEN 'NATIONWIDE'
            WHEN ilike(region_name_text, '%total%') THEN 'NATIONWIDE'
            WHEN ilike(region_name_text, '%nationwide%') THEN 'NATIONWIDE'
            WHEN ilike(region_name_text, '%overall%') THEN 'NATIONWIDE'
            WHEN ilike(region_name_text, '%philippines%') THEN 'NATIONWIDE'
            WHEN ilike(region_name_text, '%all%regions%') THEN 'NATIONWIDE'

            WHEN ilike(region_name_text, '%capital%') THEN 'NCR'
            WHEN ilike(region_name_text, '%cordillera%') THEN 'CAR'
            WHEN ilike(region_name_text, '%ilocos%') THEN 'I'
            WHEN ilike(region_name_text, '%cagayan%') THEN 'II'
            WHEN ilike(region_name_text, '%central luzon%') THEN 'III'
            WHEN ilike(region_name_text, '%calabarzon%') THEN 'IV-A'
            WHEN ilike(region_name_text, '%mimaropa%') THEN 'IV-B'
            WHEN ilike(region_name_text, '%bicol%') THEN 'V'
            WHEN ilike(region_name_text, '%western visayas%') THEN 'VI'
            WHEN ilike(region_name_text, '%negros%') THEN 'NIR'
            WHEN ilike(region_name_text, '%central visayas%') THEN 'VII'
            WHEN ilike(region_name_text, '%eastern visayas%') THEN 'VIII'
            WHEN ilike(region_name_text, '%zamboanga%') THEN 'IX'
            WHEN ilike(region_name_text, '%northern mindanao%') THEN 'X'
            WHEN ilike(region_name_text, '%davao%') THEN 'XI'
            WHEN ilike(region_name_text, '%soccsksargen%') THEN 'XII'
            WHEN ilike(region_name_text, '%caraga%') THEN 'XIII'
            WHEN ilike(region_name_text, '%bangsamoro%')
              OR ilike(region_name_text, '%barmm%')
              OR ilike(region_name_text, '%baarm%')
                THEN 'BARMM'

            WHEN upper(region_name_text) = 'IVA' THEN 'IV-A'
            WHEN upper(region_name_text) = 'IVB' THEN 'IV-B'
            WHEN upper(region_name_text) = 'BAARM' THEN 'BARMM'

            ELSE region_name_text
        END AS region,
        value
    FROM region_clean
),

-- 4️⃣ AGGREGATE PER REGION
final AS (
    SELECT
        region,
        school_year,
        SUM(value) AS total_schools
    FROM standardized
    WHERE region <> 'NATIONWIDE'
    GROUP BY region, school_year
)

-- 5️⃣ OUTPUT + COMPUTE NATIONWIDE
SELECT
    region,
    school_year,
    total_schools
FROM (

    -- all regions
    SELECT region, school_year, total_schools FROM final

    UNION ALL

    -- computed nationwide
    SELECT
        'NATIONWIDE' AS region,
        school_year,
        SUM(total_schools)
    FROM final
    GROUP BY school_year
)
ORDER BY 
    region = 'NATIONWIDE' DESC,   -- ⭐ Always put nationwide first
    region ASC
