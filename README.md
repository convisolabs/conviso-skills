# conviso-skills

Skills para LLMs operarem a Conviso Platform via `conviso-cli`, separados do repositório da CLI.

## Estrutura

- `skills/conviso-vuln-remediator/`: skill MVP de triagem e remediação de vulnerabilidades.

## Pré-requisitos

- Conviso CLI instalada (`conviso`) ou rodando com `python -m conviso.app`.
- Variáveis de ambiente da CLI configuradas (`CONVISO_API_KEY`, `CONVISO_API_URL` quando aplicável).
- `bash` e `python3`.

## Uso rápido

1. Abra o `SKILL.md` da skill desejada.
2. Siga o workflow e execute os scripts de `scripts/`.
3. Por padrão, as ações são somente leitura ou `dry-run`.

## Convenções

- Scripts falham rápido (`set -euo pipefail`).
- Saídas estruturadas são gravadas em `out/` dentro da própria skill.
- Ações mutáveis só com confirmação explícita no workflow.
