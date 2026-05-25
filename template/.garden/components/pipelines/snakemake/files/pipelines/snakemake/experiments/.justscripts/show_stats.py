import json
import sys

if len(sys.argv) != 2:
    print("Usage: python show_stats.py <log_dir>")
    sys.exit(1)

log_dir = sys.argv[1]
stats_path = f"{log_dir}/stats.json"

try:
    with open(stats_path) as f:
        stats = json.load(f)
        print(f'Total jobs: {stats.get("total_jobs", "N/A")}')
        print(f'Rules: {len(stats.get("rules", {}))}')
        print(f'Runtime: {stats.get("total_runtime", "N/A")} seconds')
except Exception as e:
    print(f"Error reading stats: {e}")
