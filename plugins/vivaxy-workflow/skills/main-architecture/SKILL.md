---
name: vivaxy-workflow:main:architecture
description: Execute the architecture procedure — analyze, model, design, and document an architectural decision or system design
argument-hint: "<system or decision description>"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - LSP
---

<objective>
Produce a well-reasoned architectural design by following an analyze → model → design doc → review procedure. Never jump to a solution before understanding the problem and trade-offs.
</objective>

<process>

## Step 1: Read the Clarification

Use the clarification summary from the current conversation context to understand the architectural question, constraints, and success criteria. If no clarification has been established yet, invoke `vivaxy-workflow:main:clarify` first.

## Step 2: Analyze

Understand the current state before proposing anything:

- Read relevant source files, existing architecture docs, and diagrams in `docs/`
- Identify the forces at play: performance, scalability, maintainability, team constraints, existing dependencies
- If the problem is complex or unclear, invoke `vivaxy-workflow:analyze:problem` for structured root-cause analysis
- State the core tension or decision in one sentence before proceeding

## Step 3: Model

Build a visual model of the proposed design:

- Choose the appropriate diagram type: flow (`flow-*.md`), architecture (`arch-*.md`), or DDD context map (`arch-ddd-*.md`)
- Use `vivaxy-workflow:analyze:model` if the domain relationships need careful mapping
- Draft the Mermaid diagram and present it to the user for review

Ask: "Does this model capture the intended design, or are there relationships or boundaries to adjust?"

Incorporate feedback.

## Step 4: Write Design Document

Write a prose design document (`docs/doc-<name>.md`) covering:

```markdown
# <Design Title>

> **Type**: Design Document
> **Last Updated**: YYYY-MM-DD
> **Covers**: One-line description

## Overview

What is being designed and why.

## Options Considered

For each option:
- **Option N**: Description
  - Pros: ...
  - Cons: ...

## Decision

Which option was chosen and why (reference the constraints from the clarification summary).

## Design

Detailed description with the Mermaid diagram (or reference to the diagram file).

## Open Questions

Any unresolved questions for later.
```

## Step 5: Review

Self-review before presenting:

- Does the decision address all constraints from the clarification summary?
- Are the trade-offs of rejected options documented?
- Is the diagram consistent with the prose?

Present the design doc and diagram to the user. Ask: "Does this decision and design look right, or are there trade-offs or constraints we haven't accounted for?"

Incorporate final feedback and save all files.

Output: "Architecture design complete. Design doc: `docs/doc-<name>.md`. Diagram: `docs/<type>-<name>.md`."

</process>

<guidelines>
- Never propose a solution before analyzing the current state and trade-offs
- Document rejected options — future readers need to understand why alternatives were not chosen
- If the architecture decision leads to significant implementation work, suggest switching to a `feature-dev` session after this one
- Diagrams must use `<br>` for line breaks inside node labels (not `\n`)
</guidelines>
