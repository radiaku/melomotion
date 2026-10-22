---
title: Commands and keymaps
status: planned
tags: [architecture]
up: "[[architecture]]"
updated: 2026-10-22
---

# Commands and keymaps

- One user command with subcommands (`:Melomotion <sub>`, for example the ones in [[recording-session]]) instead of many top-level commands. Subcommands complete through the command's `complete` function.
- No default keymaps. The plugin exposes `<Plug>(melomotion-…)` mappings, and users bind them.
- Both are defined in `plugin/melomotion.lua` and load their code lazily ([[lazy-loading]]).
- Both are public API ([[versioning]]), so renaming one is a breaking change.
