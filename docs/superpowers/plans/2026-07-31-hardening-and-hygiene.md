# Hardening & Hygiene Implementation Plan (Slice 2a)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the installer's destructive path safe, validate manifests in CI, and tidy stow/gitignore/README consistency — all additive, low-risk.

**Architecture:** Small edits to `install.sh` (one guarded `rm -rf`), `.github/workflows/ci.yml` (validation steps on existing legs), four `.stowrc` files, two `.gitignore` files, and `README.md`. No control-flow or contract changes beyond the A4 guard.

**Tech Stack:** Bash, GNU Stow, GitHub Actions, ShellCheck.

## Global Constraints

- Bash keeps `set -euo pipefail`; ShellCheck (`-S warning`) must stay clean on `install.sh`. (repo convention)
- Public repo: no identity/secret/employer strings in tracked files. (spec)
- Conventional Commits (`feat:`/`ci:`/`fix:`/`docs:`/`chore:`). (repo convention)
- The installer runs unattended and is dry-run'd in CI: the A4 prompt must NOT fire when stdin is not a TTY. (spec, locked)
- `--replace-existing` keeps its single-flag contract; A4 only adds a guard. (spec)

---

### Task 1: A4 — guard the `--replace-existing` removal

**Files:**
- Modify: `install.sh` (add `warn()` after `die()` ~line 36; edit dry-run line ~327; guard removal branch ~335-338)

**Interfaces:**
- Produces: a `warn()` helper (stderr, `WARNING:` prefix); a TTY-gated confirmation before the sole `rm -rf`.

- [ ] **Step 1: Write the failing tests (behavioral harness)**

```bash
cd ~/project/personal/dev/.dotfiles
# (a) dry-run wording
grep -q 'Would REMOVE (destructive) existing config' install.sh && echo "a PASS" || echo "a FAIL (expected)"
# (b) warn helper exists
grep -q '^warn() {' install.sh && echo "b PASS" || echo "b FAIL (expected)"
# (c) TTY guard present on the destructive path
grep -q '\[ -t 0 \]' install.sh && echo "c PASS" || echo "c FAIL (expected)"
```

- [ ] **Step 2: Run to verify all FAIL**

Expected: `a FAIL (expected)`, `b FAIL (expected)`, `c FAIL (expected)`.

- [ ] **Step 3: Add the `warn()` helper**

After the `die()` function (ends `}` at line 36), add:
```bash

warn() {
  printf '[dotfiles] WARNING: %s\n' "$*" >&2
}
```

- [ ] **Step 4: Sharpen the dry-run narration**

Replace (line ~327):
```bash
      log "Would remove existing config: $target"
```
with:
```bash
      log "Would REMOVE (destructive) existing config: $target"
```

- [ ] **Step 5: Guard the real removal branch**

Replace the removal branch (lines ~335-338):
```bash
  if [ "$REPLACE_EXISTING" -eq 1 ]; then
    log "Removing existing config: $target"

    rm -rf -- "$target"
```
with:
```bash
  if [ "$REPLACE_EXISTING" -eq 1 ]; then
    local _reply
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
```
(The `else` backup branch is unchanged.)

- [ ] **Step 6: Run tests + ShellCheck to verify PASS**

```bash
grep -q 'Would REMOVE (destructive) existing config' install.sh && echo "a PASS" || echo "a FAIL"
grep -q '^warn() {' install.sh && echo "b PASS" || echo "b FAIL"
grep -q '\[ -t 0 \]' install.sh && echo "c PASS" || echo "c FAIL"
shellcheck -S warning install.sh; echo "shellcheck exit=$?"
```
Expected: `a/b/c PASS`, `shellcheck exit=0`.

- [ ] **Step 7: Behavioral check — non-interactive does NOT hang, dry-run narrates**

```bash
# dry-run narration (safe; mutates nothing)
mkdir -p /tmp/a4test/.config/__probe && HOME=/tmp/a4test \
  DOTFILES_PLATFORM=macos ./install.sh --dry-run --skip-packages --skip-zsh-tools --replace-existing 2>&1 \
  | grep -q "Would REMOVE (destructive)" && echo "dry-run narrates PASS" || echo "dry-run narrates (n/a if no managed conflict)"
# non-interactive real path must not block on a prompt (piped stdin => [ -t 0 ] false).
# Verified by inspection: the read is inside `if [ -t 0 ]`. shellcheck-clean above confirms syntax.
rm -rf /tmp/a4test
echo "note: interactive y/N decline is verified manually in a real terminal"
```
Expected: no hang; dry-run wording present when a managed entry would be replaced.

- [ ] **Step 8: Commit**

```bash
git add install.sh
git commit -m "fix(install): guard --replace-existing rm -rf with warn + TTY prompt

Loud WARNING before the sole rm -rf; interactive y/N (aborts on no);
non-interactive runs skip the prompt so CI/automation never hang.
Dry-run now labels the destructive path explicitly."
```

---

### Task 2: A3 — validate manifests in CI

**Files:**
- Modify: `.github/workflows/ci.yml` (add a validation step to each `dry-run` matrix leg)

**Interfaces:**
- Consumes: existing `dry-run` matrix (`ubuntu-latest`+`arch`, `macos-latest`+`macos`).
- Produces: Brewfile parse check (macOS leg) + pkglist parse check (Ubuntu leg).

- [ ] **Step 1: Validate manifests locally first (the test)**

```bash
brew bundle list --file=macos/Brewfile >/dev/null && echo "Brewfile PASS" || echo "Brewfile FAIL"
for f in arch/pkglist.txt wsl/pkglist.txt; do
  n=$(grep -vE '^\s*#|^\s*$' "$f" | wc -l | tr -d ' ')
  bad=$(grep -vE '^\s*#|^\s*$' "$f" | grep -vE '^[A-Za-z0-9._+-]+$' || true)
  [ "$n" -gt 0 ] && [ -z "$bad" ] && echo "$f PASS ($n pkgs)" || echo "$f FAIL: $bad"
done
```
Expected: `Brewfile PASS`, both pkglists `PASS`.

- [ ] **Step 2: Add the Brewfile step to the macOS leg**

In `.github/workflows/ci.yml`, in the `dry-run` job, after the `Install GNU Stow (macOS)` step, add:
```yaml
      - name: Validate Brewfile parses
        if: matrix.platform == 'macos'
        run: brew bundle list --file=macos/Brewfile >/dev/null
```

- [ ] **Step 3: Add the pkglist step to the Ubuntu leg**

After the `Install GNU Stow (Linux)` step, add:
```yaml
      - name: Validate package lists parse
        if: matrix.platform == 'arch'
        run: |
          for f in arch/pkglist.txt wsl/pkglist.txt; do
            entries=$(grep -vE '^\s*#|^\s*$' "$f")
            [ -n "$entries" ] || { echo "::error::$f has no packages"; exit 1; }
            bad=$(printf '%s\n' "$entries" | grep -vE '^[A-Za-z0-9._+-]+$' || true)
            [ -z "$bad" ] || { echo "::error::$f has malformed entries: $bad"; exit 1; }
            echo "$f OK"
          done
```

- [ ] **Step 4: Validate YAML parses**

```bash
python3 -c "import yaml; d=yaml.safe_load(open('.github/workflows/ci.yml')); print(sorted(d['jobs'].keys()))"
```
Expected: `['dry-run', 'shellcheck']`.

- [ ] **Step 5: Commit**

```bash
git add .github/workflows/ci.yml
git commit -m "ci: validate Brewfile and pkglists parse in the dry-run legs"
```

---

### Task 3: C1 — unify `.stowrc` README ignore

**Files:**
- Modify: `common/.stowrc`, `arch/.stowrc`, `wsl/.stowrc`, `claude/.stowrc`

**Interfaces:**
- Produces: all five layers ignore `README.*\.md` when stowing.

- [ ] **Step 1: Show the gap (test)**

```bash
for f in common/.stowrc macos/.stowrc arch/.stowrc wsl/.stowrc claude/.stowrc; do
  grep -q "README" "$f" && echo "$f: has README ignore" || echo "$f: MISSING"
done
```
Expected: only `macos/.stowrc: has README ignore`; the other four `MISSING`.

- [ ] **Step 2: Append the ignore to the four files**

To each of `common/.stowrc`, `arch/.stowrc`, `wsl/.stowrc`, `claude/.stowrc`, append after the existing `--ignore='\.gitignore'` line:
```
--ignore='README.*\.md'
```

- [ ] **Step 3: Verify all five now ignore READMEs, and a README isn't stowed**

```bash
for f in common/.stowrc macos/.stowrc arch/.stowrc wsl/.stowrc claude/.stowrc; do
  grep -q "README" "$f" && echo "$f OK" || echo "$f MISSING"
done
# functional: a temp README in common/ must not be simulated for linking
touch common/README.test.md
cd common && stow --simulate --verbose --target ~/.config . 2>&1 | grep -i "README.test" && echo "FAIL: README would link" || echo "PASS: README ignored"
cd ..; rm -f common/README.test.md
```
Expected: all five `OK`; `PASS: README ignored`.

- [ ] **Step 4: Commit**

```bash
git add common/.stowrc arch/.stowrc wsl/.stowrc claude/.stowrc
git commit -m "chore(stow): ignore README*.md in all layers for consistency"
```

---

### Task 4: C3 — hoist generic `*.log` to root `.gitignore`

**Files:**
- Modify: root `.gitignore`, `common/nvim/.gitignore`

**Interfaces:**
- Produces: `**/*.log` ignored repo-wide from root; removed from nvim's local list.

- [ ] **Step 1: Show current state (test)**

```bash
grep -q '\*.log' common/nvim/.gitignore && echo "nvim has *.log (expected)" || echo "nvim clean already?"
grep -q '\*\*/\*.log' .gitignore && echo "root already has it?" || echo "root MISSING (expected)"
```
Expected: `nvim has *.log (expected)`, `root MISSING (expected)`.

- [ ] **Step 2: Add `**/*.log` to root `.gitignore`**

In root `.gitignore`, after the `**/.tmp*` line, add:
```
# Logs
**/*.log
```

- [ ] **Step 3: Remove `*.log` from `common/nvim/.gitignore`**

Delete the standalone `*.log` line from `common/nvim/.gitignore` (leave the nvim-runtime entries like `lazy-lock.json`, `doc/tags`, `.repro`).

- [ ] **Step 4: Verify**

```bash
grep -q '\*\*/\*.log' .gitignore && echo "root PASS" || echo "root FAIL"
grep -q '^\*.log$' common/nvim/.gitignore && echo "nvim still has it FAIL" || echo "nvim PASS"
git check-ignore -q common/nvim/foo.log && echo "log ignored PASS" || echo "log ignored FAIL"
```
Expected: `root PASS`, `nvim PASS`, `log ignored PASS`.

- [ ] **Step 5: Commit**

```bash
git add .gitignore common/nvim/.gitignore
git commit -m "chore(gitignore): hoist generic **/*.log to root"
```

---

### Task 5: B5 — link CLAUDE.md from README

**Files:**
- Modify: `README.md` (insert after the intro line, before `## Install`)

- [ ] **Step 1: Show it's missing (test)**

```bash
grep -q '(CLAUDE.md)' README.md && echo "already linked?" || echo "MISSING (expected)"
```
Expected: `MISSING (expected)`.

- [ ] **Step 2: Add the pointer**

In `README.md`, immediately after the intro line
`Personal dotfiles for macOS, Arch Linux, and WSL (Arch), managed with GNU Stow.`
add a blank line and:
```
> Architecture & conventions: see [CLAUDE.md](CLAUDE.md).
```

- [ ] **Step 3: Verify**

```bash
grep -q '\[CLAUDE.md\](CLAUDE.md)' README.md && echo "PASS" || echo "FAIL"
```
Expected: `PASS`.

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "docs(readme): link CLAUDE.md as the architecture reference"
```

---

## Post-implementation verification

- [ ] `shellcheck -S warning install.sh common/scripts/tmux-sessionizer claude/statusline-command.sh` → exit 0.
- [ ] `./install.sh --dry-run --skip-packages --skip-zsh-tools` → exit 0 (native macOS).
- [ ] `python3 -c "import yaml,sys; yaml.safe_load(open('.github/workflows/ci.yml'))"` → no error.
- [ ] Tracked-file cleanliness: `grep -riE "booking|signingkey \"ssh" README.md common macos arch wsl claude` → nothing.
- [ ] Push branch; CI green (shellcheck + dry-run + new manifest steps).

## Self-Review

**Spec coverage:** A3 → Task 2 ✓ · A4 → Task 1 ✓ · C1 → Task 3 ✓ · C3 (minimal) → Task 4 ✓ · B5 → Task 5 ✓.

**Placeholder scan:** none — all steps have concrete commands/code. The A4 interactive-decline path is verified by inspection + a manual-terminal note (the `[ -t 0 ]` gate makes it untestable in CI by design); this is called out, not hidden.

**Type/name consistency:** `warn()` (Task 1) matches the spec; `REPLACE_EXISTING`/`DRY_RUN`/`_reply`/`target` match `install.sh`. CI job name `dry-run` and `matrix.platform` values (`arch`/`macos`) match the existing workflow. `**/*.log` string identical across Task 4 steps.

## Out of scope
- D4 doctor mode (Slice 2b); A5, B4, C2, C4, D2, D3.
