{{ config(enabled=false) }}


with cln as (
    select
        region,
        toInt32OrNull(total_hospitals) as total_hospitals
    from {{ ref('clean_doh_hospital_counts') }}
),

violations as (
    select
        region,
        total_hospitals,

        multiIf(
            region is null, 'null_region',

            total_hospitals is null, 'invalid_total_hospitals',

            total_hospitals < 0, 'negative_total_hospitals',

            'ok'
        ) as dq_issue
    from cln
)

select *
from violations
where dq_issue != 'ok'
