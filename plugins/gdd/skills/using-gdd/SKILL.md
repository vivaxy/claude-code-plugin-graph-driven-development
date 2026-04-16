---
name: gdd:using-gdd
description: Guide for when to apply the GDD workflow — read at session start to understand when GDD applies and what to do first
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

# Using GDD (Graph Driven Development)

GDD enforces a documents-and-diagrams-first development process: write design documents and update architecture/flow diagrams **before** writing any code.

## When GDD Applies

| Task type | GDD required? |
|-----------|--------------|
| Implement a new feature | YES — invoke `gdd:plan` skill |
| Add a new API endpoint or route | YES — invoke `gdd:plan` skill |
| Refactor a module's structure | YES — invoke `gdd:plan` skill |
| Add a new component / service | YES — invoke `gdd:plan` skill |
| Fix a bug in existing code | NO |
| Fix a typo or rename | NO |
| Write or update tests | NO |
| Answer a question | NO |
| Update documentation | NO |
| Update a config value | NO |

**Rule**: If the task adds new behavior or changes how modules interact — GDD applies. If it corrects something that was supposed to work already — GDD does not apply.

## Routing Logic

1. Is this a feature/new-functionality task?
   - NO → proceed normally
   - YES → check project state:

2. Does `docs/` exist with at least one `flow-*.md` AND one `arch-*.md`?
   - NO → proactively create the missing documents, then invoke `gdd:plan`
   - YES → invoke `gdd:plan` skill directly with the user's requirement as the argument

## When docs/ Is Not Initialized

Do NOT ask the user to run any setup command. Proactively create the initial documents yourself:

1. Briefly tell the user: "GDD is active — `docs/` is missing, so I'll generate the initial design documents and diagrams first."
2. Scan the project (read key files: `package.json`, `README.md`, top-level dirs, up to 5 source files)
3. Create `docs/` and generate the appropriate initial files:
   - `docs/overview.md` — system context diagram
   - At least one `docs/flow-*.md` — main flow diagram
   - At least one `docs/arch-*.md` — module architecture diagram
4. After generating, immediately invoke the `gdd:plan` skill with the original requirement as the argument

## When docs/ Is Initialized

Do not wait for user confirmation. Immediately:

1. Say one line: "GDD is active — running `gdd:plan` for your requirement."
2. Invoke the `gdd:plan` skill with the user's requirement as the argument.

## Instruction Priority

1. User's explicit instructions (CLAUDE.md, direct requests) — highest
2. GDD workflow — for feature development tasks
3. Default behavior — for everything else

If the user says "just implement it, skip the diagrams" — respect that.
