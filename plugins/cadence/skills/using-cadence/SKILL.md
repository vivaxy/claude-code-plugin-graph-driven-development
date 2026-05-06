---
name: cadence:using-cadence
description: Routing skill for Cadence — read at session start to detect or create a session and spawn the agent that owns the next unchecked section of session.md
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

# Using Cadence

Cadence drives every task through one per-session checklist file:

- Path: `<project>/.claude/sessions/YYYY-MM-DD-<slug>/session.md`
- One file per session. Each `## <Section>` heading is owned by exactly one agent (or the main thread). Sections contain `- [ ]` items the owner ticks to `- [x]` as work completes.
- Side artifacts may live alongside `session.md`; only `session.md` is consulted by routing.

Routing reduces to: read `session.md`, find the first section with any unchecked item, spawn that section's owner.

## Heading → Owner Mapping

Single source of truth for routing.

| Section heading | Owner |
|---|---|
| `## Clarification` | `clarify` agent |
| `## Analysis` | `analyze-problem` agent |
| `## Plan` | `plan` agent |
| `## Implementation` | `implement` agent |
| `## Review` | `review` agent |
| `## Delivery` | `deliver` agent |
| `## Answer` | main thread |

## When Routing Runs

Run on every user prompt — including natural-language requests, explicit `/skill-name` slash commands, and meta-questions about Cadence ("is Cadence active?"). Skip only when the user explicitly opts out ("skip the workflow", "just answer"). When in doubt, run routing.

## Activation Announcement

Before any tool work, post one visible line per turn:

```
Cadence is active — routing this turn.
```

## Routing Algorithm

1. **Find session folder.** Project root via `git rev-parse --show-toplevel` (fallback `pwd`). Search `<project>/.claude/sessions/` for `YYYY-MM-DD-*/`. Newest by name (lexicographic max — folder names are date-prefixed and sortable) = active.
2. **Confirm resume vs. new** when a folder exists. `AskUserQuestion`: "An in-progress Cadence session was found at `<path>`. Continue or start new?" with options `["Continue existing", "Start new"]`. On "Start new", fall through to step 4.
3. **Walk `session.md` top-to-bottom.** Find the first `## <Section>` whose body contains any `- [ ]`. Spawn its owner (see "How to Spawn"). If `## Answer`, the main thread answers and ticks items. If every section is ticked, surface `### Final Summary` (or `## Answer` body) to the user.
4. **Spawn `clarify`** when no `session.md` exists. It creates the session folder, writes a minimal `session.md` with a ticked `## Clarification`, and returns a session-type hint.
5. **Confirm session type and copy template** (after step 4 only). See "Post-Clarify Template Copy".
6. **Re-route** to step 3.

## Post-Clarify Template Copy

After `clarify` returns for a brand-new session:

1. **Confirm session type** via `AskUserQuestion` (pre-select the agent's hint):
   - `trivial` — small change or factual question; ends after `## Answer`
   - `feature-dev` — new behavior or doc work; full plan/implement/review/deliver
   - `bugfix` — broken behavior; analysis runs before plan
   - `analysis` — diagnostic; ends after `## Delivery`
2. **Capture** the ticked `## Clarification` block clarify just wrote.
3. **Copy template via `cp`**: `cp "${CLAUDE_PLUGIN_ROOT:-$CURSOR_PLUGIN_ROOT}/templates/<type>.md" "<session-folder>/session.md"`. Use `cp`, not `Write` (Write guard rails reject filenames containing "analysis").
4. **Re-apply** the captured `## Clarification` block via `Edit`, replacing the template's blank section.
5. **Re-route** to step 3.

## Plan Mode

Cadence drives the workflow regardless of plan mode. The `plan` agent owns plan mode internally — always spawn `plan` rather than calling `EnterPlanMode` on the main thread. If plan mode is active when routing fires, call `ExitPlanMode` first to unblock `Agent`, then spawn `plan`.

## How to Spawn

1. Announce: "Cadence is active — spawning `<agent>` agent." (or "answering directly under `## Answer`.")
2. Spawn via `Agent` tool. Always pass the session folder absolute path in the prompt.
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
5. Re-route to step 3 of the Routing Algorithm.

## Instruction Priority

1. User's explicit instructions (CLAUDE.md, direct requests) — highest.
2. Cadence routing — applies by default.
3. Default behavior — everything else.

Honor "skip the workflow" or equivalent opt-outs.
