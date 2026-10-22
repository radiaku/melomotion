---
title: Testing
status: stable
tags: [development]
up: "[[development]]"
updated: 2026-10-22
---

# Testing

Tests run with mini.test, each against a fresh child Neovim that receives typed keys ([[adr-0007-mini-test-child-neovim]]).

```sh
make test                                          # everything
make test FILE=tests/test_recorder.lua             # one file
make test CASE="pickers"                           # cases whose name contains the text
make test FILE=tests/test_recorder.lua CASE="edits are not recorded"
```

`CASE` matches against the file path, set names and case name joined by spaces. `tests/minimal_init.lua` reads both variables.

| File                      | Covers |
| ------------------------- | ------ |
| `tests/test_recorder.lua` | [[recording]] rules, with an in-memory `emit` |
| `tests/test_melomotion.lua` | session files, options, `:Melomotion`, `<Plug>` maps, health, help tags |

Patterns:

- `press(...)` sends each argument as its own input with a 10 ms pause, like separate key presses. Use one string (`"2j"`) for keys typed together.
- To read state right after typing, call `child.lua_get`. Its request is answered only after the scheduled `end_cycle()` has run ([[command-cycle]]).
- Pickers are tested with a stand-in float. Real Telescope was checked by hand ([[picker-landing]]).
- which-key and flash are stand-ins too. The which-key one's triggers must be buffer-local, as the real ones are, or a global `<Space>ef` wins and the test passes without exercising anything ([[key-reading-plugins]]).

Until something better exists, check by hand with [[local-dev-loop]].
