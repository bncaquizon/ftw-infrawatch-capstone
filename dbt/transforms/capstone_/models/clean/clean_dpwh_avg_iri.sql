{{ config(
    materialized = "table",
    schema = "clean_grp3",
    engine = "MergeTree()",
    order_by = "region",
    tags=["clean", "dpwh"]
) }}

-- Clean Layer: DPWH Average IRI
-- Purpose: Standardize and validate road roughness data.

select
  upper(trim(region)) as region,
  round(cast(avg_iri as Float64), 1) as avg_iri
from {{ source('raw_grp3', 'raw___dpwh_avg_iri') }}
where region is not null
