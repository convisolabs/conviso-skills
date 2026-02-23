# conviso-skills

Skills for LLMs to operate the Conviso Platform through `conviso-cli`.

## Open Source and Contributions

This repository is intended for open collaboration.

- Contributions are welcome through pull requests.
- New skills should follow the existing structure and safety model.
- Use `CONTRIBUTING.md` for contribution rules and validation expectations.

## Project Links

- Repository: [convisolabs/conviso-skills](https://github.com/convisolabs/conviso-skills)
- Contribution Guide: [`CONTRIBUTING.md`](CONTRIBUTING.md)
- Issues: [github.com/convisolabs/conviso-skills/issues](https://github.com/convisolabs/conviso-skills/issues)

## Install via skills.sh

Install all skills from this repository:

```bash
npx skills add convisolabs/conviso-skills
```

Install a single skill:

```bash
npx skills add https://github.com/convisolabs/conviso-skills --skill conviso-vuln-remediator
npx skills add https://github.com/convisolabs/conviso-skills --skill conviso-vuln-assignee-manager
npx skills add https://github.com/convisolabs/conviso-skills --skill conviso-asset-risk-parametrizer
```

Note: skills.sh listing is driven by installs/usage telemetry, so publishing these commands helps discovery in the marketplace.

## What Is a Skill?

A skill is a reusable operational playbook for an LLM.

It packages:

- A defined workflow (step order and expected inputs/outputs).
- Safety rules (what is allowed, what requires explicit approval).
- Helper scripts and templates for repeatable execution.

In this repository, skills use the Conviso CLI as the execution engine, but add process and governance on top.

## Why Use Skills?

Use skills when you need reliable and scalable execution, not just raw command access.

Skills provide:

- Consistency: every run follows the same flow.
- Safety: preview-first and explicit approval for mutating actions.
- Speed: less ad-hoc decision-making during operations.
- Auditability: standardized artifacts (`json`, `md`, `csv`) for review and compliance.
- LLM readiness: clear guardrails that reduce operational mistakes.

## Structure

- `skills/conviso-vuln-remediator/`: triage + remediation with `preview-first` and explicit `apply`.
- `skills/conviso-vuln-assignee-manager/`: mapping-based ownership assignment for vulnerabilities.
- `skills/conviso-asset-risk-parametrizer/`: policy-based asset metadata normalization for risk scoring.

## Prerequisites

- Conviso CLI installed (`conviso`) or configured through `CONVISO_CLI_BIN`.
- CLI environment variables (`CONVISO_API_KEY`, `CONVISO_API_URL` when applicable).
- `bash` and `python3`.

## Install and Verify CLI

Install with your preferred method:

- Installed command: `conviso`
- From source (example): `CONVISO_CLI_BIN="python -m conviso.app"`

Verify before running any skill:

```bash
${CONVISO_CLI_BIN:-conviso} --help
${CONVISO_CLI_BIN:-conviso} projects list --company-id <company_id> --limit 1 --format json
```

## Security Pattern

- Default mode: analysis/read-only.
- Mutation: only through an explicit `apply` step.
- Preview is required before `apply`.

## Skill vs CLI

Using `conviso-cli` directly means running isolated commands. It is powerful, but it depends on operator experience to maintain order, validations, and safety on every run.

Using a skill means running a standardized workflow on top of the CLI:

- Defined execution sequence (`preflight` -> collect -> prioritize -> validate -> preview -> optional apply).
- Built-in guardrails (`preview-first`, `--yes` for mutations, CSV validation, and anti-unsafe-use rules for vulnerability text).
- Consistent outputs for review/audit (`out/*.json`, `out/*.md`, `out/*.csv`).

In short: the CLI is the base tool; the skill is the reliable operational playbook to scale usage across LLMs and AppSec teams.
