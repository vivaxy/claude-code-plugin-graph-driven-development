---
name: gdd:code-review
description: Review code implementation against GDD diagrams — verify alignment with design and identify quality improvements
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
Review the implemented code from two independent angles:

1. **Diagram Alignment**: Does the code faithfully implement what the GDD diagrams specified? Are there deviations — intentional or accidental?
2. **Code Quality**: Is there a better way to implement this? Simplicity, maintainability, correctness, performance.

This produces a structured report that helps the developer decide what to fix now, what to fix later, and what diagram updates are needed.
</objective>

<process>

## Step 1: GDD Completeness Check

Verify GDD is initialized. If not, stop and direct to `/gdd:init`.

## Step 2: Determine Code Review Scope

**Default scope（无 `<target>` 参数时）**: 运行 `git diff --name-only HEAD` 找出当前上下文中修改过的代码文件作为 review 对象；若未发现任何变更文件，则 fallback 到运行 `git diff HEAD~1 --name-only` 获取最近一次提交的变更文件。

**If `<target>` is provided**: 将用户指定的内容（文件路径、glob 表达式或任意描述）作为 review 对象，替代默认检测逻辑。

## Step 3: Read Diagrams and Code

Read in parallel:
1. All GDD diagram files in `docs/gdd/` (excluding `drafts/`)
2. All code files in the review scope
3. Any existing deviation records in `docs/gdd/drafts/draft-deviation-*.md`

## Step 4: Diagram Alignment Review

For each flow diagram, trace through the diagram and verify the code:

### Tracing Method

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

### Deviation Categories

Report findings with these labels:

- `[DEVIATION: MISSING]` — Diagram shows X, code does not implement X
- `[DEVIATION: EXTRA]` — Code implements X, diagram does not show X
- `[DEVIATION: WRONG_ORDER]` — Code does A then B, diagram shows B then A
- `[DEVIATION: WRONG_BOUNDARY]` — Code puts X in Module A, diagram puts X in Module B
- `[DEVIATION: MISSING_ERROR_PATH]` — Diagram shows error path, code has no error handling
- `[DEVIATION: ALREADY_RECORDED]` — This deviation exists in a draft-deviation file (just note it, don't re-flag)

For each deviation, include:
- Severity: `[CRITICAL]` (wrong behavior), `[WARNING]` (risky shortcut), `[INFO]` (minor drift)
- Diagram reference: exact file and node name
- Code reference: exact file and line range
- Recommendation: fix the code, OR update the diagram

## Step 5: Code Quality Review

Review the code for quality independently of diagram alignment:

### Quality Dimensions

**Correctness**:
- Are there off-by-one errors, null pointer risks, or unhandled exceptions?
- Are all code paths reachable? Are there dead code blocks?
- Do the tests actually test what they claim to test?
- Are error messages meaningful and actionable?

**Simplicity**:
- Is there a simpler way to express this logic?
- Are there unnecessary abstractions or indirections?
- Is there duplicated logic that could be extracted?
- Are variable/function names clear and self-documenting?

**Maintainability**:
- Would a new team member understand this code in 6 months?
- Are complex algorithms or non-obvious decisions explained with comments?
- Is the function/method size appropriate, or does it need to be split?

**Consistency**:
- Does the code follow the patterns established in the rest of the codebase?
- Are naming conventions consistent with existing code?

### Quality Issue Severity

- `[CRITICAL]` — Will likely cause bugs in production
- `[WARNING]` — Technical debt that will cause problems as the codebase grows
- `[SUGGESTION]` — Minor improvement, take it or leave it

## Step 6: Generate Review Report

Output a structured two-part report:

```
GDD Code Review Report
======================
Date: <today>
Review scope: <files reviewed>
Diagrams compared: <list of diagram files>
Verdict: [APPROVED / APPROVED_WITH_WARNINGS / NEEDS_WORK]

══════════════════════════════════════════════
PART 1: DIAGRAM ALIGNMENT
══════════════════════════════════════════════

Diagram Compliance: PASS / PARTIAL / FAIL

## Critical Deviations (must fix)

[CRITICAL] [DEVIATION: MISSING_ERROR_PATH]
Diagram: flow-request.md → ErrorHandler → RetryQueue
Code: src/handlers/request.ts:45–67
Issue: The auth failure path sends a 401 response directly. The diagram
shows it should enqueue in RetryQueue for async retry.
Recommendation: Either implement the retry queue (fix code to match diagram),
or update flow-request.md to remove RetryQueue (fix diagram to match code).

## Warnings

[WARNING] [DEVIATION: WRONG_BOUNDARY]
Diagram: arch-modules.md shows UserService owning user validation logic
Code: src/handlers/auth.ts:23 imports and calls UserRepository.validateUser()
but arch-modules.md shows AuthHandler should call UserService, not UserRepository directly.
Recommendation: Add UserService as an intermediary, or update arch-modules.md.

## Informational

[INFO] [DEVIATION: ALREADY_RECORDED]
docs/gdd/drafts/draft-deviation-<timestamp>.md records the RetryQueue deviation.
This is consistent with the deviation record.

## Diagram Updates Needed

Based on this review, the following diagrams should be updated via /gdd:plan:
- flow-request.md: Remove RetryQueue node (if code approach is correct)

══════════════════════════════════════════════
PART 2: CODE QUALITY
══════════════════════════════════════════════

## Critical Issues (likely bugs)

[CRITICAL] [CORRECTNESS]
File: src/handlers/auth.ts:78
Issue: `token.expiresAt` is compared without timezone normalization.
If the server runs in UTC but the token was issued in UTC+8, this comparison
will fail for 8 hours of valid tokens.
Recommendation: Use `Date.UTC()` or a timezone-aware comparison.

## Warnings (technical debt)

[WARNING] [SIMPLICITY]
File: src/services/user.ts:120–145
Issue: The 26-line validation function can be replaced by a single Zod schema parse.
The current implementation is harder to maintain and misses some edge cases.
Recommendation: Extract to a Zod schema at src/schemas/user.ts.

## Suggestions

[SUGGESTION] [NAMING]
File: src/handlers/auth.ts:34
Issue: Variable `t` is used for the token. `token` or `accessToken` would be clearer.

══════════════════════════════════════════════
SUMMARY
══════════════════════════════════════════════

Diagram Alignment: 1 critical, 1 warning, 1 info
Code Quality: 1 critical, 1 warning, 1 suggestion

Verdict: NEEDS_WORK

Recommended actions:
1. Fix the timezone comparison bug (Code Quality Critical #1)
2. Decide: implement RetryQueue or update flow-request.md (Diagram Critical #1)
3. Fix the UserService boundary violation (Diagram Warning #1)
4. Consider the Zod schema refactor (Code Quality Warning #1)

After fixing critical items, run /gdd:code-review again.
If diagram updates are needed, run /gdd:plan first.
```

**Verdict definitions:**
- `APPROVED` — No critical issues in either dimension
- `APPROVED_WITH_WARNINGS` — No critical issues, but has warnings worth addressing
- `NEEDS_WORK` — Has at least one critical issue in either dimension

</process>

<guidelines>
- Be concrete: cite exact file paths and line numbers for every finding
- For each diagram deviation, make a clear recommendation: fix the code OR fix the diagram — not both vaguely
- Do not flag diagram deviations that are already in deviation record files unless the implementation is still wrong
- The quality review should focus on real issues, not style preferences
- A "SUGGESTION" that requires major refactoring is better reported as a [WARNING] — match severity to actual impact
- When the code is correct but the diagram is outdated, recommend a diagram update via /gdd:plan, not a code revert
- If everything looks good, say so clearly — an empty critical section with a confident APPROVED verdict is a valuable outcome
</guidelines>
