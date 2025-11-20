{{ config(
    materialized="table",
    schema="clean_grp3"
) }}

WITH base AS (
    SELECT
        trim(regions) AS region,
        toInt64OrZero(replaceAll(running_total_enrollees_22_23, ',', '')) AS enrollees_22_23
    FROM {{ source('raw_grp3', 'raw___deped_enrollees_22_23') }}
)

SELECT *
FROM base
ORDER BY region
