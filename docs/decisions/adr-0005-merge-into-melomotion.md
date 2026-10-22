---
title: "ADR 0005: Continue in the melomotion repo"
status: stable
tags: [decisions]
up: "[[decisions]]"
updated: 2026-10-22
---

# ADR 0005: Continue in the melomotion repo

Accepted 2026-10-22.

## Context

melomotion (`radiaku/melomotion`) was an earlier attempt at the same idea. It logged keys with `vim.on_key`, grouped them with a 0.4 s timer and appended them to a text file. Its readme called it a beta that shouldn't be used yet. nvim-serenade then started from scratch on the same concept, so there were two projects for one plugin.

## Decision

Work continues in the melomotion repo, under the melomotion name. nvim-serenade's history is merged in. The old code is replaced by the design in [[recording]] and [[architecture]], not patched.

## Consequences

- The module is `require("melomotion")`, the command is `:Melomotion`, the mappings are `<Plug>(melomotion-…)` and the help page is `:help melomotion`.
- The old commands `:MelomotionStart` and `:MelomotionSave` and the old text log format are gone. Nobody depended on them.
- [[adr-0001-lua-neovim-plugin]] still holds. Only the name changed.
