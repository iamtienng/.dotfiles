---
name: commit
description: Stage changes and create a git commit with a clear, WHY-focused message. Use this whenever the user wants to commit, save, or check in their work — phrases like "commit this", "commit my changes", "make a commit", or when wrapping up a unit of work that should be recorded. Inspects the actual diff first and writes a message that explains why the change was made.
---

# Commit

Anyone can read the diff to see *what* changed — the commit message exists to record *why*. Treat it as self-sufficient documentation for whoever does archaeology on this code later (possibly you).

## Gather context first

```bash
git status            # what's staged, unstaged, untracked
git diff HEAD         # the actual change
git log --oneline -10 # match the repo's existing style
```

## One commit = one logical change

If the diff covers several unrelated changes, you can't write a non-vague subject for it — that's the signal to split into separate commits. Offer to do so.

## Write the message

**Subject line:** short, at-a-glance summary of the change (tooling like `git log --oneline` treats it like an email subject). Blank line after it.

**Body** (word-wrapped ~72 cols) — invest here in proportion to how non-trivial and how load-bearing the code is. Cover what's relevant:

- **WHAT** was wrong / what this does — a little "what" disambiguates *intent* from what you actually implemented.
- **WHY** it was a problem and **HOW** this addresses it — the part no one can recover from the code.
- **Dead ends:** approaches you tried that didn't work, so the next person doesn't repeat them.
- **Data:** paste error output, or before/after, when it makes the change concrete.
- **Links** (Jira, wiki, PR) are welcome — but copy the relevant text into the message, since links rot and access varies.

Never include PII. For a trivial change (typo, formatting) a one-line subject is fine — the bar scales with impact.

## Commit

Stage the files that belong to this change (prefer specific paths over a blanket `git add .` when the tree has unrelated edits), commit, then show the result with `git log -1 --stat`.

**Example subject:** `Fix price mismatch between Hotel page and search results`
(body then explains the two paths computed prices differently and now share one code path.)
