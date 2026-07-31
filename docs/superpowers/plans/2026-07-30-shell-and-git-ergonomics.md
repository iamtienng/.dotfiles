# Shell & Git Ergonomics Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wire up installed-but-unused tooling (fzf), add modern CLI tools + additive aliases, add a reproducible XDG gitconfig with work-only signing, add a machine-local shell override hook, and fix a dead AeroSpace binding.

**Architecture:** All changes are additive and land in existing stow layers. `common/zshrc/common.zsh` is already stowed (a symlink into this repo), so edits to it are live immediately — no re-stow needed. The new `common/git/` package requires one `stow --restow`. Identity and signing never enter tracked files: they live in untracked `~/.config/git/config.local` (+ optional `config.work`) pulled in via `[include]`.

**Tech Stack:** zsh, GNU Stow, fzf, fd, bat, eza, git-delta, git includeIf, TOML (AeroSpace).

## Global Constraints

- **Public repo, scrubbed of employer info.** No tracked file may contain personal identity, signing keys, a work directory path, or any "Booking" reference. (from spec)
- **Additive aliasing only** — `ls`, `cat`, `find` stay unchanged. (from spec, locked decision)
- **Signing is work-only, never a global default.** Tracked gitconfig sets no `commit.gpgsign` / `user.signingkey`. (from spec)
- Commit messages use Conventional Commits (`feat:`, `docs:`, `fix:`, `chore:`). (repo convention)
- `common/zshrc/common.zsh` is stowed as a symlink into this repo; editing it is live — verify with a fresh `zsh -ic '…'`, no re-stow. New files under `common/` need `cd common && stow --restow .`. (grounded in repo)
- Each platform has its own package list; packages must be added to `macos/Brewfile`, `arch/pkglist.txt`, AND `wsl/pkglist.txt`. (grounded in repo)

---

### Task 1: Modern CLI tools + additive aliases

Adds `fd`/`bat`/`eza`/`git-delta` to all three manifests, installs them locally (this is macOS), and adds new eza/lazygit/lazydocker aliases. `fd`/`bat` are prerequisites for Task 2's fzf preview and `git-delta` for Task 3's pager.

**Files:**
- Modify: `macos/Brewfile`, `arch/pkglist.txt`, `wsl/pkglist.txt`
- Modify: `common/zshrc/common.zsh` (after the util-aliases block, `common.zsh:92`)

**Interfaces:**
- Produces: `fd`, `bat`, `eza`, `delta` on PATH; interactive aliases `ll`, `la`, `lt`, `lg`, `lzd`. Consumed by Task 2 (`fd`/`bat`) and Task 3 (`delta`).

- [ ] **Step 1: Write the failing test**

```bash
cd ~/project/personal/dev/.dotfiles
for t in fd bat eza delta; do command -v "$t" >/dev/null 2>&1 && echo "$t OK" || echo "$t MISSING"; done
zsh -ic 'alias ll' 2>/dev/null || echo "no ll alias"
```

- [ ] **Step 2: Run it to verify it fails**

Expected: `fd/bat/eza/delta` print `MISSING` (some may exist), and `alias ll` prints nothing / `no ll alias`.

- [ ] **Step 3: Add the packages to all three manifests**

Append to `macos/Brewfile`:
```ruby
brew "fd"
brew "bat"
brew "eza"
brew "git-delta"
```
Append to BOTH `arch/pkglist.txt` and `wsl/pkglist.txt`:
```
fd
bat
eza
git-delta
```

- [ ] **Step 4: Install locally (macOS)**

```bash
brew install fd bat eza git-delta
```

- [ ] **Step 5: Add the additive aliases**

In `common/zshrc/common.zsh`, immediately after the `nvimclean` alias (`common.zsh:92`), add:
```sh

# eza / lazygit / lazydocker (additive — ls/cat/find left unchanged)
alias ll='eza -l --git --icons'
alias la='eza -la --git --icons'
alias lt='eza --tree --level=2'
alias lg='lazygit'
alias lzd='lazydocker'
```

- [ ] **Step 6: Run the tests to verify they pass**

```bash
for t in fd bat eza delta; do command -v "$t" >/dev/null 2>&1 && echo "$t OK" || echo "$t MISSING"; done
zsh -ic 'alias ll' 2>/dev/null | grep -q "eza -l --git --icons" && echo "PASS ll" || echo "FAIL ll"
zsh -ic 'alias lg' 2>/dev/null | grep -q "lazygit" && echo "PASS lg" || echo "FAIL lg"
```
Expected: all four tools `OK`; `PASS ll`; `PASS lg`.

- [ ] **Step 7: Commit**

```bash
git add macos/Brewfile arch/pkglist.txt wsl/pkglist.txt common/zshrc/common.zsh
git commit -m "feat(shell): add fd/bat/eza/git-delta and additive eza+lazy aliases"
```

---

### Task 2: fzf shell integration

Sources fzf's zsh integration so `Ctrl-R`/`Ctrl-T`/`Alt-C` work, wired to `fd`/`bat`. Placed after the line-editor plugins so its `Ctrl-R` binding lands last.

**Files:**
- Modify: `common/zshrc/common.zsh` (after the line-editor plugins block, `common.zsh:76`)

**Interfaces:**
- Consumes: `fzf` (installed), `fd`/`bat` (Task 1).
- Produces: `Ctrl-R` bound to `fzf-history-widget`; `Ctrl-T`/`Alt-C` widgets.

- [ ] **Step 1: Write the failing test**

```bash
zsh -ic 'bindkey "^R"' 2>/dev/null | grep -q 'fzf-history-widget' && echo "PASS" || echo "FAIL (expected before change)"
```

- [ ] **Step 2: Run it to verify it fails**

Expected: `FAIL (expected before change)` — fzf is not sourced yet, so `^R` is not the fzf widget.

- [ ] **Step 3: Add the fzf integration block**

In `common/zshrc/common.zsh`, immediately after the line-editor plugins `fi` (`common.zsh:76`) and before the `# Cached completions` section, insert:
```sh

# ------------------------------------------------------------
# fzf — fuzzy finder shell integration (Ctrl-R / Ctrl-T / Alt-C)
# fd/bat power the file source and preview; guarded so a missing
# fzf (or an older one without --zsh) never breaks shell startup.
# ------------------------------------------------------------
if command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :200 {}'"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
  source <(fzf --zsh 2>/dev/null)
fi
```

- [ ] **Step 4: Run the test to verify it passes**

```bash
zsh -ic 'bindkey "^R"' 2>/dev/null | grep -q 'fzf-history-widget' && echo "PASS" || echo "FAIL"
zsh -ic 'true'; echo "startup exit=$?"
```
Expected: `PASS`, and `startup exit=0` (no shell-init error).

- [ ] **Step 5: Commit**

```bash
git add common/zshrc/common.zsh
git commit -m "feat(shell): enable fzf key bindings (Ctrl-R/Ctrl-T/Alt-C) with fd+bat"
```

---

### Task 3: Tracked XDG gitconfig + template

Creates a shared, identity-free `~/.config/git/config` (via a new `common/git/` package) with delta, sane defaults, and aliases, plus a copy-me template. No `~/.gitconfig` symlink — git reads XDG natively.

**Files:**
- Create: `common/git/config`
- Create: `common/git/config.local.example`

**Interfaces:**
- Produces: `~/.config/git/config` (stowed) providing `core.pager=delta`, defaults, aliases, and an `[include]` of `~/.config/git/config.local`. Consumed by Task 4 (identity/signing includes).

- [ ] **Step 1: Write the failing test**

```bash
git config --show-origin --get core.pager 2>/dev/null | grep -q delta && echo "delta pager set" || echo "no delta pager (expected before change)"
```

- [ ] **Step 2: Run it to verify it fails**

Expected: `no delta pager (expected before change)`.

- [ ] **Step 3: Create `common/git/config`**

```gitconfig
# Shared git config (tracked, XDG: ~/.config/git/config).
# Personal identity and work-only signing live in untracked local includes.
# See config.local.example.

[core]
	pager = delta

[interactive]
	diffFilter = delta --color-only

[delta]
	navigate = true
	line-numbers = true
	side-by-side = true

[init]
	defaultBranch = main

[pull]
	rebase = true

[push]
	autoSetupRemote = true
	default = simple

[rebase]
	autostash = true

[fetch]
	prune = true

[alias]
	st = status -sb
	co = checkout
	lg = log --oneline --graph --decorate
	last = log -1 HEAD
	undo = reset --soft HEAD~1
	amend = commit --amend --no-edit

[include]
	path = ~/.config/git/config.local
```

- [ ] **Step 4: Create `common/git/config.local.example`**

```gitconfig
# Copy to ~/.config/git/config.local (untracked) and fill in your identity.
# Personal commits are UNSIGNED by default.
#
# [user]
#     name = Your Name
#     email = you@personal.example
#
# --- Work-only signing (optional) --------------------------------------------
# Keep signing config OUT of the tracked repo. Add a conditional include that
# points at an untracked work config, scoped to your work directory so personal
# repos stay unsigned:
#
# [includeIf "gitdir:~/work/"]        # set to your real work directory
#     path = ~/.config/git/config.work
#
# Then create ~/.config/git/config.work (untracked):
#
# [user]
#     email = you@work.example
#     signingkey = <GPG key id or fingerprint>
# [commit]
#     gpgsign = true
# [gpg]
#     format = openpgp     # GPG smartcard (e.g. YubiKey) via gpg-agent
```

- [ ] **Step 5: Stow and verify the symlink + values**

```bash
cd ~/project/personal/dev/.dotfiles/common && stow --restow . && cd ..
ls -l ~/.config/git/config
git config --show-origin --get core.pager
git config --get alias.st
```
Expected: `~/.config/git/config` is a symlink into this repo; `core.pager` resolves to `delta`; `alias.st` is `status -sb`. (A missing `config.local` include is silently ignored by git — fine until Task 4.)

- [ ] **Step 6: Commit**

```bash
git add common/git/config common/git/config.local.example
git commit -m "feat(git): add tracked XDG gitconfig (delta, defaults, aliases) + local-include template"
```

---

### Task 4: Migrate `~/.gitconfig` → local includes + README update

Moves existing personal identity into the untracked `config.local`, relocates any global signing into a work-scoped untracked `config.work`, collapses the old `~/.gitconfig`, and replaces the README's manual git-setup commands. **Contains a confirmation gate before touching the real `~/.gitconfig`.**

**Files:**
- Create (untracked, machine-local): `~/.config/git/config.local`, optionally `~/.config/git/config.work`
- Modify: `README.md` (the `git config --global …` lines in the WSL block, `README.md:50-52`)
- Backup/remove (machine-local): `~/.gitconfig`

**Interfaces:**
- Consumes: `~/.config/git/config` `[include]` from Task 3.
- Produces: `git config user.email` resolving via `config.local`; `commit.gpgsign` empty in personal repos.

- [ ] **Step 1: Inspect the current real config**

```bash
cat ~/.gitconfig 2>/dev/null || echo "(no ~/.gitconfig)"
git config --show-origin --get user.email
git config --show-origin --get user.signingkey 2>/dev/null || echo "(no global signingkey)"
git config --get commit.gpgsign 2>/dev/null || echo "(gpgsign unset)"
```
Record: personal name/email, and whether a global `signingkey`/`gpgsign` exists.

- [ ] **Step 2: Create `~/.config/git/config.local` with personal identity**

Use the identity from Step 1 (personal name + personal email; **no signing**):
```bash
cat > ~/.config/git/config.local <<'EOF'
[user]
	name = Tien Nguyen
	email = iamtienng@gmail.com
EOF
```
(Adjust name/email to match Step 1 if they differ.)

- [ ] **Step 3: Relocate work signing (only if Step 1 found global signing)**

If Step 1 showed a global `signingkey`/`gpgsign`, ask the user for their work directory path (e.g. `~/project/booking`) and their work email + GPG key id (`gpg --list-secret-keys --keyid-format=long`). Then:

Append the conditional include to `~/.config/git/config.local`:
```bash
cat >> ~/.config/git/config.local <<'EOF'

[includeIf "gitdir:<WORK_DIR>/"]
	path = ~/.config/git/config.work
EOF
```
Create `~/.config/git/config.work` (untracked):
```bash
cat > ~/.config/git/config.work <<'EOF'
[user]
	email = <WORK_EMAIL>
	signingkey = <GPG_KEY_ID>
[commit]
	gpgsign = true
[gpg]
	format = openpgp
EOF
```
Replace `<WORK_DIR>`, `<WORK_EMAIL>`, `<GPG_KEY_ID>` with the user-provided values. If Step 1 found NO global signing, skip this step.

- [ ] **Step 4: CONFIRMATION GATE — collapse the old `~/.gitconfig`**

Show the user what will happen and confirm before proceeding. Then:
```bash
mv ~/.gitconfig ~/.gitconfig.pre-migration.bak
```
Verify a single source of truth now resolves correctly:
```bash
git config --show-origin --get user.email        # -> from ~/.config/git/config.local
git config --show-origin --get core.pager         # -> delta, from ~/.config/git/config
git -C ~/project/personal/dev/.dotfiles config --get commit.gpgsign 2>/dev/null || echo "gpgsign unset here (correct: personal repo unsigned)"
```
Expected: email from `config.local`; pager `delta`; `commit.gpgsign` unset/false in this personal repo. If a work repo path was configured in Step 3, `cd` into one and confirm `git config --get commit.gpgsign` is `true` there.

- [ ] **Step 5: Update the README**

In `README.md`, replace the three manual identity/signing lines (`README.md:50-52`):
```
git config --global user.name "Tien Nguyen"
git config --global user.email "iamtienng@gmail.com"
git config --global user.signingkey "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMIpJ9w+cEX0g3X5SvhbihI+R0LtG3KEkari4tyahPtN"
```
with:
```
# Git identity lives in an untracked local include (see common/git/config.local.example):
cp ~/.config/git/config.local.example ~/.config/git/config.local
# then edit ~/.config/git/config.local with your name/email (and, for work repos, a config.work with your signing key)
```

- [ ] **Step 6: Verify README no longer embeds the key/email, then commit**

```bash
grep -q "user.signingkey \"ssh-ed25519" README.md && echo "FAIL: key still present" || echo "PASS: key removed"
grep -q "config.local.example" README.md && echo "PASS: new flow documented" || echo "FAIL"
git add README.md
git commit -m "docs(readme): replace manual git identity/signing setup with local-include flow"
```
Expected: `PASS: key removed`, `PASS: new flow documented`. (Only `README.md` is committed; `config.local`/`config.work` are untracked and machine-local.)

---

### Task 5: `local.zsh` machine-local override hook

Sources `~/.config/zshrc/local.zsh` last (so it overrides everything) and ships a template.

**Files:**
- Modify: `common/zshrc/common.zsh` (append at end, after the p10k block `common.zsh:133`)
- Create: `common/zshrc/local.zsh.example`

**Interfaces:**
- Produces: any aliases/functions/exports in `~/.config/zshrc/local.zsh` take effect, overriding shared config.

- [ ] **Step 1: Write the failing test**

```bash
mkdir -p ~/.config/zshrc
echo "alias __localtest='echo local-ok'" > ~/.config/zshrc/local.zsh
zsh -ic 'alias __localtest' 2>/dev/null | grep -q 'local-ok' && echo "PASS" || echo "FAIL (expected before change)"
```

- [ ] **Step 2: Run it to verify it fails**

Expected: `FAIL (expected before change)` — nothing sources `local.zsh` yet.

- [ ] **Step 3: Append the sourcing hook**

At the END of `common/zshrc/common.zsh` (after the p10k block, `common.zsh:133`), add:
```sh

# ------------------------------------------------------------
# Machine-local overrides (untracked; sourced last so it can override anything)
# ------------------------------------------------------------
[[ -f ~/.config/zshrc/local.zsh ]] && source ~/.config/zshrc/local.zsh
```

- [ ] **Step 4: Create `common/zshrc/local.zsh.example`**

```zsh
# Copy to ~/.config/zshrc/local.zsh (untracked) for machine-local shell tweaks:
# aliases, functions, PATH, env vars. Sourced LAST by common.zsh, so anything
# here overrides the shared config.
#
# export PATH="$HOME/some/local/bin:$PATH"
# alias work='cd ~/project/work'
```

- [ ] **Step 5: Verify present-and-absent behavior**

```bash
zsh -ic 'alias __localtest' 2>/dev/null | grep -q 'local-ok' && echo "PASS present" || echo "FAIL present"
rm ~/.config/zshrc/local.zsh
zsh -ic 'true'; echo "absent exit=$?"
```
Expected: `PASS present`, then `absent exit=0` (no error when the file is gone).

- [ ] **Step 6: Stow the example and commit**

```bash
cd ~/project/personal/dev/.dotfiles/common && stow --restow . && cd ..
git add common/zshrc/common.zsh common/zshrc/local.zsh.example
git commit -m "feat(shell): source ~/.config/zshrc/local.zsh for machine-local overrides"
```

---

### Task 6: Fix the dead AeroSpace `alt-w` binding

Repoints apps-mode `alt-w` from the uninstalled WezTerm to Ghostty.

**Files:**
- Modify: `macos/aerospace/aerospace.toml:115`

- [ ] **Step 1: Write the failing test**

```bash
grep -q 'WezTerm.app' macos/aerospace/aerospace.toml && echo "dead binding present (expected)" || echo "already fixed?"
```

- [ ] **Step 2: Run it to verify the dead binding is present**

Expected: `dead binding present (expected)`.

- [ ] **Step 3: Repoint the binding**

Replace `macos/aerospace/aerospace.toml:115`:
```toml
alt-w = ['exec-and-forget open -a /Applications/WezTerm.app', 'mode main']
```
with:
```toml
alt-w = ['exec-and-forget open -a /Applications/Ghostty.app', 'mode main']
```

- [ ] **Step 4: Verify the fix (and TOML validity if available)**

```bash
grep -q 'Ghostty.app' macos/aerospace/aerospace.toml && ! grep -q 'WezTerm' macos/aerospace/aerospace.toml && echo "PASS: repointed" || echo "FAIL"
python3 -c "import tomllib" 2>/dev/null && python3 -c "import tomllib; tomllib.load(open('macos/aerospace/aerospace.toml','rb')); print('TOML OK')" || echo "(tomllib unavailable; skipping parse check)"
```
Expected: `PASS: repointed`, and `TOML OK` (or the skip note on older Python).

- [ ] **Step 5: Commit**

```bash
git add macos/aerospace/aerospace.toml
git commit -m "fix(aerospace): repoint alt-w from uninstalled WezTerm to Ghostty"
```

---

## Post-implementation verification

- [ ] **Fresh shell:** open a new terminal; `Ctrl-R` opens fzf history, `ll`/`lg`/`lzd` work, no startup errors.
- [ ] **Git:** `git config --show-origin --get core.pager` → `delta` from `~/.config/git/config`; `git config user.email` resolves from `config.local`; a personal repo shows `commit.gpgsign` unset; (if configured) a work repo shows it `true`.
- [ ] **Public-repo cleanliness:** `grep -riE "booking|signingkey \"ssh-ed25519" README.md common/git` finds nothing employer- or key-related in tracked files.
- [ ] **Installer safety:** `./install.sh --dry-run --skip-packages --skip-zsh-tools` still exits 0 (CI covers this on push).

## Self-Review

**Spec coverage:**
- Component 1 (fzf init) → Task 2. ✓
- Component 2 (tools + additive aliases) → Task 1. ✓
- Component 3 (tracked XDG gitconfig, no identity/signing; template) → Task 3. ✓
- Component 3 (migration + README replacement of manual setup) → Task 4. ✓
- Component 4 (`local.zsh` hook + example) → Task 5. ✓
- Component 5 (AeroSpace `alt-w` fix) → Task 6. ✓

**Type/name consistency:** `~/.config/git/config` → includes `~/.config/git/config.local` (Task 3) → Task 4 writes that exact path and the `config.work` path referenced by the template. Alias names (`ll`/`la`/`lt`/`lg`/`lzd`) defined once in Task 1. fzf env var names match fzf's documented `FZF_DEFAULT_COMMAND`/`FZF_CTRL_T_COMMAND`/`FZF_CTRL_T_OPTS`/`FZF_ALT_C_COMMAND`. `common.zsh` line anchors (76, 92, 133) are consistent with the read-in file.

**Placeholder scan:** The only `<…>` tokens are in Task 4 Step 3, which are deliberately user-supplied secrets (work dir, work email, GPG key id) that must not be hardcoded in a public repo — bounded by the Step 1 inspection and the Step 4 confirmation gate, not open-ended.

## Out of scope (this cycle)
- `mise` / runtime version management — Cycle 2.
- `gh`, `atuin`, `zoxide`, tmux prefix/TPM — not selected.
- Any `install.sh` control-flow change or `claude/settings.json` stowing change.
