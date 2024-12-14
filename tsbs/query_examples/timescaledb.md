### avg-daily-driving-duration
Query
```
WITH ten_minute_driving_sessions AS (
    SELECT time_bucket('10 minutes', time) AS ten_minutes, tags_id
    FROM readings
    GROUP BY tags_id, ten_minutes
    HAVING avg(velocity) > 1
),
daily_total_session AS (
    SELECT time_bucket('24 hours', ten_minutes) AS day, tags_id, count(*) / 6 AS hours
    FROM ten_minute_driving_sessions
    GROUP BY day, tags_id
)
SELECT t.fleet, t.name, t.driver, avg(d.hours) AS avg_daily_hours
FROM daily_total_session d
INNER JOIN tags t ON t.id = d.tags_id
GROUP BY fleet, name, driver
```

### avg-daily-driving-session
Query
```
WITH driver_status AS (
    SELECT tags_id, time_bucket('10 mins', time) AS ten_minutes, avg(velocity) > 5 AS driving
    FROM readings
    GROUP BY tags_id, ten_minutes
    ORDER BY tags_id, ten_minutes
),
driver_status_change AS (
    SELECT tags_id, ten_minutes AS start, lead(ten_minutes) OVER (PARTITION BY tags_id ORDER BY ten_minutes) AS stop, driving
    FROM (
        SELECT tags_id, ten_minutes, driving, lag(driving) OVER (PARTITION BY tags_id ORDER BY ten_minutes) AS prev_driving
        FROM driver_status
    ) x
    WHERE x.driving <> x.prev_driving
)
SELECT t.name, time_bucket('24 hours', start) AS day, avg(age(stop, start)) AS duration
FROM tags t
INNER JOIN driver_status_change d ON t.id = d.tags_id
WHERE d.driving = true
GROUP BY name, day
ORDER BY name, day
```

### avg-load
Query
```
SELECT t.fleet, t.model, t.load_capacity, avg(d.avg_load / t.load_capacity) AS avg_load_percentage
FROM tags t
INNER JOIN (
    SELECT tags_id, avg(current_load) AS avg_load
    FROM diagnostics
    GROUP BY tags_id
) d ON t.id = d.tags_id
GROUP BY fleet, model, load_capacity
```

### avg-vs-projected-fuel-consumption
Query
```
SELECT t.fleet, avg(r.fuel_consumption) AS avg_fuel_consumption, avg(t.nominal_fuel_consumption) AS projected_fuel_consumption
FROM tags t
INNER JOIN (
    SELECT tags_id, fuel_consumption
    FROM readings r
    WHERE velocity > 1
) r ON t.id = r.tags_id
GROUP BY fleet
```

### breakdown-frequency
Query
```
WITH breakdown_per_truck_per_ten_minutes AS (
    SELECT time_bucket('10 minutes', time) AS ten_minutes, tags_id, count(status = 0) / count(*) >= 0.5 AS broken_down
    FROM diagnostics
    GROUP BY ten_minutes, tags_id
),
breakdowns_per_truck AS (
    SELECT ten_minutes, tags_id, broken_down, lead(broken_down) OVER (
        PARTITION BY tags_id ORDER BY ten_minutes
    ) AS next_broken_down
    FROM breakdown_per_truck_per_ten_minutes
)
SELECT t.model, count(*)
FROM tags t
INNER JOIN breakdowns_per_truck b ON t.id = b.tags_id
WHERE broken_down = false AND next_broken_down = true
GROUP BY model
```

### daily-activity
Query
```
SELECT t.fleet, t.model, y.day, sum(y.ten_mins_per_day) / 144 AS daily_activity
FROM tags t
INNER JOIN (
    SELECT time_bucket('24 hours', time) AS day, time_bucket('10 minutes', time) AS ten_minutes, tags_id, count(*) AS ten_mins_per_day
    FROM diagnostics
    GROUP BY day, ten_minutes, tags_id
    HAVING avg(status) < 1
) y ON y.tags_id = t.id
GROUP BY fleet, model, y.day
ORDER BY y.day
```

### high-load
Query
```
SELECT t.name, t.driver, d.current_load, t.load_capacity
FROM tags t
INNER JOIN (
    SELECT current_load
    FROM diagnostics
    WHERE tags_id = t.id
    ORDER BY time DESC LIMIT 1
) d ON t.id = d.tags_id
WHERE d.current_load / t.load_capacity > 0.9
```

### last-loc
Query
```
SELECT t.name, t.driver, r.longitude, r.latitude
FROM tags t
INNER JOIN (
    SELECT longitude, latitude
    FROM readings
    WHERE tags_id = t.id
    ORDER BY time DESC LIMIT 1
) r ON t.id = r.tags_id
```

### long-daily-sessions
Query
```
WITH driving_sessions AS (
    SELECT time_bucket('10 minutes', time) AS ten_minutes, tags_id
    FROM readings
    WHERE velocity > 1
    GROUP BY ten_minutes, tags_id
),
daily_driving_sessions AS (
    SELECT time_bucket('24 hours', ten_minutes) AS day, tags_id, count(*) AS sessions
    FROM driving_sessions
    GROUP BY day, tags_id
)
SELECT t.name, t.driver
FROM tags t
INNER JOIN daily_driving_sessions d ON t.id = d.tags_id
WHERE d.sessions > calculated_value
```

### long-driving-sessions
Query
```
WITH driving_sessions AS (
    SELECT time_bucket('10 minutes', time) AS ten_minutes, tags_id
    FROM readings
    WHERE velocity > 1
    GROUP BY ten_minutes, tags_id
),
long_driving_sessions AS (
    SELECT time_bucket('4 hours', ten_minutes) AS session, tags_id, count(*) AS periods
    FROM driving_sessions
    GROUP BY session, tags_id
)
SELECT t.name, t.driver
FROM tags t
INNER JOIN long_driving_sessions d ON t.id = d.tags_id
WHERE d.periods > calculated_value
```

### low-fuel
Query
```
SELECT t.name, t.driver, d.fuel_state
FROM tags t
INNER JOIN (
    SELECT fuel_state
    FROM diagnostics
    WHERE tags_id = t.id
    ORDER BY time DESC LIMIT 1
) d ON t.id = d.tags_id
WHERE d.fuel_state < 0.1
```

### stationary-trucks
Query
```
SELECT t.name, t.driver
FROM tags t
INNER JOIN readings r ON r.tags_id = t.id
WHERE time >= 'start time' AND time < 'end time'
GROUP BY t.name, t.driver
HAVING avg(r.velocity) < 1
```