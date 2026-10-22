---
title: "ADR 0001: Standalone Lua Neovim plugin"
status: stable
tags: [decisions]
up: "[[decisions]]"
updated: 2026-10-22
---

# ADR 0001: Standalone Lua Neovim plugin

Accepted 2026-10-22.

## Context

The name "nvim-serenade" could have meant a Neovim config, a standalone plugin or colorscheme, or a client for the Serenade voice-coding app.

## Decision

nvim-serenade is a standalone Neovim plugin written in Lua.

## Consequences

- The layout follows `:help lua-plugin` ([[plugin-layout]]).
- User docs are vimdoc in `doc/` ([[vimdoc-vs-docs]]).
- What it records is decided in [[adr-0003-record-movement-not-edits]].
