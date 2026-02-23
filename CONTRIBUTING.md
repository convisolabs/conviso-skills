# Contributing to conviso-skills

Thanks for contributing.

## Scope

This repository contains reusable skills for operating Conviso Platform through `conviso-cli`.

## Ground Rules

- Keep changes minimal and focused.
- Prefer extending existing skill patterns instead of introducing new conventions.
- Default to safe behavior:
  - preview/read-only first
  - explicit apply confirmation (`--yes`) for mutating operations
- Do not add secrets, customer data, or internal credentials.
- Keep examples synthetic and non-sensitive.

## Contribution Types

- New skills under `skills/<skill-name>/`
- Improvements to existing workflows
- Safety/validation enhancements
- Documentation fixes

## Required Skill Structure

- `SKILL.md` with frontmatter (`name`, `description`)
- `agents/openai.yaml`
- `scripts/` for deterministic, reusable execution
- `assets/` for templates and examples

## Pull Request Checklist

- Workflow is clear and reproducible.
- Scripts use safe defaults and explicit mutation gates.
- Validation steps are included.
- Documentation links are added when relevant.
- No unrelated files changed.

## Local Validation

Run at least:

```bash
# Syntax check all scripts
find skills -type f -path "*/scripts/*.sh" -print0 | xargs -0 -I{} bash -n {}
```

Optionally run skill-level offline smoke checks before opening PR.

## Security

If you find a security issue in scripts or workflows, avoid public disclosure in issues. Contact maintainers directly.
