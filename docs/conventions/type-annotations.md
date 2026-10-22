---
title: Type annotations
status: stable
tags: [conventions]
up: "[[conventions]]"
updated: 2026-10-22
---

# Type annotations

Annotate the public API and the options with LuaCATS (`---@class`, `---@param`, `---@return`). lua-language-server reads them, so users get completion and type checks for `setup()` options ([[configuration]]).

Prefix type names with `melomotion.` so they don't collide with other plugins' types in the user's workspace. The current types are `melomotion.Config`, `melomotion.UserConfig` (all fields optional), `melomotion.Session`, `melomotion.Location` and `melomotion.State`.

Nothing enforces them yet. `lua-language-server --check` could, and adding it is a [[tooling]] decision.
