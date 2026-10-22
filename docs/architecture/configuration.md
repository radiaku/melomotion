---
title: Configuration
status: stable
tags: [architecture]
up: "[[architecture]]"
updated: 2026-10-22
---

# Configuration

The plugin works without a `setup()` call. Configuration is kept separate from starting a recording.

| Option           | Default                           | Used by |
| ---------------- | --------------------------------- | ------- |
| `autostart`      | `false`                           | `setup()` starts a session |
| `dir`            | `stdpath("state") .. "/melomotion"` | [[storage]] |
| `flush_interval` | `60000` ms (0 = only save, stop, exit) | [[recording-cost]] |
| `max_buffered`   | `500` records                     | [[recording-cost]] |
| `async_window`   | `2000` ms                         | [[late-jumps]] |

- Defaults live in `lua/melomotion/config.lua`. `set()` merges options over the defaults (not over the previous options), so calling `setup()` twice is safe. lazy.nvim calls it for you when a spec has `opts`.
- Validation is hand-written: known keys, the right type, no negative numbers. `vim.validate` changed its signature in 0.11 ([[adr-0006-minimum-neovim-0-10]]). A bad option is reported with `vim.notify`, kept for [[health-check]], and leaves the previous options in place.
- Every option is documented in `doc/melomotion.txt` ([[vimdoc-vs-docs]]) and typed as `melomotion.Config` / `melomotion.UserConfig` ([[type-annotations]]).
