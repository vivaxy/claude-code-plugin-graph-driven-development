# Feature Development Session

> Session type: feature-dev. Use when the request adds new behavior, a new API endpoint, a new component, or a structural refactor. Routing flows clarify → plan → implement → review → deliver.

## Clarification

- [ ] Read the user's initial request and identify what is already clear (scope, constraints, success criteria, non-goals)
- [ ] Identify factual unknowns that probe can resolve through codebase search, prior art, official docs, or experiment, and spawn one `probe` subagent per unknown in parallel (single message, multiple Agent calls) when any exist
- [ ] Use returned probe findings to resolve assumptions silently and to ask better-targeted clarifying questions
- [ ] Ask clarifying questions one at a time via `AskUserQuestion` (one call per question), waiting for each answer before asking the next
- [ ] Keep questioning iterative — ask one or two questions at a time and stop once a problem statement covering scope, constraints, and success criteria can be written confidently
- [ ] Restate every imperative request as a measurable, testable success condition (e.g. "users can log in" rather than "authentication works")
- [ ] For bugfix-shaped requests, also ask for exact reproduction steps, expected vs. actual behavior, and environment or version details
- [ ] Confirm understanding by summarizing what is being built, key constraints, success criteria, and what is out of scope, then call `AskUserQuestion` asking "Does this capture it correctly, or is there anything to adjust?" and incorporate any corrections
- [ ] For bugfix-shaped requests, run diagnosis with LSP (`goToDefinition`, `findReferences`) on probe-identified code paths and state the root cause in one sentence as part of the summary; note when reproduction is unconfirmed
- [ ] Infer a tentative session type from the clarified content (trivial / feature-dev / bugfix / doc-writing / analysis) and include it in the terminal handoff so the router can pre-select an option
- [ ] Treat auto mode as a directive to minimize routine interruptions while still asking one `AskUserQuestion` for any load-bearing design choice that determines API surface (new function argument, required field, public interface shape)
- [ ] When the user explicitly says "just proceed" or "skip clarification", produce a minimal summary from what is known and stop
- [ ] Wait for the user to confirm understanding before finalizing the summary
- [ ] Resolve the session folder path (project root via `git rev-parse --show-toplevel` or `pwd`; date via `date -u +%Y-%m-%d`; slug derived from the problem statement: lowercase, ASCII-only, runs of non-alphanumerics collapsed to single dashes, leading/trailing dashes stripped, truncated to 50 characters with any trailing dash re-stripped)
- [ ] Handle folder collisions by calling `AskUserQuestion` once with options ["Continue existing session", "Start fresh"] and on "Start fresh" append `-2`, then `-3`, etc. until a free path is found
- [ ] When a `reuse_folder` hint is provided by the router (re-clarification), reuse that exact path, skip slug derivation and collision detection, and overwrite the existing session.md `## Clarification` section in place
- [ ] Run `${CLAUDE_PLUGIN_ROOT:-$CURSOR_PLUGIN_ROOT}/scripts/ensure-session-folder <path>` to create the session folder and ensure `<project-root>/.claude/.gitignore` contains `sessions/` (idempotent — safe when reusing)
- [ ] Write the clarification body into `## Clarification` of `session.md` (Problem, In Scope, Out of Scope, Constraints, Success Criteria, Non-Goals; for bugfix sessions also Reproduction Steps and Root Cause) and tick every item in this section
- [ ] Return exactly one terminal line of the form: `Wrote session.md to <absolute-path-to-session.md>. Session-type hint: <hint>.`

## Plan

### Context

<TODO: filled by plan agent>

### Key Decisions

<TODO: filled by plan agent>

### Docs to Change

<TODO: filled by plan agent>

### Source Code to Change

<TODO: filled by plan agent>

### Tests to Change

<TODO: filled by plan agent>

### What Does Not Change

<TODO: filled by plan agent>

### Implementation Steps

<TODO: filled by plan agent>

### Verification

<TODO: filled by plan agent>

### Summary

<TODO: filled by plan agent>

### Procedural Checklist

- [ ] Call `EnterPlanMode` immediately so all design and drafting stays read-only until `ExitPlanMode` returns with approval
- [ ] Read `<session-folder>/session.md` and extract the Problem statement, In Scope / Out of Scope, Constraints, and Success Criteria from `## Clarification`
- [ ] When a `## Analysis` section exists in `session.md`, also read it for additional context
- [ ] Stop and report the inconsistency when `## Clarification` items are not all ticked (clarification is incomplete)
- [ ] Determine which diagrams in `docs/` need to be created or updated using C4 level criteria: `c4-context.md` for added/removed external systems or user types; `c4-containers.md` for added/removed deployable units or major integrations; `c4-component-{name}.md` for added/removed modules inside a container; `c4-seq-{flow-name}.md` for new or modified user-facing flows
- [ ] Draft each required diagram's Mermaid content inline in the plan body's "Docs to Change" table; use `<br>` for line breaks inside node labels and ensure valid Mermaid syntax
- [ ] Set `Last Updated` to today's date (`date -u +%Y-%m-%d`) on every diagram file that will be created or updated
- [ ] Skip diagram updates only when the change is purely textual (e.g. config value, copy change) with no structural impact
- [ ] Write the full plan body into the `## Plan` section of `session.md` via `Edit`, replacing each `<TODO: filled by plan agent>` placeholder under Context, Key Decisions, Docs to Change, Source Code to Change, Tests to Change, What Does Not Change, Implementation Steps, Verification, and Summary
- [ ] Copy each entry from `### Implementation Steps` into the `## Implementation` section as a `- [ ]` checklist item so the implement agent has a ready work list
- [ ] Pass the same plan body string to `ExitPlanMode` for user approval (the body shown to the user equals the body persisted to `## Plan` in `session.md`)
- [ ] Always render every plan-body sub-heading (Context, Key Decisions, Docs to Change, Source Code to Change, Tests to Change, What Does Not Change, Implementation Steps, Verification, Summary) so the user approves the plan itself
- [ ] Always propose the minimum change that satisfies the clarified success criteria — limit "Source Code to Change" entries to files needed by the success criteria; reserve abstractions for cases with two or more present (not hypothetical) call sites; add configuration only when the clarified scope names a variable to vary; add error handling only for failure modes that can actually occur in the clarified flow; when two designs satisfy the success criteria, prefer the one with fewer files, fewer lines, and fewer concepts
- [ ] Ensure every entry in "Source Code to Change" traces to a clarified success criterion — list adjacent files left untouched in "What Does Not Change" with the reason; match the existing style and structure of each file being changed; mention pre-existing dead code or smells in "What Does Not Change" rather than including their cleanup in the plan; limit cleanup to imports, variables, and helpers that this plan's changes themselves would render unused
- [ ] Keep success criteria specific and verifiable
- [ ] Keep the `### Summary` sub-section as the last item in the plan body, written as a bullet list
- [ ] When a Key Decision drives a structural change to a diagram, copy that decision into the relevant diagram file's `## Key Decisions` section with attribution `(from plan: <kebab-slug>)`
- [ ] On user rejection of the plan, return control to the main thread so the routing layer can re-invoke `clarify`; emit exactly three plain-text lines (no code fence, no prefix): `NEEDS_CLARIFICATION: <one-line description of the gap to re-clarify>`, `User feedback: <verbatim user rejection>`, `Reuse session folder: <absolute-path-to-session-folder>`; clear all `## Clarification` items back to `- [ ]` and reset the `## Plan` body to the template skeleton so the re-spawned plan agent starts from a clean section
- [ ] Tick every item in this `### Procedural Checklist` after the user approves the plan via `ExitPlanMode`
- [ ] Return exactly one terminal line: `Wrote ## Plan to <absolute-path-to-session.md>. <one-sentence summary>.`

## Implementation

### Procedural Checklist

- [ ] Read `<session-folder>/session.md` for full context — `## Clarification`, the full `## Plan` body, and any sub-bullet notes left under prior ticked `## Implementation` items
- [ ] Process exactly one unticked step per invocation (the router re-spawns this agent until no `- [ ]` items remain in `## Implementation`)
- [ ] Use `Read` on every source file before making any edit to it
- [ ] Make only the changes specified for the current step — leave unrelated code, refactors, and cleanups alone
- [ ] Run the project's type-check or test command (e.g. `npx tsc --noEmit`, `npm test`) and confirm it passes; for plugin/markdown-only repos with no build step, verify structurally (file parses, sections intact, frontmatter valid)
- [ ] When verification fails, fix the issue and re-run before reporting
- [ ] Tick the completed step's `- [ ]` item in `## Implementation` of `session.md` via `Edit` and add files-touched (with line ranges) and the verification command + result as sub-bullets under the ticked item
- [ ] When verification fails for reasons outside the step's control (upstream blocker), leave the item unticked, add a sub-bullet of the form `- blocked: <reason>` under it, and return: `Step <N> blocked — <reason>.`
- [ ] Leave commits to a separate phase — implementation does not commit
- [ ] Return exactly one terminal line: `Ticked step <N> in <absolute-path-to-session.md>. <one-sentence summary of what changed>.`

## Review

### Procedural Checklist

- [ ] Read `<session-folder>/session.md` end-to-end — `## Clarification` for success criteria (and Reproduction Steps + Root Cause when present), `## Plan` for the Docs / Source Code / Tests to Change tables, and every ticked item under `## Implementation` for files touched + verification results + any deviation notes
- [ ] Stop and return `Review blocked — <reason>.` when `## Clarification` or `## Plan` items are not all ticked, or when any `## Implementation` item is marked blocked
- [ ] Scan `## Implementation` sub-bullet notes for any deviation from the plan that lacks a resolution note or that affects a success criterion, and flag those as unresolved deviations
- [ ] Treat deviations with resolution notes and no impact on success criteria as acceptable
- [ ] Launch all of the following checks concurrently in a single message, passing the session folder absolute path to every subagent: Bash to run the project's full test suite (capturing total / passing / failing); `check` subagent with all success criteria so it can verify against the actual changes recorded in `## Implementation`; `verify` subagent with `dimension: docs-alignment`; `verify` subagent with `dimension: plan-alignment`; `code-review` subagent on staged git changes (falling back to HEAD diff); and — only when `## Clarification` recorded Reproduction Steps — a `verify` subagent with `dimension: bugfix-regression`
- [ ] Wait for every check to return before assigning the verdict so the full picture informs the call
- [ ] Assign `block` when any of these holds: one or more tests failing; any criterion is `NOT_SATISFIED`; any verify dimension is `FAIL` (including `bugfix-regression`); code review verdict is `NEEDS_WORK`
- [ ] Assign `ship` only when all of these hold: all tests passing; all criteria `SATISFIED`; all verify dimensions `PASS`; code review verdict is `APPROVED`
- [ ] Assign `revise` only when all of these hold: all tests passing; all criteria `SATISFIED` or `UNTESTED`; all verify dimensions `PASS` or `PASS_WITH_WARNINGS`; code review verdict is `APPROVED` or `APPROVED_WITH_NOTES`
- [ ] Write the review body inline under `## Review` of `session.md` via `Edit` with these sub-headings: Verdict, Test Suite (`<N> passing, <N> failing`), Success Criteria (table of criterion → result), Docs Alignment, Plan Alignment, Code Review, Bugfix Regression (only when applicable), Deviations, Warnings, Summary
- [ ] Tick every item in this section after the review body is written
- [ ] Return exactly one terminal line: `Wrote ## Review to <absolute-path-to-session.md>. Verdict: ship | revise | block.`

## Delivery

### Procedural Checklist

- [ ] Read `<session-folder>/session.md` end-to-end — `## Clarification` for original problem and success criteria, `## Analysis` when present, `## Plan` body for decisions and changes, every ticked `## Implementation` item for files touched + verification + notes, and `## Review` for verdict and check results
- [ ] Read recent project history with `git log --oneline -20` for additional delivery context
- [ ] When `## Review` records a `block` verdict, write a "Delivery Blocked" body into `## Delivery` (still write the section), tick the items in this section, and return: `Wrote ## Delivery to <absolute-path-to-session.md>. Delivery blocked — review verdict was block.`
- [ ] Compose the Retrospective body with these seven sub-headings in order: What Was Built (2–3 sentences), Files Changed (key files modified or created with one-line purpose each), Deviations (where execution diverged from the plan and why; write "None." when there are none), What Went Well (bullet list of process/tooling/decisions that worked), What Went Wrong (bullet list of friction or missteps; write "None." when there were none), Learnings (bullet list of takeaways and process improvements for next time), Open Items (bullet list of follow-up tasks, known limitations, future improvements; write "None." when there were none)
- [ ] For each Learning bullet, call `AskUserQuestion` once with `multiSelect: true` and options ["Project memory", "Project CLAUDE.md", "User CLAUDE.md", "None"]; for every selected destination, write the learning (auto-memory at `~/.claude/projects/<encoded>/memory/` where `<encoded>` is the project absolute path with `/` replaced by `-`, project `<project-root>/CLAUDE.md`, or user `~/.claude/CLAUDE.md`). Treat `None` as exclusive when selected.
- [ ] For each Open Item bullet, call `AskUserQuestion` once with options ["Append to docs/todo.md", "Skip"]; on "Append" append a new `- [ ] <text>` line to `<project-root>/docs/todo.md` under the appropriate section (creating the file with a minimal header if it does not exist).
- [ ] Compose the Final Summary body with these sub-headings: Built (one-line description), Tests (all passing or test count), What Was Built (2–3 sentences), Files Changed (key files), Open Items (none or list); end the Final Summary with the line `Workflow complete.`
- [ ] Write the Retrospective and Final Summary inline under `## Delivery` of `session.md` via `Edit` (under sub-headings `### Retrospective` and `### Final Summary`); keep the retrospective and final summary in `session.md` only and let the routing layer surface the Final Summary to the user
- [ ] Use `date -u +%Y-%m-%d` for any date references in the body
- [ ] Tick every item in this section after the body is written
- [ ] Return exactly one terminal line: `Wrote ## Delivery to <absolute-path-to-session.md>. <one-sentence summary of the delivery>.`
