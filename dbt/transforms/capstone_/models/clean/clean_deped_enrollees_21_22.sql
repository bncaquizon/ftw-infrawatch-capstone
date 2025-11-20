{{ config(
    materialized="table",
    schema="clean_grp3"
) }}

WITH base AS (
    SELECT
        trim(regions) AS region,
        toInt64OrZero(replaceAll(enrollees_21_22, ',', '')) AS enrollees_21_22
    FROM {{ source('raw_grp3', 'raw___deped_enrollees_21_22') }}
)

SELECT *
FROM base
ORDER BY region
