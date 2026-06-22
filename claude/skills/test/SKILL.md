---
name: test
description: Run and expand the Go test suite for this project. Use this whenever the user wants to run tests, check whether tests pass, run a single test, debug a failing test, add test coverage, or write new unit tests. Respects this repo's build-tag split — fast unit tests by default, integration tests (Postgres/Redis via testcontainers) behind a tag — and the service-layer-with-fakes testing strategy from the design spec.
---

# Test

Two jobs under one roof: **running** the suite and **expanding** it. Figure out which the user wants from their phrasing — "do the tests pass?" / "run the auth tests" is running; "add tests for the expiry logic" / "this isn't covered" is expanding. Often you'll run, see a gap, and expand.

## Project testing model (from the design spec)

The architecture is layered: `http → service → storage` interfaces + `domain`. Tests exploit that:

- **Unit tests** target the `service` layer against **in-memory fake repos** — no database needed. This is where most logic lives (code generation + collision retry, expiry checks, auth flows, ownership checks). Fast, deterministic, run by default.
- **HTTP tests** use `net/http/httptest` with fake services — assert status codes, auth gating, and `domain`-error → HTTP-status mapping.
- **Integration tests** exercise the real `storage/postgres` and `storage/redis` implementations against containers via `testcontainers-go`. These are **behind a build tag** so plain `go test ./...` stays fast and needs no Docker.

The cardinal rule: **plain `go test ./...` must never require Docker or a live database.** Anything that does goes behind the integration tag.

## Running

```bash
go test ./...                       # all fast unit/http tests (default, no Docker)
go test ./... -race                 # with the race detector
go test -v ./internal/service/...   # verbose, one package
go test -run TestCreateLink ./...   # a single test by name (regex)
go test -run TestCreateLink/expired ./internal/service/...  # one subtest (table-driven)
go test -tags=integration ./...     # include integration tests (needs Docker)
go test -cover ./...                # coverage summary
```

When a test fails, don't paper over it. Reproduce with `-run` narrowed to the failing case, read the actual failure, and if the cause isn't obvious, work it as a real debugging problem (form a hypothesis, confirm it) before changing code. A failing test is usually telling you something true.

## Expanding

Write tests that pin behavior, not implementation details. Defaults for this repo:

- **Table-driven** with subtests (`t.Run(tc.name, ...)`), so cases read as a list and failures name themselves.
- **Service logic → fakes, not DB.** Implement the `storage` interfaces with simple in-memory maps in the test. This keeps logic tests fast and lets you simulate conditions (collision, expiry, missing row) that are awkward to force against a real store.
- **Cover the decisions the spec calls out:** random code generation + collision retry (force a collision via the fake), expiry returning the expired path, auth/session lifecycle, and ownership checks (user A can't touch user B's link).
- **HTTP handlers** via `httptest.NewRequest`/`ResponseRecorder` with a fake service — focus on status codes and error mapping, not re-testing service logic.
- **Integration tests** (real Postgres/Redis behaviors — SQL constraints, `ON CONFLICT`, TTLs) go in files guarded by `//go:build integration`.

If the user follows TDD (this environment ships a test-driven-development skill), write the failing test first, watch it fail for the right reason, then implement. Either way, run the relevant tests after writing to confirm they pass — and that they'd fail if the behavior broke.

**Example — table-driven service test against a fake**
```go
func TestResolve_Expired(t *testing.T) {
	repo := newFakeLinkRepo()
	repo.put(Link{Code: "abc", TargetURL: "https://x", ExpiresAt: ptr(past)})
	svc := NewLinkService(repo, nil)

	_, err := svc.Resolve(context.Background(), "abc")
	if !errors.Is(err, domain.ErrExpired) {
		t.Fatalf("got %v, want ErrExpired", err)
	}
}
```
