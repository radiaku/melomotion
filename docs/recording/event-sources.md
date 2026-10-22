---
title: Event sources
status: stable
tags: [recording]
up: "[[recording]]"
updated: 2026-10-22
---

# Event sources

| Hook                                              | Role |
| ------------------------------------------------- | ---- |
| `vim.on_key(fn, ns)`                              | Collects the `typed` argument: what you pressed, before mappings. Keys from mappings, `:normal` and macro replay arrive with `typed` empty and are ignored, so `<Space>g` is recorded rather than whatever it expands to. Keys typed in insert, replace, terminal, command-line and prompt modes are text and are skipped. `<MouseMove>` is skipped too. |
| `CursorMoved`, `WinScrolled`, `BufEnter`, `TextChanged` | Only schedule a [[command-cycle]]. That way movements with no keys (timers, LSP) and edits from elsewhere still get compared. |
| `WinEnter`                                        | Notes when you enter a float ([[picker-landing]]). |
| `ModeChanged`                                     | Marks operators and leaving insert or visual mode ([[edit-filtering]]). |
| `CmdlineLeave`                                    | Swaps the `:`, `/` or `?` you typed for the whole line, so the keys read `:42` or `/foo`. It only does this when that character was the last key you typed. A mapping that opens the command line keeps its own keys. |

The old melomotion used `on_key`'s first argument (keys after mapping). That's why it saw internal codes like `<t_…>` and had to filter them out.
