#!/bin/bash

# Check for required arguments
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <scale_factor>"
  echo "Example: $0 5"
  exit 1
fi

# Parameters
SCALE_FACTOR="$1"
OUTPUT_CSV="aggregated_results_sf${SCALE_FACTOR}.csv"

# Create CSV header if the file doesn't exist
if [ ! -f "$OUTPUT_CSV" ]; then
  echo "database,scale_factor,query_type,min,mean,median,max,stddev,sum,count,wall_clock_time" > "$OUTPUT_CSV"
fi

# Function to clean and convert units
convert_to_numeric() {
  local value="$1"
  if [[ "$value" == *ms ]]; then
    echo "${value%ms}"  # Remove "ms"
  elif [[ "$value" == *sec ]]; then
    awk -v v="${value%sec}" 'BEGIN { printf "%.3f", v * 1000 }'  # Convert "sec" to "ms"
  else
    echo "$value"  # Return as-is if no unit
  fi
}

# Process each .out file
for file in query_*.out; do
  # Determine database type from filename
  if [[ $file == query_influx* ]]; then
    DATABASE="influx"
  elif [[ $file == query_timescaledb* ]]; then
    DATABASE="timescaledb"
  else
    continue
  fi

  # Extract query type from filename
  QUERY_TYPE=$(echo "$file" | sed -E 's/query_(influx|timescaledb)_\1-(.+)-queries\.out/\2/')

  # Initialize variables
  MIN="" MEAN="" MEDIAN="" MAX="" STDDEV="" SUM="" COUNT="" WALL_CLOCK_TIME=""

  # Extract metrics (third line)
  METRICS_LINE=$(sed -n '3p' "$file")
  MIN=$(convert_to_numeric "$(echo "$METRICS_LINE" | grep -oP 'min:\s*\K[\d.]+ms')")
  MEAN=$(convert_to_numeric "$(echo "$METRICS_LINE" | grep -oP 'mean:\s*\K[\d.]+ms')")
  MEDIAN=$(convert_to_numeric "$(echo "$METRICS_LINE" | grep -oP 'med:\s*\K[\d.]+ms')")
  MAX=$(convert_to_numeric "$(echo "$METRICS_LINE" | grep -oP 'max:\s*\K[\d.]+ms')")
  STDDEV=$(convert_to_numeric "$(echo "$METRICS_LINE" | grep -oP 'stddev:\s*\K[\d.]+ms')")
  SUM=$(convert_to_numeric "$(echo "$METRICS_LINE" | grep -oP 'sum:\s*\K[\d.]+[a-z]+')")
  COUNT=$(echo "$METRICS_LINE" | grep -oP 'count:\s*\K\d+')

  # Extract wall clock time (last line)
  WALL_CLOCK_TIME=$(convert_to_numeric "$(tail -n 1 "$file" | grep -oP 'wall clock time:\s*\K[\d.]+sec')")

  # Append results to the CSV
  echo "$DATABASE,$SCALE_FACTOR,$QUERY_TYPE,$MIN,$MEAN,$MEDIAN,$MAX,$STDDEV,$SUM,$COUNT,$WALL_CLOCK_TIME" >> "$OUTPUT_CSV"
done

echo "Aggregation complete. Results saved to $OUTPUT_CSV"
