---
title: "ADR 0007: Test with mini.test and a child Neovim"
status: stable
tags: [decisions]
up: "[[decisions]]"
updated: 2026-10-22
---

# ADR 0007: Test with mini.test and a child Neovim

Accepted 2026-10-22.

## Context

What needs testing is event-loop behaviour: the order of `on_key`, autocommands and scheduled callbacks ([[command-cycle]]). That only happens when real input reaches a running Neovim. Calling the recorder's functions directly wouldn't exercise it.

## Decision

Tests use mini.test. Each case restarts a child Neovim (`MiniTest.new_child_neovim()`) and types keys with `child.type_keys()`, which goes through `nvim_input` just as a person typing does. `make` clones mini.nvim's `stable` branch into `deps/`.

## Consequences

- mini.test refuses RPC calls while the child is waiting for a key, so a test that types `f` and then `(` can't hang.
- Tests for timers and late jumps sleep for 50–250 ms. If one turns flaky, widen its margin rather than retrying it.
- See [[testing]] for how to run one file or one case.
