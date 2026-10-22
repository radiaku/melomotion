---
title: Recording
status: stable
tags: [hub, recording]
up: "[[index]]"
updated: 2026-10-22
---

# Recording

What melomotion records and how ([[adr-0003-record-movement-not-edits]]). The aim is to see how you move to and reach things in Neovim when you aren't editing. The code is `lua/melomotion/recorder.lua`.

- [[what-counts-as-movement]]: where movement ends and editing starts
- [[command-cycle]]: one event per finished command, and why that works
- [[event-sources]]: which hooks feed the recorder
- [[edit-filtering]]: dropping cursor moves caused by edits and operators
- [[picker-landing]]: crediting a picker's result to the keys that opened it
- [[late-jumps]]: crediting jumps that arrive after their command
- [[recording-cost]]: keeping per-key work tiny
- [[recording-session]]: start, stop, save
- [[storage]]: where session files go
- [[event-schema]]: what one recorded line contains
