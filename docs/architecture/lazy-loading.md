---
title: Lazy loading
status: stable
tags: [architecture]
up: "[[architecture]]"
updated: 2026-10-22
---

# Lazy loading

The plugin keeps its own startup cost close to zero, so it works the same whether or not the plugin manager lazy-loads it.

- `plugin/melomotion.lua` only creates `:Melomotion` and five `<Plug>` mappings ([[commands-and-keymaps]]).
- Their callbacks, including command completion, call `require("melomotion.command")` inside the function body, so a module loads on first use.
- `plugin/` never requires a module at the top level. A test checks that `package.loaded["melomotion"]` is still nil after startup.
- It guards against being sourced twice with `vim.g.loaded_melomotion`.

Because of this, the readme recommends `lazy = false`. A lazy.nvim `cmd` trigger would leave the `<Plug>` mappings undefined until first use.

## Related

- [[plugin-layout]]
- [[recording-cost]]: the same idea applied while recording
