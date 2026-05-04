# cadence Skill Execution Flow

> **Type**: Sequence
> **Last Updated**: 2026-05-04
> **Covers**: End-to-end flow from user describing a feature to delivery, driven by checklists in a single `session.md` per session

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
  Routing->>Folder: Look for existing session.md
  alt No session.md
    Routing->>Clarify: Spawn (no template yet)
    Clarify->>User: AskUserQuestion — clarifying questions
    User-->>Clarify: Answers
    Clarify->>Folder: Create folder + write minimal session.md with ## Clarification ticked
    Clarify-->>Routing: Wrote session.md to <path>. <type-hint>.
    Routing->>User: AskUserQuestion — confirm session type
    User-->>Routing: Confirms type
    Routing->>Folder: Copy templates/<type>.md into session.md (preserving ticked ## Clarification)
  end

  loop Until every section is fully ticked
    Routing->>Folder: Read session.md top-to-bottom
    Routing->>Routing: Find first ## Section with any unchecked item; look up owner
    alt Owner is plan agent
      Routing->>Plan: Spawn (passes session folder path)
      Plan->>Folder: Read session.md (Clarification section)
      Plan->>Plan: Draft plan body
      Plan-->>User: ExitPlanMode — show plan body for approval
      User-->>Plan: Approves
      Plan->>Folder: Write plan body into ## Plan + tick procedural checklist
      Plan-->>Routing: Wrote ## Plan to session.md. <one-line summary>
    else Owner is another agent
      Routing->>Impl: Spawn [example owner]
      Impl->>Folder: Read session.md, do work, tick owned section
      Impl-->>Routing: Wrote ticks to session.md. <one-line summary>
    else Owner is main thread (## Answer)
      Routing->>User: Answer directly and tick ## Answer items
    end
  end

  Routing->>Folder: All sections ticked — surface terminal section content (## Delivery or ## Answer)
  Routing-->>User: Final summary
```

## Key Decisions

- Each phase agent owns exactly one `## <Section>` of `session.md` and ticks its checklist items in place; subagent returns are one-line handoffs pointing at `session.md` (from plan: cadence-template-driven-checklists)
- Resume is detection: a fresh session reads `session.md`, finds the first section with any `- [ ]` item, and spawns its owner per the heading→owner mapping (from plan: cadence-template-driven-checklists)
- `plan` agent uses `EnterPlanMode`/`ExitPlanMode` as the user approval gate; the body shown to the user is the same body written into `## Plan` of `session.md` — code only changes after approval (from plan: cadence-template-driven-checklists)
- `review` runs the full test suite as part of end-to-end acceptance
- Implement is invoked once per `- [ ]` item under `## Implementation`; resume identifies the next step from the first remaining unchecked item (from plan: cadence-template-driven-checklists)
- After clarify returns, the routing skill calls `AskUserQuestion` to confirm session type and copies the matching template into `session.md` before spawning the next agent (from plan: cadence-template-driven-checklists)

## Notes

- Cross-reference: `c4-component-plugin.md` shows which files implement each component in this sequence
- Cross-reference: `c4-containers.md` shows the container-level structure these components belong to
- SessionStart hook injects Cadence routing guidance at the start of each session
