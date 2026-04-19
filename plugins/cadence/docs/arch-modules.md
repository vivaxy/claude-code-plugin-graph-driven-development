# cadence Plugin — Module Architecture

> **Type**: Architecture
> **Last Updated**: 2026-04-19
> **Covers**: Internal component layout of the cadence plugin and their dependencies

## Diagram

```mermaid
graph TD
    SessionStart["hooks/session-start<br>(SessionStart hook)"]
    UsingVivaxyWorkflow["skills/using-cadence<br>(routing skill)"]
    ClarifySkill["skills/main-clarify<br>(cadence:main:clarify)"]
    PlanSkill["skills/main-plan<br>(cadence:main:plan)"]
    ReviewSkill["skills/main-review<br>(cadence:main:review)"]
    DeliverSkill["skills/main-deliver<br>(cadence:main:deliver)"]
    WorkflowDocs["docs/<br>(diagram files)"]
    ProjectSrc["Project source files"]

    SessionStart -->|injects routing context via| UsingVivaxyWorkflow
    UsingVivaxyWorkflow -->|invokes| ClarifySkill
    UsingVivaxyWorkflow -->|invokes| PlanSkill
    UsingVivaxyWorkflow -->|invokes| ReviewSkill
    UsingVivaxyWorkflow -->|invokes| DeliverSkill

    ClarifySkill -->|outputs clarification summary to conversation| UsingVivaxyWorkflow
    PlanSkill -->|reads| WorkflowDocs
    PlanSkill -->|updates diagrams| WorkflowDocs
    ReviewSkill -->|reads| WorkflowDocs
    ReviewSkill -->|reads| ProjectSrc
    DeliverSkill -->|reads| WorkflowDocs
    DeliverSkill -->|outputs retrospective to conversation| UsingVivaxyWorkflow
```

## Key Decisions

- Skills are instruction files, not executable code — Claude interprets them at runtime
- `using-cadence` is the single entry point — it detects feature tasks and routes to the correct phase automatically
- Workflow state (plan, deviations, retrospective) lives in the conversation context — Cadence is session-scoped

## Notes

- `hooks/run-hook.cmd` and `hooks/hooks.json` wire the SessionStart hook into Claude Code
- Plugin metadata lives in `.claude-plugin/` (not shown — not part of the Cadence workflow)
