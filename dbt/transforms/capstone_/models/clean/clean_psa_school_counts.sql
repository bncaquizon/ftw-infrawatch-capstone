{{ config(
    materialized="table",
    schema="clean_grp3"
) }}

WITH base AS (
    SELECT DISTINCT
        trim(school_year) AS school_year,
        toInt64OrZero(ncr) AS ncr,
        toInt64OrZero(car) AS car,
        toInt64OrZero(ilocos_region) AS ilocos_region,
        toInt64OrZero(cagayan_valley) AS cagayan_valley,
        toInt64OrZero(central_luzon) AS central_luzon,
        toInt64OrZero(calabarzon) AS calabarzon,
        toInt64OrZero(mimaropa) AS mimaropa,
        toInt64OrZero(bicol_region) AS bicol_region,
        toInt64OrZero(western_visayas) AS western_visayas,
        toInt64OrZero(central_visayas) AS central_visayas,
        toInt64OrZero(eastern_visayas) AS eastern_visayas,
        toInt64OrZero(zamboanga_peninsula) AS zamboanga_peninsula,
        toInt64OrZero(northern_mindanao) AS northern_mindanao,
        toInt64OrZero(davao_region) AS davao_region,
        toInt64OrZero(soccsksargen) AS soccsksargen,
        toInt64OrZero(caraga) AS caraga,
        toInt64OrZero(barmm) AS barmm
    FROM {{ source('raw_grp3', 'raw___psa_deped_schools') }}
),

-- UNPIVOT PSA WIDE → LONG FORMAT
unpivot AS (
    SELECT
        school_year,
        arrayJoin([
            tuple('NCR', ncr),
            tuple('CAR', car),
            tuple('I', ilocos_region),
            tuple('II', cagayan_valley),
            tuple('III', central_luzon),
            tuple('IV-A', calabarzon),
            tuple('IV-B', mimaropa),
            tuple('V', bicol_region),
            tuple('VI', western_visayas),
            tuple('VII', central_visayas),
            tuple('VIII', eastern_visayas),
            tuple('IX', zamboanga_peninsula),
            tuple('X', northern_mindanao),
            tuple('XI', davao_region),
            tuple('XII', soccsksargen),
            tuple('XIII', caraga),
            tuple('BARMM', barmm)
        ]) AS rec
    FROM base
),

final AS (
    SELECT
        rec.1 AS region,
        school_year,
        SUM(rec.2) AS total_schools
    FROM unpivot
    WHERE school_year = '2022-2023'     -- 👈 FILTER HERE
    GROUP BY region, school_year
)

SELECT
    region,
    school_year,
    total_schools
FROM final
ORDER BY 
    region = 'NATIONWIDE' DESC,   -- ⭐ Always put nationwide first
    region ASC
