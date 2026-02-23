#!/usr/bin/env bash
set -euo pipefail

CONVISO_CLI_BIN="${CONVISO_CLI_BIN:-conviso}"

skill_root() {
  cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
}

ensure_out_dir() {
  mkdir -p "$(skill_root)/out"
}

run_cli() {
  local -a cli_cmd
  read -r -a cli_cmd <<< "$CONVISO_CLI_BIN"
  "${cli_cmd[@]}" "$@"
}

require_env() {
  local name="$1"
  [[ -n "${!name:-}" ]] || { echo "Missing required env var: $name" >&2; exit 1; }
}

require_file() {
  [[ -f "$1" ]] || { echo "File not found: $1" >&2; exit 1; }
}
