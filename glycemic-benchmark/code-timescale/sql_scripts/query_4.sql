-- Detect anomalies in glucose readings
WITH glucose_stats AS (
    SELECT 
        time_bucket('1 hour', ts) AS hour,
        participant_id,
        AVG(glucose_value) AS mean_glucose,
        STDDEV(glucose_value) AS std_glucose
    FROM interstitial_glucose ig
    GROUP BY hour, participant_id
)
SELECT 
    hour,
    g.participant_id,
    mean_glucose,
    std_glucose,
    CASE 
        WHEN ABS(glucose_value - mean_glucose) > 2 * std_glucose 
        THEN 'Anomaly' 
        ELSE 'Normal' 
    END AS glucose_status
FROM interstitial_glucose g
JOIN glucose_stats s ON 
    time_bucket('1 hour', g.ts) = s.hour AND 
    g.participant_id = s.participant_id
WHERE ABS(g.glucose_value - s.mean_glucose) > 2 * s.std_glucose;

