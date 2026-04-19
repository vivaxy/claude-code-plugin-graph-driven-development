# cadence Skill Execution Flow

> **Type**: Flow
> **Last Updated**: 2026-04-19
> **Covers**: End-to-end flow from user describing a feature to delivery

## Diagram

```mermaid
flowchart TD
    Start([User describes a feature task])

    Start --> UsingVivaxyWorkflow{"using-cadence<br>feature task?"}
    UsingVivaxyWorkflow -->|No — bug fix / docs| Passthrough([Proceed normally])
    UsingVivaxyWorkflow -->|Yes| CheckClarify{"Clarification<br>in conversation?"}

    CheckClarify -->|No| Clarify["cadence:main:clarify<br>Q&A with user,<br>outputs clarification summary"]
    Clarify --> CheckPlan{"Plan<br>in conversation?"}

    CheckClarify -->|Yes| CheckPlan
    CheckPlan -->|No| Plan["cadence:main:plan<br>Analyze docs,<br>define implementation approach,<br>ExitPlanMode for approval"]
    Plan --> Implement

    CheckPlan -->|Yes| Implement[Implement the feature]
    Implement --> Review["cadence:main:review<br>Run test suite,<br>check success criteria"]
    Review --> FeatureVerdict{Verdict}
    FeatureVerdict -->|FEATURE_BLOCKED| FixFeature[Fix blocking issues]
    FixFeature --> Review
    FeatureVerdict -->|FEATURE_ACCEPTED| Deliver["cadence:main:deliver<br>Output retrospective to conversation,<br>deliver summary"]
    Deliver --> Done([Done])
```

## Key Decisions

- Clarification and plan both live in conversation context — Cadence is session-scoped
- `cadence:main:plan` uses `EnterPlanMode`/`ExitPlanMode` as the user approval gate
- `cadence:main:review` runs the full test suite as part of end-to-end acceptance
- Deviations discovered during implementation are recorded in the conversation rather than silently modifying diagrams

## Notes

- Cross-reference: `arch-modules.md` shows which files implement each step
- SessionStart hook injects Cadence routing guidance at the start of each session
