---
name: cadence:main:review
description: End-to-end acceptance of the complete feature — runs test suite, checks original success criteria, confirms no unresolved deviations
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
---

<objective>
Verify that the complete feature satisfies the original success criteria from the clarification established in the current conversation. Run the full test suite and confirm no unresolved deviations remain. Produce a verdict: FEATURE_ACCEPTED or FEATURE_BLOCKED.
</objective>

<process>

## Step 1: Read the Original Success Criteria

Use the clarification summary from the current conversation context. Extract the success criteria — these are the definition of done for the entire feature.

## Step 2: Check for Unresolved Deviations

Read deviation records from the current conversation context. If any exist, review them.

Deviations are acceptable if they are documented and the impact is understood. Flag any deviation that:
- Has not been acknowledged (no resolution note)
- Affects a success criterion

## Step 3: Run the Full Test Suite

Run the project's full test suite using Bash. Use the test command from the project's `package.json`, `Makefile`, or equivalent.

Capture: total tests, passing, failing.

If tests fail, output:
```
FEATURE_BLOCKED: <N> tests failing.
<test output summary>
Fix the failing tests before feature acceptance.
```

## Step 4: Check Each Success Criterion

For each success criterion from the clarification summary:
- Is there evidence in the implementation that it is satisfied?
- Is there a test that verifies it?

Mark each: SATISFIED / NOT_SATISFIED / UNTESTED

## Step 5: Assign Verdict

**FEATURE_ACCEPTED**: All tests pass, all success criteria SATISFIED.

**FEATURE_ACCEPTED_WITH_WARNINGS**: All tests pass, all success criteria SATISFIED, but minor issues remain (e.g., unresolved deviation docs, UNTESTED criteria with low risk). List warnings.

**FEATURE_BLOCKED**: Any test failing, or any success criterion NOT_SATISFIED.

## Step 6: Output Report

```
## Feature Review

**Verdict**: FEATURE_ACCEPTED | FEATURE_ACCEPTED_WITH_WARNINGS | FEATURE_BLOCKED

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
Feature accepted. Run `cadence:main:deliver` to close out.
```

</process>
