---
name: gdd:plan
description: Plan a new requirement — update flowcharts and architecture diagrams to reflect the proposed changes, with user confirmation before writing
argument-hint: "<requirement description>"
allowed-tools:
  - Read
  - Glob
  - Grep
  - EnterPlanMode
  - ExitPlanMode
  - Agent
---

<objective>
For a given requirement or feature request, analyze the existing GDD diagrams and produce a proposal showing exactly how the diagrams need to change. Enter plan mode to do all exploration and design work, then call ExitPlanMode to present the full Before/After diagram diffs for user approval.

The core principle: **diagrams change first, code follows**. This command is read-only — it proposes changes but does not write any files. After approval, run `/gdd:code` to apply the diagram changes and implement the feature.
</objective>

<process>

## Preamble: Enter Plan Mode

Call `EnterPlanMode` immediately when this command starts. All steps below are read-only exploration and analysis. Do not write any files.

## Step 1: GDD Completeness Check

Before doing anything else, verify that GDD is properly initialized:

1. Check if `docs/gdd/` directory exists
2. Check if at least one `flow-*.md` file exists in `docs/gdd/`
3. Check if at least one `arch-*.md` file exists in `docs/gdd/`

**If any of checks 1–3 fail:**
```
GDD is not initialized for this project.

Please run /gdd:init first to generate the initial diagram set,
then return to /gdd:plan for your requirement.
```
STOP — do not proceed.

## Step 2: Read Current Diagrams

Read all files in `docs/gdd/` (excluding `drafts/`):
- `overview.md`
- All `flow-*.md` files
- All `arch-*.md` files

Build a mental model of the current system design.

## Step 3: Understand the Requirement

The requirement is provided as `$ARGUMENTS`. If it's too brief or ambiguous:
- Ask one focused clarifying question
- Do not ask multiple questions at once
- If the requirement is clear enough, proceed

## Step 3.5: DDD Domain Analysis (conditional)

Skip this step if the requirement is clearly single-domain (a UI change, a config update, a bug fix, or a change confined to one existing module). Proceed to Step 4.

Run this step if the requirement:
- Mentions two or more system areas (e.g., "orders and inventory", "user profile and notifications")
- Introduces a new entity with its own lifecycle
- Crosses an existing architectural boundary visible in `arch-*.md` diagrams
- Adds a new integration with an external system

**If running this step, identify:**

1. **Bounded Contexts** — What are the distinct domains involved? Name each one with a noun phrase (e.g., "Order Management", "Payment Processing"). A bounded context is a self-contained area of the system with its own language and rules.

2. **Aggregates** — Within each context, what is the root entity that owns consistency? (e.g., `Order`, `User`, `Invoice`). List the aggregate root for each context touched by this requirement.

3. **Entities and Value Objects** — What data objects appear in the requirement? Classify each as:
   - *Entity*: has identity that persists across time (e.g., `Order`, `Customer`)
   - *Value Object*: defined purely by its attributes, no identity (e.g., `Money`, `Address`, `DateRange`)

4. **Context Relationships** — How do the bounded contexts interact?
   - *Shared Kernel*: two contexts share a subset of the domain model
   - *Customer/Supplier*: one context depends on outputs from another
   - *Anti-Corruption Layer*: one context must translate another's model
   - *Conformist*: one context simply adopts another's model as-is

5. **New diagram needed?** — Answer yes if two or more bounded contexts are involved AND no `arch-ddd-contexts.md` file exists (or the existing one does not show these contexts). Answer no otherwise.

**Produce an internal DDD summary (used in Steps 4 and 5, not output to user yet):**

```
DDD Analysis:
- Contexts involved: <list>
- Aggregates: <context> → <aggregate root>
- Key entities: <list>
- Key value objects: <list>
- Context relationships: <type> between <A> and <B>
- New DDD diagram needed: yes/no
```

## Step 4: Impact Analysis

Analyze which diagrams are affected by this requirement:

For each existing diagram, determine:
- **No change needed**: requirement has no impact
- **Minor update**: add/rename a node, add an edge
- **Major update**: new subgraph, new flow path, new module
- **New diagram needed**: entirely new flow or architecture area

Also determine if:
- New `flow-*.md` files need to be created
- New `arch-*.md` files need to be created
- A new `arch-ddd-contexts.md` file needs to be created (only if Step 3.5 concluded "New DDD diagram needed: yes")

## Step 5: Call ExitPlanMode with Full Diagram Diffs

Compose the full diagram changes and call ExitPlanMode with the complete proposal. The plan content must include:

```
## Proposed Diagram Changes

**Requirement**: <one-line summary>

**Affects**:
- flow-request.md (major update) — <one-line reason>
- arch-modules.md (minor update) — <one-line reason>

**Summary**: <2–3 sentences describing what changes and why>

---

### Modifying: <filename.md>

**Change type**: Major update / Minor update
**Reason**: <Why this change is needed>

#### Before

\`\`\`mermaid
<full current diagram content — copied verbatim from file>
\`\`\`

#### After

\`\`\`mermaid
<full proposed diagram content>
\`\`\`

#### What Changed

- Added node X to represent Y
- New edge from A to B because Z

---

### New File: <filename.md>

**Reason**: <Why a new diagram is needed>

#### Proposed Diagram

\`\`\`mermaid
<full new diagram content>
\`\`\`

#### Key Decisions

- Decision 1: rationale

---

## Design Considerations

<Any trade-offs, alternatives considered, or open questions>
```

After the user approves this plan, run `/gdd:code` to apply the diagram changes and implement the feature.

</process>

<guidelines>
- "Before" sections must be copied verbatim from the actual current diagram files — never paraphrase
- Proposed diagrams must be syntactically valid Mermaid — test mentally by reading the graph structure
- If a requirement is too large (affects > 5 diagrams), consider splitting into sub-requirements
- This command is read-only — no files are written. All changes are applied by `/gdd:code`
</guidelines>
