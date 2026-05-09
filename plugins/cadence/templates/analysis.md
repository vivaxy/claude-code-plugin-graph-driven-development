# Analysis Session

> Session type: analysis. Use when the request is to investigate a multi-layered problem, surface root causes, and hand off findings without implementing a fix. Routing flows clarify → analyze-problem → deliver.

## CheckList

### Clarification

- [ ] Probe technical unknowns and ask clarifying questions until scope, constraints, and success criteria are clear
- [ ] Evaluate whether the user's stated requirement is the most appropriate approach, grounded in probe findings and factual evidence — not intuition alone; when a clearly better approach exists, always use `AskUserQuestion` to present the alternative with its rationale and let the user decide, then proceed silently when no better approach is found
- [ ] Confirm understanding with the user
- [ ] Write the clarification body and session-type hint into `session.md` and return the terminal handoff line

### Analysis

- [ ] Restate the problem and collect facts (Verified / Challenged Assumptions / Hard Constraints / Evidence Gaps)
- [ ] Decompose into MECE sub-problems, trace root causes, build a Mermaid model, derive 3–7 Key Questions
- [ ] Replace every `<!-- TODO: filled by analyze-problem agent -->` placeholder under `## Analysis` with the drafted content, tick this sub-section, and return the terminal handoff line

### Delivery

- [ ] Verify all requirements in context are satisfied: check compliance with user-level `~/.claude/CLAUDE.md`, project-level `CLAUDE.md`, and any preconditions stated earlier in the conversation
- [ ] Read `session.md` end-to-end (including `## Analysis` findings) and `git log --oneline -20`
- [ ] Compose the Retrospective body and the conversational Final Summary; offer to persist Learnings and Open Items per `agents/deliver.md`
- [ ] Replace every `<!-- TODO: filled by deliver agent -->` placeholder under `## Delivery` with the drafted Retrospective content, tick this sub-section, and return the terminal handoff line carrying the Final Summary inline

## Clarification

### Problem

<!-- TODO: filled by clarify agent — one-line problem statement -->

### In Scope

<!-- TODO: filled by clarify agent — bullet list -->

### Out of Scope

<!-- TODO: filled by clarify agent — bullet list -->

### Constraints

<!-- TODO: filled by clarify agent — bullet list -->

### Success Criteria

<!-- TODO: filled by clarify agent — bullet list -->

## Analysis

### Problem Analysis

<!-- TODO: filled by analyze-problem agent — short title -->

### Restated Problem

<!-- TODO: filled by analyze-problem agent — one precise sentence covering Who, What, Where, When, and What is NOT the problem -->

### Facts

#### Verified Facts

<!-- TODO: filled by analyze-problem agent — `F1: <fact> — <source>` bullets -->

#### Challenged Assumptions

<!-- TODO: filled by analyze-problem agent — `A1: <assumption> — <what would confirm/refute>` bullets -->

#### Hard Constraints

<!-- TODO: filled by analyze-problem agent — `C1: <constraint>` bullets -->

#### Evidence Gaps

<!-- TODO: filled by analyze-problem agent — `G1: <gap> — <why it matters>` bullets -->

### Decomposition

<!-- TODO: filled by analyze-problem agent — MECE sub-problems with fact references -->

### Root Causes

<!-- TODO: filled by analyze-problem agent — causal chains with fact citations -->

### Visual Model

<!-- TODO: filled by analyze-problem agent — Mermaid diagram + brief legend -->

### Synthesis

<!-- TODO: filled by analyze-problem agent — interactions, emergent properties, core tension -->

### Key Questions

<!-- TODO: filled by analyze-problem agent — Q1..Qn ordered by priority, each with Targets / Unlocks / Type / Priority -->

## Delivery

### Retrospective

#### What Was Investigated

<!-- TODO: filled by deliver agent — 2–3 sentences -->

#### Files Read

<!-- TODO: filled by deliver agent — key files inspected during analysis -->

#### Deviations

<!-- TODO: filled by deliver agent — bullet list, or "None." -->

#### Learnings

<!-- TODO: filled by deliver agent — bullet list -->

#### Open Items

<!-- TODO: filled by deliver agent — `None.` or bullet list -->
