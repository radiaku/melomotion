---
title: Plugin layout
status: stable
tags: [architecture]
up: "[[architecture]]"
updated: 2026-10-22
---

# Plugin layout

```text
melomotion/
├── plugin/melomotion.lua        # sourced at startup: :Melomotion and <Plug> maps only
├── lua/melomotion/init.lua      # public API: setup, start, stop, save, status, is_recording
├── lua/melomotion/config.lua    # defaults, validation, merging
├── lua/melomotion/recorder.lua  # hooks and movement events
├── lua/melomotion/storage.lua   # session files
├── lua/melomotion/command.lua   # :Melomotion subcommands and their messages
├── lua/melomotion/health.lua    # :checkhealth melomotion
├── doc/melomotion.txt           # vimdoc for users
├── tests/                       # mini.test cases
├── Makefile                     # check, test, lint, fmt
└── docs/                        # this brain; not shipped
```

How data flows: `recorder` calls an `emit` function with one table per movement. `init` passes it a function that pushes into the current `storage` session. `storage` stamps the time and writes JSON Lines when it flushes.

The recorder knows nothing about files, and storage knows nothing about Neovim events. That's why the recorder tests can use an in-memory `emit` ([[testing]]).

- Neovim sources `plugin/` at startup for everyone who installs the plugin, so it stays tiny ([[lazy-loading]]).
- `require("melomotion")` is the only public Lua module. Everything else under `lua/melomotion/` can change without a major version bump ([[versioning]]).
- `doc/` and `docs/` serve different readers ([[vimdoc-vs-docs]]).
