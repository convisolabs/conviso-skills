#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

INPUT=""
TARGET_STATUS="IN_PROGRESS"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --input) INPUT="$2"; shift 2 ;;
    --status) TARGET_STATUS="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$INPUT" ]]; then
  echo "Usage: $0 --input <prioritized_vulns.json> [--status IN_PROGRESS]" >&2
  exit 1
fi

require_file "$INPUT"
ensure_out_dir
ROOT="$(skill_root)"
OUT_CSV="$ROOT/out/vulns_update_template.csv"

python3 - "$INPUT" "$OUT_CSV" "$TARGET_STATUS" <<'PY'
import csv
import json
import sys
from pathlib import Path

inp = Path(sys.argv[1])
out = Path(sys.argv[2])
target_status = sys.argv[3]
rows = json.loads(inp.read_text())
if not isinstance(rows, list):
    rows = []

fields = ["id", "status", "severity", "comment"]
with out.open("w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=fields)
    w.writeheader()
    for r in rows:
        w.writerow({
            "id": r.get("id", ""),
            "status": target_status,
            "severity": (r.get("severity") or "").upper(),
            "comment": "Prepared by conviso-vuln-remediator. Human validation required before apply.",
        })
PY

echo "[csv] wrote $OUT_CSV"
