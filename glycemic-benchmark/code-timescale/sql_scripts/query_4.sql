WITH movement_data AS (
  SELECT ts, participant_id, 
         acc_x, acc_y, acc_z, 
         SQRT(POWER(acc_x, 2) + POWER(acc_y, 2) + POWER(acc_z, 2)) AS movement
  FROM accelerometer_data
)
SELECT ts, participant_id, acc_x, acc_y, acc_z, MAX(movement) AS max_movement
FROM movement_data
GROUP BY ts, participant_id, acc_x, acc_y, acc_z;