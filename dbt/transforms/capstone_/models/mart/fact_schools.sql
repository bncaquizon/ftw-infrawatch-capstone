{{ config(
    materialized = "table",
    schema = "mart_grp3"
) }}

SELECT
    r.region_id,
    r.region_name,

    -- Total enrollment (2021-2022)
    (COALESCE(d21.total_2021_2022, 0) + COALESCE(c21.total_2021_2022, 0)) AS total_enrollment_2021_2022,

    -- Total enrollment (2022-2023)
    (COALESCE(d22.total_2022_2023, 0) + COALESCE(c22.total_2022_2023, 0)) AS total_enrollment_2022_2023,

    -- Enrollment growth rate
    ROUND(
        (
            (
                COALESCE(d22.total_2022_2023, 0) + COALESCE(c22.total_2022_2023, 0)
            ) -
            (
                COALESCE(d21.total_2021_2022, 0) + COALESCE(c21.total_2021_2022, 0)
            )
        ) / NULLIF(
            (COALESCE(d21.total_2021_2022, 0) + COALESCE(c21.total_2021_2022, 0)), 
            0
        ) * 100,
        2
    ) AS enrollment_growth_rate,

    -- School density per 100k learners
    ROUND(
        COALESCE(s.total_schools, 0)
        / NULLIF(
            (COALESCE(d22.total_2022_2023, 0) + COALESCE(c22.total_2022_2023, 0)),
            0
        ) * 100000,
        2
    ) AS school_density_per_100k

FROM mart_grp3.dim_region r

LEFT JOIN clean_grp3.clean_deped_enrollees_21_22 d21 
    ON r.region_name = d21.region

LEFT JOIN clean_grp3.clean_ched_enrollees_20_24 c21 
    ON r.region_name = c21.region

LEFT JOIN clean_grp3.clean_deped_enrollees_22_23 d22 
    ON r.region_name = d22.region

LEFT JOIN clean_grp3.clean_ched_enrollees_20_24 c22 
    ON r.region_name = c22.region

LEFT JOIN clean_grp3.clean_psa_school_counts s 
    ON r.region_name = s.region 
    AND s.school_year = '2022-2023'

ORDER BY r.region_id