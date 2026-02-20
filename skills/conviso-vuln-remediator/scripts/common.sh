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
  local -a cli_cmd
  if [[ -z "$CONVISO_CLI_BIN" ]]; then
    echo "CONVISO_CLI_BIN cannot be empty" >&2
    exit 1
  fi
  # Split binary + fixed args safely (no eval / no shell expansion).
  read -r -a cli_cmd <<< "$CONVISO_CLI_BIN"
  "${cli_cmd[@]}" "$@"
}

require_env() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    echo "Missing required env var: $name" >&2
    exit 1
  fi
}

require_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo "File not found: $file" >&2
    exit 1
  fi
}
