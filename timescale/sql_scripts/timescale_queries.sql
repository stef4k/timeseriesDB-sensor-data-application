-- Aggregate data by hour
SELECT time_bucket('1 hour', ts) AS hour,
       AVG(bvp) AS bvp
FROM blood_volume_pulse
GROUP BY hour
ORDER BY hour DESC;

Select * from blood_volume_pulse  limit 10

SELECT * 
FROM temperature_data
WHERE event_time BETWEEN '2020-02-01 00:00:00' AND '2020-02-20 23:59:59';


SELECT time_bucket('1 hour', ts) AS bucket,
       AVG(eda)
FROM electrodermal_activity
WHERE ts BETWEEN '2020-02-13 00:00:00' AND '2020-02-13 23:59:59'
GROUP BY bucket
ORDER BY bucket;

