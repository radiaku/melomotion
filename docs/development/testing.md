---
title: Testing
status: planned
tags: [development]
up: "[[development]]"
updated: 2026-10-22
---

# Testing

Tests run in headless Neovim, so they exercise real buffers and the real API instead of mocks.

The runner isn't chosen yet ([[open-questions]]). Candidates:

- busted with nlua as the interpreter, run through `luarocks test` (works well if [[versioning]] goes the luarocks way)
- plenary.nvim's harness (`PlenaryBustedDirectory`)
- mini.test from mini.nvim

Whichever wins, `CLAUDE.md` must say how to run the whole suite, one file, and one test case.

Until then, test by hand: [[local-dev-loop]].
