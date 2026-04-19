---
name: cadence:coding:code-review
description: Review staged git changes for style, bugs, and security — produces APPROVED, APPROVED_WITH_NOTES, or NEEDS_WORK verdict
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
---

<objective>
Review the staged git changes (or HEAD diff if nothing is staged) for style, correctness, and security issues. Assign severity to each finding and produce a structured verdict: APPROVED, APPROVED_WITH_NOTES, or NEEDS_WORK.
</objective>

<process>

## Step 1: Gather the Diff

Run `git diff --staged`. If the output is empty, fall back to `git diff HEAD`.

If both are empty, output:
```
No changes to review. Stage your changes with `git add` or make a commit first.
```
and stop.

## Step 2: Identify Changed Files

Parse the diff to list every changed file with its language/type and approximate lines changed.

## Step 3: Review Each File

For each changed file, read its full content with the Read tool for context, then review the diff across three dimensions:

**Style**
- Naming conventions (variables, functions, classes match surrounding code)
- Formatting consistency
- Unnecessary complexity or duplication introduced

**Bugs / Correctness**
- Logic errors or incorrect conditions
- Unhandled edge cases (empty input, null/undefined, array bounds)
- Off-by-one errors
- Incorrect error handling or swallowed exceptions

**Security**
- Injection vulnerabilities (SQL, command, path traversal)
- Hardcoded secrets, tokens, or credentials
- Unsafe deserialization or eval usage
- Missing input validation at system boundaries
- OWASP Top 10 issues relevant to the file's language and context

## Step 4: Assign Severity

For each finding, assign one of:
- `CRITICAL` — exploitable security vulnerability or data-loss bug
- `MAJOR` — likely runtime error, incorrect behavior, or significant security weakness
- `MINOR` — style issue, non-critical correctness concern, or improvement opportunity
- `NOTE` — observation or suggestion with no impact on correctness

## Step 5: Assign Verdict

- **APPROVED** — no CRITICAL or MAJOR findings
- **APPROVED_WITH_NOTES** — no CRITICAL or MAJOR findings, but MINOR or NOTE findings exist
- **NEEDS_WORK** — one or more CRITICAL or MAJOR findings

## Step 6: Output Report

```
## Code Review

**Verdict**: APPROVED | APPROVED_WITH_NOTES | NEEDS_WORK

### Files Reviewed
- <path> (<N> lines changed)

### Findings

| Severity | File | Line | Issue |
|----------|------|------|-------|
| CRITICAL | ...  | ...  | ...   |
| MAJOR    | ...  | ...  | ...   |
| MINOR    | ...  | ...  | ...   |
| NOTE     | ...  | ...  | ...   |

### Summary
<1-2 sentences describing the overall state of the changes>
```

If there are no findings, output:
```
### Findings
No issues found.
```

</process>
