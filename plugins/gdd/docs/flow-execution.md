# GDD Skill Execution Flow

> **Type**: Flow
> **Last Updated**: 2026-04-16
> **Covers**: End-to-end flow from user describing a task to documents, diagrams, and code being approved

## Diagram

```mermaid
flowchart TD
    Start([User describes a task])

    Start --> UsingGDD{"using-gdd skill<br>feature task?"}
    UsingGDD -->|No — bug fix / docs| Passthrough([Proceed normally])
    UsingGDD -->|Yes| CheckDocs{"docs/ initialized?<br>(flow-*.md + arch-*.md exist)"}
    CheckDocs -->|No| AutoInit["Auto-generate docs/<br>Scan project, create<br>design docs + diagrams"]
    CheckDocs -->|Yes| EnterPlan[EnterPlanMode<br>Read docs, analyze impact,<br>DDD analysis if needed]
    AutoInit --> EnterPlan

    EnterPlan --> WriteDocs["Write design doc + diagram changes<br>(doc-*.md, flow-*.md, arch-*.md)"]
    WriteDocs --> ExitPlan[ExitPlanMode<br>Present full proposal for approval]
    ExitPlan -->|Rejected| EnterPlan
    ExitPlan -->|Approved| ApplyDocs["Apply changes to docs/<br>Write all approved files"]
    ApplyDocs --> DocReview[Subagent design review]
    DocReview --> DocVerdict{Verdict}
    DocVerdict -->|NEEDS_WORK / BLOCKED| FixDocs["Fix critical issues<br>in docs/"]
    FixDocs --> DocReview
    DocVerdict -->|APPROVED / APPROVED_WITH_WARNINGS| ReadyToCode[Documents + diagrams approved]

    ReadyToCode --> RunCode["gdd:code skill<br>Extract constraints,<br>implement code"]
    RunCode --> CodeReview[Subagent code review<br>Alignment +<br>Code quality]
    CodeReview --> CodeVerdict{Verdict}
    CodeVerdict -->|NEEDS_WORK| FixCode[Fix critical issues<br>in code files]
    FixCode --> CodeReview
    CodeVerdict -->|APPROVED / APPROVED_WITH_WARNINGS| Done([Implementation complete])
```

## Key Decisions

- The `using-gdd` skill is the single entry point — it detects feature tasks and drives the entire workflow automatically
- When `docs/` is missing, the agent auto-generates it (no user action required)
- Design documents (`doc-*.md`) are written first, then diagrams are updated to reflect the design
- Both plan and code phases use a subagent fix-and-retry loop to self-heal critical issues
- Bug fixes and non-feature tasks are caught early by `using-gdd` and bypass the GDD flow entirely
- Deviations discovered during coding are recorded in `docs/drafts/` rather than silently applied
- There are no slash commands — all steps are executed as skills

## Notes

- Cross-reference: `arch-modules.md` shows which files implement each step
- The `using-gdd` skill handles routing logic and invokes `gdd:plan` automatically for feature tasks
- SessionStart hook injects GDD routing guidance at the start of each session
