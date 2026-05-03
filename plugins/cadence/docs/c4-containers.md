# cadence Plugin — Containers

> **Type**: C4 Container
> **Last Updated**: 2026-05-03
> **Covers**: Internal deployable/runnable units of the cadence plugin

## Diagram

```mermaid
C4Container
  title Container Diagram — cadence Plugin

  Person(developer, "Developer", "Uses Claude Code to build software features")

  System_Boundary(cadence, "cadence Plugin") {
    Container(hooks, "Hooks", "Bash scripts", "SessionStart hook — injects routing skill into every new session")
    Container(skills, "Skills & Agents", "Markdown instruction files", "using-cadence routing, clarify, analyze, plan, implement, review, deliver")
    ContainerDb(docs, "docs/", "Markdown + Mermaid", "Authoritative C4 design documents and sequence diagrams")
    ContainerDb(sessionFolder, "Session Folder", "Markdown + YAML frontmatter", "Per-session phase artifacts at &lt;project&gt;/.claude/sessions/YYYY-MM-DD-&lt;slug&gt;/")
  }

  System_Ext(projectSrc, "Project Source Code", "The user's application source files")

  Rel(developer, skills, "Describes feature task to", "Claude Code session")
  Rel(hooks, skills, "Injects routing context at session start")
  Rel(skills, docs, "Reads and writes")
  Rel(skills, sessionFolder, "Reads prior phase, writes current phase")
  Rel(skills, projectSrc, "Reads and writes")
  Rel(docs, projectSrc, "Constrains")
```

## Key Decisions

- Skills and agents are Markdown instruction files interpreted by Claude at runtime — not executable code
- `docs/` acts as a database container: it persists design state across sessions
- The hooks container has no logic — it only bootstraps the routing skill at session start
- Session Folder is a per-session container: every phase (clarify, analyze, plan, implement, review, deliver) writes its own md file with YAML frontmatter, and downstream phases read prior files (from plan: cadence-session-folders)

## Notes

- See `c4-context.md` for the system boundary view
- See `c4-component-plugin.md` for internal components within the Skills & Agents container
- See `c4-seq-execution.md` for how these containers interact at runtime
