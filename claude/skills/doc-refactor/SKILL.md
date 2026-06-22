---
name: doc-refactor
description: Restructure and reorganize a project's documentation for clarity and discoverability. Use this whenever the user wants to clean up, reorganize, or overhaul docs — a sprawling README, scattered or duplicated markdown files, missing per-module docs, or "our documentation is a mess". Adapts the structure to the project type and centralizes content under docs/ behind a streamlined README entry point.
---

# Documentation Refactor

Reorganize a project's documentation so a newcomer can find what they need fast and a maintainer knows where new docs belong. Documentation rots when there's no clear home for each kind of content — the job here is to give it one, shaped to what the project actually is.

## Approach

1. **Analyze the project.** Identify its type (library / API / web app / CLI / service or monorepo) and its readers (end users, integrators, contributors, operators). The right structure follows from who reads it and why — a library's docs look nothing like a deployed service's.
2. **Take stock of what exists.** Inventory the current docs, note duplication, staleness, and orphaned files, before moving anything. Don't delete content you didn't write or can't verify is obsolete — surface it instead.
3. **Centralize under `docs/`.** Move technical documentation into `docs/` with working cross-references, leaving the root uncluttered.
4. **Streamline the root `README.md`** as the entry point: a one-paragraph overview, a quickstart that actually works, a map of the main modules/components, and pointers into `docs/` for depth. Plus license and contact/support.
5. **Add component-level docs** where they help — a short README per module/package/service covering its purpose, setup, and how to test it.
6. **Organize `docs/` by category**, picking only what the project needs: Architecture, API Reference, Data Model, Design, Deployment, Troubleshooting, Contributing.
7. **Write the guides that apply:** User Guide (apps), API Reference (APIs — consider the dedicated API-docs skill for this), Development Guide (setup/testing/contribution), Deployment Guide (services).
8. **Use Mermaid for diagrams** (architecture, request flows, schemas) so they live in version control as text, not as binary images.

Keep every page concise and scannable. Before a large move or mass rename, show the user the proposed structure — reshuffling docs is disruptive and easier to agree on up front than to undo.
