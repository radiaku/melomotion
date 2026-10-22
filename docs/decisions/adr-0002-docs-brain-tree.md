---
title: "ADR 0002: docs/ as an atomic, linked brain tree"
status: stable
tags: [decisions]
up: "[[decisions]]"
updated: 2026-10-22
---

# ADR 0002: docs/ as an atomic, linked brain tree

Accepted 2026-10-22.

## Context

Design knowledge needs a home that both people and Claude can navigate without reading everything at once.

## Decision

`docs/` is a tree of atomic notes: [[index]], then hubs, then notes. Notes link with Obsidian-style `[[wikilinks]]`. The radia Neovim config already has an Obsidian integration, so backlinks and the graph view work without extra setup.

## Consequences

- File names must be unique across `docs/` ([[note-rules]]).
- GitHub's markdown view shows wikilinks as plain text.
- Every note carries the same [[frontmatter]].
