---
name: vivaxy-workflow:subtask-review
description: Verify a subtask implementation against its acceptance criteria and doc/diagram alignment — returns ACCEPTED, ACCEPTED_WITH_WARNINGS, or NEEDS_WORK
argument-hint: "<subtask-id> <space-separated changed files>"
allowed-tools:
  - Read
  - Glob
  - Grep
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

<objective>
Review a subtask implementation against its acceptance criteria and the design documents/diagrams. Produce a structured verdict report: ACCEPTED, ACCEPTED_WITH_WARNINGS, or NEEDS_WORK.
</objective>

<process>

## Step 1: Parse Arguments

From `$ARGUMENTS`, extract:
- Subtask ID (e.g., `ST-01`)
- List of changed files

## Step 2: Read Everything in Parallel

Read simultaneously:
- `docs/doc-subtasks.md` — find the subtask's acceptance criteria and description
- Clarification summary from the current conversation context — original problem context
- All relevant `docs/doc-*.md`, `docs/flow-*.md`, `docs/arch-*.md` files
- All changed files listed in arguments
- Any `docs/drafts/draft-deviation-<subtask-id>-*.md` files

## Step 3: Acceptance Criteria Check

For each acceptance criterion in the subtask:
- Does the implementation satisfy it?
- Is there a test that verifies it?
- Does the test pass?

Mark each criterion: SATISFIED / NOT_SATISFIED / UNTESTED

## Step 4: Document and Diagram Alignment

Check:
- **Module boundaries**: Does the implementation respect the boundaries in `arch-*.md`?
- **Flow coverage**: Does the implementation cover all paths in the relevant `flow-*.md`?
- **Naming consistency**: Do identifiers in the code match the names used in diagram nodes?
- **Error handling**: Are all error paths from the diagrams handled in the code?
- **No undocumented side effects**: Does the implementation do anything not described in the docs?

## Step 5: Code Quality Check

Check:
- Dead code or unused imports
- Missing error handling for expected failure cases
- Magic numbers or unexplained constants
- Test coverage gaps (paths in the code with no corresponding test)
- Security issues (injection, unvalidated input at system boundaries)

## Step 6: Assign Verdict

**ACCEPTED**: All acceptance criteria SATISFIED, no alignment violations, no blocking quality issues.

**ACCEPTED_WITH_WARNINGS**: All acceptance criteria SATISFIED, but minor quality issues or minor alignment gaps that do not affect correctness. List the warnings.

**NEEDS_WORK**: One or more acceptance criteria NOT_SATISFIED or UNTESTED, OR a blocking alignment violation, OR a blocking quality issue. List each issue with enough detail to fix it.

## Step 7: Output Structured Report

```
## Subtask Review: <subtask-id>

**Verdict**: ACCEPTED | ACCEPTED_WITH_WARNINGS | NEEDS_WORK

### Acceptance Criteria

| Criterion | Result |
|-----------|--------|
| <criterion 1> | SATISFIED / NOT_SATISFIED / UNTESTED |
| <criterion 2> | SATISFIED / NOT_SATISFIED / UNTESTED |

### Alignment Issues

- <issue 1> (blocking / warning)
- <none>

### Code Quality Issues

- <issue 1> (blocking / warning)
- <none>

### Summary

<1-2 sentences explaining the verdict>
```

</process>
