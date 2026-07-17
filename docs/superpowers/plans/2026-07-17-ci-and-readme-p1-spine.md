# CI + README P1 Spine Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give `install.sh` an automated safety net (shellcheck + `--dry-run` CI on macOS & Linux) and make the README accurately describe the installer and all stow layers.

**Architecture:** Add a `DOTFILES_PLATFORM` override to `detect_platform` so the installer can be driven on any CI runner; add a single GitHub Actions workflow with a `shellcheck` job and a `dry-run` matrix job (Ubuntu→arch, macOS→macos); correct and expand the README. No behavior change to the real (non-dry-run) install path beyond the opt-in override.

**Tech Stack:** Bash, GNU Stow, GitHub Actions, ShellCheck.

## Global Constraints

- All bash scripts keep `set -euo pipefail`. (from spec: preserve existing safety posture)
- Commit messages use Conventional Commits (`feat:`, `ci:`, `docs:`, `fix:`). (repo convention)
- The only third-party GitHub Action allowed is `actions/checkout@v4`; everything else installs via the runner's package manager. (from spec Theme A: minimize supply chain)
- ShellCheck targets **bash files only**: `install.sh`, `common/scripts/tmux-sessionizer`, `claude/statusline-command.sh`. `common/scripts/ghostty-tmux-initializer` is `#!/bin/zsh -i` and MUST be excluded (ShellCheck does not support zsh). (grounded in repo)
- ShellCheck severity threshold is `warning` (`-S warning`): catch real bugs, skip pedantic style.
- The `dry-run` CI job MUST stay non-mutating: always invoke with `--dry-run --skip-packages --skip-zsh-tools`. (grounded: dry-run path early-returns everywhere)
- The README MUST describe the installer's **backup-first** behavior; the word "removes" must not describe the default path. (from spec B1)

---

### Task 1: Add `DOTFILES_PLATFORM` override to `detect_platform`

Enables CI to drive the installer on any runner and makes platform selection testable. Small, opt-in change; the auto-detection path is unchanged when the env var is unset.

**Files:**
- Modify: `install.sh:61-79` (`detect_platform`)

**Interfaces:**
- Produces: `detect_platform` honors `DOTFILES_PLATFORM` when set to one of `macos|arch|wsl`, printing it verbatim; dies on any other non-empty value; falls back to existing auto-detection when unset. Consumed by `main()` (`install.sh:464`) and the CI `dry-run` job (Task 3).

- [ ] **Step 1: Write the failing test (manual command harness)**

From the repo root, this command must eventually print a "Would stow arch" line and exit 0. Run it now — it currently ignores the override, so on a non-Arch machine it will `die` or stow the wrong platform:

```bash
DOTFILES_PLATFORM=arch ./install.sh --dry-run --skip-packages --skip-zsh-tools 2>&1 | grep -q "Would stow arch" && echo "PASS" || echo "FAIL"
```

Also verify an invalid value is rejected:

```bash
DOTFILES_PLATFORM=bogus ./install.sh --dry-run --skip-packages --skip-zsh-tools 2>&1 | grep -q "unsupported DOTFILES_PLATFORM" && echo "PASS" || echo "FAIL"
```

- [ ] **Step 2: Run both commands to verify they FAIL**

Expected before the change: first prints `FAIL` (override ignored), second prints `FAIL` (no such message).

- [ ] **Step 3: Implement the override**

In `install.sh`, replace the `detect_platform` function body so the override is checked first:

```bash
detect_platform() {
  if [ -n "${DOTFILES_PLATFORM:-}" ]; then
    case "$DOTFILES_PLATFORM" in
    macos | arch | wsl)
      printf '%s' "$DOTFILES_PLATFORM"
      return
      ;;
    *)
      die "unsupported DOTFILES_PLATFORM: $DOTFILES_PLATFORM (expected macos, arch, or wsl)"
      ;;
    esac
  fi

  case "$(uname -s)" in
  Darwin)
    printf 'macos'
    ;;
  Linux)
    if is_wsl; then
      printf 'wsl'
    elif [ -f /etc/arch-release ]; then
      printf 'arch'
    else
      die "unsupported Linux distribution; this repo currently supports Arch Linux and WSL"
    fi
    ;;
  *)
    die "unsupported OS: $(uname -s)"
    ;;
  esac
}
```

- [ ] **Step 4: Run both commands to verify they PASS**

```bash
DOTFILES_PLATFORM=arch ./install.sh --dry-run --skip-packages --skip-zsh-tools 2>&1 | grep -q "Would stow arch" && echo "PASS" || echo "FAIL"
DOTFILES_PLATFORM=bogus ./install.sh --dry-run --skip-packages --skip-zsh-tools 2>&1 | grep -q "unsupported DOTFILES_PLATFORM" && echo "PASS" || echo "FAIL"
```

Expected: both print `PASS`. Also confirm auto-detect still works with the var unset:

```bash
./install.sh --dry-run --skip-packages --skip-zsh-tools 2>&1 | grep -q "Detected platform:" && echo "PASS" || echo "FAIL"
```

- [ ] **Step 5: Commit**

```bash
git add install.sh
git commit -m "feat(install): add DOTFILES_PLATFORM override to detect_platform

Lets CI drive the installer on any runner and makes platform selection
testable. Auto-detection is unchanged when the var is unset."
```

---

### Task 2: Add CI workflow with a ShellCheck job

Create the workflow file with its first job. ShellCheck lints the three bash scripts; fix whatever it reports so the job is green.

**Files:**
- Create: `.github/workflows/ci.yml`

**Interfaces:**
- Produces: a workflow named `CI` triggered on `push` to `main` and all `pull_request`s, with a `shellcheck` job. Task 3 adds a second job to the same file.

- [ ] **Step 1: Install ShellCheck locally and run it (the failing test)**

```bash
# macOS: brew install shellcheck  |  Debian/Ubuntu: sudo apt-get install -y shellcheck
shellcheck -S warning install.sh common/scripts/tmux-sessionizer claude/statusline-command.sh; echo "exit=$?"
```

- [ ] **Step 2: Record the result**

Expected: prints zero or more findings and an `exit=` line. If `exit=0` with no findings, skip Step 3. If it reports findings (`exit=1`), proceed to fix them.

- [ ] **Step 3: Fix each finding**

For every finding, apply the fix ShellCheck's `SCxxxx` code recommends (e.g. quote an unquoted expansion `"$var"`, use `read -r`, avoid `cd` without `|| exit`). If a finding is a deliberate, correct pattern, silence it narrowly with a documented directive on the line above it:

```bash
# shellcheck disable=SCxxxx  # reason: <one-line justification>
```

Do NOT add a repo-wide disable and do NOT lower the severity below `warning`. Re-run the Step 1 command after each fix until it prints `exit=0`.

- [ ] **Step 4: Create the workflow file**

Create `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  shellcheck:
    name: ShellCheck
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install ShellCheck
        run: sudo apt-get update && sudo apt-get install -y shellcheck
      - name: Lint bash scripts
        run: shellcheck -S warning install.sh common/scripts/tmux-sessionizer claude/statusline-command.sh
```

- [ ] **Step 5: Validate the workflow YAML parses**

```bash
python3 -c "import yaml,sys; yaml.safe_load(open('.github/workflows/ci.yml')); print('YAML OK')"
```

Expected: `YAML OK`.

- [ ] **Step 6: Commit**

```bash
git add .github/workflows/ci.yml install.sh common/scripts/tmux-sessionizer claude/statusline-command.sh
git commit -m "ci: add ShellCheck workflow and fix lint findings"
```

(If Steps 1–3 produced no code changes, `git add` only the workflow file.)

---

### Task 3: Add a `--dry-run` matrix job to the workflow

Extend `ci.yml` with a job that runs the installer's dry-run on both OSes. Ubuntu forces `arch` via the Task 1 override; macOS detects natively.

**Files:**
- Modify: `.github/workflows/ci.yml`

**Interfaces:**
- Consumes: `DOTFILES_PLATFORM` override from Task 1; `--dry-run --skip-packages --skip-zsh-tools` flags (existing in `install.sh`).
- Produces: a `dry-run` job with a 2-entry matrix (`ubuntu-latest`+`arch`, `macos-latest`+`macos`).

- [ ] **Step 1: Add the job to `.github/workflows/ci.yml`**

Append under `jobs:` (sibling of `shellcheck`):

```yaml
  dry-run:
    name: Dry-run install (${{ matrix.os }})
    strategy:
      fail-fast: false
      matrix:
        include:
          - os: ubuntu-latest
            platform: arch
          - os: macos-latest
            platform: macos
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - name: Install GNU Stow (Linux)
        if: runner.os == 'Linux'
        run: sudo apt-get update && sudo apt-get install -y stow
      - name: Install GNU Stow (macOS)
        if: runner.os == 'macOS'
        run: brew install stow
      - name: Dry-run install
        env:
          DOTFILES_PLATFORM: ${{ matrix.platform }}
        run: ./install.sh --dry-run --skip-packages --skip-zsh-tools
```

- [ ] **Step 2: Validate YAML still parses**

```bash
python3 -c "import yaml; d=yaml.safe_load(open('.github/workflows/ci.yml')); print(sorted(d['jobs'].keys()))"
```

Expected: `['dry-run', 'shellcheck']`.

- [ ] **Step 3: Reproduce the CI dry-run locally (the test)**

Simulate the Ubuntu job locally (works on any OS with `stow` installed):

```bash
DOTFILES_PLATFORM=arch ./install.sh --dry-run --skip-packages --skip-zsh-tools; echo "exit=$?"
```

Expected: exit 0, with `Would stow common`, `Would stow arch`, and `Would stow claude` lines, and no file changes to `~/.config` or `~/.claude`.

- [ ] **Step 4: Confirm nothing was mutated**

```bash
git -C "$HOME" status 2>/dev/null || echo "(HOME not a git repo — fine)"
ls -la ~/.config/*.backup.* 2>/dev/null && echo "UNEXPECTED BACKUP CREATED" || echo "no backups created (correct)"
```

Expected: `no backups created (correct)`.

- [ ] **Step 5: Commit**

```bash
git add .github/workflows/ci.yml
git commit -m "ci: dry-run install.sh on ubuntu and macos runners"
```

- [ ] **Step 6: Push and verify the run is green**

```bash
git push
```

Then confirm both jobs pass (GitHub UI, or `gh run list --limit 1` / `gh run watch` if `gh` is available). Expected: `shellcheck` and both `dry-run` matrix legs succeed.

---

### Task 4: Fix the README "removes vs backs up" inaccuracy (B1)

The README's "Notes" section says the installer *removes* existing config; the installer actually **backs up** by default and only removes under `--replace-existing`.

**Files:**
- Modify: `README.md` (the "Notes" paragraph beginning "Before stowing, the installer removes…") and the "Useful options" block.

- [ ] **Step 1: Assert the inaccurate text is present (the failing test)**

```bash
grep -q "the installer removes existing top-level config entries managed by this repo" README.md && echo "inaccurate text present (expected before fix)" || echo "already fixed?"
```

Expected: `inaccurate text present (expected before fix)`.

- [ ] **Step 2: Replace the inaccurate paragraph**

Find this exact paragraph in `README.md`:

```
Before stowing, the installer removes existing top-level config entries managed by this repo, such as `~/.config/nvim`, `~/.config/ghostty`, and `~/.config/zshrc`. Then it recreates them from `common/` and the detected OS package.
```

Replace it with:

```
Before stowing, the installer inspects each top-level config entry it is about to create (for example `~/.config/nvim`, `~/.config/ghostty`, `~/.config/zshrc`). Entries already managed by this repo (symlinks pointing back into it) are left as-is. Any other pre-existing entry is **backed up** to `<name>.backup.<timestamp>` before stowing — nothing is deleted by default. Pass `--replace-existing` to delete those entries instead of backing them up (DANGEROUS). The same backup-first rule applies to `~/.zshrc`: a real file is backed up, and an existing symlink into this repo is left untouched.
```

- [ ] **Step 3: Add `--replace-existing` to the "Useful options" block**

Find the "Useful options" code block:

```sh
./install.sh --dry-run
./install.sh --skip-packages
./install.sh --skip-zsh-tools
./install.sh --skip-stow
```

Replace it with:

```sh
./install.sh --dry-run           # preview every action; touches nothing
./install.sh --skip-packages     # skip Homebrew/pacman package install
./install.sh --skip-zsh-tools    # skip Oh My Zsh / Powerlevel10k / evalcache
./install.sh --skip-stow         # skip linking
./install.sh --replace-existing  # DANGEROUS: delete existing configs instead of backing them up
```

- [ ] **Step 4: Verify the fix**

```bash
grep -q "the installer removes existing top-level config entries managed by this repo" README.md && echo "FAIL: old text still present" || echo "PASS: old text gone"
grep -q "backed up" README.md && grep -q -- "--replace-existing" README.md && echo "PASS: backup + flag documented" || echo "FAIL"
```

Expected: both print `PASS`.

- [ ] **Step 5: Commit**

```bash
git add README.md
git commit -m "docs(readme): correct backup-first install behavior and document --replace-existing"
```

---

### Task 5: Document the `wsl/` and `claude/` layers (B2)

The README intro says "macOS and Arch Linux" and lists only `common/macos/arch`. Add WSL and the `claude/ → ~/.claude` package.

**Files:**
- Modify: `README.md` (intro line, the layer bullet list, and a new subsection).

- [ ] **Step 1: Assert the gaps exist (the failing test)**

```bash
grep -qi 'claude' README.md && echo "claude documented?" || echo "PASS: claude undocumented (expected before fix)"
grep -q 'Personal dotfiles for macOS and Arch Linux' README.md && echo "PASS: intro omits WSL (expected)" || echo "intro already updated?"
```

Expected: `PASS: claude undocumented (expected before fix)` and `PASS: intro omits WSL (expected)`.

- [ ] **Step 2: Update the intro line**

Replace:

```
Personal dotfiles for macOS and Arch Linux, managed with GNU Stow.
```

with:

```
Personal dotfiles for macOS, Arch Linux, and WSL (Arch), managed with GNU Stow.
```

- [ ] **Step 3: Expand the layer list**

Replace this list:

```
- `common/`: shared app config.
- `macos/`: macOS-only config and packages.
- `arch/`: Arch-only config and packages.
```

with:

```
- `common/`: shared app config (stowed to `~/.config`).
- `macos/`: macOS-only config and packages (stowed to `~/.config`).
- `arch/`: Arch-only config and packages (stowed to `~/.config`).
- `wsl/`: WSL (Arch) config and packages (stowed to `~/.config`).
- `claude/`: shared Claude Code config, stowed to `~/.claude` (not `~/.config`).
```

- [ ] **Step 4: Add a "Claude Code config" subsection**

Immediately before the "## Notes" heading, insert:

```
## Claude Code config

The `claude/` package is shared across all platforms and stows into `~/.claude`
(Claude Code reads its config there, not from XDG). The installer stows it
unconditionally, alongside `common/`. It ships `statusline-command.sh` (referenced
by `~/.claude/settings.json`), plus `agents/`, `commands/`, and `skills/`.

`~/.claude/settings.json` is intentionally **not** stowed — it holds
environment-specific endpoints and tokens. Only files safe to share live in `claude/`.
```

- [ ] **Step 5: Verify the fix**

```bash
grep -q 'macOS, Arch Linux, and WSL' README.md && echo "PASS: intro" || echo "FAIL: intro"
grep -q '`wsl/`' README.md && grep -q '`claude/`' README.md && echo "PASS: layers" || echo "FAIL: layers"
grep -q '## Claude Code config' README.md && echo "PASS: section" || echo "FAIL: section"
```

Expected: all three print `PASS`.

- [ ] **Step 6: Commit**

```bash
git add README.md
git commit -m "docs(readme): document wsl and claude stow layers"
```

---

## Self-Review

**Spec coverage (P1 spine):**
- A1 (shellcheck CI) → Task 2. ✓
- A2 (`--dry-run` CI on macOS+Linux) → Task 3, enabled by Task 1. ✓
- B1 (removes→backup README fix) → Task 4. ✓
- B2 (document `wsl/` + `claude/`) → Task 5. ✓
- Note: `--replace-existing` docs (spec B3, P2) are pulled into Task 4 because B1's corrected text is inaccurate without them. Deliberate, minimal overlap.

**Type/name consistency:** `DOTFILES_PLATFORM` (Task 1) is the exact env var consumed by the CI matrix (Task 3). Flag names (`--dry-run`, `--skip-packages`, `--skip-zsh-tools`, `--replace-existing`) match `install.sh` usage/`config_entries`. Job names (`shellcheck`, `dry-run`) are consistent between Task 2 and Task 3's YAML-parse assertion.

**Placeholder scan:** Task 2 Step 3 ("fix each finding") is procedural rather than literal because ShellCheck output is only known at run time; it is bounded by a concrete decision rule (apply the SCxxxx fix or add a justified narrow disable) and a hard exit-0 gate, not left open-ended. No other placeholders.

## Out of scope (deferred to later roadmap cycles)
- A3 manifest checks, A4 destructive-path hardening, A5 shfmt/editorconfig.
- B4 WSL bootstrap restructure + personal-info flag, B5 CLAUDE.md link.
- All of Theme C and Theme D.
