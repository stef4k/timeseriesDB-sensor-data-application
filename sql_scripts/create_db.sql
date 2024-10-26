CREATE EXTENSION IF NOT EXISTS timescaledb;

DROP TABLE IF EXISTS accelerometer_data;
DROP TABLE IF EXISTS blood_volume_pulse;
DROP TABLE IF EXISTS interstitial_glucose;
DROP TABLE IF EXISTS electrodermal_activity;
DROP TABLE IF EXISTS food_log;
DROP TABLE IF EXISTS heart_rate_data;
DROP TABLE IF EXISTS ibi_data;
DROP TABLE IF EXISTS temperature_data;


CREATE TABLE accelerometer_data  (
    ts	TIMESTAMPTZ	NOT NULL, --or TIMESTAMP(6) type
    acc_x	NUMERIC,
    acc_y	NUMERIC,
	acc_z	NUMERIC
);


CREATE TABLE blood_volume_pulse (
    ts	TIMESTAMPTZ	NOT NULL,
	bvp	NUMERIC
);

CREATE TABLE interstitial_glucose  (
	ind Serial,
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
	transmitter_time NUMERIC
);

CREATE TABLE electrodermal_activity(
	ts	TIMESTAMPTZ	NOT NULL,
	eda	numeric
);

CREATE TABLE food_log (
    --entry_id SERIAL PRIMARY KEY,          -- Unique identifier for each entry
    date DATE NOT NULL,                   -- Date of food logged
    time TIME NOT NULL,                   -- Time when food was logged
    time_begin TIMESTAMPTZ,                 -- Start time of the meal (if available)
    time_end TIMESTAMPTZ,                   -- End time of the meal (if available)
    logged_food VARCHAR(255) NOT NULL,    -- Name of the food item logged
    amount DECIMAL(10, 2),                -- Amount of food
    unit VARCHAR(50),                     -- Unit of measurement (e.g., fluid ounce, cup)
    searched_food VARCHAR(255),           -- Name of the matched/searched food item
    calorie DECIMAL(10, 2),               -- Calorie content
    total_carb DECIMAL(10, 2),            -- Total carbohydrates
    dietary_fiber DECIMAL(10, 2),         -- Dietary fiber content
    sugar DECIMAL(10, 2),                 -- Sugar content
    protein DECIMAL(10, 2),               -- Protein content
    total_fat DECIMAL(10, 2)              -- Total fat content
);

CREATE TABLE heart_rate_data (
    datetime TIMESTAMPTZ,
    hr DECIMAL(5, 2)
);

CREATE TABLE ibi_data (
    event_time TIMESTAMPTZ,  -- Stores date and time with timezone info
    ibi NUMERIC(10, 6)       -- Allows up to 10 digits with 6 decimal places for precision
);

CREATE TABLE temperature_data (
    event_time TIMESTAMPTZ,  -- Stores date and time with timezone info
    temp NUMERIC(5, 2)       -- Allows up to 5 digits with 2 decimal places for precision (e.g., 999.99)
);
