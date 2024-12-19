-- Steps count daily and weekly 
WITH accelerometer_magnitude AS (
    SELECT
        participant_id,
        ts,
        SQRT(POWER(acc_x, 2) + POWER(acc_y, 2) + POWER(acc_z, 2)) AS acceleration_magnitude
    FROM accelerometer_data
),
step_detection AS (
    SELECT
        participant_id,
        time_bucket('1 day', ts) AS day,
        time_bucket('1 week', ts) AS week,
        COUNT(*) AS potential_steps
    FROM accelerometer_magnitude
    WHERE acceleration_magnitude > 100 AND participant_id IN {{list_of_participants}}
    GROUP BY participant_id, day, week
)
SELECT
    participant_id,
    day AS period,
    'daily' AS period_type,
    potential_steps AS step_count
FROM step_detection
UNION ALL
-- Weekly Step Count
SELECT
    participant_id,
    week AS period,
    'weekly' AS period_type,
    SUM(potential_steps) AS step_count
FROM step_detection
GROUP BY participant_id, week
ORDER BY participant_id, period_type, period;