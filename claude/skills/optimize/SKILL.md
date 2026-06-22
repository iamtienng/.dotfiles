---
name: optimize
description: Analyze code for performance problems and propose concrete optimizations. Use this whenever the user wants to make code faster, cut latency or memory use, find a bottleneck, profile a slow path, or asks for a performance review of a function, file, or hot path. Reports issues ranked by severity with the location, why it's slow, and a fix — language-agnostic.
---

# Optimize

Find what's actually making code slow and propose fixes that are worth the complexity they add. Premature or speculative optimization is a cost, not a win — so anchor on evidence and call out when a "problem" isn't worth fixing.

## Where to look

Review the code in roughly this order of impact:

1. **Algorithmic complexity** — the highest-leverage wins. Nested scans over the same data (O(n²)), repeated linear lookups that should be a map/set, work inside a loop that could hoist out, sorting when a single pass would do.
2. **Wasted/repeated work** — the same computation or request issued more than once; results that could be memoized or cached; eager work that could be lazy.
3. **I/O and round-trips** — N+1 queries, per-item network/db calls that could batch, missing pagination, chatty calls on a hot path. I/O usually dominates CPU, so weight it accordingly.
4. **Allocation & memory** — allocation in hot loops, copies that could be references/views, unbounded buffers or caches (a leak in managed languages is usually an unbounded collection or a lingering reference), resources never released.
5. **Concurrency** — serial work that's embarrassingly parallel, lock contention, and the inverse risk: data races or unsafe sharing introduced *by* a "fix". Don't trade correctness for speed.

Lead with measurement where you can — a profiler, a benchmark, or at least reasoning about input size and call frequency. A bottleneck on a path that runs once at startup rarely matters; one on a per-request hot path matters a lot.

## How to report

For each issue:

- **Severity** — Critical / High / Medium / Low, judged by real-world impact (how hot the path is × how bad the cost), not theoretical ugliness.
- **Location** — file and line / function.
- **Why it's slow** — the mechanism, ideally with the complexity or the cost that dominates.
- **Fix** — a concrete change with a code example in the project's language, and a note on any trade-off (readability, memory-for-speed, added concurrency risk).

If the code is already reasonable for its workload, say so plainly instead of manufacturing findings.
