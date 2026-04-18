---
name: vivaxy-workflow:using-vivaxy-workflow
description: Guide for when to apply vivaxy Workflow — read at session start to understand when vivaxy Workflow applies and what to do first
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

# Using vivaxy Workflow

vivaxy Workflow enforces a structured 5-phase development process: main:clarify → main:plan → execute subtasks → main:review → main:deliver.

## When vivaxy Workflow Applies

| Task type | vivaxy Workflow required? |
|-----------|--------------------------|
| Implement a new feature | YES — route based on workflow state |
| Add a new API endpoint or route | YES — route based on workflow state |
| Refactor a module's structure | YES — route based on workflow state |
| Add a new component / service | YES — route based on workflow state |
| Fix a bug in existing code | NO |
| Fix a typo or rename | NO |
| Write or update tests | NO |
| Answer a question | NO |
| Update documentation | NO |
| Update a config value | NO |

**Rule**: If the task adds new behavior or changes how modules interact — vivaxy Workflow applies. If it corrects something that was supposed to work already — vivaxy Workflow does not apply.

## Routing Logic

For feature tasks, detect the current workflow state by checking `docs/`:

| Condition | Route to |
|-----------|----------|
| `docs/doc-clarification.md` does not exist | `vivaxy-workflow:main:clarify` |
| `doc-clarification.md` exists, `doc-subtasks.md` does not exist | `vivaxy-workflow:main:plan` |
| `doc-subtasks.md` exists with at least one PENDING subtask | `vivaxy-workflow:subtask-execute <first-pending-id>` |
| All subtasks in `doc-subtasks.md` are ACCEPTED, no retrospective yet | `vivaxy-workflow:main:review` |
| `doc-retrospective-*.md` does not exist after all subtasks accepted | `vivaxy-workflow:main:deliver` |
| Bug fix / non-feature task | Proceed normally |

## How to Route

Do not wait for user confirmation. Immediately:

1. Say one line: "vivaxy Workflow is active — routing to `vivaxy-workflow:<skill>`."
2. Invoke the appropriate skill.

## When vivaxy Workflow Is Not Initialized

If `docs/` does not exist or `doc-clarification.md` is missing, invoke `vivaxy-workflow:main:clarify` directly. It will create `docs/` as needed.

## Instruction Priority

1. User's explicit instructions (CLAUDE.md, direct requests) — highest
2. vivaxy Workflow routing — for feature development tasks
3. Default behavior — for everything else

If the user says "just implement it, skip the workflow" — respect that.
