---
name: gdd:code-review
description: Review implemented code for alignment with GDD design documents and diagrams, and code quality — returns APPROVED, APPROVED_WITH_WARNINGS, or NEEDS_WORK
argument-hint: "<space-separated list of code files to review>"
allowed-tools:
  - Read
  - Glob
  - Grep
---

<SUBAGENT-STOP>
This skill is intended to be invoked as a subagent by `gdd:code`. If you are the main agent running `gdd:code`, do not execute this skill inline — spawn it as a subagent via the Agent tool.
</SUBAGENT-STOP>

<objective>
Review the code files specified in `$ARGUMENTS` against the GDD design documents and diagrams in `docs/`. Check alignment with design intent and code quality. Produce a structured report and assign a verdict.
</objective>

<process>

## Step 1: Read Everything in Parallel

1. All GDD documents and diagram files in `docs/` (excluding `drafts/`)
2. All code files listed in `$ARGUMENTS`
3. Any existing deviation records in `docs/drafts/draft-deviation-*.md`

## Step 2: Diagram Alignment Review

For each flow diagram, trace through every node and verify the code:

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
- `[DEVIATION: MISSING_TEST]` — Diagram shows a decision point, no test covers it (`[CRITICAL]`)

For each deviation, include:
- Severity: `[CRITICAL]` (wrong behavior), `[WARNING]` (risky shortcut), `[INFO]` (minor drift)
- Diagram reference: exact file and node name
- Code reference: exact file and line range
- Recommendation: fix the code, OR update the diagram

## Step 3: Code Quality Review

**TDD Compliance**:
- Does every flow diagram decision node have at least one corresponding test? Name any missing ones.
- Are tests named using the `<DiagramFile> → <NodeLabel>: <scenario>` pattern?
- Are there tests that cannot possibly fail (assert always-true conditions, empty bodies, tests that mock away the logic they claim to verify)?

TDD issue severity:
- `[CRITICAL]` — A diagram decision node has no test at all
- `[WARNING]` — Tests exist but naming does not tie to diagram nodes (untraceability)
- `[SUGGESTION]` — Minor test quality issue

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

## Step 4: Assign Verdict

```
APPROVED            — No critical issues in either dimension
APPROVED_WITH_WARNINGS — No critical issues, but has warnings worth addressing
NEEDS_WORK          — At least one [CRITICAL] issue; main agent must fix before proceeding
```

## Step 5: Output Report

```
GDD Code Review Report
======================
Files reviewed: <list of code files>
Design documents and diagrams compared: <list of files>
Verdict: <APPROVED | APPROVED_WITH_WARNINGS | NEEDS_WORK>

Diagram Alignment:
<list all deviations>

Code Quality:
<list all quality issues>

Summary: N critical, N warnings, N suggestions
```

</process>
