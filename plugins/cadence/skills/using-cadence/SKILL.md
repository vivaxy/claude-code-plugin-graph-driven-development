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

## Plan mode

Plan mode does **not** skip Cadence — Cadence drives the whole workflow regardless.

**Never call `EnterPlanMode` directly on the main thread when Cadence is active.** The `cadence:plan` subagent manages plan mode internally via its own `EnterPlanMode`/`ExitPlanMode` calls. If Claude Code plan mode is already active when Cadence routing fires, call `ExitPlanMode` first to unblock the `Agent` tool, then spawn the `cadence:plan` agent normally.

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
| Plan agent returned a `NEEDS_CLARIFICATION:` signal | re-clarification handoff (see below) |
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

Borderline case (ambiguous intent): call `AskUserQuestion` with the question "This looks like a good case for structured analysis — want me to run it?" and options `["Yes, run it", "No, skip"]`, then wait.

#### Plan re-clarification handoff

When the `plan` agent's final message starts with `NEEDS_CLARIFICATION:`, the user's rejection opened a gap the original clarification didn't cover — facts, scope, constraints, or success criteria. Plan returns control rather than spawning `clarify` itself, so the new summary lands in the main-thread conversation where the next routing decision can read it.

Procedure:
1. Call `ExitPlanMode` with a brief placeholder plan to unblock the `Agent` tool — plan mode remains active after a rejection.
2. Spawn the `clarify` agent. Pass the plan agent's `NEEDS_CLARIFICATION:` message (gap line + verbatim user feedback) as additional context so clarify focuses on the gap rather than re-running the full clarification flow.
3. After `clarify` returns the updated summary, spawn the `plan` agent again — it revises the plan against the new clarification.

If the re-spawned `plan` agent emits `NEEDS_CLARIFICATION:` again, repeat the procedure.

## Implement Phase

After the plan agent completes and the user approves the plan:

1. **Apply doc changes**: Create or update each file listed in the plan's `## Docs to Change` table.
2. **Create todos**: Read the approved plan's `## Implementation Steps` list. Call `TaskCreate` for each step — one task per step, in order.
3. **Execute each step sequentially**:
   - Mark the task `in_progress` with `TaskUpdate`.
   - Spawn a `cadence:implement` subagent via the `Agent` tool. Give it the step description, the list of files to change (from the plan's "Source Code to Change" table), and full context from the plan (problem statement, constraints, key decisions).
   - After the subagent completes, verify the result: use `Read` on each file the step was supposed to change and confirm the expected change is present.
   - If verification passes: mark the task `completed` with `TaskUpdate` and proceed to the next step.
   - If verification fails: surface the failure to the user ("Step N failed verification: <what was expected vs. what was found>"). Do not proceed until resolved.
4. **After all steps are verified — this step is MANDATORY, never skip it:**
   - Announce: "All steps complete — spawning `review` agent."
   - Spawn the `cadence:review` subagent via the `Agent` tool.
   - After the review agent returns: invoke `cadence:deliver` via the `Skill` tool.
   - Do NOT summarize the work yourself or write a completion message before review runs.

## How to Route

**After the clarify agent returns**: immediately evaluate step 2 (trivial-exit). If not trivial, evaluate step 3 (routing table). Do not wait for user input. Immediately:

1. Say one line matching the destination:
   - Spawning an agent: "Cadence is active — spawning `<agent>` agent."
   - Invoking a skill: "Cadence is active — routing to `cadence:<skill>`."
2. Spawn the agent (via Agent tool) or invoke the skill (via Skill tool) as appropriate.

## User Questions

Whenever the routing layer needs to ask the user a question, it must use the `AskUserQuestion` tool. This applies to the analyze-gate borderline prompt and any future routing questions.

## Instruction Priority

1. User's explicit instructions (CLAUDE.md, direct requests) — highest
2. Cadence routing — for all non-trivial tasks
3. Default behavior — for everything else

If the user says "just implement it, skip the workflow" — respect that.
