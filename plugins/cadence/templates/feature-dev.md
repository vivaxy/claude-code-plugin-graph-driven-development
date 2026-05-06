# Feature Development Session

> Session type: feature-dev. Use when the request adds new behavior, a new API endpoint, a new component, a structural refactor, or documentation work. Routing flows clarify → plan → implement → review → deliver.

## Clarification

- [ ] Probe technical unknowns and ask clarifying questions until scope, constraints, and success criteria are clear
- [ ] Confirm understanding with the user
- [ ] Write the clarification body and session-type hint into `session.md` and return the terminal handoff line

## Plan

### Context

<TODO: filled by plan agent>

### Key Decisions

<TODO: filled by plan agent>

### Docs to Change

<TODO: filled by plan agent>

### Source Code to Change

<TODO: filled by plan agent>

### Tests to Change

<TODO: filled by plan agent>

### What Does Not Change

<TODO: filled by plan agent>

### Implementation Steps

<TODO: filled by plan agent>

### Verification

<TODO: filled by plan agent>

### Summary

<TODO: filled by plan agent>

### Procedural Checklist

- [ ] Read `## Clarification` (and `## Analysis` when present); identify which `docs/` diagrams need creation or update under C4 level criteria
- [ ] Draft the plan body and get user approval via `EnterPlanMode` / `ExitPlanMode` (the body shown to the user equals the body persisted to `## Plan`)
- [ ] On approval, write the plan body into `## Plan` of `session.md`, copy each `### Implementation Steps` entry into `## Implementation` as `- [ ]` work items, and tick this checklist
- [ ] On rejection, run the NEEDS_CLARIFICATION handoff (see `agents/plan.md`)
- [ ] Return the terminal handoff line

## Implementation

### Work Items

<filled by plan agent — one `- [ ]` item per implementation step>

## Review

- [ ] Read `session.md` end-to-end and launch all checks concurrently (tests, `check` subagent for success criteria, `verify` for docs-alignment + plan-alignment + bugfix-regression when reproduction steps exist, `code-review` on staged changes)
- [ ] Assign verdict (`ship`, `revise`, or `block`) per the thresholds in `agents/review.md`
- [ ] Write the review body into `## Review` and return the terminal handoff line

## Delivery

- [ ] Read `session.md` end-to-end (including `## Review` verdict) and `git log --oneline -20`
- [ ] Compose the Retrospective and Final Summary; offer to persist Learnings and Open Items per `agents/deliver.md`
- [ ] Write both bodies into `## Delivery` and return the terminal handoff line
