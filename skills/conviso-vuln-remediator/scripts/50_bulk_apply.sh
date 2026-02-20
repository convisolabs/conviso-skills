#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

COMPANY_ID=""
FILE=""
YES="false"
FORCE="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --company-id) COMPANY_ID="$2"; shift 2 ;;
    --file) FILE="$2"; shift 2 ;;
    --yes) YES="true"; shift ;;
    --force) FORCE="true"; shift ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$COMPANY_ID" || -z "$FILE" ]]; then
  echo "Usage: $0 --company-id <id> --file <csv> --yes [--force]" >&2
  exit 1
fi

if [[ "$YES" != "true" ]]; then
  echo "Refusing to apply without explicit --yes" >&2
  exit 1
fi

"$(dirname "$0")/35_validate_bulk_csv.sh" --file "$FILE"

echo "[bulk-apply] applying updates (mutable operation)"
if [[ "$FORCE" == "true" ]]; then
  run_cli bulk vulns --company-id "$COMPANY_ID" --file "$FILE" --op update --force
else
  run_cli bulk vulns --company-id "$COMPANY_ID" --file "$FILE" --op update
fi
