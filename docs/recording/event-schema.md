---
title: Event schema
status: stable
tags: [recording]
up: "[[recording]]"
updated: 2026-10-22
---

# Event schema

Every line in a session file has `t` (milliseconds since the Unix epoch) and `kind`.

| kind     | Other fields     |
| -------- | ---------------- |
| `start`  | `nvim` (version), `cwd` |
| `stop`   | none             |
| `tab`, `window`, `buffer`, `cursor`, `scroll` | the movement fields below |

A movement's kind is the biggest thing that changed, so a jump to another tab is `tab` even if the buffer changed too.

| Field     | Meaning |
| --------- | ------- |
| `keys`    | What you typed, in `keytrans()` form (`2j`, `<C-W>v`, `<Space>ff`), or the whole command line (`:42`, `/foo`). Empty when nothing you typed caused it. |
| `mode`    | The first letter of `mode()`: `n`, or `v`, `V`, `^V` for a visual selection. `i` appears when a picker lands you in insert mode. |
| `from`, `to` | `{ file, ft, line, col, top }`. `line` counts from 1, `col` is a 0-based byte index, and `top` is the first line on screen. |
| `via`     | Filetype of the float you came through ([[picker-landing]]). Absent otherwise. |
| `async`   | `true` when the keys were credited later ([[late-jumps]]). Absent otherwise. |

The user-facing version of this is in `doc/melomotion.txt` (`:help melomotion-recordings`). Change both together ([[vimdoc-vs-docs]]).
