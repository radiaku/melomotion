---
title: What counts as movement
status: stable
tags: [recording]
up: "[[recording]]"
updated: 2026-10-22
---

# What counts as movement

melomotion records anything that changes **where you are** or **what you're looking at**, and nothing that changes the text.

| Recorded                                    | Example                         |
| ------------------------------------------- | ------------------------------- |
| Cursor motions in normal mode               | `w`, `}`, `f(`, `gg`, `%`       |
| Moving a visual selection                   | `vjj`, `Vip` ([[adr-0004-visual-selection-is-movement]]) |
| Jumps                                       | `<C-o>`, `<C-i>`, marks, `gd`   |
| Searches                                    | `/pat`, `?pat`, `n`, `*`        |
| Scrolling                                   | `<C-d>`, `zz`, `zt`             |
| Buffer, window and tab switches             | `:b`, `<C-w>w`, `gt`            |
| Ex commands that move you                   | `:42`, `:e file`, `:tabnew`     |
| Landing from a picker                       | Telescope, fzf-lua ([[picker-landing]]) |

| Not recorded                                | Why                             |
| ------------------------------------------- | ------------------------------- |
| Text changes (`dd`, `x`, `p`, `u`, `>>`)    | Editing ([[edit-filtering]])    |
| Operators that move the cursor (`yk`, visual `y`) | Operators, not navigation |
| Insert mode, including arrow keys in it     | Movement while editing          |
| Leaving insert mode (`<Esc>` steps left)    | Side effect of editing          |
| Keys of commands that move nothing (`yy`, `:w`) | Nothing moved               |
| The text of the buffer                      | Not needed ([[storage]])        |
