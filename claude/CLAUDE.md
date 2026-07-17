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
