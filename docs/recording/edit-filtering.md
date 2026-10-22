---
title: Edit filtering
status: planned
tags: [recording]
up: "[[recording]]"
updated: 2026-10-22
---

# Edit filtering

Normal-mode edits move the cursor too (`dd`, `p`, `J`, `u`), and those moves fire `CursorMoved` like any motion. melomotion drops them by watching `b:changedtick`.

- Each buffer keeps the last `vim.b.changedtick` melomotion saw.
- On a movement event, if `changedtick` went up since the previous event, an edit caused the move. Drop it, clear the pending keys ([[event-sources]]), and store the new tick.
- Otherwise it's movement. Record it.

`changedtick` also goes up when a buffer is reloaded from disk or modified by a plugin. Those moves get dropped as well, which is fine: you didn't move.

## Related

- [[what-counts-as-movement]]
