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

```
cadence:main:clarify
  → cadence:main:plan
    → review agent
      → cadence:main:deliver
```

1. **`cadence:main:clarify`**: Clarify the problem with the user, produce a clarification summary in conversation
2. **`cadence:main:plan`**: Analyze docs, define implementation approach, update diagrams, get approval
3. **`review` agent**: End-to-end feature acceptance — test suite, success criteria, docs/plan/code alignment
4. **`cadence:main:deliver`**: Output retrospective to conversation, deliver final summary

## Analyze Skills

Use `cadence:analyze:problem` to run a structured analysis on any complex problem.

## Agent Behavior Rules

- **Clarify first**: Before any planning or coding, confirm a clarification summary has been established in the current conversation
- **Auto-initialize**: If `docs/` is missing or incomplete, proactively create the missing files — never block or ask the user to run a setup command
- **Always read** the relevant diagram files before starting any implementation task
