#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

INPUT=""
TOP_N="25"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --input) INPUT="$2"; shift 2 ;;
    --top) TOP_N="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$INPUT" ]]; then
  echo "Usage: $0 --input <recent_vulns.json> [--top <n>]" >&2
  exit 1
fi

ensure_out_dir
ROOT="$(skill_root)"
OUT_JSON="$ROOT/out/prioritized_vulns.json"
OUT_MD="$ROOT/out/prioritized_vulns.md"

python3 - "$INPUT" "$OUT_JSON" "$OUT_MD" "$TOP_N" <<'PY'
import json
import sys
from pathlib import Path

inp = Path(sys.argv[1])
out_json = Path(sys.argv[2])
out_md = Path(sys.argv[3])
top_n = int(sys.argv[4])

def sev_score(v):
    sev = (v.get("severity") or "").upper()
    return {
        "CRITICAL": 4,
        "HIGH": 3,
        "MEDIUM": 2,
        "LOW": 1,
        "NOTIFICATION": 0,
    }.get(sev, 0)

raw = json.loads(inp.read_text())
if isinstance(raw, dict) and "items" in raw:
    items = raw.get("items", [])
elif isinstance(raw, list):
    items = raw
else:
    items = []

filtered = [x for x in items if (x.get("severity") or "").upper() in {"HIGH", "CRITICAL"}]
filtered.sort(key=lambda x: (sev_score(x), x.get("createdAt") or ""), reverse=True)
selected = filtered[:top_n]

out_json.write_text(json.dumps(selected, indent=2, ensure_ascii=True))

lines = [
    "# Prioritized Vulnerabilities",
    "",
    f"Total selected: {len(selected)}",
    "",
]

for idx, v in enumerate(selected, 1):
    lines.append(f"## {idx}. {(v.get('title') or 'Untitled').strip()}")
    lines.append(f"- id: {v.get('id', 'N/A')}")
    lines.append(f"- severity: {v.get('severity', 'N/A')}")
    lines.append(f"- createdAt: {v.get('createdAt', 'N/A')}")
    lines.append(f"- projectId: {v.get('projectId', 'N/A')}")
    lines.append(f"- assetId: {v.get('assetId', 'N/A')}")
    lines.append("")

out_md.write_text("\n".join(lines))
PY

echo "[prioritize] wrote $OUT_JSON"
echo "[prioritize] wrote $OUT_MD"
