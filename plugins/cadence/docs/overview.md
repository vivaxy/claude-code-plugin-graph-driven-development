# cadence Plugin — System Overview

> **Type**: Overview
> **Last Updated**: 2026-04-18
> **Covers**: System boundary and external actors for the Cadence Claude Code plugin

## Diagram

```mermaid
flowchart TD
    User["Developer (User)"]
    ClaudeCode["Claude Code CLI"]
    Plugin["cadence Plugin<br>(skills + hooks)"]
    ProjectDocs["docs/<br>(design documents + diagram files)"]
    ProjectCode["Project Source Code"]

    User -->|describes feature task| ClaudeCode
    ClaudeCode -->|loads & executes| Plugin
    Plugin -->|reads / writes| ProjectDocs
    Plugin -->|reads / writes| ProjectCode
    ProjectDocs -->|constrains| ProjectCode
```

## Key Decisions

- The plugin has no runtime server — it is a set of instruction files interpreted by Claude Code
- `docs/` is the authoritative source of truth; code must conform to documents and diagrams, not the reverse
- The plugin operates on the user's project directory, not on its own source

## Notes

- See `flow-execution.md` for the automatic skill invocation workflow
- See `arch-modules.md` for internal plugin component layout
