# Cadence

This project uses Cadence. All feature development must align with the documents and diagrams maintained in `docs/`.

## docs/ Directory Specification

The `docs/` directory contains the authoritative design documents and diagrams for this project. Each file is a Markdown document — either a prose design doc or a diagram file with Mermaid code blocks.

### File Naming Conventions

| Prefix | Purpose | Example |
|--------|---------|---------|
| `overview.md` | System context and big-picture boundary diagram | `overview.md` |
| `flow-*.md` | Business process, request, or data flow diagrams | `flow-request.md`, `flow-auth.md` |
| `arch-*.md` | Module dependency or component architecture diagrams | `arch-modules.md`, `arch-services.md` |
| `arch-ddd-*.md` | DDD bounded context maps | `arch-ddd-contexts.md` |

### Completeness Rules

`docs/` is considered **complete** when at least one `flow-*.md` and one `arch-*.md` exist.

If `docs/` is missing or incomplete, the agent MUST proactively create the missing files — do NOT ask the user to run any command first.

### Diagram File Format

Each diagram file follows this structure:

```markdown
# <Diagram Title>

> **Type**: [Flow | Architecture | DDD | Overview]
> **Last Updated**: YYYY-MM-DD
> **Covers**: Brief one-line description of what this diagram represents

## Diagram

\`\`\`mermaid
... mermaid code ...
\`\`\`

## Key Decisions

- Decision 1: Rationale
- Decision 2: Rationale

## Notes

Additional context, constraints, or cross-references to other diagrams.
```

## Cadence Development Workflow

```
cadence:main:clarify
  → cadence:main:plan
    → cadence:main:review
      → cadence:main:deliver
```

1. **`cadence:main:clarify`**: Clarify the problem with the user, produce a clarification summary in conversation
2. **`cadence:main:plan`**: Analyze docs, define implementation approach, update diagrams, get approval
3. **`cadence:main:review`**: End-to-end feature acceptance — test suite, success criteria
4. **`cadence:main:deliver`**: Output retrospective to conversation, deliver final summary

## Analyze Skills

Use `cadence:analyze:problem` to run a structured analysis on any complex problem.
Use `cadence:analyze:model` to build a visual conceptual model of any domain or system.

## Agent Behavior Rules

- **Clarify first**: Before any planning or coding, confirm a clarification summary has been established in the current conversation
- **Auto-initialize**: If `docs/` is missing or incomplete, proactively create the missing files — never block or ask the user to run a setup command
- **Always read** the relevant diagram files before starting any implementation task
