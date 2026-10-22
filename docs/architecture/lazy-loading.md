---
title: Lazy loading
status: planned
tags: [architecture]
up: "[[architecture]]"
updated: 2026-10-22
---

# Lazy loading

The plugin keeps its own startup cost close to zero, so it works the same whether or not the user's plugin manager lazy-loads it.

- `plugin/melomotion.lua` only creates user commands and `<Plug>` mappings ([[commands-and-keymaps]]).
- Their callbacks call `require("melomotion…")` inside the function body, so a module loads on first use.
- `plugin/` never requires internal modules at the top level.
- Guard against being sourced twice:

```lua
if vim.g.loaded_melomotion then
  return
end
vim.g.loaded_melomotion = true
```

## Related

- [[plugin-layout]]
