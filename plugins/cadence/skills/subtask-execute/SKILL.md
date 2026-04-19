---
name: cadence:subtask-execute
description: Execute a single subtask — read docs, write failing tests, implement, run subtask-review, update subtask status
argument-hint: "<subtask-id e.g. ST-01>"
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
Execute one subtask from `docs/doc-subtasks.md`. Extract design constraints from docs and diagrams, write failing tests, implement until tests pass, record any deviations, then invoke `cadence:subtask-review` as a subagent. On ACCEPTED, update the subtask status in `docs/doc-subtasks.md`.
</objective>

<process>

## Step 1: Identify the Subtask

Read `docs/doc-subtasks.md`.

- If `$ARGUMENTS` contains a subtask ID (e.g., `ST-01`), find that subtask.
- If no ID is given, pick the first subtask with status PENDING whose dependencies are all ACCEPTED.

Verify:
- The subtask exists and has status PENDING
- All listed dependencies have status ACCEPTED

If dependencies are not ACCEPTED, stop and tell the user which dependency to execute first.

## Step 2: Mark Subtask as IN_PROGRESS

Update `docs/doc-subtasks.md`: change the subtask's status from PENDING to IN_PROGRESS.

## Step 3: Extract Design Constraints

Read all relevant `docs/` files for this subtask's scope:
- `doc-*.md` — requirements and design decisions
- `arch-*.md` — module boundaries and dependency rules
- `flow-*.md` — execution steps, error paths, naming conventions

Extract:
- Module boundaries: which modules this subtask touches and which it must not
- Naming conventions: use the same names as diagram nodes
- Error paths: what failure cases must be handled
- Interface contracts: what inputs/outputs are expected

## Step 4: Write Failing Tests

Map each acceptance criterion from the subtask to one or more tests:
- Happy path test for each criterion
- Error path tests for each failure case in the flow diagrams
- Edge case tests where the flow shows conditional branches

**Gate**: Run the tests. They must fail before proceeding. If they pass already, the feature may already be implemented — investigate and confirm with the user.

## Step 5: Implement Until Tests Pass

Implement the subtask following the design constraints:
- Use the same naming as diagram nodes
- Respect module boundaries from `arch-*.md`
- Follow the flow steps from `flow-*.md`
- Do NOT modify any `docs/` diagram files during implementation

Run tests after each logical unit of work. Continue until all tests pass.

## Step 6: Record Deviations

If the implementation must deviate from the diagrams (e.g., a design decision turns out to be infeasible), do NOT silently modify diagram files.

Instead, create `docs/drafts/draft-deviation-<subtask-id>-<date>.md`:

```markdown
# Deviation Record: <subtask-id>

> **Subtask**: <subtask title>
> **Date**: YYYY-MM-DD

## Deviation

**Original design**: <what the diagram/doc specified>
**Actual implementation**: <what was built instead>
**Reason**: <why the deviation was necessary>

## Impact

<Which diagrams need to be updated to reflect this deviation>
```

## Step 7: Implementation Summary

Output:
```
ST-XX implementation complete:
- Tests: <N> passing, 0 failing
- Files changed: <list>
- Deviations: <none | see docs/drafts/draft-deviation-ST-XX-*.md>
```

## Step 8: Run Subtask Review

Invoke `cadence:subtask-review` as a subagent, passing the subtask ID and the list of changed files as arguments.

If the verdict is NEEDS_WORK:
- Read the review report
- Fix the identified issues
- Re-run the subagent review
- Repeat until ACCEPTED or ACCEPTED_WITH_WARNINGS

## Step 9: Update Subtask Status

After ACCEPTED or ACCEPTED_WITH_WARNINGS:

Update `docs/doc-subtasks.md`: change the subtask's status to ACCEPTED.

Check if all subtasks are now ACCEPTED. If yes, output:
```
All subtasks complete. Run `cadence:review` for end-to-end feature acceptance.
```

If more subtasks remain, output:
```
ST-XX accepted. Next: run `cadence:subtask-execute ST-YY`.
```

</process>

<guidelines>
- Never modify `flow-*.md` or `arch-*.md` during implementation — record deviations instead
- Always read the relevant docs before writing any code
- Tests must fail before implementation begins — this is the TDD gate
- The subtask's acceptance criteria are the source of truth for what "done" means
- Keep implementation scoped to the subtask — do not fix unrelated issues
</guidelines>
