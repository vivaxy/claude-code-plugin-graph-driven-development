# cadence Skill Execution Flow

> **Type**: Sequence
> **Last Updated**: 2026-05-03
> **Covers**: End-to-end flow from user describing a feature to delivery, driven by per-session folder file handoffs

## Diagram

```mermaid
sequenceDiagram
  participant User
  participant Routing as using-cadence
  participant Clarify as clarify agent
  participant Plan as plan agent
  participant Impl as implement agent
  participant Review as review agent
  participant Deliver as deliver agent
  participant Folder as Session Folder

  User->>Routing: Describes a feature task
  Routing->>Folder: Look for existing session folder
  alt No session folder
    Routing->>Clarify: Invoke
    Clarify->>User: AskUserQuestion — clarifying questions
    User-->>Clarify: Answers
    Clarify->>Folder: Create <project>/.claude/sessions/YYYY-MM-DD-<slug>/<br>Write clarify.md (status: complete)
    Clarify-->>Routing: (path, summary)
  end

  Routing->>Folder: Read frontmatter to find next phase
  alt No plan.md
    Routing->>Plan: Invoke (path to clarify.md)
    Plan->>Folder: Read clarify.md
    Plan->>Plan: Design diagrams, draft plan
    Plan-->>User: ExitPlanMode — request approval
    User-->>Plan: Approves
    Plan->>Folder: Write plan.md (status: complete)
    Plan-->>Routing: (path, summary)
  end

  Routing->>Folder: Read plan.md, find next implement-step-N.md to write
  loop For each step
    Routing->>Impl: Invoke (path to plan.md, step N)
    Impl->>Folder: Read plan.md and prior implement-step-*.md
    Impl->>Folder: Write implement-step-N.md (status: complete)
    Impl-->>Routing: (path, summary)
  end

  Routing->>Review: Invoke (path to session folder)
  Review->>Folder: Read plan.md + implement-step-*.md
  Review->>Folder: Write review.md (status: complete)
  Review-->>Routing: (path, verdict)

  Routing->>Deliver: Invoke (path to session folder)
  Deliver->>Folder: Read all prior md files
  Deliver->>Folder: Write deliver.md (status: complete)
  Deliver-->>Routing: (path, summary)
  Routing->>Folder: Read deliver.md
  Routing-->>User: Surface Final Summary section
```

## Key Decisions

- Each phase reads prior md files from the session folder and writes its own md file; subagent returns are one-line `(path, summary)` handoffs (from plan: cadence-session-folders)
- Resume is detection: a fresh session reads the folder, identifies the latest written phase by frontmatter `status`, and continues from the next step (from plan: cadence-session-folders)
- `plan` agent uses `EnterPlanMode`/`ExitPlanMode` as the user approval gate — no code is written until the user approves
- `review` runs the full test suite as part of end-to-end acceptance
- Implement is invoked once per step; resume identifies the last completed step from the highest-N `implement-step-*.md` with `status: complete` (from plan: cadence-session-folders)

## Notes

- Cross-reference: `c4-component-plugin.md` shows which files implement each component in this sequence
- Cross-reference: `c4-containers.md` shows the container-level structure these components belong to
- SessionStart hook injects Cadence routing guidance at the start of each session
