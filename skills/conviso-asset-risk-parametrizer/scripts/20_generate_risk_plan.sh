#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

INPUT=""
POLICY=""
TOP_N="500"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --input) INPUT="$2"; shift 2 ;;
    --policy-file) POLICY="$2"; shift 2 ;;
    --top) TOP_N="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

[[ -n "$INPUT" && -n "$POLICY" ]] || { echo "Usage: $0 --input <assets.json> --policy-file <csv> [--top N]" >&2; exit 1; }
require_file "$INPUT"
require_file "$POLICY"
ensure_out_dir
OUT="$(skill_root)/out/asset_risk_plan.csv"

python3 - "$INPUT" "$POLICY" "$OUT" "$TOP_N" <<'PY'
import csv, json, sys
from pathlib import Path

assets = json.loads(Path(sys.argv[1]).read_text())
policy = list(csv.DictReader(Path(sys.argv[2]).open()))
out = Path(sys.argv[3])
top_n = int(sys.argv[4])

policy = sorted(policy, key=lambda r: int((r.get("priority") or "999").strip() or "999"))

def split_tags(s):
    return [x.strip().lower() for x in (s or "").split(",") if x.strip()]

def match_rule(asset, rule):
    field = (rule.get("match_field") or "").strip().lower()
    value = (rule.get("match_value") or "").strip().lower()
    aname = (asset.get("name") or "").lower()
    atags = split_tags(asset.get("assetsTagList") or asset.get("tags") or "")
    if field == "asset_tag":
        return value in atags
    if field == "asset_name":
        return value in aname
    if field == "default" and value == "*":
        return True
    return False

rows=[]
for a in (assets if isinstance(assets, list) else [])[:top_n]:
    aid = str(a.get("id", "")).strip()
    if not aid.isdigit():
        continue
    matched=None
    for r in policy:
        if match_rule(a, r):
            matched=r
            break
    if not matched:
        continue
    rows.append({
      "id": aid,
      "business_impact": (matched.get("business_impact") or "").upper(),
      "data_classification": (matched.get("data_classification") or "").upper(),
      "tags": matched.get("tags") or "",
      "environment_compromised": (matched.get("environment_compromised") or "false").lower(),
      "reason": f"{matched.get('match_field')}={matched.get('match_value')}",
    })

with out.open("w", newline="") as f:
    w=csv.DictWriter(f, fieldnames=["id","business_impact","data_classification","tags","environment_compromised","reason"])
    w.writeheader()
    w.writerows(rows)

print(f"Risk plan rows: {len(rows)}")
PY

echo "[plan] wrote $OUT"
