#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

COMPANY_ID=""
DAYS_BACK="30"
SEVERITIES="HIGH,CRITICAL"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --company-id) COMPANY_ID="$2"; shift 2 ;;
    --days-back) DAYS_BACK="$2"; shift 2 ;;
    --severities) SEVERITIES="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

[[ -n "$COMPANY_ID" ]] || { echo "Usage: $0 --company-id <id> [--days-back N] [--severities HIGH,CRITICAL]" >&2; exit 1; }

ensure_out_dir
ROOT="$(skill_root)"
RAW="$ROOT/out/candidate_vulns_raw.json"
OUT="$ROOT/out/candidate_vulns.json"

echo "[collect] company=$COMPANY_ID days_back=$DAYS_BACK severities=$SEVERITIES"
run_cli vulns list --company-id "$COMPANY_ID" --days-back "$DAYS_BACK" --severities "$SEVERITIES" --all --format json --output "$RAW"

python3 - "$RAW" "$OUT" <<'PY'
import json, re, sys
from pathlib import Path

raw = json.loads(Path(sys.argv[1]).read_text())
out = Path(sys.argv[2])

def norm_sev(v):
    return re.sub(r"\[[^\]]+\]", "", str(v or "")).strip().upper()

rows = []
for item in (raw if isinstance(raw, list) else []):
    assignee = (item.get("assignee") or "").strip()
    if assignee:
        continue
    rows.append({
        "id": str(item.get("id", "")).strip(),
        "title": str(item.get("title", ""))[:180],
        "type": str(item.get("type", "")).strip(),
        "severity": norm_sev(item.get("severity")),
        "status": str(item.get("status", "")).strip(),
        "asset": str(item.get("asset", "")).strip(),
        "tags": str(item.get("tags", "")).strip(),
    })

out.write_text(json.dumps(rows, indent=2, ensure_ascii=True))
print(f"Filtered unassigned candidates: {len(rows)}")
PY

echo "[collect] wrote $OUT"
