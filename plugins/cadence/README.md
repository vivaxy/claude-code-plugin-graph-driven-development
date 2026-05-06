# Cadence

A Claude Code plugin that enforces development process consistency through design documents, Mermaid flowcharts, and architecture diagrams.

**Core idea**: Documents and diagrams are the source of truth. They change before code, and code is reviewed against them.

---

## Why Cadence?

Without design documentation, coding agents drift: they fix the immediate problem but miss the broader system picture. Over time, the codebase diverges from intent, and each new feature makes the architecture harder to understand.

Cadence addresses this by:

1. **Making design explicit** — Every module boundary, flow path, and key decision is documented in `docs/`
2. **Enforcing spec-first** — Code is only written after documents and diagrams are updated and reviewed
3. **Closing the loop** — Code review checks implementation against documents and diagrams, not just against itself

---

## Installation

### Via Claude Code Plugin Marketplace

```
/plugin marketplace add vivaxy/claude-code-plugins-vivaxy
```

Then install the plugin:

```
/plugin install cadence@vivaxy-marketplace
```

### Manual Installation (Global)

```bash
cp -r plugins/cadence/skills/ ~/.claude/skills/cadence/
cp plugins/cadence/CLAUDE.md ~/.claude/CLAUDE.md   # or append to existing ~/.claude/CLAUDE.md
```

### Manual Installation (Project-Level)

```bash
mkdir -p .claude/skills/cadence/
cp -r plugins/cadence/skills/ .claude/skills/cadence/
# Append CLAUDE.md content to your project's .claude/CLAUDE.md
```

---

## How sessions are stored

Every Cadence run creates a per-session folder inside the user's project containing a single `session.md` file:

```
<project>/.claude/sessions/YYYY-MM-DD-<slug>/
└── session.md            # the entire session lives here
```

`session.md` is the only state. A single `## CheckList` section groups every workflow item under `### <Sub-section>` headings (one per agent), each containing a list of `- [ ]` items. Body sections (`## Clarification`, `## Plan`, `## Analysis`, `## Review`, `## Delivery`, `## Answer`) hold the structured content the agents fill in via `<!-- TODO: ... -->` placeholders. The routing skill walks `## CheckList` top-to-bottom, finds the first sub-section with any unchecked item, and spawns its owner. Each agent ticks its items as `- [x]` and replaces the matching `<!-- TODO: ... -->` placeholders in the body section it owns.

### Session types

There are four session types, each with a template under `plugins/cadence/templates/` that defines its `## CheckList` sub-sections and body sections:

| Session type | Template | CheckList sub-sections | Body sections |
|---|---|---|---|
| `trivial` | `templates/trivial.md` | `### Clarification`, `### Answer` | `## Clarification` |
| `feature-dev` | `templates/feature-dev.md` | `### Clarification`, `### Plan`, `### Implementation`, `### Review`, `### Delivery` | `## Clarification`, `## Plan`, `## Review`, `## Delivery` |
| `bugfix` | `templates/bugfix.md` | `### Clarification`, `### Analysis`, `### Plan`, `### Implementation`, `### Review`, `### Delivery` | `## Clarification`, `## Analysis`, `## Plan`, `## Review`, `## Delivery` |
| `analysis` | `templates/analysis.md` | `### Clarification`, `### Analysis`, `### Delivery` | `## Clarification`, `## Analysis`, `## Delivery` |

`feature-dev` covers both new behavior and documentation work — the implement agent handles both source code (with type-check/test verification) and docs (with structural verification).

Every session begins with the `clarify` agent writing a minimal `session.md`. After clarify runs, the routing skill calls `AskUserQuestion` to confirm the session type with the user, then copies the matching template into `session.md`. From there, routing walks `## CheckList` top-to-bottom and spawns owners sub-section by sub-section.

The plan body lives in `## Plan` of `session.md` — the plan is part of the session file itself.

**Resume**: if a Claude session is interrupted mid-run, opening a fresh session in the same project detects the existing session folder, finds the first `### <Sub-section>` under `## CheckList` with any `- [ ]` item, and continues from there.

**Recommended `.gitignore`**: session folders are personal scratch space by default. Add this line to your project `.gitignore`:

```
.claude/sessions/
```

Omit it (and commit the folders) to keep a durable team-shared record of every session.

---

## Quick Start

There is nothing to invoke explicitly. Just make a request:

```
Add user authentication with JWT tokens
```

The `using-cadence` skill activates at session start and routes the request:

1. **Clarify** — the `clarify` agent writes a minimal `session.md` capturing your intent and any open questions.
2. **Confirm session type** — the routing skill calls `AskUserQuestion` to confirm one of the four session types (`trivial`, `feature-dev`, `bugfix`, `analysis`), then copies the matching template into `session.md`.
3. **Walk the checklist** — routing reads `## CheckList` in `session.md` top-to-bottom, finds the first `### <Sub-section>` with any `- [ ]` item, and spawns that sub-section's owner. Each agent ticks its items as `- [x]` and fills the matching body-section blanks after completing the work.
4. **Deliver** — the final `### Delivery` items get ticked and `## Delivery` body produces the summary handed back to you.

For a `feature-dev` session, the flow walks through `### Clarification → ### Plan → ### Implementation → ### Review → ### Delivery` under `## CheckList`. For a `bugfix`, an extra `### Analysis` step runs before `### Plan`. For `analysis`, the flow stops after `### Analysis → ### Delivery`. For `trivial`, the main thread answers directly to the user and ticks `### Answer` to terminate.

---

## The Cadence

```
                  user request
                       │
                       ▼
            ┌──────────────────────┐
            │     using-cadence    │ ← session.md routing
            │       (skill)        │
            └──────────────────────┘
                       │
              no session.md found
                       │
                       ▼
                ┌─────────────┐
                │   clarify   │
                └─────────────┘
                       │
              writes session.md
                       │
                       ▼
            ┌──────────────────────┐
            │  AskUserQuestion:    │
            │ confirm session type │
            └──────────────────────┘
                       │
        cp templates/<type>.md → session.md
                       │
                       ▼
            ┌──────────────────────┐
            │  Read session.md →   │
            │  first section with  │
            │  any [ ] item →      │
            │  spawn owner         │
            └──────────────────────┘
                       │
                       ▼
   clarify ─→ analyze ─→ plan ─→ implement ─→ review ─→ deliver
                                                            │
                                                            ▼
                                            Final Summary (conversation only)
```

`session.md` is the state. Each agent owns one section, ticks its `- [ ]` items as `- [x]`, and routing always reads top-to-bottom to pick the next owner. Documents and diagrams live in `docs/`. They change first, code follows.

---

## docs/ Directory Layout

The `docs/` directory follows the [C4 model](https://c4model.com/). Each diagram is a Markdown file with a Mermaid block plus explanatory text.

```
docs/
├── c4-context.md                # Level 1 — System boundary, users, external systems
├── c4-containers.md             # Level 2 — Deployable/runnable units inside the system
├── c4-component-{name}.md       # Level 3 — Internal modules of a complex container
└── c4-seq-{flow-name}.md        # Behavioral — Sequence diagrams for key flows
```

| File | C4 Level | Mermaid type | When required |
|---|---|---|---|
| `c4-context.md` | Level 1 — Context | `C4Context` | Always |
| `c4-containers.md` | Level 2 — Container | `C4Container` | When the system has 2+ deployable/runnable units |
| `c4-component-{name}.md` | Level 3 — Component | `C4Component` | Per container complex enough that developers get lost |
| `c4-seq-{flow-name}.md` | Behavioral | `sequenceDiagram` | Per key user-facing flow |

`docs/` is considered **complete** when `c4-context.md`, `c4-containers.md`, and at least one `c4-seq-*.md` exist. If incomplete, the agent proactively creates the missing files.

Each diagram `.md` file follows this structure:

```markdown
# Request Flow

> **Type**: Sequence
> **Last Updated**: 2026-01-23
> **Covers**: How HTTP requests are processed end-to-end

## Diagram

\`\`\`mermaid
sequenceDiagram
    participant Client
    participant Router
    participant AuthMiddleware
    participant UserHandler
    participant UserService
    participant Database

    Client->>Router: HTTP POST /api/users
    Router->>AuthMiddleware: forward
    alt invalid token
        AuthMiddleware-->>Client: 401 Unauthorized
    else valid token
        AuthMiddleware->>UserHandler: forward
        UserHandler->>UserService: create user
        UserService->>Database: query
        Database-->>UserService: result
        UserService-->>UserHandler: user object
        UserHandler-->>Client: 200 OK
    end
\`\`\`

## Key Decisions

- Auth is checked at middleware level, not inside handlers
- UserService owns all DB interactions for user data

## Notes

Additional context, constraints, or cross-references to other diagrams.
```

---

## Skill and Agent Reference

### Skill: `cadence:using-cadence`

The single entry point for Cadence. Activates at session start and on every Cadence-relevant turn. Detects the active session folder, asks whether to resume or start fresh, walks `## CheckList` in `session.md` top-to-bottom, and spawns the agent that owns the first `### <Sub-section>` with any `- [ ]` item.

### Agents

Each agent owns one `### <Sub-section>` under `## CheckList` (and where applicable, the matching body section) and is spawned by `using-cadence`:

| Agent | Ticks under `## CheckList` | Fills body section | Responsibility |
|---|---|---|---|
| `clarify` | `### Clarification` | `## Clarification` | Capture intent, list open questions, write the initial `session.md`, recommend a session type |
| `analyze-problem` | `### Analysis` | `## Analysis` | Investigate the problem (bugfix/analysis sessions) and record findings |
| `plan` | `### Plan` | `## Plan` | Propose document and diagram updates; manage plan mode internally; runs a subagent diagram review loop until `APPROVED` or `APPROVED_WITH_NOTES` |
| `implement` | `### Implementation` | (work-item sub-bullets, in `### Implementation` itself) | Read `## Plan` and the relevant diagrams, then write code that follows the defined boundaries and flow order |
| `review` | `### Review` | `## Review` | Run a code review (doc/diagram alignment plus code quality), fix critical issues, and re-review until `APPROVED` or `APPROVED_WITH_NOTES` |
| `deliver` | `### Delivery` | `## Delivery` (Retrospective only) | Run a retrospective into `## Delivery`, consolidate learnings, and return the Final Summary as conversational handoff text (never written to `session.md`) |

You can rely on the routing skill to spawn these agents at the right time. Manual invocation is rarely needed.

---

## Best Practices

### Keep Documents and Diagrams at the Right Level of Abstraction

Too detailed → maintenance burden that slows you down  
Too abstract → too little constraint on implementation

**Always show**: module boundaries, decision points, external system interactions, key requirements  
**Always omit**: function signatures, variable types, implementation details

### One Source of Truth

Documents and diagrams in `docs/` are authoritative. When code and docs disagree:

1. If the code is right → run a new Cadence session to update the document/diagram
2. If the document/diagram is right → fix the code

Always treat drift as a signal that one side needs to be updated in the same session.

### Documents and Diagrams Are Living Documents

Update them when you learn something new. A document that accurately reflects a simpler system is better than one that aspires to a complex system that lives only on paper.

### Use Cadence for New Features, Not Archaeology

Apply Cadence to forward-looking work on a legacy codebase. Begin with a roughly accurate document set, then refine each area the next time you touch it.

---

## Troubleshooting

**"docs/ is missing or incomplete"**  
Just describe your requirement — the `plan` agent will auto-create the initial documents and diagrams.

**The generated diagrams are inaccurate**  
This is expected for complex codebases. Correct them manually — they are Markdown files with Mermaid blocks, easy to edit. Accuracy improves over time as each new Cadence session refines the relevant area.

**Code review finds too many deviations**  
If deviations are consistently valid (the code is right, the document is wrong), update the documents in the next Cadence session. If deviations are consistently invalid (the code drifted from the document), enforce Cadence more strictly by always running through `### Plan` before `### Implementation`.

---

## Credits

The Simplicity First, Surgical Changes, and Goal-Driven Execution rules in Cadence are adapted from [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills), a distillation of [Andrej Karpathy's observations](https://x.com/karpathy/status/2015883857489522876) on common LLM coding pitfalls.

---

## License

MIT
