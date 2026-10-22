---
title: "ADR 0003: Record movement, not edits"
status: stable
tags: [decisions]
up: "[[decisions]]"
updated: 2026-10-22
---

# ADR 0003: Record movement, not edits

Accepted 2026-10-22.

## Context

A lot of time in Neovim goes into moving: motions, jumps, searches, switching buffers and windows, opening files through pickers. Nothing shows how that time is spent, or which ways of getting to things actually get used.

## Decision

serenade records navigation and access, and ignores editing. It records how you got somewhere (the keys) and where you ended up, but never what you changed.

## Consequences

- The line between movement and editing is defined in [[what-counts-as-movement]] and enforced by [[edit-filtering]].
- Hooks fire on almost every key press, so cost is a first-class constraint ([[recording-cost]]).
- Recording is opt-in per session ([[recording-session]]).
