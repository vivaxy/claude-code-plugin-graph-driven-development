---
name: vivaxy-workflow:main:review
description: End-to-end acceptance of the complete feature — verifies all subtasks accepted, runs test suite, checks original success criteria
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
---

<objective>
Verify that the complete feature satisfies the original success criteria from `docs/doc-clarification.md`. Check that all subtasks are ACCEPTED, run the full test suite, and confirm no unresolved deviations remain. Produce a verdict: FEATURE_ACCEPTED or FEATURE_BLOCKED.
</objective>

<process>

## Step 1: Read the Original Success Criteria

Read `docs/doc-clarification.md`. Extract the success criteria — these are the definition of done for the entire feature.

## Step 2: Verify All Subtasks Are Accepted

Read `docs/doc-subtasks.md`. Check that every subtask has status ACCEPTED.

If any subtask has status PENDING or IN_PROGRESS or NEEDS_WORK, stop and output:
```
FEATURE_BLOCKED: The following subtasks are not yet ACCEPTED:
- ST-XX: <title> (status: <status>)
Run `vivaxy-workflow:subtask-execute ST-XX` to continue.
```

## Step 3: Check for Unresolved Deviations

Glob for `docs/drafts/draft-deviation-*.md`. If any exist, read them.

Deviations are acceptable if they are documented and the impact is understood. Flag any deviation that:
- Has not been acknowledged (no resolution note)
- Affects a success criterion

## Step 4: Run the Full Test Suite

Run the project's full test suite using Bash. Use the test command from the project's `package.json`, `Makefile`, or equivalent.

Capture: total tests, passing, failing.

If tests fail, output:
```
FEATURE_BLOCKED: <N> tests failing.
<test output summary>
Fix the failing tests before feature acceptance.
```

## Step 5: Check Each Success Criterion

For each success criterion from `doc-clarification.md`:
- Is there evidence in the implementation that it is satisfied?
- Is there a test that verifies it?

Mark each: SATISFIED / NOT_SATISFIED / UNTESTED

## Step 6: Assign Verdict

**FEATURE_ACCEPTED**: All subtasks ACCEPTED, all tests pass, all success criteria SATISFIED.

**FEATURE_ACCEPTED_WITH_WARNINGS**: All subtasks ACCEPTED, all tests pass, all success criteria SATISFIED, but minor issues remain (e.g., unresolved deviation docs, UNTESTED criteria with low risk). List warnings.

**FEATURE_BLOCKED**: Any subtask not ACCEPTED, any test failing, or any success criterion NOT_SATISFIED.

## Step 7: Output Report

```
## Feature Review

**Verdict**: FEATURE_ACCEPTED | FEATURE_ACCEPTED_WITH_WARNINGS | FEATURE_BLOCKED

### Subtask Status
All N subtasks: ACCEPTED ✓

### Test Suite
<N> tests passing, 0 failing ✓

### Success Criteria

| Criterion | Result |
|-----------|--------|
| <criterion 1> | SATISFIED |
| <criterion 2> | SATISFIED |

### Deviations
<none | list of unresolved deviations>

### Warnings
<none | list of warnings>

### Summary
<1-2 sentences>
```

On FEATURE_ACCEPTED or FEATURE_ACCEPTED_WITH_WARNINGS, output:
```
Feature accepted. Run `vivaxy-workflow:main:deliver` to close out.
```

</process>
