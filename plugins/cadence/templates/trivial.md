# Trivial Session

> Session type: trivial. Use when the request is a small, localized change or a factual question. Routing terminates after `## Answer`.

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

## Answer

- [ ] Read `## Clarification` in `session.md` for the user's question and the established context
- [ ] Write the answer directly to the user using affirmative phrasing
- [ ] Tick every item in this section to terminate the session
