---
name: cadence:using-cadence
description: Cadence workflow router — invoke when starting any feature, bugfix, or analysis task.
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

# Using Cadence

Cadence drives every task through one per-session checklist file:

- Path: `<project>/.claude/sessions/YYYY-MM-DD-<slug>/session.md`
- One file per session. The single `## CheckList` section groups every workflow item under `### <Sub-section>` headings; each sub-section is owned by exactly one agent (or the main thread) and contains `- [ ]` items the owner ticks to `- [x]` as work completes. Body sections (`## Clarification`, `## Analysis`, `## Plan`, `## Review`, `## Delivery`, `## Answer`) hold the structured content the agents fill in.
- Side artifacts may live alongside `session.md`; only `session.md` is consulted by routing.

Routing reduces to: read `session.md`, walk `## CheckList` top-to-bottom, find the first `### <Sub-section>` with any unchecked item, spawn that sub-section's owner.

## Sub-section → Owner Mapping

Single source of truth for routing. The mapped sub-section lives under `## CheckList`.

| `## CheckList` sub-section | Owner |
|---|---|
| `### Clarification` | `clarify` agent |
| `### Analysis` | `analyze-problem` agent |
| `### Plan` | `plan` agent |
| `### Implementation` | `implement` agent |
| `### Review` | `review` agent |
| `### Delivery` | `deliver` agent |
| `### Answer` | main thread |

## When Routing Runs

Run on every user prompt — including natural-language requests, explicit `/skill-name` slash commands, and meta-questions about Cadence ("is Cadence active?"). Skip only when the user explicitly opts out ("skip the workflow", "just answer"). When in doubt, run routing.

## Activation Announcement

Before any tool work, post one visible line per turn:

```
Cadence is active — routing this turn.
```

## Routing Algorithm

1. **Identify the active session folder.** Read the session folder absolute path from the current conversation context — parent-agent prompt, earlier turn, or user-supplied path. When a path is present, take it as the active session folder and proceed to step 2. When no path is present, record that no active session was found and fall through to step 3.
2. **Walk `## CheckList` in `session.md` top-to-bottom.** Find the first `### <Sub-section>` whose item list contains any `- [ ]`. Spawn its owner (see "How to Spawn"). If `### Answer`, the main thread answers and ticks items. If every sub-section is ticked, surface the deliver agent's Final Summary handoff text (or the `## Answer` body) to the user — the Final Summary lives in conversation only and is never read back from `session.md`.
3. **Spawn `clarify`** when no `session.md` exists. It creates the session folder, writes a minimal `session.md` with a ticked `### Clarification` under `## CheckList` plus a filled `## Clarification` body, and returns a session-type hint.
4. **Confirm session type and copy template** (after step 3 only). See "Post-Clarify Template Copy".
5. **Re-route** to step 2.

## Post-Clarify Template Copy

After `clarify` returns for a brand-new session:

**Before calling `AskUserQuestion` for session-type confirmation:**
Check if the clarify handoff line contains `delegate_to_skill: <skill-name>`.
If it does:
1. Skip `AskUserQuestion` — session type is trivial.
2. Extract `<skill-name>` from the handoff.
3. Copy the trivial template: `cp "${CLAUDE_PLUGIN_ROOT:-$CURSOR_PLUGIN_ROOT}/templates/trivial.md" "<session-folder>/session.md"`.
4. Re-apply `### Clarification` ticks and `## Clarification` body (same as normal trivial path).
5. In the `### Answer` checklist item in session.md, append a note: `invoke \`<skill-name>\``.
6. Route to main thread — main thread invokes the matched skill directly.

If the handoff does not contain `delegate_to_skill`, proceed with the normal session-type confirmation below.

1. **Confirm session type** via `AskUserQuestion` (pre-select the agent's hint):
   - `trivial` — small change or factual question; ends after `### Answer` is fully ticked
   - `feature-dev` — new behavior or doc work; full plan/implement/review/deliver
   - `bugfix` — broken behavior; analysis runs before plan
   - `analysis` — diagnostic; ends after `### Delivery` is fully ticked
2. **Capture** the filled `## Clarification` body that clarify just wrote. (The `### Clarification` ticks are deterministic — clarify always ticks every item before returning — so they do not need to be captured.)
3. **Copy template via `cp`**: `cp "${CLAUDE_PLUGIN_ROOT:-$CURSOR_PLUGIN_ROOT}/templates/<type>.md" "<session-folder>/session.md"`. Use `cp`, not `Write` (Write guard rails reject filenames containing "analysis").
4. **Re-apply** via one `Edit` pass: tick every `- [ ]` item under `## CheckList` → `### Clarification` to `- [x]`, and replace the template's `## Clarification` body blanks with the captured filled body.
5. **Re-route** to step 2.

## Plan Mode

Cadence drives the workflow regardless of plan mode. The `plan` agent owns plan mode internally — always spawn `plan` rather than calling `EnterPlanMode` on the main thread. If plan mode is active when routing fires, call `ExitPlanMode` first to unblock `Agent`, then spawn `plan`.

## How to Spawn

1. Announce: "Cadence is active — spawning `<agent>` agent." (or "answering directly under `## Answer`.")
2. Spawn via `Agent` tool. Always pass the session folder absolute path in the prompt.
   When spawning the `clarify` agent for a brand-new session, also extract the installed skill list from the current session system-reminder block (the block that lists "Available skills" with descriptions). Include each skill's name and description in the spawn prompt under the key `available_skills`, formatted as:
   ```
   Available skills (name → description):
   - <skill-name>: <description>
   ...
   ```
3. Inspect terminal output. If the first line begins with `NEEDS_CLARIFICATION:`, run "Plan Rejection Recovery" below. Otherwise re-run routing.

## Plan Rejection Recovery

The `plan` agent emits 3 lines when the user rejects the plan for inadequate clarification:

```
NEEDS_CLARIFICATION: <gap>
User feedback: <verbatim>
Reuse session folder: <abs-path>
```

On detection:

1. Call `ExitPlanMode` to unblock `Agent` (no-op if already inactive).
2. Strip `Reuse session folder: ` from line 3 to get the absolute path.
3. Announce: "Cadence is active — re-spawning `clarify` agent to address the rejected clarification."
4. Re-spawn `clarify` via `Agent` with `reuse_folder: <path>` plus the gap and user feedback. Clarify overwrites `## Clarification` in place.
5. Re-route to step 2 of the Routing Algorithm.

## Instruction Priority

1. User's explicit instructions (CLAUDE.md, direct requests) — highest.
2. Cadence routing — applies by default.
3. Default behavior — everything else.

Honor "skip the workflow" or equivalent opt-outs.
