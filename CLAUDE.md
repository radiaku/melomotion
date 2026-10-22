# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

melomotion is a Neovim plugin in Lua. It records how you move around Neovim (motions, jumps, searches, scrolling, window, buffer and tab switches, landing from pickers) and ignores editing. It requires Neovim 0.10 or newer. Recording works. Reading recordings back hasn't been built yet. Undecided things are listed in `docs/decisions/open-questions.md`. Don't guess at them: ask, then record the answer as an ADR in `docs/decisions/`.

## Commands

```sh
make check                                  # fmt-check + lint + test; run before committing
make test                                   # all tests (the first run clones mini.nvim into deps/)
make test FILE=tests/test_recorder.lua      # one file
make test CASE="pickers"                    # cases whose "file set case" name contains the text
make fmt                                    # StyLua in place
make lint                                   # luacheck
nvim --clean --cmd "set rtp^=."             # try this checkout without any user config
```

StyLua and luacheck come from Mason. The Makefile adds `~/.local/share/nvim/mason/bin` to `PATH`.

## Architecture

- `plugin/melomotion.lua` runs at startup for every user. It only defines `:Melomotion` and the `<Plug>(melomotion-…)` maps, and requires modules inside callbacks. A test checks that nothing is loaded at startup.
- `recorder.lua` turns hooks into movement events and passes each one to an `emit` function. `init.lua` (the public API) pushes them into a `storage.lua` session, which writes JSON Lines to `stdpath("state")/melomotion/`. The recorder knows nothing about files, which is why its tests use an in-memory `emit`.
- `command.lua` owns the `:Melomotion` subcommands and every user message. The API stays silent.

## How recording works

Details and the reasoning behind each rule are in `docs/recording/`.

- **One event per finished command.** The first key of a command schedules `end_cycle()`, which compares the current location (tab, window, buffer, cursor, top line) with the last one. Scheduled callbacks run only after the command has finished and its `CursorMoved`/`WinScrolled` have fired. They never run between `f` and `(`. The exceptions are operator-pending mode, command-line mode and a plugin waiting in `getchar()` (which-key, flash). `end_cycle()` returns early in all three. which-key feeds the keys it read back to run them, so a cycle that waited and reads X X keeps one X.
- **Keys come from `on_key`'s `typed` argument.** That's what was pressed. Keys from mappings and macros arrive with `typed` empty and are ignored. Keys typed in insert, terminal, cmdline and prompt modes are text, so they're skipped. `CmdlineLeave` swaps a typed `:`, `/` or `?` for the full line.
- **Edits are filtered out.** In the same window and buffer (a reused empty buffer doesn't count as the same: it was unloaded and renamed), a cycle is dropped if `changedtick` moved, if `ModeChanged` flagged an operator or leaving insert or visual mode, or if the mode is insert. Window and buffer switches are never filtered.
- **Pickers.** While the current window is a float, keys are kept and its filetype becomes `via`. The landing gets both. Keys that moved nothing are kept for `async_window` ms, so a late jump such as LSP `gd` gets them, marked `async`.
- **Cost.** These hooks run on nearly every key. Keep `on_key` and the autocommands to flag-setting and appends, and do no I/O outside `storage.flush()`.

The record format is documented twice: `docs/recording/event-schema.md` and `:help melomotion-recordings` in `doc/melomotion.txt`. Change both together.

## Testing

Tests use mini.test with a child Neovim per case, and keys are typed through `child.type_keys`. That's real input, so they exercise the actual event-loop ordering. `press("f", "(")` sends separate inputs with a pause. `press("2j")` sends them together. Late-jump and timer tests sleep 50–250 ms. If one turns flaky, widen the margin rather than adding retries.

## docs/ brain

`docs/` is a tree of atomic notes linked with Obsidian-style `[[wikilinks]]`, for maintainers. User docs are vimdoc in `doc/`. Start at `docs/index.md` and read only the notes the task needs.

- One idea per note. File names are kebab-case and unique across `docs/`, because wikilinks resolve by name.
- Frontmatter: `title`, `status` (`planned` / `draft` / `stable` / `superseded`), `tags`, `up: "[[hub]]"` and `updated`. Each hub is named after its folder and lists every note in it.
- After renaming a note, run `grep -rn "\[\[old-name" docs/` and fix every link.
- When code makes a note wrong, fix the note in the same commit and bump `updated`.
- Never edit an accepted ADR. Write a new one and mark the old one `superseded`.
