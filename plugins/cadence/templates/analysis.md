# Analysis Session

> Session type: analysis. Use when the request is to investigate a multi-layered problem, surface root causes, and hand off findings without implementing a fix. Routing flows clarify → analyze-problem → deliver.

## Clarification

- [ ] Probe technical unknowns and ask clarifying questions until scope, constraints, and success criteria are clear
- [ ] Confirm understanding with the user
- [ ] Write the clarification body and session-type hint into `session.md` and return the terminal handoff line

## Analysis

- [ ] Restate the problem and collect facts (Verified / Challenged Assumptions / Hard Constraints / Evidence Gaps)
- [ ] Decompose into MECE sub-problems, trace root causes, build a Mermaid model, derive 3–7 Key Questions
- [ ] Write the analysis body into `## Analysis` and return the terminal handoff line

## Delivery

- [ ] Read `session.md` end-to-end (including `## Analysis` findings) and `git log --oneline -20`
- [ ] Compose the Retrospective and Final Summary; offer to persist Learnings and Open Items per `agents/deliver.md`
- [ ] Write both bodies into `## Delivery` and return the terminal handoff line
