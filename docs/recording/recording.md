---
title: Recording
status: planned
tags: [hub, recording]
up: "[[index]]"
updated: 2026-10-22
---

# Recording

What serenade records and how ([[adr-0003-record-movement-not-edits]]). The aim is to see how you move to and reach things in Neovim when you aren't editing.

- [[what-counts-as-movement]]: where movement ends and editing starts
- [[event-sources]]: which Neovim hooks capture which movement
- [[edit-filtering]]: dropping cursor moves that edits cause
- [[recording-cost]]: keeping hot hooks cheap
- [[recording-session]]: start, stop, save
- [[storage]]: where recordings go and in what format
