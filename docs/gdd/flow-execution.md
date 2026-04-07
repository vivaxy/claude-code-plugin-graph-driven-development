# GDD Command Execution Flow

> **Type**: Flow
> **Last Updated**: 2026-04-07
> **Covers**: End-to-end flow from user describing a task to diagrams and code being approved

## Diagram

```mermaid
flowchart TD
    Start([User describes a task])

    Start --> UsingGDD{"using-gdd skill<br>feature task?"}
    UsingGDD -->|No — bug fix / docs| Passthrough([Proceed normally])
    UsingGDD -->|Yes| CheckInit{docs/gdd/ initialized?}
    CheckInit -->|No| RunInit["/gdd:init<br>Scan project, classify,<br>generate diagrams"]
    CheckInit -->|Yes| EnterPlan[EnterPlanMode<br>Read diagrams, analyze impact,<br>DDD analysis if needed]
    RunInit --> ReviewInit[User reviews & corrects<br>generated diagrams]
    ReviewInit --> EnterPlan

    EnterPlan --> WriteDraft[Write draft-plan to<br>docs/gdd/drafts/]
    WriteDraft --> ExitPlan[ExitPlanMode<br>Present summary for approval]
    ExitPlan -->|Rejected| EnterPlan
    ExitPlan -->|Approved| ApplyDiagrams[Apply changes to docs/gdd/<br>Delete draft file]
    ApplyDiagrams --> DiagramReview[Subagent diagram review]
    DiagramReview --> DiagramVerdict{Verdict}
    DiagramVerdict -->|NEEDS_WORK / BLOCKED| FixDiagrams[Fix critical issues<br>in docs/gdd/]
    FixDiagrams --> DiagramReview
    DiagramVerdict -->|APPROVED / APPROVED_WITH_WARNINGS| ReadyToCode[Diagrams approved]

    ReadyToCode --> RunCode["/gdd:code task<br>Extract constraints,<br>implement code"]
    RunCode --> CodeReview[Subagent code review<br>Diagram alignment +<br>Code quality]
    CodeReview --> CodeVerdict{Verdict}
    CodeVerdict -->|NEEDS_WORK| FixCode[Fix critical issues<br>in code files]
    FixCode --> CodeReview
    CodeVerdict -->|APPROVED / APPROVED_WITH_WARNINGS| Done([Implementation complete])
```

## Key Decisions

- The `using-gdd` skill invokes `gdd:plan` directly — the user does not need to type `/gdd:plan`
- `/gdd:plan` uses `EnterPlanMode`/`ExitPlanMode` as the user approval gate — the draft file bridges plan mode to execution mode
- The draft file holds the full Before/After diagram diffs; `ExitPlanMode` presents only a human-readable summary
- Both plan and code phases use a subagent fix-and-retry loop to self-heal critical issues
- Bug fixes and non-feature tasks are caught early by `using-gdd` and bypass the GDD flow entirely
- Deviations discovered during coding are recorded in `docs/gdd/drafts/` rather than silently applied

## Notes

- Cross-reference: `arch-modules.md` shows which files implement each step
- The `using-gdd` skill handles routing logic and invokes `gdd:plan` automatically for feature tasks
- SessionStart hook injects GDD routing guidance at the start of each session
