---
title: Configuration
status: planned
tags: [architecture]
up: "[[architecture]]"
updated: 2026-10-22
---

# Configuration

The plugin works without a `setup()` call. Configuration is kept separate from initialization.

- Defaults live in `lua/melomotion/config.lua`.
- `require("melomotion").setup(opts)` only merges options: `vim.tbl_deep_extend("force", defaults, opts or {})`.
- Calling `setup()` more than once must be safe. lazy.nvim calls it for you when a spec has `opts`.
- Check options with `vim.validate`, and report bad values through `vim.notify` and [[health-check]] instead of throwing at startup.
- Every option is documented in `doc/melomotion.txt` ([[vimdoc-vs-docs]]) and typed ([[type-annotations]]).
