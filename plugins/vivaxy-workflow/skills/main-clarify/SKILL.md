---
name: vivaxy-workflow:main:clarify
description: Clarify the problem with the user before decomposing into subtasks — asks focused questions and confirms understanding in conversation
argument-hint: "<feature or problem description>"
allowed-tools:
  - Read
  - Glob
---

<objective>
Understand the feature or problem clearly enough to decompose it into subtasks. Ask focused questions and confirm understanding through conversation. Do NOT write any files — clarification lives in the conversation only.
</objective>

<process>

## Step 1: Check for Existing Clarification

Check if a clarification summary has already been established earlier in the current conversation:
- If it has, summarize the current problem statement to the user. Ask if it's still accurate or needs updating.
- If it has not, proceed to Step 2.

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

## Step 5: Detect Session Type

Before writing the doc, infer the session type from the clarified content:

| Signal in the clarified problem | Session Type |
|---|---|
| Adds new behavior, new API endpoint, new component, refactor of module structure | `feature-dev` |
| Something is broken, defect, regression, error, "it used to work" | `bugfix` |
| Writing or updating documentation, README, guides, specs, changelogs | `doc-writing` |
| Designing a system, exploring options, modeling, architecture decision, no immediate coding | `architecture` |

State the inferred type to the user: "I'm classifying this as a `<type>` session. Does that sound right?"

If the user corrects it, use their correction.

## Step 6: Confirm and Hand Off

Once the user confirms, output a concise summary in conversation:

- **Problem**: one-line statement
- **In Scope**: bullet list
- **Out of Scope**: bullet list
- **Constraints**: bullet list
- **Success Criteria**: measurable bullet list
- **Non-Goals**: bullet list
- **Session Type**: `<type>`

Output: "Problem clarified. Ready to proceed with `vivaxy-workflow:main:plan`."

</process>

<guidelines>
- Ask one or two questions at a time — iterative dialogue, not an interrogation dump
- Success criteria must be measurable, not vague ("users can log in" not "authentication works")
- Never output the final summary until the user has confirmed the understanding
- If the user says "just proceed" or "skip clarification", output a minimal summary from what you know and proceed
</guidelines>
