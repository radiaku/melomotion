---
title: Plugin layout
status: planned
tags: [architecture]
up: "[[architecture]]"
updated: 2026-10-22
---

# Plugin layout

```text
melomotion/
├── plugin/melomotion.lua       # sourced at startup: commands and <Plug> maps only
├── lua/melomotion/init.lua     # public API: require("melomotion")
├── lua/melomotion/config.lua   # defaults and merging of user options
├── lua/melomotion/health.lua   # :checkhealth melomotion
├── lua/melomotion/*.lua        # internal modules, required on demand
├── doc/melomotion.txt          # vimdoc for users
├── tests/                    # runner not chosen yet
└── docs/                     # this brain; not shipped to users
```

- Neovim sources `plugin/` at startup for everyone who installs the plugin, so it stays tiny ([[lazy-loading]]).
- `require("melomotion")` is the only public Lua module. Anything else under `lua/melomotion/` can change without a major version bump ([[versioning]]).
- `doc/` and `docs/` serve different readers ([[vimdoc-vs-docs]]).
- How tests are laid out depends on the runner ([[testing]]).
