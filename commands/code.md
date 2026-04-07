---
name: gdd:code
description: Implement a feature guided by GDD diagrams — extract design constraints from flowcharts and architecture diagrams before writing code
argument-hint: "<feature or task description>"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - TodoWrite
  - Agent
---

<objective>
Implement a feature or task by first extracting implementation constraints from the GDD diagrams, then writing code that strictly adheres to those constraints.

The diagrams are the source of truth. If the code needs to deviate from the diagrams, that deviation must be recorded — NOT silently done. Diagram updates happen through `/gdd:plan`, not during coding.
</objective>

<process>

## Step 1: GDD Completeness Check

1. Verify `docs/gdd/` exists with at least one `flow-*.md` and one `arch-*.md`
2. Check `docs/gdd/drafts/` for unreviewed drafts

**If GDD is not initialized:**
```
GDD diagrams are missing or incomplete.

Run /gdd:init to generate the initial diagram set, then:
- If this is a new requirement: run /gdd:plan to update diagrams
- Run /gdd:plan-review to validate
- Then return to /gdd:code
```
STOP.

**If deviation records exist:**
```
Note: Unresolved deviation records exist in docs/gdd/drafts/:
- draft-deviation-<timestamp>.md — recorded during a prior coding session

These deviations mean the diagrams may not match the current code.
Consider running /gdd:plan to update the diagrams before proceeding.

Continuing with the current diagrams...
```
Continue with a note, do not block.

## Step 1.5: Apply Pending Diagram Changes (conditional)

If `/gdd:plan` was just approved in this conversation (the plan content contains Before/After Mermaid diffs), apply those diagram changes to `docs/gdd/` before coding:

1. For each "Modifying: \<filename.md\>" entry in the approved plan:
   - Read the current file content
   - Replace the Mermaid diagram block with the "After" content from the plan
   - Update the `**Last Updated**` date to today
   - Write the full file back using `Write`

2. For each "New File: \<filename.md\>" entry in the approved plan:
   - Create the new file in `docs/gdd/` using the standard diagram file format
   - Write it using `Write`

Output confirmation before proceeding:
```
Applied diagram changes from approved plan:
- Updated: flow-request.md
- Created: flow-auth.md

Proceeding with implementation...
```

If no plan was recently approved (this is a standalone coding task), skip this step.

## Step 2: Understand the Task

Parse `$ARGUMENTS` — the feature or task to implement. If unclear, ask one focused clarifying question before proceeding.

## Step 3: Extract Design Constraints from Diagrams

Read all relevant diagram files. For each relevant diagram, extract specific implementation constraints:

### From Architecture Diagrams (arch-*.md)

Extract:
- **Module boundaries**: Which module/file/package is responsible for this feature?
- **Dependency direction**: Which modules does this feature depend on? Which modules must NOT be depended on?
- **Interface contracts**: How does this module communicate with others? (function calls, events, HTTP, etc.)
- **Ownership rules**: Does any existing module's boundary need to expand, or does this require a new one?

### From Flow Diagrams (flow-*.md)

Extract:
- **Execution order**: What must happen before what?
- **Decision points**: What conditions branch the flow?
- **Data inputs and outputs**: What data enters and exits each step?
- **Error paths**: How should failures be handled?
- **External systems**: Which external services are involved and at which steps?

### Constraint Summary

Produce an internal constraint checklist before writing any code:

```
GDD Implementation Constraints for: <task name>

MODULE BOUNDARIES:
- This feature belongs in: <module/file>
- Must NOT import from: <list of modules outside the boundary>
- May depend on: <list of allowed dependencies>

EXECUTION ORDER (from flow diagrams):
1. Step A must happen before Step B
2. If condition X, branch to path Y
3. On error at Step C, do D (not E)

DATA CONTRACTS:
- Input: <data shape coming in>
- Output: <data shape going out>
- State mutations: <what state changes are expected>

EXTERNAL SYSTEM INTERACTIONS:
- Call System X at step N with payload Y
- Do NOT call System Z (not in the diagram for this flow)
```

## Step 4: Implementation

Implement the feature following the constraints. During implementation:

### Do

- Follow module boundaries exactly as defined in arch diagrams
- Implement error handling for every error path shown in flow diagrams
- Use the same naming as nodes/labels in the diagrams (consistency)
- Implement steps in the order shown in flow diagrams
- Add tests that verify each decision point in the relevant flow diagrams

### Do NOT

- Import from modules outside the allowed dependency set
- Skip error paths that are shown in the diagrams
- Silently deviate from the diagram (see Step 5 if deviation is needed)
- "Improve" the architecture while coding — record it as a deviation instead

### Track Progress with TodoWrite

Create a todo list from the flow diagram steps:

```
Implementation todos:
[ ] Step 1: Validate input (from flow-request.md → Validate node)
[ ] Step 2: Check authorization (from flow-request.md → AuthCheck node)
[ ] Step 3: Execute business logic (from flow-data.md → Process node)
[ ] Step 4: Persist result (from flow-data.md → Write node)
[ ] Step 5: Return response (from flow-request.md → Response node)
[ ] Step 6: Handle auth error path (from flow-request.md → Error → 401)
[ ] Step 7: Handle DB error path (from flow-data.md → Error → Rollback)
```

## Step 5: Record Deviations

If during implementation you discover that the diagram is inaccurate, incomplete, or impractical:

**Do NOT silently fix the diagram or deviate without recording.**

Instead, record the deviation in a `docs/gdd/drafts/draft-deviation-<timestamp>.md` file:

```markdown
# Diagram Deviation Record

> **Recorded**: <timestamp>
> **Task**: <task name>
> **Status**: PENDING_DIAGRAM_UPDATE

## Deviation #1

**Diagram**: flow-request.md
**Node/Path**: ErrorHandler → RetryQueue

**What the diagram says**: On validation error, send to RetryQueue
**What was actually implemented**: Return 400 immediately (no retry queue)

**Reason**: The RetryQueue service does not exist in the codebase and
adding it is out of scope for this task.

**Required diagram update**: Remove RetryQueue node from flow-request.md,
replace with direct 400 response path.

**Action needed**: Run /gdd:plan to update the diagram
```

After recording, continue implementing the practical solution.

## Step 6: Implementation Summary

After completing implementation, output:

```
GDD Implementation Complete

Task: <task name>
Files modified: N files

Constraint compliance:
- Module boundaries: FOLLOWED / N DEVIATIONS (see docs/gdd/drafts/)
- Flow execution order: FOLLOWED / N DEVIATIONS
- Error paths: FOLLOWED / N DEVIATIONS
- Test coverage: N tests added for N diagram decision points

Deviations recorded:
- docs/gdd/drafts/draft-deviation-<timestamp>.md (2 deviations)

Starting automated code review...
```

## Step 7: Automated Subagent Code Review Loop

After completing implementation, spawn a subagent to run the code review. Repeat until the verdict is `APPROVED` or `APPROVED_WITH_WARNINGS`.

### How to Invoke

Use the Agent tool to invoke the `gdd:code-review` skill as a subagent:

```
Invoke the `gdd:code-review` skill via the Agent tool.
Pass the list of code files modified during Step 4 as the argument.
```

### Fix-and-Retry Loop

**If verdict is `NEEDS_WORK`**:

1. Read the full review report returned by the subagent
2. Fix all `[CRITICAL]` issues directly in the code files
3. If diagram updates are needed (e.g., to reconcile recorded deviations), invoke `gdd:plan` first, then continue
4. Spawn the subagent again
5. Repeat until verdict is `APPROVED` or `APPROVED_WITH_WARNINGS`

**If verdict is `APPROVED` or `APPROVED_WITH_WARNINGS`**:

Output the final summary:
```
GDD Code Review: APPROVED [/ APPROVED_WITH_WARNINGS]

Files reviewed: <list of code files>
Diagrams compared: <list of diagram files>
Issues found: N critical (fixed), N warnings, N suggestions

<If APPROVED_WITH_WARNINGS, list the warnings here>

Implementation complete. If deviations were recorded, run /gdd:plan to update diagrams.
```

Then wait for the user to confirm there are no further issues.

</process>

<guidelines>
- The diagrams are the contract. If reality doesn't match, record the gap — don't silently bridge it
- Extract constraints BEFORE writing code — never start coding and then check the diagram
- Tests are not optional: each decision point in a flow diagram should have at least one test case
- Deviation records are not failures — they are valuable feedback that improves the diagrams
- If you find yourself writing code for a module that doesn't appear in any diagram, that's a signal: either the diagram is incomplete (record it) or you're going out of scope
</guidelines>
