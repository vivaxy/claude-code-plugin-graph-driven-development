---
name: cadence:using-cadence
description: Guide for when to apply Cadence — read at session start to understand when Cadence applies and what to do first
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

## Session Folder

Every Cadence run lives in a per-session folder under the project:

- Path: `<project>/.claude/sessions/YYYY-MM-DD-<slug>/`
- Files: `clarify.md`, optional `analyze.md`, `plan.md`, `implement-step-N.md` (one per step), `review.md`, `deliver.md`.
- Each file carries YAML frontmatter (`agent`, `session_type`, `status`, `created_at`). `status` values: `in_progress`, `complete`, `blocked`.
- The clarify agent owns folder creation. Other agents only write into an existing folder.
- Subagents return one-line handoffs of the form: `Wrote <file>.md to <absolute-path>. <one-sentence summary>`. The full output lives in the file.
- The routing layer tracks the active session folder for the duration of the conversation. When invoking any agent or skill, pass the session folder absolute path in the prompt.

## Session-Folder Detection (Resume)

At the very start of any Cadence-relevant request, before invoking `clarify`:

1. Determine the project root via `git rev-parse --show-toplevel` (fall back to `pwd`).
2. List existing session folders matching `<project>/.claude/sessions/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-*/` via Bash glob.
3. If one or more exist, read the frontmatter of the most recently modified folder's files to determine which phase it is in. Use `AskUserQuestion` to ask the user: "An in-progress Cadence session was found at `<path>` (last phase: `<X>`). Continue this session, or start a new one?" with options `["Continue existing", "Start new"]`.
   - On "Continue existing": treat the chosen folder as the active session folder; route by file presence + `status` instead of invoking `clarify`.
   - On "Start new": fall through to the normal flow — `clarify` will create a fresh folder.
4. If no folders exist, fall through to the normal flow.

Routing-by-state means: read the frontmatter of each file in the session folder. The next step is the first phase whose file is missing or has `status: blocked`. The routing table below maps that state to the next agent.

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

The active session folder defines current state. Read the frontmatter of each file:

| File state in session folder | Route to |
|---|---|
| No `clarify.md`, or `clarify.md` `status: in_progress` | `clarify` agent |
| `clarify.md` `status: complete`, no `plan.md` (and analyze gate does not apply) | `plan` agent |
| `clarify.md` `status: complete`, no `analyze.md`, analyze gate applies | `analyze-problem` agent (then `plan` agent after) |
| Plan agent returned a `NEEDS_CLARIFICATION:` signal | re-clarification handoff (see below) |
| `plan.md` `status: complete`, fewer `implement-step-N.md` files than steps in plan | implement phase (see below) |
| All `implement-step-N.md` `status: complete`, no `review.md` | `review` agent |
| `review.md` `status: complete`, verdict accepted | `deliver` agent |
| `review.md` verdict `FEATURE_BLOCKED` | surface the blocker to the user; do not auto-route |

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
2. Spawn the `clarify` agent and pass `reuse_folder: <session-folder-path>` (read from the third line of plan's `NEEDS_CLARIFICATION` message: `Reuse session folder: <path>`). Also pass the gap line and verbatim user feedback as additional context so clarify focuses on the gap. Clarify will overwrite the existing `clarify.md` instead of creating a new folder.
3. After `clarify` returns the updated summary, spawn the `plan` agent again — it revises the plan against the new clarification.

If the re-spawned `plan` agent emits `NEEDS_CLARIFICATION:` again, repeat the procedure.

## Implement Phase

After the plan agent completes and the user approves the plan:

1. **Apply doc changes**: Create or update each file listed in the plan's `## Docs to Change` table.
2. **Create todos**: Read the approved `<session-folder>/plan.md`'s `## Implementation Steps` list. Call `TaskCreate` for each step — one task per step, in order.
3. **Execute each step sequentially**:
   - Mark the task `in_progress` with `TaskUpdate`.
   - Spawn a `cadence:implement` subagent via the `Agent` tool. Pass it:
     - Session folder absolute path
     - Step number `N`
     - Path to `<session-folder>/plan.md`
     - The step description and files to change (from plan.md's "Source Code to Change" table)
   - After the subagent returns its `Wrote implement-step-N.md to <path>. <summary>` handoff:
     - Read `<session-folder>/implement-step-N.md` and confirm `status: complete` in the frontmatter.
     - Read each file listed in `files_touched` and confirm the expected change is present.
     - If verification passes: mark the task `completed` with `TaskUpdate` and proceed to the next step.
     - If `status: blocked` or verification fails: surface the failure to the user ("Step N blocked: <reason from the file's Notes section>"). Do not proceed until resolved.
4. **After all steps are verified — this step is MANDATORY, never skip it:**
   - Announce: "All steps complete — spawning `review` agent."
   - Spawn the `cadence:review` subagent via the `Agent` tool. Pass it the session folder absolute path.
   - After review returns its `Wrote review.md to <path>. Verdict: <V>` handoff:
     - On `FEATURE_ACCEPTED` or `FEATURE_ACCEPTED_WITH_WARNINGS`: spawn the `cadence:deliver` agent via the `Agent` tool, passing the session folder absolute path. After deliver returns its `Wrote deliver.md to <path>. <summary>` handoff, read `<session-folder>/deliver.md` and surface its `## Final Summary` section to the user as the terminal output.
     - On `FEATURE_BLOCKED`: surface the blocker; do not spawn the deliver agent.
   - Do NOT summarize the work yourself or write a completion message before review runs.

## How to Route

**After the clarify agent returns**: immediately evaluate step 2 (trivial-exit). If not trivial, evaluate step 3 (routing table). Do not wait for user input. Immediately:

1. Say one line matching the destination:
   - Spawning an agent: "Cadence is active — spawning `<agent>` agent."
   - Invoking a skill: "Cadence is active — routing to `cadence:<skill>`."
2. Spawn the agent (via Agent tool) or invoke the skill (via Skill tool) as appropriate.

When spawning any agent or skill, always pass the session folder absolute path in the prompt. Without it, the agent cannot read prior phase files.

## User Questions

Whenever the routing layer needs to ask the user a question, it must use the `AskUserQuestion` tool. This applies to the analyze-gate borderline prompt and any future routing questions.

## Instruction Priority

1. User's explicit instructions (CLAUDE.md, direct requests) — highest
2. Cadence routing — for all non-trivial tasks
3. Default behavior — for everything else

If the user says "just implement it, skip the workflow" — respect that.
