---
title: Playback
status: stable
tags: [hub, playback]
up: "[[index]]"
updated: 2026-10-22
---

# Playback

Reading recordings back, inside Neovim ([[adr-0009-show-recordings-as-lyrics]]). The code is `lua/melomotion/lyrics.lua` (records in, lines out) and the `show` handler in `command.lua`.

- [[lyrics-view]]: how a session is laid out as verses
- [[choosing-a-session]]: which session `:Melomotion show` opens
