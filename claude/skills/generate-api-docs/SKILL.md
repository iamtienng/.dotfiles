---
name: generate-api-docs
description: Generate reference documentation for a project's API from its source code. Use this whenever the user wants API docs, endpoint documentation, to document their REST/RPC/GraphQL/HTTP API, asks "document these endpoints", or needs a reference others can call the service from. Locates the API surface in whatever language the project uses, extracts signatures and doc comments, and writes Markdown with request/response schemas and runnable examples.
---

# Generate API Documentation

Produce accurate, example-rich reference docs for a project's API. The goal is a document a developer can use to call the API correctly without reading the source — so accuracy beats completeness, and every endpoint needs a concrete example.

## 1. Find the API surface

Don't assume a directory layout or language. Locate where routes/endpoints are actually defined:

- **Route registration** — search for the framework's routing calls: `ServeMux`/`http.HandleFunc` (Go), `app.get`/`router.*` (Express), `@app.route`/`APIRouter` (Flask/FastAPI), `@RestController`/`@GetMapping` (Spring), `routes.rb` (Rails), etc.
- **Existing contracts** — an OpenAPI/Swagger spec, `.proto` files, or a GraphQL schema are the source of truth when present; prefer generating from them.
- **Handlers** — follow each route to its handler to read what it consumes and returns.

If the project already has a doc generator wired up (swag, sphinx, typedoc, `go doc`), prefer driving that over hand-writing.

## 2. Extract the real contract

For each endpoint capture: method + path, auth requirement, path/query/body params, request and response shapes, and status codes (including the error cases). Pull descriptions from the project's own doc comments rather than inventing prose. Note required vs optional fields and defaults.

## 3. Write the docs

Default output: a Markdown file under `docs/` (e.g. `docs/api.md`) — but match the project's existing docs location and conventions if it has them. Organize by resource or module, not by file.

For each endpoint include:

- A one-line purpose and the auth requirement.
- Request: params and a body schema with field types.
- Response: success schema + the documented error responses and their status codes.
- A **runnable example** — a `curl` invocation (and a sample response). Use a request style that matches the API (JSON body, form, etc.).

Use the project's actual type definitions for schemas rather than a fixed language's syntax.

## 4. Verify

Cross-check a couple of endpoints against the source so the docs don't drift from reality. Flag anything you couldn't determine (e.g. an undocumented error path) rather than guessing.
