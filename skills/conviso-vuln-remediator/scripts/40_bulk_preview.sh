#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

COMPANY_ID=""
FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --company-id) COMPANY_ID="$2"; shift 2 ;;
    --file) FILE="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$COMPANY_ID" || -z "$FILE" ]]; then
  echo "Usage: $0 --company-id <id> --file <csv>" >&2
  exit 1
fi

echo "[bulk-preview] running preview-only"
run_cli bulk vulns --company-id "$COMPANY_ID" --file "$FILE" --op update --preview-only
