# cadence Plugin — Components

> **Type**: C4 Component
> **Last Updated**: 2026-05-03
> **Covers**: Internal components of the Skills & Agents container

## Diagram

```mermaid
C4Component
  title Component Diagram — Skills & Agents Container

  Container_Boundary(skills, "Skills & Agents") {
    Component(sessionStart, "session-start hook", "Bash script", "Reads using-cadence skill and injects it as session context")
    Component(usingCadence, "using-cadence", "Routing skill", "Routes by session-folder file presence + frontmatter status")
    Component(clarify, "clarify agent", "Clarification agent", "Creates session folder, derives slug, writes clarify.md")
    Component(analyze, "analyze-problem agent", "Diagnostic agent", "Reads clarify.md, writes analyze.md (diagnostic sessions only)")
    Component(plan, "plan agent", "Planning agent", "Reads clarify.md (and analyze.md if present), writes plan.md, gets approval")
    Component(implement, "implement agent", "Step executor", "Reads plan.md, executes one step, writes implement-step-N.md")
    Component(review, "review agent", "Review agent", "Reads plan.md and implement-step-*.md, writes review.md")
    Component(deliver, "deliver agent", "Delivery agent", "Reads all prior md files, writes deliver.md and final summary")
  }

  ContainerDb(docs, "docs/", "Markdown + Mermaid", "Authoritative C4 design documents")
  ContainerDb(sessionFolder, "Session Folder", "Markdown + YAML frontmatter", "Per-session phase artifacts")
  System_Ext(projectSrc, "Project Source Code", "The user's application source files")

  Rel(sessionStart, usingCadence, "Injects as session context")
  Rel(usingCadence, sessionFolder, "Routes by file presence + frontmatter status")
  Rel(usingCadence, clarify, "Invokes if no clarify.md")
  Rel(usingCadence, analyze, "Invokes for diagnostic sessions")
  Rel(usingCadence, plan, "Invokes if no plan.md")
  Rel(usingCadence, implement, "Invokes once per step")
  Rel(usingCadence, review, "Invokes after all steps complete")
  Rel(usingCadence, deliver, "Invokes after review passes")
  Rel(clarify, sessionFolder, "Creates folder + writes clarify.md")
  Rel(analyze, sessionFolder, "Reads clarify.md, writes analyze.md")
  Rel(plan, sessionFolder, "Reads clarify.md, writes plan.md")
  Rel(plan, docs, "Reads and updates diagrams")
  Rel(implement, sessionFolder, "Reads plan.md, writes implement-step-N.md")
  Rel(review, sessionFolder, "Reads prior files, writes review.md")
  Rel(deliver, sessionFolder, "Reads all files, writes deliver.md")
```

## Key Decisions

- `using-cadence` is the single entry point — all routing decisions live here, not in individual agents
- Workflow state lives in the session folder as one md file per phase (with YAML frontmatter), not in conversation context — this enables resume after interruption (from plan: cadence-session-folders)
- Every phase (clarify, analyze, plan, implement, review, deliver) is a writer to the session folder; downstream phases read prior files instead of inlined context (from plan: cadence-session-folders)
- Subagents return one-line `(path, summary)` handoffs; the file is the contract, the return message is the pointer (from plan: cadence-session-folders)

## Notes

- See `c4-containers.md` for the container-level view
- See `c4-seq-execution.md` for the runtime interaction sequence
- `hooks/run-hook.cmd` and `hooks/hooks.json` wire the SessionStart hook into Claude Code
