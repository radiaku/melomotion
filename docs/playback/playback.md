---
title: Playback
status: stable
tags: [hub, playback]
up: "[[index]]"
updated: 2026-10-22
---

# Playback

Reading recordings back, inside Neovim, as a song sheet ([[adr-0010-lyrics-as-a-song-sheet]]). The code is `lua/melomotion/lyrics.lua` (records in, lines out) and the `show` handler in `command.lua`.

- [[lyrics-view]]: how a session is laid out as a song
- [[choosing-a-session]]: which session `:Melomotion show` opens
