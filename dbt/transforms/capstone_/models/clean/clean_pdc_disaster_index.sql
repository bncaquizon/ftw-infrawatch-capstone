{{ config(materialized="table", schema="clean_grp3") }}

WITH source AS (
    SELECT 
        CAST(privince AS VARCHAR(20)) AS province,
        CAST(earthquake AS NUMERIC(10, 3)) AS earthquake_score,
        CAST(flood AS NUMERIC(10, 3)) AS flood_score,
        CAST(landslide AS NUMERIC(10, 3)) AS landslide_score,
        CAST(storm AS NUMERIC(10, 3)) AS storm_score,
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
    END AS region_name
    from {{ source('raw_grp3', 'raw___pdc_disaster_index') }}
)
,

cleaned as (
    select
        region_name,
        province,
        earthquake_score,
        flood_score,
        landslide_score,
        storm_score

    from source
    where region_name is not null
      and province is not null
      and earthquake_score is not null
      and flood_score is not null
      and landslide_score is not null
      and storm_score is not null
)

select * from cleaned
