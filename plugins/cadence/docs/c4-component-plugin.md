# cadence Plugin — Components

> **Type**: C4 Component
> **Last Updated**: 2026-05-09
> **Covers**: Internal components of the Skills & Agents container

## Diagram

```mermaid
C4Component
  title Component Diagram — Skills & Agents Container

  Container_Boundary(skills, "Skills & Agents") {
    Component(sessionStart, "session-start hook", "Bash script", "Reads using-cadence skill and injects it as session context")
    Component(usingCadence, "using-cadence", "Routing skill", "Walks ## CheckList in session.md top-to-bottom; spawns owner of first ### sub-section with any unchecked item")
    Component(clarify, "clarify agent", "Clarification agent", "Owns ## CheckList → ### Clarification and ## Clarification body — derives slug, creates session folder, ticks clarification checklist, fills body blanks; runs skill-match check before Q&A when available_skills list is provided")
    Component(analyze, "analyze-problem agent", "Diagnostic agent", "Owns ## CheckList → ### Analysis and ## Analysis body — runs facts/model/questions, fills body blanks, ticks checklist")
    Component(plan, "plan agent", "Planning agent", "Owns ## CheckList → ### Plan and ## Plan body — fills plan blanks, populates ### Implementation work items, gets approval via AskUserQuestion, ticks plan checklist")
    Component(implement, "implement agent", "Step executor", "Owns ## CheckList → ### Implementation — applies code changes per work item and ticks each item with files-touched/verification sub-bullets")
    Component(review, "review agent", "Review agent", "Owns ## CheckList → ### Review and ## Review body — runs parallel checks, fills body blanks, ticks checklist")
    Component(deliver, "deliver agent", "Delivery agent", "Owns ## CheckList → ### Delivery and ## Delivery body — fills retrospective + final summary blanks, ticks checklist")
    Component(probe, "probe agent", "Investigation subagent", "Spawned by clarify (one per unknown, in parallel) — searches codebase, popular implementations, and official docs to answer one factual question")
    Component(check, "check agent", "Criteria verifier subagent", "Spawned by review — verifies each success criterion against the codebase, returns SATISFIED / NOT_SATISFIED / UNTESTED")
    Component(verify, "verify agent", "Structural reviewer subagent", "Spawned by review (one per dimension, in parallel) — reviews docs-alignment, plan-alignment, or bugfix-regression, returns PASS / PASS_WITH_WARNINGS / FAIL")
    Component(codeReview, "code-review agent", "Diff reviewer subagent", "Spawned by review — reviews staged diff for style, bugs, and security, returns APPROVED / APPROVED_WITH_NOTES / NEEDS_WORK")
  }

  ContainerDb(templates, "templates/", "Markdown templates", "One file per session type (trivial, feature-dev, bugfix, analysis)")
  ContainerDb(docs, "docs/", "Markdown + Mermaid", "Authoritative C4 design documents")
  ContainerDb(sessionFolder, "Session Folder", "Markdown checklist", "Single session.md per session, plus incidental side artifacts")
  System_Ext(projectSrc, "Project Source Code", "The user's application source files")

  Rel(sessionStart, usingCadence, "Injects as session context")
  Rel(usingCadence, sessionFolder, "Walks ## CheckList in session.md, finds first unchecked ### sub-section")
  Rel(usingCadence, templates, "Copies <type>.md into session folder after type is confirmed")
  Rel(usingCadence, clarify, "Spawns when ### Clarification has unchecked items; passes available_skills list")
  Rel(usingCadence, analyze, "Spawns when ### Analysis has unchecked items")
  Rel(usingCadence, plan, "Spawns when ### Plan has unchecked items")
  Rel(usingCadence, implement, "Spawns when ### Implementation has unchecked items")
  Rel(usingCadence, review, "Spawns when ### Review has unchecked items")
  Rel(usingCadence, deliver, "Spawns when ### Delivery has unchecked items")
  Rel(clarify, sessionFolder, "Creates folder, fills ## Clarification body, ticks ### Clarification items")
  Rel(analyze, sessionFolder, "Fills ## Analysis body, ticks ### Analysis items")
  Rel(plan, sessionFolder, "Fills ## Plan body, populates ### Implementation work items, ticks ### Plan items")
  Rel(plan, docs, "Reads and updates diagrams")
  Rel(implement, sessionFolder, "Ticks ### Implementation work items with files-touched/verification sub-bullets")
  Rel(review, sessionFolder, "Fills ## Review body, ticks ### Review items")
  Rel(deliver, sessionFolder, "Fills ## Delivery body, ticks ### Delivery items")
  Rel(clarify, probe, "Spawns one per unknown, in parallel")
  Rel(review, check, "Spawns to verify success criteria")
  Rel(review, verify, "Spawns one per structural dimension, in parallel")
  Rel(review, codeReview, "Spawns to review staged diff")
  Rel(probe, projectSrc, "Reads")
  Rel(check, projectSrc, "Reads")
  Rel(verify, projectSrc, "Reads")
  Rel(codeReview, projectSrc, "Reads diff")
```

## Key Decisions

- `using-cadence` is the single entry point — all routing decisions live here, not in individual agents
- Workflow state lives in `session.md`: a single `## CheckList` section groups every workflow item under `### <Sub-section>` headings (one per agent); body sections (`## Clarification`, `## Plan`, `## Analysis`, `## Review`, `## Delivery`) hold the structured content with `<!-- TODO: ... -->` placeholders. Routing walks `## CheckList` top-to-bottom and spawns the owner of the first sub-section with any `- [ ]` item — this enables resume after interruption (from plan: cadence-template-driven-checklists, cadence-checklist-collapse)
- Each phase agent owns one `### <Sub-section>` under `## CheckList` (and, where applicable, the matching `## <Section>` body); its sole output is editing those (filling `<!-- TODO: ... -->` placeholders and ticking checklist items) — there are no per-phase md files (from plan: cadence-template-driven-checklists, cadence-checklist-collapse)
- Subagents return one-line handoffs pointing at `session.md` and summarising the work; the file is the contract, the return message is the pointer (from plan: cadence-template-driven-checklists)

## Notes

- See `c4-containers.md` for the container-level view
- See `c4-seq-execution.md` for the runtime interaction sequence
- `hooks/run-hook.cmd` and `hooks/hooks.json` wire the SessionStart hook into Claude Code
