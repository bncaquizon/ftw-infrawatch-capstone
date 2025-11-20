{{ config(
  materialized="table",
  schema="clean_grp3"
) }}

with raw as (
  select
    trim(year) as year_raw,
    trim(region) as region_raw,
    trim(index) as idx,
    trim(contract_id) as contract_id,
    trim(contract_description) as contract_description,
    trim(contractor) as contractor,
    trim(implementing_office) as implementing_office,
    trim(source_of_funds) as source_of_funds,

    -- normalize contract_cost: remove commas, treat nan/empty as 0
    (
      case
        when lower(trim(contract_cost)) in ('', 'nan', 'na', 'n/a') then 0.0
        when trim(contract_cost) like '%-%' and trim(contract_cost) not like '%0%' then 0.0
        else toFloat64OrZero(replaceAll(trim(contract_cost), ',', ''))
      end
    ) AS contract_cost_num,

    -- keep raw dates as strings (parse later if needed)
    trim(effectivity_date) AS effectivity_date_raw,
    trim(expiry_date) AS expiry_date_raw,

    -- status & percentage
    trim(status) AS status,
    toFloat64OrZero(replaceAll(replaceAll(trim(percentage), '%', ''), ',', '')) AS pct_complete

  from {{ source('raw_grp3', 'raw___dpwh_projects') }}
),

region_mapped as (
  select
    *,
    case
      when region_raw ilike '%CENTRAL OFFICE%' then 'CENTRAL OFFICE'
      when region_raw ilike '%CAPITAL%' or region_raw ilike '%NCR%' or region_raw ilike '%NATIONAL CAPITAL%' then 'NCR'
      when region_raw ilike '%CORDILLERA%' then 'CAR'
      when region_raw ilike '%REGION 1%' or region_raw ilike '%ILOCOS%' then 'I'
      when region_raw ilike '%REGION 2%' or region_raw ilike '%CAGAYAN%' then 'II'
      when region_raw ilike '%REGION 3%' or region_raw ilike '%CENTRAL LUZON%' then 'III'
      when region_raw ilike '%REGION 4-A%' or region_raw ilike '%CALABARZON%' then 'IV-A'
      when region_raw ilike '%REGION 4B%' or region_raw ilike '%REGION 4-B%' or region_raw ilike '%MIMAROPA%' then 'IV-B'
      when region_raw ilike '%REGION 5%' or region_raw ilike '%BICOL%' then 'V'
      when region_raw ilike '%REGION 6%' or region_raw ilike '%WESTERN VISAYAS%' then 'VI'
      when region_raw ilike '%NEGROS%' or region_raw ilike '%NIR%' then 'NIR'
      when region_raw ilike '%REGION 7%' or region_raw ilike '%CENTRAL VISAYAS%' then 'VII'
      when region_raw ilike '%REGION 8%' or region_raw ilike '%EASTERN VISAYAS%' then 'VIII'
      when region_raw ilike '%REGION 9%' or region_raw ilike '%ZAMBOANGA%' then 'IX'
      when region_raw ilike '%REGION 10%' or region_raw ilike '%NORTHERN MINDANAO%' then 'X'
      when region_raw ilike '%REGION 11%' or region_raw ilike '%DAVAO%' then 'XI'
      when region_raw ilike '%REGION 12%' or region_raw ilike '%SOCCSKSARGEN%' then 'XII'
      when region_raw ilike '%REGION 13%' or region_raw ilike '%CARAGA%' then 'XIII'
      when region_raw ilike '%BARMM%' or region_raw ilike '%MUSLIM%' or region_raw ilike '%ARMM%' then 'BARMM'
      else region_raw
    end as region_code
  from raw
),

cleaned as (
  select
    year_raw,
    region_raw,
    region_code,
    idx,
    contract_id,
    contract_description,
    contractor,
    implementing_office,
    source_of_funds,
    contract_cost_num,
    effectivity_date_raw,
    expiry_date_raw,
    status,
    pct_complete
  from region_mapped
  where coalesce(contract_id, '') != ''
    and lower(trim(contract_id)) not like '%grand%'
    and coalesce(contract_description, '') != ''
),

aggregated as (
  select
    region_code as region,
    count(*) as project_count,
    sum(contract_cost_num) as total_contract_cost,
    round( (sum(pct_complete) / nullIf(count(*), 0) ), 2) as avg_pct_complete
  from cleaned
  group by region_code
)

select *
from aggregated
order by region
