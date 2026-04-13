---
name: analyze:using-analyze
description: Guide for when to suggest the analyze plugin — read at session start to understand when /analyze:problem and /analyze:model are appropriate
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

# Using the Analyze Plugin

The `analyze` plugin provides structured problem analysis. It is an on-demand tool — suggest it when the user's question would benefit from rigorous decomposition or visual modeling.

## When to Suggest /analyze:problem

Suggest `/analyze:problem` when the user:
- Presents a vague, complex, or multi-layered problem ("why is X happening?", "how should I approach Y?")
- Is reasoning by analogy ("everyone does it this way, should we?") — first-principles thinking would help
- Has a problem with unclear root cause (symptoms are visible but causes are not)
- Needs to make an important decision with many trade-offs
- Is stuck and not sure where to start

Do **not** suggest it for:
- Simple factual questions with clear answers
- Requests to implement a specific, well-defined task
- Cases where the user has already done the analysis and just needs execution

## When to Suggest /analyze:model

Suggest `/analyze:model` when the user:
- Wants to understand how a domain, system, or codebase is structured
- Is onboarding to a new area and needs a map
- Needs to communicate a concept visually (to themselves or others)
- Is designing something and wants to see the entities and relationships before writing code

## How to Suggest

Keep it lightweight — one sentence, then proceed:

> "This looks like a good case for `/analyze:problem` — want me to run a structured analysis?"

Or, if the user seems to want an immediate answer, just proceed normally. Never force the suggestion.

If the user says "just answer it" or "skip the analysis" — respect that immediately.

## Instruction Priority

1. User's explicit instructions — highest
2. Analyze plugin suggestions — for complex, unclear, or high-stakes problems
3. Default behavior — for everything else
