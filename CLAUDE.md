# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project state

nvim-serenade is a Neovim plugin written in Lua. It records how you move around Neovim (motions, jumps, searches, buffer, window and tab switches, opening files through pickers) and ignores editing, so you can see how you reach things when you aren't changing text. There's no code yet, only this file and `docs/`. Several things are still undecided, including the minimum Neovim version, the tooling and the storage format. They're listed in `docs/decisions/open-questions.md`. Don't guess at them. Ask, then record each answer as an ADR in `docs/decisions/`.

## Commands

There's no formatter, linter or test runner yet (candidates are in `docs/development/tooling.md`). Once one is added, put its exact commands here, including how to run a single test.

Until then:

```sh
nvim --clean --cmd "set rtp^=."   # run this checkout on its own, without your config
```

Run `:checkhealth serenade` once `lua/serenade/health.lua` exists.

## Architecture (planned)

The layout follows Neovim's guide for Lua plugins (`:help lua-plugin`). Details are in `docs/architecture/`.

- `plugin/serenade.lua` runs at startup for every user. It only defines user commands and `<Plug>` mappings, and it requires modules inside callbacks, never at the top level.
- `require("serenade")` (`lua/serenade/init.lua`) is the public API. Every other module under `lua/serenade/` is internal.
- `setup(opts)` is optional. It only merges user options over the defaults in `lua/serenade/config.lua`, and calling it twice must be safe.
- There are no default keymaps. The plugin exposes `<Plug>(serenade-…)` mappings instead.
- `doc/serenade.txt` is user help (vimdoc, `:help serenade`) and ships with the plugin. `docs/` is the maintainers' brain and doesn't ship. A user-visible change updates `doc/`. A change in design or rationale updates `docs/`.

## Recording model (planned)

Details are in `docs/recording/`.

- Two kinds of hook work together: `vim.on_key` gives the keys that caused a movement, and autocommands (`CursorMoved`, `WinScrolled`, `BufEnter`, `WinEnter`, `TabEnter`, `CmdlineLeave` for `/` and `?`) give its effect. A movement event takes the keys buffered since the previous one.
- Edits are left out in two ways. `CursorMoved` never fires in insert mode, and a move made while `b:changedtick` changed comes from an edit, so it's dropped.
- These hooks fire on nearly every key press. Inside them, only append to an in-memory list. Do file I/O on save, on stop, on `VimLeavePre` or from a timer. When recording is off, no hooks are registered at all.
- Recording is opt-in through `:Serenade start`, `:Serenade stop` and `:Serenade save`. Recordings stay local under `stdpath("data")/serenade/`.

## docs/ brain

`docs/` is a tree of atomic notes linked with Obsidian-style `[[wikilinks]]`. Start at `docs/index.md`, follow the hubs down, and read only the notes the task needs.

Rules for editing it (full version in `docs/meta/note-rules.md`):

- One idea per note, short enough to fit on one screen.
- File names are kebab-case and unique across all of `docs/`, because wikilinks resolve by name, not path.
- Every note has frontmatter with `title`, `status` (`planned` / `draft` / `stable` / `superseded`), `tags`, `up: "[[hub]]"` and `updated`.
- Each hub is named after its folder (`architecture/architecture.md`). Add every new note to its hub.
- After renaming a note, run `grep -rn "\[\[old-name" docs/` and fix every link.
- When a code change makes a note wrong, fix the note in the same commit and bump `updated`.
- Never edit an accepted ADR. Write a new one and mark the old one `superseded`.
