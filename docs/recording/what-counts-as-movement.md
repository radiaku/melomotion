---
title: What counts as movement
status: planned
tags: [recording]
up: "[[recording]]"
updated: 2026-10-22
---

# What counts as movement

Serenade records anything that changes **where you are** or **what you're looking at**, and nothing that changes the text.

| Recorded                                      | Example                            |
| --------------------------------------------- | ---------------------------------- |
| Cursor motions in normal mode                 | `w`, `}`, `f(`, `gg`, `%`          |
| Jumps                                         | `<C-o>`, `<C-i>`, marks, `gd`      |
| Searches                                      | `/pat`, `?pat`, `n`, `*`           |
| Scrolling                                     | `<C-d>`, `zz`                      |
| Buffer, window and tab switches               | `:b`, `<C-w>w`, `gt`               |
| Opening files through pickers and explorers   | Telescope, fzf, yazi               |

| Not recorded                                  | Why                                |
| --------------------------------------------- | ---------------------------------- |
| Text changes (`dd`, `x`, `p`, `cw`, `>>`)     | Editing ([[edit-filtering]])       |
| Insert mode, including arrow keys in it       | Movement while editing             |
| The text of the buffer                        | Not needed; see [[storage]]        |

Visual mode is unclear: the selection moves the cursor, but it usually leads to an edit. See [[open-questions]].

## Related

- [[event-sources]]
