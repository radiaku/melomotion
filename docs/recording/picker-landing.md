---
title: Picker landing
status: stable
tags: [recording]
up: "[[recording]]"
updated: 2026-10-22
---

# Picker landing

Pickers (Telescope, fzf-lua and the like) run in floating windows.

- While the current window is a float, `end_cycle()` records nothing. It keeps the pending keys and stores the float's filetype as `via` (`"float"` when it has none).
- Inside the picker you type in insert or terminal mode, so the query is never recorded.
- When you land in a normal window, the movement gets the keys that opened the picker, plus `via`. For example, `keys = "<Space>ff"` or `":Telescope find_files"`, with `via = "TelescopePrompt"`.
- Cancelling takes you back to where you were. Nothing moved, so nothing is recorded, and the keys are dropped.
- A landing skips [[edit-filtering]]. Pickers often leave insert mode as they land, which would otherwise look like `<Esc>` moving the cursor.

Only the current window matters, so floats you never enter (hover docs, notifications) change nothing.

Checked against real Telescope in a clean Neovim (find_files opened from a mapping, opened from `:Telescope`, and cancelled). The test suite uses a small stand-in picker ([[testing]]).
