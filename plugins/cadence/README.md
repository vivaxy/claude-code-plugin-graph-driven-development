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

`session.md` is the only state. It is divided into `## <Section>` headings, each containing a checklist of `- [ ]` items. The routing skill reads `session.md` top-to-bottom, finds the first section with any unchecked item, and spawns the agent that owns that section. Each agent ticks its items as `- [x]` after completing the work for that item.

### Session types

There are four session types, each with a template under `plugins/cadence/templates/` that defines its sections:

| Session type | Template | Sections |
|---|---|---|
| `trivial` | `templates/trivial.md` | `## Clarification`, `## Answer` |
| `feature-dev` | `templates/feature-dev.md` | `## Clarification`, `## Plan`, `## Implementation`, `## Review`, `## Delivery` |
| `bugfix` | `templates/bugfix.md` | `## Clarification`, `## Analysis`, `## Plan`, `## Implementation`, `## Review`, `## Delivery` |
| `analysis` | `templates/analysis.md` | `## Clarification`, `## Analysis`, `## Delivery` |

`feature-dev` covers both new behavior and documentation work — the implement agent handles both source code (with type-check/test verification) and docs (with structural verification).

Every session begins with the `clarify` agent writing a minimal `session.md`. After clarify runs, the routing skill calls `AskUserQuestion` to confirm the session type with the user, then copies the matching template into `session.md`. From there, routing reads top-to-bottom and spawns owners section by section.

The plan body lives in `## Plan` of `session.md` — the plan is part of the session file itself.

**Resume**: if a Claude session is interrupted mid-run, opening a fresh session in the same project detects the existing session folder, finds the first section in `session.md` with any `- [ ]` item, and continues from there.

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
3. **Walk the checklist** — routing reads `session.md` top-to-bottom, finds the first section with any `- [ ]` item, and spawns that section's owner. Each agent ticks its items as `- [x]` after completing the work.
4. **Deliver** — the final `## Delivery` section produces the summary and hands back to you.

For a `feature-dev` session, the flow walks through `## Clarification → ## Plan → ## Implementation → ## Review → ## Delivery`. For a `bugfix`, an extra `## Analysis` step runs before `## Plan`. For `analysis`, the flow stops after `## Analysis → ## Delivery`. For `trivial`, the main thread answers directly under `## Answer`.

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
                                                    ## Final Summary
```

`session.md` is the state. Each agent owns one section, ticks its `- [ ]` items as `- [x]`, and routing always reads top-to-bottom to pick the next owner. Documents and diagrams live in `docs/`. They change first, code follows.

---

## docs/ Directory Layout

```
docs/
├── overview.md           # System context / big-picture boundary
├── flow-*.md             # Business process, request, data flow diagrams
└── arch-*.md             # Module dependency / component architecture diagrams
```

Each diagram `.md` file contains Mermaid diagram(s) plus explanatory text:

```markdown
# Request Flow

> **Type**: Flow
> **Last Updated**: 2026-01-23
> **Covers**: How HTTP requests are processed end-to-end

## Diagram

\`\`\`mermaid
flowchart TD
    Client -->|HTTP POST /api/users| Router
    Router --> AuthMiddleware
    AuthMiddleware -->|valid token| UserHandler
    AuthMiddleware -->|invalid token| E_401[401 Unauthorized]
    UserHandler --> UserService
    UserService --> Database
    Database -->|result| UserService
    UserService -->|user object| UserHandler
    UserHandler -->|200 OK| Client
\`\`\`

## Key Decisions

- Auth is checked at middleware level, not inside handlers
- UserService owns all DB interactions for user data
```

---

## Skill and Agent Reference

### Skill: `cadence:using-cadence`

The single entry point for Cadence. Activates at session start and on every Cadence-relevant turn. Detects the active session folder, asks whether to resume or start fresh, walks `session.md` top-to-bottom, and spawns the agent that owns the first section with any `- [ ]` item.

### Agents

Each agent owns one section of `session.md` and is spawned by `using-cadence`:

| Agent | Owns | Responsibility |
|---|---|---|
| `clarify` | `## Clarification` | Capture intent, list open questions, write the initial `session.md`, recommend a session type |
| `analyze-problem` | `## Analysis` | Investigate the problem (bugfix/analysis sessions) and record findings |
| `plan` | `## Plan` | Propose document and diagram updates; manage plan mode internally; runs a subagent diagram review loop until `APPROVED` or `APPROVED_WITH_WARNINGS` |
| `implement` | `## Implementation` | Read `## Plan` and the relevant diagrams, then write code that follows the defined boundaries and flow order |
| `review` | `## Review` | Run a code review (doc/diagram alignment plus code quality), fix critical issues, and re-review until `APPROVED` or `APPROVED_WITH_WARNINGS` |
| `deliver` | `## Delivery` | Run a retrospective, consolidate learnings, and write the final summary |

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
If deviations are consistently valid (the code is right, the document is wrong), update the documents in the next Cadence session. If deviations are consistently invalid (the code drifted from the document), enforce Cadence more strictly by always running through `## Plan` before `## Implementation`.

---

## Credits

The Simplicity First, Surgical Changes, and Goal-Driven Execution rules in Cadence are adapted from [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills), a distillation of [Andrej Karpathy's observations](https://x.com/karpathy/status/2015883857489522876) on common LLM coding pitfalls.

---

## License

MIT
