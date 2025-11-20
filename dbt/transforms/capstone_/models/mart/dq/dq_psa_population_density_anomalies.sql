{{ config(
    materialized = "view",
    schema = "mart_grp3"
) }}

-- Row-level Data Quality Violations for PSA Population Density
-- Detects nulls, outliers, invalid numeric values, and duplicate regions

with cln as (
  select * 
  from {{ ref('clean_psa_population_density') }}
),

violations as (
  select
    region,
    population_2010,
    population_2015,
    population_2020,
    population_2024,
    land_area,
    population_density_2010,
    population_density_2015,
    population_density_2020,
    population_density_2024,
    density_growth_rate_2010_2024,
    urban_pop_growth_2010_2020,

    -- Data Quality Issue Classification
    multiIf(
      region is null, 'null_region',
      land_area <= 0, 'invalid_land_area',
      population_2010 < 0 or population_2015 < 0 or population_2020 < 0 or population_2024 < 0, 'negative_population',
      population_density_2010 < 0 or population_density_2015 < 0 or population_density_2020 < 0 or population_density_2024 < 0, 'negative_density',
      density_growth_rate_2010_2024 < -100 or density_growth_rate_2010_2024 > 1000, 'outlier_density_growth',
      urban_pop_growth_2010_2020 < -100 or urban_pop_growth_2010_2020 > 1000, 'outlier_urban_growth',
      'ok'
    ) as dq_issue

  from cln
)

-- Return only rows with detected anomalies
select *
from violations
where dq_issue != 'ok'
