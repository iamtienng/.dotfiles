---
name: pr
description: Prepare a branch for a pull request — run the project's formatter, linter, and tests, commit the work, then draft a PR summary (what changed, why, testing, impact). Use this whenever the user wants to open, create, or prepare a pull request or merge request, "get this ready to push", or do pre-PR cleanup. Detects the project's own tooling instead of assuming a fixed stack.
---

# Prepare a Pull Request

Get the current branch into a clean, reviewable state and produce a PR description. Work through the steps in order; don't skip the checks, because the whole point is to catch problems before a reviewer does.

## 1. Detect the project's tooling

Don't assume the stack. Look for how *this* project formats, lints, and tests, in roughly this order of authority:

- A task runner that already encodes the commands: `Makefile`, `Taskfile.yml`, `justfile`, `package.json` scripts, `pre-commit-config.yaml`.
- Language-native defaults if no runner is defined:
  - **Go** → `gofmt -l .` / `go vet ./...` / `go test ./...` (and `golangci-lint run` if configured)
  - **JS/TS** → the `lint`/`format`/`test` scripts in `package.json` (prettier/eslint/vitest/jest)
  - **Python** → `ruff`/`black` + `pytest` (or whatever `pyproject.toml` declares)
  - **Rust** → `cargo fmt` / `cargo clippy` / `cargo test`

Use what the repo actually configures. If you can't find a formatter/linter/test command, say so rather than inventing one.

## 2. Run the checks

Format, lint, then test. If any step fails, stop and fix it (or surface it to the user) — opening a PR on red is the thing this skill exists to prevent. Report what you ran and the result honestly; don't claim tests passed if you didn't run them.

## 3. Review and commit

Inspect `git diff HEAD` and `git status`. Stage the changes that belong to this PR and commit with a Conventional Commits message (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`). If a `commit` skill is available, you can use it for the message.

If the work isn't on a feature branch yet (i.e. you're on `main`/`master`), create one first.

## 4. Draft the PR summary

Produce a description the reviewer can actually use:

- **What changed** — the concrete changes, grouped logically.
- **Why** — the motivation or the issue/ticket it addresses.
- **Testing** — what you ran and what it covered (and anything you couldn't test).
- **Impact / risk** — migrations, config or env changes, breaking changes, rollout notes.

Hand the summary to the user. Only push or open the PR (via `gh`/`glab`) if the user asks — opening a PR is outward-facing, so confirm first unless they've already told you to.
