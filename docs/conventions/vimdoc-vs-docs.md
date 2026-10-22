---
title: doc/ vs docs/
status: stable
tags: [conventions]
up: "[[conventions]]"
updated: 2026-10-22
---

# doc/ vs docs/

There are two directories for two audiences. Don't mix them up.

- **`doc/melomotion.txt`** is vimdoc. It ships with the plugin, and users read it with `:help melomotion`. It covers behaviour: commands, mappings, options, the Lua API and the record format. A test runs `:helptags doc` and opens `:help melomotion-config`, so a broken tag fails `make check`. The generated `doc/tags` file isn't committed.
- **`docs/`** is this brain. It's for maintainers and Claude: why things are the way they are, plans, decisions. Users never see it.

A user-visible change updates `doc/melomotion.txt`. A change in design or rationale updates `docs/`. Some facts live in both, like the record format ([[event-schema]]), so change both together.

## Related

- [[plugin-layout]]
- [[note-rules]]
