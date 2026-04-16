---
name: sdd:using-sdd
description: Guide for when to apply the SDD workflow — read at session start to understand when SDD applies and what to do first
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

# Using SDD (Spec Driven Development)

SDD enforces a spec-first development process: write/update design documents and architecture diagrams before writing code.

## When SDD Applies

| Task type | SDD required? |
|-----------|--------------|
| Implement a new feature | YES — invoke `sdd:plan` skill |
| Add a new API endpoint or route | YES — invoke `sdd:plan` skill |
| Refactor a module's structure | YES — invoke `sdd:plan` skill |
| Add a new component / service | YES — invoke `sdd:plan` skill |
| Fix a bug in existing code | NO |
| Fix a typo or rename | NO |
| Write or update tests | NO |
| Answer a question | NO |
| Update documentation | NO |
| Update a config value | NO |

**Rule**: If the task adds new behavior or changes how modules interact — SDD applies. If it corrects something that was supposed to work already — SDD does not apply.

## Routing Logic

1. Is this a feature/new-functionality task?
   - NO → proceed normally
   - YES → check project state:

2. Does `docs/` exist with at least one `flow-*.md` AND one `arch-*.md`?
   - NO → invoke `sdd:plan` skill directly (it will auto-initialize `docs/` as needed)
   - YES → invoke `sdd:plan` skill directly with the user's requirement as the argument

## When SDD Is Not Initialized

Do not wait for user confirmation. Immediately invoke the `sdd:plan` skill — it will proactively create the missing `docs/` files as part of the plan.

## When SDD Is Initialized

Do not wait for user confirmation. Immediately:

1. Say one line: "SDD is active — running `sdd:plan` for your requirement."
2. Invoke the `sdd:plan` skill with the user's requirement as the argument.

## Instruction Priority

1. User's explicit instructions (CLAUDE.md, direct requests) — highest
2. SDD workflow — for feature development tasks
3. Default behavior — for everything else

If the user says "just implement it, skip the spec" — respect that.
