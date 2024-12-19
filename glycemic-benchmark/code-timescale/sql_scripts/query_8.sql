SELECT time_bucket('6 hours', datetime) AS interval, 
       participant_id, 
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY hr) AS median_hr
FROM heart_rate_data
WHERE datetime BETWEEN '2020-02-18T00:00:00Z' AND '2020-02-20T00:00:00Z'
GROUP BY interval, participant_id;