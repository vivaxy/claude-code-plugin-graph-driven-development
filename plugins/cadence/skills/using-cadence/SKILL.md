---
name: cadence:using-cadence
description: Guide for when to apply Cadence — read at session start to understand when Cadence applies and what to do first
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

# Using Cadence

## Procedure (all session types)

clarify → (analyze-problem | plan) → implement → review → deliver

## Routing Logic

### 1. Clarification gate

Invoke the `clarify` agent when either:
- No clarification summary exists in the current conversation, OR
- The request is unrelated to the established session (different problem domain, different goal)

### 2. Clarification verified → route by state

| Condition | Route to |
|---|---|
| No plan in conversation | `plan` agent |
| Plan approved, implementation not started | implement phase (see below) |
| All steps implemented and verified | `review` agent → `cadence:main:deliver` |

#### Analyze gate

Invoke the `analyze-problem` agent instead of `plan` when ALL of these are true:
- The clarification summary exists and the session type is diagnostic/exploratory
- The problem has at least one of: unclear root cause, multiple interacting sub-problems, competing hypotheses with no clear winner, or high stakes where wrong diagnosis is costly
- The user has NOT said "just answer it", "skip the analysis", or equivalent

Do NOT invoke for:
- Well-defined implementation tasks ("add a button", "fix this typo")
- Factual questions with clear answers
- Cases where the user has already done the analysis

Borderline case (ambiguous intent): ask one inline question — "This looks like a good case for structured analysis — want me to run it?" — then wait.

## Implement Phase

After the plan agent completes and the user approves the plan:

1. **Apply doc changes**: Create or update each file listed in the plan's `## Docs to Change` table.
2. **Create todos**: Read the approved plan's `## Implementation Steps` list. Call `TaskCreate` for each step — one task per step, in order.
3. **Execute each step sequentially**:
   - Mark the task `in_progress` with `TaskUpdate`.
   - Spawn a `general-purpose` subagent via the `Agent` tool. Give it the step description, the list of files to change (from the plan's "Source Code to Change" table), and full context from the plan (problem statement, constraints, key decisions).
   - After the subagent completes, verify the result: use `Read` on each file the step was supposed to change and confirm the expected change is present.
   - If verification passes: mark the task `completed` with `TaskUpdate` and proceed to the next step.
   - If verification fails: surface the failure to the user ("Step N failed verification: <what was expected vs. what was found>"). Do not proceed until resolved.
4. After all steps are verified: spawn the `review` agent via the Agent tool.

## How to Route

Do not wait for user confirmation before routing. Immediately:

1. Say one line matching the destination:
   - Spawning an agent: "Cadence is active — spawning `<agent>` agent."
   - Invoking a skill: "Cadence is active — routing to `cadence:<skill>`."
2. Spawn the agent (via Agent tool) or invoke the skill (via Skill tool) as appropriate.

## Trivial tasks — still clarify if no session established

Even for trivial tasks, apply the clarification gate. If no clarification summary exists, spawn the `clarify` agent first. Only skip clarification when a session is already established and the request clearly fits within it.

## Instruction Priority

1. User's explicit instructions (CLAUDE.md, direct requests) — highest
2. Cadence routing — for all non-trivial tasks
3. Default behavior — for everything else

If the user says "just implement it, skip the workflow" — respect that.
