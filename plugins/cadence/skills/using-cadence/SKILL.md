---
name: cadence:using-cadence
description: Guide for when to apply Cadence — read at session start to understand when Cadence applies and what to do first
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

# Using Cadence

## Procedure (all session types)

clarify → (trivial-exit | analyze-problem | plan) → implement → review → deliver

## Routing Logic

### 1. Clarification gate — always first

**Do not explore the codebase or enter plan mode before this step.**

Invoke the `clarify` agent when either:
- No clarification summary exists in the current conversation, OR
- The request is unrelated to the established session (different problem domain, different goal)

### 2. Trivial exit

After clarify returns: if the clarified request is trivial, stop and respond directly. A task is trivial when it meets **either** of these criteria:
- **Small scope**: typo fix, variable rename, localized change (within one file, no cross-module impact), or any change with no design decisions
- **Informational**: factual question, code explanation, or request that requires no code changes

When the task is ambiguous, err toward non-trivial — proceed unless you are confident it meets the criteria above.

→ If trivial, stop here — do not proceed to step 3 or invoke any agents. Otherwise, continue to step 3.

### 3. Route by state

| Condition | Route to |
|---|---|
| No plan in conversation | `plan` agent |
| Plan approved, implementation not started | implement phase (see below) |
| All steps implemented and verified | `review` agent → `cadence:deliver` |

#### Analyze gate

Invoke the `analyze-problem` agent instead of `plan` when ALL of these are true:
- The session type is diagnostic/exploratory
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

**After the clarify agent returns**: immediately evaluate step 2 (trivial-exit). If not trivial, evaluate step 3 (routing table). Do not wait for user input. Immediately:

1. Say one line matching the destination:
   - Spawning an agent: "Cadence is active — spawning `<agent>` agent."
   - Invoking a skill: "Cadence is active — routing to `cadence:<skill>`."
2. Spawn the agent (via Agent tool) or invoke the skill (via Skill tool) as appropriate.

## Instruction Priority

1. User's explicit instructions (CLAUDE.md, direct requests) — highest
2. Cadence routing — for all non-trivial tasks
3. Default behavior — for everything else

If the user says "just implement it, skip the workflow" — respect that.
