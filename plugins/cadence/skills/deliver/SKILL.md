---
name: cadence:deliver
description: Retrospective, consolidate learnings, and deliver final results — outputs retrospective to conversation, summarizes what was built
allowed-tools:
  - Read
  - Glob
  - Bash
  - Write
---

<objective>
Close out a completed feature: read all prior phase files from the session folder, write `deliver.md` to the session folder for the durable record, and output a retrospective + final delivery summary to the conversation.
</objective>

## Inputs (provided by the routing layer)

- Session folder absolute path (e.g., `<project>/.claude/sessions/YYYY-MM-DD-<slug>/`)

<process>

## Step 1: Gather Delivery Materials

Read in parallel from the session folder:
- `<session-folder>/clarify.md` — original problem, success criteria, session type
- `<session-folder>/analyze.md` (if it exists) — problem analysis findings
- `<session-folder>/plan.md` — plan and decisions
- All `<session-folder>/implement-step-*.md` files — what changed at each step (files touched, verification results, notes/deviations)
- `<session-folder>/review.md` — verdict and check results
- Git log: `git log --oneline -20`

Verify each file's frontmatter `status: complete`. If `review.md` verdict is `FEATURE_BLOCKED`, output a "Delivery Blocked" message to the conversation and stop — do not write `deliver.md`.

## Step 2: Compose Retrospective

Output the retrospective to the conversation (the same content will be persisted to `deliver.md` in Step 4):

```markdown
# Retrospective: <feature name>

> **Type**: Retrospective
> **Date**: YYYY-MM-DD
> **Feature**: <one-line description from clarification>

## What Was Built

<2-3 sentence summary of the feature>

### Files Changed

<list of key files modified or created>

## Deviations

<List each deviation: what was planned vs. what was built and why. If none, write "None.">

## Learnings

<What went well, what was harder than expected, process improvements for next time>

## Open Items

<Any follow-up tasks, known limitations, or future improvements. If none, write "None.">
```

## Step 3: Compose Final Summary

Output the final delivery summary to the user:

```
## Delivery Summary: <feature name>

**Built**: <one-line description>
**Tests**: all passing

### What Was Built
<2-3 sentences>

### Files Changed
<key files>

### Open Items
<none | list>

Workflow complete.
```

## Step 4: Write `deliver.md`

Use the `Write` tool to write `<session-folder>/deliver.md` with this exact structure:

```markdown
---
agent: deliver
session_type: <copied-from-clarify.md>
status: complete
verdict: <copied-from-review.md frontmatter>
created_at: <YYYY-MM-DD>
---

# Delivery: <feature name>

## Retrospective

<full retrospective body from Step 2>

## Final Summary

<full final-summary body from Step 3>
```

`<YYYY-MM-DD>` from `date -u +%Y-%m-%d`. `<session_type>` from `clarify.md` frontmatter. `<verdict>` from `review.md` frontmatter.

This is the durable record. The conversation output from Steps 2 and 3 remains the user-facing terminal message.

</process>
