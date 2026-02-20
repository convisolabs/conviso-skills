# Conviso Vulnerability Remediator

## Objetivo

Executar um fluxo seguro e repetível de triagem de vulnerabilidades e preparação de remediação na Conviso Platform via CLI.

## Quando usar

- Quando precisar levantar vulnerabilidades recentes por empresa.
- Quando precisar priorizar HIGH/CRITICAL com contexto objetivo.
- Quando precisar preparar um plano de ação sem alterar dados em produção.

## Entradas esperadas

- `COMPANY_ID` (obrigatório)
- `DAYS_BACK` (opcional, padrão `7`)
- `TOP_N` (opcional, padrão `25`)
- `CONVISO_CLI_BIN` (opcional, padrão `conviso`)

## Guardrails

- Fluxo padrão é read-only + arquivos locais.
- Qualquer ação mutável deve passar por `preview-only` primeiro.
- Nunca executar deleções em lote sem confirmação humana explícita.

## Workflow

1. Preflight (valida ambiente e acesso)

```bash
./scripts/00_preflight.sh
```

2. Coleta vulnerabilidades recentes (JSON bruto)

```bash
./scripts/10_collect_recent_vulns.sh --company-id "$COMPANY_ID" --days-back "${DAYS_BACK:-7}"
```

Saída:
- `out/recent_vulns.json`

3. Priorização automática (HIGH/CRITICAL + score simples)

```bash
./scripts/20_prioritize_vulns.sh --input out/recent_vulns.json --top "${TOP_N:-25}"
```

Saídas:
- `out/prioritized_vulns.json`
- `out/prioritized_vulns.md`

4. Gerar CSV de atualização para bulk (não aplica nada)

```bash
./scripts/30_generate_bulk_update_csv.sh --input out/prioritized_vulns.json
```

Saída:
- `out/vulns_update_template.csv`

5. Rodar preview no bulk (sem mutação)

```bash
./scripts/40_bulk_preview.sh --company-id "$COMPANY_ID" --file out/vulns_update_template.csv
```

## Resultado esperado

- Lista priorizada de vulnerabilidades acionáveis.
- CSV pronto para revisão humana e execução posterior.
- Preview da operação em lote sem alteração de estado.

## Limitações

- O schema de update pode variar conforme evolução da CLI/backend.
- O script gera um template conservador para revisão manual antes de aplicar.
