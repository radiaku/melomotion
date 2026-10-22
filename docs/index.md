---
title: nvim-serenade
status: draft
tags: [hub]
updated: 2026-10-22
---

# nvim-serenade

This is the root of the project's brain: a tree of small notes linked with `[[wikilinks]]`. Start here, go down to a hub, then to the note you need.

nvim-serenade is a Neovim plugin written in Lua ([[adr-0001-lua-neovim-plugin]]). It records how you move around Neovim (motions, jumps, searches, switching buffers, windows and tabs, opening files) and ignores editing, so you can see how you reach things when you aren't changing text ([[adr-0003-record-movement-not-edits]]).

## Hubs

- [[recording]]: what gets recorded, how, and where it's stored
- [[architecture]]: how the plugin is laid out and loaded
- [[conventions]]: rules for the code and the user-facing docs
- [[development]]: tooling, tests, and running this checkout
- [[decisions]]: ADRs and open questions
- [[meta]]: how this brain is written and kept in shape
