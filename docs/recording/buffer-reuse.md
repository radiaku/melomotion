---
title: Buffer reuse
status: stable
tags: [recording]
up: "[[recording]]"
updated: 2026-10-22
---

# Buffer reuse

When you open a file from an empty, unnamed, unchanged buffer (the one Neovim starts with, or one from `:enew`), Neovim loads the file into that buffer instead of creating a new one. The buffer number stays the same.

Comparing numbers alone, that looked like staying in one buffer. A picker landing there was recorded as `cursor`, not `buffer`. `:edit file` was dropped completely, because `changedtick` moved and [[edit-filtering]] took it for an edit.

So a buffer counts as replaced when two things are both true:

- **It was unloaded.** A `BufUnload` for the current buffer marks the last location.
- **Its name changed.**

Each one alone happens in other cases, measured in 0.10.4:

| Command | Unloads | Renames |
| ------- | ------- | ------- |
| `:edit file` from an empty buffer | yes | yes |
| `:e!` | yes | no |
| `:w name`, `:saveas`, `:file` | no | yes |

`BufWipeout` isn't a usable signal either, since `:w name` on an unnamed buffer fires it too.
