---
name: unit-test-expand
description: Increase test coverage by finding untested branches, error paths, and edge cases, then writing tests for them. Use this whenever the user wants more test coverage, to cover edge cases, fill coverage gaps, harden a module with tests, or says "this isn't tested" / "add tests for the parts we're missing". Runs the coverage report, targets the weakest areas, and adds tests that follow the project's existing framework and conventions.
---

# Expand Unit Tests

Raise meaningful coverage by testing the behavior that *isn't* covered yet. The aim is catching real bugs, not chasing a coverage number — a test that pins down a tricky branch is worth more than ten that re-assert the happy path.

## Steps

1. **Measure coverage.** Run the project's coverage report to see which files, branches, and lines are uncovered (`go test -cover` / `pytest --cov` / `vitest --coverage` / `cargo tarpaulin` / etc.). Let the data point you at the gaps rather than guessing.

2. **Identify the gaps that matter.** Read the uncovered code and look for: error/exception paths, boundary values (empty, zero, min/max, off-by-one), null/missing inputs, state transitions and side effects, and conditional branches that only the unusual case reaches. These are where bugs hide; trivial getters are not.

3. **Write the tests in the project's existing style.** Match the framework and conventions already in the repo (Jest/Vitest/Mocha; pytest/unittest; Go `testing`/testify; Rust `#[test]`). If the project uses table-driven tests, subtests, fixtures, or fakes, follow that pattern so the new tests read like they belong.

4. **Prefer fast, isolated tests.** Drive logic through seams (fakes/stubs/in-memory doubles) rather than real I/O where the project's design allows it — fast deterministic tests are the ones that actually get run.

5. **Verify.** Run the new tests (they must pass), then re-run coverage to confirm a real increase. Sanity-check that a test would *fail* if the behavior it covers broke — a test that passes no matter what protects nothing.

Follow existing test file locations and naming. If a gap reveals a likely bug rather than just a missing test, flag it instead of writing a test that quietly encodes the wrong behavior.
