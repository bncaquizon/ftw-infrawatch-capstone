{{ config(
    materialized = "table",
    schema = "mart_grp3"
) }}


-- ============================================================
-- DEPED 21-22
-- ============================================================
deped_21 AS (
    SELECT
        {{ clean }} AS region_clean,
        enrollees_21_22
    FROM clean_grp3.clean_deped_enrollees_21_22
),

-- ============================================================
-- DEPED 22-23
-- ============================================================
deped_22 AS (
    SELECT
        {{ clean }} AS region_clean,
        enrollees_22_23
    FROM clean_grp3.clean_deped_enrollees_22_23
),

-- ============================================================
-- CHED ENROLLEES
-- ============================================================
ched AS (
    SELECT
        {{ clean }} AS region_clean,
        total_2021_2022 AS ched_21_22,
        total_2022_2023 AS ched_22_23
    FROM clean_grp3.clean_ched_enrollees_20_24
),

-- ============================================================
-- PSA SCHOOL COUNTS
-- ============================================================
psa AS (
    SELECT
        {{ clean }} AS region_clean,
        total_schools AS psa_schools_22_23
    FROM clean_grp3.clean_psa_school_counts
    WHERE school_year = '2022-2023'
),

-- ============================================================
-- CHED SCHOOL COUNTS
-- ============================================================
ched_sch AS (
    SELECT
        {{ clean }} AS region_clean,
        total_schools AS ched_schools_22_23
    FROM clean_grp3.clean_ched_schools_22_25
    WHERE school_year = '2022-2023'
)