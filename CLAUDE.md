# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a Claude Code plugin collection. It contains plugins and a marketplace manifest for distributing them via the Claude Code plugin system.

## Structure

```
plugins/sdd/          — Spec Driven Development plugin
  .claude-plugin/     — Plugin metadata (plugin.json)
  skills/             — Subagent skill definitions (SKILL.md files)
  hooks/              — SessionStart hook (session-start bash script + hooks.json)
  docs/               — SDD diagram spec and example docs
  CLAUDE.md           — SDD behavior rules injected into user projects
plugins/analyze/      — Problem Analysis plugin
  .claude-plugin/     — Plugin metadata (plugin.json)
  commands/           — /analyze:problem and /analyze:model commands
  skills/             — using-analyze orientation skill
  hooks/              — SessionStart hook injecting using-analyze context
  CLAUDE.md           — Brief usage note injected into user projects
.claude-plugin/marketplace.json      — Marketplace manifest listing available plugins
```

## Plugin Architecture

Each plugin lives in `plugins/<name>/` and contains:

- **`.claude-plugin/plugin.json`** — Name, version, description, author metadata
- **`commands/*.md`** — Slash commands with YAML frontmatter (`name`, `description`, `argument-hint`, `allowed-tools`) followed by the command prompt in XML tags
- **`skills/<skill-name>/SKILL.md`** — Skills with YAML frontmatter (`name`, `description`, `allowed-tools`) followed by the skill prompt; skills marked `<SUBAGENT-STOP>` are intended for subagent invocation only
- **`hooks/hooks.json`** — Hook event bindings (e.g., SessionStart matcher → shell command)
- **`hooks/<event-name>`** — Shell scripts executed by hooks; must output JSON (`hookSpecificOutput.additionalContext` for Claude Code)
- **`CLAUDE.md`** — Content injected into the user's project when the plugin is installed

The `.claude-plugin/marketplace.json` at the repo root is the distribution manifest — it lists plugins with their local `source` paths. Users register it once with `/plugin marketplace add <path>` then install plugins by name.

## Versioning

Version is tracked in `plugins/<name>/.claude-plugin/plugin.json`. The `.claude-plugin/marketplace.json` at root also contains a version field for each plugin — keep both in sync when releasing.

## Language

All plugin content — commands, skills, hooks, docs, output messages, and comments — must be written in **English**.

## Key Conventions

- Command prompts use `$ARGUMENTS` to reference user-provided arguments
- Mermaid diagrams in docs use `<br>` for line breaks inside node labels (not `\n`)
- Hook scripts must handle both Claude Code (`CLAUDE_PLUGIN_ROOT`) and Cursor (`CURSOR_PLUGIN_ROOT`) environments
- The `session-start` hook reads the plugin's orientation skill and injects it as session context via `additionalContext`
