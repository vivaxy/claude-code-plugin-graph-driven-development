---
name: cadence:main:doc-writing
description: Execute the doc-writing procedure — outline, write, and review documentation
argument-hint: "<document description or topic>"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

<objective>
Produce clear, accurate documentation by following an outline → write → review procedure. Never write prose before the outline is confirmed.
</objective>

<process>

## Step 1: Read the Clarification

Use the clarification summary from the current conversation context to understand what document is being written, its audience, scope, and success criteria. If no clarification has been established yet, invoke `cadence:main:clarify` first.

## Step 2: Locate Existing Content

Before writing anything new:

- Search for existing documentation on this topic (README files, `docs/`, inline comments)
- Identify content that can be reused, updated, or referenced
- Note any gaps between what exists and what the clarification requires

## Step 3: Outline

Draft a document outline and present it to the user:

- Top-level sections with one-line descriptions of what each covers
- Note any sections that require reading source code or external references to fill accurately

Ask: "Does this outline cover what you need, or should any sections be added, removed, or reordered?"

Incorporate feedback before proceeding.

## Step 4: Write

Write the document section by section:

- Read source code, existing docs, or other references as needed for accuracy — never invent facts
- Use clear, direct language — no filler phrases ("it is important to note that…")
- Code examples must be correct and runnable
- Cross-link to related documents where helpful

## Step 5: Review

Self-review before presenting to the user:

- Does every section match the outline that was approved?
- Are all code examples syntactically correct?
- Are all claims accurate (verified against source code or existing docs)?
- Is the document complete relative to the success criteria in the clarification summary?

Present the finished document to the user and ask: "Does this cover everything, or are there sections to expand or adjust?"

Incorporate final feedback.

Output: "Document complete. Saved to `<path>`."

</process>

<guidelines>
- Outline must be confirmed before writing — never skip this step
- Accuracy over completeness: a short accurate doc is better than a long inaccurate one
- If writing about code, read the actual code — do not rely on memory or assumptions
- If the scope expands significantly during writing, pause and re-confirm with the user
</guidelines>
