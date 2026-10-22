---
title: Health check
status: planned
tags: [architecture]
up: "[[architecture]]"
updated: 2026-10-22
---

# Health check

`lua/serenade/health.lua` returns a table with a `check()` function, and `:checkhealth serenade` finds it on its own.

Report results with `vim.health.start`, `vim.health.ok`, `vim.health.warn` and `vim.health.error`. Check what can actually break:

- the Neovim version, against the minimum (not chosen yet, see [[open-questions]])
- external dependencies, once there are any
- invalid user options from [[configuration]]
