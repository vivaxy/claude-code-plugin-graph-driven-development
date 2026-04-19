---
name: cadence:main:deliver
description: Retrospective, consolidate learnings, and deliver final results — outputs retrospective to conversation, summarizes what was built
allowed-tools:
  - Read
  - Glob
  - Bash
---

<objective>
Close out a completed feature: output a retrospective capturing what was built, how the process went, and any learnings. Deliver a final summary to the user.
</objective>

<process>

## Step 1: Gather Delivery Materials

Read in parallel:
- Clarification summary from the current conversation context — original problem and success criteria
- Deviation records from the current conversation context
- Git log for the feature (use Bash: `git log --oneline -20`)

## Step 2: Output Retrospective

Output the retrospective to the conversation:

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

## Step 3: Deliver Final Summary

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

</process>
