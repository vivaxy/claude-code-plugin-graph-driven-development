# cadence Plugin — Containers

> **Type**: C4 Container
> **Last Updated**: 2026-05-04
> **Covers**: Internal deployable/runnable units of the cadence plugin

## Diagram

```mermaid
C4Container
  title Container Diagram — cadence Plugin

  Person(developer, "Developer", "Uses Claude Code to build software features")

  System_Boundary(cadence, "cadence Plugin") {
    Container(hooks, "Hooks", "Bash scripts", "SessionStart hook — injects routing skill into every new session")
    Container(skills, "Skills & Agents", "Markdown instruction files", "using-cadence routing, clarify, analyze, plan, implement, review, deliver")
    ContainerDb(templates, "templates/", "Markdown templates", "One file per session type (trivial, feature-dev, bugfix, doc-writing, analysis)")
    ContainerDb(docs, "docs/", "Markdown + Mermaid", "Authoritative C4 design documents and sequence diagrams")
    ContainerDb(sessionFolder, "Session Folder", "Markdown checklist", "Single session.md per session at &lt;project&gt;/.claude/sessions/YYYY-MM-DD-&lt;slug&gt;/, plus incidental side artifacts")
  }

  System_Ext(projectSrc, "Project Source Code", "The user's application source files")

  Rel(developer, skills, "Describes feature task to", "Claude Code session")
  Rel(hooks, skills, "Injects routing context at session start")
  Rel(skills, docs, "Reads and writes")
  Rel(skills, templates, "Copies <type>.md into session folder after type is confirmed")
  Rel(skills, sessionFolder, "Reads session.md, ticks owned-section checklists")
  Rel(skills, projectSrc, "Reads and writes")
  Rel(docs, projectSrc, "Constrains")
```

## Key Decisions

- Skills and agents are Markdown instruction files interpreted by Claude at runtime — not executable code
- `docs/` acts as a database container: it persists design state across sessions
- The hooks container has no logic — it only bootstraps the routing skill at session start
- Session Folder is a per-session container holding a single `session.md` whose `## <Section>` checklists are the only state; agents tick items in their owned section instead of writing per-phase files (from plan: cadence-template-driven-checklists)
- `templates/` ships one markdown template per session type; the routing skill copies the matching template into the session folder after the user confirms the session type (from plan: cadence-template-driven-checklists)

## Notes

- See `c4-context.md` for the system boundary view
- See `c4-component-plugin.md` for internal components within the Skills & Agents container
- See `c4-seq-execution.md` for how these containers interact at runtime
