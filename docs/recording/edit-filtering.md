---
title: Edit filtering
status: stable
tags: [recording]
up: "[[recording]]"
updated: 2026-10-22
---

# Edit filtering

When a [[command-cycle]] ends in the same window and buffer it started in ([[buffer-reuse]] covers what "same buffer" means), the movement is dropped if any of these hold:

- **`changedtick` went up.** An edit moved the cursor (`dd`, `p`, `u`, `J`, `>>`). A change from somewhere else, like format-on-save, also bumps it. `TextChanged` schedules a cycle for those, so the baseline catches up before your next motion.
- **The skip flag is set.** `ModeChanged` sets it when you enter operator-pending mode (which covers `yk`), when you leave insert, replace or terminal mode (`<Esc>` steps the cursor left), and when you leave visual mode (visual `y` jumps back to the start of the selection).
- **You're in insert, replace or terminal mode.** The window scrolled while you typed.

A dropped cycle also throws away its keys, so `dw` followed by `j` records just `j`.

Switching window or buffer is never filtered: switching is always navigation. Landing from a picker skips these checks too ([[picker-landing]]).
