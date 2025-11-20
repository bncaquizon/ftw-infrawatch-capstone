{{ config(
    materialized = "view",
    schema = "mart_grp3"
) }}

-- Row-level Data Quality Violations for DPWH Average IRI
-- Detects missing regions and invalid or outlier IRI values.

with cln as (
  select * 
  from {{ ref('clean_dpwh_avg_iri') }}
),

violations as (
  select
    region,
    avg_iri,

    -- Data Quality Issue Classification
    multiIf(
      region is null, 'null_region',
      avg_iri is null, 'null_avg_iri',
      avg_iri < 0, 'negative_iri',
      avg_iri > 20, 'outlier_high_iri',   -- typical IRI range: 0–15, over 20 is outlier
      'ok'
    ) as dq_issue

  from cln
)

select *
from violations
where dq_issue != 'ok'