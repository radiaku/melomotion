---
title: Open questions
status: draft
tags: [decisions]
up: "[[decisions]]"
updated: 2026-10-22
---

# Open questions

When one of these is answered, write an ADR ([[decisions]]), remove it from this list, and update the notes that link here.

- **Visual mode.** Does moving a visual selection count as movement, or as the start of an edit? See [[what-counts-as-movement]].
- **Reading recordings back.** Options are an in-editor report (`:Serenade report`), an export for other tools, or both. See [[recording-session]].
- **Storage format.** JSON Lines is the proposal in [[storage]]. Still open: rotating or capping old sessions.
- **Minimum Neovim version.** The radia config targets 0.12.x, but this machine runs 0.10.4. `vim.on_key` only passes the `typed` argument from 0.10 on ([[event-sources]]), so 0.10 is the practical floor.
- **Test runner.** See [[testing]].
- **Formatter, linter, type checks.** See [[tooling]].
- **Distribution.** luarocks (rockspec, `luarocks test`) or git tags only. See [[versioning]].
- **License.**
- **CI.** Where checks run, if anywhere.
