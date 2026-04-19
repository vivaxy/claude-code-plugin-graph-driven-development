# cadence Plugin — Components

> **Type**: C4 Component
> **Last Updated**: 2026-04-19
> **Covers**: Internal components of the Skills & Agents container

## Diagram

```mermaid
C4Component
  title Component Diagram — Skills & Agents Container

  Container_Boundary(skills, "Skills & Agents") {
    Component(sessionStart, "session-start hook", "Bash script", "Reads using-cadence skill and injects it as session context via additionalContext")
    Component(usingCadence, "using-cadence", "Routing skill", "Single entry point — detects feature tasks and routes to the correct phase")
    Component(clarify, "clarify agent", "Clarification agent", "Q&A with user, spawns probe subagents for unknowns, outputs clarification summary")
    Component(plan, "plan agent", "Planning agent", "Reads docs/, designs C4 diagrams, writes plan file, gets approval via ExitPlanMode")
    Component(review, "review agent", "Review agent", "Runs test suite, checks success criteria and alignment, assigns FEATURE_ACCEPTED or FEATURE_BLOCKED")
    Component(deliver, "deliver", "Delivery skill", "Outputs retrospective and final summary to conversation")
  }

  ContainerDb(docs, "docs/", "Markdown + Mermaid", "Authoritative C4 design documents")
  System_Ext(projectSrc, "Project Source Code", "The user's application source files")

  Rel(sessionStart, usingCadence, "Injects as session context")
  Rel(usingCadence, clarify, "Invokes if no clarification summary")
  Rel(usingCadence, plan, "Invokes if no plan")
  Rel(usingCadence, review, "Invokes after implementation")
  Rel(usingCadence, deliver, "Invokes after review passes")
  Rel(plan, docs, "Reads and updates")
  Rel(review, docs, "Reads")
  Rel(review, projectSrc, "Reads")
  Rel(deliver, docs, "Reads")
```

## Key Decisions

- `using-cadence` is the single entry point — all routing decisions live here, not in individual agents
- Workflow state (clarification summary, plan approval, deviations) lives in conversation context — Cadence is session-scoped
- `plan` is the only component that writes to `docs/` — other components read only

## Notes

- See `c4-containers.md` for the container-level view
- See `c4-seq-execution.md` for the runtime interaction sequence
- `hooks/run-hook.cmd` and `hooks/hooks.json` wire the SessionStart hook into Claude Code
