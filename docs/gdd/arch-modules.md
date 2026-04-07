# GDD Plugin — Module Architecture

> **Type**: Architecture
> **Last Updated**: 2026-04-07
> **Covers**: Internal component layout of the GDD plugin and their dependencies

## Diagram

```mermaid
graph TD
    SessionStart["hooks/session-start<br>(SessionStart hook)"]
    UsingGDD["skills/using-gdd/SKILL.md<br>(routing skill)"]
    InitCmd["commands/init.md<br>(/gdd:init)"]
    PlanCmd["commands/plan.md<br>(/gdd:plan)"]
    CodeCmd["commands/code.md<br>(/gdd:code)"]
    PlanReview["skills/plan-review/SKILL.md<br>(diagram review subagent)"]
    CodeReview["skills/code-review/SKILL.md<br>(code review subagent)"]
    GDDDocs["docs/gdd/<br>(diagram files)"]
    ProjectSrc["Project source files"]

    SessionStart -->|injects routing context via| UsingGDD
    UsingGDD -->|invokes| InitCmd
    UsingGDD -->|invokes| PlanCmd
    UsingGDD -->|invokes| CodeCmd

    InitCmd -->|creates| GDDDocs
    PlanCmd -->|reads + updates| GDDDocs
    PlanCmd -->|spawns subagent| PlanReview
    PlanReview -->|reads| GDDDocs
    CodeCmd -->|reads| GDDDocs
    CodeCmd -->|writes| ProjectSrc
    CodeCmd -->|records deviations in| GDDDocs
    CodeCmd -->|spawns subagent| CodeReview
    CodeReview -->|reads| GDDDocs
    CodeReview -->|reads| ProjectSrc
```

## Key Decisions

- Commands are instruction files, not executable code — Claude interprets them at runtime
- `using-gdd` skill is the single entry point — it detects feature tasks and invokes the appropriate skill automatically
- `commands/plan.md` never writes to project source; `commands/code.md` never writes diagrams (except deviation records)
- Review skills (`plan-review`, `code-review`) are read-only subagents — they never write files
- Dependency direction: code depends on diagrams, diagrams do not depend on code

## Notes

- Dependency direction: arrows point from dependent to dependency
- `hooks/run-hook.cmd` and `hooks/hooks.json` wire the SessionStart hook into Claude Code
- Plugin metadata lives in `.claude-plugin/` (not shown — not part of the GDD workflow)
