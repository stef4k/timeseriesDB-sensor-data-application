### avg-daily-driving-duration
Query
```
SELECT count("mv") / 6 as "hours driven"
FROM (
    SELECT mean("velocity") as "mv"
    FROM "readings"
    WHERE time > 'start time' AND time < 'end time'
    GROUP BY time(10m), "fleet", "name", "driver"
)
WHERE time > 'start time' AND time < 'end time'
GROUP BY time(1d), "fleet", "name", "driver"
```

### avg-daily-driving-session
Query
```
SELECT mean("elapsed")
FROM (
    SELECT difference("difka"), elapsed("difka", 1m)
    FROM (
        SELECT difference("mv") AS "difka"
        FROM (
            SELECT floor(mean("velocity") / 10) AS "mv"
            FROM "readings"
            WHERE "name" != '' AND time > 'start time' AND time < 'end time'
            GROUP BY time(10m), "name" fill(0)
        )
        WHERE "difka" != 0
    )
)
GROUP BY time(1d), "name"
```

### avg-load
Query
```
SELECT mean("ml") AS mean_load_percentage
FROM (
    SELECT "current_load" / "load_capacity" AS "ml"
    FROM "diagnostics"
    GROUP BY "name", "fleet", "model"
)
GROUP BY "fleet", "model"
```

### avg-vs-projected-fuel-consumption
Query
```
SELECT mean("fuel_consumption") AS "mean_fuel_consumption", mean("nominal_fuel_consumption") AS "nominal_fuel_consumption"
FROM "readings"
WHERE "velocity" > 1
GROUP BY "fleet"
```

### breakdown-frequency
Query
```
SELECT count("state_changed")
FROM (
    SELECT difference("broken_down") AS "state_changed"
    FROM (
        SELECT floor(2 * (sum("nzs") / count("nzs"))) AS "broken_down"
        FROM (
            SELECT "status" AS nzs
            FROM "diagnostics"
            WHERE time >= 'start time' AND time < 'end time'
        )
        WHERE time >= 'start time' AND time < 'end time'
    )
)
WHERE "state_changed" = 1
GROUP BY "model"
```

### daily-activity
Query
```
SELECT count("ms") / 144
FROM (
    SELECT mean("status") AS ms
    FROM "diagnostics"
    WHERE time >= 'start time' AND time < 'end time'
    GROUP BY time(10m), "model", "fleet"
)
WHERE time >= 'start time' AND time < 'end time' AND "ms" < 1
GROUP BY time(1d), "model", "fleet"
```

### high-load
Query
```
SELECT "name", "driver", "current_load", "load_capacity"
FROM (
    SELECT "current_load", "load_capacity"
    FROM "diagnostics"
    WHERE fleet = 'random fleet'
    GROUP BY "name", "driver"
)
WHERE "current_load" >= 0.9 * "load_capacity"
GROUP BY "name"
ORDER BY "time" DESC
```

### last-loc
Query
```
SELECT "name", "driver", "latitude", "longitude"
FROM "readings"
WHERE (specific truck filter conditions)
ORDER BY "time"
LIMIT 1
```

### long-daily-sessions
Query
```
SELECT "name", "driver"
FROM (
    SELECT count(*) AS ten_min
    FROM (
        SELECT mean("velocity") AS mean_velocity
        FROM "readings"
        WHERE "fleet" = 'random fleet' AND time > 'start time' AND time <= 'end time'
        GROUP BY time(10m), "name", "driver"
    )
    WHERE "mean_velocity" > 1
)
WHERE ten_min > calculated value
```

### long-driving-sessions
Query
```
SELECT "name", "driver"
FROM (
    SELECT count(*) AS ten_min
    FROM (
        SELECT mean("velocity") AS mean_velocity
        FROM "readings"
        WHERE "fleet" = 'random fleet' AND time > 'start time' AND time <= 'end time'
        GROUP BY time(10m), "name", "driver"
    )
    WHERE "mean_velocity" > 1
)
WHERE ten_min > calculated value
```

### low-fuel
Query
```
SELECT "name", "driver", "fuel_state"
FROM "diagnostics"
WHERE "fuel_state" <= 0.1 AND "fleet" = 'random fleet'
GROUP BY "name"
ORDER BY "time" DESC
```

### stationary-trucks
Query
```
SELECT "name", "driver"
FROM (
    SELECT mean("velocity") AS mean_velocity
    FROM "readings"
    WHERE time > 'start time' AND time <= 'end time'
    GROUP BY time(10m), "name", "driver", "fleet"
)
WHERE "fleet" = 'random fleet' AND "mean_velocity" < 1
GROUP BY "name"
```
