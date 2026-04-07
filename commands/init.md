---
name: gdd:init
description: Initialize GDD for this project — scan codebase and generate flowcharts and architecture diagrams in docs/gdd/
argument-hint: "[--force]"
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
---

<objective>
Initialize Graph Driven Development for this project by scanning the codebase, detecting the project type, and generating an appropriate set of Mermaid diagrams in `docs/gdd/`.

This command is the entry point for all GDD workflows. Run it once when first adopting GDD, or with `--force` to regenerate diagrams from scratch.
</objective>

<process>

## Step 1: Pre-flight Check

Check whether `docs/gdd/` already contains diagram files:

- If `docs/gdd/` exists and contains at least one `flow-*.md` and one `arch-*.md`:
  - If `--force` flag was NOT provided: inform the user that GDD is already initialized and suggest using `/gdd:plan` to update diagrams for new requirements. STOP.
  - If `--force` flag was provided: proceed, existing files will be overwritten.
- If `docs/gdd/` is missing or empty: proceed.

## Step 2: Project Discovery

Scan the project to understand its structure and technology stack. Read the following without executing code:

1. Root-level files: `package.json`, `tsconfig.json`, `pom.xml`, `build.gradle`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `requirements.txt`, `Makefile`, `docker-compose.yml`, `.env.example`
2. Top-level directory listing (one level deep)
3. `README.md` or `docs/README.md` if present
4. Any existing `docs/` files that describe architecture
5. Up to 5 key source files to understand patterns (e.g., entry point, main router, core service)

## Step 3: Project Classification

Based on what you found, classify the project along these dimensions:

**Application Type** (pick the most relevant):
- `web-frontend` — React/Vue/Angular/Svelte SPA or SSR app
- `web-backend` — REST/GraphQL API server
- `web-fullstack` — Combined frontend + backend
- `cli-tool` — Command-line application
- `library` — Reusable library or SDK
- `daemon` — Long-running background service
- `mobile` — iOS/Android/React Native app
- `data-pipeline` — ETL, data processing, ML pipeline
- `monorepo` — Multiple packages/services in one repo

**Complexity Level**:
- `simple` — Single module, < ~5 key flows
- `medium` — Multiple modules, 5–15 key flows
- `complex` — Many modules, > 15 flows, microservices, or distributed

## Step 4: Determine Which Diagrams to Generate

Based on application type and complexity, select the diagram set:

| Application Type | Diagrams to Generate |
|-----------------|----------------------|
| web-frontend | `overview.md`, `flow-user-interaction.md`, `arch-components.md` |
| web-backend | `overview.md`, `flow-request.md`, `flow-data.md`, `arch-modules.md` |
| web-fullstack | `overview.md`, `flow-user-interaction.md`, `flow-request.md`, `arch-modules.md` |
| cli-tool | `overview.md`, `flow-execution.md`, `arch-modules.md` |
| library | `overview.md`, `flow-api-usage.md`, `arch-modules.md` |
| daemon | `overview.md`, `flow-lifecycle.md`, `flow-processing.md`, `arch-modules.md` |
| mobile | `overview.md`, `flow-navigation.md`, `flow-data-sync.md`, `arch-components.md` |
| data-pipeline | `overview.md`, `flow-pipeline.md`, `arch-stages.md` |
| monorepo | `overview.md`, `arch-packages.md` + per-package diagrams as needed |

For `complex` projects, add additional flow diagrams for each major bounded context discovered.

## Step 5: Generate Diagrams

Create the `docs/gdd/` directory and generate each diagram file. Each file must:

1. Accurately reflect the **actual codebase** you scanned — do not invent fictional modules or flows
2. Use Mermaid syntax appropriate for the diagram type:
   - `flowchart TD` or `flowchart LR` for flow diagrams
   - `graph TD` for architecture/module dependency diagrams
   - `C4Context` for system context overviews (if complexity warrants it)
3. Follow the file format defined in `CLAUDE.md` (Title, Type metadata, Diagram, Key Decisions, Notes)
4. Include realistic node labels based on actual file/module names found in the codebase

**Template for a flow diagram file:**

```markdown
# <Flow Name>

> **Type**: Flow
> **Last Updated**: <today's date>
> **Covers**: <one-line description>

## Diagram

\`\`\`mermaid
flowchart TD
    ...
\`\`\`

## Key Decisions

- ...

## Notes

- Cross-references: see also `arch-modules.md` for module ownership
```

**Template for an architecture diagram file:**

```markdown
# <Architecture Name>

> **Type**: Architecture
> **Last Updated**: <today's date>
> **Covers**: <one-line description>

## Diagram

\`\`\`mermaid
graph TD
    ...
\`\`\`

## Key Decisions

- ...

## Notes

- Dependency direction: arrows point from dependent to dependency
```

## Step 6: Summary Report

After generating all files, output a summary:

```
GDD Initialized

Generated diagrams:
- docs/gdd/overview.md       — System context
- docs/gdd/flow-request.md   — HTTP request processing flow
- docs/gdd/arch-modules.md   — Module dependency graph

Next steps:
1. Review each diagram in docs/gdd/ and correct any inaccuracies
2. When starting a new feature, run /gdd:plan to update diagrams first
3. Run /gdd:plan-review to validate diagram completeness before coding
```

</process>

<guidelines>
- Base all diagrams on actual code found in the project — never invent structure
- If the project structure is unclear, err on the side of generating fewer, more accurate diagrams rather than many inaccurate ones
- Keep diagrams at the right level of abstraction: enough detail to guide implementation, not so much that they become maintenance burden
- If a README or existing architecture doc exists, use it to cross-check your diagram content
- Mermaid node IDs must be valid identifiers (no spaces, use underscores or camelCase)
</guidelines>
