SELECT MIN(daily_avg_eda) AS min_daily_avg_eda
FROM (
    SELECT AVG(eda) AS daily_avg_eda
    FROM electrodermal_activity
    WHERE participant_id IN {{list_of_participants}}
    GROUP BY time_bucket('1 day', ts)
) subquery;