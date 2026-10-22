---
title: Lyrics view
status: stable
tags: [playback]
up: "[[playback]]"
updated: 2026-10-22
---

# Lyrics view

`:Melomotion show` lays a session out like song lyrics. The keys you moved with are the words, and each window or file you were in is a verse.

```text
── melomotion · 2026-10-22 15:23 · 24s ──────────────────

♪ neo-tree filesystem [1]   ← <Space>ef
  k×5  j  k  gg  j×7

♪ docs/conventions/conventions.md   ← o
  j

♪ deps/mini.nvim/CONTRIBUTING.md   ← <C-H>
♪ docs/conventions/conventions.md   ← <C-L>
```

- **Header:** the start date and time, and how long the session ran (start to last record).
- **Verses:** the first one is where you started. Every `tab`, `window` or `buffer` movement starts a new one, named after where you landed, with the keys that took you there after `←` and the picker's filetype in parentheses ([[picker-landing]]).
- **Names:** files under the session's `cwd` are shown relative to it, other files with `~`, and a buffer with no name as `[No Name]`.
- **Words:** `cursor` and `scroll` movements, in [[event-schema]] notation. A run of the same keys folds into `j×7`. Movements with no keys (a timer, a plugin) are left out.
- **Spacing:** verses with no words stack without a blank line, so a run of switches reads as one block. Lines wrap at the window's width.

The buffer is a scratch buffer named `melomotion://<file>`, with filetype `melomotion` (highlighting in `syntax/melomotion.lua`). `q` closes it. Showing the same session again replaces it.
