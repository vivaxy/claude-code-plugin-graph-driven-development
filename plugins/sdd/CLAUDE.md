# Spec Driven Development (SDD)

This project uses Spec Driven Development. All feature development must align with the documents and diagrams maintained in `docs/`.

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
| `drafts/draft-*.md` | Pending plan proposals awaiting user approval | `drafts/draft-plan-2026-01-23.md` |

### Completeness Rules

`docs/` is considered **complete** when:
- At least one `flow-*.md` file exists
- At least one `arch-*.md` file exists
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

## SDD Development Workflow

```
sdd:plan → sdd:code
```

1. **`sdd:plan` skill**: For a new requirement, write/update design documents and diagrams, then automatically run a subagent review loop until approved
2. **`sdd:code` skill**: Implement code guided by the approved documents and diagrams, then automatically run a subagent code review loop until implementation is approved

## Agent Behavior Rules

- **Documents and diagrams first**: Before writing any code for a feature, always write/update the relevant `doc-*.md` design document AND the relevant `flow-*.md` / `arch-*.md` diagrams
- **Auto-initialize**: If `docs/` is missing or incomplete, proactively create the missing files — never block or ask the user to run a setup command
- **Never modify diagram files directly** during `sdd:code` — record deviations and update diagrams separately
- **Always read** the relevant documents and diagram files before starting any implementation task
- **Draft files are not authoritative** — only approved files in `docs/` (not `drafts/`) serve as the source of truth
