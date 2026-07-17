# Global Claude Code Setup — Design Spec

**Date:** 2026-07-17
**Author:** Tien Nguyen (with Claude Code)
**Status:** Draft for review
**Source of patterns:** `~/project/personal/dev/claude-code-best-practice` (reference "course" repo)

---

## 1. Goal

Make the best-practice patterns from the reference repo apply across **all** projects by
adding a **thin global layer** to `~/.claude/`, and standardize on **Superpowers** as the
default development methodology. Config + methodology, not just a reading plan.

All changes are authored in the **dotfiles repo** (`~/project/personal/dev/.dotfiles/claude/`)
and linked into `~/.claude/` via **GNU Stow**, matching how `keybindings.json`,
`statusline-command.sh`, `agents/`, and `skills/` are already managed.

## 2. Locked decisions

| Decision | Choice |
|----------|--------|
| Outcome | Config **and** methodology |
| Methodology base | **Standardize on Superpowers** (already installed & enabled globally) — lowest new surface area; do not reimplement what its skills already do |
| Where changes land | **dotfiles repo + Stow** (`dotfiles/claude/` → `~/.claude/`) |
| Approach | **Approach 1 — thin layer** (not the fuller toolkit, not docs-only) |
| Generalist agents | **Keep cross-project utilities, retire role-generalists** |

## 3. Constraints (must respect)

- **Corporate/managed environment.** Global `settings.json` sets `ANTHROPIC_BASE_URL`
  (<corporate-llm-gateway>), an `apiKeyHelper`, per-tier model env vars,
  `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS: "1"`, and `ENABLE_TOOL_SEARCH: "false"`.
  These keys are **preserved verbatim**. No beta-gated feature (agent teams, channels,
  ultraplan, auto mode, etc.) is introduced, because betas are disabled.
- **Stow mechanism.** `dotfiles/claude/.stowrc` targets `~/.claude` with `--no-folding`,
  so directories are real and files inside are individually symlinked. New global files
  are added by placing them under `dotfiles/claude/` and re-stowing.
- **Thin CLAUDE.md.** Target < 60 lines (repo guidance: < 200 hard cap; humanlayer ~60).
  Write goals and constraints, not railroaded step-by-step instructions.
- **No duplication of Superpowers.** Entry commands route *into* Superpowers skills; they
  do not re-encode brainstorming/planning/TDD logic.

## 4. Design — five pieces

### 4.1 Global `CLAUDE.md`  (new → `dotfiles/claude/CLAUDE.md`, stowed to `~/.claude/CLAUDE.md`)

A short personal, cross-project memory file. Content sections (goals/constraints style):

- **Methodology (defer to Superpowers):** brainstorm before planning; use plan mode for
  non-trivial tasks; TDD where a runtime surface exists; verify-before-completion by
  exercising the change, not just tests; request code review before shipping.
- **Context hygiene:** keep context < 40%; `/compact` with a focus hint or `/clear` when
  switching tasks; prefer subagents for search/exploration so only conclusions return.
- **Git/PR:** small focused PRs (one feature); squash merge; commit ~hourly / on task
  completion.
- **Agents & skills:** prefer **feature-specific** subagents + skills over generalist
  role agents; if something is done more than once a day, make it a command or skill.
- **Debugging:** screenshots for visual issues; run long-lived commands as background
  tasks; use a browser MCP so Claude can read console logs.

Explicitly **not** in CLAUDE.md: anything `settings.json` enforces deterministically
(attribution, permissions, model) — per the repo tip to prefer settings for
harness-enforced behavior.

### 4.2 `settings.json` tuning  (edit existing global file; all the company keys preserved)

Add personal-default keys:

- `"outputStyle": "Explanatory"` — see reasoning + ★ Insight boxes.
- `"alwaysThinkingEnabled": true` — see reasoning (pairs with Explanatory, per Boris).
- `"cleanupPeriodDays"` — set an explicit retention (value decided in plan).
- `"attribution": { "commit": "", "pr": "" }` — **blank both** (LOCKED): no
  `Co-Authored-By` trailer, no PR generated-with line.

**Tracking (LOCKED):** move the global `settings.json` into `dotfiles/claude/settings.json`
and stow it so all tuning is version-controlled. It contains no secrets — the token comes
from `apiKeyHelper` at runtime. Before stowing, the existing real `~/.claude/settings.json`
must be relocated (not left in place) so Stow can create the symlink; all current the company
keys are copied verbatim into the tracked file first.

### 4.3 Thin entry command(s)  (new → `dotfiles/claude/commands/`, stowed to `~/.claude/commands/`)

Start with **one** command, add more only if a repeated inner-loop appears:

- `/ship` — chains the tail of the Superpowers flow: verification-before-completion →
  requesting-code-review → finishing-a-development-branch. A single entry point for
  "wrap up and put it up," per Boris's `/go` tip, but delegating to installed skills.

Additional commands (e.g. `/context-dump`, `/techdebt`) are **out of scope** for the thin
layer and deferred to a later iteration if a daily need emerges.

### 4.4 Generalist-agent cleanup  (edits in `dotfiles/claude/agents/`)

Current 8 global agents → keep/retire:

| Agent | Action | Rationale |
|-------|--------|-----------|
| `code-reviewers` | **Keep** | Cross-project review utility |
| `debugger` | **Keep** | Cross-project debugging utility |
| `implementation-agent` | **Retire** | Role-generalist; becomes per-project feature-specific |
| `performance-optimizer` | **Retire** | Role-generalist |
| `test-engineer` | **Retire** | Role-generalist; Superpowers TDD + per-project agents cover this |
| `clean-code-reviewer` | **Retire** | Overlaps `code-reviewers` + bundled `/code-review` |
| `secure-reviewer` | **Retire** | Overlaps bundled `/security-review` |
| `documentation-writer` | **Retire** | Role-generalist; per-project or bundled skills cover this |

"Retire" = remove from `dotfiles/claude/agents/` and re-stow (symlink drops out of
`~/.claude/agents/`). Files remain recoverable in git history. **Nothing deleted without
explicit confirmation during execution.**

### 4.5 New-project bootstrap pattern  (documented, lives in global `CLAUDE.md` or a short skill)

A checklist for standing up any new repo so "run the tests" works on the first try:

1. Root `CLAUDE.md` with build/test/run commands + repo conventions.
2. Committed `.claude/settings.json` with a project permission allowlist.
3. Feature-specific agents/skills in `.claude/` as needed (not generalists).
4. `.claude/settings.local.json` / `CLAUDE.local.md` for personal, unshared overrides.

Placement (LOCKED): **inline note in the global `CLAUDE.md`** (cheapest, no extra surface).
A dedicated bootstrap skill can come later if the checklist grows.

## 5. Mechanics (how a change is applied)

1. Author/modify files under `~/project/personal/dev/.dotfiles/claude/`.
2. Re-stow: `cd ~/project/personal/dev/.dotfiles && stow --restow --target ~/.claude claude`
   (or `./install.sh`), which creates/updates/removes symlinks in `~/.claude/`.
3. Verify symlinks (`ls -l ~/.claude/CLAUDE.md ~/.claude/commands/`).
4. Commit each logical change to the dotfiles repo (separate, descriptive commits).

## 6. Out of scope (YAGNI)

- Any experimental/beta feature (betas are disabled corporate-wide).
- New MCP servers (curate later; repo warns more ≠ better).
- RPI or the fuller command toolkit (Approach 2/3 rejected).
- Rewriting Superpowers skills.

## 7. Success criteria

- Opening Claude in **any** project loads a thin global `CLAUDE.md` and Explanatory +
  thinking defaults.
- Superpowers is the assumed default methodology (reflected in CLAUDE.md guidance).
- `/ship` is available globally and routes into Superpowers.
- Global agent list contains only cross-project utilities; role-generalists retired.
- Every change is version-controlled in the dotfiles repo and reproducible via Stow.
- No the company/managed settings key is altered.

## 8. Open sub-decisions carried into the plan

1. `cleanupPeriodDays` value (propose a default in the plan).
2. Confirm the retire list once more before any file removal (execution-time gate).

**Resolved at review:** track `settings.json` in dotfiles (§4.2); blank `attribution`
(§4.2); bootstrap pattern inline in global `CLAUDE.md` (§4.5).
