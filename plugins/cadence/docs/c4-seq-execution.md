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
    Clarify->>Folder: Create folder + write minimal session.md with ### Clarification ticked under ## CheckList and ## Clarification body filled
    Clarify-->>Routing: Wrote session.md to <path>. <type-hint>.
    Routing->>User: AskUserQuestion — confirm session type
    User-->>Routing: Confirms type
    Routing->>Folder: Copy templates/<type>.md into session.md, then re-apply ticked ### Clarification + filled ## Clarification body
  end

  loop Until every ### sub-section under ## CheckList is fully ticked
    Routing->>Folder: Walk ## CheckList top-to-bottom
    Routing->>Routing: Find first ### Sub-section with any unchecked item; look up owner
    alt Owner is plan agent
      Routing->>Plan: Spawn (passes session folder path)
      Plan->>Folder: Read session.md (Clarification section)
      Plan->>Plan: Draft plan body
      Plan-->>User: ExitPlanMode — show plan body for approval
      User-->>Plan: Approves
      Plan->>Folder: Fill ## Plan blanks, populate ### Implementation work items, tick ### Plan
      Plan-->>Routing: Wrote ## Plan to session.md. <one-line summary>
    else Owner is another agent
      Routing->>Impl: Spawn [example owner]
      Impl->>Folder: Read session.md, do work, tick owned ### sub-section, fill matching ## body
      Impl-->>Routing: Wrote ticks to session.md. <one-line summary>
    else Owner is main thread (### Answer)
      Routing->>User: Answer directly and tick ### Answer items
    end
  end

  Routing->>Folder: All ### sub-sections ticked — pick terminal output (deliver agent handoff for build/analysis sessions, ## Answer body for trivial sessions)
  Routing-->>User: Final summary (from deliver handoff text or ## Answer body — never read from a ### Final Summary block)
```

## Key Decisions

- Each phase agent owns one `### <Sub-section>` under `## CheckList` and (where applicable) the matching `## <Section>` body; the agent ticks checklist items in place and replaces `<!-- TODO: ... -->` placeholders; subagent returns are one-line handoffs pointing at `session.md` (from plan: cadence-template-driven-checklists, cadence-checklist-collapse)
- Resume is detection: a fresh session reads `session.md`, walks `## CheckList` top-to-bottom, finds the first `### <Sub-section>` with any `- [ ]` item, and spawns its owner per the sub-section→owner mapping (from plan: cadence-template-driven-checklists, cadence-checklist-collapse)
- `plan` agent uses `EnterPlanMode`/`ExitPlanMode` as the user approval gate; the body shown to the user is the same body written into `## Plan` of `session.md` — code only changes after approval (from plan: cadence-template-driven-checklists)
- `review` runs the full test suite as part of end-to-end acceptance
- Implement is invoked once per `- [ ]` item under `## CheckList` → `### Implementation`; resume identifies the next step from the first remaining unchecked item (from plan: cadence-template-driven-checklists, cadence-checklist-collapse)
- After clarify returns, the routing skill calls `AskUserQuestion` to confirm session type and copies the matching template into `session.md` before spawning the next agent (from plan: cadence-template-driven-checklists)

## Notes

- Cross-reference: `c4-component-plugin.md` shows which files implement each component in this sequence
- Cross-reference: `c4-containers.md` shows the container-level structure these components belong to
- SessionStart hook injects Cadence routing guidance at the start of each session
