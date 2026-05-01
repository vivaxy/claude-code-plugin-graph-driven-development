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

## Quick Start

### 1. Plan a New Feature

Before writing any code:

```
cadence:plan Add user authentication with JWT tokens
```

Claude analyzes the current documents and diagrams (or creates them if missing), presents the proposed changes in the conversation, and waits for your confirmation before writing anything to `docs/`. After applying the changes, Claude automatically runs a diagram review as a subagent — fixing critical issues and re-reviewing until the documents are approved.

### 2. Implement

```
cadence:code Implement JWT authentication middleware
```

Claude reads the documents and diagrams, extracts implementation constraints, then writes code that follows the defined boundaries and flows. Any necessary deviations are recorded. After implementation, Claude automatically runs a code review as a subagent — fixing critical issues and re-reviewing until the code is approved.

---

## The Cadence

```
┌────────────────────────────────────┐
│  cadence:plan              │
│  Propose → confirm → apply         │
│  Subagent review → fix → re-review │
│  └────── until APPROVED ──────┘    │
└──────────────┬─────────────────────┘
               │
               ▼
┌────────────────────────────────────┐
│  cadence:code              │
│  Read docs & diagrams → implement  │
│  Subagent review → fix → re-review │
│  └────── until APPROVED ──────┘    │
└────────────────────────────────────┘
```

Documents and diagrams live in `docs/`. They change first, code follows.

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

## Skill Reference

### `cadence:plan <requirement>`

Propose document and diagram updates for a new requirement and apply them after confirmation.

- Reads current documents and diagrams (auto-creates `docs/` if missing)
- Analyzes impact of the requirement
- Presents the proposed changes in the conversation
- Writes the approved changes to `docs/` after user confirmation
- Automatically runs a subagent diagram review loop — fixing critical issues and re-reviewing until reaching `APPROVED` or `APPROVED_WITH_WARNINGS`
- Then invokes `cadence:code` to implement the feature

**When to use**: Before starting any new feature or change.

---

### `cadence:code <task description>`

Implement code guided by Cadence documents and diagrams.

- Reads documents and diagrams and extracts implementation constraints
- Writes code that follows defined module boundaries and flow order
- Records any necessary deviations in the conversation
- Automatically runs a subagent code review loop (doc/diagram alignment + code quality) — fixing critical issues and re-reviewing until reaching `APPROVED` or `APPROVED_WITH_WARNINGS`

**When to use**: When documents and diagrams are approved and you're ready to implement.

---

## Best Practices

### Keep Documents and Diagrams at the Right Level of Abstraction

Too detailed → maintenance burden that slows you down  
Too abstract → no actual constraint on implementation

**Good**: Show module boundaries, decision points, external system interactions, key requirements  
**Avoid**: Function signatures, variable types, implementation details

### One Source of Truth

Documents and diagrams in `docs/` (not `drafts/`) are authoritative. When code and docs disagree:

1. If the code is right → update the document/diagram via `cadence:plan`
2. If the document/diagram is right → fix the code

Never silently accept drift.

### Documents and Diagrams Are Living Documents

Update them when you learn something new. A document that accurately reflects a simpler system is better than one that aspires to a complex system that doesn't exist.

### Use Cadence for New Features, Not Archaeology

Don't run `cadence:plan` on a legacy codebase expecting perfect diagrams. Use it to start a document set that's roughly accurate, then refine as you work on each area.

---

## Troubleshooting

**"docs/ is missing or incomplete"**  
Just describe your requirement — `cadence:plan` will auto-create the initial documents and diagrams.

**The generated diagrams are inaccurate**  
This is expected for complex codebases. Correct them manually — they are Markdown files with Mermaid blocks, easy to edit. Accuracy improves over time as you run `cadence:plan` for each change.

**Code review finds too many deviations**  
If deviations are consistently valid (the code is right, the document is wrong), the documents need to be updated via `cadence:plan`. If deviations are consistently invalid (the code ignored the document), enforce the Cadence more strictly.

---

## Credits

The Simplicity First, Surgical Changes, and Goal-Driven Execution rules in Cadence are adapted from [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills), a distillation of [Andrej Karpathy's observations](https://x.com/karpathy/status/2015883857489522876) on common LLM coding pitfalls.

---

## License

MIT
