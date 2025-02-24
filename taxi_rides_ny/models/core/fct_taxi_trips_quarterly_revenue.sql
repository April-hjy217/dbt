--- fct_taxi_trips_quarterly_revenue.sql

{{ config(materialized='table') }}

WITH quarterly_revenue AS (
    SELECT
        service_type,
        EXTRACT(YEAR FROM pickup_datetime)    AS year,
        EXTRACT(QUARTER FROM pickup_datetime) AS quarter,
        CONCAT(
            CAST(EXTRACT(YEAR FROM pickup_datetime) AS STRING),
            '/Q',
            CAST(EXTRACT(QUARTER FROM pickup_datetime) AS STRING)
        ) AS year_quarter,
        SUM(total_amount) AS revenue
    FROM {{ ref('fact_trips') }}
    GROUP BY 1,2,3,4
),

yoy_growth AS (
    SELECT
        cur.service_type,
        cur.year,
        cur.quarter,
        cur.year_quarter,
        cur.revenue            AS current_revenue,
        prev.revenue           AS prev_revenue,
        ROUND(
          SAFE_DIVIDE(cur.revenue - prev.revenue, prev.revenue) * 100,
        2)                     AS yoy_growth_percent
    FROM quarterly_revenue cur
    LEFT JOIN quarterly_revenue prev
        ON  cur.service_type = prev.service_type
        AND cur.year         = prev.year + 1
        AND cur.quarter      = prev.quarter
)

SELECT
    service_type,
    year,
    year_quarter,
    current_revenue,
    prev_revenue,
    yoy_growth_percent
FROM yoy_growth
-- Explicitly include only 2019 & 2020 data
WHERE year IN (2019, 2020)
ORDER BY service_type, year_quarter
