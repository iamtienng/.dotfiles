# `install.sh --check` Doctor Mode Implementation Plan (Slice 2b)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a read-only `--check` (doctor) mode to `install.sh` that audits an existing installation for broken symlinks, unlinked/conflicting entries, and `~/.zshrc` health, exiting non-zero on any issue.

**Architecture:** One new flag `CHECK` that short-circuits `main()` after `detect_platform`, calling a new `run_check` (plus two small helpers) that reuse `config_entries`, `is_managed_by_stow`, and `path_points_to_dotfiles`. Nothing is mutated.

**Tech Stack:** Bash (target bash 3.2 on macOS — no `local -n`/`-xtype`), GNU Stow, ShellCheck.

## Global Constraints

- `install.sh` keeps `set -euo pipefail`; `shellcheck -S warning install.sh` must exit 0. (repo convention)
- Doctor mode is READ-ONLY: it must create/modify/delete nothing. (spec)
- Must work under macOS bash 3.2: no `local -n`, no GNU-only `find -xtype`. (grounded)
- `--check` must NOT be added to CI (clean runners would false-fail). (spec)
- Public repo: no identity/secret/employer strings. Conventional Commits.

---

### Task 1: Implement `--check` doctor mode

**Files:**
- Modify: `install.sh` — flag default (~line 13), `usage()` (~line 24), arg-parse case (~line 48), new functions before `main()` (~line 487), `main()` branch (~after line 493).

**Interfaces:**
- Produces: `./install.sh --check` runs `run_check "$platform"` and exits 0 (healthy) or 1 (issues), mutating nothing. Consumes existing `config_entries`, `is_managed_by_stow`, `path_points_to_dotfiles`, `CONFIG_HOME`, `CLAUDE_HOME`.

- [ ] **Step 1: Write the failing tests**

```bash
cd ~/project/personal/dev/.dotfiles
./install.sh --help 2>&1 | grep -q -- '--check' && echo "help PASS" || echo "help FAIL (expected)"
./install.sh --check --skip-packages --skip-zsh-tools >/dev/null 2>&1; echo "check-exit=$? (expect nonzero/unknown-option before impl)"
grep -q '^run_check()' install.sh && echo "fn PASS" || echo "fn FAIL (expected)"
```

- [ ] **Step 2: Run to verify FAIL**

Expected: `help FAIL (expected)`, an error/nonzero from the unknown `--check` option, `fn FAIL (expected)`.

- [ ] **Step 3: Add the `CHECK` default**

After `REPLACE_EXISTING=0` (~line 13) add:
```bash
CHECK=0
```

- [ ] **Step 4: Document it in `usage()`**

After the `--replace-existing` line in the `usage()` heredoc (~line 24) add:
```
  --check             Report config drift / broken symlinks (read-only); exit 1 if any found.
```

- [ ] **Step 5: Add the arg-parse arm**

After `--replace-existing) REPLACE_EXISTING=1 ;;` (~line 48) add:
```bash
  --check) CHECK=1 ;;
```

- [ ] **Step 6: Add the doctor functions before `main()`**

Immediately before the `main() {` line (~line 488), insert:
```bash
_doctor_issue() {
  warn "$*"
  _DOCTOR_ISSUES=$((_DOCTOR_ISSUES + 1))
}

_doctor_check_entries() {
  local home="$1"
  shift

  local name target
  while IFS= read -r name; do
    target="$home/$name"
    if [ ! -e "$target" ] && [ ! -L "$target" ]; then
      _doctor_issue "not linked (would be created): $target"
    elif is_managed_by_stow "$target"; then
      log "  ok: $target"
    else
      _doctor_issue "unmanaged (a real install would back this up): $target"
    fi
  done < <(config_entries "$@")
}

run_check() {
  local platform="$1"
  local dir link zt
  _DOCTOR_ISSUES=0

  log "doctor: read-only check of the existing installation"

  log "doctor: [1/3] broken symlinks under $CONFIG_HOME and $CLAUDE_HOME"
  for dir in "$CONFIG_HOME" "$CLAUDE_HOME"; do
    [ -d "$dir" ] || continue
    while IFS= read -r link; do
      [ -e "$link" ] && continue
      _doctor_issue "broken symlink: $link -> $(readlink "$link")"
    done < <(find "$dir" -type l 2>/dev/null)
  done

  log "doctor: [2/3] entry health (drift + conflicts)"
  _doctor_check_entries "$CONFIG_HOME" "$DOTFILES_DIR/common" "$DOTFILES_DIR/$platform"
  [ -d "$DOTFILES_DIR/claude" ] && _doctor_check_entries "$CLAUDE_HOME" "$DOTFILES_DIR/claude"

  log "doctor: [3/3] ~/.zshrc"
  zt="$HOME/.zshrc"
  if [ -L "$zt" ] && path_points_to_dotfiles "$zt"; then
    log "  ok: $zt"
  elif [ -e "$zt" ]; then
    _doctor_issue "~/.zshrc is a real file (a real install leaves it untouched): $zt"
  else
    _doctor_issue "~/.zshrc not linked: $zt"
  fi

  if [ "$_DOCTOR_ISSUES" -eq 0 ]; then
    log "doctor: all checks passed"
    return 0
  fi
  warn "doctor: $_DOCTOR_ISSUES issue(s) found"
  return 1
}
```
(`_DOCTOR_ISSUES` is a script global set by `run_check` before any helper reads it — bash 3.2 has no `local -n`, so a global accumulator is the portable choice. The `&&` in the main branch, next step, keeps `set -e` from aborting on a non-zero `run_check`.)

- [ ] **Step 7: Add the `main()` branch**

In `main()`, immediately after `log "Detected platform: $platform"` (~line 493) and before the `SKIP_PACKAGES` block, insert:
```bash
  if [ "$CHECK" -eq 1 ]; then
    run_check "$platform" && return 0
    return 1
  fi
```

- [ ] **Step 8: Verify PASS + shellcheck**

```bash
shellcheck -S warning install.sh; echo "shellcheck exit=$?"
./install.sh --help 2>&1 | grep -q -- '--check' && echo "help PASS" || echo "help FAIL"
grep -q '^run_check()' install.sh && echo "fn PASS" || echo "fn FAIL"
# On this machine (dotfiles already stowed) doctor should pass or report only TRUE findings:
./install.sh --check; echo "check-exit=$?"
```
Expected: `shellcheck exit=0`, `help PASS`, `fn PASS`. `--check` prints the 3-section report; exit 0 if the install is healthy (or 1 with concrete real findings — a true result, not a bug).

- [ ] **Step 9: Behavioral tests — broken link + drift + non-mutating (temp HOME)**

```bash
# (a) broken symlink is detected + exit 1
t=$(mktemp -d); mkdir -p "$t/.config/probe"
ln -s "$PWD/common/NOPE.nonexistent" "$t/.config/probe/dead"
HOME="$t" ./install.sh --check --skip-packages --skip-zsh-tools 2>&1 | grep -q "broken symlink" && echo "broken PASS" || echo "broken FAIL"
HOME="$t" ./install.sh --check >/dev/null 2>&1; echo "broken-exit=$? (expect 1)"
rm -rf "$t"
# (b) drift: clean HOME => expected entries reported as "would be created", exit 1
t=$(mktemp -d)
HOME="$t" DOTFILES_PLATFORM=arch ./install.sh --check 2>&1 | grep -q "would be created" && echo "drift PASS" || echo "drift FAIL"
HOME="$t" DOTFILES_PLATFORM=arch ./install.sh --check >/dev/null 2>&1; echo "drift-exit=$? (expect 1)"
# (c) non-mutating: no backups/files created in temp HOME
found=$(find "$t" -name '*.backup.*' 2>/dev/null); [ -z "$found" ] && echo "no-mutation PASS" || echo "no-mutation FAIL: $found"
rm -rf "$t"
```
Expected: `broken PASS`, `broken-exit=1`, `drift PASS`, `drift-exit=1`, `no-mutation PASS`.

- [ ] **Step 10: Commit**

```bash
git add install.sh
git commit -m "feat(install): add --check doctor mode (read-only drift/symlink audit)

New --check flag short-circuits main() after platform detection and runs
run_check: broken symlinks, per-entry drift/conflict classification, and
~/.zshrc health. Exits 1 on any issue. Reuses existing stow helpers; mutates
nothing. Not wired into CI (clean runners would false-fail)."
```

---

## Post-implementation verification

- [ ] `shellcheck -S warning install.sh common/scripts/tmux-sessionizer claude/statusline-command.sh` → exit 0.
- [ ] `./install.sh --dry-run --skip-packages --skip-zsh-tools` → exit 0 (unchanged path still works).
- [ ] `./install.sh --check` runs, prints the 3 sections, exits 0 on a healthy machine.
- [ ] Re-run the Step 9 temp-HOME broken/drift/non-mutation checks — all PASS.
- [ ] `git grep -nE "check" .github/workflows/ci.yml` shows `--check` was NOT added to CI.

## Self-Review

**Spec coverage:** flag + main short-circuit → Steps 3-7 ✓ · Check 1 broken symlinks → run_check [1/3] ✓ · Check 2 drift+conflict → `_doctor_check_entries` ✓ · Check 3 zshrc → run_check [3/3] ✓ · exit 0/1 + read-only → Steps 8-9 ✓ · not-in-CI → post-impl check ✓.

**Placeholder scan:** none — full function code given.

**Type/name consistency:** `CHECK` (default/arg/main) consistent; `run_check`/`_doctor_check_entries`/`_doctor_issue`/`_DOCTOR_ISSUES` consistent across steps; reuses `config_entries`/`is_managed_by_stow`/`path_points_to_dotfiles`/`CONFIG_HOME`/`CLAUDE_HOME`/`DOTFILES_DIR` exactly as defined in install.sh. bash-3.2-safe (global accumulator, `find -type l` + `[ ! -e ]`, `&&` to tame set -e).

## Out of scope
- `--fix`/auto-repair; wiring `--check` into CI; any change to existing flags or stow/backup logic.
