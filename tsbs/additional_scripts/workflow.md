```bash
sudo apt-get update
sudo apt-get install -y timescaledb-postgresql-13
sudo timescaledb-tune --quiet --yes
sudo systemctl restart postgresql@13-main.service
```
```bash
sudo systemctl restart postgresql@13-main.service
psql -U postgres
DROP DATABASE benchmark WITH (FORCE);
CREATE DATABASE benchmark;
```

```bash
~/tsbs/scripts$ sudo nano queries.txt
```
```
last-loc
low-fuel
high-load
stationary-trucks
long-driving-sessions
long-daily-sessions
avg-vs-projected-fuel-consumption
avg-daily-driving-duration
avg-daily-driving-session
avg-load
daily-activity
breakdown-frequency
```

```bash
cd bin
./tsbs_generate_data --use-case="iot" --seed=123 --scale=SF \
  --timestamp-start="2016-01-01T00:00:00Z" --timestamp-end="2016-01-10T00:00:00Z" \
  --log-interval="1s" --format="timescaledb" > ../tmp/data_ts_sfX.txt

cat ../tmp/data_ts_sfX.txt | ./tsbs_load_timescaledb \
  --host="localhost" --port=5432 --user="postgres" --pass="mysecretpassword" \
  --db-name="benchmark" --workers=8

cd ../scripts
sudo nano generate_timescale_queries.sh
```

```bash
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
OUTPUT_DIR="../tmp/queries_timescaledb_sf${SCALE}"
TSBS_GENERATE_QUERIES="../bin/tsbs_generate_queries"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Loop through each query type in queries.txt
while IFS= read -r QUERY_TYPE; do
  echo "Generating queries for: $QUERY_TYPE (Scale: $SCALE, Database: TimescaleDB)"
  $TSBS_GENERATE_QUERIES --use-case="iot" \
  --seed=123 \
  --scale="$SCALE" \
  --timestamp-start="2016-01-01T00:00:00Z" \
  --timestamp-end="2016-01-10T00:00:00Z" \
  --queries=1000 \
  --query-type="$QUERY_TYPE" \
  --format="timescaledb" | gzip > "$OUTPUT_DIR/timescaledb-${QUERY_TYPE}-queries.gz"
done < "$QUERY_TYPES_FILE"

echo "Query generation complete. Files saved to: $OUTPUT_DIR"
```

```bash
chmod +x generate_timescale_queries.sh

cd ../scripts

./generate_timescale_queries.sh SF

python3 generate_run_script.py \
  -b 500 \
  -d timescaledb \
  -e '--postgres="host=localhost user=postgres password=mysecretpassword dbname=tsbs_test sslmode=disable"' \
  -f ./queries.txt \
  -l ../tmp \
  -n 500 \
  -o ../tmp/queries_timescaledb_sfX \
  -s localhost \
  -w 8 > ../tmp/query_test_timescaledb.sh

sudo nano query_test_timescaledb.sh
-> modify headline: ../scripts/load/load_timescaledb.sh

cd ../tmp
chmod +x ./query_test_timescaledb.sh
./query_test_timescaledb.sh

benchmark=# select
  table_name,
  pg_size_pretty(pg_total_relation_size(quote_ident(table_name))),
  pg_total_relation_size(quote_ident(table_name))
from information_schema.tables
where table_schema = 'public'
order by 3 desc;

benchmark=# SELECT
  hypertable_name,
  pg_size_pretty(hypertable_size(hypertable_name::text)) AS size
FROM
  timescaledb_information.hypertables
ORDER BY
  hypertable_size(hypertable_name::text) DESC;
```

```bash
influx
DROP DATABASE benchmark;
CREATE DATABASE benchmark;
SHOW DATABASES;

cd bin
./tsbs_generate_data --use-case="iot" --seed=123 --scale=SF \
  --timestamp-start="2016-01-01T00:00:00Z" --timestamp-end="2016-01-10T00:00:00Z" \
  --log-interval="1s" --format="influx" > ../tmp/data_in_sfX.txt

cat ../tmp/data_in_sfX.txt | ./tsbs_load_influx --urls=http://localhost:8086 \
  --db-name=benchmark --workers=8

cd ../scripts
sudo nano generate_influx_queries.sh
```

```bash
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
  --format="influx" > "$OUTPUT_DIR/influx-${QUERY_TYPE}-queries.txt"
done < "$QUERY_TYPES_FILE"

echo "Query generation complete. Files saved to: $OUTPUT_DIR"
```

```bash
chmod +x generate_influx_queries.sh

./generate_influx_queries.sh SF

python3 generate_run_script.py \
  -b 500 \
  -d influx \
  -e '--urls="http://localhost:8086" --db-name=benchmark' \
  -f ./queries.txt \
  -l ../tmp \
  -n 500 \
  -o ../tmp/queries_influx_sfX \
  -s localhost \
  -w 8 > ../tmp/query_test_influx.sh

sudo nano query_test_influx.sh
-> modify headline: ../scripts/load/load_influx.sh

chmod +x query_test_influx.sh

./query_test_influx.sh

sudo du -sh /var/lib/influxdb/data/benchmark
```

```bash
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
```

```bash
./aggregate_results.sh SF
```