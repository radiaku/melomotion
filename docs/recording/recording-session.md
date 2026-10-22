---
title: Recording session
status: planned
tags: [recording]
up: "[[recording]]"
updated: 2026-10-22
---

# Recording session

Recording is opt-in. Nothing is recorded until you start it.

| Command            | Does                                                     |
| ------------------ | -------------------------------------------------------- |
| `:Melomotion start`  | Registers the hooks ([[event-sources]]) and starts a session |
| `:Melomotion stop`   | Removes the hooks and writes the session to disk           |
| `:Melomotion save`   | Writes what's buffered so far and keeps recording          |

These are subcommands of one user command ([[commands-and-keymaps]]). Each also gets a `<Plug>(melomotion-…)` mapping.

A session that's still running when Neovim exits is written on `VimLeavePre`.

How recordings are read back afterwards (an in-editor report, or an export for other tools) is open: [[open-questions]].

## Related

- [[storage]]
- [[recording-cost]]
