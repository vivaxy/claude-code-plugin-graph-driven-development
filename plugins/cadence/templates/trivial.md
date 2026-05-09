# Trivial Session

> Session type: trivial. Use when the request is a small, localized change or a factual question. Routing terminates after `### Answer` is fully ticked.

## CheckList

### Clarification

- [ ] Probe technical unknowns and ask clarifying questions until scope, constraints, and success criteria are clear
- [ ] Evaluate whether the user's stated requirement is the most appropriate approach, grounded in probe findings and factual evidence — not intuition alone; when a clearly better approach exists, always use `AskUserQuestion` to present the alternative with its rationale and let the user decide, then proceed silently when no better approach is found
- [ ] Confirm understanding with the user
- [ ] Write the clarification body and session-type hint into `session.md` and return the terminal handoff line

### Answer

- [ ] Verify all requirements in context are satisfied: check compliance with user-level `~/.claude/CLAUDE.md`, project-level `CLAUDE.md`, and any preconditions stated earlier in the conversation
- [ ] Read `## Clarification` in `session.md` for the user's question and the established context
- [ ] Write the answer directly to the user using affirmative phrasing
- [ ] Tick every item in this sub-section to terminate the session

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
