-- Interpolation on the biggest data and then aggregation
WITH interpolated_data AS (
    SELECT 
        participant_id,
        time_bucket_gapfill(
            '1 second', 
            ts, 
            TIMESTAMP '2020-02-01 00:00:00', 
            TIMESTAMP '2020-02-20 23:59:59'
        ) AS bucketed_time, -- Specify your desired time range explicitly as TIMESTAMP
        interpolate(avg(bvp)) AS interpolated_bvp
    FROM blood_volume_pulse
    WHERE ts BETWEEN TIMESTAMP '2020-02-01 00:00:00' AND TIMESTAMP '2020-02-20 23:59:59'
    GROUP BY participant_id, time_bucket_gapfill(
        '1 second', 
        ts, 
        TIMESTAMP '2020-02-01 00:00:00', 
        TIMESTAMP '2020-02-20 23:59:59'
    )
)
SELECT 
    participant_id,
    AVG(interpolated_bvp) AS smooth_bvp,
    STDDEV(interpolated_bvp) AS bvp_variation
FROM interpolated_data
GROUP BY participant_id;