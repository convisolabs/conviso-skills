#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

FILE=""
YES="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --file) FILE="$2"; shift 2 ;;
    --yes) YES="true"; shift ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done
[[ -n "$FILE" ]] || { echo "Usage: $0 --file <assignment_plan.csv> [--yes]" >&2; exit 1; }
require_file "$FILE"
"$(dirname "$0")/30_validate_assignment_plan.sh" --file "$FILE"

if [[ "$YES" != "true" ]]; then
  echo "[preview] commands that would run:"
  python3 - "$FILE" <<'PY'
import csv, sys
for row in csv.DictReader(open(sys.argv[1])):
    print(f"conviso vulns update --id {row['id']} --type {row['type']} --assignees {row['assignee']}")
PY
  exit 0
fi

python3 - "$FILE" <<'PY' | while IFS=$'\t' read -r issue_id vtype assignee; do
import csv, sys
for r in csv.DictReader(open(sys.argv[1])):
    print(f"{r['id']}\t{r['type']}\t{r['assignee']}")
PY
  run_cli vulns update --id "$issue_id" --type "$vtype" --assignees "$assignee"
done

echo "[apply] assignment updates completed"
