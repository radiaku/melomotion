---
title: Architecture
status: stable
tags: [hub, architecture]
up: "[[index]]"
updated: 2026-10-22
---

# Architecture

The plugin's shell, built following Neovim's guide for Lua plugins (`:help lua-plugin`). The recording logic is under [[recording]].

- [[plugin-layout]]: what each file holds and how data flows
- [[lazy-loading]]: keeping startup cost close to zero
- [[configuration]]: options, and why `setup()` is optional
- [[commands-and-keymaps]]: `:Melomotion` and the `<Plug>` mappings
- [[health-check]]: `:checkhealth melomotion`
