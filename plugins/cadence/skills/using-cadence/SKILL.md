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
| `feature-dev` | clarify → plan → subtask-execute loop → review → deliver |
| `bugfix` | clarify → reproduce → diagnose → fix → verify |
| `doc-writing` | clarify → collect facts -> outline → write → review |

## Routing Logic

### 1. Clarification gate — clarify when the request is not covered

Invoke `cadence:main:clarify` when either:
- No clarification summary exists in the current conversation, OR
- The request is unrelated to the established session (different problem domain, different goal)

### 2. Clarification verified → route by session type

Use the Session Type from the clarification summary in the current conversation, then route:

| Session Type | Condition | Route to |
|---|---|---|
| `feature-dev` | `doc-subtasks.md` does not exist | `cadence:main:plan` |
| `feature-dev` | `doc-subtasks.md` has PENDING subtasks | `cadence:subtask-execute <first-pending-id>` |
| `feature-dev` | All subtasks ACCEPTED, no retrospective | `cadence:main:review` → `cadence:main:deliver` |
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

---

## Analyze Skills

The analyze skills provide structured problem analysis and visual modeling. They are on-demand tools — invoke them when the user's question would benefit from rigorous decomposition or visual modeling.

### When to Invoke cadence:analyze:problem

Invoke when the user:
- Presents a vague, complex, or multi-layered problem ("why is X happening?", "how should I approach Y?")
- Is reasoning by analogy ("everyone does it this way, should we?") — first-principles thinking would help
- Has a problem with unclear root cause (symptoms are visible but causes are not)
- Needs to frame a problem for a team before deciding what to do
- Is stuck and not sure where to start

Note: `cadence:analyze:problem` writes a `facts.md` file and concludes with **key questions to investigate** — not action recommendations. Most valuable when the problem needs rigorous framing before action.

Do **not** invoke for:
- Simple factual questions with clear answers
- Requests to implement a specific, well-defined task
- Cases where the user has already done the analysis and just needs execution

### When to Invoke cadence:analyze:model

Invoke when the user:
- Wants to understand how a domain, system, or codebase is structured
- Is onboarding to a new area and needs a map
- Needs to communicate a concept visually (to themselves or others)
- Is designing something and wants to see the entities and relationships before writing code

### How to Invoke

Keep it lightweight — one sentence, then invoke immediately:

> "This looks like a good case for a structured analysis — running `cadence:analyze:problem` now."

Then invoke the skill via the `Skill` tool. Never force it.

If the user says "just answer it" or "skip the analysis" — respect that immediately.
