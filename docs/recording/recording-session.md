---
title: Recording session
status: stable
tags: [recording]
up: "[[recording]]"
updated: 2026-10-22
---

# Recording session

Recording is opt-in. Nothing is recorded until you start it, unless `autostart` is set ([[configuration]]). One session writes one file ([[storage]]).

| Command              | Does                                                |
| -------------------- | --------------------------------------------------- |
| `:Melomotion start`  | Opens a session file and attaches the hooks         |
| `:Melomotion stop`   | Detaches the hooks and writes everything left       |
| `:Melomotion toggle` | Start or stop                                       |
| `:Melomotion save`   | Writes what's waiting and keeps recording           |
| `:Melomotion status` | Shows the file and how many records are written     |

Each one except `status` has a `<Plug>(melomotion-…)` mapping ([[commands-and-keymaps]]).

- `stop` first runs a [[command-cycle]] that's still waiting, so a jump in the last command isn't lost.
- A session still running when Neovim exits is stopped on `VimLeavePre`.
- The old `:MelomotionStart` and `:MelomotionSave` are gone ([[adr-0005-merge-into-melomotion]]).

How recordings are read back is still open: [[open-questions]].
