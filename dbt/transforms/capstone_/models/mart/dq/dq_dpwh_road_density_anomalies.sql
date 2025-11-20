{{ config(
    materialized = "view",
    schema = "mart_grp3"
) }}

-- Row-level Data Quality Violations for DPWH Road Density
-- Detects missing regions, negative densities, and extreme outlier values.

with cln as (
  select * 
  from {{ ref('clean_dpwh_road_density') }}
),

violations as (
  select
    region,
    year_2012,
    year_2013,
    year_2014,
    year_2015,
    year_2016,
    year_2017,
    year_2018,
    year_2019,
    year_2020,
    year_2021,
    year_2022,
    year_2023,
    year_2024,

    -- Data Quality Issue Classification
    multiIf(
      region is null, 'null_region',
      year_2012 < 0 or year_2013 < 0 or year_2014 < 0 or year_2015 < 0 or
      year_2016 < 0 or year_2017 < 0 or year_2018 < 0 or year_2019 < 0 or
      year_2020 < 0 or year_2021 < 0 or year_2022 < 0 or year_2023 < 0 or
      year_2024 < 0, 'negative_density',
      greatest(
        abs(year_2012 - year_2013),
        abs(year_2013 - year_2014),
        abs(year_2014 - year_2015),
        abs(year_2015 - year_2016),
        abs(year_2016 - year_2017),
        abs(year_2017 - year_2018),
        abs(year_2018 - year_2019),
        abs(year_2019 - year_2020),
        abs(year_2020 - year_2021),
        abs(year_2021 - year_2022),
        abs(year_2022 - year_2023),
        abs(year_2023 - year_2024)
      ) > 500, 'outlier_jump',
      'ok'
    ) as dq_issue

  from cln
)

select *
from violations
where dq_issue != 'ok'