{{ config(enabled=false) }}


-- Standardize region names
{% set clean_region %}
    replaceAll(
        replaceAll(
            replaceAll(upper(trimBoth(region)), ' ', ''),
        '-', ''),
    'BARRM', 'BARMM')
{% endset %}

SELECT
    trimBoth(region) AS region,
    toInt64OrZero(total_hospitals) AS total_hospitals
FROM raw_grp3.clean_doh_hospital_counts