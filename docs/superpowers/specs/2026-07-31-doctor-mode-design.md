# `install.sh --check` Doctor Mode — Design

**Date:** 2026-07-31
**Status:** Approved design (Slice 2b; roadmap D4)
**Repo:** `iamtienng/.dotfiles` (public GitHub) — GNU Stow dotfiles for macOS, Arch Linux, WSL (Arch)

## Purpose

Add a read-only `--check` (doctor) mode to `install.sh` that audits an **existing**
installation for problems, without changing anything. It is the inverse of `--dry-run`:
dry-run validates a *clean* install would succeed; `--check` audits what's *already* on
disk. Exits non-zero if any issue is found, so it's scriptable.

Constraint: public repo — no identity/secret/employer strings in tracked files.

## Baseline (grounded)

- `install.sh` (`set -euo pipefail`) parses flags into `DRY_RUN`/`SKIP_*`/`REPLACE_EXISTING`
  (defaults near line 9), in a `while ... case "$1"` loop (~line 42), with a `usage()` heredoc.
- Helpers exist and are reused verbatim: `log()`, `die()`, `warn()`, `detect_platform()`
  (honors `DOTFILES_PLATFORM`), `config_entries()` (top-level entry names for given package
  dirs, excluding `.stowrc`/`.DS_Store`/`.gitignore`/`README*.md`, sorted-unique),
  `path_points_to_dotfiles()` (realpath under `$DOTFILES_DIR`), `is_managed_by_stow()`
  (target is a symlink into the repo, or a dir containing such symlinks).
- Targets: `CONFIG_HOME` (`${XDG_CONFIG_HOME:-$HOME/.config}`) and `CLAUDE_HOME`
  (`$HOME/.claude`). `main()` stows `common` + one detected OS package to `CONFIG_HOME`,
  and `claude` to `CLAUDE_HOME`.
- `--dry-run` short-circuits work paths; `main()` guards each phase on the flags.

## Behavior

`./install.sh --check`:
1. Parse `--check` → `CHECK=1` (new flag, default 0); documented in `usage()`.
2. In `main()`, after `platform=$(detect_platform)`, if `CHECK=1`: call `run_check "$platform"`
   and `return` its status — **before** any package/zsh/stow phase. Nothing is mutated.
3. `run_check` runs three checks, prints a grouped report, and returns 0 (healthy) or 1 (issues).

### Check 1 — broken symlinks
Walk `CONFIG_HOME` and `CLAUDE_HOME` for symlinks whose target does not exist:
`find "$dir" -type l` then test `[ ! -e "$link" ]` (portable; no GNU-only `-xtype`).
Report each broken link. (Guard: skip a target dir that doesn't exist.)

### Check 2 — entry health (drift + conflict preview in one pass)
For the entries the installer would stow — `config_entries "$DOTFILES_DIR/common" "$DOTFILES_DIR/$platform"`
against `CONFIG_HOME`, and `config_entries "$DOTFILES_DIR/claude"` against `CLAUDE_HOME` —
classify each `target = <home>/<entry>`:
- does not exist → **issue**: "would be created (not linked)";
- `is_managed_by_stow "$target"` → **OK**;
- exists but not managed → **issue**: "conflict — a real install would back this up".

### Check 3 — `~/.zshrc` health
- symlink resolving into the repo → **OK**;
- real file → **issue/warn**: "unmanaged (a real install leaves it untouched)";
- missing → **warn**: "not linked".

### Output & exit
Each check prints a header, an `OK` line per healthy item (or a single "all good" line), and
an issue line per problem. Final summary via `log`: `doctor: all checks passed` (exit 0) or
`doctor: N issue(s) found` (exit 1). All output is informational; nothing is written to disk.

## Explicitly NOT in CI

`--check` must **not** be added to the CI workflow. CI runners start with an empty
`~/.config`/`~/.claude`, so every expected entry would classify as drift and the mode would
exit 1 — a guaranteed false failure. `--check` is a local health tool; the CI dry-run already
covers the clean-install path. (Called out so it isn't "helpfully" added to the matrix later.)

## Verification strategy

- `shellcheck -S warning install.sh` → exit 0 (new `run_check` included).
- `--check` help: `./install.sh --help` lists `--check`.
- **Healthy case:** on this machine (dotfiles already stowed), `./install.sh --check` exits 0
  and reports managed entries OK. (May legitimately flag pre-existing unmanaged entries — that's
  a true finding, not a bug.)
- **Broken-link detection:** create a temp broken symlink under a temp `CONFIG_HOME` (via
  `HOME=$(mktemp -d)`) pointing at a missing repo file; `--check` reports it and exits 1.
- **Drift detection:** with a clean temp `HOME`, `DOTFILES_PLATFORM=arch ./install.sh --check`
  reports the expected entries as "would be created" and exits 1.
- **Non-mutating:** after any `--check` run, the temp `HOME` has no new `.backup.*` and no
  files were created/removed.

## Out of scope

- Auto-repair / `--fix` (doctor only reports). A future slice could add repair.
- Wiring `--check` into CI (see above).
- Any change to existing flags or the stow/backup logic.
