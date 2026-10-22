---
title: "ADR 0004: Moving a visual selection is movement"
status: stable
tags: [decisions]
up: "[[decisions]]"
updated: 2026-10-22
---

# ADR 0004: Moving a visual selection is movement

Accepted 2026-10-22.

## Context

Moving a visual selection moves the cursor, but a selection usually ends in an edit. It could have been counted either way.

## Decision

It counts as movement. Motions in visual mode are recorded with `mode` set to `v`, `V` or `^V`.

## Consequences

- An analysis can tell selection movement apart from plain navigation by `mode` ([[event-schema]]).
- The operator that ends the selection (`y`, `d`) is still not recorded ([[edit-filtering]]).
