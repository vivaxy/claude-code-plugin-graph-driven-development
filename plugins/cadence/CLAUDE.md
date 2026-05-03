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
      → cadence:deliver
```

1. **`cadence:main:clarify`**: Clarify the problem with the user, create the session folder, write `clarify.md`
2. **`cadence:main:plan`**: Read `clarify.md`, design implementation approach, update diagrams, write `plan.md`, get approval
3. **`implement` agent (one per step)**: Read `plan.md`, execute one step, write `implement-step-N.md`
4. **`review` agent**: Read prior phase files, run end-to-end acceptance, write `review.md`
5. **`cadence:deliver`**: Read all phase files, write `deliver.md`, output retrospective + final summary

## Session Folders

Every Cadence run produces a per-session folder of phase artifacts inside the user's project:

- **Path**: `<project>/.claude/sessions/YYYY-MM-DD-<slug>/` (one folder per session under `.claude/sessions/`)
- **Files**: `clarify.md`, optional `analyze.md`, `plan.md`, `implement-step-N.md` (one per step), `review.md`, `deliver.md`
- **Frontmatter**: every file carries YAML frontmatter (`agent`, `session_type`, `status`, `created_at`). `status` values: `in_progress`, `complete`, `blocked`. The routing layer reads frontmatter to decide the next phase.
- **Inter-agent contract**: each agent reads prior phase files and writes its own. Subagents return one-line `Wrote <file>.md to <absolute-path>. <one-sentence summary>` handoffs; full output lives in the file.
- **Resume**: a fresh Claude session detects an existing session folder, identifies the latest written phase by frontmatter, and continues from the next step.

### Recommended `.gitignore`

Session folders are personal scratch space by default. Add this line to your project `.gitignore`:

```
.claude/sessions/
```

To opt in to committing session folders for a team-shared durable record, omit that line and commit the folders alongside code.

## Analyze Skills

Cadence auto-invokes the `analyze-problem` agent when it detects a complex problem. The agent reads `clarify.md` and writes `analyze.md` to the session folder. You can also trigger it explicitly by describing your problem.

## Agent Behavior Rules

- **Clarify first**: Always run `clarify` before any planning or coding so the session folder and `clarify.md` exist
- **Pass the session folder path**: Always include the session folder absolute path when invoking any Cadence agent or skill
- **Read prior phase files**: Always read the prior phase md file(s) from the session folder rather than relying on conversation context
- **Auto-initialize `docs/`**: If `docs/` is missing or incomplete, proactively create the missing files
- **Always read** the relevant diagram files before starting any implementation task
- **Centralize references**: add any new reference (e.g., a link to an external source) to `plugins/cadence/README.md`; keep `plugins/cadence/agents/` and `plugins/cadence/skills/` reference-free.
