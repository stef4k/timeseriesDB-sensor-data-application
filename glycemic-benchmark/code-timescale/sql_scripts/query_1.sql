WITH mean_bvp AS (
  SELECT time_bucket('5 seconds', ts::TIMESTAMP) AS bucket, 
         participant_id, 
         AVG(bvp) AS mean_bvp
  FROM blood_volume_pulse
  WHERE ts::TIMESTAMP BETWEEN TIMESTAMP '2020-02-13 22:29:00' AND TIMESTAMP '2020-02-13 22:30:00'
  GROUP BY bucket, participant_id
)
SELECT bucket, 
       participant_id, 
       mean_bvp - LAG(mean_bvp) OVER (PARTITION BY participant_id ORDER BY bucket) AS bvp_rate
FROM mean_bvp;