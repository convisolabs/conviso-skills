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
[[ -n "$FILE" ]] || { echo "Usage: $0 --file <assignment_plan.csv>" >&2; exit 1; }
require_file "$FILE"

python3 - "$FILE" <<'PY'
import csv, re, sys
from pathlib import Path

p=Path(sys.argv[1])
with p.open(newline="") as f:
    r=csv.DictReader(f)
    req={"id","type","assignee","severity","title","reason"}
    headers=set(r.fieldnames or [])
    missing=req-headers
    if missing:
        raise SystemExit(f"Missing headers: {', '.join(sorted(missing))}")
    seen=set(); n=0
    for i,row in enumerate(r,2):
        n+=1
        if not (row.get("id") or "").isdigit():
            raise SystemExit(f"Invalid id at line {i}")
        if row["id"] in seen:
            raise SystemExit(f"Duplicate id at line {i}")
        seen.add(row["id"])
        if "@" not in (row.get("assignee") or ""):
            raise SystemExit(f"Invalid assignee email at line {i}")
print(f"Plan validation OK: {n} row(s)")
PY
