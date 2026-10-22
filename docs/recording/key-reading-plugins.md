---
title: Key-reading plugins
status: stable
tags: [recording]
up: "[[recording]]"
updated: 2026-10-22
---

# Key-reading plugins

Some plugins read the rest of a command themselves with `getchar()`. which-key reads the keys after a trigger like `<Space>` or `g`, then feeds the whole sequence back with `feedkeys(…, "mit")` to run it. flash reads the character after `s` and jumps.

Left alone, that breaks the recording in two ways:

- **The cycle ends too early.** Scheduled callbacks run while `getchar()` waits, unlike Neovim's own waits ([[command-cycle]]). `end_cycle()` saw that nothing had moved yet and dropped the keys, so flash's `ss` came out as `s`.
- **Keys arrive twice.** The `t` flag makes fed keys look typed, so `on_key` sees which-key's replay as well as the keys it read. `<Space>ef` came out as `f<Space>ef` and `gg` as `ggg`.

What the recorder does:

- While `state()` contains `S`, a plugin is waiting in `getchar()`. `end_cycle()` keeps the pending keys and notes how many bytes there are. Measured in 0.10.4, `S` is there during `getchar()` and missing whenever Neovim waits for a new command in normal, visual or insert mode.
- If a cycle that waited ends with keys of the form X X, it keeps one X. The second X has to start after the last wait. Otherwise those are keys the plugin read, so `ss` stays `ss`.

Checked with real which-key, neo-tree and Telescope. The tests use stand-ins ([[testing]]).

**Limit:** when keys reach Neovim in one chunk (it was busy), `getchar()` never waits. A mapping like `<Space>ef` is still recorded once, because Neovim matches it before which-key's trigger. A built-in command routed through a trigger, like `gg`, comes out doubled (`gggg`).
