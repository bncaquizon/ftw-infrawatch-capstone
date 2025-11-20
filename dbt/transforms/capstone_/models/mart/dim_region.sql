{{ config(
    materialized = "table",
    schema = "mart_grp3",
    engine = "MergeTree()",
    order_by = "region_id",
    tags = ["mart", "dimension"]
) }}

-- Dimension Table: Regions
-- Purpose: Standardized PSA region codes including Nationwide aggregate.

select 
    region_id,
    region_name,
    current_timestamp() as created_at
from (
    select 0 as region_id, 'NATIONWIDE' as region_name union all
    select 1, 'NCR' union all
    select 2, 'CAR' union all
    select 3, 'I' union all
    select 4, 'II' union all
    select 5, 'III' union all
    select 6, 'IV-A' union all
    select 7, 'IV-B' union all
    select 8, 'V' union all
    select 9, 'VI' union all
    select 10, 'VII' union all
    select 11, 'VIII' union all
    select 12, 'IX' union all
    select 13, 'X' union all
    select 14, 'XI' union all
    select 15, 'XII' union all
    select 16, 'XIII' union all
    select 17, 'NIR' union all
    select 18, 'BARMM'
) r