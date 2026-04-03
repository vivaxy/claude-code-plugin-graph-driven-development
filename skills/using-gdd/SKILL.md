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
| Implement a new feature | YES — run `/gdd:plan` first |
| Add a new API endpoint or route | YES |
| Refactor a module's structure | YES |
| Add a new component / service | YES |
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
   - NO → offer `/gdd:init` first, then `/gdd:plan`
   - YES → run `/gdd:plan` (then `/gdd:code` to implement)

## When GDD Is Not Initialized

Say:

> This project doesn't have GDD diagrams yet. Before implementing, I'll need to map the current architecture first.
>
> Run `/gdd:init` to generate the initial diagrams, then I'll run `/gdd:plan` to design the changes before writing any code.
>
> Would you like me to start with `/gdd:init` now?

## When GDD Is Initialized

Say:

> GDD is active. I'll run `/gdd:plan` first to update the architecture diagrams for this feature, then implement via `/gdd:code`.

Then invoke `gdd:plan` with the user's requirement as the argument.

## Instruction Priority

1. User's explicit instructions (CLAUDE.md, direct requests) — highest
2. GDD workflow — for feature development tasks
3. Default behavior — for everything else

If the user says "just implement it, skip the diagrams" — respect that.
