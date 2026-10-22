---
title: Health check
status: stable
tags: [architecture]
up: "[[architecture]]"
updated: 2026-10-22
---

# Health check

`lua/melomotion/health.lua` returns a table with a `check()` function, and `:checkhealth melomotion` finds it on its own. It reports:

- the Neovim version, with an error below 0.10 ([[adr-0006-minimum-neovim-0-10]])
- the last bad option passed to `setup()`, if there was one ([[configuration]])
- whether `dir` exists and is writable ([[storage]])
- whether a session is recording, and to which file

A test runs it and checks that it reports no errors.
