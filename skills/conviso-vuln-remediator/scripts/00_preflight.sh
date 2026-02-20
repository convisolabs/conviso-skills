#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

require_env CONVISO_API_KEY
ensure_out_dir

echo "[preflight] checking CLI availability..."
if [[ "$CONVISO_CLI_BIN" == *" "* ]]; then
  bash -lc "$CONVISO_CLI_BIN --help" >/dev/null
else
  "$CONVISO_CLI_BIN" --help >/dev/null
fi

echo "[preflight] checking API access with a lightweight query..."
run_cli projects list --company-id 1 --limit 1 --format json >/dev/null || {
  echo "[preflight] warning: company-id 1 may be inaccessible."
  echo "[preflight] CLI is available, but validate scope with your target COMPANY_ID."
}

echo "[preflight] OK"
