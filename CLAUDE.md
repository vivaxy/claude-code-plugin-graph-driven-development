# Graph Driven Development (GDD)

This project uses Graph Driven Development. All feature development must align with the diagrams maintained in `docs/gdd/`.

## docs/gdd Directory Specification

The `docs/gdd/` directory contains the authoritative design diagrams for this project. Each file is a Markdown document with one or more Mermaid diagram code blocks plus explanatory text.

### File Naming Conventions

| Prefix | Purpose | Example |
|--------|---------|---------|
| `overview.md` | System context and big-picture boundary diagram | `overview.md` |
| `flow-*.md` | Business process, request, or data flow diagrams | `flow-request.md`, `flow-auth.md` |
| `arch-*.md` | Module dependency or component architecture diagrams | `arch-modules.md`, `arch-services.md` |
| `drafts/draft-*.md` | Pending plan proposals awaiting user approval | `drafts/draft-plan-2026-01-23.md` |

### Completeness Rules

`docs/gdd/` is considered **complete** when:
- At least one `flow-*.md` file exists
- At least one `arch-*.md` file exists
- No unapproved draft files exist in `docs/gdd/drafts/`

If `docs/gdd/` is missing or incomplete, the agent MUST stop and instruct the user to run `/gdd:init` before proceeding.

### Diagram File Format

Each diagram file follows this structure:

```markdown
# <Diagram Title>

> **Type**: [Flow | Architecture | Overview]
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

### Draft File Format

Draft files in `docs/gdd/drafts/` follow this structure:

```markdown
# Draft Plan: <Requirement Title>

> **Status**: PENDING_REVIEW
> **Created**: YYYY-MM-DD HH:MM
> **Affects**: List of diagram files that will be modified

## Requirement Summary

...

## Diagram Changes

### Modifying: <filename.md>

**Reason**: Why this change is needed

#### Before

\`\`\`mermaid
... original diagram ...
\`\`\`

#### After

\`\`\`mermaid
... proposed diagram ...
\`\`\`
```

## GDD Development Workflow

```
gdd:init → gdd:plan → gdd:code
```

1. **`/gdd:init`**: Scan project, auto-detect type, generate initial diagrams in `docs/gdd/`
2. **`/gdd:plan`**: For a new requirement, update diagrams and automatically run a subagent review loop until diagrams are approved
3. **`/gdd:code`**: Implement code guided by the approved diagrams, then automatically run a subagent code review loop until implementation is approved

## Agent Behavior Rules

- **Never start coding** if `docs/gdd/` is missing or incomplete — always direct users to `/gdd:init` first
- **Never modify diagram files directly** during `gdd:code` — record deviations and update diagrams separately
- **Always read** the relevant diagram files before starting any implementation task
- **Draft files are not authoritative** — only approved files in `docs/gdd/` (not `drafts/`) serve as the source of truth
