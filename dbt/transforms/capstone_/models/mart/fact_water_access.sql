{{ config(
    materialized = "table",
    schema = "mart_grp3"
) }}

{% set clean_region %}
    replaceAll(
        replaceAll(
            replaceAll(upper(trimBoth(region)), ' ', ''),
        '-', ''),
    'BARRM', 'BARMM')
{% endset %}

--------------------------------------------------------------------------------------
-- 1. LOAD PSA WATER ACCESS
--------------------------------------------------------------------------------------
WITH psa AS (
    SELECT
        {{ clean_region }} AS region_key_raw,
        if(isNaN(safely_managed_waters), 0, safely_managed_waters) AS safely_managed_waters
    FROM clean_grp3.clean_psa_basic_water_access
),

--------------------------------------------------------------------------------------
-- 2. CLEAN REGION NAME
--------------------------------------------------------------------------------------
fixed AS (
    SELECT
        CASE
            WHEN region_key_raw = 'IVA' THEN 'IV-A'
            WHEN region_key_raw = 'IVB' THEN 'IV-B'
            ELSE region_key_raw
        END AS region_key,
        safely_managed_waters
    FROM psa
),

--------------------------------------------------------------------------------------
-- 3. PRECOMPUTE WEIGHTED SCORES FOR MIN/MAX CALCULATION
--------------------------------------------------------------------------------------
weights AS (
    SELECT
        r.region_id,
        r.region_name,
        f.safely_managed_waters,
        toFloat64(round(f.safely_managed_waters / 0.30, 2)) AS weighted_score,
        r.created_at
    FROM mart_grp3.dim_region r
    LEFT JOIN fixed f ON r.region_name = f.region_key
    WHERE r.region_id != 0         -- exclude Nationwide
      AND r.region_name != 'NIR'   -- exclude NIR
      AND f.safely_managed_waters > 0 -- Excel ignores missing / zero values
),

--------------------------------------------------------------------------------------
-- 4. COMPUTE MIN & MAX OF WEIGHTED SCORE
--------------------------------------------------------------------------------------
stats AS (
    SELECT
        max(weighted_score) AS max_ws,
        min(weighted_score) AS min_ws
    FROM weights
),

--------------------------------------------------------------------------------------
-- 5. REGION FACTS WITH NORMALIZED SCORE
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
-- 5. REGION FACTS WITH NORMALIZED SCORE (EXACT EXCEL LOGIC)
--------------------------------------------------------------------------------------
region_facts AS (
    SELECT
        w.region_id,
        w.region_name,
        w.safely_managed_waters,
        w.weighted_score,
        round((s.max_ws - w.weighted_score) 
              / nullIf(s.max_ws - s.min_ws, 0), 2) AS normalized_score,
        w.created_at
    FROM weights w
    CROSS JOIN stats s
),

--------------------------------------------------------------------------------------
-- 6. NATIONWIDE (EXACT SAME NORMALIZATION)
--------------------------------------------------------------------------------------
nationwide AS (
    SELECT
        0 AS region_id,
        'NATIONWIDE' AS region_name,
        psa.safely_managed_waters AS safely_managed_waters,
        toFloat64(round(psa.safely_managed_waters / 0.30, 2)) AS weighted_score,
        toFloat64(round((s.max_ws - toFloat64(round(psa.safely_managed_waters / 0.30, 2))) 
                / nullIf(s.max_ws - s.min_ws, 0), 2)) AS normalized_score,
        now() AS created_at
    FROM psa
    CROSS JOIN stats s
    LIMIT 1
)


--------------------------------------------------------------------------------------
-- 7. FINAL OUTPUT
--------------------------------------------------------------------------------------
SELECT *
FROM (
    -- NATIONWIDE
    SELECT
        toInt32(region_id) AS region_id,
        region_name,
        toDecimal32(round(safely_managed_waters, 2), 2) AS safely_managed_waters,
        toDecimal32(round(weighted_score, 2), 2)           AS weighted_score,
        toDecimal32(round(normalized_score, 2), 2)         AS normalized_score,
        created_at
    FROM nationwide

    UNION ALL

    -- REGION FACTS
    SELECT
        toInt32(region_id) AS region_id,
        region_name,
        toDecimal32(round(safely_managed_waters, 2), 2) AS safely_managed_waters,
        toDecimal32(round(weighted_score, 2), 2)         AS weighted_score,
        toDecimal32(round(normalized_score, 2), 2)       AS normalized_score,
        created_at
    FROM region_facts
)
ORDER BY 
    CASE WHEN region_id = 0 THEN 0 ELSE 1 END,
    region_id ASC