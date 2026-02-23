---
name: conviso-asset-risk-parametrizer
description: Standardize asset metadata used by risk scoring (business impact, data classification, tags) via conviso-cli with preview-first controls.
---

# Conviso Asset Risk Parametrizer

## Objective

Normalize asset attributes that influence risk scoring and prioritization.

## Setup

```bash
${CONVISO_CLI_BIN:-conviso} --help
```

Required authentication:

- `CONVISO_API_KEY`
- `CONVISO_API_URL` when needed

## Inputs

- `COMPANY_ID` (required)
- `TOP_N` (optional, default `500`)

## Safety Rules

- Default is plan/preview only.
- Apply requires explicit `--yes`.
- Do not use destructive asset operations in this skill.

## Workflow

1. Preflight

```bash
./scripts/00_preflight.sh --company-id "$COMPANY_ID"
```

2. Collect assets

```bash
./scripts/10_collect_assets.sh --company-id "$COMPANY_ID"
```

3. Generate risk parameterization plan from policy

```bash
./scripts/20_generate_risk_plan.sh --input out/assets.json --policy-file assets/risk_policy.csv --top "${TOP_N:-500}"
```

4. Validate plan

```bash
./scripts/30_validate_risk_plan.sh --file out/asset_risk_plan.csv
```

5. Preview

```bash
./scripts/40_apply_risk_plan.sh --company-id "$COMPANY_ID" --file out/asset_risk_plan.csv
```

6. Apply

```bash
./scripts/40_apply_risk_plan.sh --company-id "$COMPANY_ID" --file out/asset_risk_plan.csv --yes
```

## References

- [Conviso Platform Risk Score](https://docs.convisoappsec.com/platform/risk-score)
