WITH movement_activity AS (
    SELECT
        participant_id,
        ts,
        GREATEST(ABS(acc_x), ABS(acc_y), ABS(acc_z)) AS max_acc,
        CASE 
            WHEN GREATEST(ABS(acc_x), ABS(acc_y), ABS(acc_z)) > 70 THEN 1
            ELSE 0
        END AS is_exercise
    FROM
        accelerometer_data
    WHERE
        acc_x IS NOT NULL AND acc_y IS NOT NULL AND acc_z IS NOT NULL
),
heart_rate_activity AS (
    SELECT
        participant_id,
        datetime AS ts,
        hr,
        CASE 
            WHEN hr > 120 THEN 1  -- Threshold for exercise heart rate
            ELSE 0
        END AS is_exercise
    FROM
        heart_rate_data
    WHERE
        hr IS NOT NULL
),
combined_activity AS (
    SELECT
        COALESCE(m.participant_id, h.participant_id) AS participant_id,
        COALESCE(m.ts, h.ts) AS ts,
        COALESCE(m.max_acc, 0) AS max_acc,
        COALESCE(h.hr, 0) AS hr,
        COALESCE(m.is_exercise, 0) + COALESCE(h.is_exercise, 0) AS exercise_score
    FROM
        movement_activity m
    FULL OUTER JOIN
        heart_rate_activity h
    ON
        m.participant_id = h.participant_id AND m.ts = h.ts
),
exercise_detection AS (
    SELECT
        participant_id,
        ts,
        max_acc,
        hr,
        exercise_score,
        CASE
            WHEN exercise_score >= 2 THEN 'Exercise'
            ELSE 'Rest'
        END AS activity_state
    FROM
        combined_activity
)
SELECT
    participant_id,
    ts,
    max_acc,
    hr,
    activity_state
FROM
    exercise_detection
WHERE
    activity_state = 'Exercise'
ORDER BY
    participant_id, ts;



