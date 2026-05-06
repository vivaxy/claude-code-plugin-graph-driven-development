# Cadence Plugin — Audit To-Do

Issues surfaced by the audit on 2026-05-05. Severity: **Critical** (broken/contradictory) / **Major** (drift, likely user confusion) / **Minor** (clarity, style) / **Info** (observation).

## Critical

- [x] **C1. Add `NEEDS_CLARIFICATION` routing handler to `using-cadence` SKILL.md.** `agents/plan.md:168-183` emits a 3-line `NEEDS_CLARIFICATION:` / `User feedback:` / `Reuse session folder:` handoff on plan rejection, and `agents/clarify.md:39-44` accepts a `reuse_folder:` hint, but `skills/using-cadence/SKILL.md` has no step that detects the signal and re-spawns clarify with `reuse_folder`. The whole rejection-recovery flow is wired on both ends but disconnected in the middle.
- [x] **C2. Fix heading levels in `agents/analyze-problem.md:157-197` output template.** The body uses `# Problem Analysis` (level 1) and `## 1. Restated Problem` … `## 7. Key Questions` (level 2). When inserted under the existing `## Analysis` (level 2), the level-2 sub-headings become siblings — terminating the section. Lower them to `### 1. Restated Problem` etc. so they nest correctly.
- [x] **C3. Reconcile retrospective sub-headings between `agents/deliver.md` and templates.** `deliver.md:51-57, 76-105` writes `What Went Well` / `What Went Wrong` / `Learnings`, but `templates/feature-dev.md:127`, `templates/bugfix.md:149`, `templates/doc-writing.md:127` require `What Was Built` / `Files Changed` / `Deviations` / `Learnings` / `Open Items`. Pick one structure and align both sides.
- [x] **C4. Add an analysis-session Final Summary path to `agents/deliver.md`.** `templates/analysis.md:55-56` requires `Investigated` / `Top Findings` / `Recommended Next Investigation` / `Open Items` ending with `Analysis complete.`, but `deliver.md:60-68` only knows the feature-dev format (`Built` / `Tests` / … ending `Workflow complete.`). Branch on session type or read the template's expected structure.
- [x] in analyze, is "Out of Scope" and "Non-Goals" the same content?

## Major

- [ ] **M1. Rewrite `README.md:157-194` `docs/ Directory Layout` section to match the C4 model.** README still describes `overview.md`, `flow-*.md`, `arch-*.md` with a `flowchart TD` example, contradicting `CLAUDE.md:11-30` (C4 names: `c4-context.md`, `c4-containers.md`, `c4-component-{name}.md`, `c4-seq-{flow-name}.md`).
- [ ] **M2. Replace the `flowchart TD` example in `README.md:178-188` with `sequenceDiagram`.** The example is labeled "Request Flow" but uses the wrong Mermaid type per `CLAUDE.md:60-63`.
- [ ] **M3. Resolve the "Goal-Driven Execution" credit in `README.md:265`.** Only `Simplicity First` and `Surgical Changes` appear in the codebase (`agents/code-review.md:95, 102`). Either add the missing principle to an agent or remove the credit.
- [ ] **M4. Add `probe`, `check`, `code-review`, `verify` to the C4 component diagram (`docs/c4-component-plugin.md:13-22`) and the container description (`docs/c4-containers.md:17`).** These four utility subagents exist as agent files and are spawned by phase agents (clarify spawns probe; review spawns check, verify, code-review) but are absent from the architectural docs.
- [ ] **M5. Document the four utility subagents in `README.md:204-216` agent table.** Mark them as "internal" or expand the public surface — but tell users they exist.
- [ ] **M6. Fix the ASCII flow in `README.md:150` to show `### Final Summary` (level 3).** Current text says `## Final Summary` (level 2). The actual format is `### Final Summary` per `agents/deliver.md:88, 122` and every template's `## Delivery` checklist; the router extracts level-3 (`SKILL.md:52`).

## Minor

- [ ] **m1. Replace ASCII arrows in `templates/analysis.md:3, 40` with Unicode `→`** to match other templates (e.g. `templates/feature-dev.md:3`, `templates/bugfix.md:40`).
- [ ] **m2. Drop the stale `cadence:` prefix in `agents/review.md:142`.** It currently says `cadence:deliver` — the `cadence:` namespace was the skill form; `deliver` is now an agent.
- [ ] **m3. Clarify the "centralize references" rule in `CLAUDE.md:140`.** Read literally, it forbids the cross-references that every agent file needs to function. Restate so the rule names what kind of references are forbidden (external/setup/marketing) vs. allowed (internal cross-mention).
- [ ] **m4. Eliminate template duplication across `templates/{trivial,feature-dev,bugfix,doc-writing,analysis}.md`.** `## Clarification` is byte-identical across all 5 (~270 lines duplicated); `## Plan` is identical across the 3 plan-having templates; `## Implementation` / `## Review` / `## Delivery` are 90%+ identical. Consider a shared-include mechanism or a generator so policy changes apply once.
- [ ] **m5. Resolve color collisions across `agents/*.md` frontmatter.** `cyan` (clarify, analyze-problem), `purple` (check, deliver), `blue` (implement, verify) — 10 agents share 7 colors. Cosmetic but reduces visual distinguishability.
- [ ] **m6. Move `<example>...</example>` blocks out of YAML frontmatter** in every phase agent (`agents/clarify.md:3-22`, `agents/analyze-problem.md:3-21`, `agents/plan.md:3-21`, etc.). The blocks sit between `---` markers at column 0, which non-tolerant YAML parsers will reject. Either fold the examples into the description string with `|` or move them to the body below the frontmatter.
- [ ] **m7. Add `allowed-tools` to `skills/using-cadence/SKILL.md` frontmatter** to satisfy the project's own skill spec at root `CLAUDE.md:81`.

## Info (observations, no action required unless context changes)

- [ ] **I1. Note that `plugin.json` version 0.1.7 predates significant post-release refactors** (`f38185d`, `6f0f468`, `2485b90`). Any user installing from the marketplace at 0.1.7 gets a meaningfully different plugin than HEAD. Per project rule, version bumps go through the release script — flagging only because this means the next release will be a behaviorally large jump.
- [ ] **I2. `hooks/session-start` JSON-escaping is correct for current SKILL.md content** but escapes only `\\`, `"`, newline, CR, and tab. If SKILL.md ever contains literal Unicode control characters or surrogate pairs, the escape function will need extending.

## Coverage

| File | Findings |
|---|---|
| `.claude-plugin/plugin.json` | I1 |
| `README.md` | M1, M2, M3, M5, M6 |
| `CLAUDE.md` | C1 (gap), m3 |
| `skills/using-cadence/SKILL.md` | C1, m7 |
| `hooks/hooks.json` | clean |
| `hooks/session-start` | I2 |
| `hooks/run-hook.cmd` | clean |
| `templates/trivial.md` | m4 |
| `templates/feature-dev.md` | m4, C3 |
| `templates/bugfix.md` | m4 |
| `templates/doc-writing.md` | m4 |
| `templates/analysis.md` | m1, C4 |
| `agents/clarify.md` | m6 |
| `agents/analyze-problem.md` | C2, m6 |
| `agents/plan.md` | m6 |
| `agents/implement.md` | m5 |
| `agents/review.md` | m2 |
| `agents/deliver.md` | C3, C4 |
| `agents/probe.md` | M4, M5 |
| `agents/check.md` | M4, M5, m5 |
| `agents/code-review.md` | M3, M4, M5 |
| `agents/verify.md` | M4, M5, m5 |
| `docs/c4-context.md` | clean |
| `docs/c4-containers.md` | M4 |
| `docs/c4-component-plugin.md` | M4 |
| `docs/c4-seq-execution.md` | clean |
| `.claude-plugin/marketplace.json` (root) | I1 |
