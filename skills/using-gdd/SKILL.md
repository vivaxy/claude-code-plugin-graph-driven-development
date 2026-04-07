---
name: gdd:using-gdd
description: Guide for when to apply the GDD workflow — read at session start to understand when GDD applies and what to do first
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

# Using GDD (Graph Driven Development)

GDD enforces a diagrams-first development process: update architecture and flow diagrams before writing code.

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

2. Does `docs/gdd/` exist with at least one `flow-*.md` AND one `arch-*.md`?
   - NO → offer to run `gdd:init` first, then invoke `gdd:plan`
   - YES → invoke `gdd:plan` skill directly with the user's requirement as the argument

## When GDD Is Not Initialized

Briefly inform the user, then ask for confirmation before invoking `gdd:init` (since it scans the project and creates files):

> This project doesn't have GDD diagrams yet. I'll need to map the current architecture first via `gdd:init`, then run `gdd:plan` to design the changes.
>
> Shall I start with `gdd:init` now?

If the user confirms, invoke the `gdd:init` skill. After it completes, invoke the `gdd:plan` skill with the original requirement as the argument.

## When GDD Is Initialized

Do not wait for user confirmation. Immediately:

1. Say one line: "GDD is active — running `gdd:plan` for your requirement."
2. Invoke the `gdd:plan` skill with the user's requirement as the argument.

## Instruction Priority

1. User's explicit instructions (CLAUDE.md, direct requests) — highest
2. GDD workflow — for feature development tasks
3. Default behavior — for everything else

If the user says "just implement it, skip the diagrams" — respect that.
