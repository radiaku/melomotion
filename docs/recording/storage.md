---
title: Storage
status: planned
tags: [recording]
up: "[[recording]]"
updated: 2026-10-22
---

# Storage

Proposed default (format not final, see [[open-questions]]):

- One file per session under `vim.fn.stdpath("data") .. "/serenade/"`.
- JSON Lines, one event per line, so a crashed session still leaves a readable file and the files are easy to process with other tools.
- Each event has a timestamp, the kind of event, the keys that caused it ([[event-sources]]), the buffer's file path, and the cursor position.

What isn't stored: buffer text. Search patterns and file paths are stored, and they can be sensitive, so recordings stay on the local machine. Serenade never sends them anywhere.

Writes happen off the hot path ([[recording-cost]]).
