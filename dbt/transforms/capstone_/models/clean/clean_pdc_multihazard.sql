{{ config(materialized="table", schema="clean_grp3") }}

WITH source AS (
    SELECT 
        CAST(province AS VARCHAR(20)) AS province,
        CAST(multi_hazard_exposure AS NUMERIC(10, 3)) AS multi_hazard_exposure,
        CAST(vulnerability AS NUMERIC(10, 3)) AS vulnerability,
        CAST(coping AS NUMERIC(10, 3)) AS coping,
        CAST(resilience AS NUMERIC(10, 3)) AS resilience,
        CAST(multi_hazard_risk AS NUMERIC(10, 3)) AS multi_hazard_risk,
        CASE
        WHEN province IN ('Ilocos Norte', 'Ilocos Sur', 'La Union', 'Pangasinan') THEN 'I'
        WHEN province IN ('Batanes', 'Cagayan', 'Isabela', 'Nueva Vizcaya', 'Quirino') THEN 'II'
        WHEN province IN ('Aurora', 'Bataan', 'Bulacan', 'Nueva Ecija', 'Pampanga', 'Tarlac', 'Zambales') THEN 'III'
        WHEN province IN ('Batangas', 'Cavite', 'Laguna', 'Quezon', 'Rizal') THEN 'IV-A'
        WHEN province IN ('Marinduque', 'Occidental Mindoro', 'Oriental Mindoro', 'Palawan', 'Romblon') THEN 'IV-B'
        WHEN province IN ('Albay', 'Camarines Norte', 'Camarines Sur', 'Catanduanes', 'Masbate', 'Sorsogon') THEN 'V'
        WHEN province IN ('Aklan', 'Antique', 'Capiz', 'Guimaras', 'Iloilo', 'Negros Occidental') THEN 'VI'
        WHEN province IN ('Bohol', 'Cebu', 'Negros Oriental', 'Siquijor') THEN 'VII'
        WHEN province IN ('Biliran', 'Eastern Samar', 'Leyte', 'Northern Samar', 'Samar', 'Southern Leyte') THEN 'VIII'
        WHEN province IN ('Zamboanga del Norte', 'Zamboanga del Sur', 'Zamboanga Sibugay') THEN 'IX'
        WHEN province IN ('Bukidnon', 'Camiguin', 'Lanao del Norte', 'Misamis Occidental', 'Misamis Oriental') THEN 'X'
        WHEN province IN ('Davao de Oro', 'Davao del Norte', 'Davao del Sur', 'Davao Occidental', 'Davao Oriental') THEN 'XI'
        WHEN province IN ('Cotabato', 'Sarangani', 'South Cotabato', 'Sultan Kudarat') THEN 'XII'
        WHEN province IN ('Agusan del Norte', 'Agusan del Sur', 'Dinagat Islands', 'Surigao del Norte', 'Surigao del Sur') THEN 'XIII'
        WHEN province IN ('Abra', 'Apayao', 'Benguet', 'Ifugao', 'Kalinga', 'Mountain Province') THEN 'CAR'
        WHEN province IN ('NCR') THEN 'NCR'
        WHEN province IN ('Basilan', 'Lanao del Sur', 'Maguindanao', 'Sulu', 'Tawi-Tawi') THEN 'BARMM'
        ELSE 'NIR'
    END AS region
    from {{ source('raw_grp3', 'raw___pdc_multihazard') }}
)
,

cleaned as (
    select
        region,
        province,
        multi_hazard_exposure,
        vulnerability,
        coping,
        resilience,
        multi_hazard_risk

    from source
    where region is not null
      and province is not null
      and multi_hazard_exposure is not null
      and vulnerability is not null
      and coping is not null
      and resilience is not null
      and multi_hazard_risk is not null
)

select * from cleaned
