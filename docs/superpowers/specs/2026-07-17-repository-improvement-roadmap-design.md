# Repository Improvement Roadmap — Design

**Date:** 2026-07-17
**Status:** Approved roadmap (advisory priorities, no forced ordering)
**Repo:** `iamtienng/.dotfiles` (GitHub) — GNU Stow dotfiles for macOS, Arch Linux, WSL (Arch)

## Purpose

Capture a prioritized set of improvements across four themes: **Safety & CI**,
**Documentation & onboarding**, **Cleanup & consistency**, and **New capabilities**.

This is a roadmap, not a single implementation plan. Each theme (or slice of one)
is meant to be picked up as its own `brainstorm → plan → implement` cycle. The
`P1/P2/P3` tags are **impact/leverage advisories**, not a required sequence.

## Current state (baseline observations)

- `install.sh` is 489 lines, 24 functions, with a solid safety posture already:
  `set -euo pipefail`, `--dry-run` implemented via `stow --simulate`.
- **No automated validation exists**: no CI, no `shellcheck`, no test harness. The
  installer's non-trivial backup/stow logic (`prepare_config_entry`,
  `path_points_to_dotfiles`, `is_managed_by_stow`) is exercised only by running it.
- **Hygiene is good**: `.DS_Store`, `.env`, `.envrc` are gitignored and untracked.
- **README has drifted**: it predates the `wsl/` and `claude/` packages. The intro
  says "macOS and Arch Linux"; the layer list is only `common/macos/arch`. The
  `claude/` package (statusline, agents, commands, skills) has zero mentions.
- **README has a correctness bug**: the "Notes" section says the installer *removes*
  existing config entries, but the default behavior is to **back them up** to
  `<name>.backup.<timestamp>`; removal happens only under `--replace-existing`
  (which the README does not document at all).

## Priority spine

If only the highest-leverage items are done, they are: **A1, A2** (shellcheck +
`--dry-run` in CI) and **B1, B2** (README correctness + `wsl/`/`claude/` coverage).
Together these make the repo meaningfully safer and self-explanatory.

---

## Theme A — Safety & CI (P1)

Goal: turn the installer's latent quality into an enforced guarantee. Host is
GitHub, so GitHub Actions with macOS + Linux runners is the natural home.

- **A1 — `shellcheck` in CI (P1).** Lint `install.sh`, `common/scripts/*`, and
  `claude/statusline-command.sh`. Fix any warnings surfaced.
- **A2 — `install.sh --dry-run` in CI (P1).** Run on `ubuntu-latest` and
  `macos-latest`. Install `stow` on the runner; invoke with `--skip-packages` and
  `--skip-zsh-tools` so the job exercises the stow-simulate + backup logic without
  needing Homebrew/pacman. Highest-value guardrail.
- **A3 — Manifest sanity checks (P2).** Verify the Brewfile parses
  (`brew bundle list --file macos/Brewfile`) and `pkglist*.txt` are readable/parse
  cleanly (respecting `#` comments as `read_package_list` does).
- **A4 — Harden the destructive path (P2).** `--replace-existing` runs `rm -rf`.
  Add a loud confirmation/log line, and ensure `--dry-run` explicitly narrates what
  it *would* remove vs back up.
- **A5 — `shfmt` + `.editorconfig` (P3).** Consistent shell formatting, optionally
  enforced in CI.

**Acceptance:** a CI badge-able workflow where a green run means "install.sh lints
clean and dry-runs successfully on both OSes."

## Theme B — Documentation & onboarding (P1–P2)

- **B1 — Fix the "removes vs backs up" bug (P1).** Correct the README Notes to
  describe the default backup behavior and the `--replace-existing` opt-in.
- **B2 — Document `wsl/` and `claude/` (P1).** Update the intro to "macOS, Arch, and
  WSL"; add `wsl/` and `claude/` to the layer list; describe the
  `claude/ → ~/.claude` stow exception and what it ships (statusline, agents,
  commands, skills). Note that `claude/settings.json` is intentionally NOT stowed.
- **B3 — Document `--replace-existing` (P2).** Add it to "Useful options" with an
  explicit "DANGEROUS" note.
- **B4 — Restructure the WSL bootstrap (P2).** Convert the inline shell dump into a
  clear numbered one-time-setup subsection. **Flag (non-urgent cleanup):** the
  README currently embeds a personal git email and SSH signing public key; note it
  as something to reconsider/relocate. Low risk (public key + email), not urgent.
- **B5 — Reference CLAUDE.md as the architecture doc (P3).** Link it from the README
  rather than duplicating the architecture writeup.

**Acceptance:** a fresh reader can understand all four stow layers, the `~/.claude`
exception, and the true (backup-first) install behavior without reading the source.

## Theme C — Cleanup & consistency (P2)

- **C1 — Unify `.stowrc` ignores (P2).** `macos/.stowrc` ignores `README.*\.md` but
  `common/arch/wsl` do not. Standardize so a README can live in any layer without
  being symlinked into `~/.config`.
- **C2 — Manifest ↔ config audit (P2).** Verify every configured tool has a package
  entry and vice versa (Brewfile/pkglist vs actual config dirs). Candidate to
  graduate into a CI lint (ties to A3).
- **C3 — `.gitignore` consolidation (P3).** Five scattered `.gitignore` files (root,
  `arch/hypr`, `common/k9s`, `common/nvim`, `common/zed`). Fold generic
  generated-file ignores into root where sensible; keep tool-specific ones local.
- **C4 — Local `.DS_Store` sweep (P3).** Working-tree clutter only (already
  gitignored); not a repo change.

**Acceptance:** stow layers follow one consistent convention; no orphan configs or
orphan package entries.

## Theme D — New capabilities (P3, opt-in / YAGNI-gated)

Only worth doing if they solve a real friction. Listed for completeness.

- **D1 — Per-machine local overrides (P3).** Extend the existing
  `settings.local.json` / `CLAUDE.local.md` pattern to the shell: source
  `~/.config/zshrc/local.zsh` if present, and support a `Brewfile.local`.
- **D2 — Documented `sops` secrets flow (P3).** A documented sops-based flow for
  `.env`/`.envrc` (tooling already present via `common/nvim/.../lang/sops.lua`).
- **D3 — `install.sh --update` (P3).** One-shot pull + restow + refresh zsh tools.
- **D4 — `install.sh --check` doctor mode (P3).** Report config drift / broken
  symlinks without changing anything; pairs with the CI work in Theme A.

**Acceptance (per item):** the capability is documented and dry-run-safe.

---

## How to consume this roadmap

1. Pick a theme or a slice (e.g. the P1 spine, or "Theme A only").
2. Run it through `brainstorming → writing-plans` as its own cycle.
3. Implement with TDD/verification where a runtime surface exists (the installer
   qualifies); request code review; finish the branch cleanly.

## Out of scope

- Rewriting/modularizing `install.sh` into multiple files — the single-file
  installer is appropriate for a dotfiles repo (explicitly not pursued; YAGNI).
- Any change to `claude/settings.json` stowing (intentionally excluded).
