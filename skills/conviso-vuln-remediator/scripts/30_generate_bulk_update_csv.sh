#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

INPUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --input) INPUT="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$INPUT" ]]; then
  echo "Usage: $0 --input <prioritized_vulns.json>" >&2
  exit 1
fi

ensure_out_dir
ROOT="$(skill_root)"
OUT_CSV="$ROOT/out/vulns_update_template.csv"

python3 - "$INPUT" "$OUT_CSV" <<'PY'
import csv
import json
import sys
from pathlib import Path

inp = Path(sys.argv[1])
out = Path(sys.argv[2])
rows = json.loads(inp.read_text())
if not isinstance(rows, list):
    rows = []

# Conservative template for manual review before execution.
fields = ["id", "status", "severity", "comment"]
with out.open("w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=fields)
    w.writeheader()
    for r in rows:
      w.writerow({
          "id": r.get("id", ""),
          "status": "IN_PROGRESS",
          "severity": (r.get("severity") or "").upper(),
          "comment": "Reviewed by conviso-vuln-remediator skill; update after analyst validation.",
      })
PY

echo "[csv] wrote $OUT_CSV"
