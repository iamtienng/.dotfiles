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
