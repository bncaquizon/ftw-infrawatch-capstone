{{ config(
    materialized="table",
    schema="clean_grp3"
) }}

WITH base AS (
    SELECT
        trim(regions) AS region_raw,
        toFloat64OrZero(replaceAll(safely_managed_waters, ',', '')) AS safely_managed_waters,
        toFloat64OrZero(replaceAll(basic_drinking_water, ',', '')) AS basic_drinking_water
    FROM {{ source('raw_grp3', 'raw___psa_basic_water_access') }}
),

standardized AS (
    SELECT
        CASE
            WHEN ilike(region_raw, 'Philippines') THEN 'PHILIPPINES'
            WHEN region_raw = 'NCR' THEN 'NCR'
            WHEN region_raw = 'CAR' THEN 'CAR'
            WHEN region_raw = 'I' THEN 'I'
            WHEN region_raw = 'II' THEN 'II'
            WHEN region_raw = 'III' THEN 'III'
            WHEN region_raw = 'IV-A' THEN 'IV-A'
            WHEN region_raw = 'IV-B' THEN 'IV-B'
            WHEN region_raw = 'V' THEN 'V'
            WHEN region_raw = 'VI' THEN 'VI'
            WHEN region_raw = 'NIR' THEN 'NIR'
            WHEN region_raw = 'VII' THEN 'VII'
            WHEN region_raw = 'VIII' THEN 'VIII'
            WHEN region_raw = 'IX' THEN 'IX'
            WHEN region_raw = 'X' THEN 'X'
            WHEN region_raw = 'XI' THEN 'XI'
            WHEN region_raw = 'XII' THEN 'XII'
            WHEN region_raw = 'XIII' THEN 'XIII'
            WHEN ilike(region_raw, 'BARRM') OR ilike(region_raw, 'BARMM') THEN 'BARMM'
            ELSE region_raw
        END AS region,
        safely_managed_waters,
        basic_drinking_water
    FROM base
)

SELECT *
FROM standardized
WHERE region != 'PHILIPPINES'
ORDER BY region
