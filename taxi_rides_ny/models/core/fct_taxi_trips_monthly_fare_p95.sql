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
      AND payment_type_description IN ('Cash', 'Credit Card')
),
with_time AS (
    SELECT
        service_type,
        EXTRACT(YEAR  FROM pickup_datetime) AS year,
        EXTRACT(MONTH FROM pickup_datetime) AS month,
        fare_amount
    FROM valid_trips
),
approximate AS (
    SELECT
      service_type,
      year,
      month,
      APPROX_QUANTILES(fare_amount, 101) AS arr
    FROM with_time
    GROUP BY service_type, year, month
)

SELECT
  service_type,
  year,
  month,
  arr[SAFE_OFFSET(97)] AS p97,
  arr[SAFE_OFFSET(95)] AS p95,
  arr[SAFE_OFFSET(90)] AS p90

FROM approximate
ORDER BY service_type, year, month



