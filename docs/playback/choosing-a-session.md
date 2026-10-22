---
title: Choosing a session
status: stable
tags: [playback]
up: "[[playback]]"
updated: 2026-10-22
---

# Choosing a session

- `:Melomotion show` opens the session being recorded. If nothing is recording, it opens the newest file in `dir` ([[storage]]).
- `:Melomotion show pick` lists every session with `vim.ui.select`, so it looks like whatever picker overrides it (Telescope, dressing, fzf-lua). Items read as `2026-10-22 15:23:36`, taken from the file name, and the running one is marked `(recording)`.
- A running session is shown with the records that are still waiting in memory, so you don't need `:Melomotion save` first, and showing it never writes the file.
- Sorting by file name sorts by age, because names start with the date and time.
- A line that isn't valid JSON, such as one cut short by a crash, is skipped.

The Lua API behind this is `require("melomotion").sessions()` and `.read(path?)`.
