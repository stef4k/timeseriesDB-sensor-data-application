-- Glucose and Heart Rate Correlation Trend
SELECT 
    hrd.participant_id,
    time_bucket('1 hour', hrd.datetime) AS hour,
    ROUND(AVG(hrd.hr), 2) AS avg_heart_rate,
    ROUND(AVG(ig.glucose_value), 2) AS avg_glucose,
    CORR(hrd.hr, ig.glucose_value) AS hr_glucose_correlation
FROM heart_rate_data hrd
JOIN interstitial_glucose ig 
    ON hrd.participant_id = ig.participant_id 
    AND hrd.datetime BETWEEN ig.ts - INTERVAL '30 minutes' AND ig.ts + INTERVAL '30 minutes'
GROUP BY hrd.participant_id, hour