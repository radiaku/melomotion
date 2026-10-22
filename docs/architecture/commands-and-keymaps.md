---
title: Commands and keymaps
status: stable
tags: [architecture]
up: "[[architecture]]"
updated: 2026-10-22
---

# Commands and keymaps

- There's one user command, `:Melomotion {start|stop|toggle|save|status}`, rather than one command per action ([[recording-session]]). Subcommands complete from `command.complete()`. An unknown one is reported as an error that lists the valid ones.
- There are no default keymaps. `<Plug>(melomotion-start|stop|toggle|save)` exist for users to bind. `vim.keymap.set` makes a mapping recursive when its right-hand side starts with `<Plug>`, so users don't need `remap = true`.
- Both are defined in `plugin/melomotion.lua` and load their code lazily ([[lazy-loading]]).
- The messages (`recording to …`, `stopped, N records in …`) live in `command.lua`. The API in `init.lua` stays silent, so `autostart` doesn't print anything at startup.
- Both the command and the mappings are public API ([[versioning]]), so renaming one is a breaking change.
