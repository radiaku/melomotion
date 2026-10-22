---
title: Architecture
status: planned
tags: [hub, architecture]
up: "[[index]]"
updated: 2026-10-22
---

# Architecture

Everything here is planned; no code exists yet. These notes cover the plugin's shell, following Neovim's guide for Lua plugins (`:help lua-plugin`). The recording logic is under [[recording]].

- [[plugin-layout]]: what each directory holds
- [[lazy-loading]]: keeping startup cost close to zero
- [[configuration]]: `setup()` is optional
- [[commands-and-keymaps]]: user commands and `<Plug>` mappings
- [[health-check]]: `:checkhealth serenade`
