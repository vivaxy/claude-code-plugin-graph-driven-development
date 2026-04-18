---
name: vivaxy-workflow:main:deliver
description: Retrospective, consolidate learnings, and deliver final results — writes doc-retrospective, cleans up drafts, summarizes what was built
allowed-tools:
  - Read
  - Write
  - Glob
  - Bash
---

<objective>
Close out a completed feature: write a retrospective document capturing what was built, how the process went, and any learnings. Clean up resolved deviation drafts. Deliver a final summary to the user.
</objective>

<process>

## Step 1: Verify Feature Is Accepted

Read `docs/doc-subtasks.md`. Confirm all subtasks have status ACCEPTED.

If not all subtasks are ACCEPTED, stop and output:
```
Feature is not yet accepted. Run `vivaxy-workflow:main:review` first.
```

## Step 2: Gather Delivery Materials

Read in parallel:
- `docs/doc-clarification.md` — original problem and success criteria
- `docs/doc-subtasks.md` — all subtasks and their status
- All `docs/drafts/draft-deviation-*.md` files
- Git log for the feature (use Bash: `git log --oneline -20`)

## Step 3: Write Retrospective

Write `docs/doc-retrospective-<YYYY-MM-DD>.md`:

```markdown
# Retrospective: <feature name>

> **Type**: Retrospective
> **Date**: YYYY-MM-DD
> **Feature**: <one-line description from clarification>

## What Was Built

<2-3 sentence summary of the feature>

### Files Changed

<list of key files modified or created>

## Subtask Summary

| ID | Title | Notes |
|----|-------|-------|
| ST-01 | <title> | <any rework or deviations> |

**Total subtasks**: N
**Subtasks requiring rework**: N

## Deviations

<List each deviation: what was planned vs. what was built and why. If none, write "None.">

## Learnings

<What went well, what was harder than expected, process improvements for next time>

## Open Items

<Any follow-up tasks, known limitations, or future improvements. If none, write "None.">
```

## Step 4: Clean Up Deviation Drafts

Move resolved deviation draft files from `docs/drafts/` to `docs/drafts/resolved/` using Bash:
```bash
mkdir -p docs/drafts/resolved
mv docs/drafts/draft-deviation-*.md docs/drafts/resolved/ 2>/dev/null || true
```

## Step 5: Deliver Final Summary

Output the final delivery summary to the user:

```
## Delivery Summary: <feature name>

**Built**: <one-line description>
**Subtasks**: N completed
**Tests**: all passing
**Retrospective**: docs/doc-retrospective-<date>.md

### What Was Built
<2-3 sentences>

### Files Changed
<key files>

### Open Items
<none | list>

Workflow complete.
```

</process>
