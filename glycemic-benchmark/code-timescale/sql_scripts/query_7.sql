-- stress detection
WITH aggregated_heart_rate AS (
    
    SELECT 
        participant_id,
        time_bucket('1 hour', datetime) AS time_bucket,
        AVG(hr) AS avg_heart_rate
    FROM heart_rate_data
    GROUP BY participant_id, time_bucket
),
aggregated_eda AS (
    
    SELECT 
        participant_id,
        time_bucket('1 hour', ts) AS time_bucket,
        AVG(eda) AS avg_eda
    FROM electrodermal_activity
    GROUP BY participant_id, time_bucket
)
SELECT 
    hr.participant_id,
    hr.time_bucket,
    hr.avg_heart_rate,
    eda.avg_eda,
    CASE 
        WHEN hr.avg_heart_rate > 100 AND eda.avg_eda > 2 THEN 'Stress'
        ELSE 'Normal'
    END AS stress_status
FROM aggregated_heart_rate hr
JOIN aggregated_eda eda 
    ON hr.participant_id = eda.participant_id 
    AND hr.time_bucket = eda.time_bucket
ORDER BY hr.time_bucket;
