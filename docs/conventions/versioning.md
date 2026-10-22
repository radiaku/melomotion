---
title: Versioning
status: planned
tags: [conventions]
up: "[[conventions]]"
updated: 2026-10-22
---

# Versioning

Releases follow SemVer and are tagged `vX.Y.Z`.

The public surface is `require("serenade")`, the user commands, the `<Plug>` mappings ([[commands-and-keymaps]]) and the options ([[configuration]]). Breaking any of them needs a major version bump. Internal modules ([[plugin-layout]]) can change freely.

How releases are distributed (luarocks, or git tags only) is still open: [[open-questions]].
