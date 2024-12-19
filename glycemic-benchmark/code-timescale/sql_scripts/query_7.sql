WITH daily_max_glucose AS (
  SELECT time_bucket('1 day', ts) AS day, participant_id, MAX(glucose_value) AS daily_max
  FROM interstitial_glucose
  WHERE ts BETWEEN '2020-02-18T00:00:00Z' AND '2020-02-28T00:00:00Z'
  GROUP BY day, participant_id
)
SELECT day, participant_id, 
       daily_max - LAG(daily_max) OVER (PARTITION BY participant_id ORDER BY day) AS glucose_diff
FROM daily_max_glucose;