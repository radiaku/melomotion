---
title: Type annotations
status: planned
tags: [conventions]
up: "[[conventions]]"
updated: 2026-10-22
---

# Type annotations

Annotate the public API and the options table with LuaCATS (`---@class`, `---@param`, `---@return`). lua-language-server reads these, so users get completion and type checks for `setup()` options ([[configuration]]).

Prefix type names with `melomotion.` (for example `melomotion.Config`) so they don't collide with other plugins' types in the user's workspace.

`lua-language-server --check` can enforce them; whether it does is a [[tooling]] decision.
