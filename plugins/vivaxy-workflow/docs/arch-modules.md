# vivaxy-workflow Plugin — Module Architecture

> **Type**: Architecture
> **Last Updated**: 2026-04-18
> **Covers**: Internal component layout of the vivaxy-workflow plugin and their dependencies

## Diagram

```mermaid
graph TD
    SessionStart["hooks/session-start<br>(SessionStart hook)"]
    UsingVivaxyWorkflow["skills/using-vivaxy-workflow<br>(routing skill)"]
    ClarifySkill["skills/main-clarify<br>(vivaxy-workflow:main:clarify)"]
    PlanSkill["skills/main-plan<br>(vivaxy-workflow:main:plan)"]
    SubtaskExecuteSkill["skills/subtask-execute<br>(vivaxy-workflow:subtask-execute)"]
    SubtaskReviewSkill["skills/subtask-review<br>(subagent)"]
    ReviewSkill["skills/main-review<br>(vivaxy-workflow:main:review)"]
    DeliverSkill["skills/main-deliver<br>(vivaxy-workflow:main:deliver)"]
    WorkflowDocs["docs/<br>(design documents + diagram files)"]
    ProjectSrc["Project source files"]

    SessionStart -->|injects routing context via| UsingVivaxyWorkflow
    UsingVivaxyWorkflow -->|invokes| ClarifySkill
    UsingVivaxyWorkflow -->|invokes| PlanSkill
    UsingVivaxyWorkflow -->|invokes| SubtaskExecuteSkill
    UsingVivaxyWorkflow -->|invokes| ReviewSkill
    UsingVivaxyWorkflow -->|invokes| DeliverSkill

    ClarifySkill -->|outputs clarification summary to conversation| UsingVivaxyWorkflow
    PlanSkill -->|reads| WorkflowDocs
    PlanSkill -->|writes doc-subtasks.md + design docs| WorkflowDocs
    SubtaskExecuteSkill -->|reads| WorkflowDocs
    SubtaskExecuteSkill -->|writes| ProjectSrc
    SubtaskExecuteSkill -->|records deviations in| WorkflowDocs
    SubtaskExecuteSkill -->|updates subtask status in| WorkflowDocs
    SubtaskExecuteSkill -->|spawns subagent| SubtaskReviewSkill
    SubtaskReviewSkill -->|reads| WorkflowDocs
    SubtaskReviewSkill -->|reads| ProjectSrc
    ReviewSkill -->|reads| WorkflowDocs
    ReviewSkill -->|reads| ProjectSrc
    DeliverSkill -->|reads| WorkflowDocs
    DeliverSkill -->|writes doc-retrospective| WorkflowDocs
```

## Key Decisions

- Skills are instruction files, not executable code — Claude interprets them at runtime
- `using-vivaxy-workflow` is the single entry point — it detects feature tasks and routes to the correct phase automatically
- `vivaxy-workflow:subtask-execute` never modifies `flow-*.md` or `arch-*.md` — deviations are recorded in `docs/drafts/`
- `vivaxy-workflow:subtask-review` is a read-only subagent — it never writes files
- Workflow state is persisted in `docs/doc-subtasks.md` — resumable across sessions

## Notes

- `hooks/run-hook.cmd` and `hooks/hooks.json` wire the SessionStart hook into Claude Code
- Plugin metadata lives in `.claude-plugin/` (not shown — not part of the vivaxy Workflow workflow)
