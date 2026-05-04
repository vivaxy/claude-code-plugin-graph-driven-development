# Analysis Session

> Session type: analysis. Use when the request is to investigate a multi-layered problem, surface root causes, and hand off findings without implementing a fix. Routing flows clarify -> analyze-problem -> deliver.

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
- [ ] Create the session folder with `mkdir -p <path>` (idempotent — safe when reusing)
- [ ] Write the clarification body into `## Clarification` of `session.md` (Problem, In Scope, Out of Scope, Constraints, Success Criteria, Non-Goals; for bugfix sessions also Reproduction Steps and Root Cause) and tick every item in this section
- [ ] Return exactly one terminal line of the form: `Wrote session.md to <absolute-path-to-session.md>. Session-type hint: <hint>.`

## Analysis

### Procedural Checklist

- [ ] Read `## Clarification` in `session.md` first; treat the Problem, In Scope, Out of Scope, and Constraints as the authoritative starting point
- [ ] Restate the problem in one precise sentence that makes Who is affected, What is actually broken or unclear (symptom vs. problem), Where (system, context, scope), When (always / intermittently / since when), and What is NOT the problem (boundary) explicit
- [ ] When the problem statement is too vague to restate precisely, call `AskUserQuestion` with one focused clarifying question and stop
- [ ] Collect facts in memory into four categories: Verified facts (F#) directly observable or measurable with cited sources or evidence; Challenged assumptions (A#) accepted as true but not yet verified, with what would confirm or refute each; Hard constraints (C#) physical, logical, or system-level limits; Evidence gaps (G#) things not yet known but needing to be known
- [ ] Strip away analogies, conventions, and inherited thinking — for each claim embedded in the problem statement, ask "Do I know this is true, or am I just accepting it?"
- [ ] Reference fact IDs in every subsequent step; when new facts emerge during decomposition, root-cause tracing, or synthesis, add them to the fact list first before using them
- [ ] When the problem touches code in the current project, use Read / Glob / Grep to gather relevant context before recording facts
- [ ] Decompose the problem into sub-problems that are mutually exclusive and collectively exhaustive (MECE), each with name, description, scope (contained or cross-cutting), and relevant fact IDs (F#, A#, C#); analyze each sub-problem independently before looking at interactions
- [ ] Trace causality for each sub-problem using up to 5 levels of "Why"; cite a fact ID for every "Why" or explicitly label the step `[assumption]`; distinguish symptoms (visible effects), proximate causes (direct triggers), and root causes (underlying conditions)
- [ ] Build a Mermaid visual model whose type matches the problem (causal chain -> `graph LR`; concept breakdown -> `mindmap`; system with interactions -> `graph TD`; process / sequence -> `flowchart TD`); reference fact IDs in node labels; use `<br>` for line breaks; ensure valid syntax; add a brief legend
- [ ] Generate the diagram even when simple — visual representation forces structural clarity
- [ ] Synthesize emergent properties and tensions grounded in the recorded facts: interactions between sub-problems, emergent properties that only appear when parts combine, and the core tension or fundamental trade-off at the heart of the problem
- [ ] Derive 3–7 Key Questions from the model; root each in a root cause, evidence gap, or challenged assumption; for each question record Targets (which sub-problem / root cause / gap it addresses), Unlocks (what becomes possible once answered), Type (Diagnostic / Decision / Risk), and Priority (High / Medium based on impact x uncertainty)
- [ ] Order Key Questions by priority (High first); keep them as questions to investigate, not action recommendations
- [ ] Write the analysis body inline under `## Analysis` of `session.md` via `Edit` with these sub-headings: Restated Problem, Facts (Verified Facts / Challenged Assumptions / Hard Constraints / Evidence Gaps), Decomposition, Root Causes, Visual Model (Mermaid block + legend), Synthesis, Key Questions
- [ ] Tick every item in this section after the body is written
- [ ] Return exactly one terminal line: `Wrote ## Analysis to <absolute-path-to-session.md>. <one-sentence summary of the core finding or top key question>.`

## Delivery

### Procedural Checklist

- [ ] Read `<session-folder>/session.md` end-to-end — `## Clarification` for original problem and success criteria, and `## Analysis` for the recorded facts, decomposition, root causes, visual model, synthesis, and key questions
- [ ] Read recent project history with `git log --oneline -20` for additional delivery context
- [ ] Compose the Retrospective body with these sub-headings: What Was Investigated (2–3 sentences), Files Read (key files inspected during analysis), Deviations (where the analysis surfaced something unexpected; write "None." when there are none), Learnings (what went well, what was harder than expected, process improvements for next time), Open Items (follow-up investigations, unanswered key questions, future work; write "None." when there are none)
- [ ] Compose the Final Summary body with these sub-headings: Investigated (one-line description), Top Findings (bullet list of root causes and key questions), Recommended Next Investigation (one-line pointer to the highest-priority key question), Open Items (none or list); end the Final Summary with the line `Analysis complete.`
- [ ] Write the Retrospective and Final Summary inline under `## Delivery` of `session.md` via `Edit` (under sub-headings `### Retrospective` and `### Final Summary`); keep the retrospective and final summary in `session.md` only and let the routing layer surface the Final Summary to the user
- [ ] Use `date -u +%Y-%m-%d` for any date references in the body
- [ ] Tick every item in this section after the body is written
- [ ] Return exactly one terminal line: `Wrote ## Delivery to <absolute-path-to-session.md>. <one-sentence summary of the analysis handoff>.`
