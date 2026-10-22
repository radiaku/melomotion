---
title: Recording cost
status: planned
tags: [recording]
up: "[[recording]]"
updated: 2026-10-22
---

# Recording cost

`vim.on_key` runs on every key press, and `CursorMoved` runs on almost every one. Anything slow in them shows up as typing lag.

- Inside these hooks, only append a small table to an in-memory list. No file I/O, no `vim.fn` calls that touch the filesystem, no string formatting beyond what's needed.
- Write to disk off the hot path: on `:Serenade save`, on `:Serenade stop`, on `VimLeavePre`, or from a `vim.uv` timer ([[storage]]).
- Cap the in-memory list. If it fills up before a flush, flush early rather than grow forever.
- When recording is off, no hooks are registered at all. Detach them with `vim.on_key(nil, ns)` and delete the autocommand group.

## Related

- [[lazy-loading]]: the same rule applied at startup
- [[recording-session]]
