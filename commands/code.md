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

**If unreviewed drafts exist:**
```
Warning: Unreviewed draft proposals exist in docs/gdd/drafts/:
- draft-plan-2026-01-23-10-30.md — "Add authentication flow"

These drafts contain planned diagram changes that have NOT been applied yet.

If this task depends on those planned changes, apply the drafts first:
  /gdd:plan --apply docs/gdd/drafts/draft-plan-2026-01-23-10-30.md

Continuing with the current (pre-draft) diagrams...
```
Continue with a note, do not block.

## Step 1b: Read Todo List

Before parsing `$ARGUMENTS`, check if `docs/gdd/todos.md` exists.

**If it exists and `$ARGUMENTS` is empty:**

1. Read `docs/gdd/todos.md`
2. Find the first unchecked item (first line matching `- [ ] ...`)
3. Use that item's task title as the task for this session — treat it as if the user passed it as `$ARGUMENTS`
4. Output:
   ```
   Reading from docs/gdd/todos.md...
   Next task: <task title> (<diagram ref>)
   ```

**If `$ARGUMENTS` is provided by the user:** use `$ARGUMENTS` as-is (ignore the todo list for task selection).

**If `docs/gdd/todos.md` does not exist or has no unchecked items:** continue to Step 2 and ask the user for the task.

> Note: Do NOT mark the todo item as complete in this step. Mark it complete (change `- [ ]` to `- [x]`) only after Step 6 (Implementation Summary) succeeds.

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

Then, if this task was read from `docs/gdd/todos.md` in Step 1b, mark it as complete:

- Find the matching `- [ ] <task title>` line in `docs/gdd/todos.md`
- Change it to `- [x] <task title>`

## Step 7: Automated Subagent Code Review Loop

After completing implementation, immediately run a full code review as a subagent. Repeat until the verdict is `APPROVED` or `APPROVED_WITH_WARNINGS`.

### Review Logic (run as subagent)

Perform the following review checks on the code that was just written. This is identical to the full `gdd:code-review` logic:

**Scope**: All files modified during Step 4, plus any existing deviation records in `docs/gdd/drafts/draft-deviation-*.md`.

Read in parallel:
1. All GDD diagram files in `docs/gdd/` (excluding `drafts/`)
2. All code files in scope
3. Any existing deviation records

#### 7a. Diagram Alignment Review

For each flow diagram, trace through the diagram and verify the code:

For each node in the flow diagram:
1. Find the corresponding code (function, method, handler, etc.)
2. Verify the code does what the node describes
3. Verify the transition to the next node is implemented
4. Verify branching conditions match the diagram's decision points

For each architecture diagram:
1. Find each module/component in the code
2. Verify imports/dependencies match the diagram's edges
3. Check for undeclared dependencies (module imports something not shown in the arch diagram)
4. Check for missing dependencies (diagram shows a connection, code doesn't have it)

Deviation categories:
- `[DEVIATION: MISSING]` — Diagram shows X, code does not implement X
- `[DEVIATION: EXTRA]` — Code implements X, diagram does not show X
- `[DEVIATION: WRONG_ORDER]` — Code does A then B, diagram shows B then A
- `[DEVIATION: WRONG_BOUNDARY]` — Code puts X in Module A, diagram puts X in Module B
- `[DEVIATION: MISSING_ERROR_PATH]` — Diagram shows error path, code has no error handling
- `[DEVIATION: ALREADY_RECORDED]` — This deviation exists in a draft-deviation file (just note it)

For each deviation, include:
- Severity: `[CRITICAL]` (wrong behavior), `[WARNING]` (risky shortcut), `[INFO]` (minor drift)
- Diagram reference: exact file and node name
- Code reference: exact file and line range
- Recommendation: fix the code, OR update the diagram

#### 7b. Code Quality Review

**Correctness**:
- Are there off-by-one errors, null pointer risks, or unhandled exceptions?
- Are all code paths reachable?
- Do the tests actually test what they claim to test?

**Simplicity**:
- Is there a simpler way to express this logic?
- Are there unnecessary abstractions or indirections?
- Is there duplicated logic that could be extracted?

**Maintainability**:
- Would a new team member understand this code in 6 months?
- Are complex algorithms explained with comments?
- Is the function/method size appropriate?

**Consistency**:
- Does the code follow the patterns established in the rest of the codebase?
- Are naming conventions consistent with existing code?

Quality issue severity:
- `[CRITICAL]` — Will likely cause bugs in production
- `[WARNING]` — Technical debt that will cause problems as the codebase grows
- `[SUGGESTION]` — Minor improvement, take it or leave it

### Review Verdict

Assign one of:
- `APPROVED` — No critical issues in either dimension
- `APPROVED_WITH_WARNINGS` — No critical issues, but has warnings worth addressing
- `NEEDS_WORK` — Has at least one critical issue in either dimension; main agent must fix before proceeding

### Fix-and-Retry Loop

**If verdict is `NEEDS_WORK`**:

1. Output the full review report (both Diagram Alignment and Code Quality sections)
2. As the main agent, fix all `[CRITICAL]` issues directly in the code files
3. If diagram updates are needed (e.g., to reconcile recorded deviations), run `/gdd:plan` first, then continue
4. Go back to the subagent review and run it again
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

</process>

<guidelines>
- The diagrams are the contract. If reality doesn't match, record the gap — don't silently bridge it
- Extract constraints BEFORE writing code — never start coding and then check the diagram
- Tests are not optional: each decision point in a flow diagram should have at least one test case
- Deviation records are not failures — they are valuable feedback that improves the diagrams
- If you find yourself writing code for a module that doesn't appear in any diagram, that's a signal: either the diagram is incomplete (record it) or you're going out of scope
</guidelines>
