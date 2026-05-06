---
name: cadence:using-cadence
description: Routing skill for Cadence — read at session start to detect or create a session and spawn the agent that owns the next unchecked section of session.md
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

# Using Cadence

Cadence drives every task — including trivial ones — through a single per-session checklist file:

- Path: `<project>/.claude/sessions/YYYY-MM-DD-<slug>/session.md`
- One file per session. Each `## <Section>` heading is owned by exactly one agent (or by the main thread). Sections contain `- [ ]` checklist items the owning agent ticks to `- [x]` as it works.
- Side artifacts (analysis figures, plan diagrams the agents emit) may live alongside `session.md` in the same folder; only `session.md` is consulted by routing.

Routing reduces to: read `session.md`, find the first section with any unchecked item, spawn that section's owner.

## Activation Announcement

Always post a single visible line to the user the first time routing fires in a turn, before doing any tool work:

```
Cadence is active — routing this turn.
```

This makes activation observable. It is required even when the next step is a trivial `## Answer` handled by the main thread. Emit it once per turn, before step 1 of the routing algorithm.

## Heading → Owner Mapping

This mapping is the single source of truth for routing. Every section in every template uses one of these headings.

| Section heading | Owner |
|---|---|
| `## Clarification` | `clarify` agent |
| `## Analysis` | `analyze-problem` agent |
| `## Plan` | `plan` agent |
| `## Implementation` | `implement` agent |
| `## Review` | `review` agent |
| `## Delivery` | `deliver` agent |
| `## Answer` | main thread (no agent spawned) |

## Plan Mode

Plan mode does not skip Cadence — Cadence drives the whole workflow regardless. The `plan` agent manages plan mode internally via its own `EnterPlanMode`/`ExitPlanMode` calls. Always spawn the `plan` agent rather than calling `EnterPlanMode` directly on the main thread when Cadence is active. If Claude Code plan mode is already active when Cadence routing fires, call `ExitPlanMode` first to unblock the `Agent` tool, then spawn the `plan` agent normally.

## Routing Algorithm

Run this on every Cadence-relevant turn (new request or resume):

1. **Find the active session folder.** Determine the project root via `git rev-parse --show-toplevel` (fall back to `pwd`). Look in `<project>/.claude/sessions/` for folders matching `[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-*/`.
   - If one or more exist, treat the most recently modified folder as the active session folder. Read its `session.md`.
   - If no folders exist, treat the request as a new session: skip ahead to step 4 to spawn `clarify`.
2. **Confirm resume vs. new session** when a folder exists. Use `AskUserQuestion`: "An in-progress Cadence session was found at `<path>`. Continue this session, or start a new one?" with options `["Continue existing", "Start new"]`.
   - On "Continue existing": treat the chosen folder as active and proceed to step 3.
   - On "Start new": fall through to step 4 to spawn `clarify` (which will create a fresh folder).
3. **Walk `session.md` top-to-bottom.** Find the first `## <Section>` heading whose body contains any `- [ ]` item.
   - Look up the section's owner in the mapping above.
   - If the owner is an agent: spawn that agent (see "How to Spawn" below).
   - If the owner is the main thread (`## Answer`): answer the user directly and tick the items in `## Answer` via `Edit` as they are satisfied.
   - If every section is fully ticked, the session is complete: surface the terminal section's content to the user (the `### Final Summary` block under `## Delivery`, or the body of `## Answer` for trivial sessions).
4. **Spawn `clarify` for a brand-new session.** When no `session.md` exists yet, spawn the `clarify` agent. It derives a slug, creates the session folder, writes a minimal `session.md` containing `## Clarification` with all items ticked, and returns a one-line handoff that includes a session-type hint.
5. **Confirm session type and copy the template** (runs immediately after `clarify` returns its handoff for a brand-new session). See "Post-Clarify Template Copy" below.
6. **Re-route** by going back to step 3: read the freshly populated `session.md` and spawn the owner of its first unchecked section.

## Post-Clarify Template Copy

After the `clarify` agent returns its handoff for a brand-new session, the router runs these substeps before re-routing:

1. **Confirm the session type with the user.** Use `AskUserQuestion` with these five options (pre-select the agent's hinted type when present):

   - `trivial` — small or localized change, or a factual question; terminates after `## Answer`
   - `feature-dev` — new behavior; full plan / implement / review / deliver flow
   - `bugfix` — broken behavior; analysis runs before plan
   - `doc-writing` — documentation work
   - `analysis` — diagnostic or exploratory; terminates after `## Delivery` of analysis findings

2. **Capture the ticked `## Clarification` block** that `clarify` just wrote. Read the existing minimal `session.md` and remember the exact text of the `## Clarification` section (including all `- [x]` items and any sub-bullets the agent added).

3. **Copy the template via the Bash tool with `cp`.** Run:

   ```bash
   cp "${CLAUDE_PLUGIN_ROOT:-$CURSOR_PLUGIN_ROOT}/templates/<type>.md" "<session-folder>/session.md"
   ```

   Always use the `cp` command for this copy. The Write tool guard rails false-positive on filenames containing the literal word "analysis"; `cp` avoids that issue and is the only supported mechanism for the template copy step.

4. **Re-apply the captured `## Clarification` block** to the new `session.md` via `Edit`, replacing the template's blank `## Clarification` section with the ticked block from substep 2. This preserves the work `clarify` already did.

5. **Re-route** by going back to step 3 of the routing algorithm — read the populated `session.md` and spawn the owner of its first unchecked section.

## Session-Type Short-Circuits

The session-type templates encode terminal phases. The router's only behavior is "spawn the owner of the first unchecked section", and the templates make the short-circuits work automatically:

- **Trivial sessions** contain only `## Clarification` and `## Answer`. After `clarify` ticks `## Clarification`, routing lands on `## Answer` → main thread answers directly and ticks the items. The only spawned agent is `clarify`.
- **Analysis sessions** contain only `## Clarification`, `## Analysis`, and `## Delivery`. Routing goes clarify → `analyze-problem` → `deliver`. The `plan`, `implement`, and `review` agents stay out of the flow entirely.
- **Feature-dev**, **bugfix**, and **doc-writing** sessions run the full clarify → (analyze if present) → plan → implement → review → deliver chain.

## Resume

Resume IS routing — there is no separate resume mechanism. On any new turn:

1. Apply the routing algorithm above (steps 1 through 6).
2. Step 1 detects the existing session folder; step 2 confirms continue vs. new; step 3 reads `session.md` and spawns the owner of the first unchecked section.

This means a fresh Claude session that walks into a half-finished `session.md` will pick up at exactly the right phase by reading one file.

## How to Spawn

When the routing algorithm decides to spawn an agent or hand to the main thread:

1. Say one line announcing the destination, matched to the owner:
   - Spawning an agent: "Cadence is active — spawning `<agent>` agent."
   - Main thread takes over: "Cadence is active — answering directly under `## Answer`."
2. Spawn the agent via the `Agent` tool. Always pass the session folder absolute path in the prompt — every agent reads `session.md` from that folder.
3. Inspect the agent's terminal output:
   - When the first line begins with `NEEDS_CLARIFICATION:`, treat the output as a plan-rejection handoff and apply the "Plan Rejection Recovery" procedure below before re-routing.
   - Otherwise, re-run the routing algorithm to decide what spawns next.

## Plan Rejection Recovery

The `plan` agent emits a 3-line terminal message when the user rejects the plan via `ExitPlanMode` for inadequate clarification:

- Line 1: `NEEDS_CLARIFICATION: <one-line description of the gap>`
- Line 2: `User feedback: <verbatim user rejection>`
- Line 3: `Reuse session folder: <absolute-path-to-session-folder>`

When the router observes this exact format from a spawned agent, always run these substeps before re-entering the routing algorithm:

1. **Clear plan mode if active.** Call `ExitPlanMode` on the main thread to unblock the `Agent` tool. The plan agent already exited plan mode internally before emitting the handoff; this step is a no-op when plan mode is already inactive.
2. **Extract the reuse path** from line 3 by stripping the literal `Reuse session folder: ` prefix. Treat the remainder as the absolute path to the existing session folder.
3. **Announce the recovery** with one line: "Cadence is active — re-spawning `clarify` agent to address the rejected clarification."
4. **Re-spawn the `clarify` agent** via the `Agent` tool. Always include `reuse_folder: <path>` in the prompt alongside the line-1 gap description and line-2 user feedback. The `clarify` agent uses `reuse_folder` to overwrite the existing `## Clarification` section in place rather than creating a new session folder.
5. **Re-route after `clarify` returns.** Go back to step 3 of the Routing Algorithm — read the freshly populated `session.md` and spawn the owner of the first unchecked section. The plan agent's pre-handoff edits already reset `## Clarification` to `- [ ]` and skeletoned `## Plan`, so routing naturally lands on `## Clarification` first, then `## Plan`.

## User Questions

The router uses `AskUserQuestion` whenever it needs input from the user — at minimum the resume prompt (step 2) and the post-clarify session-type confirmation. Any future routing question goes through the same tool.

## Instruction Priority

1. The user's explicit instructions (CLAUDE.md, direct requests) — highest.
2. Cadence routing — applies to every task by default.
3. Default behavior — for everything else.

If the user says "just implement it, skip the workflow", honor that.
