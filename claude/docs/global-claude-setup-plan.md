# Global Claude Code Setup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a thin, version-controlled global layer to `~/.claude/` that makes Superpowers the default methodology across all projects.

**Architecture:** Author files in `~/project/personal/dev/.dotfiles/claude/` and link into `~/.claude/` via GNU Stow (`--no-folding`, target `~/.claude`). Four independent deliverables: tracked+tuned `settings.json`, global `CLAUDE.md`, a `/ship` entry command, and retirement of role-generalist agents.

**Tech Stack:** GNU Stow 2.4.1, git (SSH-signed commits), JSON, Markdown.

## Global Constraints

- Stow config is fixed: `--target=~/.claude`, `--no-folding` (`dotfiles/claude/.stowrc`). Re-link command: `cd ~/project/personal/dev/.dotfiles && stow --restow --target ~/.claude claude`.
- Preserve these `settings.json` keys VERBATIM: `apiKeyHelper`, all `env` keys (`ANTHROPIC_BASE_URL`, `ANTHROPIC_DEFAULT_SONNET_MODEL`, `ANTHROPIC_DEFAULT_HAIKU_MODEL`, `ANTHROPIC_DEFAULT_OPUS_MODEL`, `ENABLE_TOOL_SEARCH`, `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS`), `model`, `statusLine`, `enabledPlugins`, `extraKnownMarketplaces`, `theme`.
- Introduce NO beta-gated feature (betas disabled corporate-wide).
- Global `CLAUDE.md` < 60 lines; goals/constraints style, not railroaded steps.
- Commits are SSH-signed; the signing key must be loaded in `ssh-agent` before committing (`ssh-add <key>`).
- Commit only the files each task touches; never stage the unrelated `macos/zshrc/.zshrc` change.
- `attribution` is blanked, so committed messages carry NO `Co-Authored-By` trailer once Task 1 lands; before then, follow existing repo convention.

---

### Task 1: Track and tune global `settings.json`

**Files:**
- Create: `~/project/personal/dev/.dotfiles/claude/settings.json`
- Backup+remove: `~/.claude/settings.json` (real file → becomes a stow symlink)
- Verify: symlink `~/.claude/settings.json`

**Interfaces:**
- Produces: a stowed `~/.claude/settings.json` symlink with all managed keys plus `outputStyle`, `alwaysThinkingEnabled`, `cleanupPeriodDays`, `attribution`.

- [ ] **Step 1: Snapshot the current live settings for comparison**

Run:
```bash
cp ~/.claude/settings.json /tmp/claude-settings.before.json
cat /tmp/claude-settings.before.json
```
Expected: prints the current JSON (managed keys). Keep this file to diff against.

- [ ] **Step 2: Create the tracked settings file with all keys**

Create `~/project/personal/dev/.dotfiles/claude/settings.json` with exactly:
```json
{
  "apiKeyHelper": "<corporate-token-helper-command>",
  "env": {
    "ANTHROPIC_BASE_URL": "https://<corporate-llm-gateway>/anthropic/claude_code/",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "<gateway-sonnet-model-id>",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "<gateway-haiku-model-id>",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "<gateway-opus-model-id>",
    "ENABLE_TOOL_SEARCH": "false",
    "CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS": "1"
  },
  "model": "opus",
  "outputStyle": "Explanatory",
  "alwaysThinkingEnabled": true,
  "cleanupPeriodDays": 30,
  "attribution": {
    "commit": "",
    "pr": ""
  },
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/statusline-command.sh"
  },
  "enabledPlugins": {
    "superpowers@claude-plugins-official": true
  },
  "extraKnownMarketplaces": {},
  "theme": "auto"
}
```

- [ ] **Step 3: Verify the tracked file is valid JSON and preserves managed keys**

Run:
```bash
python3 -m json.tool ~/project/personal/dev/.dotfiles/claude/settings.json >/dev/null && echo "VALID JSON"
python3 -c "import json;d=json.load(open('$HOME/project/personal/dev/.dotfiles/claude/settings.json'));print('base_url ok:', d['env']['ANTHROPIC_BASE_URL'].endswith('claude_code/'));print('betas disabled ok:', d['env']['CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS']=='1');print('attribution blank ok:', d['attribution']=={'commit':'','pr':''})"
```
Expected: `VALID JSON`, then three `... ok: True` lines.

- [ ] **Step 4: Remove the live real file so Stow can link it**

Run:
```bash
mv ~/.claude/settings.json ~/.claude/settings.json.bak
```
Expected: no output; `~/.claude/settings.json` no longer exists as a real file (backup kept).

- [ ] **Step 5: Re-stow to create the symlink**

Run:
```bash
cd ~/project/personal/dev/.dotfiles && stow --restow --target ~/.claude claude
ls -l ~/.claude/settings.json
```
Expected: `~/.claude/settings.json -> ../project/personal/dev/.dotfiles/claude/settings.json` (a symlink).

- [ ] **Step 6: Confirm no drift vs. the pre-change managed keys**

Run:
```bash
python3 -c "import json;a=json.load(open('/tmp/claude-settings.before.json'));b=json.load(open('$HOME/.claude/settings.json'));import sys;missing=[k for k in a if k not in b];print('missing top-level keys:', missing or 'none');print('env preserved:', a['env']==b['env'])"
```
Expected: `missing top-level keys: none` and `env preserved: True`.

- [ ] **Step 7: Remove the backup and commit**

Run:
```bash
rm ~/.claude/settings.json.bak
cd ~/project/personal/dev/.dotfiles
git add claude/settings.json
git commit -m "feat(claude): track global settings.json in dotfiles; Explanatory+thinking, blank attribution, explicit cleanup"
```
Expected: one new commit; `git status --short` shows only the pre-existing `macos/zshrc/.zshrc` (untouched).

---

### Task 2: Global `CLAUDE.md`

**Files:**
- Create: `~/project/personal/dev/.dotfiles/claude/CLAUDE.md`
- Verify: symlink `~/.claude/CLAUDE.md`

**Interfaces:**
- Consumes: nothing.
- Produces: `~/.claude/CLAUDE.md` loaded into every session as user memory.

- [ ] **Step 1: Verify no global CLAUDE.md exists yet**

Run:
```bash
test -e ~/.claude/CLAUDE.md && echo "EXISTS" || echo "ABSENT (expected)"
```
Expected: `ABSENT (expected)`.

- [ ] **Step 2: Create the global CLAUDE.md**

Create `~/project/personal/dev/.dotfiles/claude/CLAUDE.md` with exactly:
```markdown
# Global preferences (all projects)

## Methodology — default to Superpowers
- Brainstorm before planning; use plan mode for non-trivial work.
- TDD wherever a runtime surface exists; verify-before-completion by exercising
  the change, not just tests.
- Request code review before shipping; finish branches cleanly.

## Context hygiene
- Keep context < 40%. `/compact` with a focus hint or `/clear` when switching tasks.
- Offload search/exploration to subagents so only conclusions return to main context.

## Git / PR
- Small, focused PRs — one feature each. Squash merge. Commit ~hourly or on task completion.

## Agents & skills
- Prefer feature-specific subagents + skills over generalist role agents.
- If I do something more than once a day, turn it into a command or skill.

## Debugging
- Share screenshots for visual issues. Run long-lived commands as background tasks.
- Use a browser MCP so console logs can be read directly.

## New-project bootstrap (do this when starting any repo)
1. Root `CLAUDE.md` with build/test/run commands + repo conventions.
2. Committed `.claude/settings.json` with a project permission allowlist.
3. Feature-specific agents/skills in `.claude/` as needed (not generalists).
4. `.claude/settings.local.json` / `CLAUDE.local.md` for personal, unshared overrides.
```

- [ ] **Step 3: Verify the file is under the 60-line budget**

Run:
```bash
wc -l ~/project/personal/dev/.dotfiles/claude/CLAUDE.md
```
Expected: a number ≤ 60.

- [ ] **Step 4: Re-stow and verify the symlink**

Run:
```bash
cd ~/project/personal/dev/.dotfiles && stow --restow --target ~/.claude claude
ls -l ~/.claude/CLAUDE.md
```
Expected: `~/.claude/CLAUDE.md -> ../project/personal/dev/.dotfiles/claude/CLAUDE.md`.

- [ ] **Step 5: Commit**

Run:
```bash
cd ~/project/personal/dev/.dotfiles
git add claude/CLAUDE.md
git commit -m "feat(claude): add global CLAUDE.md — Superpowers defaults, context hygiene, project bootstrap"
```
Expected: one new commit; `macos/zshrc/.zshrc` remains unstaged.

---

### Task 3: `/ship` entry command

**Files:**
- Create: `~/project/personal/dev/.dotfiles/claude/commands/ship.md`
- Verify: symlink `~/.claude/commands/ship.md`

**Interfaces:**
- Consumes: Superpowers skills `verification-before-completion`, `requesting-code-review`, `finishing-a-development-branch` (invoked via the Skill tool).
- Produces: a globally available `/ship` slash command.

- [ ] **Step 1: Verify the command does not exist yet**

Run:
```bash
test -e ~/.claude/commands/ship.md && echo "EXISTS" || echo "ABSENT (expected)"
```
Expected: `ABSENT (expected)`.

- [ ] **Step 2: Create the command file**

Create `~/project/personal/dev/.dotfiles/claude/commands/ship.md` with exactly:
```markdown
---
description: Wrap up the current change and put it up for review — routes into Superpowers.
when_to_use: When a change is functionally done and you want to verify, review, and finish the branch.
argument-hint: "[optional note about scope]"
---

You are wrapping up work to ship it. Do NOT reimplement any logic — route into the
installed Superpowers skills, in order, and stop if any step surfaces a blocker:

1. Invoke the `superpowers:verification-before-completion` skill and exercise the change
   end-to-end (not just tests). If verification fails, report and stop.
2. Invoke `superpowers:requesting-code-review`. Address blocking findings before continuing.
3. Invoke `superpowers:finishing-a-development-branch` to finalize the branch.

Extra context from the user (optional): $ARGUMENTS
```

- [ ] **Step 3: Re-stow and verify the symlink**

Run:
```bash
cd ~/project/personal/dev/.dotfiles && stow --restow --target ~/.claude claude
ls -l ~/.claude/commands/ship.md
```
Expected: `~/.claude/commands/ship.md -> ../../project/personal/dev/.dotfiles/claude/commands/ship.md`.

- [ ] **Step 4: Commit**

Run:
```bash
cd ~/project/personal/dev/.dotfiles
git add claude/commands/ship.md
git commit -m "feat(claude): add global /ship command routing into Superpowers verify/review/finish"
```
Expected: one new commit; `macos/zshrc/.zshrc` remains unstaged.

---

### Task 4: Retire role-generalist agents

**Files:**
- Remove: `~/project/personal/dev/.dotfiles/claude/agents/{clean-code-reviewer,documentation-writer,implementation-agent,performance-optimizer,secure-reviewer,test-engineer}.md`
- Keep: `~/project/personal/dev/.dotfiles/claude/agents/{code-reviewers,debugger}.md`
- Verify: `~/.claude/agents/` contains only the two kept symlinks

**Interfaces:**
- Consumes: nothing.
- Produces: a global agents dir with only cross-project utilities.

- [ ] **Step 1: EXECUTION GATE — reconfirm the retire list with the user**

Show the user the six files to remove and the two to keep. Do NOT proceed to Step 2 until they confirm. (Files remain in git history and are recoverable.)

- [ ] **Step 2: Record the current agent set**

Run:
```bash
ls ~/.claude/agents/
```
Expected: 8 symlinks (clean-code-reviewer, code-reviewers, debugger, documentation-writer, implementation-agent, performance-optimizer, secure-reviewer, test-engineer).

- [ ] **Step 3: Remove the six role-generalist source files**

Run:
```bash
cd ~/project/personal/dev/.dotfiles/claude/agents
git rm clean-code-reviewer.md documentation-writer.md implementation-agent.md performance-optimizer.md secure-reviewer.md test-engineer.md
```
Expected: git reports 6 files removed.

- [ ] **Step 4: Re-stow so the dropped symlinks are cleaned up**

Run:
```bash
cd ~/project/personal/dev/.dotfiles && stow --restow --target ~/.claude claude
ls ~/.claude/agents/
```
Expected: only `code-reviewers.md` and `debugger.md` remain.

- [ ] **Step 5: Verify no dangling symlinks remain**

Run:
```bash
find ~/.claude/agents/ -xtype l -print
```
Expected: no output (no broken links).

- [ ] **Step 6: Commit**

Run:
```bash
cd ~/project/personal/dev/.dotfiles
git commit -m "refactor(claude): retire role-generalist global agents; keep code-reviewers + debugger"
```
Expected: one new commit; `macos/zshrc/.zshrc` remains unstaged.

---

## Post-implementation verification

- [ ] **Open a fresh Claude session in any project and confirm:** Explanatory output style + thinking are active, and the global `CLAUDE.md` guidance is loaded (`/memory` shows the user file).
- [ ] **Run `/ship --help`-style check:** typing `/ship` is recognized as a command.
- [ ] **`claude` still authenticates** against the corporate endpoint (apiKeyHelper unaffected).
