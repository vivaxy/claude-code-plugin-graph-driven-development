---
name: cadence:main:plan
description: Plan the clarified feature — analyze existing docs, produce design documents and diagrams, define implementation approach, get user approval
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
Read the clarified problem from the current conversation context (established by `main:clarify`), analyze the codebase and existing docs, define the implementation approach, produce or update design documents and diagrams, get user approval via ExitPlanMode.
</objective>

<process>

## Preamble: Enter Plan Mode

Call `EnterPlanMode` immediately. All exploration and analysis is read-only until ExitPlanMode returns with approval.

## Step 1: Read Clarification

Use the clarification summary from the current conversation context. If no clarification has been established yet, invoke `cadence:main:clarify` first and stop.

Extract:
- Problem statement
- Scope (in/out)
- Constraints
- Success criteria

## Step 2: Read Existing Docs and Codebase

Read all files in `docs/` (excluding `drafts/`):
- `overview.md`
- All `flow-*.md` files
- All `arch-*.md` files

Also scan the project root to understand the current codebase structure (Glob for key files).

Build a mental model of what already exists and what needs to change.

## Step 3: Define Implementation Approach

Describe the implementation:
- What needs to be built or changed
- Which files/modules are expected to change
- Key design decisions and trade-offs
- Success criteria mapping: how each criterion will be satisfied

## Step 4: Design Document and Diagram Impact Analysis

Determine which `docs/` files need to change:
- **No change**: no architectural impact
- **Minor update**: small addition to an existing file
- **Major update**: new section, new flow path, new module
- **New file needed**: new design area

Produce the full proposed content for each new or modified file.

## Step 5: Call ExitPlanMode with Full Proposal

Compose the proposal and call ExitPlanMode. The plan must include:

```
## Proposed Plan

**Feature**: <one-line summary from clarification>

### Implementation Approach

<description of what to build and how>

**Expected scope**: <files/modules>

### Success Criteria Mapping

| Criterion | How it will be satisfied |
|-----------|--------------------------|
| <criterion 1> | <approach> |
| <criterion 2> | <approach> |

### Document and Diagram Changes

**<filename.md>** (NEW / major update / minor update)
<proposed content or diff description>
```

If the user rejects the plan, incorporate their feedback and call ExitPlanMode again.

## Step 6: Apply Approved Changes

After the user approves (ExitPlanMode returns with approval):

1. Create or update each diagram file in `docs/`

Output:
```
Plan applied:
- Created/updated: docs/<file>.md

Ready to implement. Run `cadence:main:review` when done.
```

</process>

<guidelines>
- Success criteria mapping must be specific and verifiable
- If the feature touches architecture or introduces a new module, always produce or update the relevant `arch-*.md` or `flow-*.md` diagram
- Diagrams must use valid Mermaid syntax; use `<br>` for line breaks in node labels
</guidelines>
