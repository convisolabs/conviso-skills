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

if [[ -z "$COMPANY_ID" ]]; then
  echo "Usage: $0 --company-id <id>" >&2
  exit 1
fi

require_env CONVISO_API_KEY
ensure_out_dir

command -v python3 >/dev/null || {
  echo "python3 is required" >&2
  exit 1
}

echo "[preflight] checking CLI availability..."
run_cli --help >/dev/null

echo "[preflight] validating access for company=$COMPANY_ID ..."
run_cli projects list --company-id "$COMPANY_ID" --limit 1 --format json >/dev/null

echo "[preflight] OK"
