---
name: mr-description
description: Use when the user wants an MR/merge-request description for their current GitLab branch — "write the MR description", "MR desc", "describe this MR", "get the MR text ready to paste". Produces one ready-to-copy block filled into the repo's own MR template with the JIRA ticket linked. This is narrower than the `pr` skill (which also runs checks and commits).
---

# MR Description (GitLab, ready to paste)

Produce a merge request description for the current branch that the user can copy **verbatim** into GitLab's description box — filled into the repo's own MR template, with the JIRA ticket linked. No pre-check running, no committing; that's the `pr` skill's job.

**Core principle:** the output is a paste, not a report. Everything the user needs is inside one fenced block; nothing before or after it needs to be deleted.

## Steps

1. **Gather the change.** Determine the base branch (`master`/`main` — check `git remote show origin` or default to `master`). Then:
   ```bash
   git log <base>..HEAD --oneline
   git diff <base>...HEAD --stat
   ```
   Read the full diff for anything non-obvious. Group changes logically; don't just restate the commit list.

2. **Find the JIRA ticket.** Scan commit subjects and the branch name for a key like `CRON-1234` (pattern `[A-Z]+-\d+`). Link it: `https://<your-jira-host>/browse/CRON-1234`. If several appear, use the dominant one. If none, omit the link and note that.

3. **Use the repo's MR template.** Look for `.gitlab/merge_request_templates/*.md` (prefer `default.md`). If present, fill it in exactly — keep its headings and order. For checklist pairs (Documentation / API / Testing), tick **exactly one box per pair** based on the actual diff:
   - API changed (endpoints, request/response, swagger annotations) → tick "changes the API" ; else tick "doesn't change the API".
   - source code changed → tick "changes source code and I have implemented tests" (only if tests are in the diff; otherwise flag it) ; else "doesn't change source code".
   - dev workflow / README changed → tick accordingly.
   If there is no template, use: **Summary** (1 line), **What changed**, **Why**, **Testing**.

4. **Write the Description body.** Lead with the ticket link + a one-line summary in the repo's tone (their commits use `CRON-XXXX:` and conventional prefixes like `chore(scope):`). Then the concrete changes grouped logically, and *why*. Keep it tight — a reviewer's briefing, not an essay. Put risk/rollout notes (e.g. "requires policy X deployed first") **inside** the block under a short heading, not as out-of-band commentary.

## Output contract (this is what "ready to copy" means)

- Emit the **entire MR body inside one ```markdown fenced block**.
- Put the suggested **MR title on a line above the block, labelled** (`Title:`) — the title is set in a separate GitLab field, so it stays outside the paste.
- **Nothing else inside the block.** No "Here is...", no "Key files:", no "One thing to flag..." trailing the block. If it's worth saying, it goes in the description under a heading; if it's meta-commentary to the user, put it *after* the closing fence in one short line.
- Do not invent testing you didn't verify from the diff. If tests are absent, say so in the Testing section rather than ticking the box.

## Common mistakes

- Writing a GitHub-style PR summary and ignoring the repo's checklist template — GitLab renders `- [x]` as ticked boxes; use them.
- Leaving the ticket as bare text instead of a JIRA link.
- Wrapping the block in prose the user has to strip before pasting (the #1 baseline failure).
- Ticking a "tests implemented" box when the diff has no tests.
