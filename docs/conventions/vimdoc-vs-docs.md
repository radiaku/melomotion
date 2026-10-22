---
title: doc/ vs docs/
status: planned
tags: [conventions]
up: "[[conventions]]"
updated: 2026-10-22
---

# doc/ vs docs/

There are two directories for two audiences. Don't mix them up.

- **`doc/serenade.txt`** is vimdoc. It ships with the plugin, and users read it with `:help serenade`. It covers behaviour: commands, options, `<Plug>` maps, the Lua API. To check that its tags resolve, run `:helptags doc`. The generated `doc/tags` file isn't committed.
- **`docs/`** is this brain. It's for maintainers and Claude: why things are the way they are, plans, decisions. Users never see it.

A user-visible change updates `doc/serenade.txt`. A change in design or rationale updates `docs/`.

## Related

- [[plugin-layout]]
- [[note-rules]]
