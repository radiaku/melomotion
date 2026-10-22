---
title: Tooling
status: planned
tags: [development]
up: "[[development]]"
updated: 2026-10-22
---

# Tooling

Nothing is chosen yet. Candidates:

| Job    | Candidates                                     |
| ------ | ---------------------------------------------- |
| Format | StyLua                                         |
| Lint   | selene, luacheck                               |
| Types  | lua-language-server `--check` ([[type-annotations]]) |
| Tests  | see [[testing]]                                |

Once a tool is picked:

1. Commit its config file.
2. Put its exact command under Commands in `CLAUDE.md`.
3. Record the choice as an ADR ([[decisions]]) and remove it from [[open-questions]].
4. Set this note's status to `stable`.
