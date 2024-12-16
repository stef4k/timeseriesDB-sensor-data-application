-- Query to analyse rolling average using window functions over time-series data useful for trend analysis
SELECT 
    hrd.participant_id,
    time_bucket('1 hour', hrd.datetime) AS time_bucket,
    hrd.datetime,
    hrd.hr,
    AVG(hrd.hr) OVER (
        PARTITION BY hrd.participant_id
        ORDER BY hrd.datetime
        RANGE BETWEEN INTERVAL '1 hour' PRECEDING AND CURRENT ROW
    ) AS rolling_avg_hr
FROM heart_rate_data hrd
ORDER BY time_bucket, hrd.datetime;