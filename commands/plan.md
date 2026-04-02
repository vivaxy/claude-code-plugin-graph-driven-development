---
name: gdd:plan
description: Plan a new requirement — update flowcharts and architecture diagrams to reflect the proposed changes, with user confirmation before writing
argument-hint: "<requirement description>"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - TodoWrite
---

<objective>
For a given requirement or feature request, analyze the existing GDD diagrams and produce a proposal showing exactly how the diagrams need to change. Present the proposal to the user for confirmation, then directly write the approved changes to `docs/gdd/`.

The core principle: **diagrams change first, code follows**.
</objective>

<process>

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

## Step 5: Present Proposal and Wait for Confirmation

Output the full proposal in the conversation using this structure:

```
## Proposed Diagram Changes

**Requirement**: <one-line summary>
**Affects**:
- flow-request.md (major update)
- arch-modules.md (minor update)

### Requirement Summary

<2–4 sentences describing what the requirement entails and why it's needed>

### Impact Analysis

<Brief explanation of what changes are needed and why>

---

### [Modifying] flow-request.md

**Change type**: Major update
**Reason**: <Why this change is needed>

#### Before

\`\`\`mermaid
<full current diagram content>
\`\`\`

#### After (Proposed)

\`\`\`mermaid
<full proposed diagram content>
\`\`\`

#### What Changed

- Added node X to represent Y
- New edge from A to B because Z
- Renamed C to D for clarity

---

### [New File] flow-auth.md

**Reason**: <Why a new diagram is needed>

#### Proposed Diagram

\`\`\`mermaid
<full new diagram content>
\`\`\`

#### Key Decisions

- Decision 1: rationale
- Decision 2: rationale

---

### Design Considerations

<Any trade-offs, alternatives considered, or open questions the user should think about>
```

Then ask:
```
Please review the proposed diagram changes above.

Reply with:
- "yes" or "confirm" to apply the changes directly to docs/gdd/
- Any feedback or corrections to revise the proposal
```

**Wait for user confirmation before proceeding.**

## Step 6: Apply Confirmed Changes

Once the user confirms, directly write all changes to `docs/gdd/`:

1. For each "Modifying" entry: replace the diagram content in the actual file with the "After (Proposed)" content, update the "Last Updated" date
2. For each "New File" entry: create the new file in `docs/gdd/` using the standard diagram file format

Output confirmation:
```
Changes applied to docs/gdd/:

- Updated: flow-request.md
- Created: flow-auth.md

Starting automated diagram review...
```

## Step 7: Automated Subagent Review Loop

After applying the changes, immediately run a full diagram review as a subagent. Repeat until the verdict is `APPROVED` or `APPROVED_WITH_WARNINGS`.

### Review Logic (run as subagent)

Perform the following review checks on the diagrams that were just written. This is identical to the full `gdd:plan-review` logic:

**Scope**: The diagram files modified or created in Step 6.

**Review Dimensions**:

#### 7a. Completeness Check

- Does every major external interaction have a flow diagram?
- Does every top-level module/service appear in at least one architecture diagram?
- Are all error paths, failure modes, and edge cases represented?
- Are all state transitions captured?

For each gap: `[SEVERITY] [COMPLETENESS] <description> — Suggestion: add <X> to <diagram>`

#### 7b. Consistency Check

- Do the same entities appear with the same names across all diagrams?
- Do flow diagrams agree with architecture diagrams about which module owns each step?
- Are there contradictions between diagrams?
- Do "Key Decisions" in related diagrams contradict each other?

For each inconsistency: `[SEVERITY] [CONSISTENCY] <description> — Found in: <file1> vs <file2>`

#### 7c. Boundary and Edge Case Check

- What happens when a user provides invalid input?
- What happens when an external service is unavailable?
- What happens when a database operation fails?
- Are timeout/retry behaviors captured where relevant?
- Are authentication/authorization boundaries clear?

For each missing edge case: `[SEVERITY] [EDGE_CASE] <scenario> — Impact: <what could go wrong>`

#### 7d. Feasibility and Design Quality Check

- Does any part of the design seem overly complex?
- Does the design introduce tight coupling between modules that should be independent?
- Are there circular dependencies in the architecture diagram?
- Is the separation of concerns clear?

For each concern: `[SEVERITY] [FEASIBILITY] <concern> — Consider: <alternative>`

#### 7e. Mermaid Syntax Sanity Check

- Are all node IDs valid (no special characters, no spaces)?
- Are all referenced nodes actually defined in the same diagram?
- Do flow directions make sense?

For each issue: `[WARNING] [SYNTAX] <description>`

### Review Verdict

Assign one of:
- `APPROVED` — No critical issues, no warnings
- `APPROVED_WITH_WARNINGS` — No critical issues, but has warnings
- `NEEDS_WORK` — Has at least one critical issue; main agent must fix before proceeding
- `BLOCKED` — Fundamental design problem; main agent must rethink the approach

### Fix-and-Retry Loop

**If verdict is `NEEDS_WORK` or `BLOCKED`**:

1. Output the full review report
2. As the main agent, fix all `[CRITICAL]` issues directly in the `docs/gdd/` files (update diagrams to address the problems identified)
3. Go back to the subagent review and run it again
4. Repeat until verdict is `APPROVED` or `APPROVED_WITH_WARNINGS`

**If verdict is `APPROVED` or `APPROVED_WITH_WARNINGS`**:

Output the final summary:
```
GDD Plan Review: APPROVED [/ APPROVED_WITH_WARNINGS]

Files reviewed: flow-request.md, arch-modules.md (...)
Issues found: N critical (fixed), N warnings, N suggestions

<If APPROVED_WITH_WARNINGS, list the warnings here>

Ready to implement. Run /gdd:code to begin implementation.
```

## Step 8: Write Todo List

After diagrams are approved, generate a concrete implementation todo list and write it to `docs/gdd/todos.md`.

Each todo item must be derived from the approved diagram changes — one item per distinct implementation task (e.g., one per new module, one per new API endpoint, one per new flow path).

Format each item as:

```
- [ ] <short task title> — <diagram reference, e.g. flow-request.md → NewNode>
```

Write the full block to `docs/gdd/todos.md`:

```markdown
## <Requirement summary, one line> — <YYYY-MM-DD>

- [ ] Task 1 — <diagram ref>
- [ ] Task 2 — <diagram ref>
...
```

If `docs/gdd/todos.md` does not exist, create it. If it already exists, append the new block at the bottom.

Output confirmation:
```
Todo list written to docs/gdd/todos.md (N items).

Run /gdd:code to implement the first task.
```

</process>

<guidelines>
- The proposal must be self-contained: a reader who hasn't seen the requirement should understand exactly what is changing and why
- Directly write to docs/gdd/ only after explicit user confirmation
- Proposed diagrams must be syntactically valid Mermaid — test mentally by reading the graph structure
- If a requirement is too large (affects > 5 diagrams), consider splitting into sub-requirements
- "Before" sections must be copied verbatim from the actual current diagram files — never paraphrase
</guidelines>
