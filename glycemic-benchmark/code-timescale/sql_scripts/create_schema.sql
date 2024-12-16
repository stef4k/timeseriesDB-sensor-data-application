CREATE EXTENSION IF NOT EXISTS timescaledb;

DROP TABLE IF EXISTS accelerometer_data;
DROP TABLE IF EXISTS blood_volume_pulse;
DROP TABLE IF EXISTS interstitial_glucose;
DROP TABLE IF EXISTS electrodermal_activity;
DROP TABLE IF EXISTS food_log;
DROP TABLE IF EXISTS heart_rate_data;
DROP TABLE IF EXISTS ibi_data;
DROP TABLE IF EXISTS temperature_data;
DROP TABLE IF EXISTS demographics;


CREATE TABLE demographics ( 
	ID SERIAL PRIMARY KEY,
	Gender VARCHAR(6) NOT NULL,
	HbA1c NUMERIC(3, 1));


CREATE TABLE accelerometer_data  (
    ts	TIMESTAMPTZ	NOT NULL, --or TIMESTAMP(6) type
    acc_x	NUMERIC,
    acc_y	NUMERIC,
	acc_z	NUMERIC,
	participant_id INTEGER REFERENCES demographics(id)
);
SELECT create_hypertable('accelerometer_data', by_range('ts', INTERVAL '1 day'));
ALTER TABLE accelerometer_data SET (timescaledb.compress, timescaledb.compress_orderby='ts');
SELECT add_compression_policy('accelerometer_data', INTERVAL '2 weeks');

CREATE TABLE blood_volume_pulse (
    ts	TIMESTAMPTZ	NOT NULL,
	bvp	NUMERIC,
	participant_id INTEGER REFERENCES demographics(id)
);
SELECT create_hypertable('blood_volume_pulse', by_range('ts', INTERVAL '1 day'));
ALTER TABLE blood_volume_pulse SET (timescaledb.compress, timescaledb.compress_orderby='ts');
SELECT add_compression_policy('blood_volume_pulse', INTERVAL '2 weeks');


CREATE TABLE interstitial_glucose  (
    ts	TIMESTAMPTZ,
	event_type	text,
	event_subtype text,
	patient_info text,
	device_info text,
	source_device_id text,
	glucose_value NUMERIC,
	insulin_value NUMERIC,
	carb_value NUMERIC,
	duration interval,
	glucose_rate_change numeric,
	transmitter_time NUMERIC,
	participant_id INTEGER REFERENCES demographics(id)
);
SELECT create_hypertable('interstitial_glucose',by_range('ts', INTERVAL '1 day'));
ALTER TABLE interstitial_glucose SET(timescaledb.compress, timescaledb.compress_orderby='ts');
SELECT add_compression_policy('interstitial_glucose', INTERVAL '2 weeks');


CREATE TABLE electrodermal_activity(
	ts	TIMESTAMPTZ	NOT NULL,
	eda	numeric,
	participant_id INTEGER REFERENCES demographics(id)
);
SELECT create_hypertable('electrodermal_activity', by_range('ts', INTERVAL '1 day'));
ALTER TABLE electrodermal_activity SET (timescaledb.compress, timescaledb.compress_orderby='ts');
SELECT add_compression_policy('electrodermal_activity', INTERVAL '2 weeks');

CREATE TABLE heart_rate_data (
    datetime TIMESTAMPTZ,
    hr DECIMAL(5, 2),
	participant_id INTEGER REFERENCES demographics(id)
);
SELECT create_hypertable('heart_rate_data',by_range('datetime', INTERVAL '1 day'));
ALTER TABLE heart_rate_data SET (timescaledb.compress, timescaledb.compress_orderby='datetime');
SELECT add_compression_policy('heart_rate_data', INTERVAL '2 weeks');


CREATE TABLE ibi_data (
    event_time TIMESTAMPTZ,  -- Stores date and time with timezone info
    ibi NUMERIC(10, 6),       -- Allows up to 10 digits with 6 decimal places for precision
	participant_id INTEGER REFERENCES demographics(id)
);
SELECT create_hypertable('ibi_data',by_range('event_time', INTERVAL '1 day'));
ALTER TABLE ibi_data SET (timescaledb.compress, timescaledb.compress_orderby='event_time');
SELECT add_compression_policy('ibi_data', INTERVAL '2 weeks');

CREATE TABLE temperature_data (
    event_time TIMESTAMPTZ,  -- Stores date and time with timezone info
    temp NUMERIC(5, 2) ,      -- Allows up to 5 digits with 2 decimal places for precision (e.g., 999.99)
	participant_id INTEGER REFERENCES demographics(id)
);
SELECT create_hypertable('temperature_data', by_range('event_time', INTERVAL '1 day'));
ALTER TABLE temperature_data SET (timescaledb.compress, timescaledb.compress_orderby='event_time');
SELECT add_compression_policy('temperature_data', INTERVAL '2 weeks');