# Example Session

```bash
export CONVISO_API_KEY=***
export COMPANY_ID=443

cd skills/conviso-vuln-remediator
./scripts/00_preflight.sh --company-id "$COMPANY_ID"
./scripts/10_collect_recent_vulns.sh --company-id "$COMPANY_ID" --days-back 7
./scripts/20_prioritize_vulns.sh --input out/recent_vulns.json --top 25
./scripts/30_generate_bulk_update_csv.sh --input out/prioritized_vulns.json
./scripts/35_validate_bulk_csv.sh --file out/vulns_update_template.csv
./scripts/40_bulk_preview.sh --company-id "$COMPANY_ID" --file out/vulns_update_template.csv
# optional:
./scripts/50_bulk_apply.sh --company-id "$COMPANY_ID" --file out/vulns_update_template.csv --yes
```
