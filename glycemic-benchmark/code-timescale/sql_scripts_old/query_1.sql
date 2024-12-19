-- Glucose Spike Detection
WITH glucose_changes AS (
    SELECT
        participant_id,
        glucose_value AS current_glucose,
        LEAD(ts) OVER (PARTITION BY participant_id ORDER BY ts) AS next_time,
        LEAD(glucose_value) OVER (PARTITION BY participant_id ORDER BY ts) AS next_glucose,
        LEAD(ts) OVER (PARTITION BY participant_id ORDER BY ts) - ts AS time_diff,
        LEAD(glucose_value) OVER (PARTITION BY participant_id ORDER BY ts) - glucose_value AS glucose_change
    FROM
        interstitial_glucose
    WHERE
        glucose_value IS NOT NULL
)
SELECT
    participant_id,
    next_time,
    current_glucose,
    next_glucose,
    glucose_change,
    time_diff
FROM
    glucose_changes
WHERE
    glucose_change > 14
    AND time_diff <= INTERVAL '30 minutes' 
ORDER BY
    participant_id,
    current_time;
