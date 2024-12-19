SELECT time_bucket('1 day', datetime::TIMESTAMP) AS day, 
       participant_id, 
       hr
FROM heart_rate_data
WHERE datetime::TIMESTAMP BETWEEN TIMESTAMP '2020-02-14 00:00:00' AND TIMESTAMP '2020-02-20 23:59:59'
ORDER BY day, participant_id, hr DESC
LIMIT 3;