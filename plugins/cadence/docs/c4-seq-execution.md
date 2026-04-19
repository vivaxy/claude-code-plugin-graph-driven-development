# cadence Skill Execution Flow

> **Type**: Sequence
> **Last Updated**: 2026-04-19
> **Covers**: End-to-end flow from user describing a feature to delivery

## Diagram

```mermaid
sequenceDiagram
  participant User
  participant Routing as using-cadence
  participant Clarify as clarify agent
  participant Plan as plan agent
  participant Impl as general-purpose agent
  participant Review as main-review
  participant Deliver as deliver

  User->>Routing: Describes a feature task
  Routing->>Routing: Is this a feature-dev task?

  alt Not a feature task (bug fix / docs)
    Routing-->>User: Proceed normally
  else Feature task
    Routing->>Routing: Clarification summary in conversation?
    alt No clarification
      Routing->>Clarify: Invoke
      Clarify->>User: AskUserQuestion — clarifying questions (1-2 at a time)
      User-->>Clarify: Answers
      Clarify->>User: AskUserQuestion — confirm understanding
      User-->>Clarify: Confirms or corrects
      Clarify->>User: AskUserQuestion — confirm session type<br>(options: feature-dev / bugfix / doc-writing)
      User-->>Clarify: Confirms
      Clarify-->>Routing: Clarification summary
    end

    Routing->>Routing: Plan in conversation?
    alt No plan
      Routing->>Plan: Invoke
      Plan->>Plan: Read docs/ and codebase
      Plan->>Plan: Design C4 diagrams, write plan file
      Plan-->>User: ExitPlanMode — request approval
      User-->>Plan: Approves or rejects with feedback
      Plan-->>Routing: Plan approved
    end

    Routing->>Impl: Apply doc changes, then implement steps
    Impl->>Impl: Execute implementation steps sequentially
    Impl-->>Routing: Implementation complete

    Routing->>Review: Invoke
    Review->>Review: Run test suite, check success criteria
    alt FEATURE_BLOCKED
      Review-->>Routing: Blocked — fix required
      Routing->>Impl: Fix blocking issues
      Impl-->>Routing: Fixed
      Routing->>Review: Re-invoke
    end
    Review-->>Routing: FEATURE_ACCEPTED

    Routing->>Deliver: Invoke
    Deliver-->>User: Retrospective + final summary
  end
```

## Key Decisions

- Clarification and plan both live in conversation context — Cadence is session-scoped, not persisted across sessions
- `plan` agent uses `EnterPlanMode`/`ExitPlanMode` as the user approval gate — no code is written until the user approves
- `main-review` runs the full test suite as part of end-to-end acceptance
- Deviations discovered during implementation are recorded in conversation, not silently applied to diagrams

## Notes

- Cross-reference: `c4-component-plugin.md` shows which files implement each component in this sequence
- Cross-reference: `c4-containers.md` shows the container-level structure these components belong to
- SessionStart hook injects Cadence routing guidance at the start of each session
