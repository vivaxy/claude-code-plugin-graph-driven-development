---
name: gdd:plan
description: Plan a new requirement — write/update design documents and flowcharts/architecture diagrams to reflect the proposed changes, with user confirmation before writing
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - EnterPlanMode
  - ExitPlanMode
  - Agent
---

<objective>
For a given requirement or feature request, analyze the existing GDD documents and diagrams and produce a proposal showing exactly how they need to change. The plan covers both prose design documents (`doc-*.md`) and diagram files (`flow-*.md`, `arch-*.md`).

Enter plan mode to do all exploration and design work, then call ExitPlanMode to present the full proposal for user approval.

The core principle: **documents and diagrams change first, code follows**. This skill proposes changes and, once approved, writes the document and diagram files. After that, run `gdd:code` to implement the feature.
</objective>

<process>

## Preamble: Enter Plan Mode

Call `EnterPlanMode` immediately when this skill starts. All exploration and analysis steps are read-only. Do not write any files during plan mode.

## Step 1: docs/ Completeness Check

Verify that the `docs/` directory is ready:

1. Check if `docs/` directory exists
2. Check if at least one `flow-*.md` file exists in `docs/`
3. Check if at least one `arch-*.md` file exists in `docs/`

**If any checks fail:**

Do NOT stop. Note the gap and proceed — the plan proposal will include creating the missing files as part of the plan.

## Step 2: Read Current Documents and Diagrams

Read all files in `docs/` (excluding `drafts/`):
- `overview.md`
- All `doc-*.md` files
- All `flow-*.md` files
- All `arch-*.md` files

Build a mental model of the current system design.

## Step 3: Understand the Requirement

The requirement is provided as `$ARGUMENTS`. If it's too brief or ambiguous:
- Ask one focused clarifying question
- Do not ask multiple questions at once
- If the requirement is clear enough, proceed

## Step 4: DDD Domain Analysis (conditional)

Skip this step if the requirement is clearly single-domain (a UI change, a config update, a bug fix, or a change confined to one existing module). Proceed to Step 5.

Run this step if the requirement:
- Mentions two or more system areas
- Introduces a new entity with its own lifecycle
- Crosses an existing architectural boundary visible in `arch-*.md` diagrams
- Adds a new integration with an external system

**If running this step, identify:**

1. **Bounded Contexts** — What are the distinct domains involved?
2. **Aggregates** — Within each context, what is the root entity?
3. **Entities and Value Objects** — Classify each data object
4. **Context Relationships** — Shared Kernel / Customer-Supplier / Anti-Corruption Layer / Conformist
5. **New DDD diagram needed?** — Yes if two or more bounded contexts involved AND no `arch-ddd-contexts.md` exists

## Step 5: Impact Analysis

Analyze which documents and diagrams are affected:

For each existing file, determine:
- **No change needed**: requirement has no impact
- **Minor update**: small addition or correction
- **Major update**: new section, new flow path, new module
- **New file needed**: entirely new design area

Also determine:
- New `doc-*.md` design documents that need to be created (one per significant feature or design decision)
- New `flow-*.md` files that need to be created
- New `arch-*.md` files that need to be created
- Whether `arch-ddd-contexts.md` needs to be created

## Step 6: Call ExitPlanMode with Full Proposal

Compose the full proposal and call ExitPlanMode with the complete content. The plan must include:

```
## Proposed Changes

**Requirement**: <one-line summary>

**Affects**:
- doc-<feature>.md (NEW) — <one-line reason>
- flow-request.md (major update) — <one-line reason>
- arch-modules.md (minor update) — <one-line reason>

**Summary**: <2–3 sentences describing what changes and why>

---

### New Design Document: doc-<feature>.md

**Reason**: <Why a design document is needed>

#### Proposed Content

# <Title>

> **Type**: Design Document
> **Last Updated**: <today>
> **Covers**: <description>

## Overview

<content>

## Requirements

- <requirement>

## Design

<design content>

---

### Modifying: <filename.md>

**Change type**: Major update / Minor update
**Reason**: <Why this change is needed>

#### Changes

- Added node `X` — <purpose>
- Removed node `Y` — <reason>
- New edge `A → B` — <reason>

---

### New Diagram: <filename.md>

**Reason**: <Why a new diagram is needed>

#### Proposed Diagram

\`\`\`mermaid
<full new diagram content>
\`\`\`

#### Key Decisions

- Decision 1: rationale

---

## Design Considerations

<Any trade-offs, alternatives considered, or open questions>
```

## Step 7: Apply Approved Changes

After the user approves this plan (ExitPlanMode returns with approval), apply all the changes:

1. For each "New Design Document" entry: create the file in `docs/` with the proposed content
2. For each "Modifying" entry: read the current file, apply the changes, update `**Last Updated**` date, write the file back
3. For each "New Diagram" entry: create the file in `docs/` with the standard diagram file format

Output confirmation:
```
Applied changes from approved plan:
- Created: docs/doc-<feature>.md
- Updated: docs/flow-request.md
- Created: docs/flow-auth.md

Documents and diagrams are ready. Proceeding with implementation...
```

Then invoke the `gdd:code` skill with the original requirement as the argument.

</process>

<guidelines>
- Design documents come first: every significant feature should have a `doc-*.md` before diagrams are updated
- Diagrams come second: update flow and architecture diagrams to reflect the design
- Code comes last: implementation follows the approved documents and diagrams
- Proposed diagrams must be syntactically valid Mermaid
- If a requirement is too large (affects > 5 files), consider splitting into sub-requirements
- Base all content on the actual codebase — never invent fictional modules or flows
</guidelines>
