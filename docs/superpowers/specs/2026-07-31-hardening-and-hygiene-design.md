# Hardening & Hygiene — Design

**Date:** 2026-07-31
**Status:** Approved design (Slice 2a of the improvement roadmap; D4 doctor mode is Slice 2b)
**Repo:** `iamtienng/.dotfiles` (public GitHub) — GNU Stow dotfiles for macOS, Arch Linux, WSL (Arch)

## Purpose

A cohesive batch of roadmap follow-ups that make the installer safer and the repo more
consistent, all low-risk and additive. Covers roadmap items A3, A4, C1, C3 (minimal), B5.
D4 (`install.sh --check` doctor mode) is deferred to its own slice.

Constraint: the repo is public; no change may add identity, secrets, or employer
references to tracked files.

## Baseline (grounded in the code)

- `install.sh` has exactly **one** `rm -rf` (line 338, in `prepare_config_entry`), reached
  only under `--replace-existing` (`REPLACE_EXISTING=1`, default 0).
- Dry-run **already** narrates remove-vs-backup (lines 325-331) — only the *actual*
  removal branch lacks a warning/prompt.
- Helpers are `log()` (stdout, `[dotfiles]` prefix) and `die()` (stderr, exit 1). **No
  `warn()`**, no color, no TTY check (`[ -t 0 ]`) anywhere.
- Only `macos/.stowrc` ignores `README.*\.md`; `common`/`arch`/`wsl`/`claude` do not.
- `.gitignore`s: root is generic; nested ones (`arch/hypr`, `common/k9s`, `common/zed`) are
  allowlist-style and MUST stay local. `common/nvim/.gitignore` is nvim-runtime artifacts
  plus one generic entry: `*.log`.
- README headings: `# Dotfiles` (1), `## Install` (13), `## Manual Stow` (96),
  `## Claude Code config` (114), `## Notes` (124). Root `CLAUDE.md` exists.
- CI (`.github/workflows/ci.yml`) has `shellcheck` + a `dry-run` matrix (ubuntu→arch,
  macos→macos).

---

## Component A3 — manifest checks in CI

**File:** `.github/workflows/ci.yml` (modify the existing `dry-run` matrix legs; no new job).

Add one validation step per leg, before or after the existing dry-run:

- **macOS leg** (`matrix.platform == macos`): `brew bundle list --file=macos/Brewfile`
  — parses the Brewfile and lists entries without installing; non-zero exit on a syntax error.
- **Ubuntu leg** (`matrix.platform == arch`): a shell step that, for each of
  `arch/pkglist.txt` and `wsl/pkglist.txt`, strips `#` comments and blank lines (mirroring
  `read_package_list`), asserts the result is non-empty, and asserts every remaining line
  matches a sane package-name charset (`^[A-Za-z0-9._+-]+$`); fail with a clear message otherwise.

Rationale for reusing the matrix legs: brew only exists on the macOS runner; the pkglists are
Linux packages. No extra runner spin-up.

## Component A4 — harden the `--replace-existing` removal

**File:** `install.sh` (add `warn()` near `log()`/`die()` ~line 32; modify the removal branch
at lines 325-338).

1. **Add `warn()`** — stderr, prominent prefix, no color (matches existing plain style):
   ```bash
   warn() {
     printf '[dotfiles] WARNING: %s\n' "$*" >&2
   }
   ```
2. **Sharpen the dry-run narration** (line 327): change
   `log "Would remove existing config: $target"` →
   `log "Would REMOVE (destructive) existing config: $target"`. Backup line unchanged.
3. **Guard the real removal** (lines 335-338). Before `rm -rf -- "$target"`:
   ```bash
   if [ "$REPLACE_EXISTING" -eq 1 ]; then
     warn "About to permanently delete: $target"
     if [ -t 0 ]; then
       printf '[dotfiles] Remove %s? [y/N] ' "$target" >&2
       read -r _reply
       case "$_reply" in
         y | Y | yes | YES) ;;
         *) die "aborted by user (existing config left untouched: $target)" ;;
       esac
     fi
     log "Removing existing config: $target"
     rm -rf -- "$target"
   else
     ...backup (unchanged)...
   fi
   ```
   - **Interactive (`[ -t 0 ]` true):** prompt; anything but yes → `die` (abort whole run,
     nothing deleted so far in this entry).
   - **Non-interactive (CI/pipe):** no prompt (never hangs); the loud `warn` still fires.
   - Keeps `set -euo pipefail` intact; `_reply` is local-scoped.

## Component C1 — unify `.stowrc` README ignore

**Files:** `common/.stowrc`, `arch/.stowrc`, `wsl/.stowrc`, `claude/.stowrc`.

Append `--ignore='README.*\.md'` to each (macOS already has it). Lets a README live in any
stow layer without being symlinked into `~/.config` / `~/.claude`. No functional change today
(no such READMEs exist), pure consistency/future-proofing.

## Component C3 — minimal `.gitignore` consolidation

**Files:** root `.gitignore`, `common/nvim/.gitignore`.

Hoist the one generic entry: add `**/*.log` to root `.gitignore` (under a `# Logs` comment)
and remove the `*.log` line from `common/nvim/.gitignore`. All other nested `.gitignore`s are
tool-specific allowlists and stay untouched. (Deliberately minimal — the structure is already
sound; this is the only sensible consolidation.)

## Component B5 — link CLAUDE.md from README

**File:** `README.md` (insert after the intro line, before `## Install`).

Add a one-line pointer:
```
> Architecture & conventions: see [CLAUDE.md](CLAUDE.md).
```
Defers architecture detail to `CLAUDE.md` instead of duplicating it in the README.

---

## Verification strategy

- **A3:** locally, `brew bundle list --file=macos/Brewfile` exits 0; the pkglist parse
  snippet exits 0 for both lists and fails on an injected bad line. YAML parses; CI green on push.
- **A4:** `printf 'n\n' | ./install.sh ...` path — simulate; unit-check the branch via a
  small harness: interactive-decline aborts, non-interactive proceeds without prompting,
  dry-run prints "Would REMOVE (destructive)". `shellcheck -S warning install.sh` stays clean.
- **C1:** `grep -c "README" */.stowrc` shows all five layers ignore READMEs; a temp
  `common/README.md` is NOT symlinked after a dry-run stow.
- **C3:** `git check-ignore some.log` is ignored from root; nvim `.gitignore` no longer lists `*.log`.
- **B5:** README contains a `[CLAUDE.md](CLAUDE.md)` link; markdown renders.
- Installer dry-run still exits 0 on both platforms (CI covers it).

## Out of scope (this slice)

- **D4** `install.sh --check` doctor mode — Slice 2b.
- A5 (`shfmt`/`.editorconfig`), B4 (WSL bootstrap restructure), C2 (manifest↔config audit),
  C4 (`.DS_Store` sweep), D2/D3 — not selected.
- Any change to `--replace-existing`'s single-flag contract beyond adding the guard.
