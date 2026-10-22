---
title: "ADR 0008: StyLua and luacheck"
status: stable
tags: [decisions]
up: "[[decisions]]"
updated: 2026-10-22
---

# ADR 0008: StyLua and luacheck

Accepted 2026-10-22.

## Context

The project needs a formatter and a linter. Mason already installs StyLua and luacheck on this machine. selene isn't installed.

## Decision

StyLua formats the code (2-space indent, 100 columns, which matches the old melomotion style). luacheck lints it, with `vim` as a writable global. The Makefile puts Mason's `bin` directory on `PATH`.

## Consequences

- `make check` runs `fmt-check`, `lint` and `test` ([[tooling]]).
- Type checking with lua-language-server isn't wired up yet ([[type-annotations]]).
