---
name: cadence:using-cadence
description: Guide for when to apply Cadence — read at session start to understand when Cadence applies and what to do first
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

# Using Cadence

Cadence enforces a session-type-specific procedure. Every non-trivial session starts with `main:clarify`, which detects the session type. The procedure for the rest of the session is determined by that type.

## Session Types and Their Procedures

| Session Type | Procedure |
|---|---|
| `feature-dev` | clarify → plan → implement → review → deliver |
| `bugfix` | clarify → reproduce → diagnose → fix → verify |
| `doc-writing` | clarify → collect facts -> outline → write → review |

## Routing Logic

### 1. Clarification gate — clarify when the request is not covered

Invoke the `clarify` agent when either:
- No clarification summary exists in the current conversation, OR
- The request is unrelated to the established session (different problem domain, different goal)

### 2. Clarification verified → route by session type

Use the Session Type from the clarification summary in the current conversation, then route:

| Session Type | Condition | Route to |
|---|---|---|
| `feature-dev` | No plan in conversation | `cadence:main:plan` |
| `feature-dev` | Plan approved, not yet reviewed | `cadence:main:review` → `cadence:main:deliver` |
| `bugfix` | Any state | `cadence:main:bugfix` |
| `doc-writing` | Any state | `cadence:main:doc-writing` |
| `architecture` | Any state | `cadence:main:architecture` |

## How to Route

Do not wait for user confirmation before routing. Immediately:

1. Say one line: "Cadence is active — routing to `cadence:<skill>`."
2. Invoke the appropriate skill.

## Trivial tasks — still clarify if no session established

Even for trivial tasks, apply the clarification gate. If no clarification summary exists, invoke `cadence:main:clarify` first. Only skip clarification when a session is already established and the request clearly fits within it.

## Instruction Priority

1. User's explicit instructions (CLAUDE.md, direct requests) — highest
2. Cadence routing — for all non-trivial tasks
3. Default behavior — for everything else

If the user says "just implement it, skip the workflow" — respect that.
