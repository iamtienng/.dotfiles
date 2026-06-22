---
name: setup-ci-cd
description: Set up CI/CD quality gates — pre-commit hooks plus CI workflows (GitHub Actions or the project's CI) for formatting, linting, security scanning, type-checking, and tests. Use this whenever the user wants to add CI, set up a pipeline, configure pre-commit hooks, automate checks on push/PR, or "add quality gates" to a repo. Detects the project's language and tooling and wires up matching checks.
---

# Setup CI/CD

Stand up automated quality gates so problems are caught before they land — locally at commit time, and again in CI on every push/PR. The two layers reinforce each other: pre-commit gives fast feedback, CI is the source of truth that can't be skipped.

## Steps

1. **Analyze the project.** Detect the language(s), framework, build system, package manager, and any tooling already configured. Respect what's there — extend existing configs rather than replacing them, and match the CI provider the project already uses (GitHub Actions, GitLab CI, etc.) instead of imposing one.

2. **Configure pre-commit hooks** with the right tools for the detected stack:
   - **Formatting** — Prettier / Black / gofmt / rustfmt / …
   - **Linting** — ESLint / Ruff / golangci-lint / Clippy / …
   - **Security** — gosec / Bandit / `cargo audit` / `npm audit` / dependency scanning
   - **Type checking** — tsc / mypy (where the language has it)
   - **Tests** — the fast unit suite (keep slow/integration tests for CI, not the commit hook)

   Prefer the `pre-commit` framework when it fits, or the ecosystem's native hook tooling (e.g. Husky + lint-staged for JS) when that's the convention.

3. **Create CI workflows** that mirror the pre-commit checks on push and PR, plus what local hooks can't cover: a build/test matrix across the supported language versions or platforms, and any deploy steps the project needs. Keep jobs parallel and cached so the pipeline stays fast — a slow pipeline gets bypassed.

4. **Verify.** Run the hooks and the checks locally to confirm they pass on a clean tree and *fail* on a deliberate violation — a gate that never fails isn't a gate. Then confirm the workflow is valid (e.g. open a test PR) before declaring it done.

Favor free/open-source tooling. Keep the config minimal and readable; every check should earn its place.
