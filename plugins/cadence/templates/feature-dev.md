# Feature Development Session

> Session type: feature-dev. Use when the request adds new behavior, a new API endpoint, a new component, a structural refactor, or documentation work. Routing flows clarify → plan → implement → review → deliver.

## CheckList

### Clarification

- [ ] Probe technical unknowns and ask clarifying questions until scope, constraints, and success criteria are clear
- [ ] Confirm understanding with the user
- [ ] Write the clarification body and session-type hint into `session.md` and return the terminal handoff line

### Plan

- [ ] Read `## Clarification` (and `## Analysis` when present); identify which `docs/` diagrams need creation or update under C4 level criteria
- [ ] Draft the plan body and get user approval via `EnterPlanMode` / `ExitPlanMode` (the body shown to the user equals the body persisted to `## Plan`)
- [ ] On approval, replace every `<!-- TODO: filled by plan agent -->` placeholder under `## Plan` with the drafted content, populate `### Implementation` under `## CheckList` with one `- [ ]` work item per implementation step, and tick this sub-section
- [ ] On rejection, run the NEEDS_CLARIFICATION handoff (see `agents/plan.md`)
- [ ] Return the terminal handoff line

### Implementation

- [ ] Verify all requirements in context are satisfied: check compliance with user-level `~/.claude/CLAUDE.md`, project-level `CLAUDE.md`, and any preconditions stated earlier in the conversation

<!-- populated by plan agent — one `- [ ]` item per implementation step; implement agent ticks each item and adds `Files touched` / `Verification` sub-bullets -->

### Review

- [ ] Read `session.md` end-to-end and launch all checks concurrently (tests, `check` subagent for success criteria, `verify` for docs-alignment + plan-alignment, `code-review` on staged changes)
- [ ] Assign verdict (`ship`, `revise`, or `block`) per the thresholds in `agents/review.md`
- [ ] Replace every `<!-- TODO: filled by review agent -->` placeholder under `## Review` with the drafted content, tick this sub-section, and return the terminal handoff line

### Delivery

- [ ] Read `session.md` end-to-end (including `## Review` verdict) and `git log --oneline -20`
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

## Plan

### Context

<!-- TODO: filled by plan agent -->

### Key Decisions

<!-- TODO: filled by plan agent -->

### Docs to Change

<!-- TODO: filled by plan agent -->

### Source Code to Change

<!-- TODO: filled by plan agent -->

### Tests to Change

<!-- TODO: filled by plan agent -->

### What Does Not Change

<!-- TODO: filled by plan agent -->

### Implementation Steps

<!-- TODO: filled by plan agent -->

### Verification

<!-- TODO: filled by plan agent -->

### Summary

<!-- TODO: filled by plan agent -->

## Review

### Verdict

<!-- TODO: filled by review agent — `ship` | `revise` | `block` -->

### Test Suite

<!-- TODO: filled by review agent — `<N> tests passing, <N> failing` -->

### Success Criteria

<!-- TODO: filled by review agent — table with one row per criterion, Result is SATISFIED | NOT_SATISFIED | UNTESTED -->

### Docs Alignment

<!-- TODO: filled by review agent — `PASS` | `PASS_WITH_WARNINGS` | `FAIL` plus findings or "No issues found." -->

### Plan Alignment

<!-- TODO: filled by review agent — `PASS` | `PASS_WITH_WARNINGS` | `FAIL` plus findings or "No issues found." -->

### Code Review

<!-- TODO: filled by review agent — `APPROVED` | `APPROVED_WITH_NOTES` | `NEEDS_WORK` plus findings or "No issues found." -->

### Deviations

<!-- TODO: filled by review agent — `none` or list of unresolved deviations -->

### Warnings

<!-- TODO: filled by review agent — `none` or list of warnings -->

### Summary

<!-- TODO: filled by review agent — 1–2 sentences -->

## Delivery

### Retrospective

#### What Was Built

<!-- TODO: filled by deliver agent — 2–3 sentences -->

#### Files Changed

<!-- TODO: filled by deliver agent — key files modified or created -->

#### Deviations

<!-- TODO: filled by deliver agent — bullet list, or "None." -->

#### What Went Well

<!-- TODO: filled by deliver agent — bullet list -->

#### What Went Wrong

<!-- TODO: filled by deliver agent — bullet list, or "None." -->

#### Learnings

<!-- TODO: filled by deliver agent — bullet list -->

#### Open Items

<!-- TODO: filled by deliver agent — `None.` or bullet list -->
