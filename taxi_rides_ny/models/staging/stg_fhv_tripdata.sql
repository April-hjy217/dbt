{{ config(materialized="view") }}

select
    {{ dbt.safe_cast("PUlocationID", api.Column.translate_type("integer")) }} as pickup_locationid,
    {{ dbt.safe_cast("DOlocationID", api.Column.translate_type("integer")) }} as dropoff_locationid,
    
    TIMESTAMP(CAST(pickup_datetime AS STRING)) AS pickup_datetime,
    TIMESTAMP(CAST(dropoff_datetime AS STRING)) AS dropoff_datetime,

    cast(SR_Flag as numeric) as sr_flag,
    Affiliated_base_number as affiliated_base_number
FROM {{ source('staging', 'fhv_taxi_external') }}
-- where rn = 1


-- dbt build --select <model_name> --vars '{'is_test_run': 'false'}'
{% if var('is_test_run', default=true) %}

  -- limit 100

{% endif %}