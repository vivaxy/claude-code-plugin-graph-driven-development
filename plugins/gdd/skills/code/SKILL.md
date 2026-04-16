---
name: gdd:code
description: Implement a feature guided by GDD documents and diagrams — extract design constraints from design documents, flowcharts, and architecture diagrams before writing code
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
Implement a feature or task by first extracting implementation constraints from the GDD design documents and diagrams, then writing code that strictly adheres to those constraints.

The documents and diagrams are the source of truth. If the code needs to deviate from them, that deviation must be recorded — NOT silently done. Document and diagram updates happen through `gdd:plan`, not during coding.
</objective>

<process>

## Step 1: docs/ Completeness Check

1. Verify `docs/` exists with at least one `flow-*.md` and one `arch-*.md`
2. Check `docs/drafts/` for unreviewed drafts

**If docs/ is not initialized:**

Do NOT stop. Invoke the `gdd:plan` skill with the current task as the argument, which will create the initial documents and diagrams first.

**If deviation records exist:**
```
Note: Unresolved deviation records exist in docs/drafts/:
- draft-deviation-<timestamp>.md — recorded during a prior coding session

These deviations mean the diagrams may not match the current code.
Consider running gdd:plan to update the diagrams before proceeding.

Continuing with the current diagrams...
```
Continue with a note, do not block.

## Step 2: Understand the Task

Parse `$ARGUMENTS` — the feature or task to implement. If unclear, ask one focused clarifying question before proceeding.

## Step 3: Extract Design Constraints from Documents and Diagrams

Read all relevant files. For each relevant file, extract specific implementation constraints:

### From Design Documents (doc-*.md)

Extract:
- **Requirements**: What must the feature do?
- **Key decisions**: What design choices were already made and why?
- **Constraints**: What must NOT be done?
- **Open questions**: Are there unresolved items that affect implementation?

### From Architecture Diagrams (arch-*.md)

Extract:
- **Module boundaries**: Which module/file/package is responsible for this feature?
- **Dependency direction**: Which modules does this feature depend on? Which modules must NOT be depended on?
- **Interface contracts**: How does this module communicate with others?
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

REQUIREMENTS (from doc-*.md):
- <requirement 1>
- <requirement 2>

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

## Step 4: Write Failing Tests

Before writing any production code, write one failing test per decision point extracted in Step 3.

### Test mapping rule

Name each test after its diagram node:

```
test("<DiagramFile> → <NodeLabel>: <scenario>", ...)
```

Examples:
```
test("flow-request.md → AuthCheck: returns 401 when token is missing", ...)
test("flow-request.md → AuthCheck: continues to Process when token is valid", ...)
test("flow-data.md → Rollback: rolls back transaction when DB write fails", ...)
```

### What to cover

For each **decision node** (two or more outgoing edges): one test per branch.
For each **error path**: one test that triggers the error condition and asserts the error behavior.
For each **external system interaction**: one test that stubs the external system and asserts the correct payload.

Skip simple pass-through nodes (one ingoing, one outgoing, no branching logic).

### Verification gate

Run the tests. They must ALL FAIL before proceeding to Step 5. A test that passes before any production code exists is testing nothing — rewrite or delete it.

```
TDD Gate: N tests written, N failing — proceeding to implementation
```

Do not proceed to Step 5 until this gate is cleared.

## Step 5: Implement Until Tests Pass

Implement the feature following the constraints. The tests written in Step 4 are the acceptance criteria.

### Do

- Follow requirements from design documents
- Follow module boundaries exactly as defined in arch diagrams
- Implement error handling for every error path shown in flow diagrams
- Use the same naming as nodes/labels in the diagrams (consistency)
- Implement steps in the order shown in flow diagrams
- Run the test suite after each logical unit of implementation

### Do NOT

- Import from modules outside the allowed dependency set
- Skip error paths that are shown in the diagrams
- Silently deviate from the documents or diagrams (see Step 6 if deviation is needed)
- "Improve" the architecture while coding — record it as a deviation instead
- Write new tests here — tests belong in Step 4

### Track Progress with TodoWrite

Create a todo list covering both test-writing and implementation:

```
TDD todos:
[ ] Test: Validate input — flow-request.md → Validate node (write failing test)
[ ] Test: Auth success path — flow-request.md → AuthCheck node (write failing test)
[ ] Test: Auth failure → 401 — flow-request.md → Error node (write failing test)
[ ] Run tests — verify all fail (TDD gate)
[ ] Implement: Validate input
[ ] Implement: Check authorization
[ ] Implement: Execute business logic
[ ] Implement: Persist result
[ ] Implement: Return response
[ ] Run tests — verify all pass
```

## Step 6: Record Deviations

If during implementation you discover that a document or diagram is inaccurate, incomplete, or impractical:

**Do NOT silently fix the document/diagram or deviate without recording.**

Instead, record the deviation in a `docs/drafts/draft-deviation-<timestamp>.md` file:

```markdown
# Diagram Deviation Record

> **Recorded**: <timestamp>
> **Task**: <task name>
> **Status**: PENDING_DIAGRAM_UPDATE

## Deviation #1

**Document/Diagram**: flow-request.md
**Node/Path**: ErrorHandler → RetryQueue

**What the document/diagram says**: On validation error, send to RetryQueue
**What was actually implemented**: Return 400 immediately (no retry queue)

**Reason**: The RetryQueue service does not exist in the codebase and
adding it is out of scope for this task.

**Required update**: Remove RetryQueue node from flow-request.md,
replace with direct 400 response path.

**Action needed**: Run gdd:plan to update the diagram
```

After recording, continue implementing the practical solution.

## Step 7: Implementation Summary

After completing implementation, output:

```
GDD Implementation Complete

Task: <task name>
Files modified: N files

Constraint compliance:
- Requirements: FOLLOWED / N DEVIATIONS (see docs/drafts/)
- Module boundaries: FOLLOWED / N DEVIATIONS
- Flow execution order: FOLLOWED / N DEVIATIONS
- Error paths: FOLLOWED / N DEVIATIONS
- TDD coverage: N failing tests written, N passing after implementation

Deviations recorded:
- docs/drafts/draft-deviation-<timestamp>.md (2 deviations)

Starting automated code review...
```

## Step 8: Automated Subagent Code Review Loop

After completing implementation, spawn a subagent to run the code review. Repeat until the verdict is `APPROVED` or `APPROVED_WITH_WARNINGS`.

### How to Invoke

Use the Agent tool to invoke the `gdd:code-review` skill as a subagent:

```
Invoke the `gdd:code-review` skill via the Agent tool.
Pass the list of code files modified during Step 5 as the argument.
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
Documents and diagrams compared: <list of files>
Issues found: N critical (fixed), N warnings, N suggestions

<If APPROVED_WITH_WARNINGS, list the warnings here>

Implementation complete. If deviations were recorded, run gdd:plan to update documents and diagrams.
```

Then wait for the user to confirm there are no further issues.

</process>

<guidelines>
- Documents and diagrams are the contract. If reality doesn't match, record the gap — don't silently bridge it
- Extract constraints BEFORE writing code — never start coding and then check the documents/diagrams
- Tests come before code: write failing tests for every decision point before any production code; the TDD gate in Step 4 is not optional
- Deviation records are not failures — they are valuable feedback that improves the documents and diagrams
- If you find yourself writing code for a module that doesn't appear in any document or diagram, that's a signal: either the docs are incomplete (record it) or you're going out of scope
</guidelines>
