SELECT time_bucket('1 hour', ts) AS hour, 
       AVG(glucose_value) AS mean_g, 
       STDDEV(glucose_value) AS std_g
FROM interstitial_glucose
WHERE participant_id IN {{list_of_participants}} 
  AND ts >= TIMESTAMP '2020-02-15 00:00:00' 
  AND ts < TIMESTAMP '2020-02-15 23:59:59'
GROUP BY time_bucket('1 hour', ts)
ORDER BY hour;