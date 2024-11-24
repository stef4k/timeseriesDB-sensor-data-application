-- Average blood_volume_pulse by day
SELECT time_bucket('1 day', ts) AS hour,
       AVG(bvp) AS bvp
FROM blood_volume_pulse
GROUP BY hour
ORDER BY hour DESC;

-- Filter data on specific period using BETWEEN
SELECT *
FROM temperature_data
WHERE event_time BETWEEN '2020-02-01 00:00:00' AND '2020-02-20 23:59:59';

-- Filter data on specific period using INTERVAL
SELECT * 
FROM temperature_data
WHERE event_time > TIMESTAMP '2020-02-29 00:00:00' - INTERVAL '1 day'

-- Average electrodermal activity per hour for specific period
SELECT time_bucket('1 hour', ts) AS bucket,
       AVG(eda)
FROM electrodermal_activity
WHERE ts BETWEEN '2020-02-13 00:00:00' AND '2020-02-13 23:59:59'
GROUP BY bucket
ORDER BY bucket;

-- Average electrodermal activity per month for each participant
SELECT participant_id, time_bucket('1 month', ts) AS bucket,
       AVG(eda)
FROM electrodermal_activity
GROUP BY participant_id, bucket
ORDER BY participant_id, bucket;

-- Last 10 chronological timestamps of blood pulse with the greatest bvp values
Select *
FROM blood_volume_pulse
ORDER BY ts DESC, bvp DESC
LIMIT 10;

-- The first and last chronological electrodermal index for each participant
-- for a specific period
SELECT participant_id, FIRST(eda, ts), LAST(eda, ts)
FROM electrodermal_activity
WHERE ts BETWEEN '2020-02-15 00:00:00' AND '2020-05-20 23:59:59'
GROUP BY participant_id
ORDER BY participant_id

-- Continuous aggregates of first, last, max, average of electrodermal activity per
-- participant and per day
CREATE MATERIALIZED VIEW electrodermal_stats_daily
WITH (timescaledb.continuous) AS
SELECT participant_id, time_bucket('1 day', ts) AS bucket, 
	FIRST(eda, ts), LAST(eda, ts), MAX(eda), AVG(eda)
FROM electrodermal_activity
WHERE ts BETWEEN '2020-02-21 00:00:00' AND '2020-02-22 23:59:59'
GROUP BY participant_id, bucket

-- DROP MATERIALIZED VIEW IF EXISTS electrodermal_stats_daily CASCADE;
select * from electrodermal_stats_daily ORDER BY bucket ASC

-- Setting up automatic refresh policy for continuous aggregates (materialized views)
SELECT add_continuous_aggregate_policy('electrodermal_stats_daily',
    start_offset => INTERVAL '5 days',
    end_offset => INTERVAL '1 hour',
    schedule_interval => INTERVAL '1 days');