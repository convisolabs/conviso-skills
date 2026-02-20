#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

COMPANY_ID=""
DAYS_BACK="7"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --company-id) COMPANY_ID="$2"; shift 2 ;;
    --days-back) DAYS_BACK="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$COMPANY_ID" ]]; then
  echo "Usage: $0 --company-id <id> [--days-back <n>]" >&2
  exit 1
fi

ensure_out_dir
ROOT="$(skill_root)"
OUT_JSON="$ROOT/out/recent_vulns.json"

CREATED_START="$(python3 - <<PY
from datetime import date, timedelta
print((date.today() - timedelta(days=int("$DAYS_BACK"))).isoformat())
PY
)"

echo "[collect] company=$COMPANY_ID created_start=$CREATED_START"
run_cli vulns list \
  --company-id "$COMPANY_ID" \
  --created-start "$CREATED_START" \
  --all \
  --format json \
  --output "$OUT_JSON"

echo "[collect] wrote $OUT_JSON"
