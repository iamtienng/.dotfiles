# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal dotfiles for **macOS**, **Arch Linux**, and **WSL (Arch)**, managed with **GNU Stow**. There is no build/test/lint pipeline — the "commands" are the installer and the stow workflow.

## Commands

```sh
./install.sh                 # detect OS, install packages, install zsh tooling, stow configs
./install.sh --dry-run       # preview every action without touching files (uses stow --simulate)
./install.sh --skip-packages # skip Homebrew/pacman package install
./install.sh --skip-zsh-tools# skip Oh My Zsh / Powerlevel10k / evalcache
./install.sh --skip-stow     # skip linking
./install.sh --replace-existing  # DANGEROUS: rm existing ~/.config entries instead of backing them up
```

Manual stow of just the dotfiles (no packages):

```sh
cd common && stow --restow .
cd ../macos && stow --restow .   # or ../arch, ../wsl
```

Always validate stow changes with `./install.sh --dry-run` before running for real.

## Architecture

### Stow layers → `~/.config`
Every package directory (`common/`, `macos/`, `arch/`, `wsl/`) stows into `~/.config` (set by each dir's `.stowrc` with `--target=~/.config --no-folding`). `install.sh` always stows **`common/` plus exactly one detected OS package**. `--no-folding` is deliberate: it creates real directories and symlinks individual files, so `common/` and the OS package can merge into the same config dir (e.g. `common/ghostty/themes/` + `macos/ghostty/config`). Keep this in mind when adding files — putting a file in `common/ghostty/` vs `macos/ghostty/` decides whether it's shared or OS-specific, and both land in `~/.config/ghostty/`.

### `claude/` → `~/.claude` (exception to the `~/.config` rule)
`claude/` is a shared, all-platform package whose `.stowrc` targets **`~/.claude`** instead of `~/.config` (Claude Code reads config from `~/.claude`, not XDG). It holds the share-safe Claude config — `statusline-command.sh` (referenced by the machine-local `~/.claude/settings.json`'s `statusLine.command`), plus `agents/`, `commands/`, `skills/`, `docs/`, and `keybindings.json`. `install.sh` stows it unconditionally (like `common/`) via the target-aware `stow_package "$pkg" "$CLAUDE_HOME"` / `prepare_config_entries "$CLAUDE_HOME" ...` helpers — these take the target dir as a parameter so the backup-existing logic works against `~/.claude` too. Note: `settings.json` is deliberately **not tracked in this repo** — it holds machine-specific config (the `ANTHROPIC_BASE_URL` gateway, the `the token helper` token helper, and the per-machine `model` pin such as `opusplan[1m]`) and exists only as a standalone, untracked file at `~/.claude/settings.json` (not stowed, not symlinked).

### Zsh: shared body + platform heads
This is the most important pattern in the repo.

- `common/zshrc/common.zsh` — the shared body: Oh My Zsh load, history, aliases (kube, terragrunt, utils), line-editor plugins, p10k sourcing.
- `macos/zshrc/.zshrc`, `arch/zshrc/.zshrc`, `wsl/zshrc/.zshrc` — platform heads. Each one **sources `common.zsh` at its end**.

A platform head MUST set up, *before* sourcing common.zsh:
1. the **Powerlevel10k instant-prompt block first of all** (top of file),
2. PATH / Homebrew (macOS) or pacman paths / nvm,
3. `fpath` completion dirs,
4. `$ZSH_PLUGIN_DIR` (base dir holding the `zsh-*` line-editor plugins),
5. `plugins=(...)` (the Oh My Zsh plugin list),
6. platform-only package-manager aliases (`brew*` / `pacman*`).

**Edit shared behavior once in `common.zsh`; edit platform quirks in the matching head.** Don't duplicate shared logic into the heads.

`install.sh` links `~/.zshrc → ~/.config/zshrc/.zshrc` (the stowed platform head), but only when `~/.zshrc` is missing or already a symlink — a real `~/.zshrc` file is left untouched.

`nvm` is **lazy-loaded**: the default node is prepended to PATH immediately (so `node`/`npm`/`npx` and the p10k node segment work at zero startup cost), and the heavy `nvm.sh` is only sourced on the first actual `nvm` call.

### install.sh flow
`detect_platform` → `install_packages` (Brewfile / pacman+AUR via yay|paru) → `install_zsh_tools` (clones/updates Oh My Zsh, Powerlevel10k, evalcache into `~/.oh-my-zsh`) → `stow_dotfiles`.

`stow_dotfiles` is conservative about existing configs: `prepare_config_entries` enumerates the top-level entry names from `common/` + the OS package, and for each existing `~/.config/<name>` that is **not** already stow-managed (it checks whether symlinks resolve back into this repo via `path_points_to_dotfiles`), it **backs it up** to `<name>.backup.<timestamp>` (or removes it only under `--replace-existing`). Then it stows and marks `~/.config/scripts/*` executable.

### Package manifests
- macOS: `macos/Brewfile` (`brew bundle`).
- Arch / WSL: `pkglist.txt` (pacman) and `pkglist-aur.txt` (AUR). `read_package_list` strips `#` comments and blank lines, so these files may be commented.

When adding a tool, add both its config (under the right stow layer) and its package entry (Brewfile and/or pkglist).

### Neovim
LazyVim-based: `common/nvim/init.lua` → `config.lazy` (bootstraps lazy.nvim) → `lua/config/*` (options, keymaps, autocmds) and `lua/plugins/*` specs. Shared across all platforms via `common/`. Lua is formatted with `stylua` per `common/nvim/stylua.toml`.

### Scripts
`common/scripts/` are stowed to `~/.config/scripts/` and chmod'd +x by the installer. `tmux-sessionizer` fzf-picks a dir under `~/project` (depth 3) and opens/switches a tmux session named after it.

## Conventions

- `.gitignore` excludes generated/secret files: `.DS_Store`, `.env`, `.envrc`, `Brewfile.lock.json`, Karabiner `automatic_backups`, Zed `*.mdb`, `packer_compiled.lua`. Don't commit these.
- Each `.stowrc` ignores `.stowrc`, `.DS_Store`, `.gitignore` (macOS also `README*.md`) so they aren't symlinked into `~/.config`.
