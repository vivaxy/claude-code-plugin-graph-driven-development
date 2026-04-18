---
name: vivaxy-workflow:main:clarify
description: Clarify the problem with the user before decomposing into subtasks — asks focused questions and writes docs/doc-clarification.md
argument-hint: "<feature or problem description>"
allowed-tools:
  - Read
  - Write
  - Glob
---

<objective>
Understand the feature or problem clearly enough to decompose it into subtasks. Ask focused questions, confirm understanding, and write `docs/doc-clarification.md` as the authoritative problem statement for all downstream skills.
</objective>

<process>

## Step 1: Check for Existing Clarification

Check if `docs/doc-clarification.md` already exists:
- If it exists, read it and summarize the current problem statement to the user. Ask if it's still accurate or needs updating.
- If it does not exist, proceed to Step 2.

## Step 2: Understand the Initial Request

The initial description is in `$ARGUMENTS`. If `$ARGUMENTS` is empty, ask the user to describe the feature or problem in one sentence.

Assess what is already clear and what is ambiguous:
- **Scope**: What is in scope? What is explicitly out of scope?
- **Constraints**: Technical, time, or resource constraints?
- **Success criteria**: How will we know this is done?
- **Non-goals**: What should this NOT do?

## Step 3: Ask Clarifying Questions

Ask one or two focused questions at a time — never dump all questions at once. Wait for the user's answer before asking the next question.

Focus on the most important unknowns first. Stop asking when you can confidently write a problem statement that covers scope, constraints, and success criteria.

Good clarifying questions:
- "What does success look like for this feature?"
- "Are there any existing systems or APIs this must integrate with?"
- "Is there anything this should explicitly NOT do?"
- "Who are the users of this feature?"

## Step 4: Confirm Understanding

Summarize your understanding back to the user in plain language:
- What is being built
- Key constraints
- Success criteria
- What is out of scope

Ask: "Does this capture it correctly, or is there anything to adjust?"

Incorporate any corrections and re-confirm if needed.

## Step 5: Write docs/doc-clarification.md

Once the user confirms, create `docs/` if it does not exist, then write `docs/doc-clarification.md`:

```markdown
# Problem Clarification

> **Type**: Clarification
> **Last Updated**: YYYY-MM-DD
> **Covers**: One-line description of the feature/problem

## Problem Statement

<What is being built and why>

## Scope

### In Scope
- Item 1
- Item 2

### Out of Scope
- Item 1

## Constraints

- Constraint 1
- Constraint 2

## Success Criteria

- Criterion 1 (measurable)
- Criterion 2 (measurable)

## Non-Goals

- Non-goal 1
```

Output: "Problem clarified and saved to `docs/doc-clarification.md`. Run `vivaxy-workflow:main:plan` to decompose into subtasks."

</process>

<guidelines>
- Ask one or two questions at a time — iterative dialogue, not an interrogation dump
- Success criteria must be measurable, not vague ("users can log in" not "authentication works")
- Never write `doc-clarification.md` until the user has confirmed the summary
- If the user says "just proceed" or "skip clarification", write a minimal `doc-clarification.md` from what you know and proceed
</guidelines>
