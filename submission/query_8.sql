--query_8
INSERT INTO host_activity_reduced
WITH
  yesterday AS (
    SELECT *
      FROM host_activity_reduced
     WHERE month_start = '2023-08-01'
  ),
  today AS (
    SELECT *
      -- Assuming table already exists
      FROM qhamzah.daily_web_metrics
     WHERE date = DATE('2023-08-01')
  )

SELECT
  COALESCE(t.host, y.host) AS host,
  COALESCE(t.metric_name, y.metric_name) AS metric_name,
  COALESCE(
    y.metric_array,
    REPEAT(
      NULL,
      CAST(DATE_DIFF('day', DATE('2023-08-01'), t.date) AS INTEGER)
    )
  ) || ARRAY[t.metric_value] AS metric_array,
  '2023-08-01' AS month_start
  FROM today t
  FULL OUTER JOIN yesterday y ON t.host = y.host AND t.metric_name = y.metric_name
