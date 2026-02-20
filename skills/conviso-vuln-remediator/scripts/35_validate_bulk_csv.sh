#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --file) FILE="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$FILE" ]]; then
  echo "Usage: $0 --file <vulns_update_template.csv>" >&2
  exit 1
fi

require_file "$FILE"

python3 - "$FILE" <<'PY'
import csv
import sys
from pathlib import Path

file = Path(sys.argv[1])
required = {"id", "status", "severity", "comment"}

with file.open(newline="") as f:
    reader = csv.DictReader(f)
    rows = list(reader)
    headers = set(reader.fieldnames or [])
    if not required.issubset(headers):
        missing = sorted(required - headers)
        raise SystemExit(f"Missing required headers: {', '.join(missing)}")

    ids = []
    for idx, row in enumerate(rows, 2):
        v = (row.get("id") or "").strip()
        if not v.isdigit():
            raise SystemExit(f"Invalid id at CSV line {idx}: {v!r}")
        ids.append(int(v))

    if len(ids) != len(set(ids)):
        raise SystemExit("Duplicate vulnerability ids found in CSV")

print(f"CSV validation OK: {len(rows)} row(s)")
PY
