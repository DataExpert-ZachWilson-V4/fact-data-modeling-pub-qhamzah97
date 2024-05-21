-- query_4
WITH
  today AS (
    SELECT *
      FROM user_devices_cumulated
     WHERE date = DATE('2023-01-07')
  ),
  date_list_int AS (
    SELECT 
      user_id,
      browser_type,
      --convert integer to binary
      TO_BASE(
        CAST(
          SUM(
            CASE
              WHEN CONTAINS(dates_active, sequence_date) THEN POW(2, 30 - DATE_DIFF('day', sequence_date, date))
              ELSE 0
            END
          ) AS BIGINT
        ),
      2
      ) as history_int
      FROM today
     CROSS JOIN UNNEST (SEQUENCE(DATE('2023-01-01'), DATE('2023-01-07'))) AS t (sequence_date)
     GROUP BY user_id, browser_type
  )

SELECT
  user_id,
  browser_type,
  -- ensuring a 32-bit value
  LPAD(history_int, 32, '0') AS history_binary
  FROM date_list_int
