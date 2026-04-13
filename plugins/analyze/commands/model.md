---
name: analyze:model
description: Build a visual conceptual model of any topic, domain, or system — entities, relationships, and hierarchies as a Mermaid diagram
argument-hint: "<topic or domain to model>"
allowed-tools:
  - Read
  - Glob
  - Grep
  - WebSearch
---

<objective>
For the topic given in `$ARGUMENTS`, construct a clear visual conceptual model: identify the key entities, their attributes, and the relationships between them. Output a Mermaid diagram plus a concise written explanation of the structure.

The goal is understanding through structure — making implicit relationships explicit and visible.
</objective>

<process>

## Step 1: Scope the Topic

Identify the boundaries of what to model:
- What is the core subject?
- What is in scope vs. out of scope?
- What level of abstraction is appropriate (high-level overview vs. detailed)?

If the topic is ambiguous or too broad, narrow it to one coherent domain before proceeding.

If `$ARGUMENTS` refers to code in the current project, use Read/Glob/Grep to examine relevant files before modeling.

## Step 2: Identify Entities

List the key concepts, components, or actors in this domain. For each entity:
- **Name**: concise noun phrase
- **Role**: what it represents or does
- **Key attributes** (if relevant): 2–3 defining properties

Aim for 5–12 entities for a useful diagram. Too few loses detail; too many loses clarity.

## Step 3: Map Relationships

For each pair of entities that interact, define the relationship:
- **Type**: is-a, has-a, uses, depends-on, produces, triggers, contains, communicates-with
- **Direction**: unidirectional or bidirectional
- **Cardinality** (if applicable): one-to-one, one-to-many, many-to-many
- **Label**: a short verb phrase on the edge

## Step 4: Choose Diagram Type and Generate

Select the best Mermaid format:
- **`graph TD`** — component/system relationships (most common)
- **`mindmap`** — hierarchical breakdown of a concept
- **`classDiagram`** — object-oriented domain model with attributes and methods
- **`erDiagram`** — data entities with cardinalities (for data domains)

Generate the diagram. Use `<br>` for line breaks inside node labels. Ensure valid Mermaid syntax.

```mermaid
<diagram here>
```

## Step 5: Explain the Model

Write a brief explanation (3–6 bullet points) covering:
- The central entity or concept (the "anchor" of the model)
- The most important relationships
- Any non-obvious structural decisions
- Key boundaries or exclusions from the model

</process>

<output-format>

## Conceptual Model: <topic>

### Entities
| Entity | Role |
|--------|------|
| ... | ... |

### Diagram
```mermaid
...
```

### Key Relationships
- **A → B**: <what this relationship means>
- ...

### Notes
- <structural insight 1>
- <structural insight 2>

</output-format>

<guidelines>
- Prefer `graph TD` for system/component topics; `mindmap` for concept hierarchies; `classDiagram` for domain models
- Keep entity names concise — long labels make diagrams unreadable
- If the topic is in the current codebase, derive the model from actual code, not assumptions
- If `$ARGUMENTS` is empty, ask the user what topic or domain they want modeled
</guidelines>
