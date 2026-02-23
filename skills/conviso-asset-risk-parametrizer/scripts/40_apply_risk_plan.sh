#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

COMPANY_ID=""
FILE=""
YES="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --company-id) COMPANY_ID="$2"; shift 2 ;;
    --file) FILE="$2"; shift 2 ;;
    --yes) YES="true"; shift ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done
[[ -n "$COMPANY_ID" && -n "$FILE" ]] || { echo "Usage: $0 --company-id <id> --file <csv> [--yes]" >&2; exit 1; }
require_file "$FILE"
"$(dirname "$0")/30_validate_risk_plan.sh" --file "$FILE"

if [[ "$YES" != "true" ]]; then
  echo "[preview] commands that would run:"
  python3 - "$COMPANY_ID" "$FILE" <<'PY'
import csv,sys
cid=sys.argv[1]
for r in csv.DictReader(open(sys.argv[2])):
    print("conviso assets update --id {id} --company-id {cid} --business-impact {bi} --data-classification {dc} --tags {tags} --environment-compromised {ec}".format(
      id=r["id"],cid=cid,bi=r["business_impact"],dc=r["data_classification"],tags=r["tags"],ec=r["environment_compromised"]))
PY
  exit 0
fi

python3 - "$FILE" <<'PY' | while IFS=$'\t' read -r aid bi dc tags ec; do
import csv,sys
for r in csv.DictReader(open(sys.argv[1])):
    print(f"{r['id']}\t{r['business_impact']}\t{r['data_classification']}\t{r['tags']}\t{r['environment_compromised']}")
PY
  run_cli assets update --id "$aid" --company-id "$COMPANY_ID" --business-impact "$bi" --data-classification "$dc" --tags "$tags" --environment-compromised "$ec"
done

echo "[apply] asset risk parameterization completed"
