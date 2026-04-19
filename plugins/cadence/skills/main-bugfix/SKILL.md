---
name: cadence:main:bugfix
description: Execute the bugfix procedure — reproduce, diagnose, fix, and verify a defect
argument-hint: "<bug description or ST-XX>"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - LSP
---

<objective>
Fix a defect by following a disciplined reproduce → diagnose → fix → verify procedure. Never jump straight to the fix — always reproduce and diagnose first.
</objective>

<process>

## Step 1: Read the Clarification

Use the clarification summary from the current conversation context to understand the bug's scope, constraints, and success criteria. If no clarification has been established yet, invoke `cadence:main:clarify` first.

## Step 2: Reproduce

Establish a reliable reproduction:

- Identify the exact steps or inputs that trigger the bug
- Confirm the bug is reproducible in the current codebase
- Write a failing test (or identify the existing test that covers the broken behavior) — **the test must fail before you touch any fix code**

If reproduction is not possible, stop and ask the user for more context.

## Step 3: Diagnose

Trace the root cause:

- Read the relevant code paths
- Use LSP (goToDefinition, findReferences) to trace call chains
- Identify the exact line(s) or logic where the defect originates
- State the root cause in one sentence before writing any fix

## Step 4: Fix

Apply the minimal fix that addresses the root cause:

- Change only what is necessary — do not refactor unrelated code
- Do not introduce new abstractions unless the fix requires it
- If the fix is non-obvious, add a one-line comment explaining the constraint

## Step 5: Verify

Confirm the fix works:

- Run the failing test from Step 2 — it must now pass
- Run the full test suite — no regressions
- Manually verify the reproduction steps from Step 2 no longer trigger the bug

Output a summary:
```
Root cause: <one sentence>
Fix: <what was changed and why>
Test: <test name — was failing, now passing>
```

</process>

<guidelines>
- Never skip reproduction — a fix without a failing test is a guess
- If the root cause turns out to be a missing feature (not a defect), stop and tell the user — this may need to switch to a `feature-dev` session
- Keep the fix minimal: the smaller the diff, the easier the review
- If you find related bugs while diagnosing, note them but do not fix them in this session
</guidelines>
