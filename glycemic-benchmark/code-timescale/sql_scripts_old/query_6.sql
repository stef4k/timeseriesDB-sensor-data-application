-- Most Active Interval of each day
WITH activity_intervals AS (
    SELECT 
        participant_id,
        time_bucket('5 minutes', ts) AS time_interval,  -- 5-minute intervals for activity analysis
        DATE(ts) AS activity_date,  -- Extract the date part from timestamp for daily grouping
        SUM(SQRT(acc_x^2 + acc_y^2 + acc_z^2)) AS total_activity
    FROM accelerometer_data
    GROUP BY participant_id, activity_date, time_interval
)
SELECT 
    participant_id,
    activity_date,
    time_interval,
    total_activity
FROM activity_intervals
WHERE (participant_id, activity_date, total_activity) IN (
    SELECT participant_id, activity_date, MAX(total_activity)
    FROM activity_intervals
    GROUP BY participant_id, activity_date
)
ORDER BY participant_id, activity_date, time_interval;