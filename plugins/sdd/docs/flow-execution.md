# SDD Skill Execution Flow

> **Type**: Flow
> **Last Updated**: 2026-04-07
> **Covers**: End-to-end flow from user describing a task to documents, diagrams, and code being approved

## Diagram

```mermaid
flowchart TD
    Start([User describes a task])

    Start --> UsingSDD{"using-sdd skill<br>feature task?"}
    UsingSDD -->|No — bug fix / docs| Passthrough([Proceed normally])
    UsingSDD -->|Yes| EnterPlan[EnterPlanMode<br>Read docs & diagrams, analyze impact,<br>DDD analysis if needed]

    EnterPlan --> ExitPlan[ExitPlanMode<br>Present summary for approval]
    ExitPlan -->|Rejected| EnterPlan
    ExitPlan -->|Approved| ApplyDocs[Apply changes to docs/<br>Create/update doc-*.md, flow-*.md, arch-*.md]
    ApplyDocs --> DiagramReview[Subagent diagram review]
    DiagramReview --> DiagramVerdict{Verdict}
    DiagramVerdict -->|NEEDS_WORK / BLOCKED| FixDiagrams[Fix critical issues<br>in docs/]
    FixDiagrams --> DiagramReview
    DiagramVerdict -->|APPROVED / APPROVED_WITH_WARNINGS| ReadyToCode[Documents and diagrams approved]

    ReadyToCode --> RunCode["sdd:code task<br>Extract constraints,<br>implement code"]
    RunCode --> CodeReview[Subagent code review<br>Doc/diagram alignment +<br>Code quality]
    CodeReview --> CodeVerdict{Verdict}
    CodeVerdict -->|NEEDS_WORK| FixCode[Fix critical issues<br>in code files]
    FixCode --> CodeReview
    CodeVerdict -->|APPROVED / APPROVED_WITH_WARNINGS| Done([Implementation complete])
```

## Key Decisions

- The `using-sdd` skill invokes `sdd:plan` directly — the user does not need to type a command
- `sdd:plan` uses `EnterPlanMode`/`ExitPlanMode` as the user approval gate
- Both plan and code phases use a subagent fix-and-retry loop to self-heal critical issues
- Bug fixes and non-feature tasks are caught early by `using-sdd` and bypass the SDD flow entirely
- Deviations discovered during coding are recorded in `docs/drafts/` rather than silently applied
- `docs/` is auto-initialized if missing — the plan step creates initial documents and diagrams as needed

## Notes

- Cross-reference: `arch-modules.md` shows which files implement each step
- The `using-sdd` skill handles routing logic and invokes `sdd:plan` automatically for feature tasks
- SessionStart hook injects SDD routing guidance at the start of each session
