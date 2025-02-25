# dbt

Q1. select * from myproject.raw_nyc_tripdata.ext_green_tax

Q2. 
Update the WHERE clause to `pickup_datetime >= CURRENT_DATE - INTERVAL '{{ var("days_back", env_var("DAYS_BACK", "30")) }}' DAY`

Q3.

 `dbt run --select +models/core/fct_taxi_monthly_zone_revenue.sql`

Q4. 

• Setting a value for `DBT_BIGQUERY_TARGET_DATASET` env var is mandatory, or it'll fail to compile

• When using `core`, it materializes in the dataset defined in `DBT_BIGQUERY_TARGET_DATASET`

• When using `stg`, it materializes in the dataset defined in `DBT_BIGQUERY_STAGING_DATASET`, or defaults to `DBT_BIGQUERY_TARGET_DATASET`

• When using `staging`, it materializes in the dataset defined in `DBT_BIGQUERY_STAGING_DATASET`, or defaults to `DBT_BIGQUERY_TARGET_DATASET`

Q5

• green: {best: 2020/Q1, worst: 2020/Q2}, yellow: {best: 2020/Q1, worst: 2020/Q2}

```sql
WITH yoy AS (
    SELECT
        service_type,
        year_quarter,
        yoy_growth_percent
    FROM `zoomcamp.fct_taxi_trips_quarterly_revenue`
    WHERE year = 2020
),

best_worst AS (
    SELECT
        service_type,
        -- Grab the quarter with the highest yoy_growth_percent
        ARRAY_AGG(year_quarter ORDER BY yoy_growth_percent DESC LIMIT 1)[SAFE_OFFSET(0)] AS best_qtr,
        -- Grab the quarter with the lowest yoy_growth_percent
        ARRAY_AGG(year_quarter ORDER BY yoy_growth_percent ASC  LIMIT 1)[SAFE_OFFSET(0)] AS worst_qtr
    FROM yoy
    GROUP BY service_type
)

SELECT *
FROM best_worst
ORDER BY service_type;

```

Q6.
green: {p97: 55.0, p95: 45.0, p90: 26.5}, yellow: {p97: 31.5, p95: 25.5, p90: 19.0}

```
SELECT * FROM `kestra-week2.zoomcamp.fct_taxi_trips_monthly_fare_p95` 
WHERE year = 2020 AND month = 4 and service_type='Yellow' --'Green'
limit 1;
```

```
Green
2020
4
55.0
45.0
26.5
Yellow
2020
4
32.0
26.0
19.0
```