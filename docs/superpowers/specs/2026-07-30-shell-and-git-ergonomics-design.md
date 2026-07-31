# Shell & Git Ergonomics — Design

**Date:** 2026-07-30
**Status:** Approved design (Cycle 1 of the "workflow leverage" batch; mise is Cycle 2)
**Repo:** `iamtienng/.dotfiles` (public GitHub) — GNU Stow dotfiles for macOS, Arch Linux, WSL (Arch)

## Purpose

Close a set of high-leverage, low-risk gaps found in a workflow inventory: tools that
are installed but not wired up, missing reproducible git config, and a dead keybinding.
All changes are **additive** and fit the existing stow-layer conventions. A separate
Cycle 2 will handle runtime version management (`mise`) on its own brainstorm→plan cycle.

Constraint that shapes this design: **the repo is public and was just scrubbed of
employer references.** Nothing tracked here may hardcode personal identity, signing
keys, or any employer path.

## Baseline observations (from inventory)

- `fzf` is installed but **never sourced** in any `.zshrc` — no `Ctrl-R`/`Ctrl-T`/`Alt-C`.
- `fd`, `bat`, `eza`, `git-delta` are **absent**; `lazygit`/`lazydocker` are installed
  but have no shell launch alias.
- **No tracked gitconfig** — identity + signing are set by hand-run commands in the
  README; not reproducible, and the README embeds a personal email + signing key.
- **No machine-local shell override hook** (only `common.zsh` + p10k are sourced).
- `macos/aerospace/aerospace.toml` binds apps-mode `alt-w` to `WezTerm.app`, which is
  not installed (the terminal is Ghostty) — a dead binding.

## Decisions (locked)

| Decision | Choice |
|----------|--------|
| eza/bat/fd wiring | **Additive only** — new aliases; `ls`/`cat`/`find` untouched |
| Git identity | **Untracked local include** — tracked config carries no identity |
| Commit signing | **Work-only, untracked** — never a global default; no employer path in the repo |
| Grouping | This cycle = shell + git ergonomics; `mise` deferred to Cycle 2 |

---

## Component 1 — fzf shell integration

**File:** `common/zshrc/common.zsh` (shared body).

Add `source <(fzf --zsh)` **after** the line-editor plugins (zsh-autosuggestions,
zsh-syntax-highlighting, zsh-history-substring-search) so fzf's `Ctrl-R` widget binds
last and wins. Enables `Ctrl-R` (history), `Ctrl-T` (file insert), `Alt-C` (cd).

Point fzf at `fd`/`bat` for speed and `.gitignore`-awareness:

```sh
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :200 {}'"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
```

No conflict with `zsh-history-substring-search` (bound to ↑/↓; fzf is `Ctrl-R`).

**Depends on:** `fzf` (present), `fd`, `bat` (added in Component 2). If `fd`/`bat` are
missing the env vars are harmless (fzf falls back to its defaults on next shell), but
they are guaranteed present because they ship in the same manifests.

## Component 2 — modern CLI tools + additive aliases

**Files:** `macos/Brewfile`, `arch/pkglist.txt`, `wsl/pkglist.txt`,
`common/zshrc/common.zsh`. (Each platform has its own `pkglist.txt`; `install.sh` reads
`$platform_dir/pkglist.txt`, so all three manifests need the new packages.)

Add packages: `fd`, `bat`, `eza`, `git-delta` (Homebrew names: `fd`, `bat`, `eza`,
`git-delta`; pacman names: `fd`, `bat`, `eza`, `git-delta`).

Additive aliases in `common.zsh` (grouped with existing util aliases):

```sh
alias ll='eza -l --git --icons'
alias la='eza -la --git --icons'
alias lt='eza --tree --level=2'
alias lg='lazygit'
alias lzd='lazydocker'
```

`ls`, `cat`, `find` are **left unchanged**; `bat` and `fd` are used by name and by fzf.

## Component 3 — tracked gitconfig (new stow content)

**New tracked file:** `common/git/config` → stows to `~/.config/git/config`. Git reads
this via XDG natively, so **no `~/.gitconfig` symlink** is needed — it fits the existing
`--target=~/.config` model with no new `~/`-target exception (only `claude/` needs that).

Tracked `config` is **generic**: no identity, no signing, no employer trace.

- **Pager:** `git-delta` — `core.pager = delta`, `interactive.diffFilter = delta --color-only`,
  `delta.navigate = true`, `delta.line-numbers = true`, `delta.side-by-side = true`.
- **Defaults:** `init.defaultBranch = main`, `pull.rebase = true`,
  `push.autoSetupRemote = true`, `push.default = simple`, `rebase.autostash = true`,
  `fetch.prune = true`.
- **Aliases:** `st = status -sb`, `co = checkout`,
  `lg = log --oneline --graph --decorate`, `last = log -1 HEAD`,
  `undo = reset --soft HEAD~1`, `amend = commit --amend --no-edit`.
- **Include:** `[include] path = ~/.config/git/config.local` (absolute `~` path so
  git does not resolve it relative to the stow symlink's target).

**Untracked `~/.config/git/config.local`** (per machine, never committed) holds personal
`user.name` / `user.email` (personal commits stay **unsigned**), and — optionally — a
conditional include that turns on work identity + signing only inside work repos:

```gitconfig
[includeIf "gitdir:~/work/"]     # placeholder path — user sets their real work dir
    path = ~/.config/git/config.work
```

**Untracked `~/.config/git/config.work`** (per machine) holds the work email and GPG
signing config (GPG key on a hardware token / YubiKey, driven by gpg-agent):

```gitconfig
[user]
    email = you@work.example
    signingkey = <GPG key id or fingerprint>
[commit]
    gpgsign = true
[gpg]
    format = openpgp    # git default; GPG smartcard (e.g. YubiKey) via gpg-agent
```

**Tracked template `common/git/config.local.example`** demonstrates the personal-identity
block plus the commented work conditional-include pattern above, using the `~/work/`
placeholder and a generic "hardware token (e.g. YubiKey)" comment — **never "Booking"**.
The public repo ships the *mechanism*; the machine carries the employer-specific values.

**Migration note:** a real `~/.gitconfig` currently exists (set via README commands).
Git merges `~/.gitconfig` and `~/.config/git/config`, with `~/.gitconfig` taking
precedence. The plan will reconcile this: move personal identity into
`~/.config/git/config.local`, move work signing into `~/.config/git/config.work`, then
remove/blank the old `~/.gitconfig` so there is a single source of truth. The README's
manual git-setup commands (identity + signing key) will be replaced by a short
"copy `config.local.example` → `config.local` and fill in identity" instruction.

## Component 4 — `local.zsh` machine-local override hook

**Files:** `common/zshrc/common.zsh` (add sourcing line), new tracked
`common/zshrc/local.zsh.example`.

At the **very end** of `common.zsh` (after all aliases, functions, and p10k):

```sh
[ -f ~/.config/zshrc/local.zsh ] && source ~/.config/zshrc/local.zsh
```

Sourced last so a machine can override aliases/functions/PATH without editing tracked
files. The real `~/.config/zshrc/local.zsh` is untracked; `local.zsh.example` is a
tracked template. Mirrors the existing `settings.local.json` / `CLAUDE.local.md` pattern.

## Component 5 — AeroSpace dead-binding fix

**File:** `macos/aerospace/aerospace.toml`. Repoint the apps-mode `alt-w` binding from
`WezTerm.app` (not installed) to `Ghostty.app` (the actual terminal). One-line change.

---

## Stow & installer impact

- `common/git/` and the `*.example` templates are picked up automatically by the
  existing unconditional `common/` stow — **no `install.sh` change required.**
- On first stow, `prepare_config_entries` will back up any pre-existing `~/.config/git`
  that is not already managed (none today) to `git.backup.<timestamp>`.
- The `.example` files stow into `~/.config/...` as harmless example files; the real
  `.local` / `.work` files are created by the user (real files, not symlinks) alongside.
- The CI dry-run added in the prior cycle already exercises these stow additions on
  ubuntu + macos.

## Verification strategy

Each component has a concrete runtime check (TDD-ish where a runtime surface exists):

- **fzf:** `source <(fzf --zsh)` runs without error; `bindkey '^R'` shows the
  `fzf-history-widget`.
- **tools/aliases:** `command -v fd bat eza` all resolve; `alias ll` shows the eza form.
- **gitconfig:** `git config --show-origin --get core.pager` → `delta`;
  `git config --get commit.gpgsign` is **empty/false** in a personal repo (signing not
  global); with a work `config.work` present and inside the work gitdir, it resolves to
  `true`.
- **local.zsh:** creating `~/.config/zshrc/local.zsh` with a marker alias and starting a
  new shell exposes that alias; absence causes no error.
- **aerospace:** `aerospace.toml` parses; the `alt-w` value is `Ghostty.app`.

## Out of scope (this cycle)

- **`mise` / runtime version management** — Cycle 2, its own brainstorm→plan.
- `gh` CLI, `atuin`, `zoxide`, tmux prefix/TPM changes — not selected; revisit later.
- Any change to `install.sh` control flow, or to `claude/settings.json` stowing.
- Reformatting/relocating the README's WSL bootstrap block (roadmap B4) beyond replacing
  the now-obsolete manual git-setup commands.
