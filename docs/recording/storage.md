---
title: Storage
status: stable
tags: [recording]
up: "[[recording]]"
updated: 2026-10-22
---

# Storage

- **Where:** `stdpath("state")/melomotion/`, which is `~/.local/state/nvim/melomotion/` on macOS and Linux. The `dir` option changes it. It's state rather than data because it's a log, and the old melomotion used state too.
- **Files:** one per session, named `YYYYMMDD-HHMMSS-<pid>.jsonl`. The pid keeps two Neovims started in the same second apart.
- **Format:** JSON Lines. Each flush appends, so a crash loses only what was still waiting ([[recording-cost]]). The fields are in [[event-schema]].
- **Escaping:** Neovim 0.10's `vim.json.encode` writes `/` as `\/`. Storage undoes that, but only when the running Neovim escapes (checked once at load). Newer versions don't escape, and backslashes in search patterns survive either way.

Buffer text is never stored. File paths are, and so are search patterns and the `:` commands that moved you. Files are only ever written to `dir`.
