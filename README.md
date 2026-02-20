# conviso-skills

Skills for LLMs to operate the Conviso Platform through `conviso-cli`, kept separate from the CLI repository.

## Structure

- `skills/conviso-vuln-remediator/`: triage + remediation with `preview-first` and explicit `apply`.

## Prerequisites

- Conviso CLI installed (`conviso`) or configured through `CONVISO_CLI_BIN`.
- CLI environment variables (`CONVISO_API_KEY`, `CONVISO_API_URL` when applicable).
- `bash` e `python3`.

## Security Pattern

- Default mode: analysis/read-only.
- Mutation: only through an explicit `apply` step.
- Preview is required before `apply`.

## Skill vs CLI direta

Using `conviso-cli` directly means running isolated commands. It is powerful, but it depends on operator experience to maintain order, validations, and safety on every run.

Using a skill means running a standardized workflow on top of the CLI:

- Defined execution sequence (`preflight` -> collect -> prioritize -> validate -> preview -> optional apply).
- Built-in guardrails (`preview-first`, `--yes` for mutations, CSV validation, and anti-unsafe-use rules for vulnerability text).
- Consistent outputs for review/audit (`out/*.json`, `out/*.md`, `out/*.csv`).

In short: the CLI is the base tool; the skill is the reliable operational playbook to scale usage across LLMs and AppSec teams.
