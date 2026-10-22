---
title: Event sources
status: planned
tags: [recording]
up: "[[recording]]"
updated: 2026-10-22
---

# Event sources

Autocommands report *that* you moved but not *how*. `vim.on_key` reports which keys you pressed. Serenade needs both: the key gives the cause, and the autocommand gives the effect.

| Hook                            | Gives                                              |
| ------------------------------- | -------------------------------------------------- |
| `vim.on_key(fn)`                | Keys after mapping, plus the typed keys (`typed` argument) |
| `CursorMoved`                   | New cursor position, normal and visual mode only   |
| `WinScrolled`                   | Scrolls without a cursor move                      |
| `BufEnter`, `WinEnter`, `TabEnter` | Buffer, window and tab switches                 |
| `CmdlineLeave`                  | Searches: `vim.fn.getcmdtype()` is `/` or `?`      |
| `ModeChanged`                   | Entering and leaving visual or insert mode         |

How they combine: `on_key` keeps the keys pressed since the last movement. The next movement event takes those keys as its cause and clears them. A movement with no keys came from a timer, an LSP callback or a plugin.

`CursorMoved` doesn't fire in insert mode (`CursorMovedI` does), so recording only `CursorMoved` already skips most editing. Normal-mode edits still move the cursor: [[edit-filtering]].

All of these run very often: [[recording-cost]].
