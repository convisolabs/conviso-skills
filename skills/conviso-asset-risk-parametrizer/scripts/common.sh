#!/usr/bin/env bash
set -euo pipefail

CONVISO_CLI_BIN="${CONVISO_CLI_BIN:-conviso}"

skill_root() { cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd; }
ensure_out_dir() { mkdir -p "$(skill_root)/out"; }
run_cli() { local -a c; read -r -a c <<< "$CONVISO_CLI_BIN"; "${c[@]}" "$@"; }
require_env() { [[ -n "${!1:-}" ]] || { echo "Missing required env var: $1" >&2; exit 1; }; }
require_file() { [[ -f "$1" ]] || { echo "File not found: $1" >&2; exit 1; }; }
