#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

COMPANY_ID=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --company-id) COMPANY_ID="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done
[[ -n "$COMPANY_ID" ]] || { echo "Usage: $0 --company-id <id>" >&2; exit 1; }

ensure_out_dir
OUT="$(skill_root)/out/assets.json"
run_cli assets list --company-id "$COMPANY_ID" --all --format json --output "$OUT"
echo "[collect] wrote $OUT"
