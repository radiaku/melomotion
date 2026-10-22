---
title: Plugin layout
status: planned
tags: [architecture]
up: "[[architecture]]"
updated: 2026-10-22
---

# Plugin layout

```text
nvim-serenade/
├── plugin/serenade.lua       # sourced at startup: commands and <Plug> maps only
├── lua/serenade/init.lua     # public API: require("serenade")
├── lua/serenade/config.lua   # defaults and merging of user options
├── lua/serenade/health.lua   # :checkhealth serenade
├── lua/serenade/*.lua        # internal modules, required on demand
├── doc/serenade.txt          # vimdoc for users
├── tests/                    # runner not chosen yet
└── docs/                     # this brain; not shipped to users
```

- Neovim sources `plugin/` at startup for everyone who installs the plugin, so it stays tiny ([[lazy-loading]]).
- `require("serenade")` is the only public Lua module. Anything else under `lua/serenade/` can change without a major version bump ([[versioning]]).
- `doc/` and `docs/` serve different readers ([[vimdoc-vs-docs]]).
- How tests are laid out depends on the runner ([[testing]]).
