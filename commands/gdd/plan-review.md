---
name: gdd:plan-review
description: Review GDD diagrams for completeness, consistency, and feasibility — catch design gaps before coding begins
argument-hint: "[<target>]"
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
  - TodoWrite
---

<objective>
Critically review the current GDD diagrams (or a specific draft proposal) to identify design gaps, inconsistencies, and potential issues before code is written.

This is a pure review step — no files are modified. The output is a structured report that helps the team decide whether to proceed to implementation or iterate on the design.
</objective>

<process>

## Step 1: GDD Completeness Check

Verify GDD is initialized (same as gdd:plan Step 1). If not, stop and direct to `/gdd:init`.

## Step 2: Determine Review Scope

**Default scope（无 `<target>` 参数时）**: 运行 `git diff --name-only HEAD`，找出 `docs/gdd/` 下有变更的文件作为主要 review 对象；若未发现任何变更文件，则 fallback 到 `docs/gdd/` 下所有文件（排除 `drafts/`）。

**If `<target>` is provided**: 将用户指定的内容（文件路径、draft 文件名或任意描述）作为 review 对象，替代默认检测逻辑。

## Step 3: Read All Diagram Files

Read every diagram file in scope. For each file, extract:
- The Mermaid diagram(s)
- Key decisions listed
- Notes and cross-references

Build a complete mental model of the design.

Also read up to 5 key source files to understand the actual codebase state (compare design vs. reality).

## Step 4: Run Review Checks

Apply the following review dimensions. For each issue found, assign a severity:

- **[CRITICAL]** — Blocks implementation; must be resolved before coding
- **[WARNING]** — Significant gap or risk; strongly recommended to address
- **[SUGGESTION]** — Minor improvement opportunity; can address later

### 4a. Completeness Check

Questions to answer:
- Does every major external interaction have a flow diagram? (user actions, API calls, background jobs, etc.)
- Does every top-level module/service appear in at least one architecture diagram?
- Are all error paths, failure modes, and edge cases represented?
- Are all state transitions (if applicable) captured?
- Are there any areas of the codebase with NO diagram coverage?

For each gap found: `[SEVERITY] [COMPLETENESS] <description of what's missing> — Suggestion: add <X> to <diagram>`

### 4b. Consistency Check

Questions to answer:
- Do the same entities appear with the same names across all diagrams? (inconsistent naming = confusion)
- Do flow diagrams agree with architecture diagrams about which module owns each step?
- Are there contradictions between diagrams? (e.g., Module A calls Module B in flow diagram, but arch diagram shows B calling A)
- Do "Key Decisions" in related diagrams contradict each other?
- Are cross-references between diagram files accurate?

For each inconsistency: `[SEVERITY] [CONSISTENCY] <description of contradiction> — Found in: <file1> vs <file2>`

### 4c. Boundary and Edge Case Check

Questions to answer:
- What happens when a user provides invalid input?
- What happens when an external service is unavailable?
- What happens when a database operation fails?
- What happens when the system receives concurrent requests?
- Are timeout/retry behaviors captured where relevant?
- Are authentication/authorization boundaries clear?

For each missing edge case: `[SEVERITY] [EDGE_CASE] <scenario not covered> — Impact: <what could go wrong>`

### 4d. Feasibility and Design Quality Check

Questions to answer:
- Does any part of the design seem overly complex for the requirement? Is there a simpler alternative?
- Does the design introduce tight coupling between modules that should be independent?
- Are there circular dependencies in the architecture diagram?
- Does the design scale appropriately for the expected load/usage?
- Is the separation of concerns clear? Or are too many responsibilities lumped in one module?
- Are there known anti-patterns present (e.g., God object, distributed monolith)?

For each concern: `[SEVERITY] [FEASIBILITY] <design concern> — Consider: <alternative approach>`

### 4e. Mermaid Syntax Sanity Check

- Are all node IDs valid (no special characters, no spaces)?
- Are all referenced nodes actually defined in the same diagram?
- Do flow directions make sense (no isolated nodes, no loops that shouldn't loop)?

For each issue: `[WARNING] [SYNTAX] <description of potential Mermaid issue>`

## Step 5: Generate Review Report

Output a structured report:

```
GDD Plan Review Report
======================
Scope: <which files were reviewed>
Date: <today>
Verdict: [APPROVED / APPROVED_WITH_WARNINGS / NEEDS_WORK / BLOCKED]

## Critical Issues (must fix before coding)

[CRITICAL] [CONSISTENCY] The "auth" module appears as a separate service in arch-modules.md
but is called directly (not via API) in flow-request.md. These diagrams contradict each other.
- Found in: arch-modules.md vs flow-request.md
- Fix: Decide whether auth is a separate service or an in-process module, update both diagrams

[CRITICAL] [COMPLETENESS] No diagram covers what happens when the database connection is lost
during a write operation.
- Fix: Add error path to flow-data.md

## Warnings (strongly recommended to fix)

[WARNING] [EDGE_CASE] Token refresh flow is not shown. If the JWT expires mid-session,
the user experience is undefined.
- Suggestion: Add a token refresh path to flow-auth.md

[WARNING] [FEASIBILITY] Module X has 8 outgoing dependencies in arch-modules.md.
This may indicate too many responsibilities. Consider splitting into X-core and X-adapter.

## Suggestions (nice to have)

[SUGGESTION] [CONSISTENCY] "UserService" in flow-request.md and "user-service" in arch-modules.md
appear to refer to the same module. Standardize naming.

[SUGGESTION] [COMPLETENESS] A sequence diagram for the OAuth handshake would clarify the
multi-step interaction with the external identity provider.

## Summary

Total issues: N critical, N warnings, N suggestions

Verdict: NEEDS_WORK

Recommended actions before running /gdd:code:
1. Resolve the auth module placement contradiction (arch-modules.md + flow-request.md)
2. Add database failure path to flow-data.md
3. Consider addressing token refresh (Warning #1)
```

**Verdict definitions:**
- `APPROVED` — No critical issues, no warnings. Safe to proceed to `/gdd:code`
- `APPROVED_WITH_WARNINGS` — No critical issues, but has warnings. Can proceed, but review the warnings
- `NEEDS_WORK` — Has critical issues. Fix them and re-run `/gdd:plan-review` before coding
- `BLOCKED` — Fundamental design problem that requires rethinking the approach. Do not proceed to planning implementation

</process>

<guidelines>
- Be specific: vague feedback like "this could be better" is not actionable
- Cite the exact file and diagram element when reporting issues
- Do not suggest gratuitous complexity — only flag missing edge cases that have real consequences
- If a "missing" element is obviously out of scope for the current requirement, do not flag it
- When a warning is genuinely minor, say so explicitly — developers should be able to confidently ignore SUGGESTION-level items
- The goal is to catch real problems, not to be exhaustive. A 3-issue report that identifies real blockers is more valuable than a 30-issue report full of noise
</guidelines>
