#!/bin/bash

# Check for required arguments
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <scale>"
  echo "Example: $0 15"
  exit 1
fi

# Parameters
SCALE="$1"
QUERY_TYPES_FILE="./queries.txt"
OUTPUT_DIR="../tmp/queries_influx_sf${SCALE}"
TSBS_GENERATE_QUERIES="../bin/tsbs_generate_queries"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Loop through each query type in queries.txt
while IFS= read -r QUERY_TYPE; do
  echo "Generating queries for: $QUERY_TYPE (Scale: $SCALE, Database: InfluxDB)"
  $TSBS_GENERATE_QUERIES --use-case="iot" \
    --seed=123 \
    --scale="$SCALE" \
    --timestamp-start="2016-01-01T00:00:00Z" \
    --timestamp-end="2016-01-10T00:00:00Z" \
    --queries=1000 \
    --query-type="$QUERY_TYPE" \
    --format="influx" | gzip > "$OUTPUT_DIR/influx-${QUERY_TYPE}-queries.gz"
done < "$QUERY_TYPES_FILE"

echo "Query generation complete. Files saved to: $OUTPUT_DIR"

