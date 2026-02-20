# conviso-skills

Skills para LLMs operarem a Conviso Platform via `conviso-cli`, separados do repositório da CLI.

## Estrutura

- `skills/conviso-vuln-remediator/`: triagem + remediação com `preview-first` e `apply` explícito.

## Pré-requisitos

- Conviso CLI instalada (`conviso`) ou configurada em `CONVISO_CLI_BIN`.
- Variáveis da CLI (`CONVISO_API_KEY`, `CONVISO_API_URL` quando aplicável).
- `bash` e `python3`.

## Padrão de segurança

- Modo padrão: análise/read-only.
- Mutação: apenas com etapa explícita de `apply`.
- Preview obrigatório antes de `apply`.
