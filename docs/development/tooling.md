---
title: Tooling
status: stable
tags: [development]
up: "[[development]]"
updated: 2026-10-22
---

# Tooling

| Command          | Does |
| ---------------- | ---- |
| `make check`     | `fmt-check`, then `lint`, then `test`. Run it before every commit. |
| `make test`      | Runs the mini.test suite ([[testing]]). The first run clones mini.nvim into `deps/`. |
| `make lint`      | luacheck on `lua/`, `plugin/` and `tests/` (`.luacheckrc`) |
| `make fmt`       | StyLua rewrites files in place (`.stylua.toml`) |
| `make fmt-check` | StyLua reports unformatted files without changing them |

StyLua and luacheck come from `PATH`, or from Mason (`~/.local/share/nvim/mason/bin`) when they aren't on it ([[adr-0008-stylua-and-luacheck]]). The Makefile runs them by full path, because macOS's make 3.81 ignores an exported `PATH` for commands it runs without a shell. `make check STYLUA=… LUACHECK=…` overrides either. Type checking isn't wired up ([[type-annotations]]).
