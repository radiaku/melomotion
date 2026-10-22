---
title: Local dev loop
status: planned
tags: [development]
up: "[[development]]"
updated: 2026-10-22
---

# Local dev loop

There are two ways to run the code from this checkout.

## In a clean Neovim

```sh
nvim --clean --cmd "set rtp^=."
```

`--clean` skips your config but still sources `plugin/` from every runtimepath entry, and `--cmd` runs before that happens. You get this plugin and nothing else. It's the quickest way to tell a plugin bug from a config interaction.

## Inside the daily config

The radia config (`~/Dev/personal/nvim`) loads local plugins through lazy.nvim `dir =` specs, the same way `lua/radia/plugins/disabled/melomotion.lua` does. Put the spec in a group that gets imported (any folder except `disabled/`):

```lua
return {
  dir = "~/Dev/personal/nvim-serenade",
  name = "serenade",
}
```

After a change, restart Neovim or run `:Lazy reload serenade`.

## Related

- [[lazy-loading]]: what loads at startup and what waits
- [[health-check]]
