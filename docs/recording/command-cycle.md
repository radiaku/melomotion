---
title: Command cycle
status: stable
tags: [recording]
up: "[[recording]]"
updated: 2026-10-22
---

# Command cycle

melomotion records one event per finished command, not one per key or per autocommand. The first key of a command schedules `end_cycle()`, which compares where you are with where you were.

This relies on how Neovim orders things. Measured in a child Neovim 0.10.4:

- `vim.on_key` runs for each key before Neovim processes it.
- `CursorMoved`, `WinScrolled` and `TextChanged` fire once the command has finished and no typed keys are waiting.
- A `vim.schedule` callback queued from `on_key` runs after those autocommands, when Neovim waits for input again.
- While a command still needs keys (`f` waiting for its character, a count, `<C-w>`, `g`), scheduled callbacks don't run. So `f(` with a pause in between is still one cycle.
- They do run in operator-pending mode (`d` … `w`) and on the command line. `end_cycle()` returns early in both, because the command isn't done yet.
- They also run while a plugin waits in `getchar()`. `end_cycle()` returns early then too ([[key-reading-plugins]]).

Comparing locations also removes duplicates. A `<C-d>` fires both `CursorMoved` and `WinScrolled` but records one event. A plugin that hops into another window and back within one command records nothing.

## Related

- [[event-sources]]
- [[recording-cost]]
