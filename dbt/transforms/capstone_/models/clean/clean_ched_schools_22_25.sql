{{ config(
    materialized = "table",
    schema = "clean_grp3"
) }}

WITH base AS (
    SELECT
        trim(school_year) AS school_year,
        trim(region) AS region_raw,
        toInt64OrZero(replaceAll(private, ',', '')) AS private,
        toInt64OrZero(replaceAll(luc, ',', '')) AS luc,
        toInt64OrZero(replaceAll(ogs, ',', '')) AS ogs,
        toInt64OrZero(replaceAll(suc_main, ',', '')) AS suc_main,
        toInt64OrZero(replaceAll(suc_satellite, ',', '')) AS suc_satellite,
        toInt64OrZero(replaceAll(grand_total, ',', '')) AS grand_total
    FROM {{ source('raw_grp3', 'raw___ched_schools_22_25') }}
),

-- SAFEST REGION NORMALIZER
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

-- STANDARDIZE REGION NAMES
standardized AS (
    SELECT
        school_year,

        CASE
            WHEN ilike(region_name_text, '%capital%') THEN 'NCR'
            WHEN ilike(region_name_text, '%cordillera%') THEN 'CAR'
            WHEN ilike(region_name_text, '%ilocos%') THEN 'I'
            WHEN ilike(region_name_text, '%cagayan%') THEN 'II'
            WHEN ilike(region_name_text, '%central luzon%') THEN 'III'
            WHEN ilike(region_name_text, '%calabarzon%') THEN 'IV-A'
            WHEN ilike(region_name_text, '%mimaropa%') THEN 'IV-B'
            WHEN ilike(region_name_text, '%bicol%') THEN 'V'
            WHEN ilike(region_name_text, '%western visayas%') THEN 'VI'
            WHEN ilike(region_name_text, '%central visayas%') THEN 'VII'
            WHEN ilike(region_name_text, '%eastern visayas%') THEN 'VIII'
            WHEN ilike(region_name_text, '%zamboanga%') THEN 'IX'
            WHEN ilike(region_name_text, '%northern mindanao%') THEN 'X'
            WHEN ilike(region_name_text, '%davao%') THEN 'XI'
            WHEN ilike(region_name_text, '%soccsksargen%') THEN 'XII'
            WHEN ilike(region_name_text, '%caraga%') THEN 'XIII'
            WHEN ilike(region_name_text, '%barmm%') THEN 'BARMM'
            WHEN ilike(region_name_text, '%negros%') OR ilike(region_name_text, '%nir%') THEN 'NIR'
            WHEN ilike(region_name_text, '%philippine%') THEN 'NATIONWIDE'
            ELSE region_name_text
        END AS region,

        private,
        luc,
        ogs,
        suc_main,
        suc_satellite,
        grand_total
    FROM region_clean
),

final AS (
    SELECT
        region,
        school_year,
        SUM(private) AS private,
        SUM(luc) AS luc,
        SUM(ogs) AS ogs,
        SUM(suc_main) AS suc_main,
        SUM(suc_satellite) AS suc_satellite,
        SUM(grand_total) AS total_schools
    FROM standardized
    GROUP BY region, school_year
)

SELECT *
FROM final
ORDER BY region, school_year
