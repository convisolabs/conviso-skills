#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

INPUT=""
MAP_FILE=""
TOP_N="200"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --input) INPUT="$2"; shift 2 ;;
    --map-file) MAP_FILE="$2"; shift 2 ;;
    --top) TOP_N="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

[[ -n "$INPUT" && -n "$MAP_FILE" ]] || { echo "Usage: $0 --input <json> --map-file <csv> [--top N]" >&2; exit 1; }
require_file "$INPUT"
require_file "$MAP_FILE"
ensure_out_dir
ROOT="$(skill_root)"
OUT="$ROOT/out/assignment_plan.csv"

python3 - "$INPUT" "$MAP_FILE" "$OUT" "$TOP_N" <<'PY'
import csv, json, sys
from pathlib import Path

inp = json.loads(Path(sys.argv[1]).read_text())
map_rows = list(csv.DictReader(Path(sys.argv[2]).open()))
out = Path(sys.argv[3])
top_n = int(sys.argv[4])

def norm_type(t):
    t = (t or "").upper()
    m = {
      "WEB_VULNERABILITY":"WEB", "NETWORK_VULNERABILITY":"NETWORK", "SOURCE_CODE_VULNERABILITY":"SOURCE",
      "DAST_FINDING":"DAST", "SAST_FINDING":"SAST", "SCA_FINDING":"SCA", "IAC_FINDING":"IAC",
      "CONTAINER_FINDING":"CONTAINER", "SECRET_FINDING":"SECRET",
      "WEB":"WEB", "NETWORK":"NETWORK", "SOURCE":"SOURCE", "DAST":"DAST", "SAST":"SAST", "SCA":"SCA", "IAC":"IAC", "CONTAINER":"CONTAINER", "SECRET":"SECRET"
    }
    return m.get(t, "")

rules = sorted(map_rows, key=lambda r: int((r.get("priority") or "999").strip() or "999"))

def pick_assignee(v):
    tags = [x.strip().lower() for x in (v.get("tags") or "").split(",") if x.strip()]
    vtype = norm_type(v.get("type"))
    for r in rules:
        field = (r.get("match_field") or "").strip().lower()
        value = (r.get("match_value") or "").strip()
        email = (r.get("assignee_email") or "").strip()
        if not email:
            continue
        if field == "asset_tag" and value.lower() in tags:
            return email, f"asset_tag={value}"
        if field == "issue_type" and value.upper() == vtype:
            return email, f"issue_type={value.upper()}"
        if field == "default" and value == "*":
            return email, "default=*"
    return "", ""

rows = []
for v in inp[:top_n]:
    issue_id = str(v.get("id", "")).strip()
    if not issue_id.isdigit():
        continue
    t = norm_type(v.get("type"))
    if not t:
        continue
    assignee, reason = pick_assignee(v)
    if not assignee:
        continue
    rows.append({
      "id": issue_id,
      "type": t,
      "assignee": assignee,
      "severity": v.get("severity", ""),
      "title": (v.get("title", "") or "")[:120],
      "reason": reason,
    })

with out.open("w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=["id","type","assignee","severity","title","reason"])
    w.writeheader()
    w.writerows(rows)

print(f"Assignment plan rows: {len(rows)}")
PY

echo "[plan] wrote $OUT"
