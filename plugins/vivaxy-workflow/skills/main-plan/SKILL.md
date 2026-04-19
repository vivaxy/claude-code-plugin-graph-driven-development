---
name: vivaxy-workflow:main:plan
description: Decompose the clarified problem into subtasks — analyze existing docs, produce design documents and diagrams, define subtasks with acceptance criteria, get user approval, then write docs/doc-subtasks.md
argument-hint: "<optional: specific aspect to focus on>"
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
Read the clarified problem from the current conversation context (established by `main:clarify`), analyze the codebase and existing docs, decompose the work into ordered subtasks with acceptance criteria, produce or update design documents and diagrams, get user approval via ExitPlanMode, then write `docs/doc-subtasks.md`.
</objective>

<process>

## Preamble: Enter Plan Mode

Call `EnterPlanMode` immediately. All exploration and analysis is read-only until ExitPlanMode returns with approval.

## Step 1: Read Clarification

Use the clarification summary from the current conversation context. If no clarification has been established yet, invoke `vivaxy-workflow:main:clarify` first and stop.

Extract:
- Problem statement
- Scope (in/out)
- Constraints
- Success criteria

## Step 2: Read Existing Docs and Codebase

Read all files in `docs/` (excluding `drafts/`):
- `overview.md`
- All `doc-*.md` files
- All `flow-*.md` files
- All `arch-*.md` files

Also scan the project root to understand the current codebase structure (Glob for key files).

Build a mental model of what already exists and what needs to change.

## Step 3: Decompose into Subtasks

Break the feature into ordered, independent-as-possible subtasks. For each subtask define:
- **ID**: `ST-01`, `ST-02`, etc.
- **Title**: imperative phrase (e.g., "Add user authentication endpoint")
- **Description**: what needs to be built
- **Acceptance Criteria**: 2–4 measurable criteria (what must be true for this subtask to be ACCEPTED)
- **Dependencies**: list of subtask IDs that must be ACCEPTED first (empty if none)
- **Scope**: which files/modules are expected to change

Guidelines:
- Each subtask should be completable in one focused session
- Acceptance criteria must be specific and verifiable (e.g., "POST /login returns 200 with JWT token", not "login works")
- Order subtasks so dependencies flow naturally (infrastructure before features, shared utilities before consumers)

## Step 4: Design Document and Diagram Impact Analysis

For each subtask, determine which `docs/` files need to change:
- **No change**: subtask has no architectural impact
- **Minor update**: small addition to an existing file
- **Major update**: new section, new flow path, new module
- **New file needed**: new design area

Produce the full proposed content for each new or modified file.

## Step 5: Call ExitPlanMode with Full Proposal

Compose the proposal and call ExitPlanMode. The plan must include:

```
## Proposed Plan

**Feature**: <one-line summary from clarification>

### Subtasks

| ID | Title | Dependencies |
|----|-------|--------------|
| ST-01 | <title> | — |
| ST-02 | <title> | ST-01 |

---

#### ST-01: <Title>

**Description**: <what to build>

**Acceptance Criteria**:
- <criterion 1>
- <criterion 2>

**Expected scope**: <files/modules>

---

### Document and Diagram Changes

**<filename.md>** (NEW / major update / minor update)
<proposed content or diff description>
```

If the user rejects the plan, incorporate their feedback and call ExitPlanMode again.

## Step 6: Apply Approved Changes

After the user approves (ExitPlanMode returns with approval):

1. Create or update each design document and diagram file in `docs/`
2. Write `docs/doc-subtasks.md` with the approved subtask list:

```markdown
# Subtask Plan

> **Type**: Subtask Plan
> **Last Updated**: YYYY-MM-DD
> **Feature**: <feature name from clarification>

## Subtasks

### ST-01: <Title>

> **Status**: PENDING
> **Dependencies**: —

**Description**: <description>

**Acceptance Criteria**:
- [ ] <criterion 1>
- [ ] <criterion 2>

**Expected scope**: <files/modules>

---

### ST-02: <Title>

> **Status**: PENDING
> **Dependencies**: ST-01

...
```

Output:
```
Plan applied:
- Created/updated: docs/<file>.md
- Created: docs/doc-subtasks.md (<N> subtasks: ST-01 through ST-0N)

Run `vivaxy-workflow:subtask-execute ST-01` to begin.
```

</process>

<guidelines>
- Acceptance criteria must be verifiable, not subjective
- If a subtask touches architecture or introduces a new module, always produce or update the relevant `arch-*.md` or `flow-*.md` diagram
- Diagrams must use valid Mermaid syntax; use `<br>` for line breaks in node labels
- Keep subtasks focused — if a subtask would change more than 5 files, consider splitting it
- `doc-subtasks.md` is the single source of truth for subtask status; do not track status anywhere else
</guidelines>
