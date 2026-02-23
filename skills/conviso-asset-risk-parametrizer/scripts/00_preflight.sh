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

require_env CONVISO_API_KEY
ensure_out_dir
run_cli --help >/dev/null
run_cli assets list --company-id "$COMPANY_ID" --limit 1 --format json >/dev/null
echo "[preflight] OK"
