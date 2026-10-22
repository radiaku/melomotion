---
title: Late jumps
status: stable
tags: [recording]
up: "[[recording]]"
updated: 2026-10-22
---

# Late jumps

Some jumps arrive after the command that asked for them. LSP `gd` waits for the server to answer.

- When a cycle has keys but nothing moved, `end_cycle()` keeps those keys as the *orphan*.
- If a movement with no keys of its own happens within `async_window` milliseconds (default 2000, see [[configuration]]), it gets the orphan's keys and `async = true`.
- Any movement clears the orphan. Edits and operators never become orphans.

The trade-off: an unrelated movement with no keys (a plugin moving the cursor) inside that window gets misattributed. `async` marks these events, so an analysis can treat them separately.
