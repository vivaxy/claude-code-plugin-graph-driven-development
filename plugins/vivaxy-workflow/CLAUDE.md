# vivaxy Workflow

This project uses vivaxy Workflow. All feature development must align with the documents and diagrams maintained in `docs/`.

## docs/ Directory Specification

The `docs/` directory contains the authoritative design documents and diagrams for this project. Each file is a Markdown document — either a prose design doc or a diagram file with Mermaid code blocks.

### File Naming Conventions

| Prefix | Purpose | Example |
|--------|---------|---------|
| `overview.md` | System context and big-picture boundary diagram | `overview.md` |
| `flow-*.md` | Business process, request, or data flow diagrams | `flow-request.md`, `flow-auth.md` |
| `arch-*.md` | Module dependency or component architecture diagrams | `arch-modules.md`, `arch-services.md` |
| `arch-ddd-*.md` | DDD bounded context maps | `arch-ddd-contexts.md` |
| `doc-*.md` | Prose design documents (requirements, decisions, specs) | `doc-auth-design.md`, `doc-api-spec.md` |
| `doc-subtasks.md` | Ordered subtask list with status tracking | `doc-subtasks.md` |
| `doc-retrospective-*.md` | Post-delivery retrospective and learnings | `doc-retrospective-2026-04-18.md` |
| `drafts/draft-*.md` | Pending plan proposals awaiting user approval | `drafts/draft-plan-2026-01-23.md` |

### Completeness Rules

`docs/` is considered **complete** when:
- `doc-subtasks.md` exists
- No unapproved draft files exist in `docs/drafts/`

If `docs/` is missing or incomplete, the agent MUST proactively create the missing documents — do NOT ask the user to run any command first.

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

### Design Document Format

Prose design documents (`doc-*.md`) follow this structure:

```markdown
# <Document Title>

> **Type**: Design Document
> **Last Updated**: YYYY-MM-DD
> **Covers**: Brief one-line description

## Overview

High-level description of the feature/component/decision.

## Requirements

- Requirement 1
- Requirement 2

## Design

Detailed design description, decisions, and rationale.

## Open Questions

- Question 1 (if any)
```

### Draft File Format

Draft files in `docs/drafts/` follow this structure:

```markdown
# Draft Plan: <Requirement Title>

> **Status**: PENDING_REVIEW
> **Created**: YYYY-MM-DD HH:MM
> **Affects**: List of files that will be modified

## Requirement Summary

...

## Document Changes

### Modifying: <filename.md>

**Reason**: Why this change is needed

#### Before

... original content (or mermaid block) ...

#### After

... proposed content (or mermaid block) ...
```

## vivaxy Workflow Development Workflow

```
vivaxy-workflow:main:clarify
  → vivaxy-workflow:main:plan
    → Loop: vivaxy-workflow:subtask-execute → vivaxy-workflow:subtask-review
      → vivaxy-workflow:main:review
        → vivaxy-workflow:main:deliver
```

1. **`vivaxy-workflow:main:clarify`**: Clarify the problem with the user, produce a clarification summary in conversation
2. **`vivaxy-workflow:main:plan`**: Decompose into subtasks, write design docs and diagrams, write `docs/doc-subtasks.md`
3. **`vivaxy-workflow:subtask-execute <ST-XX>`**: Execute one subtask (TDD), invoke `subtask-review` subagent, mark ACCEPTED
4. **`vivaxy-workflow:subtask-review`**: Subagent — verifies acceptance criteria and doc alignment
5. **`vivaxy-workflow:main:review`**: End-to-end feature acceptance — all subtasks, test suite, success criteria
6. **`vivaxy-workflow:main:deliver`**: Retrospective, clean up drafts, deliver final summary

## Analyze Skills

Use `vivaxy-workflow:analyze:problem` to run a structured analysis on any complex problem.
Use `vivaxy-workflow:analyze:model` to build a visual conceptual model of any domain or system.

## Agent Behavior Rules

- **Clarify first**: Before any planning or coding, confirm a clarification summary has been established in the current conversation
- **Auto-initialize**: If `docs/` is missing or incomplete, proactively create the missing files — never block or ask the user to run a setup command
- **Never modify diagram files directly** during `vivaxy-workflow:subtask-execute` — record deviations in `docs/drafts/`
- **Always read** the relevant documents and diagram files before starting any implementation task
- **Draft files are not authoritative** — only approved files in `docs/` (not `drafts/`) serve as the source of truth
- **Subtask status** is tracked in `doc-subtasks.md` — update it as work progresses
