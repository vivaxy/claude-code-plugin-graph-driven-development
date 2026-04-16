# GDD Plugin — Module Architecture

> **Type**: Architecture
> **Last Updated**: 2026-04-16
> **Covers**: Internal component layout of the GDD plugin and their dependencies

## Diagram

```mermaid
graph TD
    SessionStart["hooks/session-start<br>(SessionStart hook)"]
    UsingGDD["skills/using-gdd/SKILL.md<br>(routing skill + auto-init)"]
    PlanSkill["skills/plan/SKILL.md<br>(gdd:plan — doc + diagram planning)"]
    CodeSkill["skills/code/SKILL.md<br>(gdd:code — implementation)"]
    PlanReview["skills/plan-review/SKILL.md<br>(design review subagent)"]
    CodeReview["skills/code-review/SKILL.md<br>(code review subagent)"]
    ProjectDocs["docs/<br>(design docs + diagram files)"]
    ProjectSrc["Project source files"]

    SessionStart -->|injects routing context via| UsingGDD
    UsingGDD -->|auto-generates when missing| ProjectDocs
    UsingGDD -->|invokes| PlanSkill

    PlanSkill -->|reads + writes| ProjectDocs
    PlanSkill -->|spawns subagent| PlanReview
    PlanReview -->|reads| ProjectDocs
    PlanSkill -->|invokes| CodeSkill

    CodeSkill -->|reads| ProjectDocs
    CodeSkill -->|writes| ProjectSrc
    CodeSkill -->|records deviations in| ProjectDocs
    CodeSkill -->|spawns subagent| CodeReview
    CodeReview -->|reads| ProjectDocs
    CodeReview -->|reads| ProjectSrc
```

## Key Decisions

- Skills are instruction files, not executable code — Claude interprets them at runtime
- `using-gdd` skill is the single entry point — it detects feature tasks, auto-initializes `docs/` if missing, and invokes the appropriate skill automatically
- No slash commands exist — the entire workflow runs via skills
- `skills/plan/SKILL.md` writes both design documents (`doc-*.md`) and diagram files; `skills/code/SKILL.md` never writes either (except deviation records)
- Review skills (`plan-review`, `code-review`) are read-only subagents — they never write files
- Dependency direction: code depends on documents and diagrams; documents and diagrams do not depend on code

## Notes

- Dependency direction: arrows point from dependent to dependency
- `hooks/run-hook.cmd` and `hooks/hooks.json` wire the SessionStart hook into Claude Code
- Plugin metadata lives in `.claude-plugin/` (not shown — not part of the GDD workflow)
