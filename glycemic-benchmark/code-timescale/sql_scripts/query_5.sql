SELECT participant_id, MAX(temp) - MIN(temp) AS temp_diff
FROM temperature_data
GROUP BY participant_id;