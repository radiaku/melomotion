---
title: "ADR 0006: Minimum Neovim 0.10"
status: stable
tags: [decisions]
up: "[[decisions]]"
updated: 2026-10-22
---

# ADR 0006: Minimum Neovim 0.10

Accepted 2026-10-22.

## Context

The radia config targets 0.12.x, but this machine runs 0.10.4. The recorder needs `vim.on_key`'s second argument (the keys as typed), which arrived in 0.10. It also uses `vim.keycode`, `vim.fs.joinpath` and `vim.uv`, all from 0.10.

## Decision

melomotion supports Neovim 0.10 and newer.

## Consequences

- `:checkhealth melomotion` reports an error below 0.10 ([[health-check]]).
- Option validation is hand-written, because `vim.validate`'s signature changed in 0.11 ([[configuration]]).
- Storage handles 0.10 escaping `/` in JSON ([[storage]]).
- Once there's CI, it should run on 0.10 and on the latest stable release ([[open-questions]]).
