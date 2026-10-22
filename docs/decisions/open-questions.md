---
title: Open questions
status: draft
tags: [decisions]
up: "[[decisions]]"
updated: 2026-10-22
---

# Open questions

When one of these is answered, write an ADR ([[decisions]]), remove it from this list, and update the notes that link here.

- **Reading recordings back.** This is the next feature. Options are an in-editor report (`:Melomotion report`), an export for other tools, or both. See [[recording-session]] and [[event-schema]].
- **Old sessions.** Should old files be rotated or capped, or kept forever? See [[storage]].
- **Distribution.** luarocks (rockspec, `luarocks test`) or git tags only. See [[versioning]].
- **License.**
- **CI.** Where checks run, if anywhere. If it's added, run on 0.10 and on the latest stable release ([[adr-0006-minimum-neovim-0-10]]).
