---
title: "ADR 0009: Show recordings as lyrics"
status: superseded
tags: [decisions]
up: "[[decisions]]"
updated: 2026-10-22
---

# ADR 0009: Show recordings as lyrics

Accepted 2026-10-22. Superseded by [[adr-0010-lyrics-as-a-song-sheet]], which keeps the command and replaces the layout.

## Context

Recording worked, but the only way to read a session was the raw JSON Lines file. How to read recordings back was an [[open-questions]] item: an in-editor report, an export for other tools, or both. The maintainer asked for `:Melomotion show`, which shows the keys as text "like lyrics", for example `w  <Space>ff`.

## Decision

- `:Melomotion show` opens a session as lyrics in a scratch buffer: one verse per window or file you were in, headed by where you went and the keys that took you there ([[lyrics-view]]).
- Runs of the same keys fold into one word with a count (`j×7`).
- Keys use Vim notation (`<Space>ff`, `<C-W>v`), the same as in the recording and in mappings, not a friendlier `space+ff`.
- With no argument it shows the session being recorded or, if none is, the newest. `:Melomotion show pick` lets you choose ([[choosing-a-session]]).

## Consequences

- `:Melomotion` takes an optional second argument, so `nargs` became `+` and completion knows each subcommand's arguments ([[commands-and-keymaps]]).
- The renderer (`lyrics.lua`) is pure, so most of it is tested without a window.
- An export for other tools is still open.
