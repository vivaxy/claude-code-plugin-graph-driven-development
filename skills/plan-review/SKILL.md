---
name: gdd:plan-review
description: Review GDD diagram files for completeness, consistency, edge cases, design quality, and Mermaid syntax — returns APPROVED, APPROVED_WITH_WARNINGS, NEEDS_WORK, or BLOCKED
argument-hint: "<space-separated list of diagram files to review>"
allowed-tools:
  - Read
  - Glob
---

<SUBAGENT-STOP>
This skill is intended to be invoked as a subagent by `gdd:plan`. If you are the main agent running `gdd:plan`, do not execute this skill inline — spawn it as a subagent via the Agent tool.
</SUBAGENT-STOP>

<objective>
Review the GDD diagram files specified in `$ARGUMENTS` (or all files in `docs/gdd/` if no arguments given) across six dimensions. Produce a structured report and assign a verdict.
</objective>

<process>

## Step 1: Read Diagrams

Read all diagram files in scope:
- If `$ARGUMENTS` lists specific files, read those.
- Otherwise, read all `*.md` files in `docs/gdd/` (excluding `drafts/`).

## Step 2: Run Review Checks

### 2a. Completeness Check

- Does every major external interaction have a flow diagram?
- Does every top-level module/service appear in at least one architecture diagram?
- Are all error paths, failure modes, and edge cases represented?
- Are all state transitions captured?

For each gap: `[SEVERITY] [COMPLETENESS] <description> — Suggestion: add <X> to <diagram>`

### 2b. Consistency Check

- Do the same entities appear with the same names across all diagrams?
- Do flow diagrams agree with architecture diagrams about which module owns each step?
- Are there contradictions between diagrams?
- Do "Key Decisions" in related diagrams contradict each other?

For each inconsistency: `[SEVERITY] [CONSISTENCY] <description> — Found in: <file1> vs <file2>`

### 2c. Boundary and Edge Case Check

- What happens when a user provides invalid input?
- What happens when an external service is unavailable?
- What happens when a database operation fails?
- Are timeout/retry behaviors captured where relevant?
- Are authentication/authorization boundaries clear?

For each missing edge case: `[SEVERITY] [EDGE_CASE] <scenario> — Impact: <what could go wrong>`

### 2d. Feasibility and Design Quality Check

- Does any part of the design seem overly complex?
- Does the design introduce tight coupling between modules that should be independent?
- Are there circular dependencies in the architecture diagram?
- Is the separation of concerns clear?

For each concern: `[SEVERITY] [FEASIBILITY] <concern> — Consider: <alternative>`

### 2e. Mermaid Syntax Sanity Check

- Are all node IDs valid (no special characters, no spaces)?
- Are all referenced nodes actually defined in the same diagram?
- Do flow directions make sense?

For each issue: `[WARNING] [SYNTAX] <description>`

### 2f. DDD Context Integrity Check (only if `arch-ddd-contexts.md` is in scope)

- Does each subgraph correspond to a named bounded context?
- Does each aggregate root node own its listed entities and value objects?
- Are context relationships labeled with the correct DDD type (Shared Kernel, Customer/Supplier, Conformist, ACL)?
- Do context boundaries agree with module boundaries in `arch-*.md`?
- Is there at least one aggregate root per bounded context?

For each issue: `[SEVERITY] [DDD_CONTEXT] <description> — Suggestion: <fix>`

## Step 3: Assign Verdict

```
APPROVED            — No critical issues, no warnings
APPROVED_WITH_WARNINGS — No critical issues, but has warnings
NEEDS_WORK          — At least one [CRITICAL] issue; main agent must fix before proceeding
BLOCKED             — Fundamental design problem; main agent must rethink the approach
```

## Step 4: Output Report

```
GDD Diagram Review Report
=========================
Files reviewed: <list>
Verdict: <APPROVED | APPROVED_WITH_WARNINGS | NEEDS_WORK | BLOCKED>

Issues:
<list all findings, grouped by check dimension>

Summary: N critical, N warnings, N suggestions
```

</process>
