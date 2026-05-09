
### Plan

- [ ] Read `## Clarification` (and `## Analysis` when present); identify which `docs/` diagrams need creation or update under C4 level criteria
- [ ] Draft the plan body; if in plan mode call `ExitPlanMode`, otherwise print plan as Markdown in conversation then call `AskUserQuestion` — the body shown to the user equals the body persisted to `## Plan`
- [ ] On approval, replace every `<!-- TODO: filled by plan agent -->` placeholder under `## Plan` with the drafted content, populate `### Implementation` under `## CheckList` with one `- [ ]` work item per implementation step, and tick this sub-section
- [ ] On rejection, run the NEEDS_CLARIFICATION handoff (see `agents/plan.md`)
- [ ] Return the terminal handoff line
