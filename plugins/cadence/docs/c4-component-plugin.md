# cadence Plugin — Components

> **Type**: C4 Component
> **Last Updated**: 2026-05-04
> **Covers**: Internal components of the Skills & Agents container

## Diagram

```mermaid
C4Component
  title Component Diagram — Skills & Agents Container

  Container_Boundary(skills, "Skills & Agents") {
    Component(sessionStart, "session-start hook", "Bash script", "Reads using-cadence skill and injects it as session context")
    Component(usingCadence, "using-cadence", "Routing skill", "Scans session.md top-to-bottom; spawns owner of first section with any unchecked item")
    Component(clarify, "clarify agent", "Clarification agent", "Owns ## Clarification — derives slug, creates session folder, ticks clarification checklist")
    Component(analyze, "analyze-problem agent", "Diagnostic agent", "Owns ## Analysis — runs facts/model/questions and ticks analysis checklist")
    Component(plan, "plan agent", "Planning agent", "Owns ## Plan — writes plan body into ## Plan, gets approval via ExitPlanMode, ticks plan checklist")
    Component(implement, "implement agent", "Step executor", "Owns ## Implementation — applies code changes and ticks implementation checklist")
    Component(review, "review agent", "Review agent", "Owns ## Review — runs parallel checks and ticks review checklist")
    Component(deliver, "deliver agent", "Delivery agent", "Owns ## Delivery — writes retrospective + final summary, ticks delivery checklist")
  }

  ContainerDb(templates, "templates/", "Markdown templates", "One file per session type (trivial, feature-dev, bugfix, doc-writing, analysis)")
  ContainerDb(docs, "docs/", "Markdown + Mermaid", "Authoritative C4 design documents")
  ContainerDb(sessionFolder, "Session Folder", "Markdown checklist", "Single session.md per session, plus incidental side artifacts")
  System_Ext(projectSrc, "Project Source Code", "The user's application source files")

  Rel(sessionStart, usingCadence, "Injects as session context")
  Rel(usingCadence, sessionFolder, "Reads session.md, finds first unchecked section")
  Rel(usingCadence, templates, "Copies <type>.md into session folder after type is confirmed")
  Rel(usingCadence, clarify, "Spawns when ## Clarification has unchecked items")
  Rel(usingCadence, analyze, "Spawns when ## Analysis has unchecked items")
  Rel(usingCadence, plan, "Spawns when ## Plan has unchecked items")
  Rel(usingCadence, implement, "Spawns when ## Implementation has unchecked items")
  Rel(usingCadence, review, "Spawns when ## Review has unchecked items")
  Rel(usingCadence, deliver, "Spawns when ## Delivery has unchecked items")
  Rel(clarify, sessionFolder, "Creates folder + ticks ## Clarification items in session.md")
  Rel(analyze, sessionFolder, "Ticks ## Analysis items in session.md")
  Rel(plan, sessionFolder, "Writes plan body into ## Plan + ticks checklist in session.md")
  Rel(plan, docs, "Reads and updates diagrams")
  Rel(implement, sessionFolder, "Ticks ## Implementation items in session.md")
  Rel(review, sessionFolder, "Ticks ## Review items in session.md")
  Rel(deliver, sessionFolder, "Ticks ## Delivery items in session.md")
```

## Key Decisions

- `using-cadence` is the single entry point — all routing decisions live here, not in individual agents
- Workflow state lives in `session.md` as `## <Section>` checklists; routing reads the file top-to-bottom and spawns the owner of the first section with any `- [ ]` item — this enables resume after interruption (from plan: cadence-template-driven-checklists)
- Each phase agent owns exactly one section; its sole output is editing that section of `session.md` (writing body content where applicable and ticking checklist items) — there are no per-phase md files (from plan: cadence-template-driven-checklists)
- Subagents return one-line handoffs pointing at `session.md` and summarising the work; the file is the contract, the return message is the pointer (from plan: cadence-template-driven-checklists)

## Notes

- See `c4-containers.md` for the container-level view
- See `c4-seq-execution.md` for the runtime interaction sequence
- `hooks/run-hook.cmd` and `hooks/hooks.json` wire the SessionStart hook into Claude Code
