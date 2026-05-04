# Cadence

This project uses Cadence. All feature development must align with the documents and diagrams maintained in `docs/`.

## docs/ Directory Specification

The `docs/` directory contains the authoritative design documents and diagrams for this project. Each file is a Markdown document with Mermaid code blocks following the C4 model.

### File Naming Conventions

| File | C4 Level | Purpose |
|------|----------|---------|
| `c4-context.md` | Level 1 — Context | System boundary: users, the system, external dependencies |
| `c4-containers.md` | Level 2 — Container | Deployable/runnable units inside the system boundary |
| `c4-component-{name}.md` | Level 3 — Component | Internal modules inside a container (one file per complex container) |
| `c4-seq-{flow-name}.md` | Behavioral | Sequence diagrams for key use cases and flows |

### C4 Level Guide

- **Level 1 Context** (`c4-context.md`): Always required. Shows the system as one box with users and external systems around it. Audience: everyone.
- **Level 2 Container** (`c4-containers.md`): Required when the system has 2+ deployable/runnable units. Shows what the system is made of. Audience: developers, architects, DevOps.
- **Level 3 Component** (`c4-component-{name}.md`): Required for containers complex enough that developers get lost. One file per container. Audience: developers on that container.
- **Level 4 Code**: Never maintain manually — auto-generate from code if needed.
- **Sequence diagrams** (`c4-seq-{flow-name}.md`): Required for every key user-facing flow. Shows what happens when X occurs. Complements C4 structural diagrams with behavioral context.

### Completeness Rules

`docs/` is considered **complete** when `c4-context.md`, `c4-containers.md`, and at least one `c4-seq-*.md` exist.

If `docs/` is missing or incomplete, the agent MUST proactively create the missing files — do NOT ask the user to run any command first.

### Diagram File Format

Each diagram file follows this structure:

```markdown
# <Diagram Title>

> **Type**: [C4 Context | C4 Container | C4 Component | Sequence]
> **Last Updated**: YYYY-MM-DD
> **Covers**: Brief one-line description of what this diagram represents

## Diagram

\`\`\`mermaid
... mermaid code ...
\`\`\`

## Key Decisions

- Decision 1: Rationale
- Decision 2: Rationale (from plan: <plan-slug>, if this decision originated in a plan file)

## Notes

Additional context, constraints, or cross-references to other diagrams.
```

Mermaid diagram types by file:
- `c4-context.md` → `C4Context`
- `c4-containers.md` → `C4Container`
- `c4-component-{name}.md` → `C4Component`
- `c4-seq-{flow-name}.md` → `sequenceDiagram`

### Diagram Lifecycle

**When to create a new diagram file** (rather than updating an existing one):
- The change introduces a new container or component not covered by any existing diagram's `Covers` line
- An existing diagram would exceed ~15 nodes to accommodate the change — split it
- The new content will be independently referenced by other diagrams

**When to update an existing diagram file:**
- The change modifies a container or component already shown in the diagram
- The new content fits within the existing diagram's `Covers` scope

**When to delete a diagram file:**
- The system area it describes no longer exists
- Its content has been fully absorbed into another diagram (note the absorption in the absorbing file before deleting)
- It has not been updated in 6+ months AND no current code corresponds to it — add `> **Status**: Stale` to its header first, then delete in the next planning cycle if still unneeded

## Cadence Development Workflow

The workflow is driven by a single `session.md` per session. Its `## <Section>` headings hold checklists of `- [ ]` items, and the routing skill spawns the agent that owns the first section with any unchecked item.

| Section heading | Owner |
|---|---|
| `## Clarification` | `clarify` agent |
| `## Analysis` | `analyze-problem` agent (bugfix, analysis sessions) |
| `## Plan` | `plan` agent (feature-dev, bugfix, doc-writing) |
| `## Implementation` | `implement` agent (feature-dev, bugfix, doc-writing) |
| `## Review` | `review` agent (feature-dev, bugfix, doc-writing) |
| `## Delivery` | `deliver` agent (feature-dev, bugfix, doc-writing, analysis) |
| `## Answer` | main thread (trivial only) |

Routing reads `session.md` top-to-bottom, finds the first section with any `- [ ]` item, and invokes that section's owner. Each agent ticks its items as `- [x]` after completing the work.

## Session Types

There are five session types. Each has a template under `plugins/cadence/templates/` that defines its sections:

- **`trivial`** — small/localized change or factual question. Sections: `## Clarification`, `## Answer`.
- **`feature-dev`** — new behavior. Sections: `## Clarification`, `## Plan`, `## Implementation`, `## Review`, `## Delivery`.
- **`bugfix`** — broken behavior. Sections: `## Clarification`, `## Analysis`, `## Plan`, `## Implementation`, `## Review`, `## Delivery`.
- **`doc-writing`** — documentation work. Sections: `## Clarification`, `## Plan`, `## Implementation`, `## Review`, `## Delivery`.
- **`analysis`** — diagnostic/exploratory. Sections: `## Clarification`, `## Analysis`, `## Delivery`.

After `clarify` runs, the routing skill calls `AskUserQuestion` to confirm the session type, then copies the matching template into `session.md`.

## Session Folder

Every Cadence run produces a per-session folder inside the user's project:

- **Path**: `<project>/.claude/sessions/YYYY-MM-DD-<slug>/`
- **Contents**: a single `session.md` per session, plus any incidental side artifacts (e.g. analysis figures, plan diagrams)
- **`session.md` is the only state**: routing reads it top-to-bottom and spawns the owner of the first section with any `- [ ]` item
- **Plan body lives in `## Plan` of `session.md`** — the plan is part of the session file itself

### Recommended `.gitignore`

Session folders are personal scratch space by default. Add this line to your project `.gitignore`:

```
.claude/sessions/
```

To opt in to committing session folders for a team-shared durable record, omit that line and commit the folders alongside code.

## Analyze Skills

When session type is `bugfix` or `analysis`, the routing skill spawns the `analyze-problem` agent to fill `## Analysis` of `session.md`. The agent reads `## Clarification` for context.

## Agent Behavior Rules

- **Always run `clarify` first**: every session starts with the clarify agent writing a minimal `session.md`
- **Always pass the session folder absolute path**: every Cadence agent invocation includes the absolute path to `<session-folder>`
- **Always read the relevant section of `session.md`** for context instead of relying on conversation context
- **Always tick checklist items as `- [x]`** in the agent's owned section after completing the work for that item
- **Always proactively create missing `docs/` files** if the project's `docs/` directory is incomplete
- **Always read** the relevant diagram files before starting any implementation task
- **Always centralize references** in `plugins/cadence/README.md` — keep `plugins/cadence/agents/` and `plugins/cadence/skills/` reference-free
