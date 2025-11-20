{{ config(
    materialized="table",
    schema="clean_grp3"
) }}

WITH base AS (
    SELECT
        trim(region) AS region,
        trim(hei_type) AS hei_type,
        trim(program_level) AS program_level,

        -- FIX: match actual raw column name _2020_20201
        toInt64OrZero(replaceAll(_2020_20201, ',', '')) AS sy_2020_2021,

        -- This column name exists and is correct
        toInt64OrZero(replaceAll(_2021_2022, ',', '')) AS sy_2021_2022
    FROM {{ source('raw_grp3', 'raw___ched_schools_21_22') }}
),

region_clean AS (
    SELECT
        replaceRegexpAll(region, '^[0-9]+\\s*-\\s*', '') AS region,
        hei_type,
        program_level,
        sy_2020_2021,
        sy_2021_2022
    FROM base
),

unpivoted AS (
    SELECT
        region,
        hei_type,
        program_level,
        '2020–2021' AS school_year,
        sy_2020_2021 AS total_enrollment
    FROM region_clean
    UNION ALL
    SELECT
        region,
        hei_type,
        program_level,
        '2021–2022' AS school_year,
        sy_2021_2022 AS total_enrollment
    FROM region_clean
),

standardized AS (
    SELECT
        tupleElement({{ standardize_region('region') }}, 1) AS region_code,
        tupleElement({{ standardize_region('region') }}, 2) AS region_id,
        tupleElement({{ standardize_region('region') }}, 3) AS region_name,
        region,
        hei_type,
        program_level,
        school_year,
        total_enrollment
    FROM unpivoted
)

SELECT
    region_code,
    region_id,
    region_name,
    hei_type,
    program_level,
    school_year,
    total_enrollment
FROM standardized
WHERE total_enrollment > 0
  AND region_code != '00'