# vivaxy-workflow Skill Execution Flow

> **Type**: Flow
> **Last Updated**: 2026-04-18
> **Covers**: End-to-end flow from user describing a feature to delivery

## Diagram

```mermaid
flowchart TD
    Start([User describes a feature task])

    Start --> UsingVivaxyWorkflow{"using-vivaxy-workflow<br>feature task?"}
    UsingVivaxyWorkflow -->|No — bug fix / docs| Passthrough([Proceed normally])
    UsingVivaxyWorkflow -->|Yes| CheckClarify{"doc-clarification.md<br>exists?"}

    CheckClarify -->|No| Clarify["vivaxy-workflow:main:clarify<br>Q&A with user,<br>write doc-clarification.md"]
    Clarify --> CheckPlan{"doc-subtasks.md<br>exists?"}

    CheckClarify -->|Yes| CheckPlan
    CheckPlan -->|No| Plan["vivaxy-workflow:main:plan<br>Decompose into subtasks,<br>write design docs + diagrams,<br>ExitPlanMode for approval,<br>write doc-subtasks.md"]
    Plan --> SubtaskLoop

    CheckPlan -->|Yes| SubtaskLoop{"Pending subtasks?"}
    SubtaskLoop -->|Yes| Execute["vivaxy-workflow:subtask-execute ST-XX<br>Read docs, TDD implementation,<br>update subtask status"]
    Execute --> SubtaskReview["vivaxy-workflow:subtask-review<br>(subagent)<br>Check acceptance criteria<br>+ doc alignment"]
    SubtaskReview --> SubtaskVerdict{Verdict}
    SubtaskVerdict -->|NEEDS_WORK| FixSubtask[Fix issues in code]
    FixSubtask --> SubtaskReview
    SubtaskVerdict -->|ACCEPTED| MarkAccepted[Mark subtask ACCEPTED<br>in doc-subtasks.md]
    MarkAccepted --> SubtaskLoop

    SubtaskLoop -->|No — all ACCEPTED| Review["vivaxy-workflow:main:review<br>Verify all subtasks,<br>run test suite,<br>check success criteria"]
    Review --> FeatureVerdict{Verdict}
    FeatureVerdict -->|FEATURE_BLOCKED| FixFeature[Fix blocking issues]
    FixFeature --> Review
    FeatureVerdict -->|FEATURE_ACCEPTED| Deliver["vivaxy-workflow:main:deliver<br>Write retrospective,<br>clean up drafts,<br>deliver summary"]
    Deliver --> Done([Done])
```

## Key Decisions

- Workflow state is detected from `docs/` file presence — the routing skill resumes from the correct phase automatically
- `vivaxy-workflow:main:plan` uses `EnterPlanMode`/`ExitPlanMode` as the user approval gate for the subtask plan
- Each subtask is independently executed and accepted before moving to the next
- `vivaxy-workflow:subtask-review` is a read-only subagent — it never writes files
- `vivaxy-workflow:main:review` runs the full test suite as part of end-to-end acceptance
- Deviations discovered during execution are recorded in `docs/drafts/` rather than silently modifying diagrams

## Notes

- Cross-reference: `arch-modules.md` shows which files implement each step
- SessionStart hook injects vivaxy Workflow routing guidance at the start of each session
