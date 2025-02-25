{{ config(materialized='table') }}

WITH valid_trips AS (
    SELECT
        service_type,
        pickup_datetime,
        trip_distance,
        fare_amount,
        payment_type_description
    FROM {{ ref('fact_trips') }}
    WHERE
          fare_amount > 0
      AND trip_distance > 0
      AND payment_type_description in ('Cash', 'Credit card')
),
with_time AS (
    SELECT
        service_type,
        EXTRACT(YEAR  FROM pickup_datetime) AS year,
        EXTRACT(MONTH FROM pickup_datetime) AS month,
        fare_amount
    FROM valid_trips
)

SELECT
    service_type,
    year,
    month,
    PERCENTILE_CONT(fare_amount, 0.97) OVER (PARTITION BY service_type, year, month) AS p97,
    PERCENTILE_CONT(fare_amount, 0.95) OVER (PARTITION BY service_type, year, month) AS p95,
    PERCENTILE_CONT(fare_amount, 0.90) OVER (PARTITION BY service_type, year, month) AS p90
FROM with_time
ORDER BY service_type, year, month




