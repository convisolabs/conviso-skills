#!/usr/bin/env bash
set -euo pipefail

CONVISO_CLI_BIN="${CONVISO_CLI_BIN:-conviso}"

skill_root() {
  cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
}

ensure_out_dir() {
  local root
  root="$(skill_root)"
  mkdir -p "$root/out"
}

run_cli() {
  # Allow either a simple binary (default) or a compound command via bash -lc.
  if [[ "$CONVISO_CLI_BIN" == *" "* ]]; then
    bash -lc "$CONVISO_CLI_BIN $*"
  else
    "$CONVISO_CLI_BIN" "$@"
  fi
}

require_env() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    echo "Missing required env var: $name" >&2
    exit 1
  fi
}
