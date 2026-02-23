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
[[ -n "$FILE" ]] || { echo "Usage: $0 --file <asset_risk_plan.csv>" >&2; exit 1; }
require_file "$FILE"

python3 - "$FILE" <<'PY'
import csv, sys
from pathlib import Path

BI={"LOW","MEDIUM","HIGH","NOT_DEFINED"}
DC={"PERSONALLY_IDENTIFIABLE_INFORMATION","PAYMENT_CARD_INDUSTRY","NON_SENSITIVE","NOT_DEFINED"}

p=Path(sys.argv[1])
with p.open(newline="") as f:
    r=csv.DictReader(f)
    req={"id","business_impact","data_classification","tags","environment_compromised","reason"}
    headers=set(r.fieldnames or [])
    if not req.issubset(headers):
        raise SystemExit("Missing required headers")
    seen=set(); n=0
    for i,row in enumerate(r,2):
        n+=1
        if not row["id"].isdigit():
            raise SystemExit(f"Invalid id at line {i}")
        if row["id"] in seen:
            raise SystemExit(f"Duplicate id at line {i}")
        seen.add(row["id"])
        if row["business_impact"] not in BI:
            raise SystemExit(f"Invalid business_impact at line {i}")
        if row["data_classification"] not in DC:
            raise SystemExit(f"Invalid data_classification at line {i}")
        if row["environment_compromised"] not in {"true","false"}:
            raise SystemExit(f"Invalid environment_compromised at line {i}")
print(f"Risk plan validation OK: {n} row(s)")
PY
